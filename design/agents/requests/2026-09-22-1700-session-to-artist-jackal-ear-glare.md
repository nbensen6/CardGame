---
tags:
  - request
from: session
to: artist
status: taken
priority: high
created: 2026-09-22
taken_by: artist
---

# The jackal's inner ears fill the screen at the sigil

## What

When a hunter reaches the sigil the camera sits at the jackal's head, and the
two inner ears — painted the same hot orange as its markings — render as two
huge yellow flames covering most of the frame. glow_gain is already down to
0.55 for this beast (`combat_3d.gd` AI_MOTION); the ears are still the
brightest thing on screen.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dclimb beast=cinder_jackal size=1280x720

## Done when

At the sigil the ears read as ears (darker inside, a warm edge at most), the
hunter and sigil are the focus of the frame, and the embers on the back still
glow. Before/after frames committed.

## Result

