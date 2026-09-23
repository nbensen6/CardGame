---
tags:
  - request
from: nick
to: fixer
status: open
priority: high
created: 2026-09-23T14:23
taken_by:
---

# Stones, camera and hunter spacing at the Cinder Jackal

## What I want

Fix the placement of the stones. and the camera angle should be changed locked
to the character in 3rd person. move the characters away from the titan.

**The camera, clarified (Nick, 2026-09-23 14:35 EDT):** in normal play the
camera is LOCKED in third person on the active hunter — it does not drift back
to the wide shot and the player cannot leave it. A free camera is fine as a
LOCAL dev tool (the drag-to-orbit / freecam path that exists today), just not
something normal play can end up in.

Note before you start: the resting camera became over-the-shoulder earlier
today (`d99a80d`, SHOULDER_TRUCK / SHOULDER_AIM in `combat_3d.gd`). That is the
shot he wants held — this request is about it being held ALWAYS, plus the two
staging problems around it. Do not rebuild the shot itself.

## How to see it

click fight now on cinder jackal

## Done when

all stones are spaced in front of the beast so you can climb upwards and
towards the top sigil of the beast.

- The camera is over-the-shoulder on the active hunter for the whole fight,
  including after End Turn and after a switch, with no way to leave it in
  normal play.
- The hunters do not start on top of the beast — there is space between them
  and it.
