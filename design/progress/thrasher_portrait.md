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
