# dexterity — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 17 — continuing the icon rubric batches 14-16 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/dexterity.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 17's four — see `design/progress/strength_icon.md` for the pair
this section of `ART-REVIEW.md` names together.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample and alpha-bbox method as `strength_icon.md`
(this batch) and batches 14-16.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 8 | 5 | 8 | 8 | **35** |

## What is actually there

A single soft-edged blue-grey oval (two overlapping tones, ICE over SKY, the
"vane" the build comment names) standing upright, crossed by four thin pale
diagonal grooves. Alpha bbox `(60, 0, 194, 255)`: both the top and bottom
rows are fully opaque — the vane's top touches the canvas ceiling and the
quill (a thin spike meant to poke through both ends per the build comment)
is invisible in the render, cropped off at the bottom edge with nothing
visible below the oval body.

- **Silhouette @ 42px (6):** the oval-with-diagonal-stripes shape survives
  the downsample as a clean, simple silhouette, but it reads as generically
  oval rather than specifically feather-shaped — nothing in the outline
  itself (as opposed to the diagonal grooves, which are a texture detail)
  signals "feather" over "leaf," "guitar pick," or "loaf of bread," all of
  which share the same rounded-oval-with-a-point outline.
- **Family distinction (8):** no other icon in the 36-icon set is a blue
  oval; clearly distinct by shape and colour from `strength`'s dumbbell and
  from everything else scored so far under this item.
- **Mechanic match (5):** confirms `ART-REVIEW.md`'s own stated doubt
  directly — the shape is confidently "not confusable with anything else,"
  which is the bar `ART-REVIEW.md` set for this line, but not confidently
  "a feather," which is the bar Dexterity actually needs. The diagonal
  grooves that are meant to read as barb texture are visible at 256px but
  compress into faint, ambiguous streaks at 42px that could as easily be
  read as fabric folds or wood grain as feather barbs.
- **Colour & contrast (8):** the blue-grey vane reads clearly against the
  brown card standin — the strongest warm/cool contrast pairing scored
  under this item, matching `strength`'s equally clear (if less colourful)
  separation in the same batch.
- **Style consistency (8):** the two-tone overlapping-ball shading matches
  the construction `flask`'s own body already uses per the build comment;
  nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (5).** Concrete fix: taper the oval's top to an actual
   point rather than a rounded arc (the current top edge reads as an
   ellipse tip, not a feather's natural taper), and lengthen the visible
   quill past the vane's own edge instead of letting it clip off-canvas —
   a quill that actually shows, even briefly, would do more to say
   "feather" than another texture pass on the barb grooves.
2. **Silhouette @ 42px (6).** Concrete fix: the same top-taper change would
   likely lift this line too, since the outline carries the whole
   silhouette read at 42px and the texture grooves already fade to near
   nothing at that size regardless of any texture-level fix.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The quill "poking through both ends," per the build comment, is not visible
at either end in this render at all — the alpha bbox shows the bottom row
fully opaque, meaning something reaches the very bottom edge, but nothing
below the oval body is visible as a distinct quill shape; whether that is
the quill clipped flush against the canvas edge (the same pattern this
batch's own `rally`/`strength` and batch 16's other icons show) or the
quill rendering directly behind the vane's own opaque body from this camera
angle is not something a single orthographic render can distinguish. Also
unsure whether "reads as a feather, not just as an unidentified blue oval"
is a bar this icon can clear at all without a genuinely spiked/pointed
outline, versus needing the tooltip to carry that meaning the way
`ART-REVIEW.md`'s own text already allows for the strength icon's cleaner
case.

## Pass 2 — cloud, backlog #86 duty 1

Confirmed by pixel math rather than guessing why the quill never showed:
`spike(x, z, r0, r1, length)` centres its taper at `z`, so the old
`i.spike(0.0, -0.58, 0.020, 0.006, 1.20, TAN, seg=4)` spanned world z
`-1.18` (thick base) to `0.02` (thin tip) — the thin end landed *inside*
the vane's own body (the SKY ball's centre sits at `z=0.02`, radius
`0.56`), not past its top, and the thick end sat almost entirely below the
camera's `±0.575` ortho frame (`FRAME=1.15`), which is why pass 1 found
only a faint sliver reaching the bottom edge and nothing above the vane at
all — the quill was never built to poke through both ends, only to stop
short inside one of them.

Applied both named lines with one shared change to the vane's silhouette
plus a corrected quill span:

1. **Silhouette @ 42px (6).** The vane's two balls kept their `x`/`y`
   radii and centres but had their `z` radius cut from `0.56`→`0.364` and
   `0.52`→`0.338` (same 0.65 ratio on both, so the two-tone joint is
   unchanged) to make room for a capping taper: `i.spike(0.0, 0.40, 0.21,
   0.01, 0.24, SKY, seg=6)`, based one radius-width (`0.21`, the SKY
   ellipsoid's own radius at `z=0.28` by
   `rx*sqrt(1-((z-cz)/rz)^2)=0.30*sqrt(1-(0.26/0.364)^2)=0.21`) onto the
   ball's surface at `z=0.28` and narrowing to `0.01` at `z=0.52`, well
   inside the `0.575` edge. A straight-sided cone reads as a point where an
   ellipsoid's pole only ever reads as a rounded dome.
2. **Mechanic match (5).** Rebuilt the quill as one taper spanning the
   whole figure: `i.spike(0.0, 0.04, 0.020, 0.006, 1.00, TAN, seg=4)` runs
   from `z=-0.46` (thick end, `0.116` below the vane's own new base at
   `-0.344`) to `z=0.54` (thin end, `0.02` above the new point's own tip at
   `0.52`) — visibly past both the vane and the point now, both ends still
   inside the `±0.575` frame with margin.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless; `download.blender.org`
unreachable through this container's proxy, same fallback prior duty-1
passes used; needed `libegl1`/`libgles2` and `pip install numpy pillow`
into the `/usr/bin/python3.12` Blender's `bpy` actually runs, neither
present before this pass). Console: `TRIS ... PARTS ... BUDGET 700 ok`, no
warnings. Diffed all 36 icons against `HEAD` by mean per-channel pixel
difference: every icon except `dexterity.png` came back at mean ≤ 6.70
(the same WORKBENCH render-noise band `fire_icon.md`/`rally_icon.md`'s
passes used to draw this line), `dexterity.png` at mean 16.46 — clearly
content, not noise. Reverted the other 35, kept only `dexterity.png`.

Looked at it three ways, same method as `fire_icon.md`/`rally_icon.md`:
the full 256px composite over the brown card-face standin
(`design/renders/dexterity_icon_pass2_full.png`, vs a same-method render
of the committed `HEAD` blob kept alongside it for the side-by-side), a
real 42px Lanczos downsample nearest-neighbour upscaled for viewing
(`..._pass2_42px_big.png`), and a pure black-on-white alpha silhouette
(`..._pass2_sil.png`), plus a 4× zoom crop on the new point's tip
(`..._pass2_topzoom.png`) to check the quill's top end specifically.

- **Silhouette @ 42px (6 → 8):** the 42px composite and the silhouette
  crop both show a teardrop/leaf outline — a straight-sided point at top,
  a rounded body, a thin quill stem at bottom — where pass 1 was a plain
  rounded oval. Not higher: the body itself is still a simple rounded
  mass: the point and stem are the only two features carrying the read.
- **Family distinction (8, unchanged):** still the only icon in the set
  with this outline; the new shape is if anything more specific, but the
  rubric doesn't separately reward that.
- **Mechanic match (5 → 7):** the point plus the visible quill stem
  sticking out below the body reads far more specifically as "a feather"
  than pass 1's ambiguous oval — confirmed at both 256px and the 42px
  downsample. Not higher: the top zoom crop shows the quill's thin tip
  does poke a couple of pixels past the point (`..._pass2_topzoom.png`),
  matching the build comment's "poking through both ends," but it is far
  too small to survive the 42px downsample — only the bottom stem reads
  at that size, so the "poking through both ends" idea only half survives
  to the size the card panel actually draws at.
- **Colour & contrast (8, unchanged):** this pass touched no palette —
  same SKY/ICE/TAN as pass 1.
- **Style consistency (8, unchanged):** the new point reuses the existing
  `spike()`/taper primitive every other icon already uses (e.g. `fire`'s
  cones, `rally`'s bell); no new build vocabulary.

**+4 total (35 → 39), not a plateau — kept.** No line regressed. Below the
40/50 stop line; 2 of 4 passes used.

`run_tests.gd`: ALL TESTS PASSED (fresh `--import`, headless, Godot 4.7.1).

## Unsure about (pass 2)

Whether a third pass shortening the vane's rounded body further (so more
of the silhouette's height is the point rather than the oval mass) would
help Silhouette and Mechanic more than it costs Family distinction by
making the shape read as a plain triangle — a size trade this pass's two
named fixes didn't ask for and didn't touch. Also unsure whether the
quill's top tip is worth enlarging in a future pass specifically so it
survives the 42px downsample, or whether a single visible stem (the
bottom one) already clears the bar this line needs.

## Pass 3 — cloud, backlog #86 duty 1

Tried the pass 2 "unsure about" question first, since it was the more
speculative of the two and the cheaper one to rule out. A standalone trial
script (not `icons.py`, so it renders one variant in a couple of seconds
instead of the full 36-icon batch) reproduced the vane/point/quill build
exactly — a `dexterity.png` from it diffed against a real `icons.py` build
at mean 0.0035/max 40 (WORKBENCH noise band), confirming the trial is
faithful before trusting any of its output.

**Trial 1 — shorten the vane, lengthen the point (reverted).** Cut both
vane balls' `z` radius by the same 0.75 ratio pass 2's own 0.65 cut used
(`0.364→0.273`, `0.338→0.2535`), dropped the shared centre from `z=0.02` to
`z=-0.10` to keep the now-longer point inside the `±0.575` ortho frame, and
stretched the tip taper from `length=0.24` to `0.45` (recomputing its base
radius off the ball's own surface at the same 0.714 height-fraction pass 2
used, which lands on the same `r0=0.21` pass 2 already found — the fraction
cancels the ball's own size out). Rendered and looked
(`design/renders/dexterity_icon_pass3_trial1_*` — not committed, reverted
with everything else this trial touched): the body reads rounder, not more
oval, because only the `z` radius shrank while `x` (`0.30`) stayed fixed —
a wider-looking ball under a long straight cone reads as an onion dome or a
water balloon, not a feather, which is a worse Mechanic-match read than
pass 2's plain teardrop, not a better one. This is exactly the risk pass
2's own "Unsure about" section named before trying it. Not applied.

**Trial 2 — widen and extend the quill instead (applied).** The build
comment already claimed the quill "pokes past both the point and the
vane's base," but pass 2's own numbers show it barely does: the thin end
was `r1=0.006`, thin enough to disappear into the point's own taper by
eye, and the "Unsure about" section flagged this exact gap. Left the vane
and point untouched and widened the quill's thin end to `0.018` (still
much thinner than the `0.020` thick end, so it stays a taper, not a rod),
pushing the point-side end from `0.02` past the tip to `0.05` past it so
the wider sliver has room to clear the point's own taper before the frame
edge: `i.spike(0.0, 0.04, 0.020, 0.006, 1.00, TAN, seg=4)` →
`i.spike(0.0, 0.055, 0.020, 0.018, 1.03, TAN, seg=4)`. A `0.028` thin end
was also tried and rejected — thick enough that the top blurred into the
point's own taper instead of reading as a distinct shaft, the opposite of
what the fix wants. `0.018` was the widest that still read as a separate
sliver against the point.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless). Console: `TRIS 544
PARTS 8 BUDGET 700 ok`, no warnings for `dexterity`. Diffed all 36 icons
against `HEAD` by mean per-channel pixel difference: every icon except
`dexterity.png` fell in the same ≤6.70 WORKBENCH noise band prior
duty-1/fixer passes established (`strength.png` 5.635 the highest of the
batch, unrelated to this change), `dexterity.png` at only 0.161 — low
because the changed pixels are a thin line across a 256×256 canvas, not
because nothing changed; confirmed by re-rendering the actual committed
`game/assets/icons/dexterity.png` through the same 42px/silhouette/topzoom
views used below and seeing the new sliver directly. Reverted the other 35
icons with `git checkout --`, kept only `dexterity.png`.

Verified by looking, not just the diff number:

- **Full 256px composite** over the brown card-face standin
  (`design/renders/dexterity_icon_pass3_full.png` vs `..._pass2_full.png`):
  pass 2 shows the point's own tip as the topmost thing in frame with the
  quill only visible below the vane; pass 3 shows a thin tan sliver poking
  out past the point's tip as well, with clear background margin around it
  (a top-edge zoom crop, `..._pass3_topzoom.png`, confirms the sliver has
  real alpha margin above it, not a clip against the canvas edge — row 0
  carries only a 3-of-255 antialiasing fringe, row 1 is already 199/255).
- **A real 42px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, same brown-standin composite,
  `..._pass3_42px_big.png` vs `..._pass2_42px_big.png`): the new sliver
  survives the downsample as a thin vertical line running through both
  ends of the oval — a "shaft piercing a vane" read that pass 2's version,
  where the quill only showed below, didn't have.

Score:

- **Silhouette @ 42px (8 → 9):** the through-line is a genuine new
  silhouette feature at 42px, not just a texture detail that fades at
  distance — confirmed in the downsample comparison above. Not a 10: the
  body outline is still a plain oval-with-point: one line through it
  doesn't make the outline itself feather-shaped.
- **Mechanic match (7 → 8):** a shaft visibly piercing both ends of the
  vane is a specific "feather" cue (a quill through a plume) that a bare
  oval-with-point doesn't carry, matching the build comment's own original
  intent for the first time. Not a 9-10: no barb split, still a smooth
  solid body rather than two separated lobes either side of the shaft.
- **Family distinction (8, unchanged):** still the only oval-with-point
  shape in the set; the new sliver makes it more distinct, not less, but
  the rubric doesn't separately reward that.
- **Colour & contrast (8, unchanged):** no palette touched this pass.
- **Style consistency (8, unchanged):** the widened quill reuses the same
  `spike` taper every other icon in this file already builds with; no new
  vocabulary.

**+2 total (39 → 41), not a plateau — crosses the loop's 40/50 stop line.**
No line regressed. Three of four passes used.

`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless, Godot
4.7.1, Blender 4.0.2 apt install). No new tests — an icon-geometry-only
change, same as every prior icon pass under this item.

## Unsure about (pass 3)

Whether the shaft would read even more clearly as a quill with two full
barb-lobes either side (an actual split down the centre) rather than one
solid vane crossed by diagonal grooves — that's real new geometry, not a
parameter nudge on the existing build, and out of this pass's two-fix
budget. Also unsure whether Trial 1's core idea (more of the height being
"point," less "oval") could still help if paired with a genuinely
elongated vane (narrower `x`, not just shorter `z`) rather than the
uniform-`z`-shrink this pass tried and rejected — not attempted, since
that is a proportion change to the whole body, not one of the two named
lines.
