# boulder_ram — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/boulder_ram.py`.** Views: `design/renders/boulder_ram_pass1_*.png`.
Captured after "Darken the rock, warm the organics" (palette + UV fix) and the
three-point lighting rig landed underneath this pass via merge — re-rendered
against both before scoring; this asset's colours and the horn issue below are
unchanged from the pre-fix render.

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

---

## Pass 2 — fixer lane, 2026-09-05

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`). Views:
`design/renders/boulder_ram_pass1_front.png` (the dead-on angle `look.py`
gained on 2026-08-31, after this asset's pass-1 diagnosis was written — the
diagnosis above was scored without it) and
`design/renders/boulder_ram_pass2_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 4 | 5 | 7 | **29** |
| 2 | 7 | 6 | 4 | 5 | 7 | **29** |

### Colour (5) — investigated, not a bug, nothing changed

`TAN` resolves to `swatch(272, 320)` in `kenney.py` — an interior cell of the
atlas, 16px clear of every edge, same as every other named swatch. Not
off-atlas.

The dedicated close look this item asked for (`boulder_ram_pass1_front.png`)
shows why the diagnosis read "grey-and-gold, not TAN": **the grey-and-gold
disc-with-rod is not the horn.** It is the sigil assembly mounted on the
hump's own front face two lines below the horn call in the script
(`boulder_ram.py:108-109`, a STONE box plus the gold `mark()`), sitting a
few centimetres from the horn's own end point in the `34`/`side`/`top`
renders and reading as one object there. In the front view, both TAN horns
are plainly visible, correctly coloured, correctly mirrored, symmetric
either side of the head. There is no colour bug and no missing second
horn — both were an artifact of scoring against a render set that did not
yet include the front angle. Nothing to fix here; leaving the code as-is.

### Build hygiene (4) — tried and reverted

Tried thickening the horn tube to see if a thin cross-section was why it
reads as a flat disc from the fight camera: `[0.09, 0.07, 0.05, 0.02] ->
[0.16, 0.13, 0.09, 0.05]` in `boulder_ram.py`'s `limb()` call (radii only,
same points, same seg=6).

Rebuilt and compared `boulder_ram_pass2_34.png`, `_side.png` and `_top.png`
against the pass-1 versions side by side: no visible change in any of the
three. The horn is still essentially unreadable from the fight camera, the
side, and the top — it only reads (as a flat wedge, not a curl) from the
front angle, which the actual game camera never uses. Thickness was not
the problem, so reverted (`git checkout -- tools/blender/boulder_ram.py`,
rebuilt to confirm the shipped glb matches).

**Real cause, as best determined by looking:** the curl sits low against
the head and nearly edge-on to every camera except the front one — from
`34`/`side`/`top` it is occluded by or foreshortened flat against the head
and hump, not merely thin. Fixing that means moving or re-angling the curl
so it projects clear of the head from the fight-camera direction, which is
a shape change to how prominently a "ram horn" silhouette should read
against this body, not a measurement — flagging rather than guessing at it
inside this run's two-fix budget.

Total unchanged (29), a plateau on the numbers, but not wasted: one of the
two named problems (colour) turns out not to exist, and the real hygiene
problem is now stated correctly (occlusion/angle, not thickness or a
missing horn) for whoever takes the next pass.
