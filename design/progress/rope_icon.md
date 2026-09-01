# rope — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/rope.png` (256x256). Last of the "six are about going up"
family scored this batch; `lift` and `rally` remain for a future batch.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 8 | 3 | 7 | **33** |

## What is actually there

A vertical stack of tan rings, each slightly narrower toward the middle,
forming a ribbed coiled-rope cylinder, with a silver ring (a carabiner) at
the top right. Alpha bbox `(35, 0, 242, 256)`: touches both the top and
bottom canvas edges — the coil runs off-frame at both ends, unlike every
other icon in this batch.

- **Silhouette @ 42px (6):** the ribbed coil shape survives the downsample
  and reads as a textured cylinder, but cold — without already knowing the
  keyword — it's ambiguous between "coiled rope" and other ribbed-cylinder
  readings (a spring, a stack of rings). The carabiner ring is the one
  element that disambiguates it toward "climbing gear," and it's small
  relative to the frame.
- **Family distinction (9):** unlike anything else in this batch or the
  "not dying" family scored in batch 15 — no other icon in the set uses a
  vertical ribbed-coil shape.
- **Mechanic match (8):** a coiled rope with a carabiner is a strong,
  on-genre read for "both hunters climb" — climbing gear specifically,
  not just "up" in the abstract the way `climb`/`ascend`'s arrows are.
- **Colour & contrast (3):** the lowest line scored in this batch and the
  worst colour-separation problem found across both families this item has
  scored. The tan rope body sits close enough in value to the brown card
  standin (`RGB(139,105,74)`) that at 42px the coil's outer edge nearly
  merges into the card face — only the silver carabiner ring stands out
  clearly.
- **Style consistency (7):** the ring-stack construction is a different
  vocabulary from the flat-faceted blocks most of the rest of the set uses
  (`climb`, `ascend`, `peak` are all built from slabs and spikes), so while
  the palette and render angle match, the shape language reads as slightly
  apart from the family.

## Diagnosis — two lowest

1. **Colour & contrast (3).** Concrete fix: darken the rope body or shift
   it away from the card-face brown (a cooler tan, or an outline), since a
   tan rope on a brown card is the closest colour match between an icon and
   its background found under this item so far.
2. **Top/bottom edge clipping.** Concrete fix: shrink the coil or extend
   the canvas margin so the rope doesn't run off both the top and bottom
   edges — every other icon scored under this item keeps its subject fully
   inside frame.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ribbed-coil shape reads as "rope" on first sight with no
tooltip, versus needing the carabiner ring specifically to anchor the
read — this static comparison can't settle that, only in-hand testing
could.
