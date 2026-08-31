# bounder (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 6. Filed as `bounder_ground` rather than `bounder` because a beast of
the same name already exists in `game/assets/3d/cast/`. **Scoring pass
only — item #83 is report, not repair; no edits made to
`tools/blender/env/bounder.py`.** Views: `design/renders/bounder_pass1_*.png`,
captured with `look.sh env bounder 1`.

Same rubric adaptation as `stone_warden_ground.md` and `crag_pup_ground.md`:
silhouette/proportion ask whether it reads as a *place*, following item #83's
own ART-REVIEW treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 4 | 6 | 5 | 7 | **27** |

## What is actually there

A ring of tall, blocky dark-slate pillars of varied width and height
encloses a flat pale-tan disc. From `_34.png` and `_side.png` the pillar
ring fills almost the entire frame — the "flat pale wash of rounded
cobbles" and the dry channels the script's own docstring names as the point
("the flatness is the point... a floor with nothing on it is a floor you
can see it land on") are invisible from that angle. The `_top.png` view
shows the intended floor clearly: a tan disc with dark rounded cobbles
scattered densest along two crossing channels, exactly as the script
describes.

- **Silhouette** (`_sil.png`): a jagged, tall-topped ring, close kin to
  `stone_warden_ground`'s and `crag_pup_ground`'s silhouettes — reads as
  "wall of blocks" generically rather than as anything specific to a
  riverbed. Since the script's whole intent for this ground is a *flat*
  floor (the opposite of a wall), the enclosure's silhouette actively
  contradicts the one-line design pitch in its own docstring.
- **Proportion**: worst line here and the reason for the low score — the
  script says explicitly that flatness is the point, so that this beast's
  own fight-camera view is dominated by a tall pillar ring rather than a
  flat plain is a direct miss against the stated intent, not just an
  unlucky camera angle. The actual cobble floor is only confirmable from
  directly above.
- **Build hygiene**: the pillars vary cleanly in width and height with no
  obvious floating pieces or repeated-tile look; the cobbles in `_top.png`
  read as individually sunk rocks rather than a smeared texture. Cannot
  confirm the "dry channels" braid pattern from any angled view — only
  visible from the top.
- **Colour & read**: STONE and PEWTER cobbles separate reasonably from the
  WHEAT/TAN floor in the top view. The pillar ring itself is a dark,
  near-uniform mass in the angled views — the same value-crowding problem
  already flagged for `stone_warden_ground`'s PEWTER/SLATE/GRAPHITE walls.
- **Style consistency**: sits fine beside the other two stone rings scored
  so far; the script's own docstring calls out a deliberate contrast with
  `crag_pup` (rounded/flat vs. angular/standing) and that contrast reads
  correctly when the top views of the two are compared.

## Diagnosis — two lowest

1. **Proportion (4).** The enclosure wall directly contradicts this
   ground's stated design goal — a flat, empty floor to watch a jumping
   beast land on — by filling the frame with a tall pillar ring instead.
   Concrete fix: none proposed here; item #83 reports rather than repairs,
   and whether the wall should be lower or set further back for this
   specific ground is a call for whoever owns the environment rig.
2. **Silhouette (5).** The ring's jagged block-top silhouette reads as
   generic "broken wall," the same shape already used for
   `stone_warden_ground` and `crag_pup_ground`, so a player cannot
   distinguish this ground from the other two stone rings by silhouette
   alone. Not applying a fix — flagged rather than diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Same open camera question as the first two grounds scored: whether
`look.py`'s three-quarter camera, calibrated for single creatures, actually
matches the real in-game fight camera's height and distance for a ring this
wide (45×46 units). This ground is the clearest case yet for asking that
question, since the whole design intent — a floor with nothing standing on
it — is invisible if the real camera sits where this render's camera sits.
