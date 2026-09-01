# light — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md`/`burn_icon.md` for the batch's full scope and the
shared rubric). **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/light.png` (256x256,
rendered by `icons.py`, orthographic head-on). Third of batch 22's four; also
answers `design/ART-REVIEW.md`'s own standalone "one Light icon" section.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established — Silhouette@42px / Family
distinction / Mechanic match / Colour & contrast / Style consistency. Same
method as `burn_icon.md`/`stack_icon.md`: composited over the flat brown card
standin RGB(139,105,74), downsampled to a real 42px with Pillow LANCZOS,
alpha bbox checked numerically (raw and >10-alpha threshold: `(11,11,245,245)`
/ `(12,12,244,244)` — margin on all four sides, doesn't touch the canvas
edge, unlike several icons scored in earlier batches).

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 9 | 7 | 8 | **41** |

## What is actually there

A CREAM core ball at centre with eight straight tapered rays radiating out —
four long GOLD rays on the cardinals, four shorter AMBER rays on the
diagonals — a clean eight-point starburst.

- **Silhouette @ 42px (8):** the burst shape survives the downsample well —
  a distinct radiating star, symmetric, with comfortable margin on all four
  sides (confirmed by the alpha bbox above, no edge-touching). Docked one
  step because the length difference between the four long and four short
  rays — the detail `ART-REVIEW.md`'s own note flags as an open question —
  is visibly there at 256px but nearly disappears at the real 42px
  downsample: all eight rays read as close to the same length once
  shrunk, so the intended long/short rhythm doesn't survive.
- **Family distinction (9):** answers `ART-REVIEW.md`'s own named worry
  directly. `light`'s straight tapered rays are clearly distinct from
  `fire`'s curved flame tongues (confirmed against `fire.png` at the same
  scale) and from `expose`/`target`'s concentric-ring-plus-ticks
  construction (rings, not radiating spikes) — no confusion with either
  neighbour by shape alone. Docked one step only because an eight-point
  radiating burst is a fairly generic "magic/energy" shape family in games
  broadly, even though nothing else in *this* set shares it.
- **Mechanic match (9):** "generate Light" — a radiant burst is about as
  direct and unambiguous a symbol for light as exists; no keyword knowledge
  needed to read it as "light" or "energy" rather than damage or defense.
- **Colour & contrast (7):** pixel-sampled directly. The CREAM core samples
  at roughly RGB(198,191,182) against the standin RGB(139,105,74) — a strong
  +59/+86/+108 gap, cool pale grey against warm brown. The AMBER diagonal
  rays separate well too, roughly RGB(196,147,93), a +57/+42/+19 gap. The
  four long GOLD cardinal rays are the weak point: roughly RGB(179-181,
  140-142, 66-70) against the same standin — the red and green channels
  separate reasonably (+40/+35) but the blue channel is actually *lower*
  than the standin's own blue (66-70 vs 74), so the long rays lean on hue
  difference (warm yellow-gold vs muddy brown) rather than a strong overall
  channel gap the way the core and the short rays do.
- **Style consistency (8):** the ball-plus-radiating-spikes construction
  reuses the same primitives `thorns` established and explicitly credits in
  its own build comment; nothing about the render angle is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (7).** Concrete fix: shift the four long GOLD
   cardinal rays toward a brighter or cooler tone — the same direction
   `cog_icon.md` and `timer_icon.md` already proposed for their own
   warm-on-warm elements — so all eight rays separate from the card standin
   as confidently as the core and the short AMBER rays already do.
2. **Silhouette @ 42px (8).** Concrete fix: exaggerate the length
   difference between the long and short rays further (or thicken only the
   short rays) so the alternating rhythm survives the downsample rather
   than compressing into eight near-identical spikes.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the long/short ray alternation is meant to be a legible feature at
card-hand viewing distance at all, or whether it exists mainly for the
256px source render and "eight spikes" is an acceptable simplification once
it's small — `ART-REVIEW.md`'s own note already flags this exact question
as open. Also unsure whether an eight-point burst reads as confusable with
`expose`'s ring-plus-four-ticks from across a real hand of cards the way
`ART-REVIEW.md` asks, since the two are compared here only as isolated
42px renders side by side, not laid out in an actual hand — a `needs a
screen` question this pass can't settle.
