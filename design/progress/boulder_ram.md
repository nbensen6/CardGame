# boulder_ram — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/boulder_ram.py`.** Views: `design/renders/boulder_ram_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 4 | 5 | 7 | **29** |

## What is actually there

A low, block-bodied quadruped: a boxy CLAY chest, an UMBER shoulder hump, a
lowered BROWN wedge head with a single dark eye dot, four short CHARCOAL legs
planted wide. The script means to mirror a pair of curled TAN ram horns up
and back off the head. What actually renders, in every lit view, is a single
grey-and-gold disc-with-rod sitting beside the hump like a bobbin or a stuck
knob — nothing that reads as a curled horn, and no second horn visible
anywhere, on either side.

- **Silhouette** (`_sil.png`): reads cleanly as a stocky charging animal —
  humped shoulders, lowered head, four stub legs. The horn geometry is
  invisible in the silhouette; it neither helps nor hurts here, which is
  itself a sign it isn't doing the "ram" work the module doc asks of it.
- **Proportion**: torso, hump, and lowered head read as "boulder-quadruped"
  exactly as intended. But the doc is explicit that curled horns are what
  reads "ram" rather than "dog or boar" — with the horns reading as a stray
  mechanical part instead, the creature's identity leans back toward
  generic stone beast.
- **Build hygiene**: the horn's `limb()` curl does not read as a curl from
  any angle captured — three-quarter, side, and top all show the same flat
  disc-with-rod, as if the four-point curl is being viewed edge-on from
  every camera at once, or the segments have collapsed toward one plane.
  Top view (`_top.png`) shows only one such shape near the right shoulder
  with nothing mirrored on the left, despite the script mirroring the horn
  with `s` over `(-1, 1)` — the second horn is not visible in any view,
  either hidden behind the hump from every angle by coincidence or not
  contributing to the silhouette/render at all.
- **Colour & read**: body colours (CLAY/UMBER/BROWN/CHARCOAL) separate
  cleanly and nothing is dark-on-dark. The horn itself renders grey with a
  gold band rather than TAN — a specular artifact on thin curled geometry,
  or the wrong swatch; either way it reads as metal, not horn keratin.
- **Style consistency**: boxy stone-plate primitives sit fine beside the
  rest of the low-poly cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** The horn reads as a flat mechanical disc from
   three-quarter, side, and top alike, and only one is visible anywhere
   despite being mirrored in script. Concrete fix: render a dedicated close
   camera on just the head/horn region (crop tighter than the six standard
   views) to see whether the curl geometry is actually built as intended or
   is collapsing — this needs a closer look before a numeric fix is
   proposable.
2. **Colour & read (5).** The horn's grey-and-gold look does not match TAN.
   Concrete fix: confirm what swatch `TAN` resolves to in `kenney.py`'s
   palette and check the horn's UVs land inside it rather than off the atlas
   edge, since an off-atlas UV would explain both the wrong colour and the
   metallic look.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the horn is genuinely mis-rendering (a UV or geometry bug) or
whether it is built correctly but this creature's curled-horn shape simply
doesn't read at this poly budget from any of the six standard camera
angles — a tighter head-only crop would settle this and is worth doing
before anyone spends a fix on it.
