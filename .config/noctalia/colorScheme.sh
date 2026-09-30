#!/bin/sh
current=$(grep -oP '"predefinedScheme":\s*"\K[^"]+' ~/.config/noctalia/settings.json)
if [ "$current" = "Tokyo Night" ]; then
    qs -c noctalia-shell ipc call colorScheme set "Noctalia (default)"
    qs -c noctalia-shell ipc call darkMode setLight
else
    qs -c noctalia-shell ipc call colorScheme set "Tokyo Night"
    qs -c noctalia-shell ipc call darkMode setDark
fi
