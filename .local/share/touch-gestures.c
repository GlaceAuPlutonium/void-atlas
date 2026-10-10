/*
 * 'smart' gestures on trackpad edge : volume, brightness, media control
 * rewrite in C of Ayuz's implementation of Asus' Smart Gestures, check the original project at https://github.com/Traciges/Ayuz
 *
 * left :  volume
 * right : brightness
 * top : media +- 5s
 *
 * build : cc -O2 -Wall -o touch-gestures touch-gestures.c $(pkg-config --cflags --libs libevdev)
 * syntax : touchpad-edge [-d] [/dev/input/eventN] (-d for debug)
 */
#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <libevdev/libevdev.h>
#include <signal.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EDGE 0.04 /* edge size (width/height %) */
#define STEP 0.05 /* sliding required for one step (size %)  */

extern char **environ;
enum zone { IDLE, CLASSIFY, LEFT, RIGHT, TOP, OTHER };
static const char *zone_name[] = { "idle", "classify", "left", "right", "top", "other" };
static int debug;

static void run(char *const argv[])
{
	posix_spawn_file_actions_t fa;
	posix_spawnattr_t at;
	sigset_t def;
	pid_t pid;

	posix_spawn_file_actions_init(&fa);
	posix_spawn_file_actions_addopen(&fa, 1, "/dev/null", O_WRONLY, 0);
	posix_spawn_file_actions_addopen(&fa, 2, "/dev/null", O_WRONLY, 0);
	/* SIG_IGN on SIGCHLD inherited through exec : reset it to default in the child */
	sigemptyset(&def);
	sigaddset(&def, SIGCHLD);
	posix_spawnattr_init(&at);
	posix_spawnattr_setsigdefault(&at, &def);
	posix_spawnattr_setflags(&at, POSIX_SPAWN_SETSIGDEF);
	if (posix_spawnp(&pid, argv[0], &fa, &at, argv, environ) != 0 && debug)
		fprintf(stderr, "can't launch %s\n", argv[0]);
	posix_spawnattr_destroy(&at);
	posix_spawn_file_actions_destroy(&fa);
}

/* dir > 0 : up (left/right edge) or right (top edge) */
static void act(enum zone z, int dir)
{
	if (debug)
		printf("%s %s\n", zone_name[z], dir > 0 ? "+" : "-");
	switch (z) {
	case LEFT:
		run((char *const[]){ "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0", NULL });
		run((char *const[]){ "wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@",
				     dir > 0 ? "2%+" : "2%-", NULL });
		break;
	case RIGHT:
		run((char *const[]){ "brightnessctl", "set", dir > 0 ? "5%+" : "5%-", NULL });
		break;
	case TOP:
		run((char *const[]){ "playerctl", "position", dir > 0 ? "5+" : "5-", NULL });
		break;
	default:
		break;
	}
}

static int is_touchpad(struct libevdev *dev)
{
	const char *name = libevdev_get_name(dev);

	return name && strcasestr(name, "touchpad") && !strcasestr(name, "numpad") &&
	       libevdev_has_event_code(dev, EV_ABS, ABS_MT_POSITION_X) &&
	       libevdev_has_event_code(dev, EV_ABS, ABS_MT_POSITION_Y);
}

static struct libevdev *open_touchpad(const char *forced)
{
	struct libevdev *dev = NULL;
	char path[300];
	struct dirent *de;
	DIR *d;
	int fd;

	if (forced) {
		fd = open(forced, O_RDONLY);
		if (fd >= 0 && libevdev_new_from_fd(fd, &dev) == 0)
			return dev;
		return NULL;
	}
	d = opendir("/dev/input");
	if (!d)
		return NULL;
	while ((de = readdir(d))) {
		if (strncmp(de->d_name, "event", 5))
			continue;
		snprintf(path, sizeof path, "/dev/input/%s", de->d_name);
		fd = open(path, O_RDONLY);
		if (fd < 0)
			continue;
		if (libevdev_new_from_fd(fd, &dev) == 0) {
			if (is_touchpad(dev)) {
				closedir(d);
				return dev;
			}
			libevdev_free(dev);
		}
		close(fd);
	}
	closedir(d);
	return NULL;
}

int main(int argc, char **argv)
{
	const char *forced = NULL;
	struct libevdev *dev;
	struct input_event ev;
	enum zone zone = IDLE;
	int x = 0, y = 0, anchor = 0, multi = 0, slot = 0, rc;
	int xmin, xmax, ymin, ymax, use_mt;

	for (int i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-d"))
			debug = 1;
		else
			forced = argv[i];
	}
	signal(SIGCHLD, SIG_IGN); /* launched wpctl/brightnessctl processes automatically repeated */

	dev = open_touchpad(forced);
	if (!dev) {
		fprintf(stderr, "No touchpad found (user in input group ? touchpad input owned by user ?)\n");
		return 1;
	}
	/* coordinates source : ABS_X/Y emulated if here, else slot 0 of MT */
	use_mt = !libevdev_has_event_code(dev, EV_ABS, ABS_X);
	xmin = libevdev_get_abs_minimum(dev, use_mt ? ABS_MT_POSITION_X : ABS_X);
	xmax = libevdev_get_abs_maximum(dev, use_mt ? ABS_MT_POSITION_X : ABS_X);
	ymin = libevdev_get_abs_minimum(dev, use_mt ? ABS_MT_POSITION_Y : ABS_Y);
	ymax = libevdev_get_abs_maximum(dev, use_mt ? ABS_MT_POSITION_Y : ABS_Y);
	int edge_l = xmin + EDGE * (xmax - xmin), edge_r = xmax - EDGE * (xmax - xmin);
	int edge_t = ymin + EDGE * (ymax - ymin);
	int step_x = STEP * (xmax - xmin), step_y = STEP * (ymax - ymin);

	if (debug)
		printf("%s : x %d-%d, y %d-%d\n", libevdev_get_name(dev), xmin, xmax, ymin, ymax);

	for (;;) {
		rc = libevdev_next_event(dev, LIBEVDEV_READ_FLAG_NORMAL | LIBEVDEV_READ_FLAG_BLOCKING, &ev);
		if (rc == LIBEVDEV_READ_STATUS_SYNC) { /* events lost: starts from zeo */
			while (libevdev_next_event(dev, LIBEVDEV_READ_FLAG_SYNC, &ev) == LIBEVDEV_READ_STATUS_SYNC)
				;
			zone = IDLE;
			continue;
		}
		if (rc == -EAGAIN || rc == -EINTR)
			continue;
		if (rc < 0) {
			fprintf(stderr, "reading : %s\n", strerror(-rc));
			return 1;
		}

		if (ev.type == EV_ABS) {
			if (use_mt && ev.code == ABS_MT_SLOT) {
				slot = ev.value;
				if (slot > 0)
					multi = 1;
			} else if (use_mt && slot == 0 && ev.code == ABS_MT_POSITION_X)
				x = ev.value;
			else if (use_mt && slot == 0 && ev.code == ABS_MT_POSITION_Y)
				y = ev.value;
			else if (!use_mt && ev.code == ABS_X)
				x = ev.value;
			else if (!use_mt && ev.code == ABS_Y)
				y = ev.value;
		} else if (ev.type == EV_KEY) {
			if (ev.code == BTN_TOUCH && ev.value == 1) {
				zone = CLASSIFY;
			} else if (ev.code == BTN_TOUCH && ev.value == 0) {
				zone = IDLE;
				multi = 0;
			} else if ((ev.code == BTN_TOOL_DOUBLETAP || ev.code == BTN_TOOL_TRIPLETAP ||
				    ev.code == BTN_TOOL_QUADTAP || ev.code == BTN_TOOL_QUINTTAP) && ev.value == 1) {
				multi = 1;
			}
		} else if (ev.type == EV_SYN && ev.code == SYN_REPORT) {
			/* one finger only */
			if (multi && zone != IDLE)
				zone = OTHER;

			if (zone == CLASSIFY) {
				/* zone determined from 1st contact */
				if (x < edge_l) {
					zone = LEFT;
					anchor = y;
				} else if (x > edge_r) {
					zone = RIGHT;
					anchor = y;
				} else if (y < edge_t) {
					zone = TOP;
					anchor = x;
				} else {
					zone = OTHER;
				}
				if (debug)
					printf("zone : %s (x=%d y=%d)\n", zone_name[zone], x, y);
			} else if (zone == LEFT || zone == RIGHT) {
				int dy = y - anchor;

				if (abs(dy) >= step_y) {
					anchor = y;
					act(zone, dy < 0 ? 1 : -1);
				}
			} else if (zone == TOP) {
				int dx = x - anchor;

				if (abs(dx) >= step_x) {
					anchor = x;
					act(zone, dx > 0 ? 1 : -1);
				}
			}
		}
	}
}
