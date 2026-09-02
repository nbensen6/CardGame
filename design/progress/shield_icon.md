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

## Pass 2 — #86 duty 1 (repair)

Item 86's asset lane now repairs directly rather than only scoring (the old
"scores, never repairs" rule existed to stop two agents editing one file;
tier ownership — icons vs. beasts/grounds/hunters — replaces it). `guard`
already picked up its own fix in the meantime (shoulder flares, a real clock
face) without touching `shield`, so the pair's distance was checked fresh
rather than assumed still at the pass-1 numbers.

Applied both named lines, in-lane (`tools/blender/icons.py` only, no palette
edit, no budget or constant moved):

1. **Family distinction (3).** The single centred point (`spike(0, -0.30,
   0.34, 0.02, 0.52, ang=pi)`) is now two smaller tapers angled apart
   (`ang = pi ± 0.30`, `r0=0.15` each, roughly half the old base radius) —
   a forked tail. This changes the *base* of the kite, the opposite end from
   where `guard`'s own fix (batch 15 pass 2) added its shoulder flares, so
   the two now differ at both ends rather than trading one shared-silhouette
   problem for another.
2. **Mechanic match (6).** The old cross (`slabf(0,0.02,0.045,0.34)` +
   `slabf(0,0.02,0.24,0.045)`, a vertical bar and a horizontal one) is
   replaced with one raised boss (`ball((0,-0.12,0.02), (0.12,0.06,0.12))`,
   pulled to y=−0.12 the same way `guard`'s clock ring had to be pulled
   forward of the body's own y=−0.10 face to render instead of hiding inside
   it) — a domed stud, not a plus sign.

Rebuilt with `blender --background --python tools/blender/icons.py --
game/assets/icons` (the same invocation `build.cmd icons` makes; no other
icon script touched — confirmed by diffing every PNG in the batch's own
output against a pre-edit render, pixel arrays identical everywhere except
`shield.png`), then `--headless --import` in Godot so the reimported PNG is
what the game actually loads, then `run_tests.gd`.

Renders: `design/renders/shield_pass2_full.png` (composited on the same
brown card-face standin `RGB(139,105,74)` prior batches used) and
`design/renders/shield_pass2_42px_big.png` (real 42px `LANCZOS` downsample,
nearest-neighbour upscaled for viewing).

Sampled actual PNG pixels rather than eyeballing: alpha bbox `(51, 25, 205,
246)`, comfortable margin, no clipping. The boss reads as its own shape —
centre sample RGB(119,121,129) against the body plate's RGB(143,148,160),
visibly darker/cooler in the lit render rather than blending flat into the
plate. The gap between the two fork prongs is real background (alpha 3 at
the sampled point, not a thin sliver of body colour), so the fork reads as
two separate points rather than one point with a scored centre-line.

- **Family distinction (3 → 7):** side by side with `guard`'s current
  (post-fix) render at 42px, the pair now differs by outer silhouette at
  both the shoulders (`guard` has flares, `shield` doesn't) and the base
  (`shield` forks, `guard` still tapers to one point) — checked directly in
  the downsample, not assumed from the script. Not higher: both are still
  fundamentally the same flat-top kite body underneath those two added
  marks, which is arguably correct since they are meant to read as a
  family — same ceiling `guard`'s own pass 2 landed on for the same reason.
- **Mechanic match (6 → 8):** a domed boss reads as a shield stud — a real
  shield-design element — without borrowing the plus-sign silhouette this
  game's card-game genre otherwise uses for "heal." Not a 10: the boss is a
  single round mark and a very small part of the icon's total area, so it
  is a supporting cue rather than something that reads as "block" entirely
  on its own the way the kite outline itself does.
- **Silhouette @ 42px (8, unchanged):** confirmed directly in the 42px
  render — both fork prongs survive as distinct tapering shapes rather than
  blurring into one point, and the boss stays a clean circle, so the swap
  didn't cost the line that was already strong.
- **Colour & contrast (7, unchanged):** same STEEL body / SILVER accent
  pairing as pass 1; neither fix touched colour.
- **Style consistency (8, unchanged):** the fork uses the same `spike()`
  vocabulary the original single point did, and the boss is the same
  `ball()` primitive `gadget`'s rivet and `bomb`'s fuse tip already use
  elsewhere in the set; construction style didn't change.

**+6 total (32 → 38), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether a player reading `shield` at actual hand size (well under the 42px
downsample used here) will register the boss as a deliberate stud rather
than as a slightly darker smudge in the middle of the plate — confirmed
readable as a distinct circle at 42px, but a still smaller real hand-card
size wasn't checked. Also carrying forward pass 1's original "unsure":
whether the cross-as-heal association was ever strong enough to mislead a
player in practice — moot now that the cross is gone, but never confirmed
either way.
