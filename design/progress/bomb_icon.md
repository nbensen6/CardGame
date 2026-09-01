# bomb — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
19 — continuing the icon rubric batches 14-18 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/bomb.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Second of batch 19's
four (see `flask_icon.md` for the batch's scope and shared rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-18 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 8 | 8 | 8 | **41** |

## What is actually there

A dark charcoal/graphite round bomb with a short stem, and a tan curving fuse
rising off the stem to an orange-and-gold spark ball at its tip.

- **Silhouette @ 42px (8):** the round body plus short stem reads
  immediately and unambiguously as a bomb even compressed — the single
  strongest, most conventional shape read scored in this batch. Docked one
  point because the alpha bbox `(51, 0, 225, 240)` shows the fuse's spark
  tip flush against row 0: the topmost row of non-transparent pixels
  (checked directly, x=182-224) is the spark, which is clipped by the
  canvas rather than fully contained.
- **Family distinction (9):** nothing else scored under this item pairs a
  dark round body with a curling stem-and-spark — clearly apart from
  `flask` (this same batch), the only other roughly-round icon, which
  reads light-purple and necked rather than dark and stemmed.
- **Mechanic match (8):** a bomb reads directly as "a big one-off blast,"
  the strongest match in this batch alongside `flask`'s — docked slightly
  because the spark, the one element that signals "about to go off" rather
  than just "an inert ball," is the same element clipped by the canvas
  edge, weakening the "blast" read a step short of unambiguous.
- **Colour & contrast (8):** pixel-sampled directly: the body ranges
  RGB(33,35,38) to RGB(135,135,137) against the card standin RGB(139,105,74)
  — the darkest values sit far below the standin's luminance (~35 vs ~112,
  a large, unambiguous gap) and the lit highlight near the top does not
  wash out into the standin either. The strongest colour-separation score
  in this batch.
- **Style consistency (8):** the same bevelled-sphere construction as
  `flask`'s body and `thorns`' spiked ball; the curling fuse limb matches
  the tapered-limb vocabulary `climb`'s arrow and `taunt`'s pole already
  use. Nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Silhouette @ 42px / Mechanic match (8, tied).** Concrete fix: pull the
   fuse's spark ball down and left by roughly 0.05-0.06 so its full radius
   clears row 0 with margin, the same crop several other icons in this set
   already carry.
2. **Colour & contrast (8).** No concrete fix proposed — this line already
   scores well; noted only as tied-lowest by number, not a real weak point.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the clipped spark reads as a visible hard cut once seen inside the
game's actual UI frame, or whether the frame crops enough of the outer
canvas anyway that it never shows — this scoring script renders the full
256x256 canvas uncropped, which may overstate how visible the clip actually
is in play. `bomb` is the eighth icon across five batches (`wall`, `rally`,
`lift`, `dexterity`, `strength`, `sword`, `flask` this batch, now `bomb`) to
touch a canvas edge with no margin — worth a shared look at `icons.py`'s
framing/camera setup across the whole set if Nick wants one fix rather than
eight.
