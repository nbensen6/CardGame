# taunt — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 20 — continuing the icon rubric batches 14-19 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/taunt.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 20's four (see `expose_icon.md` for the batch's scope and shared
rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 6 | 8 | 8 | **38** |

## What is actually there

A dark UMBER flagpole topped with a small GOLD ball, carrying three
horizontal ORANGE/TANGERINE banners of decreasing width stacked down the
pole — a signal flag or notice-board, read as one continuous shape.

- **Silhouette @ 42px (7):** the pole-and-flags block survives the
  downsample as one clean, solid silhouette; the top ball shrinks to a
  small dot but the three-flag stack it sits on stays legible as three
  distinct bands rather than fusing into a single rectangle.
- **Family distinction (9):** checked against every other icon scored
  under this item — nothing else uses a pole-with-banners shape; this is
  one of the more unambiguous silhouettes scored so far.
- **Mechanic match (6):** a flag on a pole reads as "planting a marker" or
  "a signal/rally point," which is a reasonable metaphor for pulling
  attention, but nothing about the shape specifically ties it to *the
  beast's* attention rather than a generic notice-board or waypoint icon
  — no eye, no aggressive posture, no line pointing at a target the way
  `expose`'s crosshair points at one. A player who hasn't read the
  keyword text would plausibly guess "a marker/checkpoint" before
  guessing "taunt."
- **Colour & contrast (8):** pixel-sampled directly: the UMBER pole runs
  roughly RGB(72-78, 39-43, 27-30), darker and redder than the brown
  standin RGB(139,105,74) — a real, unambiguous separation on the dark
  side; the ORANGE/TANGERINE flags are visibly lighter and more saturated
  than the standin in every rendered view.
- **Style consistency (8):** the flat bevelled banner slabs match the
  slab-stack construction used elsewhere in the set (`wall`'s bricks,
  batch 19's `gadget`); the ball-topped pole matches the spike-plus-ball
  vocabulary `support` and `relic` (this batch) also use.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: none proposed that stays within
   "one concrete fix, not redesign the whole icon" — the flag reads fine
   as *a* signal, just not distinctly as *aggro-pulling* versus any other
   marker; a small directional cue (an arrow or eye motif worked into the
   topmost flag) would be the more targeted change if Nick wants one.
2. **Silhouette @ 42px (7).** Concrete fix: the top ball is the icon's
   only rounded element and is nearly lost at 42px; enlarging it slightly
   relative to the pole width would keep it legible as a deliberate cap
   rather than a stray dot.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "signal flag" reads as *taunt* specifically to a player with no
tooltip open, or whether it needs the keyword text to land — the same
kind of open question `intangible_icon.md` already named for "afterimage,"
and not settleable from a static render alone.
