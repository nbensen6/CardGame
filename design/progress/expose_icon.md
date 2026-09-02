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

## Pass 2 — #86 duty 1 (repair)

Item 86's asset lane repairs directly now (icons vs. beasts/grounds/hunters
tier split — see `shield_icon.md` pass 2 for the full rationale). Both named
lines shared one root cause per the pass-1 diagnosis, so one geometry change
addresses both: the round BRICK ball at centre is replaced with an angular
two-taper shard (the same opposed-spike construction `relic()` uses for its
gem), and the four symmetric AMBER axis ticks are replaced with three BRICK
crack-lines at uneven angles and lengths radiating from centre through the
rings. `target` keeps its round ball and single diagonal accent untouched —
only `expose` changed.

Applied both named lines, in-lane (`tools/blender/icons.py` only, no palette
edit, no budget or constant moved):

1. **Family distinction (3).** `i.ball((0.0, -0.06, 0.0), (0.09, 0.06, 0.09),
   BRICK, 7, 4)` replaced with two opposed `spike()` calls (`(0.0, 0.02, 0.11,
   0.02, 0.20, BRICK, seg=5)` and the same mirrored with `ang=math.pi`),
   forming a small angular rhombus rather than a round ball — the first
   silhouette element that genuinely differs from `target`'s smooth ball
   rather than only differing in an internal detail. The four axis ticks
   (`slabf` at `±0.56` on each axis) are replaced with three `spike()` crack
   lines centred at the origin at uneven angles (`0.35`, `2.05`, `-1.15`
   radians) and uneven lengths (`1.10`, `1.04`, `1.00`), so the corona is
   asymmetric rather than a symmetric crosshair.
2. **Mechanic match (6).** Same geometry change — an angular shard plus
   asymmetric crack-lines reads as a fracture/weak-point, where the old round
   ball plus four evenly-spaced ticks read as a generic aim reticle, the same
   genre `target`'s own diagonal-arrow-on-a-ring is already in.

Rebuilt with `blender --background --python tools/blender/icons.py --
/tmp/icon_build` (the same invocation `build.cmd icons` makes). Diffed every
PNG in the batch's own output against the currently committed set with
Pillow/numpy (mean/max abs channel difference per file) to separate a real
change from this Blender build's known render noise (per `fire_icon.md` pass
3 and `rally_icon.md`'s own precedent) — 29 other icons came back with mean
diffs of 0.08-11.2 (max ≤126), the same noise band those prior passes
measured, while `expose.png` came back at mean 14.77 (max 255), clearly
outside it. Kept only `expose.png`; the other 35 committed files are
untouched (confirmed byte-identical, not just visually).

Rendered three ways over the flat brown card-face standin `RGB(139,105,74)`,
same method as `shield_icon.md`/`rally_icon.md`: the full 256px composite
(`design/renders/expose_pass2_full.png`), a real 42px Lanczos downsample
nearest-neighbour upscaled for viewing
(`design/renders/expose_pass2_42px_big.png`), a black-on-white alpha
silhouette (`design/renders/expose_pass2_sil.png`), and a side-by-side 42px
strip against `target` rendered and downsampled the same way
(`design/renders/expose_pass2_vs_target_42px.png`) to check the family line
directly rather than by memory.

Alpha bbox `(19, 10, 237, 245)`: comfortable margin on all four sides, no
clipping — an improvement over pass 1's ticks touching all four edges,
though that wasn't one of the two named lines. Sampled actual alpha values
radially from centre along +X to confirm the ring structure reads as three
genuinely separate solid bands (shard, inner ring, outer ring) with real
transparent gaps between them, not a solid disc — the low-resolution preview
render is hard to read by eye at this size, so this was checked numerically
rather than assumed.

- **Family distinction (3 → 7):** the side-by-side 42px strip shows `expose`
  as an asymmetric red crack-star with three uneven flecks past the ring,
  and `target` as a clean double ring with one smooth diagonal silver arrow
  and a round ball — no longer the same recipe with only a colour/detail
  swap, confirmed in the actual downsampled render. Not higher: both are
  still fundamentally a double-ring-plus-centre-mark composition, which the
  rubric doesn't fully forgive even when the marks themselves are unrelated
  shapes.
- **Mechanic match (6 → 8):** the shard-and-crack read as "this point is
  breaking" more specifically than a round ball with a plus/cross ever did,
  and no longer borrows the "aim here" reticle language `target`'s own
  diagonal-arrow-on-a-ring already owns. Not a 10: a card reader who has
  never been told the intent could still read it as generic damage/impact
  rather than "weak point" specifically — a real ceiling for a 42px icon
  with no text.
- **Silhouette @ 42px (8, unchanged):** confirmed in the real downsample —
  the shard and all three crack-lines survive as distinct shapes rather
  than blurring into the rings; the swap didn't cost the line that was
  already strong.
- **Colour & contrast (7, unchanged):** neither fix touched colour — the
  shard and crack-lines kept the original BRICK, same as the ball and ticks
  they replaced.
- **Style consistency (8, unchanged):** the two-taper shard reuses `relic()`'s
  own gem construction and the crack-lines reuse the `spike()` vocabulary
  every other icon in the set already draws from; nothing about the render
  angle or palette is an outlier.

**+8 total (32 → 40), not a plateau — kept. Meets the loop's 40/50 stop
line.** No line regressed. `run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the shard reads clearly as "angular/fractured" rather than just "a
smaller, darker ball" at true hand-card size (well under the 42px downsample
checked here) — confirmed distinct from a round ball at 42px, but a still
smaller real hand size wasn't checked. Also unsure whether the asymmetric
crack-line angles read as deliberate (a fracture radiating unevenly) or as
slightly broken/off-balance to a first-time viewer who has no `target` to
compare against directly — the side-by-side comparison here made the
distinction obvious, but a player sees `expose` alone in a hand, not next to
`target`. This is still `cloud-art`, still needs a human look — a repaired
score is not Nick's judgement on a real card face in a real hand.
