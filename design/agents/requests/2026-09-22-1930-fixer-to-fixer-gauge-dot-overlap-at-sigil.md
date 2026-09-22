---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# Climb-rail gauge draws one hunter's dot on top of the other's at the sigil

## What

Filed by myself, found while hunting bugs per the fixer brief (no open
`to: fixer` request this run). The climb rail (`_draw_gauge` in
`combat_3d.gd`, the right-edge ladder HUD) draws one dot per hunter for their
current Height. Once both hunters are at or past the sigil with different
RAW footholds (e.g. Frog at 16, Goblin at 5, sigil Height 5), only ONE
tinted dot shows on the rung — the second hunter's dot is drawn in the exact
same spot and paints over the first.

Same root as the two earlier sigil fixes today (hunters-overlap-at-sigil,
climb-readout-past-sigil): a foothold keeps climbing to `FOOTHOLD_MAX` past
the sigil (core/combat.gd never caps it at `weak_point_height`), and
`_draw_gauge`'s `y_of` correctly clamps the Y position for that — but the
code that decides whether to step the two dots apart
(`if heights.size() > 1 and int(heights[0]) != int(heights[1])`) compared
the RAW footholds, not the clamped ones. Two hunters both drawn on the same
clamped rung but with different raw values (16 vs 5) read as "on different
rungs" and the step-apart never fired.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=25 out=/tmp/pt

Step 20: Frog foothold 16, Goblin foothold 5, sigil Height 5 — the gauge
shows a single blue (Goblin) dot at the top rung; the Frog's green dot is
hidden underneath it.

## Done when

Both hunters' dots are visible, side by side, on the rung whenever their
clamped footholds match — a unit test pins the rule.

## Result

**Cause.** Confirmed exactly as filed: `_draw_gauge` compared
`int(heights[0]) != int(heights[1])` (raw footholds) to decide whether to
offset the two dots apart. Reproduced live at
`mode=play beast=cinder_jackal steps=25`, step 20 — only the Goblin's blue
dot is visible on the sigil rung, the Frog's green dot painted underneath it
(`design/agents/frames/fixer/2026-09-22-gauge-dot-overlap-before.png`, crop
in `-before-crop.png`).

**Fix.** Pulled the decision into a new pure function,
`Combat3D.gauge_dot_dx(heights: Array, i: int, top: int) -> float`
(`game/views/combat_3d.gd`, right before `_draw_gauge`), matching how
`hunter_side_offset` was already pulled out for the 3D placement bug. It
clamps both `heights[0]` and `heights[1]` to `top` (mirroring `y_of`) before
comparing, so two footholds that render on the same rung always compare
equal and step apart, whatever their raw values. `_draw_gauge` now just
calls `gauge_dot_dx(heights, i, top)` for `dx`.

**Proof.**
- Four new unit tests in `game/tools/run_tests.gd`:
  `_test_backlog86_gauge_dot_dx_is_the_default_offset_for_a_lone_hunter`,
  `_test_backlog86_gauge_dot_dx_splits_apart_when_footholds_match`,
  `_test_backlog86_gauge_dot_dx_centres_both_dots_when_footholds_genuinely_differ`,
  and the regression pin,
  `_test_backlog86_gauge_dot_dx_treats_footholds_past_the_sigil_as_shared`
  (footholds 13/16 against a Height-13 sigil, mirroring the existing
  `hunter_side_offset` sigil test). `$GODOT --headless --path game --script
  res://tools/run_tests.gd` → `ALL TESTS PASSED`.
- Re-ran the identical reproduction (`steps=25`) on the fixed code, same
  deterministic sequence (step 20: Frog foot 16, Goblin foot 5): both the
  green and blue dots now show side by side on the sigil rung —
  `design/agents/frames/fixer/2026-09-22-gauge-dot-overlap-after.png`, crop
  in `-after-crop.png`. Playtest report: `**All checks passed.**`

Commit: see the commit that introduces this Result section.
