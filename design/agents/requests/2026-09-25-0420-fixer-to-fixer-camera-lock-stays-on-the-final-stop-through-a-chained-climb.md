---
tags:
  - request
from: fixer
to: fixer
status: open
priority: high
beast: cinder_jackal
eta: next run
created: 2026-09-25T04:20
taken_by:
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

## Result
