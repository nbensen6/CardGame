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
