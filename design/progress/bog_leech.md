# bog_leech — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/bog_leech.py`.** Views: `design/renders/bog_leech_pass1_*.png`.
Captured after "Darken the rock, warm the organics" (rock-family palette darkened,
a UV row-sampling bug fixed) and the three-point lighting rig landed underneath this
pass via merge — re-rendered against both before scoring rather than scoring stale
images; geometry is unchanged so silhouette/proportion/hygiene findings below hold,
colour was checked fresh against the darker body.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 4 | 5 | 6 | **25** |

## What is actually there

A squat, swollen slate-grey blob body with two smaller humps stepping up its
back, four small red ledge-shelf bars along its flank, a ring of small dark
balls (a torus) hanging under the front as the "wet sucker-mouth" the module
doc describes, and a thin grey crest off to one side carrying the gold sigil
disc.

- **Silhouette** (`_sil.png`): the main body reads as a rounded blob, but the
  sucker-mouth ring shows up as a separate smudge low and to the left,
  visually split from the main mass rather than reading as a mouth
  structure that's part of the same creature. Weakest silhouette of this
  batch.
- **Proportion**: the "squat, swollen" main mass matches the doc, but the
  two back humps read as a generic stacked-snowman shape rather than
  distinct "fed-fat body-segments," and the sucker-mouth — the one feature
  the doc singles out as this creature's identity — does not read as a
  mouth in any of the six views; it reads as a decorative ring or anklet
  hanging beneath the body.
- **Build hygiene**: the top view confirms the sucker-ring does touch the
  body (not a true floating island), but built from small spaced balls on a
  thin torus it reads as debris rather than an attached feature from every
  lit angle. The sigil crest repeats the same thin-rod-plus-disc pattern
  already flagged this batch in Silk Widow and Thrasher — three of four
  beasts scored this session share the identical "orbiting part" issue on
  their sigil crest.
- **Colour & read**: darker now than the pre-fix render (the rock-family
  swatches this body uses were darkened for the Crag Pup/Stone Warden), but
  still close to monochrome — main mass and both back humps sit in the same
  dark slate value range with little separation between them. The red ledge
  bars are the only real colour break and they read as level markers, not
  body features, which is presumably correct.
- **Style consistency**: primitives and bevel style match the rest of the
  cast; nothing here looks out of place beside the other elites.

## Diagnosis — two lowest

1. **Build hygiene (4).** The sucker-mouth ring reads as loose debris, not
   a mouth. Concrete fix: replace the spaced-ball torus with a single
   solid ring-shaped mesh (or fatten the existing balls until they overlap
   into one continuous loop) so it reads as one wet sucker rather than a
   string of beads.
2. **Silhouette (5).** The sucker-mouth splits off from the main body
   silhouette. Concrete fix: pull the ring up and into the main body's
   bounding volume by roughly 0.10-0.15 so the two masses overlap in
   silhouette instead of touching only at one point.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the two back humps are meant to be read as separate "fed-fat
segments" at all, or whether the flat, close-in-value grey across the whole
body is a deliberate "bog creature" choice that a warmer body colour plus a
darker/wetter mouth colour would undercut — that's a palette-direction call,
not a measurement, so it's named rather than guessed at.

---

## Pass 2 — fixer lane, 2026-08-31

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/bog_leech_pass2_*.png`, captured with
`look.cmd bog_leech 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 4 | 5 | 6 | **25** |
| 2 | 6 | 5 | 6 | 5 | 6 | **28** |

### Both diagnosed fixes applied, together, since they're the same feature

The sucker-mouth ring and its mouth-well ball are one visual unit, so both
moved as one:

- **Build hygiene (4 → 6).** `ring(..., 14, 5, thickness=0.10)` — a torus thin
  enough, with few enough major segments, that its facets read as separate
  lumps rather than one loop. Thickness `0.10 → 0.16` and minor segments
  `5 → 7` so the tube reads as one rounded ring instead of a string of
  beads. `bog_leech_pass2_form.png` shows a visibly fatter, rounder loop
  next to `bog_leech_pass1_34.png`'s thin faceted one.
- **Silhouette (5 → 6).** Ring and mouth-well pulled 0.12 up (Z) and 0.12
  forward into the main sac (Y: -1.42 → -1.30, Z: 0.55 → 0.67).
  `bog_leech_pass2_sil.png` now reads as one connected mass at the front-
  bottom; compare `bog_leech_pass1_sil.png`, where the mouth is a clearly
  separate hooked smudge below and left of the body with daylight between
  them.

Neither line hit "shippable" (8) — from the side (`bog_leech_pass2_side.png`)
the mouth is now mostly hidden behind the main mass rather than reading as a
mouth at all, a legibility/hygiene trade Nick may want revisited with a
purpose-built close camera the way `boulder_ram`'s open finding suggests —
but both diagnosed lines measurably improved and neither regressed the other
four, so the pass is kept. +3 total, not a plateau.

Not touched: proportion, colour, style — outside the two diagnosed lines,
per the brief.
