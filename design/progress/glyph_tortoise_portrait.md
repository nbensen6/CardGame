# glyph_tortoise — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/glyph_tortoise.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 6 | 6 | 8 | 6 | **29** |

## What is actually there

A blue-grey domed shell fills most of the frame, a gold-ringed sigil set
into its front slope, brown head and stubby legs visible at the bottom-left
corner. Checked the alpha channel directly rather than eyeballing it: the
content's bounding box is `(0, 20, 512, 512)` — the shell and legs are cut
by the LEFT, RIGHT, and BOTTOM edges of the 512x512 canvas, with only 20px
of clearance at the top. Three of four edges are clipping content.

- **Framing (3):** the worst edge-clipping found under this item so far —
  `clot_toad_portrait` (24/50, fixed to 33) cropped one edge; this crops
  three. Not scored lower than 3 because, unlike `clot_toad`, the parts cut
  off (legs, chin) are peripheral rather than the beast's own identity
  feature — the sigil and shell dome, `glyph_tortoise.md`'s named strengths,
  are both fully inside the frame with room to spare.
- **Identity (6):** the shell dome plus visible sigil reads as this beast,
  but the crop removes most of the leg/chin detail that would otherwise
  support the read, so it leans on the shell and sigil alone.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  blue-grey dome and gold sigil disc stay separated as a blob-with-a-dot;
  the cropped legs are reduced to faint tan smudges at the frame edges,
  barely readable as legs at all.
- **Colour & separation (8):** blue-grey shell, brown head, and gold sigil
  all separate cleanly from each other and from the white/transparent
  ground — no dark-on-dark. Best-scoring line for this asset, consistent
  with `glyph_tortoise.md`'s own 3D pass (7/10 on the equivalent line).
- **Style consistency (6):** every other scored portrait crops
  head-and-shoulders with headroom above the subject; this one is
  effectively a top-down shell shot with the head shoved into a corner —
  a different framing idiom from the rest of the cast, not just a tight
  version of the same one.

## Diagnosis — two lowest

1. **Framing (3).** Concrete fix: pull `portraits.py`'s `FOCUS` entry back
   (widen the span and/or lower the centre) so the shell and legs sit fully
   inside the 512x512 canvas — right now the crop is effectively zoomed
   past the model's own extent on three sides.
2. **Style consistency (6).** Same root cause as framing: once the crop is
   pulled back to fit the model, it should also land closer to the
   head-and-shoulders framing the rest of the cast uses, since the shell
   dome would no longer need to fill the entire frame to appear large.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the 3D pass's own "sigil mount reads as a bolted-on handle"
finding (`glyph_tortoise.md`, Build hygiene 5/10) is visible from this
portrait's angle — the sigil reads flush and clean here, but this is a
single static crop, not the turntable the 3D pass used, so it can't
confirm or clear that finding.
