---
tags:
  - request
from: playtester
to: fixer
status: taken
priority: normal
created: 2026-09-24T10:02
taken_by: fixer
ask:
waiting: false
issue: 6
---

# A small sliver of the intent-tag-vs-hunter bug survives your fix, at the very start of a ground-level hop

## What I need

- Your `intent_tag_pos`/`hunter_screen_rect` fix (commit `73ae6b4`) closes the
  main case cleanly — a full 80-step live baseline shows 0 fails on every
  hop except one. That one is real, just much smaller than the artist's
  original report: at the very first instant of a ground-level hop (the
  hunter still low, near the beast's front leg), the tag's left edge grazes
  roughly the rightmost ~13px of the hunter's own on-screen body for a
  single sampled frame, not the ~half-tag/half-hunter swallow from before.
- Reproduce with the exact command below and look at
  `hop_000_04.png` (or nearby) at 1:1 — the frog's right edge sits under
  the tag's left edge, low on screen, right after it launches.

## What

Extended `playtest.gd` with a live check (`intent-tag-vs-hunter`, check 5d)
that reads `_intent_tag`'s own real rect and `Combat3D.hunter_screen_rect`
of the active hunter's live AABB during every real sampled frame of every
hop in a run — the same shape of live coverage check 5c
(`intent-hidden`) already gives the party-panel fix, now given to yours.

First version fired 3-4/29 times per run even on your already-fixed code —
every one a hairline AABB-vs-AABB graze (down to 0.13px wide) that I could
not see at all when I opened the actual frame; `hunter_screen_rect`'s box
is the convex hull of a 3D AABB's projected corners, always a little looser
than the character's real silhouette, so it sweeps past the tag's edge on
nearly every hop without anything ever visibly touching. Added an 8px
minimum-overlap-on-both-axes margin (the same idea as check 5's own
`grow(-6)` for a card resting near a button) before ruling out
`hunter_screen_rect`'s own looseness as the cause of anything — full
reasoning is in the check's own comment in `playtest.gd`.

With that margin in place, three full fresh 80-step baselines all agree:
0 fails everywhere your fix already covers, and exactly 1 real fail per
run, always on the OPENING hop (step 0, `Tongue Snap`, ground → foot 2),
always this same small ~13x34px sliver. `hover` and `hands` (all 10 sizes)
both stay clean — nothing outside a real ground-level hop start trips it.

![[frames/playtester/2026-09-24-intent-tag-vs-hunter-groundhop-full.png]]
Real frame, full 1:1 — the frog's rightmost edge sits under the tag's own
left edge, low on screen, moments after the hop starts.

![[frames/playtester/2026-09-24-intent-tag-vs-hunter-groundhop-crop.png]]
Same frame, cropped in for detail only (2x nearest-neighbour, no upscale
beyond that) — the overlap is small but genuinely visible, not just a
bounding-box artifact.

Didn't chase the exact cause myself (not my job per this brief's own
hand-off rule), but the shape suggests it: `hunter_rect` is likely computed
from the hunter's home/rest position (or an early tween sample) at the very
first frame or two of the hop, before the AABB has risen far enough off the
ground to clear the tag the way it does for the rest of the arc — worth
checking whether `_position_intent_tag()` ever runs a frame behind the
tween on the very first tick of a climb.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=1 out=/tmp/pt

Then look at `/tmp/pt/hop_000_03.png` through `hop_000_05.png` at 1:1 (real
render timing varies slightly run to run, so the exact frame index can
shift by one or two) — the frog's own right edge sits just under the tag's
left edge while still low over the beast's front leg.

## Done when

A fresh `mode=play beast=cinder_jackal steps=80` run shows 0
`intent-tag-vs-hunter` fails, and a unit test (same shape as your existing
four, built on these real numbers) pins the fix for this specific
hop-start case.

## Nick's answer

## Result
