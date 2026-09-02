# volley — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 20 — continuing the icon rubric batches 14-19 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/volley.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Last of
batch 20's four (see `expose_icon.md` for the batch's scope and shared
rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 5 | 8 | 4 | 7 | 6 | **30** |

## What is actually there

Three RUST-red slab segments laid end to end along one diagonal, forming
what reads as a single continuous streak, with three separate SILVER
triangular spikes floating above and to the right of the streak, not
touching it.

- **Silhouette @ 42px (5):** the three red segments, distinct enough at
  256px to read as separate bars, fuse completely into one unbroken
  diagonal line at the real downsample — the "several" the icon needs to
  communicate is gone at the size it's actually read.
- **Family distinction (8):** nothing else scored under this item is a
  diagonal streak with separate floating triangles; distinct by shape
  from the rest of the set.
- **Mechanic match (4), the lowest line scored this batch:** "several hits
  at once" needs to read as multiple discrete impacts. What renders
  instead is one continuous red slash (read most naturally as a claw mark
  or a single wound) with three grey triangles scattered above it that
  never touch the line or each other — confirmed at both 256px and the
  42px downsample. Neither the (now-fused) red line nor the disconnected
  triangles communicate "multiple hits"; if anything the single unbroken
  streak argues *against* it.
- **Colour & contrast (7):** the RUST red and SILVER grey both separate
  cleanly from the brown standin in every sampled region — no colour
  problem found, the defect is entirely shape.
- **Style consistency (6):** the three SILVER triangles floating clear of
  the RUST line, never touching it, is the same "orbiting/disconnected
  part" failure this item has already named repeatedly for beast sigil
  crests across the 3D batches (`eyrie_hawk`, `clot_toad`, `silk_widow`,
  `thrasher`, `husk_beetle`, `gloom_moth`, `vine_weaver` — batch 4's own
  ranked-ten note called it "likely the single highest-leverage fix
  available" across those seven) — the first time this item has found the
  same pattern recurring in a 2D icon rather than a 3D model.

## Diagnosis — two lowest

1. **Mechanic match (4).** Concrete fix: separate the three red segments
   with a visible gap (rather than letting them touch end-to-end) so they
   stay three distinct marks at 42px instead of fusing into one line, and
   move the three SILVER triangles to sit directly at the end of each red
   segment rather than floating clear of all three — turning "one streak
   plus stray debris" into "three separate impact marks."
2. **Silhouette @ 42px (5).** Concrete fix: same as above — the fused-line
   problem and the "several hits" problem share one root cause and one
   fix.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the three floating triangles are meant to be arrowheads implying
motion (each one at the leading edge of a strike) rather than debris —
plausible from the build script's intent, but not what the render actually
communicates at either 256px or 42px; only Nick's read on the original
design intent could settle which the fix above should assume.

## Pass 2 — cloud, backlog #86 duty 1

Both named lines trace to one cause: `icons.py`'s `volley()` placed its three
`slabf` marks with a spacing vector `(0.34, -0.22)` that, once the rotation
was worked out (`slabf`'s `w` is a Blender object-scale value — a HALF-extent,
since `primitive_cube_add`'s base cube already spans -1..1 — so the marks'
real half-width was `0.22`, not the `0.11` the old spacing looks like it was
built for), left adjacent marks about 0.047 world units apart — under a pixel
at 42px, which is why they fused into one streak. The three `spike` triangles
were placed at a fixed `(x+0.20, z+0.20)` offset that never referenced the
marks' own geometry at all, which is why they floated clear of the line
regardless of where the marks actually sat.

Rewrote `volley()` from explicit magic-number placements to one shared
diagonal direction vector (`dx, dz = cos(rot), -sin(rot)`, the true world
direction `slabf`'s local +X maps to after its own Y-rotation) and three
marks stepped along it by `2*hw + gap` — a real, chosen gap between marks
instead of an accidental near-zero one. Each `spike` is now placed and
oriented from that same vector so its apex sits exactly on its own mark's
near tip, rather than at an independent offset: `ang = atan2(dx, dz)` and
`spike_center = mark_center - dir * (hw + spike_len/2)`, which puts the
arrowhead touching the mark it belongs to for any future change to `hw`,
`gap` or `rot`. First render's alpha bbox touched column 0 exactly
(`(0, 43, 228, 186)` on a 256-wide canvas — the same "no margin" pattern this
item's pass 1 already flagged across eight other icons); pulled `hw` and
`spike_len` in slightly (`0.12/0.15` → `0.11/0.13`) and re-rendered, which
gave `(2, 49, 222, 183)` — comfortable margin on every side, no other change.

Rendered with an apt-installed Blender 4.0.2 (`download.blender.org` still
policy-403 for a direct download; apt route is the same one `rhythm_icon.md`
pass 2 and others used). `Pillow` (`pip install pillow`) built the composited
full/42px/silhouette views and the family strip locally — no dedicated
downsample tool exists in this repo, so this pass wrote one inline rather
than adding a new tracked script for a single use. Only `volley.png` copied
over the shipped asset; no other icon script touched. Renders:
`design/renders/volley_icon_pass2_full.png` (composited on the brown
card-face standin), `design/renders/volley_icon_pass2_42px.png` and
`..._42px_big.png` (real 42px Lanczos downsample, nearest-neighbour upscaled
for viewing), `design/renders/volley_icon_pass2_sil.png` (silhouette), and
`design/renders/volley_family_42px_strip_pass2.png` (volley next to climb/
ascend/peak at 42px, checking it hasn't drifted into their family now that
it's also a diagonal-plus-triangle shape — it hasn't; the strip shows a red
zigzag with silver caps, nothing like their vertical arrow-on-post/mountain
silhouettes).

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 8 | 8 | 7 | 8 | **39** |

- **Silhouette @ 42px (5 → 8):** looked at the 42px render — three distinct
  red marks with a visible gap between each, no longer one fused diagonal
  line. Not a 9-10: at 42px the gaps read as thin rather than bold, so the
  "three" count is legible but not emphatic.
- **Family distinction (8, unchanged):** re-checked against the concern a
  diagonal-plus-triangle shape might now drift toward the "going up" family
  — the side-by-side strip shows it stays a red zigzag with silver caps,
  nothing like `climb`/`ascend`/`peak`'s vertical post-and-mountain
  silhouettes. Not one of the two named lines; unmoved because it was
  already fine and stayed fine.
- **Mechanic match (4 → 8):** the fix's actual target. Three separate red
  marks, each capped by a silver arrowhead touching it, reads directly as
  three discrete impacts rather than one slash — confirmed at both 256px and
  the 42px downsample.
- **Colour & contrast (7, unchanged):** not one of the two fixes; pixel-
  sampled after the change to confirm nothing shifted — RUST averages
  RGB(189,98,80), SILVER RGB(143,145,152), both still well clear of the
  brown standin RGB(139,105,74).
- **Style consistency (6 → 8):** the "orbiting/disconnected part" failure
  this item's pass 1 named — the same pattern flagged repeatedly for beast
  sigil crests across the 3D batches — is gone: each spike's apex now
  touches its own mark instead of floating clear of all three. Not a 9-10:
  the marks' gaps are still fairly tight, a stylistic choice rather than a
  defect.

**+9 total (30 → 39), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (icons aren't exercised by the suite
directly; this confirms no unrelated regression).

## Unsure about (pass 2)

Whether Silhouette @ 42px should be higher now that the shape is objectively
fixed — left at 8 rather than 9-10 since the gaps between marks, while
readable, are still the smallest amount of separation that reads reliably
rather than a bold, unmistakable one; a slightly wider `gap` would likely
buy another point at real cost to how compact the icon reads at full size,
which felt like a judgement call rather than a clear win.
