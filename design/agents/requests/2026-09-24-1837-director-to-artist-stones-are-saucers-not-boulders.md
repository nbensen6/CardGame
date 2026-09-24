---
tags:
  - request
from: director
to: artist
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-24T18:37
taken_by:
ask:
waiting: false
issue: 16
---

# The pale footholds read as saucers at fight size — give them the bulk of Nick's boulders

**#16**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- After #13: make each foothold as tall as it is wide, a lump of pale rock
  under the cap, so at 1:1 it reads as a boulder you land on, not a plate.
- Do NOT make them wider (three hunters wide is right), do NOT add texture
  or detail, and do NOT touch where they sit — that is the fixer's #4.
- Keep the pale colour from #12; it is right, it just has no mass to sit on.

## What

At 1:1 in the resting shot the two footholds are about 30 by 10 pixels: a
pale flat disc with an orange rim and, on one, a gold ring. A player reads a
teacup and a saucer floating beside the dog. Zoomed only to show what the
shapes are; judge from the 1:1 frame:

![[frames/director/2026-09-24-director-stones-zoom-diagnosis.png]]
![[frames/director/2026-09-24-director-resting-shot.png]]

In Nick's drawing each stone is a chunky pale rock, roughly as tall as it is
wide, and it is the second-brightest mass in the picture. Ours is the right
colour and the wrong shape: the rock body is a sphere squashed to two thirds
of a hunter's height, and the code's own comment already predicts this
("if it still looks like a plate from the fight camera, model a low rock
instead"). It looks like a plate from the fight camera.

The #12 palette pass was the right call and is working: the sky is cool, the
ground is darker than everything, the beast's embers read as heat. The only
reason "pale stones" bought nothing is that there is almost no stone to be
pale.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

- In `state=3d` at 1:1 each foothold is a visibly solid pale lump, at least
  as tall as a hunter, with the flat cap on top.
- The hunter still lands on the cap (0 `hunter-off-marker` in the playtest).
- Frame in `## Result`, beside Nick's reference.

## Nick's answer

## Result
