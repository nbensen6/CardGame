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

## Pass 2 — cloud, backlog #86 duty 1

Of the two named lines, only **Silhouette @ 42px (8)** had a fix that stays
in `icons.py` without touching anything Nick would need to weigh in on —
**Mechanic match (6)**'s fix was explicitly "none proposed that doesn't
touch geometry Nick would need to weigh in on," so left untouched, same as
every prior pass under this item that hit a design-level rather than a
technical fix.

Applied the named concrete fix exactly: thickened the outer hex ring's
torus tube from `thickness=0.11` to `thickness=0.13` (+18%, "roughly a
fifth") in `buffer()`. The inner ICE ring and every other primitive in the
function are untouched.

Rebuilt the full 36-icon set twice (apt's Blender 4.0.2, headless, EGL —
`icons.py`'s `main()` always builds the whole `ICONS` list, there is no
per-icon build) to two scratch directories and diffed all 36 PNGs
pixel-by-pixel (Pillow `ImageChops.difference`): every icon *other than*
`buffer.png` came back byte-identical (mean/max diff 0 — unlike some prior
passes, this render hit no WORKBENCH non-determinism), and `buffer.png`
alone changed (mean 4.69, max 251). Copied only the changed `buffer.png`
into `game/assets/icons/`.

Alpha bbox (Pillow, >10 threshold) moved from `(29, 34, 234, 214)` to
`(27, 34, 234, 216)` on the 256×256 canvas — 2px wider/taller from the
thicker tube, still with real margin on all four sides; no clipping risk.

Looked at three renders per pass (full 256px composite over the
`RGB(139,105,74)` card-face standin, a real 42px Lanczos downsample
nearest-neighbour upscaled for viewing, and a black-on-white alpha
silhouette), pass 1 vs pass 2 side by side:

- **Silhouette @ 42px (8 → 9):** the outer ring's six corners are visibly
  sharper and more distinct in both the 42px downsample and the
  silhouette crop — pass 1's corners had already started softening toward
  round at that thickness; pass 2's thicker tube keeps each facet reading
  as a flat edge rather than blending into its neighbour. Not a 10: the
  ring is still built from only 6 major segments, so at any thickness the
  corners are approximations of a hex rather than sharp mitred joins —
  a torus's corner is inherently a rounded turn, just a less-rounded one
  now.
- **Mechanic match (6, unchanged):** not one of the two applied fixes;
  the shard-off-a-ring metaphor is unchanged.
- **Family distinction (9, unchanged):** ring silhouette vs. the rest of
  the defensive-keyword set is untouched by a thickness change.
- **Colour & contrast (7, unchanged):** same palette, same shading setup.
- **Style consistency (8, unchanged):** still the same ring-plus-accent
  vocabulary; thickening one existing torus's tube doesn't add a new
  primitive.

**+1 total (38 → 39), not a plateau — kept.** No line regressed. Below the
loop's 40/50 stop line; the other named fix (Mechanic match) is Nick's
call, not this lane's to invent a new visual idea for.

`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — an icon-geometry-parameter-only pass adds none, matching every
prior icon-only pass under this item.

## Unsure about (pass 2)

Whether a fourth pass targeting Mechanic match (now the sole lowest line)
is worth it without a genuinely different visual idea (an X, a
strike-through, a caught-projectile shape) — this lane's own diagnosis in
pass 1 already concluded the shard metaphor itself, not a technical
tweak, is what's holding that line back, which is Nick's call rather than
something to guess at unsupervised.
