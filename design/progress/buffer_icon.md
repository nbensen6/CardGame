# buffer — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
14. Rubric defined in full in `design/progress/intangible_icon.md`; referenced,
not repeated, here. **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/buffer.png` (256x256).
Second of batch 14's four defensive-keyword icons.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 6 | 7 | 8 | **38** |

## What is actually there

A hexagonal (six-sided, not round) steel-blue ring with a small white orb at
its centre, and a red triangular shard breaking off the ring's top-right
edge as if just knocked loose.

- **Silhouette @ 42px (8):** the hexagon ring, the red shard, and the centre
  dot all stay individually legible at 42px — the cleanest three-part read
  of this batch. Minor: the ring's own line weight thins enough at 42px that
  the hexagon's corners round off slightly, reading a touch closer to an
  octagon than a hex.
- **Family distinction (9):** a ring silhouette (hollow centre) is
  immediately different from `shield`'s and `guard`'s solid kite shapes and
  `wall`'s solid brick grid — confirmed at the same 42px scale side by side.
  The hex-not-round choice `ART-REVIEW.md` names as deliberate (so it can't
  be mistaken for `guard`'s ring) holds up; nothing else in the family has a
  hollow polygon silhouette.
- **Mechanic match (6):** "the next hit is cancelled outright" — a shard
  visibly breaking off the ring's edge is a reasonable "deflected" reading,
  but at 42px it reads about as easily as a small flag or pennant flying
  off a badge, which doesn't obviously say "cancelled." Matches
  `ART-REVIEW.md`'s own stated uncertainty on this exact point.
- **Colour & contrast (7):** the steel-blue ring separates cleanly from the
  brown card standin; the red shard is the strongest colour accent in the
  batch and reads instantly; the white centre dot is small but bright
  enough to stay visible at 42px.
- **Style consistency (8):** ring-plus-accent construction matches the
  shared "outline badge" vocabulary other icons in the set use (`target`,
  `expose`); no inconsistency in angle or palette family.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: none proposed that doesn't touch
   geometry Nick would need to weigh in on — the shard-off-a-ring metaphor
   is inherently a step removed from "cancelled hit" and closing that gap
   probably means a different visual idea (e.g. an X or a strike-through)
   rather than a tweak to this one.
2. **Silhouette @ 42px (8, tied-lowest-of-the-strong-lines).** Concrete fix:
   thicken the hexagon ring's line weight by roughly a fifth so the six
   corners stay distinct from a rounded octagon at 42px.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the red shard reads as "the hit that got cancelled" (the intended
story per `ART-REVIEW.md`) or just as "a stray triangle" to someone seeing
it cold — this comparison confirms the shape is legible, not that the
metaphor lands.
