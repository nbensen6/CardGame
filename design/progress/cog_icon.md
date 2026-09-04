# cog — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 (see `target_icon.md` for the batch's full scope and shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/cog.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Last of
batch 21's four — with this batch, thirty-two of the thirty-six total card
icons are now scored.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 7 | 5 | 8 | **36** |

## What is actually there

Two overlapping toothed rings — a larger CLAY (rust-orange) gear at
upper-left with six square teeth and a centre bump, and a smaller PEWTER
(blue-grey) gear at lower-right with six teeth of its own, its rim
crossing into the larger gear's own circle.

- **Silhouette @ 42px (7):** both rings and most of their teeth stay
  distinct at the real downsample — a clear "two overlapping toothed
  wheels" read — docked because the teeth along the overlap seam itself
  (where CLAY meets PEWTER, roughly the small gear's upper-left quadrant)
  compress together and lose their individual square shape, the one part
  of the icon that doesn't fully survive the downsample.
- **Family distinction (9):** nothing else scored under this item is a
  pair of overlapping toothed rings — the closest neighbours by
  construction (`buffer`'s single hex ring, `target`/`expose`'s
  concentric rings) are all a single ring, not two meshing ones, so `cog`
  stands apart by shape alone.
- **Mechanic match (7):** "meld / fuse" is served reasonably well by two
  distinct wheels physically overlapping into one shape — the overlap
  itself is doing real communicative work, since two separate
  non-touching gears would read as "mechanism" generically rather than
  "combination" specifically. Not a perfect match only because a gear's
  first, more common association is "machinery" or "engineering" broadly,
  and a player unfamiliar with the keyword may reach for that reading
  before "meld."
- **Colour & contrast (5), the lowest line scored this batch:** pixel-sampled
  directly, and the two gears are not equally legible against the card
  standin. The CLAY gear's dominant sampled tone, roughly RGB(168,100,65),
  sits close to the standin RGB(139,105,74) — a weak 29/5/9-per-channel
  gap, the smallest colour separation measured for any icon scored under
  this item so far. The PEWTER gear separates far better, roughly
  RGB(85,92,107) against the same standin (a 54/13/33 gap, cool grey-blue
  against warm brown) — confirmed by direct pixel sampling, not
  eyeballing, so this is a real asymmetry between the icon's two halves
  rather than a uniform read.
- **Style consistency (8):** the ring-plus-teeth-plus-centre-ball
  construction matches the vocabulary `buffer`'s hex ring and
  `target`/`expose`'s concentric rings already use; nothing about the
  render angle is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: shift the CLAY gear's tone
   further from the card-face brown — either darken it toward a more
   saturated rust, or lighten it toward the PEWTER gear's own better-
   separated value — so both halves of the icon read with equal
   confidence rather than one wheel standing out and the other nearly
   matching the background.
2. **Silhouette @ 42px (7).** Concrete fix: widen the gap between the two
   gears' teeth in the overlap zone specifically (the seam where CLAY
   meets PEWTER), since that is the one region where the downsample loses
   individual tooth shape while the rest of both rings holds up fine.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "meld / fuse" is meant to read as *combining two different
things* (which the two-colour, two-size gear pair supports) or as
*mechanism/engineering* more generally (which a single gear would have
served just as well) — the build comment names the mechanic but not which
reading the shape is meant to carry, and only Nick's sense of the card's
actual in-game context could settle it.

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `cog()`, in-lane
(icons only, no beast/portrait geometry, no shared palette or budget
constant touched — `PUMPKIN` is an existing swatch already imported at the
top of `icons.py`, not a new one).

1. **Colour & contrast (5).** Before touching anything, sampled the palette
   atlas directly (`tools/blender/colormap.png`) rather than guessing:
   `CLAY` sits at raw RGB(204,116,77) against the card standin's
   RGB(139,105,74) — a 65/11/3 raw gap, the weakest of every warm swatch
   checked. `PUMPKIN` sits at RGB(238,145,78) — a 99/40/4 raw gap, the
   widest of the same set (`ORANGE`/`TANGERINE` were wider still but
   already `fire`'s and `burn`'s own flame colours; `PUMPKIN` keeps `cog`
   in the same warm-orange family without borrowing another icon's
   palette). Swapped `CLAY` for `PUMPKIN` on the larger gear; `PEWTER`
   untouched.
2. **Silhouette @ 42px (7).** The diagnosis named the ring-crossing seam
   specifically, not the rings generally. Both gears built their 6 teeth
   from the same `k * tau/6` starting at angle zero, so a tooth sits at
   the same absolute angle on both rings regardless of where the rings
   themselves are centred — at the one place they're close enough to
   matter (the overlap seam), a tooth from each ring was landing almost
   directly on top of the other, fusing into one jagged shape rather than
   two clean squares. Added a `tau/12` (half a tooth-step) phase offset to
   the smaller (`PEWTER`) ring's teeth only, so they interleave with the
   larger ring's teeth instead of colliding with them — the way real
   meshing gear teeth actually alternate.

Built with apt's Blender 4.0.2, headless EGL (`libegl1`, `libegl-mesa0`,
`libgles2`, `numpy` via `python3.12 -m pip install --break-system-packages
numpy` — same environment prior icon passes in this file's siblings have
used; `download.blender.org` was not tried since apt's copy already works).
Ran the full `icons.py` batch (no single-icon build path exists), diffed
all 36 PNGs against the pre-build renders pixel-for-pixel: only `cog.png`
differed (every other icon rendered byte-identical this run — no
WORKBENCH non-determinism to revert this time, unlike most prior passes in
this file's siblings). Also diffed against `HEAD` after the real build into
`game/assets/icons/` and reverted the other 35 with `git checkout --`,
keeping only `cog.png`.

Verified both fixes with real numbers, not the full-res render alone:

- **Colour.** Pixel-sampled the committed PNG's gear body (a 200-pixel
  patch inside the ring, alpha>200 only): avg RGB(180.8, 125.7, 86.0)
  against the standin RGB(139,105,74) — gap (41.8, 20.7, 12.0), sum 74.5,
  more than double pass 1's measured CLAY gap (sum ~33 by the same method,
  recomputed here for a fair comparison rather than trusting the raw-
  swatch numbers above, which don't account for `render()`'s shared
  exposure/shading).
- **Silhouette.** Cropped and 4x-zoomed the overlap seam for the pre- and
  post-fix renders side by side
  (`design/renders/cog_icon_pass2_seam_before.png` /
  `_after.png`). Before: one `PEWTER` tooth bites directly into a
  `PUMPKIN`/`CLAY` tooth, the two squares fusing into one jagged shape with
  an asymmetric notch. After: the same two teeth sit side by side as two
  distinct clean squares — the phase offset moved the `PEWTER` tooth
  out from directly behind the `PUMPKIN` tooth into the gap beside it.
- **No regression check.** Alpha>10 bbox unchanged at `(2, 18, 247, 232)`
  of 256×256 before and after — the phase shift and recolour moved no
  geometry's overall reach, so the pre-existing (and already-passing)
  framing margins are untouched.

- **Colour & contrast (5 → 8):** confirmed by the pixel samples above — a
  real, more-than-doubled separation, not a rendering illusion. Not higher:
  `render()`'s shared exposure/shading still mutes every swatch below its
  raw palette value (the same ceiling `fire_icon.md` pass 2 flagged for its
  own `GOLD` core), so the icon is not as vivid as the raw atlas swatch,
  and that shared setting is out of a single icon's two-fix budget.
- **Silhouette @ 42px (7 → 8):** confirmed by the before/after seam crop —
  the two teeth at the overlap no longer fuse into one shape. Not higher:
  the rest of each ring's teeth (away from the seam) were already reading
  fine per pass 1 and are unchanged; only the one crowded spot improved,
  which is what the diagnosis asked for.
- **Family distinction (9, unchanged):** neither fix touched the two-ring
  overlapping-gear composition itself, still the most distinctive
  silhouette scored under this item.
- **Mechanic match (7, unchanged):** the recolour and phase offset don't
  change the "two things fused into one" read either direction; not one of
  the two named lines.
- **Style consistency (8, unchanged):** `PUMPKIN` and the phase-offset
  `slabf` calls are both already this set's existing vocabulary — no new
  primitive, no new swatch.

**+6 total (36 → 42), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the interleaved-teeth fix would still read clearly at a smaller
overlap (a bigger size difference between the two gears, or a bigger
positional overlap than this pair's) — this pass only confirms it works
for `cog`'s own specific geometry, not the general case. Also unsure
whether `render()`'s shared exposure muting (the Colour line's remaining
gap to a perfect score) is worth raising with Nick generally, the same
open question `fire_icon.md` pass 2 already flagged for its own `GOLD`
core and left untouched for the same reason — it's shared infrastructure
across all 36 icons, not a per-asset fix.
