---
tags:
  - request
from: playtester
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T23:44
taken_by:
ask:
waiting: false
---

# Every ordinary climb hop is now ~20m, 2-8x hop_arc()'s own ceiling — the hunter reads as invisible, then popped-in, not climbing

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- `hop-distance-band` (playtest.gd) now measures the LIVE route (fixed per
  #director's checks-measure-the-old-route ticket, landed this run) instead
  of the stale, pre-b0648db anchors it used to read.
- On current main it reports every ordinary Height N->N+1 hop at exactly
  **20.44m**, against `hop_arc()`'s own 2.42-9.15m band — 2-8x over the
  ceiling, on all four gaps (1->2, 2->3, 3->4, 4->5), every single run.
- This is new since your 22:12 EDT commit (b0648db): the route now crosses
  the widened ground gap (GROUND_STANDOFF 0.62 -> 4.2) in `n-1` EVEN steps
  of a straight line from the ground to the sigil — so the total ~82-unit
  span divided into 4 steps is ~20m each, regardless of how the beast's own
  named anchors are spaced.
- I checked with a shrunk `GROUND_STANDOFF` (temporary, reverted, never
  committed): the same fight comes back with 0 `hop-distance-band` fails —
  so this is the widened gap meeting the even-spacing rule, not a check bug.
- Frame below: a hunter is invisible for 6 of 8 sampled frames of an
  ordinary climb hop, then pops in already close to the beast — this reads
  as a teleport, not a jump, which is exactly checklist item 1/3 ("nothing
  snaps... teleports").
- Not mine to tune (route/camera are yours tonight) — recommend either
  widening `hop_arc()`'s own ceiling for this route specifically, or adding
  intermediate stones so no single hop crosses the whole gap. Your call.

## What

`_stand_on_model`'s new route_pos() branch (see your own b0648db message)
places every non-top rung on a straight line from a point just in front of
the hunters to the sigil, `n-1` even steps. For the Cinder Jackal, `n=5`
(named climb rungs 1-5), and the line runs from z≈81 (near the hunters) to
z≈0.5 (the sigil) — an ~82-unit straight-line span. Evenly dividing that
into 4 steps gives ~20.44m per hop, independent of which specific Heights
get visited (I checked the beast's own `_ledges` too: {0,2,3,4} — a real
climb still visits several of these route_pos-based points in sequence, so
the ~20m-per-leg experience is real, not an artifact of which waypoints get
named).

`hop_arc()` clamps its own arc height to 0.63-2.38 units regardless of
distance ("the arc stops growing... stops reading as effort") — so a 20m
horizontal hop still gets, at most, a 2.38-unit-tall arc, in the same fixed
0.62s per-hop duration every other hop uses. The hunter covers most of the
empty gap while barely inside the camera's frame, then arrives already
close to the beast — reads as popping into existence, not climbing.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=10 out=/tmp/pt

Step 1 ("Leap", hunter 0, foot 2->6) is a clean repro — `hop watched`
reports endpoints y 4.62 -> 15.10 in one continuous tween.

![[frames/playtester/2026-09-24-hop-distance-20m-pop-in-strip.png]]
8 evenly-spaced frames across that one hop (mid-climb OTS camera, not the
wide establishing shot): the frog is off-frame for the first 6, then
appears already well up the beast's belly in frame 7, near the sigil by
frame 8.

## Done when

`hop-distance-band` reads 0 on a full `mode=play` baseline (currently 124
fails on `steps=80`), proven both ways: 0 on the real fix, and it fires
again if you temporarily widen the gap further.

## Nick's answer

## Result

## Director — 2026-09-24 23:58 EDT

Good find, and the strip is the right proof. To the fixer: this is #14's
symptom, not a separate fix — the four 20 m legs exist because nothing sits
between the ground spot and rung 1. Take it WITH #14 (sequencing note there,
23:57), and do not "fix" it by widening `hop_arc()`'s band: the number would
go green and the Frog would still pop in. The Done-when above stays as the
check that #14's stones actually worked.
