---
tags:
  - request
from: director
to: playtester
status: done
priority: high
beast: cinder_jackal
eta: this run
created: 2026-09-24T22:33
taken_by: playtester
ask:
waiting: false
---

# Your checks measure where the hunters USED to stand and a camera Nick has replaced

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Nick's own commit `b0648db` (22:12 EDT) moved the route to `route_pos()`
  (one straight line from the ground to the top hold) and parked the ground
  camera 9 units behind the active hunter. His message: `hop-distance-band`
  and `hunter-off-marker` "both read `_climb_points`, the beast's authored
  anchors, so they measure where a hunter USED to stand and cannot see the
  route at all. Filed for the playtester rather than silenced." Nothing was
  filed; this is it.
- Point both checks at the live route (`route_pos` / `_stand_on_model`), so
  a real miss fires and the current, correct route does not. Prove both
  directions as you always do.
- `camera-ots-while-grounded` (your 19:18 split) forbids what Nick now wants
  at rest. His target is a Risk of Rain third-person shot: camera behind the
  ACTIVE hunter at rest AND mid-climb. Flip that check back to "third-person
  on the active hunter always" — and write in its comment that this is
  Nick's decision of 22:25 EDT so the next flip needs his word, not a
  ticket.
- Do NOT delete or skip either check. Do NOT tune the route or the camera
  yourself — the fixer is on both tonight; land yours first so its playtests
  are honest.

## What

Tonight the fixer will re-lay the stones left-to-right and lock the camera
behind the hunter (two tickets, high). Every one of its runs ends with a
full playtest, and right now that playtest reports 62 `hop-distance-band`
fails that describe nothing on screen. A red baseline nobody trusts hides
the one real regression when it comes.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

## Done when

- On current main: 0 `hop-distance-band`, 0 `hunter-off-marker` false fires,
  and both still fire when you break `route_pos` on purpose.
- The camera check fires when the resting camera is NOT behind the active
  hunter, and does not fire on `b0648db`'s resting shot.
- `ALL TESTS PASSED`; baseline table in `## Result`.

## Nick's answer

## Result

Done, 2026-09-24 23:44 EDT. `game/tools/playtest.gd`, no game code touched.

**`hunter-off-marker` (check 8):** now compares a hunter's real `home`
against the LIVE route -- `foothold_anchor`/`stand_offset_x` (x/y, real
side) for the top hold, `route_pos(route_top_hold, ground_z, i, n)` (exact,
side-independent) for every rung below it -- instead of the raw
`_climb_points` anchor. `route_top_hold`/`route_rungs`/`ground_z` are
recomputed independently from the same pure static pieces `_stand_on_model`
itself calls, not by calling `_stand_on_model`, so a wiring bug (wrong
foot/index/count reaching it) still has something independent to fail
against. z is skipped for the top-hold, off-anchor case only -- that's
`stand_z_for`'s own hull query (`_front_of_beast`), which this file has no
independent way to recompute, and which the ORIGINAL version of this check
never verified either.

Verified both directions: 0 fires across a full `play` (80 steps), `hover`,
and `hands` (1-10) baseline on real, current code. Fires 2/2 when I reverted
`_stand_on_model` to always return `on_body` (simulating undoing b0648db's
route_pos fix, temporary, never committed) -- `git diff` on `combat_3d.gd`
is clean.

**`hop-distance-band` (8c):** now measures the LIVE route's own
consecutive-rung distances -- `route_pos()` at each index, reusing check
8's own `route_top_hold`/`route_rungs`/`ground_z` -- instead of raw
`_climb_points` anchor-to-anchor distance.

This is where the real finding is. On current main it reports **124** fails
(`play`, 80 steps) -- not 0. Every one of the four ordinary hops (Height
1->2, 2->3, 3->4, 4->5) measures **exactly 20.44m**, 2-8x `hop_arc()`'s own
9.15m ceiling, every single call. I checked this is real, not a check bug,
three ways: (1) hand-derived the same 20.44m from the beast's own printed
`_climb_points`/box numbers independent of any code path here; (2)
temporarily reverted `GROUND_STANDOFF` to its pre-b0648db value (0.62, never
committed) and re-ran `mode=hands` -- 0 `hop-distance-band` fails, proving
the check tracks real geometry both ways, not a fixed false positive; (3)
looked at the actual frames -- a hunter is invisible for 6 of 8 sampled
frames of an ordinary climb hop, then pops in already close to the beast.
b0648db's own even-spacing design (`n-1` equal steps across the WIDENED
82-unit gap it just opened) makes every ordinary hop this long by
construction, regardless of which specific Heights a beast names. Filed
separately, since it's a real, new, high-priority finding and not something
this ticket's check-pointing was meant to fix:
`2026-09-24-2344-playtester-to-fixer-ordinary-climb-hops-now-measure-20m.md`.

**Camera (9c):** flipped per Nick's 22:25 EDT decision, comment cites it by
name so the next flip needs his word. Not the `_shoulder`/`_focused` TRUCK
9b already checks (still mid-climb-only, untouched, per Nick's own "mid-
climb stays as it is") -- the fixer's own rebuild of the resting shot to
engage that truck too is still open tonight (`2155`), and demanding it here
would fail on their not-yet-built code for no reason. Checks the weaker,
already-true invariant b0648db's 22:12 commit already provides: from the
active hunter's own eye level, does the camera sit roughly opposite the
beast (third-person chase angle), not beside or in front of them
(`BEHIND_HUNTER_MIN=0.5` on the dot product between camera-from-hunter and
hunter-to-beast, both normalised).

Verified both directions: 0 fires on the real, current resting shot (real
value measured: 0.98) across a full three-mode baseline. Fires 1/1 when I
forced `_lock_point` to fall back to `Vector2.ZERO` (simulating the camera
losing track of the active hunter entirely, temporary, never committed;
measured value: -1.00) -- `git diff` on `combat_3d.gd` is clean.

**Baseline, all three modes, real committed code (after this fix):**

| mode | hop-distance-band | hunter-off-marker | camera-not-behind-hunter | script-error |
|---|---|---|---|---|
| play (80 steps) | 124 | 0 | 0 | 0 |
| hover | 4 | 0 | 0 | 0 |
| hands (1-10) | 44 | 0 | 0 | 0 |

`ALL TESTS PASSED` (`run_tests.gd`), before and after.

Two of three Done-when bullets met exactly as asked. The third
(`hop-distance-band` reads 0) can't be, honestly -- the check now measures
the live route correctly, as asked, and what it measures is a real, new
regression bigger than the one this ticket was filed to unmask. Landing a
check that reads 0 here would mean going back to measuring the wrong thing.
Filed the finding above rather than tune the route to make it disappear.

![[frames/playtester/2026-09-24-hop-distance-20m-pop-in-strip.png]]
