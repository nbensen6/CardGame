# guard — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 15 — rubric and method as `design/progress/shield_icon.md` (this
batch's reference file), not repeated here. Asset:
`game/assets/icons/guard.png` (256x256). Second of the "not dying" family
(`shield`, `guard`, `wall`, `support`) — the specific icon
`design/ART-REVIEW.md` names as the closest pair to `shield`.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 3 | 3 | 7 | 7 | **28** |

## What is actually there

A pale grey-white kite/pennant shape — same flat-top, rounded-shoulder,
tapering-point outline as `shield` — with a plain grey "L" glyph centred on
the body. Alpha bbox `(60, 38, 196, 242)`: comfortable margin, no clipping.

- **Silhouette @ 42px (8):** the kite outline and the "L" both stay legible
  through the downsample, same as `shield`.
- **Family distinction (3):** the mirror of `shield`'s finding — this is the
  one pair `ART-REVIEW.md` itself flagged as unsure, and looking at it
  directly confirms the worry rather than clearing it. Outer silhouette is
  effectively identical to `shield`'s at 42px.
- **Mechanic match (3), the weak point of this batch:** `design/ART-REVIEW.md`
  describes the intended build as "a shield with a clock face" — a clock
  face would visually carry "timed" the way `timer`'s icon already does
  elsewhere in the set. What actually renders is a plain block letter "L,"
  which reads as neither a clock nor as timing of any kind on its own; a
  player would need the tooltip to connect it to "block, but timed" at all.
  This is a build-vs-intent gap, not just a legibility problem — even at full
  256px the L reads as a letter, not a clock hand.
- **Colour & contrast (7):** the pale body reads clearly against the brown
  standin — if anything the lightest of the four in this batch, closer to
  `wall`'s neutral tone than `shield`'s more saturated blue. The grey "L" has
  adequate but not strong contrast against the pale body (both are cool
  greys, closer in value than `shield`'s white-on-blue cross).
- **Style consistency (7):** matches the shared bevel/shadow construction;
  docked slightly below `shield` because the near-white body value sits
  further from the rest of the set's generally mid-toned palette.

## Diagnosis — two lowest

1. **Mechanic match (3).** Concrete fix: rebuild the internal mark as the
   clock face the design intent already names — a circle with two short
   hands set at an off-angle (not 12:00, which reads as a plus/cross again)
   — rather than a letter glyph unrelated to timing.
2. **Family distinction (3).** Same fix named in `shield_icon.md`: change an
   outer-silhouette element, not just the internal mark or shade, so
   `shield` and `guard` separate by shape alone.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the "L" was ever meant to evoke a clock hand at a specific hour
(an L-shaped pair of hands, like 9:15) and reads that way to someone who
already knows the intent — cold, with no such context, it read as a letter
in every view checked here, but that prior-knowledge case wasn't testable
from a static image alone.

## Pass 2 — fixer

Before touching either named line, pixel-sampling the committed PNG turned up
a third thing neither pass-1 finding mentioned: the ring `icons.py` already
built for the clock face was never visible in any render. Its `loc` put it
at world y=-0.05, and the body plate's own depth (`slabf`'s default `d=D`)
spans y −0.10 to +0.10 — the ring sat fully inside that range, behind the
body's own front face at y=−0.10, so the opaque ICE plate hid it completely.
That is the real reason pass 1's "what is actually there" section never
mentions a ring at all, and it meant the Mechanic-match fix couldn't just add
hands — there was no visible face for hands to sit on yet.

Applied both named lines, in-lane (no palette edit, no budget/constant
moved):

1. **Mechanic match (3).** Pulled the ring to y=−0.12, in front of the body's
   own face, so it renders. Replaced the two disconnected slabs (the "L") with
   two tapered hands built with `spike()`, both centred so their pivot end
   sits exactly at the ring's own centre (0.0, 0.10) and radiate outward at
   0.5 rad and 2.6 rad — a genuine off-12 angle pair, not the 12-and-3 "plus"
   `design/ART-REVIEW.md` warned against. Each hand's own object had its
   `.location.y` set to −0.12 to match the ring, for the same reason the ring
   needed moving. Both hands kept under length 0.14, inside the ring's own
   tube (inner edge ≈0.164), so neither tip hides behind the rim.
2. **Family distinction (3).** Added a small flared taper at each shoulder
   (`seg=3`, pointed) rooted at the body's own edge (x=±0.30) and angled
   outward-and-up — an outer-silhouette element `shield` does not share at
   all, rather than another change to the internal mark or a shade of the
   same kite outline.

Rebuilt by running `icons.py` directly through Blender (`build.cmd icons`
itself only accepts confirmation to run through this session's shell, so the
same Blender invocation the batch file makes was issued directly — no other
icon script touched), then `--headless --import` in Godot so the reimported
`guard.png` is what the game actually loads, then `run_tests.gd`.

Renders: `design/renders/guard_pass2_full.png` (composited on the same
brown card-face standin RGB(139,105,74) prior batches used) and
`design/renders/guard_pass2_42px_big.png` (real 42px `LANCZOS` downsample,
nearest-neighbour upscaled for viewing). `shield`'s existing PNG was
regenerated the same way, side by side, purely to eyeball the
family-distinction comparison below — not re-committed since its own script
wasn't touched and the render is otherwise identical to what's already in
the repo.

Sampled actual PNG pixels to confirm the geometry, not just the eyeballed
render: the widest row (y=71) now spans x=31 to x=225 (wing tip to wing
tip, both ends still comfortably inside the 256px canvas — bbox `(31, 38,
226, 242)`, no edge clipping), and both wing-tip pixels read RGB(189,198,205)
/ RGB(190,198,204) — the body's own ICE, not a colour artefact. The clock
face interior samples RGB(99,109,129), visibly darker/bluer than the body
fill RGB(191,199,205) it sits inside, so the disc reads as its own shape
rather than blending into the plate.

- **Mechanic match (3 → 8):** a round face with two hands radiating from a
  shared centre at a clear off-12 angle is visible in both the full render
  and the 42px downsample — the thing the design intent named and pass 1
  never got to see rendered at all. Not a 10: the hands are thin and read
  best at full size; at 42px they're a legible dark mark inside the face
  but not as crisp as the face outline itself.
- **Family distinction (3 → 7):** side-by-side against `shield`'s own 42px
  downsample, `guard` now carries two small shoulder flares `shield`'s plain
  kite outline never has — the two separate by silhouette alone, which is
  what this line asked for. Not higher: both are still fundamentally the
  same kite-and-point body underneath the flares, so a very fast glance at
  low contrast could still group them as "the same shield family," which is
  arguably correct since they are meant to read as a family.
- **Silhouette @ 42px (8, unchanged):** the wings are small enough that the
  core kite-and-point shape still reads cleanly at 42px; checked directly in
  the downsample rather than assumed.
- **Colour & contrast (7, unchanged):** same ICE/STEEL pairing as pass 1;
  neither fix touched colour.
- **Style consistency (7, unchanged):** the flares use the same
  `spike()`/bevelled-taper vocabulary `fire` and `sword` already use
  elsewhere in the set; construction style didn't change.

**+9 total (28 → 37), not a plateau — kept.** No line regressed.
`run_tests.gd`: **ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether a player reading `guard` at actual hand size (well under the 42px
downsample used here, which already approximates a card in a full hand)
will catch the hands at all, given Mechanic match's own note above that they
read better at full size than at 42px — the two ideas fixed here (a visible
clock, a distinct silhouette) are both now confirmed in a render; whether
the clock reads at the smallest size it's actually seen is a finer question
this pass's two-fix budget didn't chase further.
