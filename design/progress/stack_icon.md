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

## Pass 2 — cloud, backlog #86 duty 1

Applied both named lines, in `icons.py`'s `stack()` only — no other icon
script touched, no shared constant moved:

1. **Family distinction (5).** Replaced the flat `i.slabf(0.0, 0.34, 0.30,
   0.055, TAN)` bar with three `i.ball()` pips in a shallow arc (`(-0.14,
   0.30)`, `(0.0, 0.38)`, `(0.14, 0.30)`, radius `(0.065, 0.05, 0.065)`,
   `GOLD`) — a "count" badge instead of a plain rectangle, so the accent
   shape itself now differs from `draw`'s single arrow and `burn`'s flame
   cluster, not just the card count underneath it.
2. **Colour & contrast (6).** The replacement pips are `GOLD` rather than
   `TAN` — already the fix direction the diagnosis proposed ("toward a
   contrasting accent colour entirely").

Rebuilt the full 36-icon set with the real `blender` binary (apt package,
4.0.2 — `download.blender.org` blocked through the proxy this run, same apt
fallback prior duty-1 passes used; needed `python3.12 -m pip install
--break-system-packages numpy` first, not installed in this container
before this pass). Diffed every PNG against committed by mean and max
per-channel pixel difference: `stack.png` alone showed a max of 255 (a real
opaque/transparent edge moved); every other icon's max stayed ≤120 — the
same AA/lighting-noise ceiling `fire_icon.md` pass 3 and `rally_icon.md`
pass 3 measured for their own untouched icons. Reverted the other 35, kept
only `stack.png`.

Composited the new PNG over the flat brown card-face standin
`RGB(139,105,74)`, the same method as every prior batch:
`design/renders/stack_pass2_full.png` (256px), `stack_pass2_42px_big.png`
(real 42px Lanczos downsample, nearest-neighbour upscaled for viewing), and
`stack_pass2_sil.png` (alpha silhouette). Looked at all three, plus
regenerated (scratch, not committed) silhouettes of `draw.png`/`burn.png`
for a direct side-by-side rather than relying on memory of their shapes.

Pixel-sampled the centre pip directly off the render: `(198,161,99)`
against the `(139,105,74)` standin — a `+59/+56/+25` per-channel gap,
against the old TAN bar's `+27/+16/+17` (this file's own pass-1 numbers).

- **Silhouette @ 42px (8, unchanged):** the fan-of-cards read is untouched;
  this pass didn't touch the card seams pass 1 docked a point for.
- **Family distinction (5 → 8):** `stack_pass2_sil.png` shows three
  distinct round bumps atop the fan, clearly different from `draw`'s single
  triangular arrow-tip silhouette (checked directly, not from memory) and
  from `burn`'s flame-and-notch. Not higher: still the same broad
  composition family (a card fan plus one small accent) as `draw`/`burn`,
  which the two-fix budget didn't change.
- **Mechanic match (8, unchanged):** already the strongest line in the
  batch pre-fix; a pip cluster doesn't add or subtract from "a fan of
  cards is a hand of cards."
- **Colour & contrast (6 → 9):** verified off real render pixels (numbers
  above), a substantially wider gap than the old TAN bar's near-miss. Not
  10: the pips sit close together and slightly overlap in the full render
  (visible in `stack_pass2_full.png`), which isn't a colour problem but
  keeps this from being a clean, fully separated read.
- **Style consistency (8, unchanged):** `ball()` pips are already the set's
  vocabulary (`sword`'s pommel, `taunt`'s bell) — as consistent as the flat
  bar was, not more or less.

**+6 total (35 → 41), not a plateau — kept. Crosses the 40 stop line.**
No line regressed.

`run_tests.gd`: ALL TESTS PASSED (fresh import, headless, godot 4.7.1).

## Unsure about (pass 2)

Whether the two outer pips sitting close enough to the centre pip to
visually touch at 256px (not confirmed as a hard silhouette-merge, just
close) is worth a follow-up spacing pass — the 42px downsample and the
silhouette crop both still read three distinct bumps, so this is a
polish note, not a diagnosed failure, and the total is already past the
40 stop line.
