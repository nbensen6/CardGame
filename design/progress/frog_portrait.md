# frog — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair; no edits to `tools/blender/portraits.py` or its
`FOCUS` table.** Asset: `game/assets/portraits/frog.png` (512x512, rendered by
`portraits.py` from the 3D model). Batch 9 of #83, the first to score
portraits rather than 3D models.

## The adapted rubric (1–10 each, out of 50)

The 3D rubric's five lines don't all transfer to a single static 2D render —
there is no separate silhouette pass, no poly budget, no camera turn. Kept
what each line was *for* (per `asset-loop.md`'s own "changed and why"):

| Criterion | Question | Replaces |
|---|---|---|
| **Framing** | Is the crop well-balanced — enough headroom, nothing important cut off, no dead space? | (new; portraits have no equivalent in the 3D rubric) |
| **Identity** | Recognizable as this specific character at a glance? | Proportion |
| **Readability @ 34px** | Downsampled to the actual party-panel size (not eyeballed on a shrunk full-size image) — do the parts still separate? | Silhouette + Colour & read, merged (a portrait has no separate black-silhouette pass) |
| **Colour & separation** | Do the palette swatches separate against each other and the transparent background at full size? Dark-on-dark or same-value-on-same-value? | Colour & read |
| **Style consistency** | Same three-quarter angle, transparent background, framing convention as the rest of the cast? | Style consistency |

"Build hygiene" (poly budget, floating parts) has no meaning for a rendered
PNG and is dropped rather than stretched to fit.

34px check done with a real downsample (Pillow, `Image.LANCZOS` to 34x34,
then nearest-neighbour back up for viewing) — the same "actually look, don't
guess" standard the 3D loop holds itself to.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 9 | 8 | 8 | **42** |

## What is actually there

Head-and-shoulders crop, three-quarter angle, transparent background. Two
stalked bulbous eyes (amber iris, black pupil) sit above a wide green
head/mouth; a cream belly patch is visible at the bottom edge giving some
body context below the head.

- **Framing (8):** generous headroom above the eyes, both eyes and the mouth
  fully inside the frame, a sliver of shoulder/body visible at the bottom
  rather than cutting off mid-face. Minor: a little unused space at the top.
- **Identity (9):** stalked bulging eyes plus a wide flat mouth reads as
  "frog" immediately, no ambiguity.
- **Readability @ 34px (9):** confirmed via a real 34px downsample — the
  amber eyes stay clearly separated from the green head, the cream belly
  patch still reads as a distinct shape. Best-reading portrait in this batch.
- **Colour & separation (8):** amber-on-green and cream-on-green both
  separate cleanly; nothing dark-on-dark.
- **Style consistency (8):** matches the shared three-quarter head-and-
  shoulders convention on transparent background.

## Diagnosis — two lowest (tied, both named)

1. **Framing (8).** Concrete fix: nudge the frame down slightly (lower the
   `FOCUS` centre fraction a little from 0.71) to use the empty headroom
   above the eyes, giving a marginally tighter crop.
2. **Colour & separation (8).** Concrete fix: none needed at full size; the
   only soft spot is the belly patch's cream sitting close in value to a
   lighter green highlight just above it — a very minor read cost, not a
   real failure.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing unresolved for this one — of the batch, this is the cleanest read.
