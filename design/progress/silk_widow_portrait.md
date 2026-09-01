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
