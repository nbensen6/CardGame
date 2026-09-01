# skull — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
18 — continuing the icon rubric batches 14-17 established. **Scoring pass
only — report, not repair; no edits to `tools/blender/icons.py`.** Asset:
`game/assets/icons/skull.png` (256x256, rendered by `icons.py`, orthographic
head-on per `design/ART-REVIEW.md`'s own build note). Last of batch 18's
four — the "four basic damage-type icons" (sword, bow, fire, skull).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-17 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

Same Pillow-based 42px downsample (`Image.LANCZOS`, flat brown
`RGB(139,105,74)` card-face standin) and >10-alpha-threshold bbox method
batch 17 added.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 8 | 6 | 8 | 8 | **38** |

## What is actually there

A blocky rounded-square mint-green head with two solid black ovoid eye
sockets, a small charcoal nose slab, and a jaw of three vertical charcoal
teeth-bars below. Alpha bbox `(56, 38, 200, 227)` — comfortable margin on
all four sides, no edge-flush framing.

- **Silhouette @ 42px (8):** the head-plus-jaw shape reads clearly and
  survives the downsample as a distinct blocky face — the two dark eye
  sockets and the teeth bar remain visibly separate elements rather than
  fusing into the head mass.
- **Family distinction (8):** nothing else in the set is a face/head
  shape at all, so it can't be confused with anything else reviewed under
  this item — docked only slightly because the read is "a green blocky
  face" rather than anything more specific within that.
- **Mechanic match (6):** the green colour supports "poison" clearly, but
  the shape itself reads more as a blocky robot or alien head than
  specifically a skull — the eye sockets are solid black ovals rather than
  the hollow triangular/round sockets a skull silhouette usually uses, and
  the teeth are three even rectangular bars rather than a jaw shape. It
  reads unambiguously as "a face, something's death-coded," which covers
  the comment's "poison, wound, death" fairly well, but not as
  unambiguously "a skull specifically" as the comment's literal name
  implies.
- **Colour & contrast (8):** the mint-green head separates cleanly from
  the brown card standin, and the charcoal eyes/teeth separate cleanly
  from the green — the strongest internal contrast of this batch's four
  icons.
- **Style consistency (8):** the same blocky, rounded-bevel low-poly
  construction as the rest of the set; nothing about the render is an
  outlier.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: none proposed beyond naming the
   gap — if a more literal skull read is wanted, hollowing or angling the
   eye sockets toward a triangular shape and narrowing the jaw would move
   it closer to a classic skull silhouette rather than a blocky
   robot/alien face; not confirmed whether the current read causes any
   real confusion in play, since "green face" already carries the
   poison/death association well.
2. **Family distinction (8).** No defect found; scored short of a perfect
   10 only because a single unique shape in its own class has less to
   prove than the closely-packed families (`shield`/`guard`/`wall`,
   `climb`/`ascend`/`peak`/etc.) scored in earlier batches.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "green blocky face" reads as *skull* on first sight with no
tooltip, or needs the keyword text to land as death/poison rather than
just "an enemy's face" — the same kind of question `intangible_icon.md`
(batch 14) left open for "afterimage," and one this static comparison
can't settle on its own.
