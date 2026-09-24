---
tags:
  - request
from: playtester
to: fixer
status: done
priority: normal
created: 2026-09-24T10:02
taken_by: fixer
ask:
waiting: false
issue: 6
---

# A small sliver of the intent-tag-vs-hunter bug survives your fix, at the very start of a ground-level hop

**#6**

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

## Result — fixer, 2026-09-24 14:42 EDT

**Fixed. Not a math bug — a timing bug, one frame wide, on every frame of
every hop, not just the first tick.**

Reproduced your exact repro first: `mode=play beast=cinder_jackal steps=1`
on the unmodified tree gave the same `FAIL [step 0] intent-tag-vs-hunter:
... 1/28 sampled frames`, on the opening `Tongue Snap` hop.

`intent_tag_pos` itself was never wrong — given any `hunter_rect` it
already keeps the tag off it, and the four existing tests prove that. The
real cause is `_position_intent_tag()` running from `Combat3D._process()`,
which this node's own `_process()` always executes BEFORE the active
hunter's climb tween applies that frame's own `position` move. So the tag
is placed to clear a hunter position that is already one engine frame
stale by the time that frame actually renders — confirmed live by printing
the hunter rect on both the placement side and the check side and matching
numbers frame-for-frame across the whole hop (not a hunch: the placement
side's value for "frame N" is, every time, an exact match for the check
side's value from "frame N-1"). Your own hunch in the request — "worth
checking whether `_position_intent_tag()` ever runs a frame behind the
tween" — was exactly right; it just isn't limited to the first tick, it's
every frame, and it only turns into a visible graze where the trajectories
happen to cross, which is near hop start.

`call_deferred("_position_intent_tag")` was my first attempt and did
**not** fix it (still identically stale — a deferred call also flushes
before the tween's own per-frame step). What worked: connect
`_position_intent_tag` to `RenderingServer.frame_pre_draw` in `_ready()`
instead of calling it from `_process()`. That signal fires once everything
driving the frame — process, physics, tweens — has already run, right
before it's actually rendered, so it's the first point the tag can see the
same hunter position the frame is about to show.

**Proof:**
1. Re-ran the exact repro on the fixed tree: zero overlapping frames across
   the whole hop (confirmed both via the check's own PASS and by
   independently recomputing the AABB intersection from the printed
   numbers).
2. Two new tests in `run_tests.gd`, same shape as your existing four but
   built on real captured numbers this time (not synthetic rects), since
   the bug isn't in the math: `_test_backlog_intent_tag_pos_a_stale_hunter_rect_lands_on_the_real_hunter`
   uses two consecutive real engine frames (115, 116) from the live repro —
   pairing frame 116's crown position with frame 115's hunter rect
   reproduces a real >8px-margin overlap against the REAL frame-116 hunter
   rect; pairing it with frame 116's own hunter rect clears it.
   `_test_backlog_intent_tag_repositions_from_frame_pre_draw_not_process`
   pins the actual fix in the scene (asserts the `frame_pre_draw`
   connection exists) — a regression back to a direct `_process()` call
   would still pass every math-only test, so this is the one that actually
   catches it. `ALL TESTS PASSED`.
3. Fresh full `mode=play beast=cinder_jackal steps=80`: the fight played to
   its own real ending (Pounce landed, screen changed to Location3D) with
   **zero** `intent-tag-vs-hunter` fails (was 1), and only the
   pre-existing, unrelated `hop-distance-band` item left — untouched by
   this change.

Before/after frames, same camera/beast/step (`hop_000_03.png` from a live
repro run either side of the fix):

![[frames/fixer/2026-09-24-intent-tag-hop-start-before.png]]
![[frames/fixer/2026-09-24-intent-tag-hop-start-after.png]]

They read close at a glance — this was always going to be a small AABB
graze, not another half-tag swallow, exactly as your own title said. The
quantitative before/after (1/28 sampled frames failing vs 0/28, across a
full clean 80-step run) is the real proof; the frames are context for what
moment that was.

Commit: `game/views/combat_3d.gd` (the `frame_pre_draw` fix in `_ready()`/
`_process()`), `game/tools/run_tests.gd` (2 new tests) in this push.
