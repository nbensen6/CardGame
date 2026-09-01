# guard — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 15 — rubric and method as `design/progress/shield_icon.md` (this
batch's reference file), not repeated here. Asset:
`game/assets/icons/guard.png` (256x256). Second of the "not dying" family
(`shield`, `guard`, `wall`, `support`) — the specific icon
`design/ART-REVIEW.md` names as the closest pair to `shield`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 3 | 7 | 7 | **28** |

## What is actually there

A pale grey-white kite/pennant shape — same flat-top, rounded-shoulder,
tapering-point outline as `shield` — with a plain grey "L" glyph centred on
the body. Alpha bbox `(60, 38, 196, 242)`: comfortable margin, no clipping.

- **Silhouette @ 42px (8):** the kite outline and the "L" both stay legible
  through the downsample, same as `shield`.
- **Family distinction (3):** the mirror of `shield`'s finding — this is the
  one pair `ART-REVIEW.md` itself flagged as unsure, and looking at it
  directly confirms the worry rather than clearing it. Outer silhouette is
  effectively identical to `shield`'s at 42px.
- **Mechanic match (3), the weak point of this batch:** `design/ART-REVIEW.md`
  describes the intended build as "a shield with a clock face" — a clock
  face would visually carry "timed" the way `timer`'s icon already does
  elsewhere in the set. What actually renders is a plain block letter "L,"
  which reads as neither a clock nor as timing of any kind on its own; a
  player would need the tooltip to connect it to "block, but timed" at all.
  This is a build-vs-intent gap, not just a legibility problem — even at full
  256px the L reads as a letter, not a clock hand.
- **Colour & contrast (7):** the pale body reads clearly against the brown
  standin — if anything the lightest of the four in this batch, closer to
  `wall`'s neutral tone than `shield`'s more saturated blue. The grey "L" has
  adequate but not strong contrast against the pale body (both are cool
  greys, closer in value than `shield`'s white-on-blue cross).
- **Style consistency (7):** matches the shared bevel/shadow construction;
  docked slightly below `shield` because the near-white body value sits
  further from the rest of the set's generally mid-toned palette.

## Diagnosis — two lowest

1. **Mechanic match (3).** Concrete fix: rebuild the internal mark as the
   clock face the design intent already names — a circle with two short
   hands set at an off-angle (not 12:00, which reads as a plus/cross again)
   — rather than a letter glyph unrelated to timing.
2. **Family distinction (3).** Same fix named in `shield_icon.md`: change an
   outer-silhouette element, not just the internal mark or shade, so
   `shield` and `guard` separate by shape alone.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the "L" was ever meant to evoke a clock hand at a specific hour
(an L-shaped pair of hands, like 9:15) and reads that way to someone who
already knows the intent — cold, with no such context, it read as a letter
in every view checked here, but that prior-knowledge case wasn't testable
from a static image alone.
