# intangible — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83, batch
14 — the third adaptation after the 3D-model rubric (batches 1-8) and the
portrait rubric (batches 9-13). **Scoring pass only — report, not repair; no
edits to `tools/blender/icons.py`.** Asset: `game/assets/icons/intangible.png`
(256x256, rendered by `icons.py`, orthographic head-on per
`design/ART-REVIEW.md`'s own build note). First of batch 14's four — the
"four defensive-keyword icons (intangible, buffer, plated_armour, thorns)"
block in `design/ART-REVIEW.md`, its own stated question: can these four be
told apart from `shield`/`guard`/`wall` at 42px, and does each look like what
its card actually does.

## The adapted rubric (1–10 each, out of 50)

An icon has no crop/framing question (it's a fixed square render) and no
"identity" in the portrait sense (nobody needs to recognize *which specific
icon* the way they recognize *which specific beast*) — the questions that
matter for an icon are legibility at the size it's actually seen, and
standing apart from its nearest neighbours, since a hand is read by shape,
fast (`ART-REVIEW.md`'s own framing of the whole icon set).

| Criterion | Question | Replaces |
|---|---|---|
| **Silhouette @ 42px** | Downsampled to the size `ART-REVIEW.md` names as the real read distance ("an icon is read at 42 pixels as a silhouette") — does the shape itself stay legible, or do its parts fuse into a blob? | Silhouette |
| **Family distinction** | Told apart from its named nearest neighbours (`shield`/`guard`/`wall` for this batch) by shape alone, not colour? | Proportion |
| **Mechanic match** | Does the shape suggest what the card wearing it actually DOES (the comment beside it in `card_view.gd`'s `ICONS` table), not just a flavour object? | (new; portraits have no "does what it claims" question) |
| **Colour & contrast** | Internal contrast between the icon's own parts, and contrast against the card face it sits on? | Colour & read |
| **Style consistency** | Same orthographic head-on angle, shared palette, similar visual weight to the rest of the icon set? | Style consistency |

"Build hygiene" (poly budget, floating parts) and "Framing"/"Identity"
(portrait-specific) don't apply to a fixed-square icon render and are
dropped rather than stretched to fit.

42px check done with a real downsample (Pillow, `Image.LANCZOS` to 42x42,
nearest-neighbour back up to view, composited over a flat brown standing-in
for the card face — `RGB(139,105,74)`, an approximation of the game's actual
card colour, not sampled from the real shader; noted as a limitation, not
claimed as exact) — the same "actually look, don't guess" standard the 3D
and portrait loops hold themselves to. `shield`, `guard` and `wall` were
rendered the same way alongside it for the family-distinction line, since
that question is meaningless without the neighbours in frame; they are not
themselves scored under this item; the "twenty-eight card icons" block they
belong to is unscored and left for a future batch.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 9 | 6 | 5 | 8 | **34** |

## What is actually there

Three overlapping rounded-square/diamond tiles on a diagonal chain from
upper-left to lower-right, fading from saturated indigo/purple through a
mid steel-blue to a near-white pale grey — an afterimage trail, per
`ART-REVIEW.md`'s own description.

- **Silhouette @ 42px (6):** the three tiles read as one continuous
  elongated lozenge with three shaded bands rather than three separate
  overlapping objects — the overlap that at 256px clearly shows three
  distinct rounded squares compresses at 42px into a single diagonal bar.
  The shape is clean and legible, just not legible as *three* things.
- **Family distinction (9):** nothing about `shield`'s kite, `guard`'s
  kite-plus-clock, or `wall`'s brick grid resembles a diagonal fading bar —
  this is the least ambiguous line for this icon, confirmed side-by-side
  against all three at the same 42px scale.
- **Mechanic match (6):** a fading diagonal chain plausibly reads as
  "afterimage / phasing" for a player already told the keyword, but cold
  (no tooltip, no context) it could as easily read as a colour ramp or a
  loading indicator. Plausible, not unambiguous.
- **Colour & contrast (5):** confirms `ART-REVIEW.md`'s own named worry —
  the palest of the three tiles (bottom-right) sits close enough in value
  to the brown card standin that its trailing edge nearly disappears at
  42px, leaving what looks like two tiles plus a faint smudge rather than
  three graduated steps.
- **Style consistency (8):** the rounded-block-on-block construction matches
  the shared vocabulary other icons in the set already use (`climb`,
  `ascend` build from similar solid blocks); nothing about the render angle
  or palette family stands out as inconsistent.

## Diagnosis — two lowest

1. **Colour & contrast (5).** Concrete fix: shift the palest tile's colour
   value further from the card-face brown — either darken it or add a thin
   contrasting outline — so it stays visibly present rather than fading to
   nothing at 42px.
2. **Silhouette @ 42px (6).** Concrete fix: increase the offset between the
   three tiles (or reduce the overlap) so the "three steps" read survives
   the downsample instead of compressing into one bar with internal
   shading.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "afterimage trail" is the read a player gets on first sight with no
tooltip open, versus needing the keyword text to make sense of it — this
static comparison can't settle that, only game-context testing could.
