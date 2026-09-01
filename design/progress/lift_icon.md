# lift — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
17 — continuing the icon rubric batches 14-16 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/lift.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Third of batch 17's
four, and the fifth of the **"six are about going up" family**
(`climb`, `ascend`, `peak`, `rope`, `lift`, `rally`) batch 16 left open —
`rally` (this batch's other family member) is scored alongside it in
`design/progress/rally_icon.md`.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up 8x to view, composited over the same flat brown
card-face standin batches 14-16 used, `RGB(139,105,74)`). Alpha channel
bounding box checked directly (`Image.getbbox()`, plus a >10 threshold pass
to separate "touches the edge" from "clipped there") rather than guessing at
cropping. All six family members rendered and downsampled together in one
strip for a true side-by-side comparison.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 7 | 6 | 8 | **38** |

## What is actually there

Two rounded humanoid blob figures (a ball head on a tapered body, the same
construction `support`'s hand and other cast pieces use), one lower-left and
one upper-right, joined by a thin tan diagonal bar (the "grip" the build
comment names), with a gold up-arrow rising between them. Alpha bbox
`(36, 0, 219, 252)`: the arrow tip sits flush against the top row (row 0 is
fully opaque) — clipped there, no margin above it, though it doesn't read as
an obvious crop at either 256px or 42px.

- **Silhouette @ 42px (8):** the two-figures-plus-arrow composition survives
  the downsample cleanly — two round heads, two body masses, a connecting
  diagonal, and a triangle pointing up are all still separable shapes, not a
  blur.
- **Family distinction (9):** the strongest line in this batch. Next to
  `climb`/`ascend`/`peak` (all a single triangle-on-a-mass silhouette) and
  `rope` (a coil), `lift`'s two-figure composition is unmistakably a
  different shape at a glance — exactly what the build comment says it was
  built to avoid confusing with `support`'s hand and `rope`'s coil, and it
  succeeds at both.
- **Mechanic match (7):** "haul the ally to you" reads as "two people, one
  above the other, connected, going up" reasonably well, but the two figures
  are drawn identically in size and pose — nothing distinguishes "the one
  being hauled" from "the one hauling," so the specific verb (a rescue/pull)
  is weaker than the general concept (togetherness plus up).
- **Colour & contrast (6):** the two figures are built from GREEN and MINT
  per the source (`icons.py:256`) to read as two different people, but at
  both 256px and the 42px downsample they read as the same green — the hue
  gap between the two greens is too small to survive the shading gradient
  each figure already carries. Both greens also sit in the same colour
  family as `support`'s hand (a different green), so a hand of cards mixing
  `lift` and `support` would show two green-ish icons rather than two
  clearly different ones.
- **Style consistency (8):** same bevelled-blob construction as the rest of
  the set; nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (6).** Concrete fix: push GREEN and MINT further
   apart in hue or value (not just the current near-identical greens), or
   give one figure a warm colour (tan/gold, matching the grip and arrow)
   instead of two greens, so "hauler" and "hauled" separate by colour as
   well as position.
2. **Mechanic match (7).** Concrete fix: differentiate the two figures'
   pose — the lower-left one reaching/straining, the upper-right one
   already part-way up — rather than two identical blobs at different
   coordinates, so the "pull" reads as an action rather than a static
   diagram.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the arrow tip's flush top-edge clipping (alpha bbox top row fully
opaque, no margin) is visible as a hard crop once this icon sits inside the
game's own icon frame at 30x30 (`card_view.gd`'s rail icon size) rather than
this scoring script's flat 256px canvas — this is the same "flush against
the canvas edge" pattern batch 15 found on `wall` and this batch's own
`rally`/`strength`/`dexterity` also show, now five icons deep, and worth a
shared look if Nick wants one fix rather than four.
