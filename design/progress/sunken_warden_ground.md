# sunken_warden (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 8. Filed as `sunken_warden_ground` rather than `sunken_warden` because
a beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/sunken_warden.py`.** Views:
`design/renders/sunken_warden_pass1_*.png`, captured with
`look.sh env sunken_warden 1`. **6908 tris against the 3600 ground budget —
92% over, the largest overage found under this item across all eight
batches, surpassing `grove_bear_ground`'s 75% from batch 7.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 2 | 3 | 6 | **21**, the lowest scored under this item so far |

## What is actually there

A tight ring of NAVY/MIDNIGHT colonnade pillars (the `ruin` enclosure)
encloses a small round temple floor at the centre. `_top.png` shows the
temple floor clearly: concentric rings of square slabs, most seated flush
and a few visibly lifted, matching the docstring's "big square slabs in
courses ... some lifted." A cluster of small vertical shapes sits at the
very centre — per the build script this is the `coral()` scatter, drawn
from `CORAL`/`ROSE`/`BLUSH`. In every view captured here — `_top.png`,
`_34.png` and `_side.png` alike — that cluster reads as cool blue/indigo,
not as the warm pink-orange the docstring calls out by name: "coral, the
one warm colour in the game's coldest palette." The colonnade itself
tightly encloses the floor from every angle, consistent with the docstring's
own goal ("the last fight is the only one with walls").

- **Silhouette** (`_sil.png`): a dense, evenly-spaced ring of similar-height
  pillars with one taller pillar breaking the line at centre-back — reads
  as a colonnade specifically, more distinct than the irregular cliff/crag
  walls scored elsewhere, and appropriate to "temple."
- **Proportion**: the colonnade closing tightly around the floor is the
  stated design goal here (unlike the outdoor grounds, where a closed wall
  was a defect), so the near-total floor occlusion at the fight-camera
  angle is arguably working as intended rather than against it — though
  that also means the slab-course floor detail visible from above is not
  verifiable as ever being seen in play.
- **Build hygiene (2, lowest line scored under this item across all eight
  batches).** 6908 tris against a 3600 budget is a 92% overage — the
  largest found under this item, ahead of `grove_bear_ground`'s previous
  record of 75%. No floating geometry found otherwise; the fault is purely
  the budget, but by a wide enough margin to be the worst hygiene line
  scored so far.
- **Colour & read (3, lowest line scored this batch).** The docstring names
  one specific design goal for this ground's colour — "coral, the one warm
  colour in the game's coldest palette" — and in every view captured here
  the central coral cluster reads as blue/indigo, not warm. If that read is
  accurate rather than a rendering artefact (see Unsure, below), the
  ground's single stated colour idea is not visible at all.
- **Style consistency**: reads as a family with `drowned_colossus_ground`
  (also a `ruin` enclosure, this same batch) while remaining visually
  distinct from it — cooler, tighter, more symmetrical — a genuine
  "distinct place" result.

## Diagnosis — two lowest

1. **Build hygiene (2).** 92% over the 3600 ground budget, the worst found
   under this item. No fix proposed — item #83 reports rather than
   repairs.
2. **Colour & read (3).** The coral cluster reads cool rather than warm in
   every view. No fix proposed; if this is a real colour-application bug
   rather than a lighting artefact, it directly contradicts the build
   script's own stated design goal and would be worth a second look with a
   different light setup before treating it as confirmed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the central cluster reading blue/indigo instead of coral/rose/blush
is a real colour-application problem in `coral()` or purely a rendering
artefact: `look.py` uses generic capture lighting, not the game's actual
underwater biome light (`combat_3d.BIOME`), and this is the only ground
scored under this item whose script explicitly calls out warm colour as its
whole point, so a wrong ambient/fog tint here would be more visible than on
any other asset scored so far. Genuinely cannot tell from a static render
under unknown lighting whether the swatch itself is wrong or the light is —
flagged rather than guessed, same caveat item #83's own notes raise for
other assets' "too dark" concerns.
