# cog — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
21 (see `target_icon.md` for the batch's full scope and shared rubric).
**Scoring pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/cog.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Last of
batch 21's four — with this batch, thirty-two of the thirty-six total card
icons are now scored.

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-20 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency. Same method as `target_icon.md`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 7 | 5 | 8 | **36** |

## What is actually there

Two overlapping toothed rings — a larger CLAY (rust-orange) gear at
upper-left with six square teeth and a centre bump, and a smaller PEWTER
(blue-grey) gear at lower-right with six teeth of its own, its rim
crossing into the larger gear's own circle.

- **Silhouette @ 42px (7):** both rings and most of their teeth stay
  distinct at the real downsample — a clear "two overlapping toothed
  wheels" read — docked because the teeth along the overlap seam itself
  (where CLAY meets PEWTER, roughly the small gear's upper-left quadrant)
  compress together and lose their individual square shape, the one part
  of the icon that doesn't fully survive the downsample.
- **Family distinction (9):** nothing else scored under this item is a
  pair of overlapping toothed rings — the closest neighbours by
  construction (`buffer`'s single hex ring, `target`/`expose`'s
  concentric rings) are all a single ring, not two meshing ones, so `cog`
  stands apart by shape alone.
- **Mechanic match (7):** "meld / fuse" is served reasonably well by two
  distinct wheels physically overlapping into one shape — the overlap
  itself is doing real communicative work, since two separate
  non-touching gears would read as "mechanism" generically rather than
  "combination" specifically. Not a perfect match only because a gear's
  first, more common association is "machinery" or "engineering" broadly,
  and a player unfamiliar with the keyword may reach for that reading
  before "meld."
- **Colour & contrast (5), the lowest line scored this batch:** pixel-sampled
  directly, and the two gears are not equally legible against the card
  standin. The CLAY gear's dominant sampled tone, roughly RGB(168,100,65),
  sits close to the standin RGB(139,105,74) — a weak 29/5/9-per-channel
  gap, the smallest colour separation measured for any icon scored under
  this item so far. The PEWTER gear separates far better, roughly
  RGB(85,92,107) against the same standin (a 54/13/33 gap, cool grey-blue
  against warm brown) — confirmed by direct pixel sampling, not
  eyeballing, so this is a real asymmetry between the icon's two halves
  rather than a uniform read.
- **Style consistency (8):** the ring-plus-teeth-plus-centre-ball
  construction matches the vocabulary `buffer`'s hex ring and
  `target`/`expose`'s concentric rings already use; nothing about the
  render angle is an outlier.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: shift the CLAY gear's tone
   further from the card-face brown — either darken it toward a more
   saturated rust, or lighten it toward the PEWTER gear's own better-
   separated value — so both halves of the icon read with equal
   confidence rather than one wheel standing out and the other nearly
   matching the background.
2. **Silhouette @ 42px (7).** Concrete fix: widen the gap between the two
   gears' teeth in the overlap zone specifically (the seam where CLAY
   meets PEWTER), since that is the one region where the downsample loses
   individual tooth shape while the rest of both rings holds up fine.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "meld / fuse" is meant to read as *combining two different
things* (which the two-colour, two-size gear pair supports) or as
*mechanism/engineering* more generally (which a single gear would have
served just as well) — the build comment names the mechanic but not which
reading the shape is meant to carry, and only Nick's sense of the card's
actual in-game context could settle it.
