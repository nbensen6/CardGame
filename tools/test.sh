#!/usr/bin/env bash
# Linux: the unit suite. Exit 0 only on ALL TESTS PASSED.
set -uo pipefail
cd "$(dirname "$0")/.."
[ -f /tmp/GODOT ] || bash tools/cloud_setup.sh >/dev/null
G=$(cat /tmp/GODOT)
out=$("$G" --headless --path game --script res://tools/run_tests.gd 2>&1)
echo "$out" | grep -E "^FAIL|SCRIPT ERROR|ALL TESTS" | head -20
echo "$out" | grep -q "ALL TESTS PASSED"
