---
tags:
  - request
from: playtester
to: fixer
status: taken
priority: high
created: 2026-09-23
taken_by: fixer
---

# Regression: a hunter at foothold 4 floats off the jackal entirely, in open air with no stone under it

## What

Full three-mode baseline this run (`play` 80 steps, `hover`, `hands` 1-10) against
today's tip, which now includes `a823001` ("Rebuild the jump: real arc,
jump-framing camera, hunters facing the boss", Nick's own commit, not one of
the three agents'). `hover` and `hands` came back clean (0 fails each,
matching the last recorded baseline). `play` did **not**: `hunter-off-marker`
(check 8) failed 3 times — the last several runs had this at 0 fails, so
this is a genuine regression, not a flake.

    PLAYTEST FAIL: 1 failing check(s) { "hunter-off-marker": 3 }
    FAIL [step 34] hunter-off-marker: End Turn: hunter at foothold 4 is 4.01m
      from its climb marker (home (5.230187, 13.825942, 10.253428),
      anchor (3.901302, 13.825942, 6.473297), x-tol 1.06)
    FAIL [step 35] hunter-off-marker: play 'Brace' (hunter 0) ... foothold 4
      ... (same home/anchor as step 34)
    FAIL [step 71] hunter-off-marker: End Turn: hunter at foothold 4 ...
      (same home/anchor again — a *different* hunter, landing at foothold 4
      via a different path: step 34 got there `foot 7→4`, step 71 `foot
      10→4`)

All three fails share the exact same `home` coordinates — this is
deterministic on foothold 4 specifically, not path- or RNG-dependent. Check
8 only asserts on `x` and `y` (`y` matched exactly; `x` missed by 0.27 past
its 1.06 tolerance), but the frame makes the bug obvious without needing the
numbers at all — the hunter is floating in open air against the arena wall,
feet dangling, no stone or beast surface anywhere near it:

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034.png]]

Cropped on the Goblin Engineer — nothing underneath, no floating stone
either, just the background wall:

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034-crop.png]]

Step 71, a different hunter, same climb path length, lands at the *exact
same spot* in open air — confirms it's tied to foothold 4 itself, not to how
the hunter got there:

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step071.png]]

**My read (unconfirmed, yours to verify), so you don't have to re-derive
it):** `a823001` changed `_stand_on_model` (`combat_3d.gd:2751-2764`) to wrap
its return in `stone_point(...)` directly — previously `stone_point` was
only applied to the *stone's own* visual position
(`_build_float_stones`), while the hunter stood at the raw
`Vector3(x, p.y, maxf(p.z, clear))`. Now both the hunter and the stone call
`_stand_on_model`, which should mean they land together — and `check 8`'s
own tolerance was never widened to account for `stone_point`'s extra
outward push (`HUNTER_HEIGHT` in the `(skin.x, skin.z)` direction from world
origin), which is likely why it *just* trips the x-tolerance. But a 0.27m
tolerance miss doesn't explain a hunter hanging in the open air with nothing
under it at all — my guess is `_front_of_beast(x, p.y)` (which feeds
`clear`, which feeds the z fed into `stone_point`) is returning something
much larger than expected at this particular `x, p.y` (foothold 4's rung),
so the whole point — hunter AND its stone — computes to a spot already past
the model's silhouette, and `stone_point`'s further push sends it past the
stone too. I have not touched `_front_of_beast`, `_stand_on_model`, or
`stone_point` — diagnosing which of those three is actually wrong is yours.

## How to see it

    xvfb-run -a Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Step 34 (`foot 7→4`) or step 71 (`foot 10→4`) — either one puts a hunter at
foothold 4 and reproduces it every time on this seed. `report.md` and
`step_034.png` / `step_071.png` land in `out=`.

## Done when

`hunter-off-marker` (check 8) passes at foothold 4 in the full 80-step
`play` baseline, and the frame at that step shows the hunter standing on (or
plausibly gripping) the model or its stone — not hanging in open air.

## Result

(filled in by whoever takes it: what changed, which commit, how verified)
