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
