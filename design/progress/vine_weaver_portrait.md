# vine_weaver — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/vine_weaver.png`
(512x512). Batch 9 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 8 | 7 | 8 | **38** |

## What is actually there

Three-quarter crop centred on a tree-being's canopy and upper trunk: a green
foliage mass on top, a brown trunk body below it with two amber eye-dots and
a thin black mouth slot, and four brown branch-arms ending in small green
foliage "hands" at the frame's edges. A small purple bead is visible, mostly
cut off, at the very bottom edge of frame.

- **Framing (6):** the canopy nearly touches the top edge of frame (almost
  no headroom), and the small purple bead at the bottom is cropped enough
  that it reads as an unidentifiable colour fragment rather than a shape —
  likely the sigil crest gem the 3D scoring pass (batch 4 of this item)
  already flagged as "visibly clear of the vine mass"; the portrait crop
  makes that worse by showing only a sliver of it.
- **Identity (9):** the canopy-over-trunk-with-branch-hands read is
  immediate and distinctive — the strongest, most identity-clear silhouette
  concept in this batch, no ambiguity with any other cast member.
- **Readability @ 34px (8):** confirmed via a real 34px downsample. The
  canopy/trunk colour block stays clearly separated and the tree shape
  reads fine; the face (eye-dots, mouth slot) blurs away entirely at this
  size, but the character's identity carries through the tree silhouette
  itself rather than the face, so the loss costs little.
- **Colour & separation (7):** green canopy against brown trunk separates
  cleanly; the small red mark on the canopy (visible at full size, a bud or
  leaf detail) reads as an unexplained red dot rather than anything
  specific, at both full size and 34px.
- **Style consistency (8):** matches the shared convention.

## Diagnosis — two lowest

1. **Framing (6).** Concrete fix: drop the `FOCUS` centre fraction for
   `vine_weaver` slightly (from the current `(0.77, 0.67)`) to open a little
   headroom above the canopy, and either crop the purple bead out entirely
   or open the frame enough to show it whole — a fragment reads worse than
   either extreme.
2. **Colour & separation (7).** Concrete fix: none identified that doesn't
   touch the model itself — the red canopy mark is a modelling/colour
   choice, out of scope for a scoring-only item; named here as a question
   for Nick (is it meant to read as something specific?) rather than a
   proposed pixel fix.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

What the small red mark on the canopy is meant to represent — a bud, an
eye, damage — it doesn't read as any of those specifically in this portrait.
