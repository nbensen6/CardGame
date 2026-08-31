#!/usr/bin/env bash
# Capture an asset so it can be judged. See design/asset-loop.md.
#
#   tools/blender/look.sh frog 1               a hunter or a beast
#   tools/blender/look.sh env crag_pup 1       a fight's ground
#   tools/blender/look.sh map grass 1          an overworld hex
#   tools/blender/look.sh cast 1               every model in the cast folder
#
# The POSIX twin of look.cmd, because the cloud routine runs on Linux and a
# .cmd is unreadable to it. Blender comes from $BLENDER if set, else whatever
# `blender` is on PATH — the sandbox installs 4.0.2 via apt, Nick has 4.1
# installed at a Windows path.
#
# Neither script keeps a list of assets. An earlier version of look.cmd did,
# and it went stale the moment the routine added fourteen beasts in two days:
# `look.cmd cast` cheerfully rendered nineteen models and said nothing about
# the fourteen it had never heard of. The folder is the list.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="$ROOT/design/renders"
BLENDER="${BLENDER:-blender}"

kind=cast
case "${1:-}" in
  env) kind=env; shift ;;
  map) kind=map; shift ;;
esac

case "$kind" in
  cast) DIR="$ROOT/game/assets/3d/cast" ;;
  env)  DIR="$ROOT/game/assets/3d/env" ;;
  map)  DIR="$ROOT/game/assets/3d/hexown" ;;
esac

if [ $# -eq 0 ]; then
  echo "usage: look.sh <name> [pass] | look.sh cast [pass] | look.sh env <name> [pass]" >&2
  exit 1
fi

shoot() {          # shoot <asset> <pass>
  local glb="$DIR/$1.glb"
  if [ ! -f "$glb" ]; then
    echo "  SKIP $1 - no $glb"
    return 0
  fi
  "$BLENDER" --background --python "$HERE/look.py" -- "$glb" "$OUT" "$1" "$2" \
    | grep -E "LOOK|SIZE|Error" || true
}

if [ "$1" = "cast" ]; then
  pass="${2:-1}"
  for glb in "$DIR"/*.glb; do
    [ -e "$glb" ] || continue
    name="$(basename "$glb" .glb)"
    echo "=== $name"
    shoot "$name" "$pass"
  done
else
  shoot "$1" "${2:-1}"
fi

echo
echo "Six views per asset in design/renders/. Now open them."
