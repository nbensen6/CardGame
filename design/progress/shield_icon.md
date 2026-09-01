# shield — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
15 — continuing the icon rubric batch 14 introduced. **Scoring pass only —
report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/shield.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). First of batch 15's
four — the **"four are about not dying" family** `design/ART-REVIEW.md`
itself names as the pair to check first inside the "twenty-eight card icons"
block: `shield`, `guard`, `wall`, `support`. Its own stated open question:
"whether `guard` (a shield with a clock face) is distinguishable from
`shield` at 42px, which is the closest pair in the set."

## The adapted rubric (1–10 each, out of 50)

Same five lines batch 14 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. "Build hygiene" and
"Framing"/"Identity" don't apply to a fixed-square icon render and stay
dropped.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up 8x to view, composited over the same flat brown
card-face standin as batch 14, `RGB(139,105,74)`). Alpha channel bounding
box checked directly (`Image.getbbox()`), the same numeric-not-eyeballed
standard portrait batches 12-13 adopted, rather than guessing at cropping.
All four family members rendered and downsampled together in one script for
a true side-by-side comparison, since "family distinction" is meaningless
without the neighbours in frame.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 6 | 7 | 8 | **32** |

## What is actually there

A blue-grey kite/pennant shape — flat top edge with rounded corners, straight
sides, tapering to a point at the bottom — with a plain white cross (one
vertical bar, one horizontal bar, equal length) centred on the body. Alpha
bbox `(52, 25, 205, 254)`: comfortable margin on all four sides, no clipping.

- **Silhouette @ 42px (8):** the kite outline and the cross both survive the
  downsample cleanly — the shape stays a clean, unambiguous "shield" read
  even through visible pixel steps.
- **Family distinction (3):** this is the batch's central finding. Side by
  side with `guard` at the same 42px scale, the two outer silhouettes are
  effectively identical — same flat-top kite, same rounded shoulders, same
  point — differing only in body shade (blue-grey here vs pale grey-white on
  `guard`) and the internal mark (a cross here vs an "L" there). By shape
  alone, with colour set aside, `shield` and `guard` are not distinguishable.
  Distinction from `wall` (a brick grid) and `support` (a hand) is trivial by
  comparison and does not rescue this line.
- **Mechanic match (6):** the kite/shield silhouette itself reads as "block"
  immediately — that part is doing real work. The cross mark is more
  ambiguous: a plain plus sign is a common shorthand for "heal" in the wider
  card-game vocabulary this game is drawing from, and nothing about it says
  "block" specifically beyond sitting on a shield-shaped body.
- **Colour & contrast (7):** the blue-grey body reads clearly against the
  brown card standin, and the white cross has good internal contrast against
  the body. Not the strongest colour separation in the set (a mid blue-grey
  is closer in value to some other icons' palettes than, say, `thorns`'
  saturated green), but nothing here disappears.
- **Style consistency (8):** same bevelled-block construction and drop
  shadow as the rest of the set; nothing about the render stands out as an
  outlier.

## Diagnosis — two lowest

1. **Family distinction (3).** Concrete fix: change one shape element of
   `shield`'s or `guard`'s outer silhouette (not just colour or internal
   mark) — for example, square off `guard`'s shoulders where `shield`'s stay
   rounded, or shorten `guard`'s point — so the two remain readable as
   "block" by outline alone without relying on shade or the internal glyph
   to tell them apart.
2. **Mechanic match (6).** Concrete fix: replace the plain cross with a
   mark less associated with healing elsewhere in the genre — a raised
   centre boss (a simple circle or diamond stud) reads as "shield" without
   borrowing a "heal" glyph.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the cross-as-heal association is strong enough in practice to
actually mislead a player, since this game has no separate heal icon in the
current set to collide with directly — flagged as a plausible risk, not a
confirmed collision.
