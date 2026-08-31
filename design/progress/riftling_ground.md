# riftling (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground** under item #83,
batch 8, the fourth and final ground scored this batch — all fourteen fight
grounds are now scored. Filed as `riftling_ground` since the beast the fight
is against shares the file's own name space with other assets in
`game/assets/3d/cast/` and `env/`. **Scoring pass only — item #83 is
report, not repair; no edits made to `tools/blender/env/riftling.py`.**
Views: `design/renders/riftling_pass1_*.png`, captured with
`look.sh env riftling 1`. **3748 tris against the 3600 ground budget — 4%
over, the closest to budget of any ground scored under this item.**

Same rubric adaptation as the other scored grounds: silhouette/proportion
ask whether it reads as a *place*, following item #83's own ART-REVIEW
treatment of grounds as a set.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 4 | 6 | 3 | 5 | **23** |

## What is actually there

A dense ring of dark CHARCOAL/GRAPHITE crag pillars (the `crag` enclosure,
same family as `sky_snapper_ground` and `crag_pup_ground`) surrounds a
small floor of cracked, tilted plates at the centre. `_top.png` shows the
floor pattern clearly: individual hexagonal-ish plates, several visibly
lifted or turned off true, with small violet dots scattered among them —
matching the docstring's "black rock split into plates ... small pieces
hanging where they should have fallen." `_34.png` and `_side.png` show that
pattern reduced to a small dark, barely-legible cluster glimpsed between two
central pillars. The docstring's single defining idea for this ground —
"the light comes from BELOW here and nowhere else in the game" — cannot be
checked at all in these renders: `look.py` captures with its own generic
lighting, not the in-game biome light, so there is no under-lighting glow
visible from any angle here.

- **Silhouette** (`_sil.png`): a tightly clustered, uneven spiky crown —
  distinct in outline from the more regular colonnade of
  `sunken_warden_ground` (this same batch), but close to the general shape
  already scored for `sky_snapper_ground` and `crag_pup_ground`, the third
  ground in this crag-wall family under this item.
- **Proportion**: the cracked-plate floor pattern that is this ground's
  whole point is reduced to a barely-visible dark patch at the fight-camera
  angle — the same "the floor detail only survives from directly above"
  finding as five of the other six grounds scored across batches 5-7.
- **Build hygiene (6, best line scored this batch).** 3748 tris against a
  3600 budget is only 4% over — a near-miss rather than an overage, and the
  only one of this batch's four grounds close to its budget line (the other
  three range from 61% to 92% over). No floating geometry found.
- **Colour & read (3, lowest line scored this batch alongside Sunken
  Warden).** CHARCOAL, GRAPHITE and MIDNIGHT pillars read as near-black in
  every view, the darkest-reading ground scored under this item so far —
  a real dark-on-dark concern per the rubric's own line. The docstring's
  stated colour idea for this ground is entirely about *lighting direction*
  rather than palette, and that idea is untestable from a generically-lit
  static render (see Unsure, below), so what is left to judge is a very
  dark wall with almost no visible floor.
- **Style consistency**: sits beside `sky_snapper_ground` and
  `crag_pup_ground` as a third crag-wall ground, consistent within that
  family but adding to the same repetition already flagged for the
  stone-wall and conifer-ring families in earlier batches.

## Diagnosis — two lowest

1. **Colour & read (3).** Near-black in every view, and the one design idea
   that could redeem it — under-lighting — is not visible in this render.
   No fix proposed — item #83 reports rather than repairs.
2. **Proportion (4).** The cracked-plate floor pattern only reads from
   directly above. No fix proposed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether this ground would read entirely differently under its actual
in-game light (`combat_3d.BIOME`, lit from below per the script's own
docstring) rather than `look.py`'s generic capture lighting — more than any
other ground scored under this item, this one's whole visual premise
depends on a light direction the capture tool does not reproduce, so the
Colour & read score here may be scoring the capture method rather than the
asset. Flagged rather than guessed, same caveat raised for
`sunken_warden_ground`'s coral colour in this same batch. Also unsure
whether the small violet dots visible in `_top.png` are the "small pieces
hanging" the docstring names or a separate prop — cannot tell at this
render distance.

## All fourteen fight grounds now scored

`stone_warden_ground`, `crag_pup_ground`, `bounder_ground`,
`bramble_hog_ground`, `root_lurker_ground`, `mire_snapper_ground`,
`sky_snapper_ground`, `frost_sentinel_ground`, `shifting_idol_ground`,
`grove_bear_ground`, `gale_serpent_ground`, `drowned_colossus_ground`,
`sunken_warden_ground`, `riftling_ground`. The map, all nineteen portraits
and all icon sets remain unscored under item #83.
