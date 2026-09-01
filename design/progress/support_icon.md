# support — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 15 — rubric and method as `design/progress/shield_icon.md` (this
batch's reference file), not repeated here. Asset:
`game/assets/icons/support.png` (256x256). Fourth of the "not dying" family
(`shield`, `guard`, `wall`, `support`) — grouped with the other three by
`design/ART-REVIEW.md` even though its own card_view.gd comment ("help the
ally") is not itself a Block variant the way the other three are.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 8 | 8 | 8 | **41** |

Best score of this batch and, so far, the second-best score recorded under
this item after `thorns` (43/50, batch 14).

## What is actually there

A green open hand, palm up, four fingers standing as rounded pillars with a
small green sphere resting against the two middle fingertips, and a short
angled nub off the left side of the palm reading as a thumb. Alpha bbox
`(24, 25, 196, 209)`: comfortable margin on every side, no clipping.

- **Silhouette @ 42px (8):** the hand-with-fingers-and-ball shape holds up
  well through the downsample — four short pillars plus a round cap above
  them stays legible as "hand offering something" rather than fusing into a
  blob, though the thumb nub on the left is the one part that thins to
  almost nothing at true 42px.
- **Family distinction (9):** entirely different silhouette family and the
  only saturated green in the batch — trivially separable from the two
  kites and the brick grid.
- **Mechanic match (8):** a hand holding something up reads intuitively as
  "help/support" cold, without needing the tooltip — the clearest
  shape-to-meaning link in this batch.
- **Colour & contrast (8):** the saturated green has strong contrast against
  the brown card standin, better separation than any of the other three
  icons in this batch manage against the same background.
- **Style consistency (8):** same bevel/shadow construction as the rest of
  the set; the only member of this batch whose colour family (green) isn't
  shared with any of its three siblings, which is appropriate since it is
  the one card in this family that isn't a Block variant.

## Diagnosis — two lowest

No line scored below 8 — this asset has no clear defect the way the other
three in this batch do. Naming the two relatively weakest anyway, per this
item's format:

1. **Silhouette @ 42px (8).** Concrete fix, minor: thicken the thumb nub
   slightly so it survives the downsample as clearly as the four main
   fingers do, rather than nearly vanishing.
2. **Colour & contrast / Style consistency (tied 8).** No concrete fix
   proposed — both already read cleanly; flagged only because the format
   asks for two lines and nothing else in this asset is weaker.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing significant — this is the cleanest read of the four assets in this
batch.
