#!/bin/sh

current=$(wlr-randr | awk '/current/ {print $3}')
if [ "${current%%.*}" = "120" ]; then
    wlr-randr --output eDP-1 --mode 3200x2000@59.999001
    qs -c noctalia-shell ipc call toast send '{"title": "60 Hz", "body": "Refresh rate set to 60Hz", "icon": "keyframes", "duration": 6000}'
else
    wlr-randr --output eDP-1 --mode 3200x2000@120
    qs -c noctalia-shell ipc call toast send '{"title": "120 Hz", "body": "Refresh rate set to 120Hz", "icon": "keyframes", "duration": 6000}'
fi
