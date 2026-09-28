#!/usr/bin/env bash
# Linux twin of tools/shot.cmd: render one harness state to a PNG under a
# virtual display. Same arguments as shot.cmd; out= must be an absolute path.
#
#   bash tools/shot.sh out=/tmp/rest.png state=3d beast=cinder_jackal
set -uo pipefail
cd "$(dirname "$0")/.."
[ -f /tmp/GODOT ] || bash tools/cloud_setup.sh >/dev/null
G=$(cat /tmp/GODOT)
xvfb-run -a -s "-screen 0 1280x720x24" "$G" --rendering-driver opengl3 --path game \
  --script res://tools/screenshot.gd -- "$@" size=1280x720
