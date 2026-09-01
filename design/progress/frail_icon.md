# frail — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md`/`burn_icon.md` for the batch's full scope and the
shared rubric). **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/frail.png` (256x256,
rendered by `icons.py`, orthographic head-on). Last of batch 22's four; also
answers `design/ART-REVIEW.md`'s own standalone "one Frail icon" section. With
this batch, **all thirty-six total card icons are now scored**, and every
asset class this item's own text names (beasts, hunters, fight grounds,
portraits, icons) is complete except the overworld map, which batch 14
already reclassified `needs a screen` rather than cloud-scoreable.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established — Silhouette@42px / Family
distinction / Mechanic match / Colour & contrast / Style consistency. Same
method as the rest of this batch: composited over the flat brown card standin
RGB(139,105,74), downsampled to a real 42px with Pillow LANCZOS, alpha bbox
checked numerically: raw and >10-alpha threshold both give
`(23, 11, 239, 256)` — the bottom edge touches the canvas exactly (y=256),
the same "no margin" pattern named for several icons across batches 15-21,
here on the bottom rather than a side.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 4 | 6 | 8 | **32** |

## What is actually there

Two STEEL kite-shield shapes side by side, each with a rounded top and a
tapered point at the bottom (the same construction `shield()` itself uses),
separated by a jagged CHARCOAL crack running between them, with a small
SILVER chip broken free and drifting down-and-right, partly cropped by the
canvas bottom edge.

- **Silhouette @ 42px (7):** both shield-halves and the crack between them
  stay visible and distinct at the real downsample — this is not a smudge.
  Docked because the falling chip, the detail meant to sell "a piece has
  broken off," compresses to a few pixels at 42px and is easy to miss
  entirely against the standin at that size, even though it reads clearly
  at 256px.
- **Family distinction (7):** two side-by-side kite shapes read as a
  meaningfully different gestalt from the single-kite `shield`/`guard`/
  `plated_armour` or the brick-grid `wall` — "two of something" versus "one
  of something" is a real, legible difference in count and overall shape,
  not just colour, the same kind of distinction `cog_icon.md` credited for
  its two overlapping gears against the set's single-ring icons.
- **Mechanic match (4), the lowest line scored this batch and the
  specific question `ART-REVIEW.md`'s own note already names ("does
  `frail` read as broken/weakened rather than whole"):** it does not,
  cleanly. Each half independently still has a full rounded top and a full
  tapered point — the complete silhouette vocabulary of an intact shield —
  rather than reading as a fragment of one larger shape torn in two. At a
  glance, before the crack or the falling chip register, two complete
  shield outlines side by side risk reading as *more* protection, not
  less — the opposite of what Frail means. The crack and the drifting chip
  are the details doing the actual "broken" work, and both are the
  smallest, least prominent elements in the render.
- **Colour & contrast (6):** pixel-sampled directly. The two shield halves
  don't separate equally from the standin: the left half samples at
  roughly RGB(122,130,146) against RGB(139,105,74) — the red channel is
  actually *lower* than the standin's own red, leaning entirely on the
  green/blue shift (cool steel-blue vs warm brown) for contrast, a
  17/25/72-per-channel gap. The right half samples at roughly RGB(140,146,
  158) — its red channel, 140, is within one point of the standin's 139,
  the closest red-channel match measured for any icon under this item so
  far — separating almost entirely on hue rather than luminance. Both stay
  visible in practice because the hue shift (cool grey-blue vs warm brown)
  is doing real work even where the raw channel gap is thin, but this is a
  more fragile separation than most icons scored under this item carry.
- **Style consistency (8):** reuses `shield()`'s own tapered-kite
  construction and the family's established STEEL/SILVER palette on
  purpose — `ART-REVIEW.md`'s own build note says as much ("Frail IS about
  Block") — consistent with the vocabulary, not an outlier.

## Diagnosis — two lowest

1. **Mechanic match (4).** Concrete fix: break the *symmetry* of the two
   halves rather than keeping each a complete miniature shield — e.g. give
   only one half the rounded top and let the other end in a jagged broken
   edge instead of its own point, so at a glance the two pieces read as
   "one shield split unevenly" rather than "two small shields," and lean
   less on the crack and the small falling chip to carry the whole idea.
2. **Colour & contrast (6).** Concrete fix: darken or cool the right-hand
   half specifically — its near-zero red-channel separation from the
   standin is the weakest single measurement in this icon — so both halves
   separate from the card face with the same confidence the left half
   already has.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The exact question `ART-REVIEW.md`'s own note already raises and this pass
cannot close: whether "broken shield" reads as *Frail specifically* versus
just "something bad happened to my Block" in general, without the keyword
tooltip open — a card-hand read this static comparison can't settle. Also
unsure whether the falling chip survives being cropped by the canvas bottom
edge once it sits next to a card's real cost pip and rules text, which
`ART-REVIEW.md`'s own note flags too and which needs the actual card layout,
not this flat render, to check — a `needs a screen` question.

## Batch 22 close-out — all thirty-six card icons scored

With `burn`, `stack`, `light` and `frail`, every icon named across
`design/ART-REVIEW.md`'s icon sections (the twenty-eight-icon block, the four
defensive-keyword icons, Strength/Dexterity, and the standalone Frail and
Light sections) has a scored `design/progress/<name>_icon.md`. Combined with
batches 1-13 (all fourteen beasts, all fourteen fight grounds, all nineteen
portraits), every asset this item's own text names as cloud-scoreable is now
scored, except the overworld map — reclassified `needs a screen` in batch 14
(no single flattened map image exists to score; it is many hex-tile `.glb`
models assembled at runtime, and `ART-REVIEW.md`'s own preview instructions
call for `screenshot.gd`, unavailable in this environment). This item's own
"Done when" line ("every asset that has a model has a scored
`design/progress/<asset>.md`") is met for every model- or image-backed asset;
the map is the sole named exception, filed under a different tag rather than
silently dropped. Left unchecked regardless, per this item's own rule — a
`cloud-safe` scoring item is never ticked by the routine, only by Nick
looking at the ranked list below.
