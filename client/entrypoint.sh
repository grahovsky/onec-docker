#!/bin/sh
set -e

DISPLAY=${DISPLAY:=:99}
VNC_PORT=${VNC_PORT:=9000}
RESOLUTION=${RESOLUTION:=1920x1080x24}

/usr/bin/x11vnc -rfbport ${VNC_PORT} -display ${DISPLAY} -forever -bg -o /tmp/x11vnc.log -xkb -noxrecord -noxfixes -noxdamage -nomodtweak &

/usr/bin/Xvfb ${DISPLAY} -screen 0 $RESOLUTION -nolisten tcp
#exec "$@"