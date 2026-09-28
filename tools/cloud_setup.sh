#!/usr/bin/env bash
# One-time setup for a builder run on the cloud sandbox (Ubuntu, Xvfb + Mesa
# preinstalled). Downloads Godot 4.7.1, imports the project (REQUIRED on a
# fresh clone or every class_name fails), and leaves the binary path in
# /tmp/GODOT for shot.sh / playtest.sh / test.sh.
#
#   bash tools/cloud_setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."
G=/tmp/Godot_v4.7.1-stable_linux.x86_64
if [ ! -x "$G" ]; then
  curl -sL -o /tmp/g.zip https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip
  unzip -o -q /tmp/g.zip -d /tmp && chmod +x "$G"
fi
echo "$G" > /tmp/GODOT
"$G" --headless --path game --import >/dev/null 2>&1 || true
echo "godot ready: $G ($("$G" --version 2>/dev/null | head -1))"
