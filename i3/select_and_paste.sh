#!/bin/sh
rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
sleep 0.5
xdotool type $(xclip -o -selection clipboard)
