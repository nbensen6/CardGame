# yoke_ox — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/yoke_ox.png`
(512x512). Batch 13 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 4 | 5 | 3 | 6 | 5 | **23** |

Lowest portrait scored under this item so far, below `clot_toad_portrait`'s
24.

## What is actually there

Alpha bounding box `(0, 19, 512, 512)` — touches the left, right, and bottom
edges of the canvas at once, with clearance concentrated almost entirely at
the top. A tight crop centred on the crossing tan-wood yoke bar and horns
over the shoulders, the yellow-ringed sigil set into the bar, a wedge snout
with one dark nostril dot at bottom-left, and black legs at the bottom edge.

- **Framing (4):** three of four canvas edges are touched at once (legs and
  horn/yoke ends cut off left, right, and bottom), tighter than
  `husk_beetle_portrait`'s single-edge touch and close to
  `silk_widow_portrait`'s all-four-edges crop this same batch.
- **Identity (5):** the crossing tan-wood shapes dominate the frame and read
  as a busy brown-on-brown jumble rather than legibly "a yoke across an ox's
  shoulders"; the snout with its nostril dot is present but pushed to the
  bottom-left corner, small in frame. This crop centres exactly on the
  region `yoke_ox.md`'s own 3D pass already flagged — "the yoke bar merges
  into the horn shapes into one triangular lump" — making that merge the
  whole picture rather than one detail among several.
- **Readability @ 34px (3):** confirmed via a real 34px downsample — the
  yellow sigil sits close enough in value to the surrounding TAN wood that
  it nearly disappears into the wood grain, and the crossing wood pieces
  read as indistinct light streaks across a brown mass rather than any
  identifiable shape. Lowest Read@34 score recorded under this item so far.
- **Colour & separation (6):** the black legs read cleanly against the
  RUST/brown body where visible, matching `yoke_ox.md`'s own "nothing
  dark-on-dark" 3D finding — but the TAN yoke bar and YELLOW sigil sit close
  enough in hue to blend at both full size and 34px, a colour-separation
  problem the wider 3D render, viewed from further back, did not surface
  (its own Colour & read line scored 7).
- **Style consistency (5):** framing this tightly on the crossing wood
  shapes departs from the head-and-shoulders convention the stronger-scoring
  portraits hold to, the third framing outlier named this batch alongside
  `thrasher_portrait` and `silk_widow_portrait`.

## Diagnosis — two lowest

1. **Readability @ 34px (3).** Concrete fix: give the sigil ring a lighter
   or higher-contrast swatch against the TAN wood (e.g. the model's own
   GOLD rather than YELLOW-on-TAN) so it survives downsampling; this is a
   colour problem the portrait crop alone cannot fix.
2. **Framing (4).** Concrete fix: pull `portraits.py`'s `FOCUS` back and
   recentre slightly downward so the snout and nostril get more frame share
   relative to the wood-and-horn tangle, and so legs/horn-ends stop being
   cut at three edges at once.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the yellow-sigil-on-tan-wood value clash is a portrait-crop framing
problem or a genuine model/material choice that would look the same at any
crop — this pass can see the values sit close, not which swatch was
intended to read as "the marking" versus "the wood."
