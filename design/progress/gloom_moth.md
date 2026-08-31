# gloom_moth — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/gloom_moth.py`.** Views: `design/renders/gloom_moth_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 7 | 6 | 7 | 8 | **34** |

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

## Unsure about

Whether the eyespot marking on the wings is a deliberate identity cue (it
reads as one, and it is the model's strongest asset) or an unplanned result
of the shading — worth confirming it's kept if the wing shape changes.
