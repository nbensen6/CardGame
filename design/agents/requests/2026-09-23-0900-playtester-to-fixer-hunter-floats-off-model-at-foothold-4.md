---
tags:
  - request
from: playtester
to: fixer
status: done
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

**Confirmed the playtester's own read was right, and found the specific
mechanism.** `_front_of_beast(x, p.y)` at foothold 4's rung genuinely was
returning something far larger than the anchor's own authored z: with the
hull built (`hull_size=180`), `_front_of_beast(3.901, 13.826)` returned
**13.164**, against the anchor's own **6.473** — nowhere close. Instrumented
`hull_front_at`'s neighbourhood directly and found why: its 5-row(y)×3-col(x)
scan reached two full hull bands above foothold 4's own row and picked up a
single, otherwise-isolated cell (`(col 5, row 15) = 13.16`, every other cell
in that row empty) — the Cinder Jackal's own **ear**, not any part of the
torso/neck surface actually near the anchor. That one stray cell became
"the front of the body" for this (x, y) and won the `maxf(anchor.z,
hull_clear)` in the old `_stand_on_model`, dragging the hunter's z from
6.47 out past 13, well beyond the model and the arena wall behind it — the
exact frame the playtester caught.

Crucially, the anchor itself was never wrong. `beast.py`'s own export step
(`_decorate`, `tools/blender/beast.py`) already raycasts every `climb_<h>`
anchor out to the real mesh, clearance for a standing hunter baked in
(`push = (reach + hs * 0.80) - here`) — so an EXACT rung's anchor is
already correctly placed. The bug was `_stand_on_model` re-deriving that
same answer from a coarse, noise-prone runtime hull and letting the worse
answer win.

**Fix** (commit `c8e965b`): new static `Combat3D.stand_z_for(anchors, foot,
anchor_z, hull_clear)` — trusts `anchor_z` outright whenever `foot` is an
exact key in the model's own climb anchors, and only falls back to
`maxf(anchor_z, hull_clear)` for a foothold BETWEEN two rungs (where
`foothold_anchor` lerps a straight line across the body's curve and there
genuinely is no baked, raycast-true anchor to trust — the hull is still the
right tool there). `_stand_on_model` now skips the hull query entirely on
an exact rung. Side effect worth recording: `_build_float_stones` and
`_build_ledge_marks` both always call `_stand_on_model` with an exact
anchor height, so this also makes moot a separate, latent-but-never-live
bug I found while reading the surrounding code: `_build_float_stones()` is
called before `_build_hull()` in the beast-load sequence (`combat_3d.gd`
~line 1566-1567, contradicting its own doc comment), which used to mean
every floating stone's own clearance was computed against an EMPTY hull.
Not touching that ordering now — it's dead weight after this fix, not a
live bug, and reordering it isn't needed to close this request.

**Proof.** Three new unit tests (`game/tools/run_tests.gd`): the repro
itself (`stand_z_for` keeps the anchor's z even past a hull read more than
double it, reproducing the live 6.47-vs-13.16 numbers), plus two guards
that the off-anchor/lerped path is unchanged in both directions. Reproduced
first — temporarily reverted `stand_z_for`'s body to the old
`maxf`-always formula and confirmed the repro test failed exactly as
predicted; restored the fix and reran: `ALL TESTS PASSED`.

**Live playtest, before/after.** Same seed, `mode=play beast=cinder_jackal
steps=80`. Before (unfixed): `home (5.230187, 13.825942, 10.253428)`, a
**3.78** world-unit z-gap from the anchor (6.473), floating over the arena
wall with nothing under it at all — the playtester's own frames above.
After (this fix): `home (5.335257, 13.825942, 7.030925)`, the z-gap down to
**0.56** world units — the wild, obviously-broken float is gone:

![[frames/fixer/2026-09-23-hunter-foothold4-fixed-step037.png]]

**Not fully closed — filed separately, on purpose.** `hunter-off-marker`
(check 8) still fails narrowly at foothold 4 (x off by 0.37-0.48m past its
1.06 tolerance), and a tight crop on the frame above shows a real, much
smaller residual: the specific moment check 8 still catches is when BOTH
hunters share foothold 4 at once (confirmed live: `other_foot=[4, 4]`,
`side=±1`) — `stand_offset_x`'s own by-design spacing, scaled off the
WHOLE beast's bounding-box width, pushes the side-shifted hunter clear of
the jackal's narrow ear at that spot, and `_build_float_stones` only ever
builds one CENTRED stone per height, so the side-shifted hunter has no
stone to land on either:

![[frames/fixer/2026-09-23-hunter-foothold4-shared-side-gap-step037-crop.png]]

This is a genuinely different mechanism from the hull-grabbing-the-ear bug
this request reported and describes (`stand_offset_x`'s spacing vs. local
body width, and `_build_float_stones`'s one-stone-per-height assumption),
not a sign the fix above is incomplete for what was actually reported.
Filed as its own request rather than scope-creeping this one:
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.

Full three-mode intent: `play` (80 steps) run above; `hover`/`hands` not
re-run this pass (time went to nailing the exact mechanism instead) — worth
a fresh three-mode baseline next run, though nothing in this change touches
hover/hand-layout code. Two pre-existing, unrelated `hop-no-squash` /
`hop-flat` failures also showed up in the same 80-step run (steps 30, 42,
52, 53) — all with 6-7 in-flight samples, matching the playtester's own
documented sparse-sampling flake pattern for short single-leg hops on this
sandbox's slow renderer (see their status note's `## Old: 2026-09-22, hop
slow-mo + correction`), not anything `_stand_on_model`/`stand_z_for`
touches. Not chasing those here; noting them so nobody re-diagnoses them as
new.
