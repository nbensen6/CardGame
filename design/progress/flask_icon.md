# flask — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
19 — continuing the icon rubric batches 14-18 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/flask.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). First of batch 19's
four — the first four of the sixteen remaining "twenty-eight card icons"
entries, taken in `card_view.gd`'s `ICONS` table order: `flask`, `bomb`,
`gadget`, `draw`.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-18 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and >10-alpha-threshold bbox method
batches 15-18 used.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 8 | 10 | 7 | 8 | **41** |

## What is actually there

A rounded flask/potion bottle: a wide lilac-to-violet sphere for the body, a
narrow lilac neck rising out of the top, and a short umber cork capping it. A
small orchid highlight dot sits on the sphere's upper-right shoulder.

- **Silhouette @ 42px (8):** the wide-bottom/narrow-neck flask shape stays
  clearly readable at a real 42px downsample — no part of it fuses into a
  blob. Docked one point because the alpha bbox `(55, 0, 201, 235)` shows
  the cork flush against row 0, so the top of the neck is clipped by the
  canvas rather than showing a complete cork silhouette.
- **Family distinction (8):** nothing else scored under this item shares a
  wide-round-bottom/narrow-neck shape — the closest thing by overall
  roundness is `bomb` (this same batch), which reads dark and stemless by
  contrast rather than necked. Confirmed by placing both 42px renders
  side by side.
- **Mechanic match (10):** a potion bottle for "a potion" is as direct a
  read as `card_view.gd`'s comment asks for — no abstraction needed.
- **Colour & contrast (7):** pixel-sampled directly, not eyeballed: the
  body ranges roughly RGB(124,108,169) to RGB(170,160,198) against the
  card standin RGB(139,105,74) — real hue separation (cool purple vs warm
  brown) holds at every sample, but the sphere's own shading gradient
  runs dark enough at its lower-left edge that the silhouette's bottom
  contour loses definition against the standin there, short of a clean
  break.
- **Style consistency (8):** the same bevelled-sphere-plus-slab
  construction as `thorns`' ball and `bomb`'s body (this batch); nothing
  about the render is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (7).** Concrete fix: lighten the sphere's
   lower-left shading stop so the silhouette keeps a visible edge against
   the card standin all the way around, not just on the lit side.
2. **Silhouette @ 42px / Family distinction (8, tied).** Concrete fix for
   the framing half of this: pull the cork down 0.03-0.04 so its top
   clears the canvas edge with margin, matching the framing the
   non-edge-flush icons in this set already carry.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the top-edge crop reads as a hard, visible cut once the icon sits
inside the game's actual UI frame rather than this scoring script's flat
standin canvas — the same open question named for the other edge-flush
icons in `sword_icon.md` and `strength_icon.md`, and worth a shared look
across all of them if Nick wants one fix rather than several. `flask` is
also the icon reused for `sure_footing` (a pure Dexterity card, no potion
involved) — `ART-REVIEW.md`'s own pre-existing note, not rescored here since
this batch's job is the shape, and the mismatch was already named and left
for a future batch rather than relitigated.
