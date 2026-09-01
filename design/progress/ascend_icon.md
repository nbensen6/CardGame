# ascend — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/ascend.png` (256x256). Second of the "six are about going
up" family this batch scores.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 3 | 6 | 5 | 8 | **29** |

## What is actually there

The same cream/wheat arrow-on-post shape as `climb`, taller and with a wider
triangle, flanked at the base by two small gold wing-triangles and sitting
on a tan slab. Alpha bbox `(38, 5, 218, 256)`: touches the bottom canvas
edge (the tan base slab is cropped there), comfortable margin elsewhere.

- **Silhouette @ 42px (7):** the arrow-on-post reads cleanly, same as
  `climb`; the gold wings survive the downsample as two small triangular
  flags at the base, though the tan slab beneath them nearly disappears
  into the crop.
- **Family distinction (3):** the same finding as `climb_icon.md` reports
  from the other side — at 42px `ascend` and `climb` share an
  almost-identical outer triangle-on-post silhouette
  (`climb_family_42px_strip.png`), differing only in the small base
  attachments (gold wings and a tan slab here vs two dark bars on `climb`).
  Colour, not shape, is doing the separating work.
- **Mechanic match (6):** an arrow reads as "up," matching "a big climb" in
  the general sense, but nothing about this icon signals *bigger* than
  `climb`'s arrow beyond being drawn slightly taller — a difference easy to
  miss at 42px and not the kind of distinction a hand read by shape can
  rely on.
- **Colour & contrast (5):** the lowest line this batch. The tan base slab
  sits close enough in value to the brown card standin (`RGB(139,105,74)`)
  that it nearly merges with the background at 42px, and the bbox
  clipping at the bottom edge compounds it — the base reads as a vague
  smudge rather than a distinct shape.
- **Style consistency (8):** matches the rest of the set's bevelled-block
  construction.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: darken the tan base slab or
   give it an outline distinct from the card-face brown, and pull it fully
   inside the canvas so it isn't clipped at the bottom edge.
2. **Family distinction (3).** Same fix named in `climb_icon.md`: change
   one element of the outer silhouette (not just the base colour) so
   `ascend` doesn't rely on its gold wings alone to read as different from
   `climb`.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the bottom-edge clipping on the tan slab is deliberate framing
(the base is meant to feel like it continues off-screen) or an oversight —
nothing in the build script's comments says which.
