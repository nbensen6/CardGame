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

## Pass 2 — fixer

Neither named line was actually a lighting/export bug — pixel-sampling the
committed PNG (not just eyeballing the render) at the world coordinates of
each cone showed the real cause: `icons.py`'s `taper()`/`spike()` places a
cone's *centre* at `loc` and extends `±length/2` along its axis, so the old
`GOLD` core (`loc=(0.0, -0.16)`, `r0=0.13`, `length=0.44`) spanned world
z −0.38 to 0.06 — entirely inside the centre `TANGERINE` cone's own z-range
(−0.41 to 0.45), and at every height in that overlap `TANGERINE`'s radius
(0.21–0.11) was larger than `GOLD`'s (0.13→0.01). One cone fully enclosed
inside a bigger one, geometrically, regardless of colour or lighting — the
"whether it's the render pass or the export step" question in Pass 1's
Unsure section didn't apply; it never reached either stage.

Applied both named lines with two changes, in-lane (no palette edit, no
budget/constant moved):

1. **Colour & contrast (2).** The two outer cones were both `ORANGE`
   (`swatch(16,192)` = RGB 255,126,68); recoloured the right one to `RUST`
   (`swatch(112,192)` = RGB 231,96,71 — already imported, already in
   `icons.py`'s top-level import list, not a palette edit) so the two flanks
   read as distinct hues instead of the same colour twice. Left as `ORANGE`/
   centre `TANGERINE`/right `RUST` — three genuinely different warm tones
   instead of two `ORANGE`s and a near-identical `TANGERINE`.
2. **Mechanic match (3), the hidden core.** Raised and lengthened the
   `GOLD` cone from `loc=(0.0, -0.16)`, `r0=0.13`, `length=0.44` to
   `loc=(0.0, 0.125)`, `r0=0.16`, `length=0.85`, so its tip (z=0.55) clears
   the `TANGERINE` cone's own tip (z=0.45) by a margin comfortably inside
   the ±0.575 ortho frame — the same off-canvas-clipping trap `rally_icon`'s
   pass 2 hit, checked for and avoided here. The core is no longer enclosed;
   it pokes out above the flame body as a visible pale tip.

Rebuilt with `build.cmd icons` — no warnings for `fire`, no other icon
script touched. Renders: `design/renders/fire_pass2_full.png` (composited
on the same brown card-face standin Pass 1 used) and
`design/renders/fire_pass2_42px_big.png` (42px Lanczos downsample, nearest-
neighbour upscaled for viewing, same method as `rally_icon`/`lift_icon`).
Alpha bbox moved from `(47, 27, 205, 226)` to `(47, 5, 205, 220)` — taller
by the raised core, still with margin on all four edges.

Sampled actual PNG pixels (not just eyeballing the render) to confirm the
separation is real, not a rendering illusion: gold-tip area
`(195, 159, 100)` vs centre-body `(196, 120, 82)` vs left-orange
`(195, 116, 80)` vs right-rust `(195, 118, 105)` — G channel spread of 116
to 159 (was clustered 119–131 across the whole icon in Pass 1) and a
visible B-channel split between the orange and rust flanks (80 vs 105).

- **Colour & contrast (2 → 6):** the gold core, the tangerine body, and the
  orange/rust flanks are now four visibly distinct zones in both the full
  render and the 42px downsample — confirmed by both the crop and the pixel
  samples above. Not higher: the whole icon is still noticeably darker/more
  desaturated than the raw palette values (e.g. raw `GOLD` is RGB 255,192,68;
  the rendered core peaks around 195,159,100) — that muting is `render()`'s
  shared `BLENDER_WORKBENCH`/`STUDIO`/`exposure=0.85` setup in `icons.py`,
  used by all 28 icons, not something this pass's two-fix budget can touch
  without moving a shared constant for every other icon too.
- **Mechanic match (3 → 6):** a hot core is now visible poking above the
  main flame body at both 256px and the 42px downsample, which is what this
  line asked for. Not higher: the three main bodies are still perfectly
  straight-sided rigid cones (Pass 1's Silhouette line called this out —
  "real fire silhouettes are usually tapering and irregular/wavy, not
  perfectly straight triangles"), which neither named fix touched.
- **Silhouette @ 42px (6 → 7, not one of the two, moved as a side effect):**
  the raised core adds a second, paler tier to the tallest spike's tip in
  the 42px downsample — reads more like a flame lick with a hot tip than a
  single flat triangle. Not fixed further: still three straight cones at
  root, same caveat as Mechanic above.
- **Family distinction (5, unchanged):** the three-spike-cluster silhouette
  itself didn't change shape, so it's still the closest match to `peak`'s
  triangle-cluster composition in the set; the new colour variety helps a
  colour-aware glance but this line scores shape, which this pass's two
  fixes didn't touch.
- **Style consistency (7, unchanged):** still the same bevelled-cone
  construction as every other icon in the set; repositioning and recolouring
  existing primitives doesn't change the build vocabulary.

**+8 total (23 → 31), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether the shared `icons.py` render/lighting setup (`BLENDER_WORKBENCH`,
`STUDIO` shading, `exposure=0.85`, cavity on) is muting saturation more than
intended across the whole 28-icon set — flagged here rather than touched,
since it's shared infrastructure and moving it would silently re-render
every other committed icon, which is exactly what the hard rules warn
against. If Nick wants brighter icons generally, that's a one-line change
in `render()`, reviewed once, not a per-asset fix.
