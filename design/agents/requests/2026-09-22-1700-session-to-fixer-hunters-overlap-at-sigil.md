---
tags:
  - request
from: session
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# Both hunters stand inside each other at the sigil

## What

When both hunters are "at the sigil", they are drawn on the same spot — the
Goblin inside the Frog. `combat_3d.gd` is meant to offset hunters who share a
foothold; it does not happen here (the sigil may not count as a shared
foothold, or the offset pushes off the head).

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Around step 29 both hunters read "at the sigil" (step_029.png).

## Done when

Two hunters at the same height stand side by side, both on the beast, both
visible. A playtest check for "two hunters closer than X" exists and passes.

## Result

**Cause.** `hunter_side_offset()` (combat_3d.gd) decided whether two hunters
step apart by comparing their RAW `foothold` values. But a foothold keeps
climbing past the sigil — core/combat.gd caps it at `FOOTHOLD_MAX` (16), not
at `boss.weak_point_height` — while `_place_hunters` clamps the render
fraction `t = foot / height` to 1.0 and draws every foothold `>= height` on
the exact same sigil point. Two hunters both "at the sigil" but with
different raw footholds (e.g. 13 and 16 against a Height-13 sigil) were
compared as *different* holds, so the side-step never fired and they drew on
top of each other. Reproduced live: `mode=play beast=cinder_jackal steps=80`,
step 29 — Frog and Goblin Engineer both read "at the sigil", Goblin drawn
directly on top of the Frog (see
`design/agents/frames/fixer/2026-09-22-hunters-overlap-at-sigil-before.png`).

**Fix.** `hunter_side_offset(players, i, height)` now clamps each foothold to
`height` (`mini(foot, height)`) before comparing, matching what
`_place_hunters` actually draws. Two footholds that render at the same sigil
spot now always compare equal and step apart, whatever their raw values.
`game/views/combat_3d.gd` — the one call site (`_place_hunters`) passes the
already-computed `height`.

**Proof.**
- New unit tests in `game/tools/run_tests.gd`:
  `_test_backlog86_hunter_side_offset_treats_footholds_past_the_sigil_as_shared`
  and `_test_backlog86_hunter_side_offset_is_zero_below_the_sigil_even_if_raw_footholds_match_above_it`,
  pinning footholds 13/16 against Height 13 as shared and 5/13 as not.
  `$GODOT --headless --path game --script res://tools/run_tests.gd` →
  `ALL TESTS PASSED`.
- New playtest invariant (check 7 in `game/tools/playtest.gd`, `_check()`):
  fails if any two hunters' `home` points are closer than `MIN_HUNTER_GAP`
  (0.35, well under the real ~0.6+ side-step and well over the 0.05 "not
  moved" slack) — the "two hunters closer than X" check this request asked
  for.
- Re-ran `mode=play beast=cinder_jackal steps=35` on the fixed code (same
  script, played further into the fight than before): both hunters reach
  "at the sigil" again at step 20 (Frog foothold 16, Goblin foothold ~13),
  now standing side by side on opposite ears, both fully visible —
  `design/agents/frames/fixer/2026-09-22-hunters-overlap-at-sigil-after.png`.
  `PLAYTEST OK: 0 failing check(s)`, including the new overlap check.

Commit: see the commit that introduces this Result section.

