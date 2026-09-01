# fire — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
18 — continuing the icon rubric batches 14-17 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/fire.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Third of batch 18's
four — the "four basic damage-type icons" (sword, bow, fire, skull).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-17 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and >10-alpha-threshold bbox method
batch 17 added.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 5 | 3 | 2 | 7 | **23** |

**Tied for the lowest score recorded under this item across all eighteen
batches**, matching batch 17's `rally`.

## What is actually there

Three tapering triangular spikes clustered together — a tall centre spike
flanked by two shorter ones — rendered in a narrow band of muted tan/rust
tones. `icons.py`'s own `fire()` function specifies three visually distinct
palette colours (`ORANGE`, `TANGERINE` for the two outer/rear cones, a
brighter `GOLD` for a fourth inner spike meant to be a hot core), but none
of that separation survives to the actual PNG: directly sampling pixels down
the icon's centre column returns values clustered entirely within
RGB(185–216, 105–160, 60–135) — no bright gold spike is visible anywhere in
the render, and the whole shape sits in one narrow muted salmon-tan band.
`ORANGE` and `TANGERINE` are themselves nearly identical in the source
palette (`swatch(16,192)` = RGB(255,126,68) vs `swatch(48,192)` =
RGB(255,129,68), a 3-point difference in one channel), so even before
whatever shading muted them further, the build script asked for two
"different" flame colours that are effectively the same colour.

- **Silhouette @ 42px (6):** the three-cone cluster stays legible as three
  distinct triangular shapes of different height rather than fusing into
  a blob, but straight-sided rigid cones read as spikes or a small
  mountain range, not as flame — real fire silhouettes are usually
  tapering and irregular/wavy, not perfectly straight triangles.
- **Family distinction (5):** the three-triangle cluster (one tall centre,
  two shorter flanking) is essentially the same composition as `peak`'s
  three-mountain-and-flag icon, already in the set — `peak` renders in
  clearly distinct SLATE/PEWTER/WHITE grey tones with a red flag, so the
  two are not confused by colour, but `fire`'s failure to render any
  flame-like colour (see Colour, below) narrows that gap: a
  colour-blind or fast glance risks reading both as "triangle cluster."
- **Mechanic match (3):** nothing about a cluster of plain tan cones reads
  as "burning damage" without the tooltip already known — no flicker
  shape, no visible hot core, no colour cue that says fire rather than
  rock, sand, or a tent.
- **Colour & contrast (2):** the lowest colour score recorded under this
  item — every sampled pixel sits within one narrow muted tan/salmon band,
  close in both hue and value to the RGB(139,105,74) card-face standin
  itself, and the build script's intended bright `GOLD` (255,192,68) core
  is not visible anywhere in the rendered asset.
- **Style consistency (7):** the low-poly bevelled-cone construction
  matches the shared vocabulary of the rest of the set (e.g. `peak`'s own
  spikes); only the colour execution is the outlier, not the geometry
  style.

## Diagnosis — two lowest

1. **Colour & contrast (2).** Concrete fix: the render needs to actually
   show the palette the build script already specifies — either the
   material/lighting setup is muting `ORANGE`/`TANGERINE`/`GOLD` down to
   near-identical tans, or (separately, and worth fixing regardless) the
   palette itself should widen the gap between `ORANGE` and `TANGERINE`,
   which differ by 3 in one channel and would look near-identical even
   rendered faithfully.
2. **Mechanic match (3).** Concrete fix: downstream of the colour fix
   above — once the hot gold core and the orange/tangerine flame body
   actually separate in the render, the shape would read far more like
   fire; no additional geometry change diagnosed as necessary.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the colour loss happens in Blender's render/lighting pass or
somewhere in the export-to-PNG step — this scoring pass only confirms the
final PNG's pixels don't show the palette the build script asks for, not
which stage of the pipeline is responsible. Also unconfirmed: whether
`peak`'s greyscale mountain silhouette and `fire`'s muted-tan mountain-like
silhouette are ever visible on cards at the same time in an actual hand,
which would be the real test of whether the shape overlap named above
matters in practice.
