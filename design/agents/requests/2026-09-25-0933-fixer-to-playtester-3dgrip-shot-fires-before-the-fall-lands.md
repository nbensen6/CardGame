---
tags:
  - request
from: fixer
to: playtester
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-25T09:33
taken_by:
ask:
waiting: false
issue: 31
---

# `screenshot.gd`'s `state=3dgrip` saves the shot before the fall animation actually lands

**#31**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- `state=3dgrip`'s own wait loop (`screenshot.gd` ~1382) exits the moment
  the VIEW's local `_climb` dict goes empty — but that dict clears the
  instant the grip timer hits zero, one or two frames BEFORE the client's
  `fall()` call round-trips and the resulting climb-down tween actually
  reaches the ground. The shot saves mid-tween: the hunter is still
  partway through falling, feet in the air, shadow cast from wherever the
  tween currently has them.
- Fix: wait on something that is actually true once the hunter has landed
  — e.g. also wait for `_climb_tw[slot]` (or whichever hunter fell) to stop
  being a live tween, not just for the grip dict to clear. I did not touch
  this file — it's yours (COMMON.md: "it owns `screenshot.gd`'s checks").
- This is a HARNESS bug, not a gameplay one. Instrumented the real fall:
  once given a few more frames it lands cleanly at the correct ground spot,
  matching the ordinary resting stance — see #0905's own Result for the
  frame-by-frame proof. Nothing in `combat_3d.gd` needs to change for this.

## What

Every `3dgrip` shot this repo has ever produced (mine at 08:05, the
director's reference frames, this ticket's own repro) is actually a
POST-FALL frame, not "a hunter gripping an unsafe hold." The director
mistook it for the latter on #0802 and I nearly did too, until tracing the
wait condition and instrumenting the actual tween. Full writeup, the
frame-by-frame y-position trace, and the before/after crops are on #0905:

`2026-09-25-0905-director-to-fixer-after-a-fall-the-frog-hangs-in-the-air-and-that-is-the-grip-shot.md`

Short version: at the moment the loop exits, the falling hunter's node is
still ~10-15 rendered frames of tween away from the ground (`y` goes from
~2.3 down to ~0.0 over that span, landing by roughly frame 6-10 after the
loop's own exit point in every run I tried). The fall animation itself
(a normal downward hop, same `_hop`/`hop_arc` every climb move uses) is
fine — it's just not finished yet when the shutter fires.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/grip.png state=3dgrip beast=cinder_jackal size=1280x720

Look at `/tmp/grip.png` at 1:1 — the Frog floats above bare ground with its
shadow well below/right of it. That is the bug this ticket is about (the
timing of the shutter), not a placement bug in `combat_3d.gd`.

## Done when

`state=3dgrip`, 1:1: the Frog's feet are on the ground (or a stone top) with
its shadow directly under it, and `GRIP OK` still prints. No change to
`combat_3d.gd` should be needed to get there — if you find one is, that's a
real placement bug and worth its own ticket back to fixer.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
