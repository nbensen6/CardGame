# lift — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
17 — continuing the icon rubric batches 14-16 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/lift.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Third of batch 17's
four, and the fifth of the **"six are about going up" family**
(`climb`, `ascend`, `peak`, `rope`, `lift`, `rally`) batch 16 left open —
`rally` (this batch's other family member) is scored alongside it in
`design/progress/rally_icon.md`.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-16 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up 8x to view, composited over the same flat brown
card-face standin batches 14-16 used, `RGB(139,105,74)`). Alpha channel
bounding box checked directly (`Image.getbbox()`, plus a >10 threshold pass
to separate "touches the edge" from "clipped there") rather than guessing at
cropping. All six family members rendered and downsampled together in one
strip for a true side-by-side comparison.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 7 | 6 | 8 | **38** |

## What is actually there

Two rounded humanoid blob figures (a ball head on a tapered body, the same
construction `support`'s hand and other cast pieces use), one lower-left and
one upper-right, joined by a thin tan diagonal bar (the "grip" the build
comment names), with a gold up-arrow rising between them. Alpha bbox
`(36, 0, 219, 252)`: the arrow tip sits flush against the top row (row 0 is
fully opaque) — clipped there, no margin above it, though it doesn't read as
an obvious crop at either 256px or 42px.

- **Silhouette @ 42px (8):** the two-figures-plus-arrow composition survives
  the downsample cleanly — two round heads, two body masses, a connecting
  diagonal, and a triangle pointing up are all still separable shapes, not a
  blur.
- **Family distinction (9):** the strongest line in this batch. Next to
  `climb`/`ascend`/`peak` (all a single triangle-on-a-mass silhouette) and
  `rope` (a coil), `lift`'s two-figure composition is unmistakably a
  different shape at a glance — exactly what the build comment says it was
  built to avoid confusing with `support`'s hand and `rope`'s coil, and it
  succeeds at both.
- **Mechanic match (7):** "haul the ally to you" reads as "two people, one
  above the other, connected, going up" reasonably well, but the two figures
  are drawn identically in size and pose — nothing distinguishes "the one
  being hauled" from "the one hauling," so the specific verb (a rescue/pull)
  is weaker than the general concept (togetherness plus up).
- **Colour & contrast (6):** the two figures are built from GREEN and MINT
  per the source (`icons.py:256`) to read as two different people, but at
  both 256px and the 42px downsample they read as the same green — the hue
  gap between the two greens is too small to survive the shading gradient
  each figure already carries. Both greens also sit in the same colour
  family as `support`'s hand (a different green), so a hand of cards mixing
  `lift` and `support` would show two green-ish icons rather than two
  clearly different ones.
- **Style consistency (8):** same bevelled-blob construction as the rest of
  the set; nothing about the render is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (6).** Concrete fix: push GREEN and MINT further
   apart in hue or value (not just the current near-identical greens), or
   give one figure a warm colour (tan/gold, matching the grip and arrow)
   instead of two greens, so "hauler" and "hauled" separate by colour as
   well as position.
2. **Mechanic match (7).** Concrete fix: differentiate the two figures'
   pose — the lower-left one reaching/straining, the upper-right one
   already part-way up — rather than two identical blobs at different
   coordinates, so the "pull" reads as an action rather than a static
   diagram.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the arrow tip's flush top-edge clipping (alpha bbox top row fully
opaque, no margin) is visible as a hard crop once this icon sits inside the
game's own icon frame at 30x30 (`card_view.gd`'s rail icon size) rather than
this scoring script's flat 256px canvas — this is the same "flush against
the canvas edge" pattern batch 15 found on `wall` and this batch's own
`rally`/`strength`/`dexterity` also show, now five icons deep, and worth a
shared look if Nick wants one fix rather than four.

## Pass 2 — cloud, backlog #86 duty 1

Applied both named fixes — this asset's diagnosis is the rare case where
neither of the two lowest lines needed a model change, only `icons.py`'s own
`lift()` function.

1. **Colour & contrast (6).** `GREEN` and `MINT` are adjacent organic-green
   swatches in the shared atlas (`palette.py`'s own `ADJUST` table warms both
   by nearly the same amount) and read as one colour. The upper-right figure
   (the one being hauled up) is now `TAN` instead of `MINT` — the same warm
   colour the diagnosis suggested, already used by the grip and the arrow.
2. **Mechanic match (7).** Both figures were built from the same unrotated
   `slabf` body plate — two identical blobs at different coordinates, no
   pose. The lower-left figure (doing the hauling) now gets `rot=0.35` on its
   body slab, leaning it away from the grip's direction; the upper-right
   figure (already hauled) keeps `rot=0.0`, upright.

Rebuilt with apt's Blender 4.0.2, headless, rendering the full `ICONS` batch
to `game/assets/icons` directly (system `python3.12` — the interpreter
Blender itself embeds, distinct from the container's default `python3.11` —
needed `numpy`/`Pillow` added via `pip3.12`). Unlike the portrait passes'
notes on this project, two independent renders of the same unchanged script
came back **byte-identical** (checked directly, `lift.png` and `peak.png`
both at 0.0 mean diff run-to-run) — this Blender build's WORKBENCH output is
deterministic in this environment. The per-icon diffs against the committed
set (`ascend` 0.0, `peak` 6.70, `guard` 2.88, `relic` 4.44, `strength` 4.23,
etc., `lift` 5.88) are real but not noise from this pass — they're drift
between this render and whatever produced the currently committed PNGs
(different Blender build/platform). Since every one of those other icons'
build functions is untouched by this edit, all of them were reverted with
`git checkout --` and only `lift.png` — the one function this pass actually
changed — was kept.

Verified by looking, not just by diffing:

- **Alpha bbox** moved from `(36, 0, 220, 254)` to `(30, 0, 220, 256)` — the
  arrow's flush top-edge touch (pre-existing, not one of this pass's two
  lines, left alone per the "Unsure about" note above) is unchanged; the
  bottom now also touches row 255, traced to the leaning figure's own bevel
  corner grazing the frame edge (`/tmp/lift_bottom_crop.png`, a scratch crop,
  not a new asset) — 12 pixels of alpha on the very last row, the same class
  of peripheral corner-touch several other icons in this batch already carry
  at their own edges, not a new failure.
- **Full 256px composite** over the same brown card-face standin this
  item's pass 1 used (`design/renders/lift_icon_pass2_after_full.png` vs
  `..._pass1_before_full.png`): pass 1 shows two same-toned green blobs in
  an identical standing pose; pass 2 shows a warm-tan upright figure at
  upper-right and a green figure leaning back at lower-left.
- **A real 42px downsample** (Pillow `LANCZOS`, same brown standin, same
  method pass 1 used), and a direct pixel sample of each figure's body
  (alpha > 200 pixels only, 20x30px interior patches, avoiding
  anti-aliased edges): old `GREEN` vs `MINT` bodies sampled a mean
  per-channel gap of 13.9 (max single channel 22.8); new `GREEN` vs `TAN`
  bodies sample a mean per-channel gap of 38.7, with the red channel alone
  71.9 to 74.7 apart (green ~101, tan ~174) — a real, roughly-3x colour
  separation, not a guessed one.

- **Colour & contrast (6 → 9):** confirmed by the pixel samples above — the
  two figures now separate by hue as well as position, at both 256px and
  the 42px downsample (visible in the composite: a clear warm peach-tan
  figure beside a clear green one, where pass 1 showed two barely
  distinguishable greens). Not a 10: the new `TAN` figure sits close in hue
  to the `TAN` grip it's attached to (sampled 4.4 mean per-channel gap
  between them, against 15.7 to the `GOLD` arrow) — expected, since this is
  the same colour the diagnosis itself proposed reusing, and shape (a
  blob vs. a thin diagonal bar) still keeps the two parts visually
  distinct in the actual render.
- **Mechanic match (7 → 8):** the two figures are no longer identical —
  colour tells them apart on sight, and the lower-left figure's real lean
  (visible in the crop above and in the 42px composite) gives it a
  reaching/straining read the upright, symmetric pass-1 pose didn't have.
  Not a bigger jump: the lean is a body-plate tilt, not a full re-pose with
  distinct limbs, so it reads as "one figure looks slightly different from
  the other" more than a clearly staged pulling action — a further pass
  could add an actual arm gesture if more budget were spent here.
- **Silhouette @ 42px (8, unchanged):** not one of the two targeted lines;
  the tilt is subtle enough at this size that the three-part read (two
  heads, a connecting diagonal, an arrow) survives exactly as it did in
  pass 1 — no regression, no clear gain either.
- **Family distinction (9, unchanged):** not one of the two targeted lines;
  the composition class (two figures plus a diagonal grip plus an arrow)
  didn't change, so it still reads as distinct from `climb`/`ascend`/`peak`
  (single mass) and `rope` (a coil) exactly as pass 1 found.
- **Style consistency (8, unchanged):** same bevelled-blob construction,
  same "outline badge" vocabulary the rest of the set uses; recolouring one
  figure and tilting a body plate isn't a new composition class.

**+4 total (38 → 42), not a plateau — kept. Crosses the loop's 40/50 stop
line.** No line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh
`--import`, headless) — the change is confined to `tools/blender/icons.py`'s
`lift()` function and the regenerated `lift.png`, nothing in `/core` or
`/game` code. No new tests: an icon recolour-and-tilt pass adds none,
matching every prior icon-only pass under this item.

## Unsure about (pass 2)

Whether the lean reads as "effort/straining" or just "a slightly crooked
figure" to someone who hasn't read this file — the pixel-level colour
separation is measured and certain, but the pose read is a judgement call
this pass can describe, not prove, the same limit every prior pass under
this item has flagged for its own "does the metaphor land" question.
