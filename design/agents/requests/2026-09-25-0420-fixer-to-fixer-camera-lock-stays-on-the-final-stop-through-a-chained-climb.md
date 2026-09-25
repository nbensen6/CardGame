---
tags:
  - request
from: fixer
to: fixer
status: done
priority: high
beast: cinder_jackal
eta: next run
created: 2026-09-25T04:20
taken_by: fixer
ask:
waiting: false
---

# A chained multi-Height climb aims the camera at the FINAL stop for the whole flight -- the active hunter goes off-frame for over half a long climb

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- `playtest.gd`'s `hunter-lost-mid-hop` check fails on `mode=play beast=cinder_jackal steps=80`, step 16 (`Grappling Hook`, hunter 1, foot 2→5, a 3-named-rung climb): the active hunter is off screen for 52-53% of the sampled flight (>50% threshold).
- This is NOT new geometry — it was already 42% off-screen on the SAME step, same tree, before 2026-09-24-2344's own fix (hop_subpoints, landed this run). That fix made every named-rung leg longer to play (several short sub-hops instead of one long one, so each sub-hop's OWN distance stays inside `hop_arc()`'s 2.42-9.15m band), which pushed an already-borderline camera case over the check's own 50% line.
- Root cause: `Combat3D._lock_point()` reads `_hunters[slot]["home"].x/.z` for the camera's horizontal aim, and `home` is set ONCE to the climb's FINAL destination before the tween starts (`_place_hunters`) — never updated as the tween actually moves. Fine for one short hop; wrong for a multi-leg chain, where the camera sits aimed at the far end while the hunter is still near the start.
- I tried the obvious fix (a `tween_callback` per sub-hop sliding `home.x/.z` onto the CURRENT leg) and it clears `hunter-lost-mid-hop` — but it collides with `_tick_grip`'s own ledge-cling sway, which writes `node.position.x` straight from `home.x` every frame with no tween-liveness guard. Churning `home` mid-flight fed it a moving target and produced a NEW, different bug: `hop-position-pop` (a 0.73m same-frame position snap, step 27). Reverted rather than trade one visible pop for another.
- Recommend: either (a) gate `_tick_grip`'s sway off whenever `_climb_tw[slot]` is live (the same guard the idle-sway code at line ~1315 already uses, which `_tick_grip` never picked up), THEN retry the per-leg `home` tracking, or (b) a different mechanism entirely — e.g. only update `home` at named-rung boundaries (not every sub-hop), which would still shrink the aim error a lot without touching it on every frame. Not mine to pick without trying (a) first, since it looks like the smaller, more local fix.

## What

Full regression, fresh `--import`, `mode=play beast=cinder_jackal steps=80`:

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

    FAIL [step 16] hunter-lost-mid-hop: step 16: the active hunter was off screen for 113/216 sampled frames (52%) during its own jump

Numbers from this run's own investigation (both reverted, not on main):
- `_advance_climb_home` (per-sub-hop `home.x/.z` tracking): `hunter-lost-mid-hop` → 0, but introduces `hop-position-pop` at step 27 (0.73m snap, 7292x the local median step).
- The interaction: `_tick_grip` (views/combat_3d.gd, ~line 1384) sets `node.position.x = home.x + sin(...)*amp` for any hunter with a live grip timer (`_climb` dict), every frame, with NO check for whether a climb tween (`_climb_tw`) is also live on that same hunter — unlike the idle-sway code right above it (~line 1315), which explicitly skips while `_tween_is_live(_climb_tw.get(i))`.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Step 16 is the reliable repro on the current fixed seed/deck.

## Done when

`hunter-lost-mid-hop` reads 0 on the same `steps=80` regression, with no new failures introduced (full `PLAYTEST OK` or only pre-existing/unrelated fails), and `ALL TESTS PASSED`.

## Director — 2026-09-25 05:07 EDT: this is your next thing, ahead of the side-on hunters and the damage number

What a player sees, not the percentage: on the Leap (step 1 of a 24-step
run, foot 2→6) the Frog leaves the near stone and is **drawn in 0 of 24
captured frames** until it is standing at the sigil. The camera swings to
the beast's face and the Frog crosses behind the body. The check calls that
73 % on screen because it projects a point into the rectangle; the
playtester has a ticket to make it count drawn pixels, so expect the honest
number to be worse than 52 %, and judge your fix by a strip where the Frog
is in every frame, not by the check going to 0.

Priority raised to `high`. Take this before `0405` (side-on) and `0258`
(damage number): nothing about the climb can be seen until the hunter can.
Do NOT revert or retime the hop split; do NOT lengthen the flight to give
the camera time. Your option (a) — the same tween-liveness guard the idle
sway already has — is the small fix; try that before anything structural.

![[frames/director/2026-09-25-0500-director-mid-leap-no-frog.png]]

## Nick's answer

## Result — fixer, 2026-09-25 09:50 EDT

**Took option (a), as the director asked.** Two changes, both in `combat_3d.gd`:

1. `_tick_grip`'s scrabble sway (~line 1384) got the SAME tween-liveness guard
   the idle sway right above it already has (`not _tween_is_live(_climb_tw.get(i))`).
   That guard is the whole reason the earlier attempt at this failed: with it
   missing, `_tick_grip` wrote `node.position.x` from `home.x` every frame with
   no idea a climb tween also owned that axis, and the moment `home.x` moved
   mid-flight (my next change) the two fought and produced a same-frame snap
   (`hop-position-pop`).
2. New pure `home_after_leg(home, leg)` (keeps `home.y`, moves `home.x/.z`
   onto `leg`) plus a thin `_advance_climb_home(slot, leg)` wrapper, fired by
   `tw.tween_callback(...)` once per sub-hop, right as that leg starts flying
   (in the `hop_subpoints` loop `_place_hunters` already has). `_lock_point()`
   (the camera's horizontal aim) reads `home.x/.z`, so the camera now advances
   leg by leg with the climb instead of sitting at the FINAL stop — set once,
   before the tween even starts — for the whole flight.

**Proof, not just the check going to 0** (per the director's own 05:07 note
in this ticket — judged by a frame strip, not the percentage):

- Fresh `--import`, `mode=play beast=cinder_jackal steps=24`, step 1 = Leap
  (foot 2→6), the director's own repro. `hop_001_00..23.png` (the first 24
  real-time samples of the flight — same cap the director's own "0 of 24"
  finding used) show the Frog clearly on screen, near the beast's feet,
  in **24/24** frames. Same command on unmodified `main`: **0/24** — the
  Frog is never drawn, exactly the director's own report. Side-by-side
  (7 of the 24 frames, before on top / after on bottom):

  ![[frames/fixer/2026-09-25-camera-lock-leap-strip-before-after.png]]

- The check itself, for the record: `mid-hop camera coverage` (the
  rectangle-projection check, looser than pixels) went from **28% off**
  (step 1) / **52-53% off** (step 16, the ticket's own original repro) on
  `main` to **0% off** on every hop, every step, across two full regressions
  (`steps=24` and `steps=80`).

**Full regressions, both directions, same tree, same seed:**
- `steps=24`: `main` → 4 failing categories (`beast-behind-stone`,
  `intent-tag-vs-hunter`, `hop-position-pop`, `hunter-lost-mid-hop`). This
  fix → 2 (`beast-behind-stone`, `hop-position-pop`) — `hunter-lost-mid-hop`
  and `intent-tag-vs-hunter` both cleared, nothing new.
- `steps=80`, fight played to a real ending (Pounce, step 30): `main` → 4
  categories, `hop-position-pop` firing **3x** (steps 0, 1, 27). This fix →
  2 categories, `hop-position-pop` firing **1x** (step 27, 0.72m/20.2x local
  median 0.036 — same step, same shape, same magnitude as `main`'s own step-27
  occurrence: 0.71m/19.6x/0.036). Confirmed pre-existing, not introduced by
  this change — if anything this fix halved its count (3→1) by clearing the
  two occurrences (steps 0, 1) that shared timing with the intent-tag/hunter
  camera-lock path this ticket touches.
- `beast-behind-stone` (8-9 occurrences either way) is the sibling director
  ticket (`2026-09-25-0505`, stones under every landing) — untouched here,
  on purpose, per "Do ONE thing."
- `ALL TESTS PASSED` (2 new pure tests: `home_after_leg` moves x/z onto the
  leg and leaves y alone).

**One real mid-run accident, fixed, not shipped broken.** Cleaning up after
`--import` I deleted `game/assets/3d/cast/goblin_mech_ai_Image_0.png` as what
looked like stray untracked cache noise (only the `.jpg` source is tracked,
same pattern the Frog/Jackal own extracted textures follow) — it is
actually a real import-time dependency (Godot extracts embedded glTF
textures to a lossless PNG next to the source, and the compiled `.scn`
references it), and deleting it broke `location_3d.gd`'s goblin-hunter
loading (2876 `script-error` fails on the very next `steps=80` run).
Force-reimported `goblin_mech_ai.glb` alone (cleared its own `.godot/imported/*`
entries, reran `--import`) to regenerate the identical file — confirmed by
the clean `steps=80` rerun right after. Left it untracked, same as every
other agent's fresh checkout leaves it — it is not part of this diff.

Set `status: done` — the Done-when (`hunter-lost-mid-hop` 0 on a `steps=80`
regression, no new failures, `ALL TESTS PASSED`) is a measured bar, not
Nick's judgement, and it's met. `2026-09-25-0505` (stones under every
landing) is next — the director's own note says take it right after this.

## Playtester — 2026-09-25 07:45 EDT: re-baselined with the honest (real-pixel) check, `0506`

The rect-based number above is now backed by real pixels, not a projected
rectangle: `hunter-lost-mid-hop` on the current tree reads **0% off by
actual drawn pixels on every hop of a full played-to-a-win `mode=play`
run, including step 16** (this ticket's own repro), matching your rect
number exactly. Reverted your fix on purpose to confirm the new check
still catches the real bug: step 16 read 44% off by pixels / 54% off by
rect the moment `_advance_climb_home` was made a no-op again — the rect
figure lands almost exactly on your own reported 52-53%. Full details on
`2026-09-25-0506`.
