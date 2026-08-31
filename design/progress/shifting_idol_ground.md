# shifting_idol (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 7. Filed as `shifting_idol_ground` rather than `shifting_idol`
because a beast of the same name already exists in
`game/assets/3d/cast/`. **Scoring pass only — item #83 is report, not
repair; no edits made to `tools/blender/env/shifting_idol.py`.** Views:
`design/renders/shifting_idol_pass1_*.png`, captured with
`look.sh env shifting_idol 1`. **5504 tris against the 3600 ground
budget — 53% over, the largest overage found under this item so far.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 4 | 3 | 4 | 6 | **23** |

## What is actually there

A ring of flat rectangular slabs — colonnade stumps — surrounds a dark
central platform. `_top.png` shows the intended "made" pattern clearly:
four concentric rings of flagstones, each turned slightly off the last, and
a distinct stepped ring at the very centre where the beast stands — this is
the strongest floor storytelling seen in any ground scored under this item
when viewed from directly above. `_34.png` and `_side.png` show the same
failure as every stone-wall ground scored in batches 5–6: the colonnade
stumps fill nearly the whole fight-camera-height frame, and the flagstone
rings that read so well from above are reduced to a barely-visible dark
sliver at the base.

- **Silhouette** (`_sil.png`): a blocky, rectangular-slab crown, distinct
  in shape from the tapered crag columns (`sky_snapper_ground`) and the
  ice shards (`frost_sentinel_ground`) — reads as "built" rather than
  "grown" or "eroded," which matches the docstring's "the only made thing
  in the roster" intent.
- **Proportion**: the concentric flagstone rings and centre step — the
  script's stated point — are legible only from directly above; from the
  fight-camera angle nothing of the "made" floor detail survives, the same
  gap named for `stone_warden_ground` and `crag_pup_ground`.
- **Build hygiene (3, lowest line scored this batch).** 5504 tris against a
  3600 budget is a 53% overage, the largest found under this item across
  seven batches — worse than `vine_weaver`'s previously-flagged 304-tri
  overage by an order of magnitude. No floating geometry found otherwise.
- **Colour & read**: PEWTER/SLATE/GRAPHITE colonnade stumps against a
  GRAPHITE-rimmed platform read dark and low-contrast in `_34.png` and
  `_side.png` — another entry in the same dark-on-dark pattern named for
  `sky_snapper_ground` and the batch-5/6 stone grounds.
- **Style consistency**: fits the stone-ring family while reading as
  distinctly more "built" than `stone_warden_ground` or `crag_pup_ground`'s
  more natural rock forms — a real differentiation success within the
  family.

## Diagnosis — two lowest

1. **Build hygiene (3).** 5504 tris is 1904 over the 3600 ground budget
   (53%), the largest overage found under this item. Concrete fix: none
   proposed here; item #83 reports rather than repairs, but this is a
   budget violation rather than a subjective read and may be worth a
   priority flag distinct from the purely aesthetic findings elsewhere in
   this file.
2. **Proportion (4).** The concentric flagstone rings and centre step —
   the floor detail the script was specifically built to show, and the
   best-reading floor pattern of any ground scored under this item from
   directly above — do not survive to the fight-camera angle at all. Not
   applying a fix — flagged rather than diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the 5504-tri count is deliberate (four flagstone rings at
increasing radius, per-stone geometry, could plausibly add up fast) or an
oversight the way `vine_weaver`'s smaller overage was flagged as a
"deliberate trade-off" in its own build note — this script's docstring
makes no such note, so status unknown from the script alone. Also unsure,
as with every ground scored under this item, whether `look.py`'s
single-creature camera framing matches the real in-game fight camera
closely enough for the "floor invisible at fight height" finding to hold
in-engine.
