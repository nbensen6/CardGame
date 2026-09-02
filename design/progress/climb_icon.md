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

## Pass 2 — fixer

Applied both named lines together, since the same root cause — the
triangle-on-post outer shape — drove both:

1. **Family distinction (3).** Replaced the triangle-on-post with a literal
   three-step staircase, rising left to right, built from three `slabf()`
   plates (STONE for the bottom two, WHEAT for the top) plus a small WHEAT
   marker peg standing on the top step. The outer silhouette no longer
   shares anything with `ascend`'s arrow-and-wings shape.
2. **Mechanic match (7).** The two "up" cards now use genuinely different
   verb shapes — `ascend` keeps the big doubled chevron for "a big climb",
   `climb` is now literal ascending steps for "gain Height" — rather than
   two arrows of different size.

Rebuilt by running `icons.py` directly through Blender (no other icon
script touched — confirmed via `git status`, which showed only
`climb.png` after restoring the other 35 icons Blender re-rendered as a
side effect of running the whole script; a different Blender build than
whatever produced the committed PNGs re-renders every icon with slightly
different antialiasing, up to 69/255 on a single channel on icons whose
own build code never changed, so those 35 were checked out back to
`HEAD` rather than committed). Then `--headless --import` in Godot so the
reimported `climb.png` is what the game actually loads, then
`run_tests.gd`.

Renders: `climb_full.png` (composited on the same brown card-face standin
`RGB(139,105,74)` prior batches used) and `climb_42px_big.png` (real 42px
`LANCZOS` downsample, nearest-neighbour upscaled for viewing) — both kept
locally, not committed, per the "commit `_sil.png`/`_34.png`, not every
view" convention (there's no dedicated silhouette render for a 2D icon
pass; the 42px composite serves that role here). Alpha bbox `(11, 34,
218, 245)`, comfortably inside the 256px canvas on all sides.

Sampled actual PNG pixels rather than eyeballing only: bottom step
RGB(106,109,118), middle step RGB(76,80,91) — both the same STONE
blue-grey, darkening slightly with distance from camera — top step
RGB(185,169,150) and peg RGB(203,189,174), both WHEAT and visibly lighter
than the STONE steps, so the top step and its peg read as one lit
"you are here" element rather than blending into the staircase body.

- **Family distinction (3 → 8):** side by side with `ascend` at full size
  and at the 42px downsample, the two no longer share an outer silhouette
  at all — `climb` is three offset rectangles ascending diagonally,
  `ascend` is a symmetric arrow-and-wings column. Not a 9 or 10: both are
  still built from the same STONE/WHEAT/GOLD palette family and the same
  bevelled-block vocabulary, which is correct (they're meant to read as
  related "up" cards) but keeps a very fast glance from separating them
  purely by colour alone.
- **Mechanic match (7 → 8):** literal ascending steps is a more specific
  "climb" read than a generic up-arrow, and now visibly differs from
  `ascend`'s shape rather than only its size. Not higher: the marker peg
  standing in for "the climber" is a small, non-obvious detail at 42px —
  confirmed in the actual 42px render, it survives as a small pale mark
  on the top step but a player would likely read "stairs going up" from
  the steps alone, with the peg reinforcing rather than doing that work
  itself.
- **Silhouette @ 42px (7, unchanged):** checked directly in the 42px
  downsample — the three-step diagonal stays legible as three discrete
  blocks rather than compressing into one shape, same as the arrow-on-post
  did before.
- **Colour & contrast (8, unchanged):** neither fix touched the palette;
  the WHEAT-on-STONE top-step lift and the STONE-on-brown-standin body
  both still separate cleanly.
- **Style consistency (8, unchanged):** same `slabf()` bevelled-plate
  construction as the rest of the set; nothing about the rebuild changes
  the construction style.

**+8 total (33 → 41), not a plateau — kept. Meets the loop's 40/50 stop
condition.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the marker peg reads as "a climber" to a player who has never
seen the build comment, or just as an unexplained bump on the top step —
the 42px render confirms it survives as a visible mark, not that it
carries that specific meaning on its own; the staircase shape is doing
the real identity work here.
