#!/usr/bin/env bash
# Linux twin of tools/playtest.cmd: play the fight through scripted input
# under a virtual display. Same arguments as playtest.cmd.
#
#   bash tools/playtest.sh mode=play beast=cinder_jackal steps=40 out=/tmp/pt
set -uo pipefail
cd "$(dirname "$0")/.."
[ -f /tmp/GODOT ] || bash tools/cloud_setup.sh >/dev/null
G=$(cat /tmp/GODOT)
xvfb-run -a -s "-screen 0 1280x720x24" "$G" --rendering-driver opengl3 --path game \
  --script res://tools/playtest.gd -- "$@"
