# flicker_stag — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/flicker_stag.py`.** Views:
`design/renders/flicker_stag_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 7 | 7 | 5 | 8 | **33** |

## What is actually there

A tall, elegant stag: four long slender legs, an arched climbing neck, a
small deer head with a branching bone-coloured rack, and a low rounded
belly bulge tucked under the chest between the forelegs. Reads clearly as
"stag" in the 3/4 view — the intent (a tall creature built to look
different from the cast's low quadrupeds) comes through.

- **Silhouette** (`_sil.png`): the antler crown and legs read distinctly,
  but the chest/belly bulge sits close enough to the forelegs that their
  outlines merge into one mass near the shoulder, losing the "long slender
  legs" read the design calls for at that spot.
- **Proportion**: torso, neck, legs and rack all read as stag-proportioned
  and the animal genuinely looks tall and light rather than squat — the
  stated design goal lands.
- **Build hygiene**: 2022/2600 tris, one mesh, nothing obviously floating
  or clipping in the views captured.
- **Colour & read**: the module doc calls the belly ball CREAM against a
  RUST body specifically so it doesn't blend — in the lit renders it reads
  as a slightly darker brown than intended and sits close in value to the
  RUST torso and BROWN legs, so the "pale chest" doesn't separate the way
  the palette note says it should. Antlers (WHEAT/SAND) and the gold eye
  ring do pop cleanly.
- **Style consistency**: tapered legs and ball-torso construction match the
  rest of the cast (yoke_ox, cinder_jackal) without looking foreign.

## Diagnosis — two lowest

1. **Colour & read (5).** The CREAM belly ball reads too close in value to
   the surrounding RUST/BROWN warm tones to do the separating job the
   module doc says it's for. Concrete fix: shift the belly ball's palette
   entry toward a genuinely lighter, less saturated cream (raise its value
   noticeably, not just its hue) so it reads as a pale chest patch rather
   than another brown.
2. **Silhouette (6).** The belly ball's outline overlaps the foreleg
   region, merging chest and legs into one blob at 64px. Concrete fix: pull
   the belly ball back in Y by ~0.10–0.15 toward the torso centre so a gap
   opens between it and the forelegs in the black silhouette.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the antler tines read as branching or just as two straight sticks
at fight distance — the 3/4 view shows branching clearly, but the
silhouette view (where a player is actually judging threat at speed) is
much harder to parse. Also unsure whether the floating-orb read I initially
had on the belly ball was a genuine geometry gap or just a lighting/value
illusion from the render angle — noted as a colour issue above rather than
a hygiene one because the module doc's own description ("pale chest/belly,
lower") matches what's built; it's the palette value that isn't landing.
