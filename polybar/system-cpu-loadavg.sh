#!/bin/sh
# https://github.com/x70b1/polybar-scripts/tree/master/polybar-scripts/system-cpu-loadavg

awk '{print $1" "$2" "$3}' < /proc/loadavg
