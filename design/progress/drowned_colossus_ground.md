# drowned_colossus (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 8. Filed as `drowned_colossus_ground` rather than `drowned_colossus`
because a beast of the same name already exists in `game/assets/3d/cast/`.
**Scoring pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/drowned_colossus.py`.** Views:
`design/renders/drowned_colossus_pass1_*.png`, captured with
`look.sh env drowned_colossus 1`. **5800 tris against the 3600 ground
budget — 61% over.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 6 | 3 | 5 | 6 | **26** |

## What is actually there

A broken ring of individual UMBER/SLATE ruin pillars (the `ruin` enclosure)
at varied heights, with real gaps between segments rather than a continuous
wall — the first enclosure scored under this item built from separate
standing stones instead of a joined slab band. `_top.png` shows the floor
clearly: a TAN/UMBER dished disc with pale ICE/PERIWINKLE tide-pool patches
and small dark dots (kelp/rib props) scattered around it, matching the
docstring's "wet sand ... tide pools ... ribs of something that did not
make it back out." Unusually for this batch, `_34.png` and `_side.png` both
show a sliver of the same warm TAN/orange floor colour visible through the
gap between the two central pillars — the tide-pool detail is not fully
hidden at the fight-camera angle, unlike every other ground scored in
batches 5-8.

- **Silhouette** (`_sil.png`): a broken, unevenly-spaced jagged skyline with
  real negative space between segments — reads more like standing ruins
  than the solid battlements of the cliff/crag-wall family, and is the most
  distinct silhouette among this batch's four grounds.
- **Proportion**: the gaps between ruin pillars let a visible sliver of
  floor colour through at the fight-camera angle, a genuine partial
  exception to the "wall hides the floor" pattern named in batches 5-7 —
  though it is still a sliver, not the tide pools themselves; no individual
  pool or kelp shape is identifiable through the gap, only a colour hint.
- **Build hygiene (3).** 5800 tris against a 3600 budget is a 61% overage —
  in the same range as `gale_serpent_ground` (64% over, this same batch)
  and `shifting_idol_ground` (53% over, batch 7). No floating geometry
  found otherwise.
- **Colour & read**: the TAN/UMBER floor and pale ICE tide pools separate
  well from directly above, and the SLATE apron/pillars provide a cooler
  contrast to the warm floor — the strongest top-down colour read of this
  batch's four grounds — but almost none of that separation reaches the
  fight-camera angle beyond the one visible sliver noted under Proportion.
- **Style consistency**: the broken-pillar ruin silhouette is shared with
  `sunken_warden_ground` (also tagged `ruin` in its own script), and the two
  read as a family without being identical — a genuine "distinct place"
  result per the ART-REVIEW note's central question.

## Diagnosis — two lowest

1. **Build hygiene (3).** 61% over the 3600 ground budget. No fix proposed
   — item #83 reports rather than repairs.
2. **Colour & read, alongside Proportion.** The strong top-down tide-pool
   read barely survives to the angle a player actually sees. No fix
   proposed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the sliver of warm colour visible through the central pillar gap in
`_34.png` would register as "tide pools" to a player mid-fight, or would
read as no more than a colour smear too small to identify — the render
resolution here (512px) may be flattering a detail that would be even
smaller on an actual fight-camera framing. Also unsure whether the small
dark dots scattered on the floor in `_top.png` are the script's kelp/rib
props or shadow noise from the tide-pool geometry itself; both are
similarly small at this render distance and cannot be told apart by eye.
