# relic — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 20 — continuing the icon rubric batches 14-19 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/relic.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Third of
batch 20's four (see `expose_icon.md` for the batch's scope and shared
rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 6 | 8 | 8 | **39** |

## What is actually there

A GOLD ring around a faceted six-pointed star built from two overlapping
VIOLET/ORCHID triangular spikes — a gem-cut medallion. The build script
also places a small LILAC ball at the star's centre, but it sits directly
behind the star geometry from this head-on angle and is not visibly
distinguishable in the render.

- **Silhouette @ 42px (8):** the ring-plus-star shape stays crisp at the
  real downsample — the six points remain individually countable rather
  than smoothing into a circle, one of the cleaner silhouettes scored
  under this item.
- **Family distinction (9):** no other icon scored under this item
  combines a ring with a faceted star; distinct from `expose`'s and
  `target`'s plain-ring-plus-dot construction (this batch's `expose_icon.md`)
  by shape, not just colour.
- **Mechanic match (6):** a gem/star medallion reads generically as
  "treasure, badge, or trinket," which fits "a lasting boon" as a
  keepsake but doesn't specifically signal *permanence* the way, say, a
  root or anchor motif would — nothing distinguishes it from an icon that
  could equally sit on a one-time reward or a currency, rather than
  something that stays with you for the run.
- **Colour & contrast (8):** the saturated violet/orchid star and gold
  ring both read clearly distinct from the brown standin in every sampled
  region — no near-miss found.
- **Style consistency (8):** the ring construction matches `buffer`,
  `guard`, `expose` and `target`'s shared ring vocabulary; the faceted
  star's bevel treatment is consistent with the rest of the set's flat-
  shaded low-poly look.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: work a small distinguishing motif
   into the star's centre (where the currently-hidden LILAC ball already
   sits, unused visually) — a root, chain-link, or glow cue that reads as
   "stays with you" rather than "one-time find."
2. **Silhouette @ 42px (8) tied with Style (8), naming Silhouette as the
   lower-value fix target:** no strong defect found; if anything, adding
   the centre motif above would need to preserve the current clean
   silhouette rather than crowd it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the LILAC centre ball is doing anything visually from this
camera angle — it may be fully occluded by the star geometry, in which
case it is dead weight in the build script rather than a deliberate
design element; not confirmed either way from a single head-on render.

## Pass 2 — cloud, backlog #86 duty 1

Confirmed the "Unsure about" question first: the LILAC ball WAS fully hidden,
and the geometry explains why without needing a lighting/export theory.
`taper()`'s cross-section radius is measured around its own pointing axis
(here +Z, per `spike()`'s `ang=0`/`ang=pi` calls), so at world z=0.06 — where
the ball sits — the two star cones aren't thin triangles in depth, they are
full cones whose surface bulges toward the camera (more negative Y, since
`render()` puts the camera at `(0,-8,0)`) by their own cross-section radius
at that height: computed from each spike's `loc`/`r0`/`r1`/`length`,
`spike(0.0, 0.16, 0.30, 0.02, 0.52, ...)` reaches ~0.214 there and
`spike(0.0, -0.02, 0.30, 0.02, 0.44, ..., ang=math.pi)` reaches ~0.211 — both
comfortably nearer the lens than the ball's old `y=-0.10`. The ball was never
going to render regardless of colour.

Applied the one named fix (Mechanic match): moved the ball to `y=-0.32`,
clear of both cones' surfaces at that height with margin, and recoloured it
from LILAC to GOLD to match the outer ring — the "glow cue" option the
diagnosis listed — rather than just making the same barely-differentiated
purple visible. Left size close to the original (0.09,0.055,0.09 →
0.11,0.07,0.11), a small bump for visibility once actually on screen, not a
redesign; the diagnosis's own second line explicitly warned against crowding
the silhouette.

Rebuilt with `blender --background --python tools/blender/icons.py --
<dir>` (apt's Blender 4.0.2, headless; `numpy`/`Pillow` installed for its
embedded python3.12 first, `download.blender.org` unreachable through this
container's proxy, same workaround every prior pass under this item used).
Console: `TRIS 134 PARTS 5 BUDGET 700 ok`, no warnings. Diffed all 36 icons
against the committed set by mean per-channel pixel difference: every
untouched icon fell in the usual 0-4.4 WORKBENCH render-noise band this item
has seen before (e.g. `strength` 4.228, `bow` 2.843), `relic.png` came back
at 5.237 — only modestly above that band, so (same discipline `fire_icon.md`
pass 4 used when its own whole-image number sat too close to the noise
ceiling) trusted a direct look over the number alone. Copied only
`relic.png` into `game/assets/icons/`; every other file was never written
there.

Looked at the result three ways: the full 256px composite over the flat
brown card-face standin, a real 42px `LANCZOS` downsample nearest-neighbour
upscaled for viewing, and a direct pixel sample of the core versus the star
body. The core reads as an unambiguous small gold disc sitting inside the
star at both sizes — clearly visible at 256px and still a distinct bright
dot at 42px, not washed out by the downsample. Sampled pixels confirm real
separation, not a rendering illusion: core centre `(187,148,76)` against the
star body `(96,85,165)` and `(57,48,105)` on either side — a large gap on
every channel, nothing close to a near-miss. Alpha bbox unchanged at
`(42, 29, 214, 200)` versus the pre-pass `(43, 29, 214, 200)` (1px of
ordinary render noise) — the fix added no new silhouette, exactly the
"preserve the current clean silhouette" constraint the diagnosis named,
since the ball's footprint sits entirely inside the star's own X/Z extent
and only its Y (depth) position changed.

- **Mechanic match (6 → 8):** the star now reads as a ring holding a small
  glowing gold core rather than a plain faceted gem — a specific "this stays
  lit, this stays with you" cue rather than the generic "treasure/badge"
  read pass 1 named. Not higher: it is still fundamentally a medallion
  silhouette, the same broad "reward trinket" family as a badge or a coin,
  which a lit core narrows but doesn't fully leave.
- **Silhouette @ 42px (8, unchanged):** confirmed by the identical alpha
  bbox — the core sits fully inside the star's existing outline in X/Z, so
  the six-point read pass 1 already scored well is untouched.
- **Family distinction (9, unchanged):** the added core doesn't move this
  icon closer to any other scored icon's construction; if anything, a lit
  centre is a further point of difference from `expose`/`target`'s plain
  ring-plus-dot, not a step toward it (the dot there is a flat disc, not a
  glowing ball nested inside a faceted star).
- **Colour & contrast (8, unchanged):** this pass didn't touch the outer
  ring or star colours, and the core swap was scored under Mechanic
  (what it signals), not Colour (whether existing tones separate) — the
  line this item already scored well on stands.
- **Style consistency (8, unchanged):** `ball()` at a new position and
  colour is not new build vocabulary; the ring-plus-star-plus-core
  construction still sits beside `buffer`/`guard`/`expose`/`target`'s shared
  ring vocabulary the same way pass 1 already found.

**+2 total (39 → 41), not a plateau — clears the loop's 40/50 stop line —
kept.** No line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh
`--import`, headless, Godot 4.7.1 — this pass touches only
`tools/blender/icons.py` and the regenerated `relic.png`, no `game/**`
GDScript).

## Unsure about (pass 2)

Whether a lit gold core reads as "permanent" specifically, versus just
"more valuable/shinier," to someone who hasn't read the diagnosis — the
same kind of open question `fire_icon.md` and `frail_icon.md` have both
left standing for their own mechanic-match fixes, and not one a static
composite against a flat standin can settle on its own. Also unsure whether
the same buried-by-cone-depth trap (a part placed by Z/X alone, with no Y
check against whatever else shares that X/Z region) is worth checking
across the rest of the icon set proactively, rather than only when a score
happens to flag the symptom — this pass found it by computing one asset's
geometry after the diagnosis pointed at "unused visually," not by a general
sweep.
