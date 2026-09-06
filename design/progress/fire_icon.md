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

## Pass 3 — fixer

Picked back up as `#86` duty 1 (lowest-scoring un-plateaued icon at 31/50,
tied with `rally_icon` at 32 but lower). Pass 2's own notes named the same
root cause under two different lines: **Family distinction (5)** — the
three-cone cluster is still the same gestalt as `peak()`'s straight
triangle-mountain cluster — and **Mechanic match (6, "Not higher: the
three main bodies are still perfectly straight-sided rigid cones")**. Both
point at the same fix: the bodies were `spike()` — a straight-sided cone —
and a straight cone is a mountain, not a flame. Real fire licks and bends;
`peak()` is deliberately rigid.

Applied one geometry change covering both named lines: replaced all three
main flame bodies' `spike()` calls with `limb()` — the tapered-tube-through-
a-path primitive `bow()` already uses for its curved wooden limbs, so this
introduces no new build vocabulary — threaded through three points each
(base, a mid-point offset sideways, a near-zero tip), instead of one
straight axis. Base and tip heights kept identical to the old spikes'
`z ± length/2` span (e.g. the old TANGERINE spike ran z −0.41 to 0.45;
the new limb's first and last points sit at the same two z values), so the
cluster's footprint and reach are unchanged — only the path between base
and tip now bends. Left the `GOLD` hot-core spike untouched (not one of
the two named lines, and pass 2 already fixed its own visibility problem).

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (apt's Blender 4.0.2, headless EGL — same environment
`frail_icon.md` pass 2 used, `download.blender.org` still unreachable
through the proxy; needed `pip install numpy` for python3.12 and
`apt install libegl1 libgles2` first, neither installed in this container
before this pass). Console: `TRIS 116 PARTS 4 BUDGET 700 ok`, no warnings.
Diffed all 36 icons against `HEAD` — every icon shows some non-zero diff
from Blender's WORKBENCH render noise (the same non-determinism `bog_leech_
portrait.md`/`silk_widow_portrait.md`/this file's own pass 2 all hit
before), `fire.png` at mean 14.83/max 255 versus every other icon's mean
0–11.2/max ≤126 — the same noise-vs-content gap those prior passes used to
draw the line; reverted the other 35 and kept only `fire.png`.

Composited the new PNG over the flat brown card-face standin RGB(139,105,74)
and looked at it three ways, same method as pass 2 and `frail_icon.md`:
the full 256px composite (`design/renders/fire_icon_pass3_full.png`), a real
42px Lanczos downsample nearest-neighbour upscaled for viewing
(`fire_icon_pass3_42px_big.png`), and a pure black-on-white alpha silhouette
(`fire_icon_pass3_sil.png`). Also re-rendered `peak.png` composited the same
way (`/tmp/peak_full.png`, not committed — a scratch comparison, not a new
asset) to check the family-distinction claim directly rather than by
memory: `peak` is three dead-straight grey/white triangles with a red flag,
unmistakably rigid; the new `fire` render shows a visible concave bend in
the left body's outer edge and a lean/S-curve through the centre body, at
both 256px and in the 42px downsample, and the silhouette crop shows the
same bends with colour removed.

- **Family distinction (5 → 8):** the bent, warm-toned cluster no longer
  shares `peak`'s straight-triangle-mountain gestalt — confirmed by the
  side-by-side render above, not just the geometry math. Not higher: it is
  still three tapering bodies clustered vertically, the same broad
  composition family as `peak`/`ascend`-style icons, just no longer
  confusable with one specifically.
- **Mechanic match (6 → 7):** the bend reads as a lick rather than a rigid
  spike at both 256px and 42px, and the gold core still pokes through from
  pass 2. Not higher: each body still tapers smoothly from a wide base to
  one point along its bent path, the same single-taper vocabulary as
  before — a real flame's silhouette also varies in *width* unevenly along
  its length, which bending alone doesn't add.
- **Silhouette @ 42px (7 → 8, not one of the two, moved as a side effect):**
  the bend survives the downsample — the left body's concave notch and the
  centre's lean are both visible in `fire_icon_pass3_42px_big.png`, not
  just at full size.
- **Colour & contrast (6, unchanged):** this pass touched no palette or
  material — pass 2's fix stands untouched.
- **Style consistency (7 → 8, not one of the two, moved as a side effect):**
  `limb()` is already the primitive `bow()` uses for its curved wooden
  limbs; bending `fire`'s bodies with it is the *same* vocabulary the set
  already has, not a new one, which is a stronger form of consistency than
  pass 1/2 scored this line for (matching the bevel/primitive style
  generally).

**+6 total (31 → 37), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 3)

Whether "licking, bent flame" reads as *fire specifically* to someone who
has never been told the build intent, versus just "an organic, non-rigid
warm shape" — the same kind of open question `frail_icon.md` pass 2 raised
for its own fix, and not one a static composite against a flat standin can
settle; that needs a real card-hand read. Also unsure whether a fourth pass
targeting Colour (6, now tied-lowest with Mechanic) — the tan/orange limb's
value closeness to the brown standin, the same near-miss class
`rally_icon.md` pass 2 flagged for its own limb — would be worth the
remaining budget, or whether 37/50 is close enough to the 40 stop line that
Nick should look at it before another pass is spent.

## Pass 4 — cloud, backlog #86 duty 1 (fourth and final pass)

Picked back up per pass 3's own open question — 37/50, tied-lowest lines
Colour (6) and Mechanic (7), both named there as candidates and neither
touched yet. This is the last of the loop's 4 allowed passes either way.

Sampled the actual rendered pixels of the left `ORANGE` body (not just the
raw swatch) before touching anything: `(203,129,94)` against the standin
`(139,105,74)` — gap `(64,24,20)`, weak on G and B, the same "R survives,
G/B don't" shape `rope_icon.md` and `rally_icon.md` both hit for their own
warm limbs.

Applied both named lines with two changes, in-lane (`tools/blender/icons.py`
only, no palette edit, no shared constant moved):

1. **Colour & contrast (6).** Swapped the left body from `ORANGE` to
   `PEACH` — raw swatch gap `(102,46,34)`, positive on every channel, versus
   `ORANGE`'s `(116,21,-6)`. `RUST` (right) and `TANGERINE` (centre) left
   untouched; the diagnosis named "the tan/orange limb" specifically, and
   pass 2's own sampling already found `RUST`'s rendered B-gap acceptable.
2. **Mechanic match (7).** Every body still tapered evenly from a wide base
   to one point, one width profile — the diagnosis's own words. Added one
   extra waypoint to the centre (tallest, most prominent) `TANGERINE` body's
   `limb()` call, a third of the way up from the base, radius pinched to
   `0.07` where a straight taper through the old two points would put it at
   roughly `0.19` — a real waist, not a cosmetic nudge — so the body narrows
   then flares back out to the existing mid-point before tapering to the
   tip. Base and tip radii/positions untouched, so the cluster's footprint
   and reach are unchanged, same discipline pass 3 used for the bend.

Rebuilt with the real `blender` binary (apt package, 4.0.2 — headless; this
container's copy needed `libegl1`/`libgles2` installed and a working
`numpy` for its embedded Python 3.12 before it would run the exporter at
all, same missing pieces `fire_icon.md` pass 3 and `frail_icon.md` pass 2
both hit; `download.blender.org` is still unreachable through this
container's egress proxy, confirmed again this run). Rebuilt the full
36-icon set and diffed every file against `HEAD` by mean per-channel pixel
difference: most icons came back at 0.000 (bit-identical), a handful of
untouched icons (`relic` 4.439, `strength` 4.228, `bow` 2.843, `timer`
2.810, `light` 1.713, `support` 0.719, `thorns` 0.701, `bomb` 0.547,
`flask` 0.159, `sword` 0.296) showed nonzero drift from this run's
particular Blender/driver combination — a wider noise band than prior
passes recorded, and specifically wide enough that `fire.png`'s own whole-
image mean (4.205) sits *inside* it, not clearly above it. Given that,
whole-image mean diff was not trusted alone this pass — reverted the other
35 icons and confirmed the `fire.png` change by direct inspection instead:
alpha bbox unchanged at `(48, 5, 210, 228)` (no new clipping), and a
region-sampled pixel average, not a whole-canvas one, on the left body
specifically.

Looked at the result three ways: a full 256px composite against the flat
brown card-face standin (`design/renders/fire_icon_pass4_full.png`), a real
42px `LANCZOS` downsample nearest-neighbour upscaled for viewing
(`fire_icon_pass4_42px_big.png`), and a solid black-on-white alpha
silhouette (`fire_icon_pass4_sil.png`), each placed beside the pre-pass
version. A 3x zoom crop on the centre body's base
(`fire_icon_pass4_centrezoom.png`) was also read directly to confirm the
waist reads as a concave notch rather than a rendering artefact.

- **Colour & contrast (6 → 8):** region-sampled the left body's actual
  rendered pixels (not the raw swatch): old average `(203,129,94)` against
  standin `(139,105,74)`, gap `(64,24,20)`; new average `(193,145,121)`, gap
  `(54,40,47)` — R eased slightly but G nearly doubled and B moved from a
  weak +20 to a strong +47. Confirmed visible, not just numeric, in both the
  full composite and the 42px downsample: the left body reads as a clearly
  different, cooler-leaning tone from the card face where it used to nearly
  match it. Not a 9-10: `RUST` and `TANGERINE` were untouched by this pass's
  two-fix budget and the centre body's own near-standin patches (visible in
  the zoom crop, in the concave crease the waist introduces) remain a real
  AO-shadow near-miss, the same kind pass 3 flagged as not responding to a
  swatch swap.
- **Mechanic match (7 → 8):** the centre body now narrows to a visible waist
  roughly a third of the way up before flaring back out, confirmed in the
  full composite, the 42px downsample, and the zoom crop — a real width
  variation along the body's own length, which is exactly what the
  diagnosis asked for and a bend alone (pass 3's own fix) didn't add. Not
  higher: only one of the three bodies got the treatment, so the cluster as
  a whole still reads mostly as three smoothly-tapered shapes with one
  irregular member, not a fully organic flame.
- **Silhouette @ 42px (8 → 9, not one of the two, moved as a side effect):**
  the waist is a real geometry change, so it shows in the pure alpha
  silhouette too, not just the coloured render — the side-by-side
  silhouette crop shows a new concave notch low on the centre spike that
  the pre-pass outline doesn't have, adding a touch of the irregularity
  pass 1's own Silhouette line originally asked for beyond what pass 3's
  bend alone gave it.
- **Family distinction (8, unchanged):** the cluster is still three bodies
  of the same broad vertical-taper composition; neither fix changed the
  count or arrangement of parts.
- **Style consistency (8, unchanged):** `limb()` with an extra waypoint is
  the same primitive already in use, not a new construction; a colour swap
  touches no geometry vocabulary at all.

**+4 total (37 → 41), not a plateau — clears the loop's 40/50 stop line —
kept.** No line regressed. Fourth and final pass under this loop's own
4-pass cap either way.

`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless, Godot
4.7.1 — this pass touches only `tools/blender/icons.py` and the
regenerated `fire.png`, no `game/**` GDScript).

## Unsure about (pass 4)

Whether the whole-image mean-pixel-diff check this item and several others
(`rope_icon.md`, `rally_icon.md`, this file's own pass 3) have used to tell
a real change from render noise is still reliable on this container's
particular Blender/driver combination — this run's noise band (up to 4.439
on an untouched icon) came close enough to `fire.png`'s own whole-image
mean (4.205) that the diff alone would have been ambiguous; a region-
sampled pixel average and a direct look at the composite were needed to
settle it here, and a future pass on any icon should sample a region, not
just trust the whole-canvas number, if the two are close. Also unsure
whether the remaining `RUST`/`TANGERINE` near-standin patches (visible only
in the tight zoom crop, not in the full-size or 42px views) are worth a
fifth pass if the loop's cap is ever revisited — this file is at its
4-pass limit regardless.
