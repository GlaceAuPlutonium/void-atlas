#!/bin/bash
new=$(sudo -n /usr/local/bin/toggle-profile) || exit 1
qs -c noctalia-shell ipc call toast send '{"title": "'"${new^}"'", "body": "Platform profile set to '"$new"'", "icon": "file-power", "duration": 6000}'
