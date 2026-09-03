# plated_armour — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
14. Rubric defined in full in `design/progress/intangible_icon.md`; referenced,
not repeated, here. **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/plated_armour.png`
(256x256). Third of batch 14's four defensive-keyword icons.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 5 | 7 | 8 | **36** |

Pass 2: 9 | 9 | 7 | 7 | 8 | **40** — see below.

## What is actually there

Three stacked, overlapping octagon-ish plates — pale grey at the top,
mid steel-blue in the middle, darker slate at the bottom — narrow-to-wide
top-to-bottom, forming a rounded three-lobe tower. `ART-REVIEW.md` names
three rivet dots per plate; not visible at either 256px or 42px in this
render.

- **Silhouette @ 42px (7):** the three-lobe tapered-tower shape stays
  legible as a single rounded solid, and the shading bands between lobes
  are visible enough to read as segments rather than one smooth dome — but
  it reads as "three joined blobs" more readily than "three overlapping
  plates," since there's no visible edge/gap between them, only a shading
  change.
- **Family distinction (9):** the tapered three-lobe tower shares no
  silhouette family with `shield`'s kite, `guard`'s kite-plus-clock, or
  `wall`'s brick grid — confirmed at the same 42px scale. The clearest
  distinction line in this batch alongside `thorns`.
- **Mechanic match (5):** "Block that survives the round" via a lamellar
  scale reading — at 42px this reads closer to a stacked cairn, a totem, or
  a snowman than to armour plating; the rivets that might sell "plate" per
  the build note aren't visible at any size checked here. The weakest
  mechanic read of the batch.
- **Colour & contrast (7):** the grey-to-slate gradient gives real internal
  contrast between the three lobes and separates cleanly from the brown
  card standin, but it's the most desaturated icon in the batch — no accent
  colour anywhere, unlike `buffer`'s red shard or `thorns`'s green body.
- **Style consistency (8):** the stacked-solids construction matches the
  shared vocabulary other icons already use; no angle or palette
  inconsistency.

## Diagnosis — two lowest

1. **Mechanic match (5).** Concrete fix: add a visible gap or a thin dark
   line between each of the three lobes (rather than relying on shading
   alone) so the "stacked plates" read survives at 42px instead of reading
   as one smooth tapered mass.
2. **Silhouette @ 42px (7).** Concrete fix: same gap fix as above would also
   sharpen this line — the shape itself is clean, the missing piece is the
   between-plate separation.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the rivet detail `ART-REVIEW.md`'s build note describes is present
in the model but too small to survive a 256px orthographic render, or was
never built at a visible scale — this file can only confirm it isn't
visible in the shipped PNG at either size checked, not which of those is
true.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `plated_armour()`,
in-lane (icons only, no beast/portrait geometry, no shared palette or
budget constant touched). Both diagnosis lines traced to one cause, so one
geometric change addressed both, same as `intangible`'s pass 2: the old
plate centres (-0.30, -0.02, 0.26; step 0.28) at half-height 0.15 touched
with a real but tiny 0.02-unit overlap, so nothing but a shading change
told the three lobes apart. Widened the step to 0.31 (new centres -0.32,
0.0, 0.30) and shrank half-height 0.15 → 0.12, opening a real gap on each
seam — not a colour cue, the same technique `ascend`'s stacked arrowheads
and `intangible`'s spaced tiles already use in this file for the identical
symptom. Moved the three rivet dots' z-coordinates to match the new plate
centres; left everything else (widths, colours, rivet positions relative
to their own plate, bevel) untouched.

Rebuilt via apt's Blender 4.0.2, headless (`libegl1`, `libegl-mesa0`,
`libgles2`; `numpy` and `Pillow` installed into `/usr/bin/python3.12`, the
interpreter this Blender actually runs). Ran the full `icons.py` batch (no
single-icon build path exists) and diffed all 36 generated PNGs against the
committed set (mean per-pixel diff): `plated_armour.png` led at 8.51 — the
only real content change — against the next-highest `peak.png` at 6.70 and
a long tail down to 0.00, all render-noise from this apt build differing
slightly from whatever built the committed set, not this pass's doing
(every other icon's *script* was untouched). Copied only the changed
`plated_armour.png` into `game/assets/icons/`; nothing else in that folder
touched.

Verified by looking, not just by the numbers:

- **Alpha bbox** `(78, 34, 177, 226)` of 256 — real margin on all four
  sides, no clipping from the wider spread.
- **Full-render composite over the brown card standin**
  (`design/renders/plated_armour_pass2_full.png`) side by side with the old
  render composited the same way (`design/renders/plated_armour_pass1_full.png`):
  pass 1 is one continuous tapered mass with only a shading change between
  bands; pass 2 is three plainly separate rounded rectangles with real brown
  gaps between them.
- **A real 42px Pillow LANCZOS downsample**
  (`design/renders/plated_armour_pass2_42_big.png`, nearest-neighbour
  upscaled for viewing) beside the same downsample of the old pass-1 render
  (`design/renders/plated_armour_compare_42.png`): the pass-1 downsample
  still fuses into one lozenge with banding; the pass-2 downsample keeps
  three distinct blocks with a visible gap surviving the resample, at the
  exact size the icon is actually seen at.
- **A 64px solid-black silhouette recolour**
  (`design/renders/plated_armour_pass2_sil_64.png`): three separate rounded
  rectangles with clean white gaps between them, holding the same read at
  the silhouette rubric's own stated test size.
- **Pixel-sampled, not eyeballed:** alpha at both gap midpoints (128,168)
  and (128,90) reads 0 (fully transparent — real background showing
  through), against 255 at each plate's own centre — the gap is an actual
  hole in the geometry, not a lit shading trough that might vanish under a
  different light angle.

- **Silhouette @ 42px (7 → 9):** confirmed by both the 42px downsample and
  the 64px silhouette test above — three distinct blocks with a real gap,
  not fused. Not 10: the bottom plate is still noticeably wider than the
  other two, so a very fast glance could read it as "two small blocks on
  one wide base" rather than three equal plates — a real but minor
  ambiguity the gap fix didn't touch.
- **Family distinction (9, unchanged):** still the clearest line in the
  batch alongside `thorns` — nothing else in the set is three stacked,
  gapped blocks, and this pass didn't touch what makes it distinct.
- **Mechanic match (5 → 7):** three plainly separate hard-edged plates
  reads much closer to lamellar/stacked armour than pass 1's continuous
  taper, which is exactly the "cairn/totem/snowman" read the pass-1
  diagnosis named. Not higher: no new cue was added beyond spacing (no
  rivet, no seam highlight, no overlap-lip) that would let "armour"
  specifically beat a colder read like "three stacked blocks" or "a small
  totem of separate stones" — the rivets named in `ART-REVIEW.md`'s build
  note are still not visible at either size checked, unchanged from pass 1
  and outside this pass's two named fixes.
- **Colour & contrast (7, unchanged):** this pass touched only spacing, not
  the PEWTER/STEEL/SILVER gradient or the card-standin comparison — the
  gaps now showing raw background instead of a lit surface add a small
  amount of extra separation between plates, but not enough of a change to
  move the line on its own terms (still the most desaturated icon in the
  batch, no accent colour).
- **Style consistency (8, unchanged):** the stacked-solids construction is
  the same vocabulary as before; spacing the parts apart is the identical
  technique `ascend` and `intangible` already use, so nothing new entered
  the set's vocabulary.

**+4 total (36 → 40), not a plateau — kept.** No line regressed. Meets the
loop's stop condition (≥40/50) exactly — no pass 3 planned for this asset.
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — an icon geometry-only pass adds none, matching every prior
icon-only pass under this item.

## Unsure about (pass 2)

Whether the rivet detail is worth a dedicated future pass now that the
plates themselves read cleanly — Mechanic match's remaining gap (7, not
higher) is specifically the missing rivet/texture cue, but adding it was
not one of pass 1's two named fixes and this loop applies only those two.
Also unsure whether the bottom plate's extra width (the Silhouette line's
one open question) is a deliberate taper-for-mass choice worth keeping or
an accident of the original three widths (0.44/0.38/0.30) carried forward
unexamined — not touched here since neither diagnosis line named plate
width as the fix.
