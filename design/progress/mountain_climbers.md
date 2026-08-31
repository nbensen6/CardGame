# mountain_climbers — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/mountain_climbers.py`.** Views:
`design/renders/mountain_climbers_pass1_*.png`. First scoring under item #83's
rubric for a **hunter** (1400 tri budget) — the five-line rubric applies the
same way.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 7 | 5 | 7 | 8 | **34** |

## What is actually there

A stocky figure in a blue jacket and brown trousers, a mustard-yellow helmet
with a round headlamp on the brim, a water bottle strapped across the chest
with tan harness webbing, a brown backpack, and a coiled dark loop of rope
hanging at the hip. A pale blue angular shard sits against the right cheek,
below the helmet brim.

- **Silhouette** (`_sil.png`): a readable stocky-humanoid outline — helmet
  bump, boxy pack behind the shoulders, two planted boots. It does not
  distinguish itself sharply from a generic "person with a backpack" shape;
  nothing about the outline alone says "climber" rather than "hiker" or
  "miner", which the build intent's own module name suggests it should.
- **Proportion**: reads as a sturdy, grounded figure and sits comfortably at
  hunter scale next to the other hunters scored so far (frog, lightbearer,
  vine_weaver). No stretched or shrunken parts.
- **Build hygiene**: 1436/1400 tris, 36 over the hunter budget — a small
  overage but a real one, unlike vine_weaver's flagged/deliberate excess.
  The pale blue shard at the cheek (visible in `_34.png` and `_side.png`) has
  no clear attachment point — it isn't obviously gripped by a hand or clipped
  to the helmet, and from the side it reads as a shape poking out of the
  jaw rather than a held tool (an ice axe, going by the setting) or a strap
  buckle catching the light.
- **Colour & read**: blue jacket, brown legs/pack/boots, mustard helmet,
  tan webbing, dark rope coil — five materials that separate cleanly at
  both viewed sizes, nothing dark-on-dark. The headlamp's white dot on the
  helmet brim reads clearly even at silhouette scale as a detail (though the
  silhouette itself is solid black, so this is a colour-render-only cue).
- **Style consistency**: fits the cast's rounded low-poly look; harness
  webbing and backpack read as gear the way other hunters' props do.

## Diagnosis — two lowest

1. **Build hygiene (5).** The cheek shard has no visible connection to hand
   or helmet in any of the four lit views. Concrete fix: either move it into
   the hand (climbers carry an ice axe) with a short haft connecting it to
   the fist, or shrink it and align it flush against the helmet brim as a
   clipped-on tool so the attachment reads. Separately, trim the 36-tri
   overage — the rope coil ring is the cheapest place to drop a segment or
   two before touching anything that carries the read.
2. **Silhouette (7).** The outline doesn't say "climber" specifically. Not
   urgent, but if revisited: a visible loop of rope proud of the hip
   silhouette (it currently sits close enough to the body to read as body
   mass in `_sil.png`) or crampons at the boot line would push the read
   further than the current pack-and-helmet combination, which reads as
   general outdoor gear.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the coiled rope at the hip is legible as rope rather than as a dark
smudge at the smaller 34px party-panel size — it reads clearly at 512px in
`_side.png` but the render pipeline here doesn't produce a 34px comparison,
so this is a guess rather than a checked fact.
