# stack — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md`/`burn_icon.md` for the batch's full scope and the
shared rubric). **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/stack.png` (256x256,
rendered by `icons.py`, orthographic head-on). Second of batch 22's four.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established — Silhouette@42px / Family
distinction / Mechanic match / Colour & contrast / Style consistency. Same
method as `burn_icon.md`: composited over the flat brown card standin
RGB(139,105,74), downsampled to a real 42px with Pillow LANCZOS, alpha bbox
checked numerically.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 5 | 8 | 6 | 8 | **35** |

## What is actually there

Three overlapping card slabs fanned out — a WHEAT card angled left, a taller
CREAM card centred and upright, a WHEAT card angled right — with a TAN bar
laid horizontally across the top, resting on the centre card.

- **Silhouette @ 42px (8):** the fanned-card gesture survives the downsample
  clearly — three distinct rectangular shapes overlapping at the base, the
  centre one tallest — the single strongest read of this batch's four.
  Docked one step only because the seams between the three cards soften at
  real 42px into two darker creases rather than three fully separate edges.
- **Family distinction (5), the same line and the same finding as
  `burn_icon.md`'s:** `stack` is the third icon in the set built from
  overlapping pale rectangular card slabs, alongside `draw` (two cards plus
  an arrow) and this batch's own `burn` (one card plus flame). At a real
  42px downsample, count is the only thing separating the three at a glance
  — two cards read as `draw`, three as `stack`, one as `burn` — which is a
  real distinction but a fragile one to rely on across a fast hand-read
  compared to a difference in shape.
- **Mechanic match (8):** "draw / hand size" is served about as directly as
  any icon scored under this item — a fan of cards *is* a hand of cards,
  no metaphor required. The strongest Mechanic-match score of this batch's
  four.
- **Colour & contrast (6):** pixel-sampled directly. The three card faces
  separate strongly from the standin — roughly RGB(186-195, 173-184,
  156-172) against RGB(139,105,74), a consistent +45-to-+95-per-channel
  gap. The TAN top bar is the weak point: roughly RGB(166,121,91) against
  the same standin, only a 27/16/17-per-channel gap — the closest-to-the-
  standin element in this icon, similar in kind to `cog_icon.md`'s CLAY
  gear and `timer_icon.md`'s AMBER cap, both flagged as the same
  warm-on-warm near-miss.
- **Style consistency (8):** the overlapping-slab construction is shared
  with `draw` and `burn` by design (per `icons.py`'s own comments on the
  card-icon family) and reads as deliberate craft, not an accident.

## Diagnosis — two lowest

1. **Family distinction (5).** Concrete fix: same direction as
   `burn_icon.md` proposes for its own card — differentiate `stack` from
   `draw` by more than card count, e.g. a visibly different fan angle or an
   accent shape (the existing TAN bar could become a distinct hand-shaped
   silhouette rather than a plain rectangle) so the three card-family icons
   separate on shape as well as count.
2. **Colour & contrast (6).** Concrete fix: shift the top bar toward a
   cooler or more saturated tone — away from TAN and toward something in
   the CREAM/WHEAT family the cards already use successfully, or toward a
   contrasting accent colour entirely — so it doesn't sit as close to the
   brown card face as it currently does.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the TAN top bar is meant to read as a card-back (the deck this hand
was drawn from) or as a generic accent/header — if the former, its weaker
colour separation from the standin might actually be intentional restraint
(a deck shouldn't outshine the hand), which would make the Colour score
above too harsh. Same open question as `burn_icon.md`'s: whether the
family-distinction concern actually costs anything once `draw`, `stack` and
`burn` are seen together in a real hand rather than compared as isolated
42px renders — a `needs a screen` question.
