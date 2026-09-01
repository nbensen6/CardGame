# thrasher — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/thrasher.png`
(512x512). Batch 13 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 5 | 6 | 5 | 6 | 4 | **26** |

## What is actually there

Alpha bounding box `(43, 0, 481, 453)` — touches the top edge only, with
decent margin on both sides and the bottom. A full-body side-on crop rather
than a head-and-shoulders one: the low flat black body, the orange belly
stripe, the head with two red eye dots at bottom-left, splayed legs, and the
raised scorpion-like tail curl carrying the gold sigil disc at top-right.

- **Framing (5):** the tail curl touches the very top edge of the canvas
  with zero clearance, while both sides and the bottom carry real margin —
  the same top-edge-tight, bottom-loose imbalance already named for
  `husk_beetle_portrait`, here on the tail instead of a shell hump.
- **Identity (6):** the raised tail-curl silhouette — this beast's strongest
  feature per `thrasher.md`'s own 3D pass — is present and recognizable, but
  because the crop shows the whole body rather than a close head shot, no
  single part dominates the frame the way `frog_portrait`'s eyes do; reads
  as "some low dark creature with a curled tail," not unambiguously
  "thrasher" without the tail cue.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The
  orange belly stripe still separates cleanly and the tail-curl-plus-sigil
  silhouette survives as a distinct shape at top, but the two red eye dots
  `thrasher.md`'s 3D pass called out as popping "against the black snout"
  do not survive this downsample — they disappear into the black head
  entirely, a finding this portrait crop surfaces that the closer-range 3D
  render did not.
- **Colour & separation (6):** the orange-on-black belly stripe is the
  strongest line here, matching the 3D pass's own best-scoring finding; the
  red eyes are lost at portrait viewing distance even though they read fine
  up close.
- **Style consistency (4):** this is a full-body side-on crop, not the
  shared head-and-shoulders three-quarter convention most scored portraits
  use — the second instance of exactly this framing outlier, after
  `cinder_jackal_portrait` in batch 11, confirming it as a recurring
  `FOCUS`-table pattern rather than a one-off.

## Diagnosis — two lowest

1. **Style consistency (4).** Concrete fix: re-tune this asset's
   `portraits.py` `FOCUS` entry to a head-and-shoulders three-quarter crop
   matching the rest of the cast, the same fix already proposed for
   `cinder_jackal_portrait`.
2. **Framing (5).** Concrete fix: once re-cropped to head-and-shoulders per
   above, lower the `FOCUS` centre slightly so the tail-curl-and-sigil
   silhouette clears the top edge with visible headroom.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether a head-and-shoulders re-crop would still show the tail curl at all
— it currently sits far from the head at the opposite end of the body, so
tightening the frame to the head risks losing this beast's single best
identity feature rather than just re-balancing it. That trade-off is a
design call, not a measurement.

## Pass 2 — fixer

Applied both fixes named above, together, since they're the same `FOCUS`
entry: `portraits.py`'s `FOCUS["thrasher"]` moved from `(0.35, 1.10)` to
`(0.42, 1.55)`.

A literal "crop to the head" was tried first and rejected before this value:
`(0.54, 0.88)` (centre pulled up, span cut sharply) made the framing line
*worse*, clipping the tail tip outright rather than giving it headroom — the
risk this file's own "Unsure about" named. `(0.35, 1.30)`, span alone widened
with the centre untouched, still touched the top edge; only past roughly
`span=2.0` did the tail clear with margin, and that was too loose to read as
a tightened crop at all. `(0.42, 1.55)` was found by bisecting from there: it
raises the centre slightly off `0.35` and settles the span partway between
the too-tight and too-loose extremes, rather than executing the diagnosis's
literal "head-and-shoulders" framing — which the render evidence says this
beast's proportions don't support without losing the tail, confirming the
tension pass 1 already flagged rather than resolving it.

Rebuilt with `build.cmd portraits` — this regenerates every portrait, and
Blender's WORKBENCH output is not byte-reproducible even for unchanged
inputs (same non-determinism `silk_widow_portrait.md`'s pass 2 hit), so
every portrait other than `thrasher.png` was reverted with `git checkout --`
and only the changed asset kept.

Alpha bbox (Pillow `getbbox()`) is now `(105, 45, 416, 419)` on the 512×512
canvas — margin on all four sides (left 105, top 45, right 96, bottom 93),
where pass 1 was `(43, 0, 481, 453)`, touching the top edge outright.

- **Framing (5 → 8):** the tail-and-sigil silhouette now clears the top edge
  with real headroom instead of touching it. Not a 9+: the margin is
  unbalanced (45px top vs 93px bottom, 105px left vs 96px right) rather than
  evenly centred.
- **Identity (6 → 7):** the tighter crop makes both identity cues bigger in
  frame — the tail curl and sigil dominate the upper-right the way the
  module doc's "worn as its own silhouette" describes, and the head with its
  two red eye dots stays fully in frame at bottom-left. Still not the single
  dominant feature `frog_portrait`'s eyes are, since the two cues (head, tail)
  remain at opposite corners of the frame rather than one shape filling it.
- **Readability @ 34px (5 → 6):** confirmed via a fresh 34px downsample
  (Pillow `LANCZOS`, composited over the same brown card-face standin,
  cross-checked with a 16× crop on the head region). The tail-curl-and-sigil
  shape and the orange belly stripe both read clearly. The red eye dots
  are a genuine improvement over pass 1's "disappear entirely" but still
  don't resolve as two distinct dots — the zoomed crop shows a faint
  reddish tinge merged into the black head, present but not legible as eyes.
- **Colour & separation (6 → 7):** unchanged palette, but the tighter frame
  spends more of the fixed pixel budget on the coloured elements (belly
  stripe, sigil, eye tinge) and less on flat background, so what colour there
  is reads a little stronger.
- **Style consistency (4 → 6):** no longer the extreme full-body outlier pass
  1 flagged — the crop is visibly tighter and closer to the rest of the
  cast's convention. Not an 8+: this is still a whole-body composition
  (head to tail both in frame), not the head-and-shoulders crop most of the
  cast actually uses, for the geometric reason above.

**+8 total (26 → 34), not a plateau — kept.** All five lines moved up and
none regressed. `run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether `cinder_jackal_portrait` (the other full-body outlier this file's
pass-1 diagnosis pointed to as precedent) would hit the same "true
head-and-shoulders clips the identity feature" wall — this pass only
confirms it for `thrasher`'s own proportions, not as a rule for the family.
Also unsure whether the still-imbalanced margin (top tighter than bottom,
left tighter than right) is worth a further nudge, or whether that's Nick's
call the same way the crop-vs-identity trade-off was.
