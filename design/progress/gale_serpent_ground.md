# gale_serpent (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 8. Filed as `gale_serpent_ground` rather than `gale_serpent` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/gale_serpent.py`.** Views:
`design/renders/gale_serpent_pass1_*.png`, captured with
`look.sh env gale_serpent 1`. **5906 tris against the 3600 ground budget —
64% over.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 5 | 3 | 4 | 6 | **22** |

## What is actually there

A ring of tall, uneven SLATE/CHARCOAL cliff slabs (the `cliff` enclosure,
same primitive family as `stone_warden_ground` and `crag_pup_ground`)
surrounds a shallow dished floor. `_top.png` shows the floor's one real
design idea clearly: four rock grooves spiral out from the centre, winding
the same turn as the beast — a genuinely on-concept detail, matching the
beast's own spiral. `_34.png` and `_side.png` show that idea is invisible
from the fight camera: the cliff wall fills almost the entire frame and the
spiral grooves do not register at all below the ring's own height. No wind-
shaped stones or any other floor prop from the docstring ("a few wind-shaped
stones") are identifiable in any view.

- **Silhouette** (`_sil.png`): an irregular crenellated skyline — legible as
  "a wall," but not specifically as a "bare wind-scoured ridge." It reads
  close to the same jagged-pillar family already scored for
  `stone_warden_ground`, `crag_pup_ground`, `bounder_ground` and
  `sky_snapper_ground`, the fifth ground in this shape family scored under
  this item.
- **Proportion**: the one detail this ground was built around — the spiral
  grooves matching the beast's turn — only exists from directly above; at
  the fight-camera angle the floor is a flat grey disc with no visible
  spiral, so the ground's central design idea does not survive to the angle
  a player would see.
- **Build hygiene (3).** 5906 tris against a 3600 budget is a 64% overage.
  No floating geometry or other build fault found — the fault is purely the
  budget, same class of finding as `shifting_idol_ground` (53% over) and
  `grove_bear_ground` (75% over) in batch 7.
- **Colour & read (4, lowest line scored this batch alongside Silhouette).**
  SLATE walls, CHARCOAL rim and a grey floor — no accent colour anywhere in
  any view. Unlike `frost_sentinel_ground` (ICE/SILVER) or
  `drowned_colossus_ground` (TAN floor, this same batch), nothing here reads
  as anything but uniform grey-on-grey. Not dark-on-dark exactly, since the
  values are mid-grey rather than near-black, but there is no colour doing
  any work at all.
- **Style consistency**: sits comfortably beside the other cliff/crag-wall
  grounds already scored — consistent with the established family, for the
  same reason that family keeps scoring low elsewhere: it is now the fifth
  near-identical tall-grey-pillar-ring ground under this item.

## Diagnosis — two lowest

1. **Silhouette / Colour, tied at 4.** The wall reads as a generic grey
   pillar ring rather than anything specific to "wind-scoured ridge," and no
   colour anywhere breaks the grey. No fix proposed — item #83 reports
   rather than repairs.
2. **Build hygiene (3).** 64% over the 3600 ground budget. No fix proposed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the spiral grooves would read once the beast itself is standing in
the middle of the floor at actual play distance, rather than in this
ground-only render shot from a generic capture camera — same caveat the
`grove_bear_ground` entry raised about judging a camouflage/site-specific
detail without the beast present. Also unsure whether `look.py`'s capture
camera, calibrated for single creatures, is representing the real in-game
fight camera's framing for a ring this wide — the same open question batch
5's log first raised and never resolved.
