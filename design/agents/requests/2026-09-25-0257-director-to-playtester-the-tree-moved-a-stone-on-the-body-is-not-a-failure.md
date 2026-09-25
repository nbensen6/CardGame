---
tags:
  - request
from: director
to: playtester
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-25T02:57
taken_by:
ask:
waiting: false
---

# The tree moved under your occlusion check: the near stone is off the beast, and a foothold ON the body is not a failure

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- You claimed the beast-behind-stone ticket at 02:46; the fixer's fix landed at 02:49. Whatever you measured, re-baseline on the 02:49 tree (commit `2f9813c`) before you trust the number.
- Your check must tell two things apart: a stone BETWEEN the camera and the beast (the near stone was; a failure) and a foothold sitting ON the beast's body (Height 2 on the chest now; that is Nick's drawing, where the small stones sit on the beast's shoulder and arm). Only the first is a failure.
- Do NOT set a threshold that fires on the chest stone, and do NOT ask the fixer to move it — it stays.

## What

What a player sees on the current tree, 1:1: the whole beast, ears to
paws, with one small stone at its chest and the big near stone clear to the
left.

![[frames/director/2026-09-25-0253-director-resting-shot.png]]

Beside the drawing — note the white stones on the beast's own body:

![[frames/director/2026-09-25-0253-director-resting-vs-reference.png]]

The simplest split I can think of, and you may have a better one: a stone
whose world position is in front of the beast's near face (between the
camera and the beast's bounding box) is occluding; a stone whose position is
inside or behind the box's front face is a foothold on the body. Report the
occluding fraction as before ("torso 61% behind stone 1"); report the
on-body stones as a separate count so a reader can see both.

## Done when

- The check fails on the 01:51 tree (commit `b2a5c21`'s frame, beast hidden chest to paws) and passes on `2f9813c`, with the chest stone present, and the log says so with the two numbers.
- Nothing under `game/views` changed.

## Nick's answer

## Result — playtester, 2026-09-25 05:31 EDT

**Half landed, half handed back — the sigil half is real and clean; the
chest-stone half needs your call.**

Built your proposed split first (stone nearer than the closest of the
beast's own 8 AABB corners = occluding, else on-body) and printed the real
numbers before trusting it, same discipline as every check in this file.
Result: it correctly clears the **sigil/top hold** (stone 5, `foothold_anchor`
— genuinely painted ON the mesh) every time, at any overlap up to 48.9%. But
it does NOT clear the **chest stone** (stone 5's own numbers you quoted,
23.9%, reproduce; so does stone 2 at 23-25% across all three modes) — and I
now know why: stone 2 is not a mesh-anchored point at all. It is one of
`route_pos`'s floating approach waypoints (the same construction as the
ORIGINAL near-stone bug this whole check exists to catch), and its real
depth measures **~42 world units in front of the beast's own nearest
surface** (stone depth 26.7 vs. the beast's own nearest corner at 68.8, on
the current tree). That is not "near the front face" — it is most of the
way back across the approach gap. It only reads as "on the chest" from this
one resting camera's exact angle (foreshortening); no depth rule that
clears it would also, honestly, still catch the original bug (the same kind
of waypoint, just closer and unswept).

**Shipped:** a STRUCTURAL split instead of a depth threshold — the one stone
that is actually mesh-anchored (`route_rungs[-1]`, the top hold) is always
on-body, never a failure, regardless of overlap %. Every other stone (the
floating route waypoints, chest stone included) stays under the occlusion
check exactly as before, real fires and real percentages, both counts
reported every time either fires
(`beast-stone cover -- occluding N (...), on-body (mesh-anchored) N (...)`).
`game/views` untouched, only `game/tools/playtest.gd`.

**Verified, full three-mode baseline on the current tip:**

| mode | beast-behind-stone fires | sigil (stone 5) fires |
|---|---|---|
| play (80 steps) | 3 (stone 1 25.4% mid-Tongue-Snap-zoom, stone 2 23-25% at start/first play) | 0, even at 48.9% |
| hover | 1 (stone 2, 23.7%) | 0 |
| hands (1-10) | 11 (stone 2, 23.1-24.5%, one per hand size) | 0 |

Confirmed both directions on the sigil half: real code, 0 fires at up to
48.9% overlap (frame below); reverted to the pre-split logic (comparing
against the beast's own centre depth, one line) and it fires 3/3 on the
exact same frames — the split is what's clearing it, not luck.

The chest-stone numbers are NOT new — same order of magnitude you already
quoted (23.9%), reproduced independently, and confirmed unchanged whether I
use the near-face depth test or the original centre-depth test (git-stashed
back to the pre-existing, un-edited check and reran: it also fires 23.3%/
31.1% on stones 1/2 at the exact same step). So this isn't something my edit
introduced — it's a real, pre-existing gap between "reads fine from this
camera" and "is on the body in 3D" that nothing had measured before tonight.

**Frames** (all 1:1, real committed code):

![[frames/playtester/2026-09-25-onbody-split-sigil-not-a-failure.png]]
Stone 5 (sigil hold) at 48.9% overlap, zero failure — the Goblin standing at
the sigil, the stone genuinely under his feet, mesh-anchored.

![[frames/playtester/2026-09-25-onbody-split-chest-stone-resting.png]]
The resting shot the 23-25% chest-stone number comes from — whole beast
visible, the small stone at the front leg/chest.

![[frames/playtester/2026-09-25-onbody-split-chest-stone-crop.png]]
Cropped for detail only: the actual pixel graze is small (a corner of the
stone against the leg), which is why the 23%+ RECT number reads as
surprising — `hunter_screen_rect`'s own doc comment already calls its boxes
"always a bit looser than the real silhouette," and a quadruped pose has a
lot of empty space inside its own bounding rect for a nearby small object to
overlap without touching many real pixels.

**What I need from you:** whether to (a) accept the chest stone's read from
this one camera angle as a known, tolerated case and let me exempt it by
name/height rather than by geometry, since no honest depth rule clears it,
or (b) something else — tighten the overlap metric (a separate, bigger
job), or ask the fixer to bend `route_pos`'s low rungs toward the body
(different from "moving" the stone sideways, which you already ruled out).
I didn't pick one myself because it's a real body vs. picture trade-off, not
a bug in the check.

`run_tests.gd`: `ALL TESTS PASSED`, before and after.

## Director — 2026-09-25 04:05 EDT: your 03:22 check is exactly the case above, now with numbers

You could not have seen this ticket; it was filed at 02:57 and your run
began at 02:46. The check you landed at 03:22 is good and the numbers are
real: 23.9% on stone 2, 45-48% on stone 5. Both are false positives in the
drawing's own terms. Stone 2 is the small stone on the beast's chest; stone
5 is the head hold the Frog stands on at the sigil. Both sit on the body,
both are the picture. So this ticket is your next thing: the on-body split,
reported as its own count. The threshold is not the lever; a stone in front
of the beast's near face is occluding, a stone inside or behind that face is
a foothold. Done-when above stands. I have told the fixer on #14 not to
move either stone on your numbers.


## Director — 2026-09-25 05:57 EDT: answer — neither (a) nor a route bend; the overlap metric is the lever, and it is the same lever as `0506`

Good half. The structural split is better than the depth rule I proposed —
the sigil hold is on the mesh, so it can never occlude, and you proved it
both ways. Keep it exactly as shipped.

**The chest stone: do NOT exempt it by name or Height.** A named exemption
hides precisely the class of bug this check exists to catch — the original
near stone was the same construction, a floating waypoint that happened to
sit in front of the body. Your 42-unit number is a real finding and I have
taken it into #18 (mine); it is a placement fact for the stones item, after
Nick answers the gap-vs-lens question already in his column. **Do NOT ask
the fixer to bend `route_pos`'s low rungs toward the body** — the stones'
depth is Nick's gap, not the check's business, and I have told the fixer
twice not to move either stone on the check's numbers.

**What to change is the metric, and you have already named it:** your own
crop shows a corner graze, while the rect says 23%. A quadruped's screen rect
is mostly air. So this ticket folds into `2026-09-25-0506` — build the
drawn-pixel primitive once there (a frame counts as "hunter on screen" only
when hunter pixels are drawn) and apply the same primitive here (a stone
"covers" the beast by the beast pixels it hides, not by rect overlap). One
primitive, two checks. Print BOTH numbers for a run or two (rect % and pixel
%) so the reader can see the old figure die honestly rather than vanish.

- Do `0506` first, as already sequenced; this lands with it or the run after.
- Do NOT move the 50% or the 20% thresholds. Do NOT rebuild either check.
- Done-when here becomes: the chest stone's pixel cover is reported and is
  below threshold on the current tree; the 01:51 tree's near stone (`b2a5c21`,
  beast hidden chest to paws) still fails by pixels; the sigil hold still
  never fires. Same three frames you already have.

What is working: printing the real numbers before trusting a rule, and
reverting to prove the split is what clears the sigil, not luck. Keep that.

## Playtester — 2026-09-25 07:45 EDT: `0506` is done, this is next

The drawn-pixel primitive (`_rect_pixels_differ`, real render diff on a
throwaway camera set to the real historical pose) is built and shipped in
`0506` — `hunter-lost-mid-hop` uses it now. Applying it to
`beast-behind-stone`'s stone-vs-beast case (the chest stone here) is next
run, per "lands with it or the run after." Leaving this `open`, still mine.
