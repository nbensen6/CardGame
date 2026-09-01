# burn — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md` for batch 21's full scope and the shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/burn.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). First of
batch 22's four — the last batch of the "twenty-eight card icons" block; with
this batch, all thirty-six total card icons are scored.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`
and `cog_icon.md`: composited over a flat brown card standin RGB(139,105,74),
downsampled to a real 42px with Pillow LANCZOS, alpha bbox checked
numerically at both a raw and a >10-alpha threshold.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 5 | 6 | 7 | 8 | **33** |

## What is actually there

A single tilted LINEN card slab with a CHARCOAL title-bar band across its
upper third, and behind it two small triangular ORANGE/BRICK cones of
uneven height, poking out from the card's right edge.

- **Silhouette @ 42px (7):** the card shape itself — rounded rectangle, dark
  band, slight perspective tilt — survives the downsample cleanly and reads
  first. The two cones behind it stay visible as distinct pointed shapes but
  compress into small, ambiguous slivers that could be read as anything
  pointed, not specifically flame.
- **Family distinction (5):** a single pale rectangular card slab is also the
  base shape `draw` (two overlapping card slabs) and this same batch's
  `stack` (three fanned card slabs) both build from. At full 256px the count
  and the flame/arrow/bar dressing tell them apart; at a real 42px downsample
  all three read first as "a pale rectangle or rectangles on brown," and only
  second as their individual mechanic. Three of the thirty-six icons now
  share one base silhouette family — worth a shared look if Nick wants one.
- **Mechanic match (6):** "exhaust a card" — a burning card is about as
  literal a match as exists for the mechanic, but the execution undercuts the
  idea it reaches for: the cones pixel-sample as a flat, hard-edged, uniformly
  lit orange/brick (RGB roughly 167-185 / 108-134 / 105-131 across the
  sampled surface, no brighter core or lighter tip anywhere), so they read as
  small triangular spikes or pennants rather than flame licks with heat or
  motion in them. The card being the clear foreground shape helps the "a card
  is involved" half of the read; the "and it's burning" half is weaker.
- **Colour & contrast (7):** pixel-sampled directly. The LINEN card body
  samples at roughly RGB(177-192, 156-174, 140-162) against the standin
  RGB(139,105,74) — a strong, consistent gap on every channel (+40 to +90).
  The CHARCOAL band samples far darker, roughly RGB(32-51, 33-52, 37-56),
  contrasting hard against both the card and the background. The flame
  cones are the weakest element: roughly RGB(167-185, 108-134, 105-131)
  against the same standin, a real but moderate 30-45/5-30/30-55-per-channel
  gap — visible, not close to disappearing, but the least separated element
  in the icon.
- **Style consistency (8):** the slab-plus-spike construction matches the
  vocabulary used throughout the set (`stack`'s bar, `taunt`'s pole,
  `light`'s rays are all the same taper/slab primitives); nothing about the
  render angle or lighting is an outlier.

## Diagnosis — two lowest

1. **Family distinction (5).** Concrete fix: differentiate `burn` from
   `draw`/`stack` by silhouette rather than relying on the flame to do all
   the work — e.g. curl or char the card's own edge (a bitten, blackened
   corner) so the card shape itself, not just what's behind it, signals
   "this one is different," rather than three icons that are each "a pale
   rectangle plus one extra element."
2. **Mechanic match (6).** Concrete fix: give the flame cones a lighter,
   warmer core (a GOLD or bright ORANGE tip against the current BRICK/ORANGE
   body) the way `light`'s rays use a two-tone gold-on-amber split, so the
   flame reads as glowing rather than as a flat-shaded solid spike.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the flame is meant to be read as small and secondary (the card IS
the mechanic — exhausting — and the flame is just flavour marking how) or
as an equal partner in the read; if the former, the current balance where
the card dominates and the flame is a background detail may be exactly
right and the Mechanic-match score above may be too harsh. Also unsure
whether this reads differently once seen next to `draw` and `stack` in an
actual hand rather than compared as three isolated 42px renders side by
side, which is a `needs a screen` question this static comparison can't
settle.
