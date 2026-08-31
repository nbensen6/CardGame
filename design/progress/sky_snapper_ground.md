# sky_snapper (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 7. Filed as `sky_snapper_ground` rather than `sky_snapper` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/sky_snapper.py`.** Views:
`design/renders/sky_snapper_pass1_*.png`, captured with
`look.sh env sky_snapper 1`. 3210 tris, within the 3600 ground budget.

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 4 | 6 | 3 | 6 | **25** |

## What is actually there

A ring of tall, tapered rock columns (the `enclose("crag")` wall) surrounds
a dished disc floor with visible horizontal banding. `_top.png` shows the
bedding-plane steps clearly — six concentric rings running the same
direction, which does read as "laid down" rather than "piled up," matching
the script's stated intent. It also shows a scatter of small dark balls
along the outer edge, between the columns, which is presumably the nest
ring of dragged branches and bones the docstring calls out as "the one
detail that carries it" — too small and too dark to identify as branches or
bones specifically at this render distance. `_34.png` and `_side.png` show
the same pattern as every other stone-wall ground scored so far: the crag
columns fill almost the entire fight-camera-height frame and the dished
floor is a narrow sliver, visible only through the gaps between columns.

- **Silhouette** (`_sil.png`): an uneven, jagged crown of columns at varying
  heights — reads more like a real crag skyline than the more uniform
  `stone_warden_ground` wall, and is the strongest line scored here.
- **Proportion**: the bedding-plane floor detail is legible from directly
  above but nearly absent from the angle a player would actually see
  (`_34.png`), and the nest ring — the one detail the script's own docstring
  singles out as load-bearing — is not identifiable as branches-and-bones in
  any view, only as generic dark scatter.
- **Build hygiene**: 3210 tris, under the 3600 ground budget; the columns
  vary cleanly in height and lean with no floating pieces found.
- **Colour & read (3, tied lowest line scored this batch).** PEWTER and
  GRAPHITE columns against a GRAPHITE-rimmed floor read as near-black in
  both `_34.png` and `_side.png` — the same dark-on-dark problem already
  flagged for other grounds in this family, and here it is worse because
  almost nothing but the columns is visible from fight-camera height to
  begin with.
- **Style consistency**: fits the established stone-ring family (alongside
  `stone_warden_ground`, `crag_pup_ground`), appropriately the most
  wind-scoured and exposed-feeling of the three, which matches "the highest
  place in the game."

## Diagnosis — two lowest

1. **Colour & read (3).** The whole visible frame at fight-camera height is
   PEWTER/GRAPHITE columns reading near-black, with almost no floor colour
   breaking it up. Concrete fix: none proposed here; item #83 reports
   rather than repairs, and picking lighter or more varied column tones
   within the existing flat-palette constraint is a call for whoever owns
   the palette.
2. **Proportion (4).** The nest ring — the docstring's named "one detail
   that carries it" — is not identifiable as branches or bones in any of
   the six views, only as small dark scatter indistinguishable from generic
   ground clutter. Not applying a fix — flagged rather than diagnosed
   further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the nest ring would read correctly at the game's actual in-engine
lighting and camera distance rather than `look.py`'s generic capture setup
— this render is dark enough that a genuinely well-modelled nest of bones
could still be invisible here for lighting reasons rather than modelling
ones. Also unsure, as with every other ground scored under this item,
whether `look.py`'s single-creature camera framing (calibrated for a beast,
not a 47-unit-wide ground) actually matches the real in-game fight camera.
