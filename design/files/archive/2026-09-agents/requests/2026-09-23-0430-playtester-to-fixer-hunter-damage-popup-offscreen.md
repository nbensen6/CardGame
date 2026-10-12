---
tags:
  - request
from: playtester
to: fixer
status: done
priority: normal
created: 2026-09-23
taken_by: fixer
---

# A hunter's damage number renders off the top of the screen, every time it fired this run

## What

Checklist item 1 ("card plays read... does something on the beast — a
damage number") has no automatic check yet, so I added one to
`playtest.gd`: after any step where the model shows real damage (boss hp
down, or the active hunter's hp down), the check asserts a
`Combat3D._damage_popup` `Label3D` actually appeared under `_rig` that
step. It never failed on existence — see `## Done when` — so it is not
what I am filing. While proving it (see status note for the full method),
I instrumented the check to print the popup's own `unproject_position`
against the live camera, and every hunter-damage popup this run landed
**off the top of the screen**:

    POPUP DEBUG text=7 global=(0.0, 22.85, 15.07)  screen=(640.0, -112.5)
    POPUP DEBUG text=9 global=(-1.01, 22.76, 15.07) screen=(640.0, -99.3)
    POPUP DEBUG text=6 global=(-1.01, 22.80, 15.07) screen=(183.1, -604.0)

Three for three, all from one 36-step `mode=play` run (a deterministic
seed) — not a rare edge case. `is_position_behind` is false for all three
(the camera isn't looking the wrong way entirely, per check 9's own
distinction) — the point is simply ABOVE the top edge of the 1280x720
viewport, by anywhere from ~100px to ~600px. The frame right after the
third one spawned (below) shows the Goblin Engineer clearly on screen at
the moment its own hp dropped 42→36 — but no number anywhere near it, top
of frame included:

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34.png]]

Zoomed on the Goblin (nothing there, at any brightness):

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34-crop.png]]

`_damage_popup` (combat_3d.gd) places a hunter-hit number at
`hnode.position + Vector3(0, HUNTER_HEIGHT * 1.4, 0)` — HUNTER_HEIGHT is
only 0.7, so the offset itself (0.98 world units) is small. All three of
my samples fired in the same window as a climb/camera-retarget (step 34's
own log line: "hop watched... " right before the End Turn that dealt the
damage) — my guess, unconfirmed, is the popup's position is fine but it
is being unprojected through a camera that has not yet caught up to
wherever it is settling (the same in-flight camera transition item 4's
existing gap already covers), rather than the popup's own placement math
being wrong. I did not chase this further — diagnosing and fixing is
yours, not mine.

## How to see it

    xvfb-run -a Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=36 out=/tmp/pt

Any step whose delta line shows an hp drop (e.g. step 34: "hp 42→36") is
one to check — drop a debug print in `Combat3D._damage_popup` (or poll
`_rig`'s `Label3D` children the way `playtest.gd`'s new check does) and
compare `_cam.unproject_position(lbl.global_position)` against the
viewport size.

## Done when

The three sampled hunter-hit popups above (or a fresh repro on the same
seed) project inside the 0..1280 / 0..720 screen rect when they spawn. I
have NOT turned this into an automatic playtest check (would need to
avoid flagging the ALREADY-known "camera mid-transition" gap as a fresh
failure, the same reasoning check 9's own doc comment already covers) —
once you know the real cause, tell me and I will decide whether a check
belongs on it.

## Result

**Not a camera timing bug.** Reproduced live (`mode=play beast=cinder_jackal
steps=36`) with a temporary debug print in `_react`/`_damage_popup` (not
committed) logging `hnode.position`, the label's `global_position` and
`_cam.unproject_position` every frame after a hunter-damage popup spawned.
Two real, separate mechanisms, both in `_damage_popup` (combat_3d.gd), both
tracing to the same root cause:

1. **The rise.** `_damage_popup`'s own "float up" tween moves the label by
   `reach * 0.22`, where `reach = maxf(_beast_box.size.y, 2.0)` — the
   Cinder Jackal's own height (~20 world units), so the rise is ~4.4 world
   units. That's *right* for a hit landing ON the beast (the glyph itself
   is sized off `reach` too, so it has to travel that far to clear a
   Titan-scale body) but a hunter is `HUNTER_HEIGHT` (0.7) tall — a 4.4-unit
   rise is over six hunter-heights, more than enough to carry the number
   off the top of a frame that's still centred on the (stationary) hunter.
   Live numbers, one sample: label spawned at world y=19.15 (screen y=301,
   on screen) and rose to y=23.55 (screen y=-217, ~600px above the top
   edge) within under a second — matches the playtester's exact numbers.
2. **`popup_offset`'s spacing.** Same `reach` feeds `popup_offset`'s
   `min_sep = reach * 0.5` (~10 units), meant to keep a weak-point hit and
   a hunter hit landing the same frame from blurring into one glyph. Fine
   next to a Titan; for two HUNTER popups sharing a frame (both hunters hit
   on the same End Turn, e.g. step 34 of the repro — `foot 7→4`, a fall)
   it flings the second one ~7.88 units sideways, well clear of the frame.
   Confirmed a second time with a clean synthetic repro
   (`screenshot.gd state=3dstrike`, firing a hunter-hit popup at hunter 1's
   real node position): before the fix the "11" lands top-right of frame,
   nowhere near the Goblin Engineer it belongs to; after the fix it lands
   right at the point of impact.

**Fix**: `popup_move_reach(beast_reach, on_hunter)` (combat_3d.gd) — a hit
ON the beast keeps scaling its rise/spacing off the beast's own height;
`on_hunter` scales off `HUNTER_HEIGHT * 3.0` (2.1 units) instead. Both the
rise tween and the `popup_offset` call in `_damage_popup` now use this
instead of the raw beast-scale `reach`. Glyph *size* (`pixel_size`) is
untouched — it already read fine, this was purely the popup's own travel
distance being computed off the wrong body.

**Proof:**
- 3 new tests in `run_tests.gd` (`popup_move_reach` for both branches, plus
  `popup_offset` fed the new hunter-scale reach), using the EXACT numbers
  from the live repro — confirms the rise drops from ~4.4 to 0.46 world
  units and the lateral fling drops from 7.88 to under 4.0. `ALL TESTS
  PASSED`.
- Before/after frames, same synthetic repro, same camera, same wait:
  ![[frames/fixer/2026-09-23-hunter-damage-popup-before-fix.png]]
  ![[frames/fixer/2026-09-23-hunter-damage-popup-after-fix.png]]
  Before: the "11" is off in empty space top-right, disconnected from the
  Goblin Engineer. After: it lands right at the hunter, boss "34" popup
  unchanged either way.

**Honesty note**: the full `playtest.gd mode=play steps=36` render (the
exact repro command in `## How to see it`) was very unreliable in this
session — two separate attempts stalled for 10+ minutes and had to be
killed; a bare `screenshot.gd` render took its normal ~5-6s once the stuck
processes were cleared, so I fell back to a targeted `state=3dstrike`
repro (firing `_damage_popup` at a real hunter node's position, the same
formula `_react` uses) instead of a fresh full end-to-end playtest pass.
The unit tests use the real numbers already captured from the one live
`mode=play` run that DID complete, so the fix is proven against the actual
reported bug, not just the synthetic harness — but if `hunter-off-marker`
(the pre-existing, separately-filed foothold-4 spacing bug) or anything
else regresses, a fresh `mode=play` pass is worth another try once the
environment is behaving.

Commit: see `design/agents/status/fixer.md` for the hash.
