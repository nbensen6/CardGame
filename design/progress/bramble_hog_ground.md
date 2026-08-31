# bramble_hog (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 6. Filed as `bramble_hog_ground` rather than `bramble_hog` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/bramble_hog.py`.** Views:
`design/renders/bramble_hog_pass1_*.png`, captured with
`look.sh env bramble_hog 1`.

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 6 | 6 | 5 | 6 | **29** |

## What is actually there

A ring of conifer trees (trunk-and-cone shapes, not a solid wall) surrounds
a small trodden-brown hollow. Unlike the two stone-wall grounds scored so
far, the trunks are thin enough that `_side.png` shows a visible gap of
open dark ground between them at the base, so the hollow is at least
partly visible from an angled view, not only from directly above. `_top.png`
confirms the hollow: a rust-brown disc with a dark outer rim and scattered
green/orange dots (the leaf-litter and bramble props the script's docstring
names).

- **Silhouette** (`_sil.png`): a spiky, uneven treeline — reads clearly as
  "trees" and, because the trunks are thin rather than solid blocks, this
  is the first ground scored where the silhouette is not dominated by one
  continuous dark mass. Distinct from the stone rings' silhouettes.
- **Proportion**: better than the two stone grounds because the tree trunks
  are thin enough to partly see through — the hollow is visible, if small,
  from `_side.png` and not only from above. Still small relative to the
  treeline surrounding it, and the "fallen logs rotted into the ground"
  the script's docstring calls for are not identifiable in any view.
- **Build hygiene**: the cone-and-trunk trees vary in height and spacing
  without an obvious repeated-tile look; no floating geometry visible. The
  bramble mounds described in the script (thorny, ball-shaped, around the
  hollow's edge) are not clearly distinguishable from ordinary ground
  litter in these views — cannot confirm they read as the specific "brambles
  at rest, the same shape as the beast" the docstring intends.
- **Colour & read**: GREEN conifers against the UMBER/CHARCOAL hollow
  separate cleanly — this is the best colour separation of the three
  grounds scored in this batch so far. The hollow itself is a fairly flat,
  featureless brown from any angled view; whatever texture variety exists
  (leaf litter colours, bramble mounds) is not distinguishable at this
  camera distance.
- **Style consistency**: the trees read as generic Kenney-style conifers
  rather than as anything specific to a "thicket the beast IS," which is
  the script's stated design idea — the ground currently reads as "a
  clearing in a pine forest" rather than "a bramble thicket."

## Diagnosis — two lowest

1. **Colour & read (5).** Once past the green-vs-brown separation, the
   hollow floor has no visible internal variation (leaf litter colours,
   bramble mounds, fallen logs) at fight-camera distance — it reads as one
   flat brown disc. Concrete fix: none proposed here; item #83 reports
   rather than repairs.
2. **Style consistency (6).** The tree ring reads as generic conifer forest
   rather than the "thicket that IS the beast" the script's docstring
   describes — nothing in the visible geometry connects the ground's
   greenery to the Bramble Hog specifically, the way `crag_pup_ground`'s
   leaning shards do connect to that beast's own material. Not applying a
   fix — flagged rather than diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the small ball/mound shapes visible at the hollow's edge in
`_top.png` are the bramble mounds the script's `thicket()` helper builds
("the same shape as the beast, asleep") or ordinary leaf-litter scatter —
both are similarly small and brown at this render distance, and there is no
way to tell them apart by eye alone. Also unsure, as with the other grounds
scored, whether `look.py`'s single-creature camera framing matches the
real in-game fight camera for an environment this wide.
