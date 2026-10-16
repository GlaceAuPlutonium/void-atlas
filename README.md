# This repo is still being built and a work in project

A collection of dotfiles and system-level optimisation and configuration for Asus laptops, aimed at Void Linux user. \
\
This repo serves two purposes :
1. My daily-driver setup
2. Some collection of Void Linux and hardware-specific tweaks, config and info you may use if you want

I've tried documenting everything in this setup and explaining how everything works, so check the README below ! ***[below doesn't exists for now]***

Wallpapers available on [void-atlas-wp](https://codeberg.org/GlaceAuPlutonium/void-atlas-wp) !

# Main components

| Component | Choice | Notes |
| :--- | :--- | :--- |
| **Distro** | [Void Linux](https://voidlinux.org/) | Independent, lightweight, systemd-free, musl-compatible, stable rolling-release GNU/Linux distribution based on the XBPS package manager. |
| **WM** | [Niri](https://github.com/niri-wm/niri) | Scrollable-tiling Wayland compositor. |
| **Desktop Shell** | [Noctalia-Shell](https://noctalia.dev/) | A beautiful, minimal desktop shell for Wayland. |
| **Terminal** | [kitty](https://github.com/kovidgoyal/kitty) | Fast, feature-rich, GPU-based terminal. |
| **Shell** | [ZSH](https://www.zsh.org/) | Powerful shell. |
| **Launcher** | [Wofi](https://github.com/SimplyCEO/wofi) | Launcher/menu program for wlroots-based Wayland compositors. |
| **File Explorer** | [Yazi](https://yazi-rs.github.io/) | Blazing fast, terminal-based file explorer written in Rust. |
| **Theme** | [TokyoNight](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) | Really nice dark theme for GTK apps with overall purple/dark-blue tints. |
| **Font** | [Caskaydia Cove](https://www.nerdfonts.com/font-downloads) | A fun, monospaced Nerd Font. |
| **IDE** | [Zed](https://zed.dev/) | Lightning fast, Rust-based minimal code editor. |
| **Bootloader** | [VisorBootManager](https://github.com/IO-ZetZor/Visor-BootManager) | Minimal, fast, graphical UEFI boot manager that actually looks from this decade. |

*Note* : **Noctalia-Shell = Noctalia-V4** (Quickshell fork). This is not the newer Noctalia-V5 (C++) shell. I am not switching for now. This repo includes compiled .xbps packages and build template for noctalia-qs and noctalia-shell. See below for more.

### Hardware
This setup is being tested on the following hardware : 
- **Asus Vivobook S16 OLED M5606WA**
- **CPU** : Ryzen AI 9 HX 370
- **iGPU** : Radeon 890M
- **RAM** : 32GB LPDDR5X-7500
- **Display** : 16" 3200x2000 120Hz OLED
- **Wifi** : MediaTek MT7922

### Repositories
There are 2 repositories :
- [Codeberg](https://codeberg.org/GlaceAuPlutonium/void-atlas) : Main repo. Please go there for PRs, issues, dicussions, wiki (there isn't a wiki for now), etc..
- [Github](https://github.com/GlaceAuPlutonium/void-atlas) : Mirror repo. Synced 1h appart from main one.

### Disclaimer
This is a personal, hardware-specific setup. This isn't a ready-to-go install script for everyone. You can use these resources and adapt them to your system, but blindly copying things may break your setup. Don't be dumb, check what X thing do before applying it.

# Installation
first need to remake the install scripts and then explain evertyhing

# Documentation
i havent even finished writting the installation section and scripts what kind of documentation are you expecting 

# Others, notes, bug, etc...
## MT7922 WiFi chip being capped at 3dBm of power
This is the biggest problem right now on this computer, and possibly other similar setup. **Currently haven't found a fix.** \
The WiFi chip gets stuck in lower power mode and won't pull above 3dBm of power, as opposed to the ~15-20dBm it should normally draw, which makes the WiFi range absolutely abysmal (No wifi signal above 12m, after several tests). \
I suspect this is due to some specific SAR table (which regulates wireless devices power draws based on local regulations) being exposed by the laptop firmware, but the wifi driver fails to read it, and caps the chip into some "safe" or "low power" mode, which also makes txpower also sends back the 3dBm value. \
\
Here's some investigation/debugging report showing what was done, tested etc... if you feel interested. Maybe you'll find something useful in there. Sorry if it's poorly written. \
\
### Breakdown of wifi mt7921/mt7922 debug - TX power capped at 3dBm
Symptom : obnoxiously bad signal range in a room "far" from router (12 meters, ping 6000-7000ms), wavemon shows tx power: 3dBm intsead of 15-20dBm expected.
### Leads tested and results

iw phy set txpower fixed → silently ignored. Confirm that the cap is applied deeper, not in userspace. \
iw reg set FR → no effects, stays at country 00. Ruled out as cause, domain "00" allows up to 20dBm in 2.4GHz. \
txpower_sku (debugfs) → shows real structure : eeprom (chip calibration) = healthy values 37-41 ; tmac (actual limit applied by the firmware) = 3 everywhere, on all bitrates, all bandwidths. -r-- file, no quick test through simple echo. \
Real world test (close to room vs router vs phone hotspot) → tmac stays at 3 no matter the context. Élimine l'hypothèse d'un algorithme de puissance adaptatif (TPC) qui réagirait mal à la distance — c'est un plafond fixe et statique.
disable_clc=1 sur mt7921_common (bug CLC documenté sur Debian, cas quasi identique ASUS Vivobook S14/MT7922) → paramètre correctement chargé (vérifié via /sys/module/.../parameters/disable_clc = Y, initramfs régénéré, confirmé present dans l'image), mais aucun effet sur tmac. Conclusion : le bug CLC de ce rapport ne s'applique pas à notre cas précis (probablement une régression firmware différente, notre WM Firmware datant de juin 2026 vs mai 2025 pour le cas Debian).
Dynamic debug kernel sur mt76 → aucun point de debug disponible pour SAR spécifiquement (pas assez de hooks pr_debug dans cette version).
Décompilation DSDT (acpidump + iasl) → découverte de deux mécanismes distincts :

Un mécanisme SAR propriétaire ASUS via ALIB/WMI (Method SARC → appelle ALIB(0x0C, ...)), différent du DSM standard.
Les vraies méthodes ACPI que le driver mt76 sait lire : MTDS, MTGS, MTCL, MTAS, MTFG, MTSP, toutes présentes sous \_SB_.PCI0.GPP5.WLAN. Donc le mécanisme attendu par le driver existe bien sur cette machine.


Décodage partiel de MTDS → table SAR réelle avec des limites autour de 13dBm/10dBm/8.5dBm selon les modes. Bas, mais pas aussi bas que 3dBm — donc même si cette table s'applique intégralement, elle n'explique pas entièrement le plafond observé.
Appels ACPI live via acpi_call (MTFG, MTAS, MTSP) → toutes répondent avec des données structurées, confirmant que les méthodes sont vivantes et répondent. Décodage octet par octet non poussé jusqu'au bout (recherche de la structure exacte du parsing driver infructueuse).
Recherche du bug "use-after-free in mt7921_acpi_read()" → correctif ancien (2022-2023), très probablement déjà mergé dans le kernel 7.1.3 (2026). Piste abandonnée.
Dump mémoire EC brute (ec_sys) → découverte d'un bit nommé SARF ("SAR Feature") à l'offset 0xC0, actuellement à 0 (dans l'octet 0x60). Test d'écriture envisagé puis abandonné pour raisons de sécurité matérielle (risque rare mais réel de freeze/comportement erratique/dans le pire cas dégât matériel).

Conclusion actuelle
Le mécanisme ACPI SAR attendu par le driver existe et répond, mais soit sa table ne suffit pas à expliquer tmac=3, soit il y a un bug de parsing non identifié dans le driver ou le firmware WM (juin 2026) sur cette combinaison ASUS/MT7922 précise. Pas de bug public documenté correspondant exactement à ce cas. Décision : contournement matériel (répéteur/point d'accès dans la chambre, ou Ethernet) plutôt que poursuivre l'investigation sur un terrain à risque (EC) ou incertain (recompilation/patch driver).




# Contributing
Contributions are welcome. If you feel like something could be modified or improved, feel free to open an issue or a PR. \
If you consider pushing a big PR, I suggest opening an issue first in order to discuss it. \
Any wallpaper PR will be instantly denied. Go [here](https://codeberg.org/GlaceAuPlutonium/void-atlas) if you even *want* to submit a wallpaper.

# Credits
[Void Linux](https://voidlinux.org) for being the amazing distro that it is. \
[Noctalia](https://noctalia.dev) for developping Noctalia Shell. \
[Voiders Repo](https://git.voiders.dev/voiders-community/repository) for providing xbps-src build templates for noctalia-shell and noctalia-qs. \
[Ayuz](https://github.com/Traciges/Ayuz) for original 'Smart Gestures' implementation. \
[Visor](https://github.com/IO-ZetZor/Visor-BootManager) for the bootloader. \
The wallpapers I provide for Visor belong to their respective creators and can be found on [Wallhaven](https://wallhaven.cc). \
\
Also anyone that might one day find a fix for this stupid MT7922 wifi power problem.

# License
i'll add a license
