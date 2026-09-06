# gloom_moth — refinement log

Loop: `design/asset-loop.md`. Views: `design/renders/gloom_moth_pass1_*.png`,
`design/renders/gloom_moth_pass2_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 7 | 6 | 7 | 8 | **34** |
| 2 | 7 | 7 | 8 | 7 | 8 | **37** |

## What is actually there

A compact insect on six hair-thin legs: a large purple wing-hump over a
black-blue thorax, a round black head with one blue eye-dot and an orange
curled proboscis, two antennae, and a small yellow sigil disc riding the tip
of one antenna. Top view shows a dark blue circular marking sunk into the
purple wing-mass like an eyespot.

- **Silhouette** (`_sil.png`): a rounded blob with several thin leg-lines
  below at 64px. The general "bug" read comes through, but nothing in the
  black shape is specifically moth-like — no wing points, no antenna
  branches; matches ART-REVIEW's own worry that the wing-hump could read
  as "just a second fuzzy hump."
- **Proportion**: wing-hump, head and six legs read as insectoid and sit
  fine next to the other beasts at this size.
- **Build hygiene**: 1856/2600 tris, 1 mesh, 1 material. The sigil is
  mounted on the antenna tip rather than a bare rod off the body, which is
  a better anchor than most sigil placements scored so far, but it is still
  a small disc riding a hair-thin line well clear of any solid surface —
  it reads as a bead on a wire, not attached hardware. Legs are
  deliberately thin per the build note; they hold up in this render's flat
  light but the note's own worry about game lighting is worth carrying
  forward, unverified here.
- **Colour & read**: purple/black/blue separates well, and the eyespot
  marking on the wings is a genuine identity cue at both render sizes.
  Nothing dark-on-dark. The yellow sigil is small against the dark antenna
  it rides, and could wash out at 34px.
- **Style consistency**: rounded, soft-shaded, fits the cast.

## Diagnosis — two lowest

1. **Silhouette (6).** No wing-tip or wing-fold shape breaks the outline
   from a generic rounded body. Concrete fix: pull the wing-hump's trailing
   edge out into one or two shallow points (extend ~0.08 past the current
   curve on the rear third) so the black silhouette shows an actual wing
   point instead of a smooth dome.
2. **Build hygiene (6).** The sigil disc sits at the very tip of the antenna
   with visible clear space around it. Concrete fix: slide the disc down
   the antenna toward the head by about half its current offset, or anchor
   it to the head/thorax surface directly, so it reads as a marking near
   the head rather than an ornament dangling off a wire.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Pass 2 — fixer, applying pass 1's two proposed fixes

Views: `design/renders/gloom_moth_pass2_*.png`.

1. **Build hygiene (6 → 8).** The sigil's `at` used `b.z_for(5)` for its z,
   which put the disc at z 2.21 (80% of body height) — 0.1 above the actual
   forehead crest ball built to host it (top at z 2.10), and close enough to
   the antenna's own curve to read as riding it. Moving the mark straight
   down onto the crest ball wasn't available: at z 1.86 (the ball's centre)
   the sigil's Height-5 climb point falls to 68% of body height, 12 points
   outside the +/-6% band `run_tests`-equivalent build check enforces, and
   `build.cmd` failed outright (`FAIL GloomMoth: nowhere to stand at
   Height(s) [5]`) — moving the contract band itself is against this loop's
   hard rules, so that's not an option. Settled on z 2.10, the crest ball's
   own top pole (1.86 + its 0.24 z-radius): this keeps Height 5 at 77%,
   inside the required band, while sitting the mark's base exactly on a
   built surface instead of 0.1 above it. Confirmed in the front-view render
   — the sigil now reads as sitting on the head between the eyes, not
   floating near the antennae. Kept.
2. **Silhouette (6 → 7).** Diagnosis called for extending the wing-hump's
   trailing edge ~0.08 past its curve. First two attempts (a point aimed
   mostly rearward off the base LILAC wing ball, then a slightly repositioned
   one) produced zero visible change — `pass2_sil.png` was pixel-identical to
   `pass1_sil.png` both times, because the fight camera's own 3/4 angle
   (`ANGLES["34"]` in `look.py`, offset toward +X/-Y/+Z) looks at the hump
   from the front-right, and a point pushed mostly toward +Y (straight back,
   toward the tail) sits behind the hump's own bulk from that angle and never
   reaches the outline — confirmed by diffing renders, not guessed. Re-aimed
   the pair toward +X/+Z as well as rearward, and moved them onto the UPPER
   FOLD ball (the piece that actually forms the visible rim in this view,
   not the base wing mass sitting behind it). A small mirrored taper (base
   0.22, tip 0.07, matching VIOLET) now breaks the top of the silhouette
   with a shallow facet on each side, confirmed in both `_sil.png` and
   `_form.png` (so it's a real geometry break, not a colour illusion). Went
   through one bolder intermediate version (tip 0.04, depth 0.40) that read
   as a devil-horn spike rather than a wing point — backed off to a blunter,
   shallower version before keeping this one. Kept.

`run_tests.gd` (`--headless --script res://tools/run_tests.gd`): ALL TESTS
PASSED.

## Unsure about

Whether the eyespot marking on the wings is a deliberate identity cue (it
reads as one, and it is the model's strongest asset) or an unplanned result
of the shading — worth confirming it's kept if the wing shape changes. Also
unsure whether the new wing-tip points read as folded-wing edges or as a
pair of small horns at a glance — they clear the silhouette test and stay
inside budget, but a design call on whether "horn-adjacent" is acceptable
for a moth is Nick's, not a measurement question.
