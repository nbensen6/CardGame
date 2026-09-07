# gadget — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
19 — continuing the icon rubric batches 14-18 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/gadget.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Third of batch 19's
four (see `flask_icon.md` for the batch's scope and shared rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-18 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 5 | 7 | 8 | **36** |

## What is actually there

Three stacked steel/pewter slabs (wide top, narrower middle, wide bottom),
two thin carrot-orange spikes angled outward from the top slab like
antennae, and a carrot-orange ball riveted to the centre of the middle slab.

- **Silhouette @ 42px (7):** the three-tier stack stays legible as three
  distinct horizontal bands even compressed, and the two top spikes and
  centre rivet all survive the downsample as visible marks rather than
  vanishing. Docked because the overall shape reads as a generic blocky
  totem/idol rather than anything specifically mechanical — nothing in the
  silhouette itself (as opposed to colour) signals "device."
- **Family distinction (9):** nothing else scored under this item is a
  three-tier horizontal slab stack — clearly apart from `flask`/`bomb`
  (this same batch, both round-bodied) and everything scored in earlier
  batches.
- **Mechanic match (5):** the lowest line in this batch, and the reason
  for the batch's lowest total. `card_view.gd`'s comment reads "the
  Engineer builds," but a stack of grey plates with one orange rivet does
  not, on its own, suggest *building* or *construction* as an action —
  cold, without the tooltip, it reads as plausibly a small robot torso, a
  trophy, or a totem as it does "a gadget." `ART-REVIEW.md` names this
  exact risk for a neighbouring icon (`plated_armour` "reads as a cairn or
  totem"); `gadget` hits the same failure mode independently.
- **Colour & contrast (7):** pixel-sampled directly: the steel slabs range
  RGB(106,116,136) to RGB(198,163,173) against the card standin
  RGB(139,105,74) — real separation from the cool-grey hue alone, plus the
  two orange accents (spikes, rivet, roughly RGB(190,126,80)) add a second,
  warmer contrast point. Docked because the two antenna spikes are thin
  enough (a few pixels at 256px) that they read closer to hairline marks
  than solid shapes once downsampled, even though they remain visible.
- **Style consistency (8):** the same bevelled-slab construction `wall`'s
  brick grid and `climb`'s steps already use; nothing about the render
  angle or palette is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (5).** Concrete fix: add one clearly mechanical detail
   that a totem/idol wouldn't have — a small gear tooth on the rivet, or a
   seam/gap line between the slabs suggesting assembled parts rather than
   a single carved block.
2. **Silhouette @ 42px (7).** Concrete fix: same as above — a
   gap/seam between the three slabs would also help the silhouette read as
   "assembled from parts" rather than "one solid stacked shape," which is
   the missing cue behind both this line's and Mechanic match's scores.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "the Engineer builds something" is meant to depict the *act* of
building (which this render does not attempt — there's no tool, no
in-progress state) or simply *a thing the Engineer has built* (which this
render is closer to) — the comment in `card_view.gd` doesn't disambiguate,
and the two readings would call for different concrete fixes. Scored
against the more literal "does the shape itself suggest construction"
reading, the harder of the two.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `gadget()`, in-lane
(icons only, no beast/portrait geometry, no shared palette or budget
constant touched).

1. **Mechanic match (5).** Concrete fix named a gear tooth on the rivet.
   Replaced the plain `CARROT` ball with the same ball plus six small
   `CARROT` ball nubs arranged radially around it at `tau/6` steps
   (`radius 0.12`, the same idea `cog`'s own gear teeth already use, scaled
   down to read as a bolt rather than a second gear) — the rivet now has a
   visible starburst of hardware around it instead of one plain dot.
2. **Silhouette @ 42px (7).** Concrete fix named a gap/seam between the
   slabs. Measured the actual world-space overlap first rather than
   guessing: the bottom slab's top (`z=-0.20`) and the middle slab's bottom
   (`z=-0.22`) OVERLAPPED by 0.02, and the middle/top gap was a bare 0.02 —
   between them, the three plates were touching or interpenetrating along
   almost the whole stack, which is exactly why they fused into one mass.
   Shrank each slab's half-height (0.14→0.11, 0.20→0.15, 0.10→0.09) and
   repositioned their centres (`z=-0.36/-0.02/0.32`) to open real
   clearance — 0.08 between bottom and middle, 0.10 between middle and top
   — the same magnitude gap `plated_armour_icon.md`'s pass 2 used to fix
   the identical "one solid mass" symptom.

Built with apt's Blender 4.0.2, headless EGL (`libegl1`, `libegl-mesa0`,
`libgles2`), `numpy` installed for Blender's own interpreter
(`/usr/bin/python3.12 -m pip install --break-system-packages numpy` —
Blender's `sys.executable` is `/usr/bin/python3.12`, not the system
`python3`, so installing numpy for the wrong interpreter left the glTF
exporter unable to `import numpy` even though it was present elsewhere).
Ran the full `icons.py` batch (no single-icon build path exists) twice,
diffing all 36 PNGs against the pre-build renders both times: only
`gadget.png` differed either run — no WORKBENCH non-determinism to revert
this time, unlike most prior passes in this file's siblings. Confirmed
`TRIS 318 PARTS 12 BUDGET 700 ok` — well inside budget.

Verified both fixes by looking at the actual render, not the geometry math:

- **Gap, quantified in the render itself.** Scanned the rendered PNG's
  alpha channel down the icon's centre column: before, one continuous
  opaque run from y=36 to y=232 (fused into a single shape); after, three
  separate opaque runs — (36,76), (98,165), (183,232) — with real 22px and
  18px transparent gaps between them at the actual 256px render
  resolution, not just in the world-space source.
- **Silhouette, at the actual rubric size.** Rendered a pure black-on-white
  alpha silhouette (the `_sil.png` convention) at full res and downsampled
  to 42px, before and after, side by side
  (`design/renders/gadget_icon_pass2_sil42_sidebyside.png`). Before: one
  fused totem-shaped blob, exactly the "totem/idol" read both this file's
  Silhouette line and Mechanic match line independently complained about.
  After: three cleanly separated rectangles. This also settles which line
  the teeth fix belongs to — the tooth nubs sit entirely inside the middle
  slab's own silhouette footprint (they don't poke past its edge from this
  camera angle), so they change nothing about the silhouette outline; the
  gap is doing 100% of the Silhouette line's work and the teeth are doing
  100% of the Mechanic line's, a clean 1:1 match to the two diagnosed
  fixes rather than one change blurring both.
- **Framing, checked for regression.** Alpha bbox `(38, 5, 218, 233)`
  after vs `(38, 5, 218, 236)` before — width unchanged, height 3px
  shorter (the bottom slab's own half-height shrank by 0.03), no clipping
  introduced, comfortable margin on all four sides of the 256×256 canvas.

| Pass | Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 9 | 5 | 7 | 8 | **36** |
| 2 | 8 | 9 | 7 | 7 | 8 | **39** |

- **Silhouette @ 42px (7 → 8):** confirmed by the silhouette crop above —
  the "one solid stacked shape" the diagnosis named is gone, replaced by
  three distinct bands with real transparent gaps between them. Not
  higher: the individual plate shapes are still plain rectangles, so the
  "reads as a generic blocky totem" complaint about the *plates
  themselves* (as opposed to them being fused) is unaddressed — this fix
  separated the parts, it didn't reshape them.
- **Mechanic match (5 → 7):** the toothed rivet directly answers the
  "reads as a trophy or totem, nothing signals *device*" finding — a
  starburst of hardware around a bolt is a specifically mechanical shape a
  totem/idol wouldn't have. Not higher: the card's actual verb is
  "builds," and a static assembled object (however mechanical) still
  doesn't depict the *act* of building — the same gap this file's own
  Unsure section already named, unaddressed by either fix.
- **Family distinction (9, unchanged):** the three-tier stack silhouette
  that made this icon distinctive is untouched in kind, just better
  separated.
- **Colour & contrast (7, unchanged):** neither fix touched a colour
  value; the antenna-spike thinness this line was docked for is still
  there.
- **Style consistency (8, unchanged):** the toothed-rivet technique reuses
  `cog`'s own radial-teeth vocabulary rather than inventing a new one, if
  anything reinforcing consistency, but this wasn't one of the two named
  lines and the underlying bevelled-slab construction it already praised
  is unchanged.

**+3 total (36 → 39), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (this pass touches only
`tools/blender/icons.py` and the regenerated `gadget.png`, nothing in
`/core` or `/game` code — run anyway, since the rule is before every
commit, not only when a change looks like it could break something).

## Unsure about (pass 2)

Whether the six tooth nubs would read as clearly at 34px in an actual
party-panel-adjacent context as they do in the 42px rubric crop used here
— this pass confirms the rubric's own downsample, not every size the icon
ships at. Also unsure whether a third pass chasing the still-open "depicts
the *act* of building" gap (this file's original Unsure section) is worth
the budget, given the shape-level fix (assembled hardware, not fused mass)
already answers the more literal "does the shape suggest construction"
reading this item was scored against.

## Pass 3 — cloud, backlog #86 duty 1

Two lowest, tied at 7: **Mechanic match** and **Colour & contrast**. Only
one had a fix that was actually in-lane. Mechanic's own pass-2 note named
the real gap — "a static assembled object... still doesn't depict the
*act* of building" — and that's a design question about what the icon
should depict, not a primitive to nudge; left untouched, same split every
prior pass under this item makes when one of the two lowest has no
concrete geometry fix available. Colour's cause was named explicitly in
pass 2 and never addressed: "the antenna-spike thinness this line was
docked for is still there."

Applied the **Colour & contrast** fix: `icons.py`'s `gadget()` antenna
`spike()` radii widened from `(0.055, 0.02)` to `(0.075, 0.032)` — both
base and tip roughly 40-60% thicker, same length (0.22) and angle
(`ang=0.4*s`) so the silhouette's outline shape is unchanged, only the
carrot-orange patch each spike puts on screen gets bigger.

Rebuilt with apt's Blender 4.0.2, headless EGL (same setup prior duty-1
passes under this item used). Ran the full `icons.py` batch and diffed
every output against the committed set: `gadget.png` at mean diff 1.54,
inside the same noise band several unrelated icons already show from
WORKBENCH non-determinism (`strength.png` 4.23, `bow.png` 2.84 this same
run, neither script touched) — so the diff number alone doesn't prove
content the way it did for `rhythm`/`volley`'s bigger reshapes. Confirmed
by direct measurement instead: scanned the right antenna's alpha-mask
width at four rows near its tip, old vs new — `y=10`: 13px → 18px,
`y=20`: 16px → 23px, `y=30`: 20px → 27px (`y=40`, inside the top slab's
own silhouette, 61px → 65px, expected to barely move since that row is
mostly slab, not antenna) — a real, verified geometry change, not noise.
Copied only `gadget.png` into `game/assets/icons/`; `icons.py`'s other 35
functions were untouched and their renders reverted.

Looked at it four ways: the full 256px composite over the brown
card-face standin (`design/renders/gadget_icon_pass3_full.png`), a real
42px Lanczos downsample nearest-neighbour upscaled for viewing
(`..._pass3_42px_big.png`), a pure black-on-white alpha silhouette
(`..._pass3_sil.png`), and a 3× zoom crop on the antenna pair specifically
(`..._pass3_antenna_zoom.png`).

- **Colour & contrast (7 → 9):** the zoom crop shows both antennae as
  clearly solid carrot-orange cones now, not the thin near-hairline wires
  pass 1 and 2 both left docked — the fix directly answers "read closer to
  hairline marks than solid shapes once downsampled." Not a 10: the tip
  end (`r=0.032`) is still meaningfully thinner than the base (`r=0.075`),
  so it's a thickened spike, not a bold uniform mark.
- **Mechanic match (7, unchanged):** not one of this pass's fix, and the
  antenna width has nothing to do with "assembled vs carved" — the gap
  pass 2 named is still open.
- **Silhouette @ 42px (8, unchanged):** the silhouette crop above shows
  the same three-band-plus-antenna shape as pass 2, just with slightly
  fatter antenna prongs — re-checked specifically for a family drift risk
  and found none; still nothing like `climb`/`ascend`/`peak`'s vertical
  post-and-mountain outlines.
- **Family distinction (9, unchanged):** shape class untouched.
- **Style consistency (8, unchanged):** same `spike()` primitive, only its
  two radius arguments changed; no new build vocabulary.

**+2 total (39 → 41) — crosses the loop's 40/50 stop line.** No line
regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`,
headless, Godot 4.7.1 — this pass touches only `tools/blender/icons.py`
and the regenerated `gadget.png`, nothing in `/core` or `/game` code).

## Unsure about (pass 3)

Whether Colour could climb past 9 with a further-thickened tip, or whether
that starts trading into Silhouette by making the antenna read as a solid
wedge rather than a tapered spike — not attempted, since the loop's own
stop condition (≥40) is met and the "assembled vs carved" Mechanic
question this file has now carried since pass 1 is the more open item for
whoever picks this file up again.
