#!/usr/bin/env sh

# Terminate running polybar instances
killall -q polybar
# Wait until all polybars have shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar left &
polybar right &

echo "Bars launched..."
