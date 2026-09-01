# rhythm — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 (see `target_icon.md` for the batch's full scope and shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/rhythm.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 21's four.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 5 | 4 | 7 | 7 | **30** |

## What is actually there

A SKY-blue jointed line rising from a ball on the left, up to a plateau,
down through a single sharp V to a valley, then back up through another
plateau to a ball on the right — one wide "checkmark"-shaped zigzag, not a
repeating wave — with a PERIWINKLE bar sitting below it, disconnected from
the line.

- **Silhouette @ 42px (7):** the line, both end balls and the bar all stay
  distinct and legible at the real downsample; the shape reads cleanly as
  a single wide V.
- **Family distinction (5), the lower of two lowest lines:** the build
  script's nine points (`sin(k*1.05)`) mathematically complete more than
  one oscillation, but the two swings plateau hard at each extreme rather
  than reading as evenly spaced beats, so what actually renders is one
  dominant V flanked by two short flat runs — a chevron silhouette close
  enough to the "going up" family's mountain shapes (`peak`, `climb`,
  `ascend`, all also built from angled line segments) that colour, not
  shape, is doing most of the separating work. Not as close a pair as
  `target`/`expose` (batch 20-21's 3/10), since the end balls and bottom
  bar are genuinely unique to `rhythm`, but the core line shape overlaps
  a crowded family this item has already flagged twice (batches 15/16).
- **Mechanic match (4), the lowest line scored this batch:** "the Frog's
  combo counter" needs to read as *counting* or *repetition* — a beat
  pattern. What renders is one wide zigzag with a flat run on each side,
  which reads as a single dip or a checkmark, not as a rhythm or a count.
  Nothing in the shape signals "counter" without the keyword already
  known.
- **Colour & contrast (7):** pixel-sampled directly along the line — the
  lit face runs roughly RGB(165,182,201) and the shaded face RGB(109,136,164)
  against the standin RGB(139,105,74), a strong 60-125-per-channel gap
  driven mostly by the blue channel; the PERIWINKLE bar at RGB(119,128,187)
  separates just as cleanly. No colour problem found — the defect above is
  entirely shape.
- **Style consistency (7):** the jointed-limb-plus-end-balls construction
  matches the game's own `limb()` vocabulary used elsewhere (`bow`'s
  string, `flicker_stag`'s antlers); nothing about the render angle or
  palette is an outlier.

## Diagnosis — two lowest

1. **Mechanic match (4).** Concrete fix: replace the current nine-point
   plateau-and-dip curve with an evenly spaced multi-peak wave (three or
   four visible up-down beats rather than one dominant V), so the shape
   itself reads as a repeating pattern rather than a single checkmark —
   the closer the silhouette gets to a literal heartbeat-monitor line, the
   less it needs the keyword to be understood.
2. **Family distinction (5).** Concrete fix: none proposed beyond the
   mechanic fix above — a genuine multi-beat wave would also pull the
   silhouette further from `peak`/`climb`/`ascend`'s single-chevron shapes
   than the current one-V render does.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the two end balls (ICE) being pinned exactly to the alpha bbox's
left and right edges — `(0, 50, 256, 255)` at the any-alpha threshold,
`(0, 50, 256, 254)` at >10 — reads as a problem the way the "no margin"
pattern already named for several other icons across batches 15-20 does,
or is closer to `expose`'s ticks: arguably part of the "reaching to both
ends" intent of a combo counter rather than an accidental clip. Flagged as
the same pattern, not scored as a defect on its own line, per that
convention.

## Pass 2 — cloud, backlog #86 duty 1

Both named lines trace to one cause: `icons.py`'s `rhythm()` built its nine
points with `math.sin(k * 1.05)`, a phase step that plateaus hard near each
extreme instead of stepping evenly through a cycle, so what rendered was one
dominant V flanked by two flat runs rather than a repeating beat. Changed
the phase step from `1.05` to `math.pi / 2` (both the point loop and the two
end-ball positions, which read the same formula at `k=0`/`k=8` so they stay
anchored to the line's own ends): `sin(k * pi/2)` for `k` in `0..8` gives
`0, +0.30, 0, -0.30, 0, +0.30, 0, -0.30, 0` — a clean four-beat zigzag with
both ends level, instead of the old asymmetric `0` / `+0.256` endpoints.
No palette or budget touched; only the two `rhythm()` lines in `icons.py`.

Rendered with a locally apt-installed Blender 4.0.2 (`download.blender.org`
still policy-403 for a direct download; apt route is the same one #74/#76/#83
and `ascend_icon.md`'s pass 2 used — needed `python3-numpy` via apt too, since
this apt build's glTF exporter shells out to the system Python and had none).
Only `rhythm.png` copied over the shipped asset, no other icon script
touched. Renders: `design/renders/rhythm_icon_pass2_full.png` (composited on
the brown card-face standin), `design/renders/rhythm_icon_pass2_42px_big.png`
(42px Lanczos downsample, nearest-neighbour upscaled for viewing),
`design/renders/rhythm_icon_pass2_sil.png` (silhouette), and
`design/renders/rhythm_family_42px_strip_pass2.png` (rhythm next to peak/
climb/ascend at 42px, same comparison method `ascend_icon.md` pass 2 used).
Alpha bbox moved from `(0, 50, 256, 255)`/`(0, 50, 256, 254)` to
`(0, 51, 256, 254)` — the same overall footprint, no new clipping.

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 8 | 8 | 7 | 7 | **38** |

- **Silhouette @ 42px (7 → 8, side effect):** looked at the 42px render —
  the line now reads as two clean peaks and a valley rather than one V,
  still fully legible with the same end balls and bar. Not one of the two
  named lines, moved because the shape itself changed.
- **Family distinction (5 → 8):** the side-by-side strip
  (`rhythm_family_42px_strip_pass2.png`) shows `rhythm` as a genuine zigzag
  with a valley, next to `peak`'s single mountain and `climb`/`ascend`'s
  single arrow-on-post — no longer sharing a silhouette family with the
  "going up" icons at all. Not a 9-10: still the same SKY/ICE/PERIWINKLE
  colour language as the rest of the set, which is intentional.
- **Mechanic match (4 → 8):** the four-beat zigzag reads as a repeating
  count/pulse rather than a single dip or checkmark — confirmed in both the
  full render and the 42px downsample.
- **Colour & contrast (7, unchanged):** not one of the two fixes; the pixel
  values weren't touched.
- **Style consistency (7, unchanged):** still the same jointed-limb-plus-
  end-balls construction; only the phase of an existing curve changed.

**+8 total (30 → 38), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (icons aren't exercised by the suite
directly; this confirms no unrelated regression).

## Unsure about (pass 2)

Whether Mechanic match should move even higher now that the pattern is a
clean repeating wave; left at 8 rather than 9-10 since nothing about the
shape names "combo" or "counter" specifically beyond "a repeating pulse,"
which is as far as a wordless glyph can reasonably go.
