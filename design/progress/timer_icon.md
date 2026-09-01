# timer — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 (see `target_icon.md` for the batch's full scope and shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/timer.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Third
of batch 21's four.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 9 | 10 | 9 | 6 | 8 | **42** |

## What is actually there

A classic hourglass: two AMBER caps top and bottom, two GOLD cones meeting
at a pinched waist, and a small WHEAT sand pile settled at the bottom of
the lower cone.

- **Silhouette @ 42px (9):** the pinched-waist double-cone shape survives
  the downsample cleanly — the single strongest, most conventional read
  scored so far this batch, one step below a perfect score only because
  the sand pile at the waist compresses into a soft blur rather than a
  distinct grain shape (which does not hurt the overall read).
- **Family distinction (10):** nothing else scored under this item is an
  hourglass, or built from two opposing cones — unambiguous at a glance
  against the whole set, matching the top score already given to
  `intangible` (batch 14) and `bow` (batch 18) on this line.
- **Mechanic match (9):** "timed, nothing else" — an hourglass is the most
  literal, universally understood symbol for a timer available; nothing
  about it needs the keyword to be understood.
- **Colour & contrast (6), the lowest line scored this batch:** pixel-sampled
  directly — the AMBER cap runs roughly RGB(197,158,120) against the
  standin RGB(139,105,74), a real but moderate 40-58-per-channel gap, and
  the GOLD glass at RGB(168,127,48) separates better (29-79 per channel,
  strongest in blue). Both stay visible, but the whole icon lives in one
  warm tan-to-gold band that sits closer to the brown card standin than
  the more saturated palettes used elsewhere in the set (`thorns`' green,
  `strength`'s rust-and-gold, `dexterity`'s blue).
- **Style consistency (8):** the cone-and-cap construction matches the
  taper/slab vocabulary used throughout the set; nothing about the render
  angle is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (6).** Concrete fix: shift the caps or the glass
   toward a cooler or more saturated tone (a SILVER or STEEL cap, say,
   rather than AMBER) to pull the icon's palette further from the warm
   brown card face it sits on, the same fix direction `intangible_icon.md`
   proposed for its own palest tile.
2. **Silhouette @ 42px (9).** No fix proposed — already the strongest
   silhouette line scored this batch and one of the strongest scored
   under this item; noted only that the sand-pile detail is the one part
   that doesn't fully survive the downsample, which costs nothing since
   the hourglass reads without it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

The alpha bbox touches both the top and bottom canvas edges exactly
(`(52, 0, 205, 256)` at both thresholds checked) — the same "no margin"
pattern already named for `wall`, `sword` and five other icons across
batches 15-19 — but unlike those, here it reads as plausibly deliberate:
an hourglass's caps are its widest, flattest feature, and letting them
run to the frame edge is a natural way to fill a square icon with this
particular silhouette. Flagged as the same pattern, not scored as a
defect on its own line, per that convention; whether it looks cramped
next to icons with visible margin on all sides in an actual hand is a
`needs a screen` question this static comparison can't settle.
