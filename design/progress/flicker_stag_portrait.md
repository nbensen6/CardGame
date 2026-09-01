# flicker_stag — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/flicker_stag.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 8 | 6 | 5 | 7 | **32** |

## What is actually there

A head-and-shoulders three-quarter crop, tighter on the body than
`eyrie_hawk_portrait`: two tall thin cream antlers reading against the white
background, a rust-brown head with a dark blue-grey block at the jaw, a gold
sigil ring at the neck, and a large rust body mass filling most of the lower
frame with no visible cream belly ball.

- **Framing (6):** the antlers get full headroom and stay inside frame, but
  the body mass is cropped tightly enough that the CREAM belly ball
  `flicker_stag.md`'s 3D pass calls out is not visible anywhere in this
  crop — the one element that pass flagged as a colour-separation problem
  isn't present to judge here at all.
- **Identity (8):** the tall thin antlers are an immediately distinctive
  silhouette against the white background and read as "stag" clearly, the
  strongest single element in this batch.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  antlers stay visible as thin pale lines against white, which is the
  identity-carrying read; the dark blue-grey jaw block reads as an
  ambiguous dark shape near the mouth rather than anything specific, and
  the body mass below softens into one undifferentiated rust blob.
- **Colour & separation (5):** the antlers separate cleanly against white,
  but the rust head and rust body blend into one mass with no internal
  colour break, and the dark blue-grey jaw block reads closer to black than
  a distinct third colour at this size — the weakest line in this batch.
- **Style consistency (7):** head-and-shoulders convention held, though the
  crop sits tighter than `frog`/`eyrie_hawk`'s, cutting off more of the body.

## Diagnosis — two lowest

1. **Colour & separation (5).** Concrete fix: same as `flicker_stag.md`'s
   own finding — shift the belly ball's palette toward a genuinely lighter,
   less saturated cream so head and body separate by value, not just hue;
   this portrait shows the problem may be broader than just the belly ball,
   since the rust head and rust body also read as one mass here with no
   belly ball even in frame to break them up.
2. **Framing (6).** Concrete fix: loosen the `FOCUS` crop slightly to bring
   the belly ball into frame, both so this element is judgeable in the
   portrait and so it can do the colour-separating job the module doc
   intends for it in the party panel, not just the fight-camera renders.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the belly ball being entirely outside this crop is deliberate (the
portrait convention favours a tighter head shot for stags than for birds)
or an oversight in `FOCUS` — this scoring pass can see it's absent, not why.
