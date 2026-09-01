# dexterity — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 17 — continuing the icon rubric batches 14-16 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/dexterity.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 17's four — see `design/progress/strength_icon.md` for the pair
this section of `ART-REVIEW.md` names together.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample and alpha-bbox method as `strength_icon.md`
(this batch) and batches 14-16.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 8 | 5 | 8 | 8 | **35** |

## What is actually there

A single soft-edged blue-grey oval (two overlapping tones, ICE over SKY, the
"vane" the build comment names) standing upright, crossed by four thin pale
diagonal grooves. Alpha bbox `(60, 0, 194, 255)`: both the top and bottom
rows are fully opaque — the vane's top touches the canvas ceiling and the
quill (a thin spike meant to poke through both ends per the build comment)
is invisible in the render, cropped off at the bottom edge with nothing
visible below the oval body.

- **Silhouette @ 42px (6):** the oval-with-diagonal-stripes shape survives
  the downsample as a clean, simple silhouette, but it reads as generically
  oval rather than specifically feather-shaped — nothing in the outline
  itself (as opposed to the diagonal grooves, which are a texture detail)
  signals "feather" over "leaf," "guitar pick," or "loaf of bread," all of
  which share the same rounded-oval-with-a-point outline.
- **Family distinction (8):** no other icon in the 36-icon set is a blue
  oval; clearly distinct by shape and colour from `strength`'s dumbbell and
  from everything else scored so far under this item.
- **Mechanic match (5):** confirms `ART-REVIEW.md`'s own stated doubt
  directly — the shape is confidently "not confusable with anything else,"
  which is the bar `ART-REVIEW.md` set for this line, but not confidently
  "a feather," which is the bar Dexterity actually needs. The diagonal
  grooves that are meant to read as barb texture are visible at 256px but
  compress into faint, ambiguous streaks at 42px that could as easily be
  read as fabric folds or wood grain as feather barbs.
- **Colour & contrast (8):** the blue-grey vane reads clearly against the
  brown card standin — the strongest warm/cool contrast pairing scored
  under this item, matching `strength`'s equally clear (if less colourful)
  separation in the same batch.
- **Style consistency (8):** the two-tone overlapping-ball shading matches
  the construction `flask`'s own body already uses per the build comment;
  nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (5).** Concrete fix: taper the oval's top to an actual
   point rather than a rounded arc (the current top edge reads as an
   ellipse tip, not a feather's natural taper), and lengthen the visible
   quill past the vane's own edge instead of letting it clip off-canvas —
   a quill that actually shows, even briefly, would do more to say
   "feather" than another texture pass on the barb grooves.
2. **Silhouette @ 42px (6).** Concrete fix: the same top-taper change would
   likely lift this line too, since the outline carries the whole
   silhouette read at 42px and the texture grooves already fade to near
   nothing at that size regardless of any texture-level fix.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The quill "poking through both ends," per the build comment, is not visible
at either end in this render at all — the alpha bbox shows the bottom row
fully opaque, meaning something reaches the very bottom edge, but nothing
below the oval body is visible as a distinct quill shape; whether that is
the quill clipped flush against the canvas edge (the same pattern this
batch's own `rally`/`strength` and batch 16's other icons show) or the
quill rendering directly behind the vane's own opaque body from this camera
angle is not something a single orthographic render can distinguish. Also
unsure whether "reads as a feather, not just as an unidentified blue oval"
is a bar this icon can clear at all without a genuinely spiked/pointed
outline, versus needing the tooltip to carry that meaning the way
`ART-REVIEW.md`'s own text already allows for the strength icon's cleaner
case.
