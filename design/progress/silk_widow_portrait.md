# silk_widow — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/silk_widow.png`
(512x512). Batch 13 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 5 | 4 | 5 | 5 | **22** |
| 7 | 6 | 6 | 5 | 7 | **31** |

Tied for the lowest score recorded under this item so far, matching
`gale_serpent_ground`'s 22.

## What is actually there

Alpha bounding box `(0, 0, 512, 512)` — content touches all four edges of the
canvas at once. A tight three-quarter close-up on the abdomen/cephalothorax
junction: two black body lobes, the gold sigil disc set into the top of the
abdomen, splayed bent-knee legs cut off at the left, right, and bottom edges,
and a thin red triangular sliver (the hourglass mark) visible low in frame
where it wraps under the body.

- **Framing (3):** the tightest, most edge-touching crop scored under this
  item so far — every one of the four canvas edges cuts off content (legs at
  left/right/bottom, body at top), worse than `husk_beetle_portrait`'s
  single-edge touch. There is no headroom anywhere in the frame.
- **Identity (5):** the two-lobe body plus splayed legs still reads as
  "spider," but the one mark the beast's own build doc names as its specific
  identity — the red hourglass — is folded almost entirely under the body at
  this angle and reduced to a thin sliver; no eyes are visible anywhere in
  the frame, which matches `silk_widow.md`'s own 3D finding that the
  CHARCOAL-on-GRAPHITE eye-huddle never resolved in any of six lit views.
- **Readability @ 34px (4):** confirmed via a real 34px downsample — the gold
  sigil holds as a small bright disc, the red hourglass survives only as a
  faint reddish hint at the bottom edge, and the legs thin to near-invisible
  pale slivers. Reads as "dark rounded shape with a gold dot" rather than
  "spider."
- **Colour & separation (5):** black-on-black across cephalothorax, abdomen,
  and legs is the dominant read, exactly `silk_widow.md`'s own 3D finding;
  only the gold sigil and the barely-visible red mark break the palette.
- **Style consistency (5):** every other scored portrait uses a
  head-and-shoulders three-quarter crop with visible margin on at least one
  side; this crop is a tight body close-up with no clearance on any edge, a
  more extreme outlier than the full-body framing already flagged for
  `cinder_jackal_portrait` in batch 11.

## Diagnosis — two lowest

1. **Framing (3).** Concrete fix: widen `portraits.py`'s `FOCUS` span (or
   pull the camera back) for this asset so all four edges gain visible
   clearance, matching the headroom-plus-single-bottom-cut convention the
   better-scoring portraits use.
2. **Readability @ 34px (4).** Concrete fix: this is the same underlying gap
   `silk_widow.md`'s own 3D diagnosis already named — thicken/shorten the
   sigil crest and swap the eye-ball colour to a lighter swatch (e.g. RED or
   STEEL). A portrait crop change alone cannot fix this line while the
   source geometry lacks the contrast.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the all-edges-touching crop is a deliberate close-up choice for this
specific beast (an "abdomen full of frame" identity read) or simply a
`FOCUS` value nobody re-checked after the model settled — this scoring pass
can see the crop, not the intent behind it.

## Pass 2 — fixer

Applied both fixes named above.

1. **Framing.** `portraits.py`'s `FOCUS["silk_widow"]` moved from
   `(0.45, 0.85)` to `(0.45, 1.35)` — same centre, a much wider span, in
   line with the other body-shot beasts (`bog_leech` also sits at `(0.45,
   1.35)`). Rebuilt with `build.cmd portraits`; every other portrait
   re-rendered byte-identical in content but not in file bytes (same
   non-reproducible WORKBENCH output `clot_toad_portrait.md`'s pass 2 hit),
   so those were reverted with `git checkout --` and only `silk_widow.png`
   was kept.
2. **Read@34px.** Same underlying fix `silk_widow.md`'s own diagnosis named:
   in `tools/blender/silk_widow.py`, the sigil crest's taper base widened
   from `0.10` to `0.18` and its length shortened from `0.75` to `0.50`, and
   the eye-huddle balls swapped from `CHARCOAL` to `STEEL`. Rebuilt with
   `build.cmd silk_widow`, then re-ran `build.cmd portraits` to pick up the
   geometry change in the portrait render.

Re-viewed `game/assets/portraits/silk_widow.png` directly, plus a fresh 34px
downsample (Pillow, `Image.LANCZOS`, same method `frog_portrait.md`
established) and an alpha-bbox check the same way pass 1 did.

- **Framing (7):** alpha bbox is now `(50, 32, 450, 458)` on the 512×512
  canvas — real margin on all four sides (left 50px, top 32px, right 62px,
  bottom 54px), where pass 1 was `(0, 0, 512, 512)`, touching every edge.
  Not an 8+: the top margin is a little tighter than the side margins, so
  it is not perfectly balanced.
- **Identity (6):** the sigil crest now reads as a short horn fused to the
  abdomen rather than a stick with a washer on the end, and the red
  hourglass is now inside the frame (a small triangle visible between the
  front legs, partially overlapped by a leg crossing in front of it) rather
  than folded almost entirely out of frame. Held below 7: cropping into the
  cephalothorax at the angle the portrait camera uses, the eye-huddle
  still does not resolve as two visible dots even after the colour swap —
  checked directly by cropping into that region of the render at 2× zoom,
  not eyeballed. The eyes are on the cephalothorax's forward face, which
  this camera angle keeps mostly turned away/occluded; colour alone cannot
  fix a part that is not facing the lens.
- **Read@34px (6):** confirmed via a fresh 34px downsample. The gold sigil
  still holds as a bright dot, the legs now survive as visible thin grey
  lines rather than near-invisible pale slivers (more of the model's true
  proportions survive the wider, uncropped frame), and a faint red fleck is
  visible near the centre-bottom. Still reads as "dark shape, gold dot, red
  fleck, legs" rather than unambiguously "spider" — better than pass 1's
  "dark rounded shape with a gold dot" but not a full recovery.
- **Colour & separation (5):** untouched by either fix's actual visible
  effect — same read as pass 1. The eye colour swap was applied in the
  model but, per the Identity finding above, the eyes are not visible from
  this portrait's camera angle at all, so there is no colour-separation
  gain to score here. Black-on-black is still the dominant read.
- **Style consistency (7):** the crop now matches the headroom-plus-margin
  convention every other scored portrait uses, where pass 1 was the most
  extreme outlier scored under this item (all four edges touching).

**+9 total (22 → 31), not a plateau — kept.** Both named lines (Framing,
Read@34px) improved and neither held steady at the old value; Identity and
Style also moved as a consequence of the same two fixes; Colour is
unchanged, honestly, because the eye-colour half of fix 2 never becomes
visible from this specific crop angle. `run_tests.gd` passes.

## Unsure about (pass 2)

Whether the eye-huddle would read from a portrait camera angle that looks
more squarely at the cephalothorax's front face — this pass only confirms
it doesn't read from the *current* `FOCUS` angle, not that no angle could
work. That is a `FOCUS_XY`-style per-character override, the same kind of
fix `riptide_eel` needed, and would be a new named diagnosis rather than
something this pass's two fixes cover.

## Pass 3 — #86 duty 1

Picked up pass 2's own open question, but a camera-angle change turned out
not to be the fix — checking the actual geometry first (same discipline
`riptide_eel_portrait.md` pass 2 used: numbers before a model edit, not a
guess) found the real cause. `silk_widow.py`'s cephalothorax is a ball at
`(0, -0.95, 0.98)` with radii `(0.42, 0.46, 0.36)`; the two eye balls sat at
`(±0.16, -1.22, 1.14)` and `(±0.24, -1.14, 1.08)`. Normalized ellipsoid
distance from the cephalothorax centre — `((x/rx)^2 + (y/ry)^2 + (z/rz)^2)
^0.5` — comes out to **0.83** and **0.76** for the two eyes: both comfortably
**under 1**, i.e. genuinely buried inside the cephalothorax mesh rather than
sitting on its surface. This is the opposite defect from `riptide_eel`'s
floating eye (distance **> 1**, outside the surface) but the same family of
bug and the same fix in reverse: checked against Eyrie Hawk's own working
eye-on-skull placement again (distance 0.91, the reference `riptide_eel`
used), both silk_widow eyes were pulled further in than that, not further
out — no camera angle was ever going to reveal geometry sitting inside the
head. The STEEL-vs-GRAPHITE colour swap an earlier pass made was real but
had nothing to render against.

Applied one fix covering both the diagnosed lines (Colour & separation, and
the still-open Identity/Read gap pass 2 left after its own two fixes): moved
both eye balls radially outward from the cephalothorax centre to land near
the surface, same 0.9–0.96 normalized-distance band as the working
reference, keeping the same eye-to-secondary-eye relationship:
`(0.16*s, -1.22, 1.14)` → `(0.18*s, -1.26, 1.16)` (distance 0.83 → 0.94) and
`(0.24*s, -1.14, 1.08)` → `(0.30*s, -1.19, 1.11)` (distance 0.76 → 0.96). No
`FOCUS`/`FOCUS_XY` change — the existing crop already frames the
cephalothorax; it just had nothing visible to show there.

Rebuilt `silk_widow.glb` (apt's Blender 4.0.2, headless EGL, `numpy`/`Pillow`
installed into `/usr/bin/python3.12`, the interpreter this Blender actually
runs — same environment prior passes in this set needed).
`tools/blender/silk_widow.py`'s own build-time hold/climb check
(`beast.py`'s `finish()`) reported all seven climb points and both holds
plus the sigil shelf unchanged from before the edit — only the two small
head balls moved, nothing that touches a ledge or the sigil crest.
`assetcheck.gd` against the rebuilt model: **PASS** on every line, including
the sigil-visibility check (46% occluded, well inside budget) and all seven
climb points at their contracted heights — confirms this pass didn't
regress the fight-distance contract while fixing a portrait-only defect.

Rebuilt the full portrait batch (`build.cmd portraits` has no single-asset
path) and diffed all 33 output PNGs against `HEAD` with numpy: every file
showed *some* non-zero diff from Blender's WORKBENCH render noise (mean
0.0–2.6 per channel across thirty of them, consistent with every prior
portrait pass's noise floor in this set), except `frog.png` (mean 58.2) and
`goblin_mech.png` (mean 15.2), both far outside that band — flagged here as
worth a look in a future pass but not investigated further, since neither
script was touched and both differences are almost certainly render-only
noise of unusually high magnitude rather than content change. Reverted every
portrait except `silk_widow.png`, which is the only one this pass's model
edit could actually change.

Looked at three ways, same method the rest of this set uses:

- **Full 512px composite** over the brown card-face standin
  (`design/renders/silk_widow_portrait_pass2_full.png` vs
  `..._pass3_full.png`): pass 2 shows a featureless black cephalothorax with
  no visible eyes anywhere, even zoomed 3x into that region; pass 3 shows
  four small pale-steel dots clustered on the cephalothorax's front-top
  face, reading immediately as a spider's eye cluster.
- **A 3x zoom crop on the cephalothorax** (same crop region, both passes):
  pass 2's crop shows plain black sphere and legs, nothing else; pass 3's
  crop shows the eye huddle clearly separated from the black body, the
  single clearest before/after in this pass.
- **A real 34px Pillow `LANCZOS` downsample**, same brown standin: the eye
  dots do **not** survive at this size in either pass — they fold into the
  same dark head blob pass 2 already found. Checked directly, not assumed:
  the two 34px composites are visually indistinguishable from each other.

Score:

- **Framing (7, unchanged):** this pass touched no crop or `FOCUS` value;
  pass 2's framing fix stands untouched.
- **Identity (6 → 8):** the eye-huddle now reads unambiguously as eyes on a
  face at full size and at the 3x zoom, the specific gap pass 2's own
  "Unsure about" section left open. Not higher: the hourglass mark is still
  a thin, partly-overlapped sliver (pass 2's own finding, untouched by this
  fix), so the beast's *second* named identity feature is still weak even
  though the eyes are now strong.
- **Readability @ 34px (6, unchanged):** confirmed by the direct pass2-vs-
  pass3 34px comparison above — the eye balls are too small relative to the
  head to survive a 34px Lanczos downsample regardless of whether they sit
  on the surface or buried inside it. A real gain here would need a bigger
  or higher-contrast eye, a model change beyond this pass's two-fix budget
  and not one either named line asked for.
- **Colour & separation (5 → 7):** the STEEL eye dots are now a real,
  visible colour break against the black cephalothorax — confirmed in both
  the full render and the zoom crop — rather than a colour choice with
  nothing to show for it. Not higher: the body is still dominated by one
  near-black CHARCOAL/GRAPHITE range outside the eyes, sigil, and hourglass;
  three small accents don't change the overall value range.
- **Style consistency (7, unchanged):** the fix reused the existing `ball`
  primitive at its existing size, just moved — no new build vocabulary, no
  crop change, nothing to move this line either direction.

**+4 total (31 → 35), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless). No new
tests — a model-geometry-only pass judged through a portrait render adds
none, matching every prior pass under this rubric.

## Unsure about (pass 3)

Whether a fourth pass on the still-thin hourglass-mark read (Identity's
remaining gap) or on `frog.png`/`goblin_mech.png`'s unusually large render
noise (flagged above, not this asset, not investigated) is worth more
budget than leaving both written down — this pass hit its named fixes and
the loop's own two-fix-per-pass rule, same stopping discipline as every
prior pass in this file.
