# target — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 — the next four of the eight "twenty-eight card icons" left unscored
after batch 20, in `card_view.gd`'s own `ICONS` table order (`target`,
`rhythm`, `timer`, `cog`). **Scoring pass only — report, not repair; no
edits to `tools/blender/icons.py`.** Asset: `game/assets/icons/target.png`
(256x256, rendered by `icons.py`, orthographic head-on per
`design/ART-REVIEW.md`'s own build note). First of batch 21's four (see
`rhythm_icon.md`, `timer_icon.md`, `cog_icon.md` for the rest).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method: Pillow real
42x42 `LANCZOS` downsample composited over the flat brown card standin
`RGB(139,105,74)`, plus a numeric alpha-bbox check at both any-alpha and
alpha>10 thresholds (batch 17's addition, carried forward).

`target` is the other half of the pair batch 20's `expose_icon.md` already
flagged from `expose`'s side — this file confirms the same finding from
`target`'s own scoring pass rather than re-rendering the comparison a
second time.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 7 | 7 | 8 | **33** |

## What is actually there

Two concentric rings (GOLD outer, AMBER inner) around a small BRICK-red
ball at the centre, with a SILVER shaft and a BRICK arrowhead crossing the
rings on one diagonal, as if an arrow has struck the bullseye.

- **Silhouette @ 42px (8):** the double ring, centre ball and diagonal
  shaft survive the downsample as one clean, legible bullseye-and-arrow
  shape; the shaft stays a distinct straight line rather than blurring
  into the rings.
- **Family distinction (3):** confirms `expose_icon.md`'s own batch-20
  finding directly, checked again from this file's own render — `target`
  and `expose` are built from the same double-ring-plus-centre-ball
  recipe and read as near-identical bullseyes at 42px. The only reliable
  tell is `target`'s one diagonal SILVER shaft versus `expose`'s four
  axis-aligned ticks, and at the real read size that is one thin line
  against four thin spurs, not a difference in silhouette. Scored the
  same 3/10 `expose` carries for the identical reason.
- **Mechanic match (7):** "scales off Exposed" pairs naturally with an
  arrow already lodged in a bullseye — a hunter capitalising on a mark
  already applied. More literal and specific than `expose`'s own bullseye
  (which has no arrow, since it applies the mark rather than exploiting
  it), so scored a point above `expose`'s 6.
- **Colour & contrast (7):** pixel-sampled directly — the outer ring runs
  roughly RGB(194,156,89) and the inner ring RGB(197,146,85) against the
  standin RGB(139,105,74), a real separation of 45-70 per channel; the
  BRICK centre ball at RGB(176,104,99) separates least cleanly of the
  three (only 37 in red, 24 in blue, near-zero in green against the
  standin) but stays visible against the lighter rings surrounding it.
- **Style consistency (8):** the ring-plus-centre-ball construction
  matches `expose`, `buffer`'s hex ring and `guard`'s ring-over-slab;
  nothing about the render angle or palette is an outlier.

## Diagnosis — two lowest

1. **Family distinction (3).** Concrete fix: same root cause `expose_icon.md`
   already named from the other side — since `target` and `expose` are
   the two Expose-family cards most likely read together, give one of
   them a shape element the other doesn't share at all (not just a
   different mark at the edge). The arrow shaft is the closer starting
   point on `target`'s side: extending it fully across the icon rather
   than stopping short of the centre, or splitting one ring into a
   distinct broken/notched shape, would separate the silhouette itself.
2. **Mechanic match (7).** No separate fix proposed — the family-distinction
   problem is the more actionable of the two, and fixing it (giving
   `target` a shape `expose` doesn't share) would likely also sharpen
   which card is "applying" versus "exploiting" the mark.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the arrowhead's BRICK tone reading close to the centre ball's own
BRICK tone (both the same base colour) is deliberate — "the arrow struck
the bullseye's own colour" — or an accident of reusing one palette entry
for two different parts; the render alone can't distinguish intent from
coincidence.
