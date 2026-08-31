# mire_snapper (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 6. Filed as `mire_snapper_ground` rather than `mire_snapper` because a
beast of the same name already exists in `game/assets/3d/cast/`. **Scoring
pass only — item #83 is report, not repair; no edits made to
`tools/blender/env/mire_snapper.py`.** Views:
`design/renders/mire_snapper_pass1_*.png`, captured with
`look.sh env mire_snapper 1`.

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set. This ground is also the one the ART-REVIEW
batch note already flagged by name — "STEEL on CLAY silt is the weakest
colour call in the batch and may not read as water at all" — so this scoring
pass checks that specific claim directly rather than starting cold.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 5 | 6 | 3 | 6 | **26** |

## What is actually there

A ring of thin reed/grass blades, the most open silhouette of the four
grounds scored this batch, surrounds a two-tone dished floor: a CLAY/brown
outer band and, at the centre, several grey lumped shapes packed close
together. `_top.png` shows the grey shapes clearly: four rounded, bumpy,
STEEL-coloured masses that read as wet grey boulders or slag, not as flat
sheets of water. `_side.png` shows the reed ring is thin enough that the
ground plane is barely visible at all through the gaps — the water/silt
detail does not register from the side at any point.

- **Silhouette** (`_sil.png`): the thinnest, most broken silhouette of the
  four grounds scored this batch — individual grass blades rather than a
  solid mass — which is the right call for a wetland and the strongest
  line here.
- **Proportion**: the reed ring being thin and low means less of the frame
  is lost to the wall than in the stone or tree grounds, but the ground
  itself is still small relative to the ring, and the "half-sunk logs" and
  "dead snags" the script scatters further out are not identifiable in any
  of the six views.
- **Build hygiene**: reeds vary in height and angle without an obvious
  repeated-tile look; the grey centre shapes are smoothly sculpted with no
  visible floating pieces. No hygiene problem found in what is visible.
- **Colour & read (3, lowest line scored this batch across all assets so
  far).** Confirms the ART-REVIEW batch note's specific concern: the
  STEEL grey lumps at centre read as wet rock, mud, or slag — not water.
  Real water at this scale would need to look flat and reflective or at
  least a distinct blue-toned colour; STEEL is a matte structural grey used
  elsewhere in this project for machinery and stone, and stacked into
  rounded bumpy masses it reads as solid material. A beast whose entire
  gimmick, per the script's docstring, is "at a glance the beast is one
  more log" lying in *water* is undercut if the water itself doesn't read
  as water — a player has no baseline to compare "log" against.
- **Style consistency**: the open reed silhouette contrasts well with the
  denser tree and stone rings scored elsewhere in this batch, which is a
  genuine "distinct place" success per the ART-REVIEW note's central
  question.

## Diagnosis — two lowest

1. **Colour & read (3).** The water reads as grey rock/slag rather than
   water — confirms the batch-level concern already on record in
   `ART-REVIEW.md`. Concrete fix: none proposed here; item #83 reports
   rather than repairs, and picking a colour that reads as water within the
   existing flat-palette constraint is a call for whoever owns the palette.
2. **Proportion (5).** The half-sunk logs and dead snags the script places
   specifically to make the beast's camouflage trick work ("at a glance the
   beast is one more log") are not identifiable in any view, so the visual
   setup for that trick is not currently visible at all from the angle a
   player would actually see it. Not applying a fix — flagged rather than
   diagnosed further.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the small dark thin shapes visible scattered on the brown band in
`_top.png` are the script's `sunk_log()` props (UMBER limbs) or the TAN
silt bars, both of which are similarly small at this distance — cannot
tell them apart by eye alone. Also unsure whether the STEEL water reading
as rock is a lighting-only problem (this render uses `look.py`'s generic
capture lighting, not the game's actual fight lighting) or would still
read as rock in-engine — flagged rather than guessed either way, same
caveat item #83 has raised for other assets' "too dark" concerns.
