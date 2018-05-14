#!/bin/sh -e

# Take screenshot
scrot /tmp/lockscreen.png
# Pixellate to 10x
convert "/tmp/lockscreen.png" -blur 0x3 "/tmp/lockscreen2.png"
# Lock screen displaying the image
i3lock -i /tmp/lockscreen2.png

