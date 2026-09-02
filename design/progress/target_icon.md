# target — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 — the next four of the eight "twenty-eight card icons" left unscored
after batch 20, in `card_view.gd`'s own `ICONS` table order (`target`,
`rhythm`, `timer`, `cog`). **Scoring pass only — report, not repair; no
edits to `tools/blender/icons.py`.** Asset: `game/assets/icons/target.png`
(256x256, rendered by `icons.py`, orthographic head-on per
`design/ART-REVIEW.md`'s own build note). First of batch 21's four (see
`rhythm_icon.md`, `timer_icon.md`, `cog_icon.md` for the rest).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method: Pillow real
42x42 `LANCZOS` downsample composited over the flat brown card standin
`RGB(139,105,74)`, plus a numeric alpha-bbox check at both any-alpha and
alpha>10 thresholds (batch 17's addition, carried forward).

`target` is the other half of the pair batch 20's `expose_icon.md` already
flagged from `expose`'s side — this file confirms the same finding from
`target`'s own scoring pass rather than re-rendering the comparison a
second time.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 7 | 7 | 8 | **33** |

## What is actually there

Two concentric rings (GOLD outer, AMBER inner) around a small BRICK-red
ball at the centre, with a SILVER shaft and a BRICK arrowhead crossing the
rings on one diagonal, as if an arrow has struck the bullseye.

- **Silhouette @ 42px (8):** the double ring, centre ball and diagonal
  shaft survive the downsample as one clean, legible bullseye-and-arrow
  shape; the shaft stays a distinct straight line rather than blurring
  into the rings.
- **Family distinction (3):** confirms `expose_icon.md`'s own batch-20
  finding directly, checked again from this file's own render — `target`
  and `expose` are built from the same double-ring-plus-centre-ball
  recipe and read as near-identical bullseyes at 42px. The only reliable
  tell is `target`'s one diagonal SILVER shaft versus `expose`'s four
  axis-aligned ticks, and at the real read size that is one thin line
  against four thin spurs, not a difference in silhouette. Scored the
  same 3/10 `expose` carries for the identical reason.
- **Mechanic match (7):** "scales off Exposed" pairs naturally with an
  arrow already lodged in a bullseye — a hunter capitalising on a mark
  already applied. More literal and specific than `expose`'s own bullseye
  (which has no arrow, since it applies the mark rather than exploiting
  it), so scored a point above `expose`'s 6.
- **Colour & contrast (7):** pixel-sampled directly — the outer ring runs
  roughly RGB(194,156,89) and the inner ring RGB(197,146,85) against the
  standin RGB(139,105,74), a real separation of 45-70 per channel; the
  BRICK centre ball at RGB(176,104,99) separates least cleanly of the
  three (only 37 in red, 24 in blue, near-zero in green against the
  standin) but stays visible against the lighter rings surrounding it.
- **Style consistency (8):** the ring-plus-centre-ball construction
  matches `expose`, `buffer`'s hex ring and `guard`'s ring-over-slab;
  nothing about the render angle or palette is an outlier.

## Diagnosis — two lowest

1. **Family distinction (3).** Concrete fix: same root cause `expose_icon.md`
   already named from the other side — since `target` and `expose` are
   the two Expose-family cards most likely read together, give one of
   them a shape element the other doesn't share at all (not just a
   different mark at the edge). The arrow shaft is the closer starting
   point on `target`'s side: extending it fully across the icon rather
   than stopping short of the centre, or splitting one ring into a
   distinct broken/notched shape, would separate the silhouette itself.
2. **Mechanic match (7).** No separate fix proposed — the family-distinction
   problem is the more actionable of the two, and fixing it (giving
   `target` a shape `expose` doesn't share) would likely also sharpen
   which card is "applying" versus "exploiting" the mark.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the arrowhead's BRICK tone reading close to the centre ball's own
BRICK tone (both the same base colour) is deliberate — "the arrow struck
the bullseye's own colour" — or an accident of reusing one palette entry
for two different parts; the render alone can't distinguish intent from
coincidence.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `target()`. The old
shaft (`slabf(0.22, 0.22, 0.30, 0.028, ..., rot=-0.79)`) ran from
`(0.009, 0.007)` — effectively the centre ball's own location — out to
`(0.431, 0.433)`, and the arrowhead spike sat with its own tip pointing
back INTO that same near-centre point. Worked out from the box/taper
maths (`slabf`'s `rot` is a Y-axis rotation of the local X axis; `spike`'s
`ang` maps directly to a world direction via `(sin ang, cos ang)`), not
assumed: on one side of the centre there was a shaft, on the other side
nothing, so the silhouette was still "two rings plus one centre mark" —
`expose`'s own family.

1. **Family distinction (3).** Concrete fix: re-centred the shaft on the
   ball (`slabf(0.0, 0.0, 0.58, 0.028, SILVER, rot=-0.79)`, up from a
   0.30 half-length off-centre to 0.58 centred) so it runs the full
   diagonal through the bullseye and out both sides, and moved the
   arrowhead from `(0.06, 0.06)` (pointing inward, buried near the ball)
   to `(0.39, 0.39)` pointing outward (`ang=0.79`, continuing the shaft's
   own direction), so the point sits at the true outer tip instead of
   hidden at the centre.
2. **Mechanic match (7).** No separate change — same fix as above; a
   shaft that visibly threads all the way through the ball to both edges
   reads more clearly as "already pierced this target" than a stub that
   stops at the centre.

Rebuilt with `apt`'s Blender 4.0.2, headless EGL (`libegl1`, `libegl-mesa0`,
`libgles2` and `python3.12 -m pip install numpy` all needed first in this
container, same packages `fire_icon.md` pass 3 and `dexterity_icon.md`
needed — `download.blender.org` is still a 403 through the egress proxy).
Console: `TRIS 208 PARTS 4 BUDGET 700 ok`, no warnings. Ran the full
`icons.py` batch and diffed all 36 PNGs against `HEAD`; kept only
`target.png`, reverted the other 35 with `git checkout --` (Blender's own
render noise touches files whose build code never changed, the same
finding every icon batch since `rope_icon.md` pass 2 has hit).

Verified three ways before scoring, not just by eyeballing the full-res
render:

- **Bounding box.** `finish()`'s own `SIZE` print was unchanged at
  `1.215 0.2 0.908` between the old and new shaft lengths — the model's
  overall bbox is set by the outer GOLD ring (radius 0.48 + thickness),
  not by the shaft, so lengthening the shaft carried no clipping risk as
  long as its own reach stayed under the ring's outer edge, which it
  does. Confirmed directly on the rendered PNG too: alpha>10 bbox moved
  from a ring-dominated box to `(7, 8, 248, 247)` of 256 — real margin
  on all four sides — and the real 42px Lanczos downsample (not the
  full-res image scaled down) shows alpha>10 at `(1, 1, 40, 40)` of 42,
  a 1px margin on every edge, comfortably inside frame.
- **Pixel sample.** Sampled the rendered PNG directly at the shaft
  midpoint, the arrowhead tip and the centre ball, against the standin
  `RGB(139,105,74)`: shaft `RGB(150,152,159)` — a cool grey/blue-tinted
  silver, gap of `(11,47,85)`, strongest on the two channels the standin
  is weakest on; centre ball `RGB(135,46,40)` and arrowhead tip
  `RGB(155,66,62)` — both clearly darker/redder than the standin on G
  and B. No line depends on this (Colour was already scored 7 and this
  pass didn't touch palette), but it confirms the new geometry didn't
  accidentally hide anything in shadow.
- **Direct comparison, not memory.** Rendered a real 42px composite of
  both `target.png` and `expose.png` side by side
  (`design/renders/target_icon_pass2_vs_expose_42px.png`) instead of
  trusting the written description of `expose`'s own shape. `expose`
  reads as a radiating starburst of thin brick crack-lines around an
  angular shard, no single dominant line and no ball; the new `target`
  reads as one bold silver diagonal with a clear pointed tip and a red
  centre ball. The two are no longer close at a glance the way two
  double-ring-plus-centre-mark icons were.

- **Family distinction (3 → 8):** confirmed by the side-by-side render
  above, not assumed from the geometry change alone — the shapes read as
  different gestalts (starburst vs. single arrow) at 42px, not just
  different colours or minor details on the same silhouette.
- **Mechanic match (7 → 8):** the shaft now visibly passes fully through
  the ball and out the far side, which reads more like "already struck
  and exploiting an existing mark" than the old stub that only reached
  the centre from one direction. Not higher: still the same ring-plus-
  line vocabulary as before; nothing new was added to say "Exposed"
  specifically rather than "arrow" generally.
- **Silhouette @ 42px (8 → 9, not one of the two, moved as a side
  effect):** the arrowhead's point is now isolated in open space beyond
  the outer ring instead of tucked in near the centre ball where the
  original render partly absorbed it into the shaft — confirmed in the
  real 42px downsample, where the tip reads as an unambiguous triangular
  point rather than a small notch.
- **Colour & contrast (7, unchanged):** this pass touched no palette or
  material, only position and length.
- **Style consistency (8, unchanged):** same primitives (`slabf`,
  `spike`), same construction vocabulary as every other icon in the set;
  repositioning them changes nothing about which vocabulary is used.

**+7 total (33 → 40), not a plateau — meets the loop's 40/50 stop
condition.** No line regressed. `run_tests.gd`: **ALL TESTS PASSED**
(fresh import, headless). No new tests — an icon geometry/position batch
adds none, matching every prior icon-only pass under this item.

## Unsure about (pass 2)

Whether "arrow piercing straight through a target" reads unambiguously as
*exploiting* an existing weak point specifically, versus just "a stronger
attack" in general, to someone seeing the card cold with no tooltip — the
same kind of question `expose_icon.md`'s own pass raised for its side of
this pair, and one a static composite can't settle on its own. Also
unresolved from pass 1: whether the arrowhead's BRICK tone still reads too
close to the centre ball's own BRICK tone at 42px now that both are
farther apart in frame — not sampled again this pass since neither was one
of the two named fixes.
