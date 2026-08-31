# lightbearer — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/lightbearer.png`
(512x512). Batch 9 of #83; rubric defined in full in `frog_portrait.md`
(Framing / Identity / Readability @34px / Colour & separation / Style
consistency, 1–10 each).

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 7 | 6 | 7 | 8 | **34** |

## What is actually there

Three-quarter crop of the whole upper figure: a tall conical hood, a dark
jagged band across the face with amber dots (eyes), an amber orb set in the
chest, and a raised staff topped with a lantern, held in the left hand. A
second small amber shape sits in the right hand.

- **Framing (6):** the lantern at the top of the staff sits very close to
  the frame's top edge (little headroom above it), while there is real
  unused space on the right side of the frame the figure doesn't use —
  crop feels staff-heavy and off-balance rather than centred on the figure.
- **Identity (7):** the staff-and-lantern plus the dark visor band are this
  character's signature and both read, but backlog #75/batch-4's own
  write-up flagged a "second light" orb near the hand with no connecting
  geometry, reading as a stray floating ball — from this single three-
  quarter angle the amber shape in the right hand looks plausibly attached
  to the fingers, but a portrait alone can't confirm or clear that earlier
  finding; carried forward as unresolved, not re-verified here.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  lantern's own structure (its frame bars) is lost, collapsing to a soft
  amber blob at the top of a thin line; the staff shaft itself thins to a
  near-invisible single-pixel diagonal. The dark visor band against the tan
  hood is the strongest surviving read at this size.
- **Colour & separation (7):** dark visor against pale tan robe separates
  well, amber accents (chest orb, hand, lantern) pop against the same tan;
  no dark-on-dark.
- **Style consistency (8):** matches the shared three-quarter, transparent-
  background convention.

## Diagnosis — two lowest

1. **Framing (6).** Concrete fix: shift the `FOCUS` crop for `lightbearer`
   left and down a little (from the current `(0.69, 0.78)`) so the empty
   space currently on the right of frame moves to a smaller margin on the
   left, centring the figure+staff group rather than the figure alone.
2. **Readability @ 34px (6).** Concrete fix: none obvious that doesn't touch
   the model itself (a bulkier lantern head would read better small, but that
   is a body-script change, out of scope for a scoring-only item).

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the right-hand amber shape is the "second light" orb ART-REVIEW
already flagged as floating with no connecting geometry, or a separate,
correctly-attached detail — this single portrait angle can't settle it; the
original finding was made looking at the full model, not this crop.
