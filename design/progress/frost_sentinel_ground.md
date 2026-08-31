# frost_sentinel (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 7. Filed as `frost_sentinel_ground` rather than `frost_sentinel`
because a beast of the same name already exists in
`game/assets/3d/cast/`. **Scoring pass only — item #83 is report, not
repair; no edits made to `tools/blender/env/frost_sentinel.py`.** Views:
`design/renders/frost_sentinel_pass1_*.png`, captured with
`look.sh env frost_sentinel 1`. 2676 tris, within the 3600 ground budget.

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 7 | 7 | 7 | **36** |

## What is actually there

A ring of tall, thin ice-shard cones — sharp, single-pointed, no crown mass
— surrounds a barely-dished ICE floor with cracks radiating out from the
centre. This is the best-reading ground scored under this item so far, and
for a specific reason: because the shards taper to points rather than
staying wide near the base, `_34.png` shows real gaps between them at
fight-camera height, so the floor and its cracks are actually visible from
the angle a player would see, not only from directly above. Every stone-
wall ground scored in batches 5–6 failed exactly this test.

- **Silhouette** (`_sil.png`): a genuinely spiky, uneven crown of narrow
  points — the most distinct and least "solid mass" silhouette of any
  ground scored under this item, and it matches the docstring's stated
  intent ("the only angular thing in the roster") directly.
- **Proportion**: the radiating cracks are legible in `_top.png` and still
  partially visible in `_34.png` through the gaps between shards — this is
  the first ground scored where the floor detail the script was built to
  show actually survives to the fight-camera angle. The "drifts and shards"
  motif is consistent between the wall and the floor rather than being two
  disconnected ideas.
- **Build hygiene**: 2676 tris, well under the 3600 ground budget; shard
  cones and floor read as clean single shapes with no floating geometry
  found.
- **Colour & read**: ICE/STEEL/SILVER read clearly as pale, cold, and
  reflective-looking even in a flat-shaded render — no dark-on-dark problem
  here, in contrast to every stone-wall ground scored so far.
- **Style consistency**: consistent Kenney low-poly build, and — unlike the
  two conifer-ring grounds scored in batch 6 — visually distinct from every
  other ground scored under this item rather than a near-repeat of one.

## Diagnosis — two lowest

Every line scored 7 or above; nothing here clears the "genuinely weak"
bar the way sub-30 totals elsewhere in this batch do. Naming the two
relatively lowest rather than two failures:

1. **Proportion (7).** Strong relative to every other ground scored, but
   the cracks still fade to near-invisible at the far edge of `_34.png`
   where shard density is highest — the effect that makes this ground work
   is partly a lucky camera angle rather than guaranteed from every seat.
   Concrete fix: none proposed here; item #83 reports rather than repairs.
2. **Colour & read (7).** Reads well, but is close in tone to PERIWINKLE/SKY
   used for at least one other cold-palette asset elsewhere in the cast —
   not confirmed as a conflict from this render alone, just flagged as
   worth checking once more ice/sky-toned assets are scored.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the near-total loss of dark-on-dark problems here is because the
palette genuinely reads well, or because ICE/SILVER are simply lighter
values than the PEWTER/GRAPHITE/CHARCOAL stack every stone-wall ground uses
— i.e. whether this is a colour-choice win specific to this ground or would
recur automatically for any wall built from light-toned primitives. Also
unsure, as with every ground scored under this item, whether `look.py`'s
single-creature camera framing matches the real in-game fight camera.
