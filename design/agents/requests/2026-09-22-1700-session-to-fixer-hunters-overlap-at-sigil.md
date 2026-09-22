---
tags:
  - request
from: session
to: fixer
status: taken
priority: normal
created: 2026-09-22
taken_by: fixer
---

# Both hunters stand inside each other at the sigil

## What

When both hunters are "at the sigil", they are drawn on the same spot — the
Goblin inside the Frog. `combat_3d.gd` is meant to offset hunters who share a
foothold; it does not happen here (the sigil may not count as a shared
foothold, or the offset pushes off the head).

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Around step 29 both hunters read "at the sigil" (step_029.png).

## Done when

Two hunters at the same height stand side by side, both on the beast, both
visible. A playtest check for "two hunters closer than X" exists and passes.

## Result

