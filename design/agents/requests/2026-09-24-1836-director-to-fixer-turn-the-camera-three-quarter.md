---
tags:
  - request
from: director
to: fixer
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-24T18:36
taken_by:
ask:
waiting: false
---

# From straight on, the hunters stand between the jackal's paws — turn the resting camera three-quarter, as Nick drew it

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Give the resting shot a three-quarter yaw (Nick's #11, bullet 4: "side-on
  / three-quarter"). He already asked; it is not a new decision to wait on.
- Do NOT move the hunters' home positions further back, and do NOT widen the
  shot again — the beast is already the right size on screen.
- Small change; do it before the stones-in-front request if it fits in one
  run, because a front route only reads as a path from the side.

## What

Your #11 fix is right: whole beast, head to foot, hunters small. But at 1:1
the Frog stands between the jackal's front paws and the Goblin beside the
right paw. The 10 world units of ground between them and the beast are real
and completely invisible, because the camera looks down that gap end-on.

![[frames/director/2026-09-24-director-resting-shot.png]]

Nick's drawing is side-on: the frog bottom-left, the beast upper-middle, and
the empty ground between them is most of the picture. From the front, that
gap collapses to nothing — and so does a stone route that climbs the chest
(it becomes a vertical stack, which is exactly the "vertical smear" he
complained about). The yaw is the one change that makes both his bullet 1
(gap) and bullet 2 (path) visible without moving anything in the world.

You asked Nick on #11 whether he wants the three-quarter turn. Bullet 4 of
his own request is that answer. His "does this match?" will come back "no"
while the frame is front-on.

## What is working — keep it

`anyone_off_ground` gating the tight lock is the right fix and the climbing
camera was rightly left alone. Keep the beast-height-driven window.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Put the frame beside `design/art/references/2026-09-24-nick-target-composition.webp`.

## Done when

- In `state=3d`, at 1:1, there is visible empty ground between the nearest
  hunter and the jackal's nearest paw.
- The whole beast is still in frame; the intent tag, party panel and hand
  checks stay at 0 fails.
- The after frame is posted on #11 for Nick's yes/no.

## Nick's answer

## Result
