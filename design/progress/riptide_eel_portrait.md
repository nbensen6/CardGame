# riptide_eel — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/riptide_eel.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 5 | 6 | 5 | 7 | 6 | **29** |

## What is actually there

A long dark navy neck and head, tilted three-quarter, with a gold-ringed
sigil and grey climbing holds visible lower in frame. Alpha bounding box
`(138, 143, 503, 512)` — a large empty margin at top-left (138px, 143px)
with the head and neck pushed into the bottom-right, right and bottom
edges nearly touching (503/512 and exactly 512).

Zoomed on the head region to check a detail the thumbnail suggested: the
head has two eyes, but they are not both mounted on the head surface. The
near eye sits correctly on the cheek; a second eye of the same size and
colour floats in open air above and to the left of the snout, with visible
background between it and any part of the head. Checked this against the
existing 3D render kept from `riptide_eel.md`'s own pass
(`design/renders/riptide_eel_pass1_34.png`) — the same detached far eye is
visible there too, so this is a real model geometry issue, not a
portrait-specific camera or crop artifact. `riptide_eel.md`'s written
scoring never named it (it only describes "yellow eyes" without flagging
a mounting problem), so this is a genuine new finding this batch is
surfacing, not a re-read of an already-known issue.

- **Framing (5):** no clipping (unlike `glyph_tortoise_portrait` and
  `husk_beetle_portrait` this batch), but the subject occupies only the
  bottom-right half of the canvas, leaving a large, asymmetric dead zone
  at top-left rather than balanced headroom.
- **Identity (6):** the long neck and head read as serpentine/eel-like,
  but the floating detached eye is a visible oddity that undercuts
  confidence in the read rather than supporting it.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The
  floating eye survives as a small stray dot clearly separate from the
  head shape — at this size it reads as visual noise (an extra fleck)
  rather than as "an eye," and someone not already told what it is would
  not identify it as part of the face.
- **Colour & separation (7):** the dark navy head/neck separates well
  from the gold sigil and eyes; no dark-on-dark problem in this crop,
  unlike the near-black-body concern `riptide_eel.md`'s 3D pass raised
  for the full body (not visible in this closer head-and-neck crop).
- **Style consistency (6):** the head-and-shoulders convention is present,
  but the large unused top-left area, and the two other subjects scored
  this batch (`glyph_tortoise_portrait`, `husk_beetle_portrait`) all
  showing their own distinct framing problems, keeps this from matching
  the tighter, well-centred crop `frog_portrait` and `gloom_moth_portrait`
  set as the convention.

## Diagnosis — two lowest

1. **Readability @ 34px (5).** Concrete fix: this line is driven entirely
   by the floating far eye — reseating it onto the head surface (or
   confirming it is a portrait-specific render artifact and re-rendering)
   would likely lift this line and Identity together, since both name the
   same cause.
2. **Framing (5).** Concrete fix: re-centre `portraits.py`'s `FOCUS` entry
   for this asset — shift it down-right toward where the head actually
   sits, or widen the crop, to remove the large empty top-left margin.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing about whether the floating eye is real — confirmed against the
kept 3D render above. Unsure why `riptide_eel.md`'s own scoring pass
didn't name it despite having the same evidence available; worth a note
that a rubric line ("Build hygiene") doesn't guarantee every visible
defect gets written down if the scorer's attention was on other parts.
