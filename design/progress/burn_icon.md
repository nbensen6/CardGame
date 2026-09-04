# burn — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md` for batch 21's full scope and the shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/burn.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). First of
batch 22's four — the last batch of the "twenty-eight card icons" block; with
this batch, all thirty-six total card icons are scored.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`
and `cog_icon.md`: composited over a flat brown card standin RGB(139,105,74),
downsampled to a real 42px with Pillow LANCZOS, alpha bbox checked
numerically at both a raw and a >10-alpha threshold.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 5 | 6 | 7 | 8 | **33** |

## What is actually there

A single tilted LINEN card slab with a CHARCOAL title-bar band across its
upper third, and behind it two small triangular ORANGE/BRICK cones of
uneven height, poking out from the card's right edge.

- **Silhouette @ 42px (7):** the card shape itself — rounded rectangle, dark
  band, slight perspective tilt — survives the downsample cleanly and reads
  first. The two cones behind it stay visible as distinct pointed shapes but
  compress into small, ambiguous slivers that could be read as anything
  pointed, not specifically flame.
- **Family distinction (5):** a single pale rectangular card slab is also the
  base shape `draw` (two overlapping card slabs) and this same batch's
  `stack` (three fanned card slabs) both build from. At full 256px the count
  and the flame/arrow/bar dressing tell them apart; at a real 42px downsample
  all three read first as "a pale rectangle or rectangles on brown," and only
  second as their individual mechanic. Three of the thirty-six icons now
  share one base silhouette family — worth a shared look if Nick wants one.
- **Mechanic match (6):** "exhaust a card" — a burning card is about as
  literal a match as exists for the mechanic, but the execution undercuts the
  idea it reaches for: the cones pixel-sample as a flat, hard-edged, uniformly
  lit orange/brick (RGB roughly 167-185 / 108-134 / 105-131 across the
  sampled surface, no brighter core or lighter tip anywhere), so they read as
  small triangular spikes or pennants rather than flame licks with heat or
  motion in them. The card being the clear foreground shape helps the "a card
  is involved" half of the read; the "and it's burning" half is weaker.
- **Colour & contrast (7):** pixel-sampled directly. The LINEN card body
  samples at roughly RGB(177-192, 156-174, 140-162) against the standin
  RGB(139,105,74) — a strong, consistent gap on every channel (+40 to +90).
  The CHARCOAL band samples far darker, roughly RGB(32-51, 33-52, 37-56),
  contrasting hard against both the card and the background. The flame
  cones are the weakest element: roughly RGB(167-185, 108-134, 105-131)
  against the same standin, a real but moderate 30-45/5-30/30-55-per-channel
  gap — visible, not close to disappearing, but the least separated element
  in the icon.
- **Style consistency (8):** the slab-plus-spike construction matches the
  vocabulary used throughout the set (`stack`'s bar, `taunt`'s pole,
  `light`'s rays are all the same taper/slab primitives); nothing about the
  render angle or lighting is an outlier.

## Diagnosis — two lowest

1. **Family distinction (5).** Concrete fix: differentiate `burn` from
   `draw`/`stack` by silhouette rather than relying on the flame to do all
   the work — e.g. curl or char the card's own edge (a bitten, blackened
   corner) so the card shape itself, not just what's behind it, signals
   "this one is different," rather than three icons that are each "a pale
   rectangle plus one extra element."
2. **Mechanic match (6).** Concrete fix: give the flame cones a lighter,
   warmer core (a GOLD or bright ORANGE tip against the current BRICK/ORANGE
   body) the way `light`'s rays use a two-tone gold-on-amber split, so the
   flame reads as glowing rather than as a flat-shaded solid spike.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the flame is meant to be read as small and secondary (the card IS
the mechanic — exhausting — and the flame is just flavour marking how) or
as an equal partner in the read; if the former, the current balance where
the card dominates and the flame is a background detail may be exactly
right and the Mechanic-match score above may be too harsh. Also unsure
whether this reads differently once seen next to `draw` and `stack` in an
actual hand rather than compared as three isolated 42px renders side by
side, which is a `needs a screen` question this static comparison can't
settle.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `burn()`, in-lane
(icons only, no beast/portrait geometry, no shared palette or budget
constant touched):

1. **Family distinction (5).** Concrete fix: the diagnosis named that
   `draw`, `stack` and `burn` all build from the same plain-rectangle base
   and only differ in what sits behind the card. Added three small
   CHARCOAL `spike()` flecks (`(0.14,0.30)`, `(0.20,0.18)`, `(0.10,0.36)`,
   `ang=0.9`) clustered at the card's own top-right corner — the corner
   nearest the flame — so the card's own silhouette gets a jagged, bitten
   edge instead of a clean rectangle, rather than relying only on what's
   behind it.
2. **Mechanic match (6).** Concrete fix: the diagnosis pointed at the same
   enclosed-hot-core trap `fire_icon.md` pass 2 already found and fixed —
   added one thin GOLD `spike()` (`(0.22, 0.22)`, `r0=0.045`, `length=0.30`)
   based low enough inside the tallest BRICK cone's own body (base z=0.07)
   and tipped high enough (tip z=0.37) to clear that cone's own tip
   (z=0.32) by real margin, so it pokes out as a visible glowing core
   instead of staying hidden inside a bigger cone the way `fire`'s old core
   did before its own pass 2.

Rebuilt with apt's Blender 4.0.2, headless EGL (`libegl1`, `libegl-mesa0`,
`libgles2`, plus `numpy` installed into the interpreter Blender actually
uses — `/usr/bin/python3.12` via `python3.12 -m pip install numpy
--break-system-packages`, not the separate system `python3.11` — the glTF
exporter import failed with `ModuleNotFoundError: No module named 'numpy'`
until that was in the right interpreter). Console for `burn` itself: `TRIS
176 PARTS 9 BUDGET 700 ok`, no warnings. Ran the full `icons.py` batch
(no single-icon build path exists) and diffed all 36 PNGs against `HEAD`;
`burn.png` was the only one with a real content change (max per-pixel
diff 255, a full alpha swing at new geometry edges) against the other 35's
render-noise-only diffs (max 51–126, mean well under 1 for most) — the
same noise-vs-content split every icon batch since `rope_icon.md` pass 2
has used. Reverted the other 35 with `git checkout --`, kept only
`burn.png`.

Verified three ways before scoring, not just by eyeballing the full-res
render:

- **Bounding box.** Alpha>10 bbox `(38, 36, 229, 231)` of 256 — real margin
  on all four sides, unchanged from pass 1 (the new geometry sits well
  inside the old cone-cluster's own reach, so no new clipping risk).
- **Pixel sample.** Zoomed the rendered PNG on the new geometry directly:
  the three charcoal flecks sample at roughly RGB(35–90, 36–90, 40–95),
  clearly darker than both the LINEN card RGB(176–190,154–172,138–159) and
  the standin RGB(139,105,74); the new gold tip samples at roughly
  RGB(204–207,170–177,113–136) against the flame body's own
  RGB(125–170,55–100,55–95) — a real, warm-toned separation on every
  channel, not a rendering illusion.
- **Direct comparison, not memory.** Rendered a real 42px composite of
  `burn.png`, `draw.png` and `stack.png` side by side
  (`design/renders/burn_icon_pass2_vs_draw_stack_42px.png`) instead of
  trusting the written description of the other two. `burn` now reads as
  a jagged-cornered card plus a red cone shape; `draw` reads as two clean
  overlapping cream/wheat rectangles with a gold arrow; `stack` reads as
  three clean fanned slabs with a light bar. The plain-rectangle-family
  problem the diagnosis named is visibly reduced — `burn`'s silhouette no
  longer starts from the same clean-cornered rectangle the other two share.

- **Family distinction (5 → 7):** confirmed by the side-by-side render
  above — the jagged corner plus the cone shape behind it separates `burn`
  from `draw`/`stack`'s clean rectangles at a glance. Not higher: the card
  BODY itself is still the same plain LINEN slab as the other two: only
  one corner is broken up, and the fix didn't touch the shared base shape
  those cards start from, so a fast glance that misses the small corner
  detail could still group them.
- **Mechanic match (6 → 8):** the gold-tipped, two-tone flame now visibly
  pokes above the card's own damaged corner in both the full render and
  the 42px downsample (`burn_icon_pass2_42px_big.png`) — confirmed in the
  zoomed crop (`burn_icon_pass2_topcrop.png`), which shows a clean
  gold-over-brick cone distinct from the flat single-tone cones pass 1
  scored. Not higher: still a single straight-sided `spike()`, the same
  "rigid, not licking" caveat `fire_icon.md` pass 1 raised for its own
  cones before its pass-3 `limb()` rework — not attempted here since
  neither named line asked for it.
- **Silhouette @ 42px (7, unchanged):** this pass added detail rather than
  changing the overall card-plus-cones read; the new corner marks and gold
  tip both survive the 42px downsample without fusing into noise
  (confirmed in the downsample render) but weren't one of the two named
  fixes.
- **Colour & contrast (7, unchanged):** this pass touched no existing
  palette entry or the card/band colours; the new CHARCOAL and GOLD marks
  are both already-used set colours, not new swatches.
- **Style consistency (8, unchanged):** `spike()` with `CHARCOAL` and
  `GOLD` are both already this set's vocabulary (`skull` uses CHARCOAL
  slabs, `fire`'s own pass 2 used a GOLD hot-core spike the same way);
  nothing new was introduced.

**+3 total (33 → 36), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — an icon geometry/colour pass adds none, matching every prior
icon-only pass under this item.

## Unsure about (pass 2)

Whether the corner damage reads unambiguously as "this card is burning"
rather than "this card is torn or old" to someone who has never seen the
build intent — the jagged shape alone doesn't carry heat or colour cues
the way the flame cones do, so the family-distinction fix and the
mechanic-match fix are doing separate jobs rather than reinforcing one
reading. Also unsure whether the card body itself staying identical to
`draw`/`stack` (Family distinction capped at 7, not higher) is worth a
future pass — tinting the LINEN slab itself toward a scorched tone, rather
than only marking one corner, is the more thorough fix but wasn't one of
this pass's two named lines and risks reading as restyling rather than a
targeted repair.

## Pass 3 — #86 duty 1

Note first: pass 2's own per-line table (Silhouette 7, Family 7, Mechanic 8,
Colour 7, Style 8) sums to 37, not the 36 its own "+3 total (33 → 36)" line
claims — a pre-existing arithmetic slip in that pass's own summary, not
touched here. Took the per-line values (37) as the real baseline, not the
stated sum.

Two lowest of those five: Family (7) and Colour (7), tied with Silhouette
(7) — picked Family and Colour because both already had a named, unapplied
concrete fix on record (this file's own pass-2 Unsure section, and pass 1's
original Colour diagnosis about the cone body's weak separation).

Tried the first idea for Family — a solid BRICK patch box laid over the
LINEN slab's corner, the same overlapping-slab construction `draw()` uses —
and rejected it after actually looking: `design/renders/burn_icon_pass3_full.png`
(first attempt, not committed) showed a clean rectangular red patch sitting
on the corner like a second card or a sticker, not a scorch mark, and it
fully hid the pass-2 charcoal flecks underneath instead of joining them. Per
the honesty rule, reverted rather than kept a fix that looked worse on
inspection.

Applied instead:

1. **Family (7).** Concrete fix: two more CHARCOAL `spike()` flecks
   (`(0.02, 0.32, 0.07)`, `(0.16, 0.06, 0.05)`) added to the existing three,
   spreading the jagged charred edge further along the top and partway down
   the right side, so the bite out of the card's silhouette is bigger and
   less like a single small nick — same primitive and colour as pass 2, more
   of it.
2. **Colour (7).** Concrete fix: the diagnosis in pass 1 named the BRICK/
   ORANGE cone bodies as reading close to the brown card standin; swapped
   both to TANGERINE (`fire()`'s own flame tone, already this set's warm-fire
   vocabulary).

Rebuilt with apt's Blender 4.0.2, headless EGL. Console for `burn`: `TRIS 258
PARTS 6 BUDGET 700 ok`, no warnings. Diffed all 36 icons by mean per-channel
pixel difference against `HEAD`: every icon but `burn.png` came back ≤6.7
(ordinary WORKBENCH render noise, the threshold prior passes have used),
`burn.png` at mean 1.96/max 255 — real content change. Reverted the other 35,
kept only `burn.png`.

Verified both fixes directly, not from the geometry alone:

- **Colour, pixel-sampled.** Cropped a clean patch of cone body
  (`x∈[150,210], y∈[140,190]`, no gold/charcoal in frame) from both the old
  and new PNG. Old (BRICK) sampled `(144, 87, 78)` against the standin
  `(139, 105, 74)` — a near-zero, and on green *reversed*, gap (+5, −18, +4).
  New (TANGERINE) sampled `(174, 119, 89)` against the same standin — a real
  positive gap on all three channels (+35, +14, +15). The exact "flat swatch
  reads fine, shaded surface doesn't" trap `rope_icon.md`/`rally_icon.md`
  both hit, confirmed and fixed the same way: measure the rendered pixel, not
  the palette entry.
- **Family, by render comparison.** `design/renders/burn_icon_pass3_sil.png`
  against pass 2's own `burn_icon_pass2_sil.png`: pass 2's charred bite is a
  small ragged point near the top corner; pass 3's spreads across more of the
  top edge and partway down the right side, a visibly bigger break from the
  clean rectangle `draw`/`stack` still are. Same comparison at 42px
  (`burn_icon_pass3_42px_big.png` against the pass-2 equivalent) shows the
  same gap, smaller but still visible at that size.

| Pass | Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 5 | 6 | 7 | 8 | **33** |
| 2 | 7 | 7 | 8 | 7 | 8 | **37** |
| 3 | 8 | 8 | 8 | 9 | 8 | **41** |

- **Family distinction (7 → 8):** confirmed by the silhouette comparison
  above — a bigger, more spread charred bite. Not higher: the card BODY
  itself is still the same plain LINEN slab `draw`/`stack` share; every fix
  so far has stayed at the edge rather than touching the base shape.
- **Colour & contrast (7 → 9):** the measured pixel gap went from
  near-zero/reversed to a solid positive margin on all three channels,
  addressing pass 1's own "weakest element" finding directly. Not a 10: the
  tight concave crease where a cone meets the card (an AO shadow, not a flat
  swatch) wasn't re-measured and may still sit closer to the standin.
- **Silhouette @ 42px (7 → 8, side effect, not one of the two named lines):**
  the same enlarged charred bite that fixed Family also reads more clearly
  as a non-rectangular notch at 42px, confirmed in the downsample comparison
  above.
- **Mechanic match (8, unchanged):** neither fix touched the flame-plus-card
  reading itself.
- **Style consistency (8, unchanged):** `spike()` with `CHARCOAL` and
  `TANGERINE` are both already this set's vocabulary; nothing new was
  introduced.

**+4 total (37 → 41), not a plateau — kept. Crosses the 40/50 stop line.**
No line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh import,
headless, godot 4.7.1). Stopping here per `design/asset-loop.md`'s own stop
condition — 3 of 4 passes used, and another pass would be chasing points
past the line the loop itself says is "shippable and good."

## Unsure about (pass 3)

Whether the charred-corner read is specific to fire (versus "torn or old",
this file's own pass-2 Unsure question) is still open — nothing this pass
did addresses it, since both fixes were colour/spread, not a new cue. Also
unsure whether the concave-crease shadow noted under Colour above is worth a
fourth pass; it's a normal AO shadow in a tight corner, not a flat-colour
near-miss, so it may not respond to a swatch swap the way the cone bodies
did, and the score is already past the stop line.
