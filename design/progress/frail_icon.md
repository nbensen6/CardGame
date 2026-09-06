# frail — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
22 (see `target_icon.md`/`burn_icon.md` for the batch's full scope and the
shared rubric). **Scoring pass only — report, not repair; no edits to
`tools/blender/icons.py`.** Asset: `game/assets/icons/frail.png` (256x256,
rendered by `icons.py`, orthographic head-on). Last of batch 22's four; also
answers `design/ART-REVIEW.md`'s own standalone "one Frail icon" section. With
this batch, **all thirty-six total card icons are now scored**, and every
asset class this item's own text names (beasts, hunters, fight grounds,
portraits, icons) is complete except the overworld map, which batch 14
already reclassified `needs a screen` rather than cloud-scoreable.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-21 established — Silhouette@42px / Family
distinction / Mechanic match / Colour & contrast / Style consistency. Same
method as the rest of this batch: composited over the flat brown card standin
RGB(139,105,74), downsampled to a real 42px with Pillow LANCZOS, alpha bbox
checked numerically: raw and >10-alpha threshold both give
`(23, 11, 239, 256)` — the bottom edge touches the canvas exactly (y=256),
the same "no margin" pattern named for several icons across batches 15-21,
here on the bottom rather than a side.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 4 | 6 | 8 | **32** |

## What is actually there

Two STEEL kite-shield shapes side by side, each with a rounded top and a
tapered point at the bottom (the same construction `shield()` itself uses),
separated by a jagged CHARCOAL crack running between them, with a small
SILVER chip broken free and drifting down-and-right, partly cropped by the
canvas bottom edge.

- **Silhouette @ 42px (7):** both shield-halves and the crack between them
  stay visible and distinct at the real downsample — this is not a smudge.
  Docked because the falling chip, the detail meant to sell "a piece has
  broken off," compresses to a few pixels at 42px and is easy to miss
  entirely against the standin at that size, even though it reads clearly
  at 256px.
- **Family distinction (7):** two side-by-side kite shapes read as a
  meaningfully different gestalt from the single-kite `shield`/`guard`/
  `plated_armour` or the brick-grid `wall` — "two of something" versus "one
  of something" is a real, legible difference in count and overall shape,
  not just colour, the same kind of distinction `cog_icon.md` credited for
  its two overlapping gears against the set's single-ring icons.
- **Mechanic match (4), the lowest line scored this batch and the
  specific question `ART-REVIEW.md`'s own note already names ("does
  `frail` read as broken/weakened rather than whole"):** it does not,
  cleanly. Each half independently still has a full rounded top and a full
  tapered point — the complete silhouette vocabulary of an intact shield —
  rather than reading as a fragment of one larger shape torn in two. At a
  glance, before the crack or the falling chip register, two complete
  shield outlines side by side risk reading as *more* protection, not
  less — the opposite of what Frail means. The crack and the drifting chip
  are the details doing the actual "broken" work, and both are the
  smallest, least prominent elements in the render.
- **Colour & contrast (6):** pixel-sampled directly. The two shield halves
  don't separate equally from the standin: the left half samples at
  roughly RGB(122,130,146) against RGB(139,105,74) — the red channel is
  actually *lower* than the standin's own red, leaning entirely on the
  green/blue shift (cool steel-blue vs warm brown) for contrast, a
  17/25/72-per-channel gap. The right half samples at roughly RGB(140,146,
  158) — its red channel, 140, is within one point of the standin's 139,
  the closest red-channel match measured for any icon under this item so
  far — separating almost entirely on hue rather than luminance. Both stay
  visible in practice because the hue shift (cool grey-blue vs warm brown)
  is doing real work even where the raw channel gap is thin, but this is a
  more fragile separation than most icons scored under this item carry.
- **Style consistency (8):** reuses `shield()`'s own tapered-kite
  construction and the family's established STEEL/SILVER palette on
  purpose — `ART-REVIEW.md`'s own build note says as much ("Frail IS about
  Block") — consistent with the vocabulary, not an outlier.

## Diagnosis — two lowest

1. **Mechanic match (4).** Concrete fix: break the *symmetry* of the two
   halves rather than keeping each a complete miniature shield — e.g. give
   only one half the rounded top and let the other end in a jagged broken
   edge instead of its own point, so at a glance the two pieces read as
   "one shield split unevenly" rather than "two small shields," and lean
   less on the crack and the small falling chip to carry the whole idea.
2. **Colour & contrast (6).** Concrete fix: darken or cool the right-hand
   half specifically — its near-zero red-channel separation from the
   standin is the weakest single measurement in this icon — so both halves
   separate from the card face with the same confidence the left half
   already has.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The exact question `ART-REVIEW.md`'s own note already raises and this pass
cannot close: whether "broken shield" reads as *Frail specifically* versus
just "something bad happened to my Block" in general, without the keyword
tooltip open — a card-hand read this static comparison can't settle. Also
unsure whether the falling chip survives being cropped by the canvas bottom
edge once it sits next to a card's real cost pip and rules text, which
`ART-REVIEW.md`'s own note flags too and which needs the actual card layout,
not this flat render, to check — a `needs a screen` question.

## Pass 2 — fixer

Item 86's own text supersedes "scores, never repairs" for portraits and
icons specifically (they render flat and headless answers them completely),
so this pass applied both named lines instead of only proposing them.
Changed `tools/blender/icons.py`'s `frail()`:

1. **Mechanic match (4).** The right half used to mirror the left exactly —
   its own rounded top slab plus its own clean `spike()` taper to a point —
   so it read as a second, complete miniature shield rather than half of one
   broken shield. Replaced the right half's taper with three small, unevenly
   rotated `slabf()` shards (matching the vocabulary the crack pieces and
   the falling chip already use, no new primitive), so the bottom of the
   right half reads as rubble rather than its own intact point. The left
   half's rounded top and clean point are untouched, so the asymmetry is
   real: one recognisable (if cracked) shield shape, one shattered edge.
2. **Colour & contrast (6).** The right half's `slabf` calls (plate, band,
   and the three new shards) were recoloured from `STEEL` to `NAVY`
   (`swatch(464,448)`, sampled directly from `colormap.png` at
   RGB(72,75,89) against `STEEL`'s RGB(124,131,157)) — cooler and
   markedly darker, specifically targeting the near-zero red-channel gap
   Pass 1 measured on the right half alone. Left half, band colours, crack
   and chip untouched.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless EGL — `download.blender.org`
still a 403 through the proxy). Console: `TRIS 560 PARTS 6 BUDGET 700 ok`,
no warnings. As `yoke_ox.md` already found for this same container/renderer
combination, EVERY icon PNG comes back with small pixel differences from the
committed versions even when unchanged (diffed all 35 others directly against
`HEAD`, up to ~mean 11/255 on some — rendering noise, not content); reverted
all 35 unrelated icons and kept only `frail.png`, whose diff is real content
(mean 16.5, max 255 — far past the noise band the other 35 sit in).

Composited both the old (`HEAD`) and new PNGs over the flat brown card-face
standin RGB(139,105,74) and downsampled to a real 42px with Pillow LANCZOS,
same method Pass 1 used, and looked at both side by side
(`/tmp/frail_old_42px_big.png` vs `design/renders/frail_icon_pass2_42px_big.png`,
plus the 256px composites) — the old render shows two identical clean-pointed
shields; the new one shows a clean point on the left and an uneven jagged
cluster on the right, at both sizes. Also rendered a pure black-on-white
silhouette from the alpha channel (`design/renders/frail_icon_pass2_sil.png`,
same alpha-mask method the asset-loop's `_sil.png` convention uses for 3D
models) — the asymmetry the two fixes were meant to produce is visible with
colour removed entirely: one whole kite outline on the left, a broken,
multi-piece cluster on the right. Pixel-sampled the new PNG directly to
confirm the colour change is real, not a rendering illusion: right-half
mid-tone samples away from the top bevel highlight read RGB(52–89, 57–89,
68–89) against the old uniform STEEL RGB(103–163, 113–167, 132–177) at the
same coordinates — a real, measured darkening, though the top bevel
highlight itself stays similarly bright on both halves regardless of base
colour (Blender's own rim-light shading, not something this pass's two-fix
budget touches).

- **Mechanic match (4 → 7):** the right half is now visibly broken rather
  than a second complete shield, at both 256px and the 42px downsample.
  Not higher: the left half is still a fully intact miniature shield in its
  own right (rounded top, clean point) rather than a fragment itself, so
  the read is "one whole half + one shattered half" rather than "one shape
  torn unevenly across the whole silhouette" — closer to Frail than before,
  not a perfect read.
- **Colour & contrast (6 → 8):** confirmed by direct pixel sampling above;
  the right half separates from the standin on luminance now, not just the
  thin hue-only gap Pass 1 measured. Not a 9-10: the shared top bevel
  highlight still reads similarly bright on both halves, so the separation
  is strongest in the lower two-thirds of the icon, not total.
- **Silhouette @ 42px (7 → 8, not one of the two, moved as a side effect):**
  the jagged shard cluster is larger and more visible at 42px than the
  single small falling chip Pass 1 docked this line for, so the "something
  came apart" read survives the downsample better than before, without
  either named fix targeting this line directly.
- **Family distinction (7, unchanged):** still reads as "two shapes" next to
  `shield`/`guard`/`wall`'s single silhouette; the asymmetry between the two
  halves doesn't change that gestalt count, which is what this line scores.
- **Style consistency (8, unchanged):** the new shards reuse `slabf()`, the
  same primitive the crack and the chip already use — no new build
  vocabulary introduced.

**+6 total (32 → 38), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (icons aren't exercised by the suite
directly; this confirms no unrelated regression).

## Unsure about (pass 2)

Whether "one whole half, one shattered half" reads as *Frail specifically*
rather than just "a damaged shield" in general — the same open question
Pass 1 raised, not closed by this pass, and ultimately a card-hand read
this static comparison can't settle. Also unsure whether push the left
half's own point toward a smaller, less-complete shape would read as "the
whole thing is breaking down" more than the current whole-half/broken-half
split — a further asymmetry, not attempted here since neither named line
asked for it and item 86's own loop caps a fix at the two lowest-scoring
lines per pass.

## Pass 3 — cloud, backlog #86 duty 1 (third pass)

Picked back up as the lowest-scoring un-plateaued icon with real budget left
(38/50, tied with `rhythm_icon`/`shield_icon` but the only one of the three
with a concrete next fix already named in its own file — pass 2's own
"Unsure about" note above). Tied-lowest lines after pass 2: **Family
distinction (7)** and **Mechanic match (7)**.

Applied both named lines, in-lane (`tools/blender/icons.py` only, no palette
edit, no budget or shared constant moved):

1. **Family distinction (7).** Pulled both halves 0.03 toward the centre
   (left half's three shapes from `x=-0.20` to `x=-0.17`; right half's five
   shapes from `x=0.22`/`0.14`/`0.27`/`0.19` to `x=0.19`/`0.11`/`0.24`/`0.16`,
   same relative offsets preserved) so the gap between them narrows rather
   than sitting as two clearly separate objects. The crack shards (unmoved,
   already centred near `x=0.0`) now bridge a tighter span.
2. **Mechanic match (7).** Pass 2's own "Unsure about" named this exact fix:
   the left half's point was still a fully clean taper (`spike` with
   `r1=0.02`, `length=0.34`) — a complete miniature shield in its own right.
   Blunted it short (`r1` raised to `0.05`, `length` cut to `0.24`, same
   base position and angle) and added one small STEEL `slabf` shard
   (`(-0.11, -0.42, 0.09, 0.10)`, `rot=0.45`) below-right of the new blunt
   tip — a single fallen piece, not the right half's three-shard cluster, so
   the asymmetry pass 2 established (one half closer to whole, one half
   closer to shattered) survives rather than collapsing into a mirrored pair.

Rebuilt with `blender --background --python tools/blender/icons.py --
/tmp/icons_out` (apt-installed Blender 4.0.2, headless EGL —
`download.blender.org` still unreachable through this container's proxy;
needed `apt-get install python3-numpy libegl1 libgles2` first, the exporter's
`ModuleNotFoundError: No module named 'numpy'` and EGL library errors prior
passes on other icons also hit). Console: `TRIS 560 PARTS 6 BUDGET 700 ok`,
no warnings. Diffed all 36 icons against the committed set with a pure-Pillow
per-pixel mean/max (no render noise this run — every untouched icon came back
bit-identical, mean 0.0000/max 0, unlike the WORKBENCH-noise band earlier
passes on other icons had to filter out): only `frail.png` changed, mean
16.02/max 255. Kept only that file.

Composited the new PNG over the flat brown card-face standin
`RGB(139,105,74)` and looked at it three ways: the full 256px composite
(`design/renders/frail_icon_pass3_full.png`), a real 42px `LANCZOS`
downsample nearest-neighbour upscaled for viewing
(`design/renders/frail_icon_pass3_42px_big.png`), and a pure black-on-white
alpha silhouette (`design/renders/frail_icon_pass3_sil.png`), each read
beside the pass-2 versions rather than from memory. Also pixel-scanned rows
across the gap region directly (not just eyeballed): at `y=60..150` (the
main body height) there is now zero background pixel between the two
halves across `x=80..180` — they touch — while the CHARCOAL crack still
renders visibly over the seam in every view, so the "broken" read survives
the halves reading as one silhouette rather than two. A 3x zoom crop on the
left half's new blunt tip and shard
(`/tmp/frail_leftpoint_zoom.png`, not committed — a scratch check) confirmed
the tip reads as a short, cut-off wedge with a separate fallen piece below
it, not a rendering artefact.

- **Family distinction (7 → 9):** the silhouette crop shows one continuous
  blob at the top with a shallow notch at the seam, not two separate kite
  outlines — confirmed by the zero-gap pixel scan above, not assumed from
  the script. Not a 10: it is still visibly two different body colours
  (STEEL/NAVY) meeting at a crack, which is correct for Frail but keeps this
  short of a single unbroken silhouette.
- **Mechanic match (7 → 8):** both halves now show damage — the right half's
  jagged rubble (pass 2) and the left half's blunted tip plus its own fallen
  shard (this pass) — instead of one whole miniature shield next to one
  broken one. Not higher: the left half's top is still a fully intact
  rounded slab, so the asymmetry pass 2 established (one half closer to
  whole) is weaker but still present, not eliminated.
- **Silhouette @ 42px (8, unchanged):** confirmed directly in the 42px
  render — both halves, the crack, and all the rubble (old and new) stay
  distinct at the downsample; narrowing the gap didn't fuse anything into a
  smudge.
- **Colour & contrast (8, unchanged):** this pass touched no palette; the
  moved shapes kept their existing STEEL/NAVY/SILVER assignments.
- **Style consistency (8, unchanged):** the new shard reuses `slabf`,
  already this icon's own vocabulary for the crack and the right half's
  rubble; the blunted spike is the same primitive with different
  parameters, not a new construction.

**+3 total (38 → 41), not a plateau — crosses the loop's 40/50 stop line —
kept.** No line regressed. Third pass; stopping here per the loop's own stop
condition rather than spending the fourth.

`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless, Godot 4.7.1 —
this pass touches only `tools/blender/icons.py` and the regenerated
`frail.png`, no `game/**` GDScript).

## Unsure about (pass 3)

Whether narrowing the gap enough to reach zero background pixels between
the halves risks reading, at a real hand-card size well under the 42px
downsample used here, as one intact shield with a paint-on crack rather
than two separate pieces — the crack colour and the rubble both still carry
the "broken" read at 42px and above, but a smaller size than that wasn't
checked, and this pass's own render environment (apt Blender 4.0.2,
bit-identical diffs against every untouched icon this run) can't stand in
for a real card-hand look. Also unsure whether the left half's fallen shard,
being singular against the right half's three, reads as an intentional
asymmetry or as "the fixer forgot one" without the two halves' history
being known — a risk pass 2 already flagged for its own asymmetric split and
not newly introduced here.

## Batch 22 close-out — all thirty-six card icons scored

With `burn`, `stack`, `light` and `frail`, every icon named across
`design/ART-REVIEW.md`'s icon sections (the twenty-eight-icon block, the four
defensive-keyword icons, Strength/Dexterity, and the standalone Frail and
Light sections) has a scored `design/progress/<name>_icon.md`. Combined with
batches 1-13 (all fourteen beasts, all fourteen fight grounds, all nineteen
portraits), every asset this item's own text names as cloud-scoreable is now
scored, except the overworld map — reclassified `needs a screen` in batch 14
(no single flattened map image exists to score; it is many hex-tile `.glb`
models assembled at runtime, and `ART-REVIEW.md`'s own preview instructions
call for `screenshot.gd`, unavailable in this environment). This item's own
"Done when" line ("every asset that has a model has a scored
`design/progress/<asset>.md`") is met for every model- or image-backed asset;
the map is the sole named exception, filed under a different tag rather than
silently dropped. Left unchecked regardless, per this item's own rule — a
`cloud-safe` scoring item is never ticked by the routine, only by Nick
looking at the ranked list below.
