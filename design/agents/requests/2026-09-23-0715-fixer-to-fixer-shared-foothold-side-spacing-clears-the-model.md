---
tags:
  - request
from: fixer
to: fixer
status: open
priority: normal
created: 2026-09-23
taken_by:
---

# Two hunters sharing a narrow foothold: the side-shifted one's spacing can push it clear of the model and its (single, centred) stone

## What

Found while proving the fix for
`2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`
(commit `c8e965b`) — a genuinely separate, smaller mechanism, not the same
bug. Not fixing it now: one thing at a time, and this one needs its own
diagnosis-to-fix pass, not a rushed add-on.

That fix made `_stand_on_model` trust an EXACT rung's own anchor.z instead
of the hull whenever `_climb_points.has(foot)` — correct, and it closed the
wild "hanging over a blank wall" defect (z-gap from anchor 3.78 world units
→ 0.56). But a live `mode=play steps=80` run against the fixed code still
shows `hunter-off-marker` (check 8) failing at foothold 4, steps 37-39,
same coordinates each time:

    FAIL [step 37] hunter-off-marker: End Turn: hunter at foothold 4 is 1.54m from its climb marker (home (5.335257, 13.825942, 7.030925), anchor (3.901302, 13.825942, 6.473297), x-tol 1.06)

Confirmed the mechanism with a temporary debug print in `_place_hunters`
(not committed): at that exact moment BOTH hunters are at foothold 4
simultaneously (`other_foot=[4, 4]`), so `hunter_side_offset` correctly
returns `side=±1` for them — this is the intentional "two hunters on one
ledge stand apart" spacing (`stand_offset_x`), working as designed, not a
bug in that function. The problem is what it's spreading them across:

- `stand_offset_x(anchor_x, side, beast_width)` scales the ±spacing off
  `_beast_box.size.x` — the WHOLE beast's bounding-box width (12.92 for
  the Cinder Jackal) — giving each side a ~1.01-unit push. That's sane
  spacing on a wide torso/flank foothold. Foothold 4 sits right at the
  jackal's ear, a much narrower local feature; a 1-unit push there lands
  the side-shifted hunter past the ear's own silhouette.
- `_build_float_stones` only ever calls `_stand_on_model(height, 0.0)` —
  ONE stone per climb height, always centred (`side=0.0`). When two
  hunters spread to `side=±1` on a shared foothold, at most one of them
  can be anywhere near that single centred stone; the other has nothing
  to land on regardless of how correct its `z` is.

Net effect: my fix made the CENTRED case (one hunter alone, or a hunter
whose side happens to be 0) land exactly on the anchor — proven, clean.
The SHARED case at a narrow feature still shows a visible gap under the
side-shifted hunter's feet — much smaller than the original bug (order of
one hunter-width, not several), but real.

![[frames/fixer/2026-09-23-hunter-foothold4-fixed-step037.png]]
![[frames/fixer/2026-09-23-hunter-foothold4-shared-side-gap-step037-crop.png]]

The second frame is a tight crop on the side-shifted hunter: its feet sit
clear of both the model and the one visible stone (which belongs to the
OTHER, centred hunter/foothold), hovering over the plain arena-wall
background behind it — smaller than the original defect, but the same
underlying complaint (checklist item 2, "nothing floats").

## How to see it

    xvfb-run -a Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=40 out=/tmp/pt

Step 37-39 on this seed puts both hunters at foothold 4 together. `report.md`
and `step_037.png` land in `out=`.

## Done when

`hunter-off-marker` (check 8) passes for BOTH hunters when they share a
foothold, and the frame shows the side-shifted hunter plausibly gripping
the model or a stone — not hovering clear of both. Two real sub-questions
for whoever takes this, not necessarily both needed:
1. Should `stand_offset_x`'s spacing scale off something narrower than the
   whole bounding box (a local width sample, or just a smaller fixed
   spacing) so it stays inside the model at a narrow feature?
2. Should `_build_float_stones` build a stone per (height, side) pair
   that's actually occupied, rather than always one centred stone per
   height, so a side-shifted hunter has something to land ON?

## Result

(filled in by whoever takes it: what changed, which commit, how verified)
