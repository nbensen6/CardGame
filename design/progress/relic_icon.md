# relic — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 20 — continuing the icon rubric batches 14-19 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/relic.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Third of
batch 20's four (see `expose_icon.md` for the batch's scope and shared
rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 6 | 8 | 8 | **39** |

## What is actually there

A GOLD ring around a faceted six-pointed star built from two overlapping
VIOLET/ORCHID triangular spikes — a gem-cut medallion. The build script
also places a small LILAC ball at the star's centre, but it sits directly
behind the star geometry from this head-on angle and is not visibly
distinguishable in the render.

- **Silhouette @ 42px (8):** the ring-plus-star shape stays crisp at the
  real downsample — the six points remain individually countable rather
  than smoothing into a circle, one of the cleaner silhouettes scored
  under this item.
- **Family distinction (9):** no other icon scored under this item
  combines a ring with a faceted star; distinct from `expose`'s and
  `target`'s plain-ring-plus-dot construction (this batch's `expose_icon.md`)
  by shape, not just colour.
- **Mechanic match (6):** a gem/star medallion reads generically as
  "treasure, badge, or trinket," which fits "a lasting boon" as a
  keepsake but doesn't specifically signal *permanence* the way, say, a
  root or anchor motif would — nothing distinguishes it from an icon that
  could equally sit on a one-time reward or a currency, rather than
  something that stays with you for the run.
- **Colour & contrast (8):** the saturated violet/orchid star and gold
  ring both read clearly distinct from the brown standin in every sampled
  region — no near-miss found.
- **Style consistency (8):** the ring construction matches `buffer`,
  `guard`, `expose` and `target`'s shared ring vocabulary; the faceted
  star's bevel treatment is consistent with the rest of the set's flat-
  shaded low-poly look.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: work a small distinguishing motif
   into the star's centre (where the currently-hidden LILAC ball already
   sits, unused visually) — a root, chain-link, or glow cue that reads as
   "stays with you" rather than "one-time find."
2. **Silhouette @ 42px (8) tied with Style (8), naming Silhouette as the
   lower-value fix target:** no strong defect found; if anything, adding
   the centre motif above would need to preserve the current clean
   silhouette rather than crowd it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the LILAC centre ball is doing anything visually from this
camera angle — it may be fully occluded by the star geometry, in which
case it is dead weight in the build script rather than a deliberate
design element; not confirmed either way from a single head-on render.
