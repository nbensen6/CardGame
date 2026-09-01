# peak — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/peak.png` (256x256). Third of the "six are about going
up" family this batch scores.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 6 | 8 | 8 | **39** |

## What is actually there

Two overlapping mountain peaks — a tall SLATE/PEWTER pyramid in front, a
smaller one behind and to the right — both with white snow caps, and a
small red flag planted at the tall peak's summit. Alpha bbox
`(4, 0, 256, 238)`: touches the top edge (the flag is cropped there) and
the right edge (the smaller peak's right slope runs off-canvas), comfortable
margin at bottom and near-full width on the left.

- **Silhouette @ 42px (8):** the twin-peak shape survives the downsample
  clearly and reads unmistakably as a mountain; the flag compresses to a
  small red smear at the summit but doesn't hurt the read of the mountain
  itself.
- **Family distinction (9):** completely unlike `climb`/`ascend`'s
  arrow-on-post, and unlike `rope`'s vertical coil — the strongest
  silhouette separation scored in this batch, confirmed side by side at
  42px.
- **Mechanic match (6):** the card text is "a strike that scales with
  Height" — an attack — but the icon shows a place (a mountain), not an
  action. It supports the Height theme strongly but doesn't itself signal
  "strike" the way, say, `sword`'s blade does; a player would need the
  keyword to connect "mountain" to "damage."
- **Colour & contrast (8):** the slate/pewter blue-grey body reads clearly
  against the brown card standin, the white snow caps add a bright accent,
  and the red flag is the only warm colour in the family, which helps it
  stand out.
- **Style consistency (8):** consistent bevelled-block construction with
  the rest of the set.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: since the card is a strike, not
   terrain, add a motion cue to the mountain — a jagged crack or an impact
   burst at the peak — so the icon reads as "a hit that comes from height"
   rather than only "a mountain."
2. **Top/right edge clipping (contributes to Silhouette).** Concrete fix:
   pull the flag and the smaller peak's right slope fully inside the
   256x256 canvas so nothing is cropped at full size, before it's cropped
   again by the 42px downsample.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the flag is meant to be read as part of the mechanic ("Height" —
reaching the top) or is pure flavour left over from a "victory flag" idea;
nothing in the build comment says which, and it's the one element of this
icon that doesn't obviously serve "a strike."
