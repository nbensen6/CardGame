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

## Pass 3 — #86 duty 1

Lowest-scoring icon/portrait left in this lane's scope (icons.py/
portraits.py only) at the time of picking — `mountain_climbers_portrait`,
`bog_leech_portrait`, `cinder_jackal_portrait` and `clot_toad_portrait` all
score lower or the same but each names a fix that needs the beast's own
model geometry (out of bounds for this lane); `guard` was the lowest whose
own diagnosis stayed inside `icons.py`.

Three lines were tied lowest at 7: Family, Colour, Style. Rendered the
current PNG fresh (`blender --background --python tools/blender/icons.py --
<tmp dir>`, apt Blender 4.0.2, headless) and looked at it beside `shield`,
`wall` and `sword` (`design/renders/guard_icon_pass3_vs_family_42px.png`,
all four at a real 42px `LANCZOS` downsample) before picking which two to
chase, rather than assuming from the written scores alone.

The render confirmed something the numbers alone didn't say clearly: next
to its neighbours, `guard`'s `ICE` body reads as visibly pale and washed
out — closer to white than to any other icon's value — where pass 1's own
Colour finding had already called it "the lightest of the four in this
batch" and Style's finding called it out for sitting "further from the
rest of the set's generally mid-toned palette." Both lines were naming the
same root cause from two angles, not two separate problems. Left Family
alone: pass 2 already gave `guard` and `shield` different silhouettes at
both ends (flares vs. fork), and pushing a third differentiator risked
re-litigating the "arguably correct to share a family resemblance" point
pass 2's own log already settled.

**Colour (7) / Style (7), single fix for both.** Swapped the body swatch
(main plate, base point, both shoulder flares — every `ICE` call in
`guard()`) to `SKY`, three lines in `tools/blender/icons.py`. Tried `SKY`
first because it sits in the same cool-blue family as `ICE` (`kenney.py`'s
`BLUE, INDIGO, ICE, SKY = swatch(x, 192)` row) but is not `shield`'s own
`STEEL`, so the fix wouldn't trade the colour-based half of Family
distinction away.

Rebuilt the full 36-icon batch (no single-icon build path exists) and
diffed every PNG against the committed `game/assets/icons/` by mean
per-channel pixel difference: every icon but `guard.png` came back at or
under mean 5.87 (the same WORKBENCH render-noise band prior batches have
used, e.g. `burn_icon.md` pass 3's ≤6.7), `guard.png` alone at mean 8.47,
max 116 — real content change. Kept only `guard.png`, left the other 35
untouched.

Verified three ways before scoring:

- **Pixel-sampled the committed PNG.** Body samples RGB(172,184,198) and
  RGB(135,158,182) at two points on the plate — a real blue, not the old
  near-neutral pale grey (previously ~RGB(150-195,160-209,170-209), barely
  distinguishable channel to channel). The `STEEL` ring/hands sample
  RGB(111,121,139) — still roughly a 60-point value gap below the new body,
  the same contrast margin the old ICE/STEEL pairing had, so the swap
  didn't trade contrast for saturation.
- **Alpha bbox unchanged.** `(30, 38, 226, 242)`, identical to pass 2 —
  only colour changed, no geometry touched, so no new clipping risk.
- **Side-by-side render**, not memory:
  `design/renders/guard_icon_pass3_vs_family_42px.png` puts the new
  `guard` beside `shield`, `wall` and `sword` at 42px. `guard` now sits
  inside the same mid-toned value range as its neighbours instead of
  standing out as the one pale/white icon in the row — the exact complaint
  both named lines raised. `design/renders/guard_icon_pass3_full.png` and
  `_42px_big.png` show the same at full size and at the actual downsample.
  `design/renders/guard_icon_pass3_sil.png` (fresh silhouette, alpha>10
  threshold) is unchanged in shape from pass 2's, confirming the fix is
  colour-only.

| Pass | Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 3 | 3 | 7 | 7 | **28** |
| 2 | 8 | 7 | 8 | 7 | 7 | **37** |
| 3 | 8 | 7 | 8 | 9 | 9 | **41** |

- **Colour & contrast (7 → 9):** the body now reads as a genuine saturated
  blue rather than a near-white/grey value, confirmed by direct pixel
  sample rather than the palette name alone (the same "measure the
  rendered pixel, not the swatch" standard `burn_icon.md` pass 3 used) —
  and the ~60-point value gap against the `STEEL` ring/hands held, so
  nothing was traded to get there. Not a 10: the ring's own hue is close
  enough to the new body hue that the contrast is still carried mostly by
  value, not by a hue split the way `shield`'s white-on-blue cross had.
- **Style consistency (7 → 9):** side by side with `shield`/`wall`/`sword`,
  `guard` no longer reads as the one washed-out icon in the row — it now
  sits in the same value band the rest of the cast uses. Not a 10: `SKY`
  is still a fairly light/cool value next to `shield`'s darker `STEEL`, so
  the family isn't identically toned, just no longer an outlier.
- **Family distinction (7, unchanged):** not one of the two named lines.
  The new `SKY` body is a visibly different hue from `shield`'s `STEEL`
  (confirmed in the side-by-side render), which if anything helps this
  line as a side effect, but the underlying kite-and-point body the two
  share is untouched, so the number wasn't moved on the strength of an
  unplanned side effect alone.
- **Silhouette @ 42px (8, unchanged) / Mechanic match (8, unchanged):**
  neither touched by a colour-only fix; confirmed by the unchanged alpha
  bbox and the unchanged clock-face geometry.

**+4 total (37 → 41), not a plateau — kept. Crosses the 40/50 stop line.**
No line regressed. `run_tests.gd`: **ALL TESTS PASSED** (fresh import,
headless, Godot 4.7.1). Stopping here per `design/asset-loop.md`'s stop
condition — 3 of 4 passes used, and past the line the loop calls
"shippable and good."

## Unsure about (pass 3)

Whether `guard` and `shield` should ever share a hue on purpose (the
"family" reading) rather than being deliberately split further — this pass
picked a different hue only as a side effect of fixing the washed-out
value complaint, not as a targeted Family fix, so the question pass 2 left
open about how similar the family should look is still open, and is
closer to Nick's call than a rubric-line fix. Also unsure whether `SKY`
specifically was the best of the ICE-family alternatives (`BLUE`, `INDIGO`
were not tried) or just the first one that measured well — picked the
first candidate that fixed the named problem without introducing a new
one, per the loop's "smallest change that fixes it" spirit.
