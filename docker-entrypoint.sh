#!/bin/sh
set -eu

DISPLAY_NUMBER="${DISPLAY#:}"
SCREEN_WIDTH="${SCREEN_WIDTH:-1600}"
SCREEN_HEIGHT="${SCREEN_HEIGHT:-900}"
SCREEN_DEPTH="${SCREEN_DEPTH:-24}"

cleanup() {
  for pid in ${APP_PID:-} ${NOVNC_PID:-} ${VNC_PID:-} ${WM_PID:-} ${XVFB_PID:-}; do
    if [ -n "$pid" ]; then
      kill "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup INT TERM EXIT

Xvfb "$DISPLAY" -screen 0 "${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}" \
  -ac -nolisten tcp &
XVFB_PID=$!

i=0
while [ ! -S "/tmp/.X11-unix/X${DISPLAY_NUMBER}" ]; do
  i=$((i + 1))
  if [ "$i" -gt 100 ]; then
    echo "A tela virtual nao iniciou." >&2
    exit 1
  fi
  sleep 0.1
done

openbox-session >/tmp/openbox.log 2>&1 &
WM_PID=$!

x11vnc -display "$DISPLAY" -forever -shared -nopw -rfbport 5900 -quiet &
VNC_PID=$!

websockify --web=/usr/share/novnc 6080 localhost:5900 &
NOVNC_PID=$!

echo "PokeGrid disponivel em http://localhost:6080/vnc.html?autoconnect=1&resize=scale"

npm start -- --no-sandbox &
APP_PID=$!
wait "$APP_PID"
