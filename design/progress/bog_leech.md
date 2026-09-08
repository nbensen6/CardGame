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

---

## Pass 3 diagnosis — #86 duty 1, 2026-09-08

Lowest-scoring beast in the cast with an unblocked (non-collided) capture —
`bog_leech` has no same-named ground, so unlike this run's other candidates
(see `sunken_warden.md` and its siblings) `bog_leech_pass2_sil.png` and
`_34.png` are genuinely the beast. No pass-3 diagnosis had been written since
the fixer applied pass 2 on 2026-08-31; scored fresh against the two
committed pass-2 views (no `_side`/`_top`/`_wire` exist for this pass) and
the anchor table added 2026-09-07, pulling real coordinates from
`tools/blender/bog_leech.py` rather than re-describing the prose.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 4 | 5 | 6 | 25 |
| 2 | 6 | 5 | 6 | 5 | 6 | 28 |
| 3 (re-score, no geometry change yet) | 5 | 4 | 6 | 5 | 6 | 26 |

- **Silhouette (6 → 5).** Computed the actual Z-spans of the four stacked
  masses from the script: main sac `ball((0,-0.05,1.05),(0.94,1.38,0.80))`
  spans z=[0.25, 1.85]; first hump `ball((0,0.15,1.95),(0.62,0.58,0.44))`
  spans z=[1.51, 2.39]. The two overlap by only 0.34 (38% of the hump's own
  0.88 diameter) — the weakest join in the whole stack. By contrast the next
  two joins overlap far more: hump1/hump2 by 0.43 (67% of hump2's 0.64
  diameter), hump2/tail-ball1 by 0.52 (100% of the tail ball's own 0.52
  diameter). The sac and different-coloured (PEWTER vs STONE) first hump
  meet at their weakest, most point-like contact, which is exactly why
  `bog_leech_pass2_sil.png` reads as a body with a ball perched on it rather
  than one mass with a stepped back — the anchor table's 6–7 band asks for
  masses that "flow into each other," and a 39%-diameter kiss between two
  different-coloured balls doesn't clear that bar.
- **Proportion (5 → 4).** The doc calls for "two fed-fat body-segments
  stepping up its back... a raised tail-sac" — three distinct ideas. The
  actual half-extents taper smoothly instead: first hump height 0.88, second
  hump (`ball((0,0.62,2.28),(0.44,0.38,0.32))`) height 0.64 (73% of hump1),
  tail-ball-1 height 0.52 (81% of hump2), tail-ball-2 height 0.32 (62% of
  ball1). Four balls each roughly three-quarters the height of the last is
  one continuous cone, not "two matched segments, then a separate smaller
  sac" — there is no size break anywhere in the stack for the eye to read as
  "segment pair ends here."

## Diagnosis — two lowest (pass 3)

1. **Silhouette (5).** Concrete fix: drop the first hump's Z centre from
   1.95 to about 1.80 (no change to its (0.62,0.58,0.44) radii). New span
   [1.36, 2.24] overlaps the sac's [0.25,1.85] by 0.49 — 56% of the hump's
   diameter, in line with the 67%/100% joins that already read well — so the
   hump reads as emerging from the sac instead of resting on it. Same
   precedent as `clot_toad.md` pass 3: `shelf(2, ...)`'s hold height comes
   from the climb contract via `z_for()`, not from the ball it decorates, so
   moving the ball alone shouldn't move the Height-2 hold.
2. **Proportion (4).** Concrete fix: enlarge the second hump's radii toward
   the first hump's — Y 0.38 → 0.50, Z 0.32 → 0.40 (height 0.64 → 0.80, 91%
   of hump1's 0.88, a matched pair) — and leave both tail-sac balls
   untouched, so the stack reads as [big hump][near-twin big hump] then a
   visibly smaller tail-sac, instead of one smooth four-step taper. As with
   the silhouette fix, `shelf(4, ...)` reads its own hold height from the
   contract, not the ball's radius.

Not applying either — this is a diagnosis pass, not a repair; the fixer
(`tools/fixer/BRIEF.md`) owns `tools/blender/bog_leech.py`.

## Unsure about (pass 3)

Whether burying the first hump 56%-deep into the main sac leaves enough of
it visible above the sac's own surface to still read as a "step" at all
once actually rendered — the arithmetic says the overlap fraction matches
the other two joins, but I have no way to render this without a screen, and
a fix that measures right can still look wrong (see `clot_toad.md` pass 2's
own "not fully separated" note on a similarly-reasoned change). Also
unsure whether resizing the second hump changes its own sigil-adjacency —
`bog_leech` is not one of backlog #88's five flagged sigil-occlusion beasts,
but nobody has re-checked that since this pass's proposed resize, and #88
is explicitly `needs a screen`.

---

## Pass 4 — fixer lane, 2026-09-08

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`). Both pass-3 fixes
applied exactly as measured, together, since they're the same visual unit
(the back-hump stack). Views: `design/renders/bog_leech_pass4_*.png`,
captured with `look.cmd bog_leech 4` against `bog_leech_pass3_*.png` (the
freshly re-captured, geometry-unchanged baseline from the naming-collision
fix, not the older pass2 set).

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 4 | 5 | 6 | 25 |
| 2 | 6 | 5 | 6 | 5 | 6 | 28 |
| 3 (re-score, no geometry change) | 5 | 4 | 6 | 5 | 6 | 26 |
| 4 | 6 | 6 | 6 | 5 | 6 | 29 |

- **Silhouette (5 → 6).** `bog_leech.py`: first hump Z centre `1.95 → 1.80`,
  radii untouched. `HOLD hold Height 2` still reports `ok` after rebuild —
  the shelf reads its height off the climb contract, not the ball, exactly
  as pass 3 predicted. Diffed `bog_leech_pass3_sil.png` against
  `_pass4_sil.png` pixel-for-pixel (`ImageChops.difference`, bbox
  `(98,41)-(183,110)`): the change is real but small — the former
  hump1/hump2 step at the silhouette's top-right now rounds into one
  continuous curve instead of a squared shelf-like notch. Real improvement,
  not a plateau-hiding non-change, but modest: the two masses read as
  closer to "flowing into each other" without fully clearing the 6–7 band's
  bar.
- **Proportion (4 → 6).** Second hump radii Y `0.38 → 0.50`, Z `0.32 →
  0.40` (height 0.64 → 0.80, now 91% of hump1's 0.88 vs 73% before).
  `bog_leech_pass4_34.png` and `_front.png` against the pass-3 equivalents:
  the two back humps now read as a near-matched pair before the visibly
  smaller tail-sac, closer to the doc's "two fed-fat body-segments...a
  raised tail-sac" than pass 3's smooth four-step taper. Not pushed to 7+
  since the first hump/main-sac join (the silhouette finding above) still
  keeps the whole stack reading a little perched rather than fully grown
  out of the body.

Both diagnosed lines moved (+1 each, +3 total) and neither of the other
three regressed — kept. `run_tests.gd`: ALL TESTS PASSED.

Not touched: hygiene, colour, style — outside the two diagnosed lines, per
the brief.

## Unsure about (pass 4)

Whether the sigil crest and its bridge (`tools/blender/bog_leech.py`
lines 97-104, anchored at `y=-0.30`/`z=2.32`, independent of the two humps
just moved) still clear the now-larger second hump from every angle —
`bog_leech_pass4_top.png` shows the sigil disc sitting clear of both humps
from above, but nobody has re-measured the gap numerically. Also: at 29/50
this asset is 4 passes in (1 initial, 2 and 4 applied, 3 a re-score) and
still 15 points under the beast stop line of 44 — the remaining low lines
(Colour 5, Hygiene 6, Style 6) haven't had a pass since pass 2, and the
next diagnosis should probably look there rather than the back-hump stack
again.
