# climb — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
16 — continuing the icon rubric batches 14-15 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/climb.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). First of batch 16's
four — the **"six are about going up" family**
`design/ART-REVIEW.md` itself names as the other pair to check, alongside the
"not dying" family batch 15 already scored: `climb`, `ascend`, `peak`,
`rope`, `lift`, `rally`. This batch covers the first four in the order
`ART-REVIEW.md` lists them; `lift` and `rally` are left for a future batch.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-15 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. "Build hygiene" and
"Framing"/"Identity" don't apply to a fixed-square icon render and stay
dropped.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up 8x to view, composited over the same flat brown
card-face standin batches 14-15 used, `RGB(139,105,74)`). Alpha channel
bounding box checked directly (`Image.getbbox()`) rather than guessing at
cropping. All four family members rendered and downsampled together in one
script for a true side-by-side comparison.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 3 | 7 | 8 | 8 | **33** |

## What is actually there

A cream/wheat arrow — a triangle pointing straight up on a short cylindrical
post — sitting above two dark navy-grey slabs stacked bottom-left, per the
build comment "two steps" plus "the arrow up." Alpha bbox `(11, 20, 227,
249)`: comfortable margin on all four sides, no clipping.

- **Silhouette @ 42px (7):** the triangle-on-post reads cleanly as an
  upward arrow even through the downsample; the two dark bars beneath
  survive as a solid dark base but don't individually read as "steps" —
  they compress into one shaded block.
- **Family distinction (3):** this batch's central finding, the same shape
  `shield`/`guard` showed in batch 15. Side by side with `ascend` at 42px
  (`climb_family_42px_strip.png`), the two share an almost identical outer
  silhouette — a triangle on a post — differing only in the small
  attachments at the base (two dark bars here vs two gold wing-triangles
  and a tan slab on `ascend`), which read as a faint colour difference at
  the base rather than a different shape. `peak` and `rope` are trivially
  distinct by comparison and don't rescue this line.
- **Mechanic match (7):** an upward-pointing arrow is an unambiguous "up"
  glyph and matches "gain Height" well in isolation. It does not, on its
  own, distinguish itself from `ascend`'s conceptually adjacent "a big
  climb" — the two cards would need to be told apart by a player some other
  way.
- **Colour & contrast (8):** the pale cream arrow reads clearly against the
  dark navy base and against the brown card standin; the strongest colour
  separation of this batch's four.
- **Style consistency (8):** the same bevelled-block construction as the
  rest of the set; nothing about the render stands out as an outlier.

## Diagnosis — two lowest

1. **Family distinction (3).** Concrete fix: change the outer silhouette,
   not just the base attachments — for example, cap `climb`'s post with a
   flat step-block instead of a point, so the "arrow" read stays unique to
   `ascend` and `climb` reads as literal steps instead.
2. **Mechanic match (7).** Concrete fix: since `climb` and `ascend` are
   both "up" arrows for related-but-different Height effects, give one of
   them a genuinely different verb shape (a footprint or a rung ladder for
   `climb`, keeping the arrow for `ascend`'s bigger effect) rather than two
   arrows of different size.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the two dark base bars are meant to be read as "steps" at all
outside the build comment — nothing about their shape (two plain
rectangles, one shorter and offset) signals "stairs" without already
knowing the intent.
