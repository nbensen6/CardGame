# expose — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
20 — the next four of the sixteen "twenty-eight card icons" left unscored
after batch 19, in `card_view.gd`'s own `ICONS` table order (`expose`,
`taunt`, `relic`, `volley`). **Scoring pass only — report, not repair; no
edits to `tools/blender/icons.py`.** Asset: `game/assets/icons/expose.png`
(256x256, rendered by `icons.py`, orthographic head-on per
`design/ART-REVIEW.md`'s own build note). First of batch 20's four (see
`taunt_icon.md`, `relic_icon.md`, `volley_icon.md` for the rest).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method: Pillow real
42x42 `LANCZOS` downsample composited over the flat brown card standin
`RGB(139,105,74)`, plus a numeric alpha-bbox check at both any-alpha and
alpha>10 thresholds (batch 17's addition, carried forward).

`target` (`game/assets/icons/target.png`) was rendered and downsampled the
same way alongside this icon purely for the Family-distinction line, since
it is the one existing icon that shares `expose`'s construction — it is not
itself scored here; `target` is one of the twelve icons still unscored
after this batch.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 6 | 7 | 8 | **32** |

## What is actually there

Two concentric rings (AMBER outer, GOLD inner) around a small BRICK-red
ball at the centre, with four short AMBER tick marks poking straight out
past the outer ring at the top, bottom, left and right — a crosshair-style
bullseye.

- **Silhouette @ 42px (8):** the double ring and centre dot stay a clean,
  solid bullseye shape at the real downsample; the four ticks survive as
  small but distinct spurs rather than blurring into the ring.
- **Family distinction (3):** checked directly against `target`
  (`design/progress/expose_icon.md`'s own render, not yet scored) at the
  same 42px scale — the two are built from the same double-ring-plus-
  centre-ball recipe and are near-identical in silhouette. `target` adds
  one diagonal SILVER line-and-arrowhead that `expose` lacks; `expose`
  substitutes four axis-aligned ticks for that diagonal. At 42px the
  diagonal line is the only reliable tell between them — this is the
  closest pair found under this item so far, closer than `shield`/`guard`
  (Family 3/10, batch 15) since that pair at least differs in fill colour
  as well as one small mark.
- **Mechanic match (6):** a bullseye reads as "aim here," a reasonable
  fit for "mark a weak point." The problem is which *other* card it's a
  reasonable fit for: `target` ("scales off Exposed") is mechanically the
  natural pair to `expose` — one applies the mark, the other reads it —
  and wearing near-identical art for both readable-together cards risks
  a player conflating "I'm about to Expose it" with "I'm about to punish
  the Expose that's already there."
- **Colour & contrast (7):** pixel-sampled along a line from centre to
  edge: the outer ring runs roughly RGB(206,166,128) against the standin
  RGB(139,105,74) — real luminance separation (a gap of roughly 55-90 per
  channel), confirmed rather than assumed.
- **Style consistency (8):** the ring-plus-centre-ball construction matches
  `buffer`'s hex ring and `guard`'s ring-over-slab; nothing about the
  render angle or palette is an outlier.

## Diagnosis — two lowest

1. **Family distinction (3).** Concrete fix: since `expose` and `target`
   are the two Expose-family cards read together most often, give `expose`
   a shape element `target` doesn't share at all (the ticks are the
   closest attempt already there, but a diagonal ring split or a distinct
   inner-ball shape would separate the *silhouette*, not just a detail
   inside it) rather than differing only by which small mark sits at the
   edge.
2. **Mechanic match (6).** Concrete fix: none proposed beyond the family
   fix above — the two findings share one root cause.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the four ticks touching all four canvas edges (alpha bbox
`(0,0,256,256)`, confirmed numerically — 14px of edge-touching content on
each side, not a full-edge fill) reads as a problem in-game the way the
"no margin" pattern already named for six other icons across batches
15-17 does, since here the ticks touching the edge is arguably part of the
crosshair's own design intent (reaching toward the frame) rather than an
accidental clip — flagged as the same pattern, not scored as a defect on
its own line.
