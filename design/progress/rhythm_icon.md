# rhythm — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 (see `target_icon.md` for the batch's full scope and shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/rhythm.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 21's four.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 5 | 4 | 7 | 7 | **30** |

## What is actually there

A SKY-blue jointed line rising from a ball on the left, up to a plateau,
down through a single sharp V to a valley, then back up through another
plateau to a ball on the right — one wide "checkmark"-shaped zigzag, not a
repeating wave — with a PERIWINKLE bar sitting below it, disconnected from
the line.

- **Silhouette @ 42px (7):** the line, both end balls and the bar all stay
  distinct and legible at the real downsample; the shape reads cleanly as
  a single wide V.
- **Family distinction (5), the lower of two lowest lines:** the build
  script's nine points (`sin(k*1.05)`) mathematically complete more than
  one oscillation, but the two swings plateau hard at each extreme rather
  than reading as evenly spaced beats, so what actually renders is one
  dominant V flanked by two short flat runs — a chevron silhouette close
  enough to the "going up" family's mountain shapes (`peak`, `climb`,
  `ascend`, all also built from angled line segments) that colour, not
  shape, is doing most of the separating work. Not as close a pair as
  `target`/`expose` (batch 20-21's 3/10), since the end balls and bottom
  bar are genuinely unique to `rhythm`, but the core line shape overlaps
  a crowded family this item has already flagged twice (batches 15/16).
- **Mechanic match (4), the lowest line scored this batch:** "the Frog's
  combo counter" needs to read as *counting* or *repetition* — a beat
  pattern. What renders is one wide zigzag with a flat run on each side,
  which reads as a single dip or a checkmark, not as a rhythm or a count.
  Nothing in the shape signals "counter" without the keyword already
  known.
- **Colour & contrast (7):** pixel-sampled directly along the line — the
  lit face runs roughly RGB(165,182,201) and the shaded face RGB(109,136,164)
  against the standin RGB(139,105,74), a strong 60-125-per-channel gap
  driven mostly by the blue channel; the PERIWINKLE bar at RGB(119,128,187)
  separates just as cleanly. No colour problem found — the defect above is
  entirely shape.
- **Style consistency (7):** the jointed-limb-plus-end-balls construction
  matches the game's own `limb()` vocabulary used elsewhere (`bow`'s
  string, `flicker_stag`'s antlers); nothing about the render angle or
  palette is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (4).** Concrete fix: replace the current nine-point
   plateau-and-dip curve with an evenly spaced multi-peak wave (three or
   four visible up-down beats rather than one dominant V), so the shape
   itself reads as a repeating pattern rather than a single checkmark —
   the closer the silhouette gets to a literal heartbeat-monitor line, the
   less it needs the keyword to be understood.
2. **Family distinction (5).** Concrete fix: none proposed beyond the
   mechanic fix above — a genuine multi-beat wave would also pull the
   silhouette further from `peak`/`climb`/`ascend`'s single-chevron shapes
   than the current one-V render does.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the two end balls (ICE) being pinned exactly to the alpha bbox's
left and right edges — `(0, 50, 256, 255)` at the any-alpha threshold,
`(0, 50, 256, 254)` at >10 — reads as a problem the way the "no margin"
pattern already named for several other icons across batches 15-20 does,
or is closer to `expose`'s ticks: arguably part of the "reaching to both
ends" intent of a combo counter rather than an accidental clip. Flagged as
the same pattern, not scored as a defect on its own line, per that
convention.
