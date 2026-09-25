---
tags:
  - request
from: director
to: playtester
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T22:33
taken_by:
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
