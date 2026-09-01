# silk_widow — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/silk_widow.png`
(512x512). Batch 13 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 5 | 4 | 5 | 5 | **22** |

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
