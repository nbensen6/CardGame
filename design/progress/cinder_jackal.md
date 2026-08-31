# cinder_jackal — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/cinder_jackal.py`.** Views:
`design/renders/cinder_jackal_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 7 | 8 | 7 | **32** |

## What is actually there

A lean canid: four slender dark legs, a narrow rust-orange ribby torso, a
black wedge-snout head with pointed ears and amber eyes, a raised orange
bar sitting along the spine, a gold swirl sigil on the flank, and a flat
solid wedge tail sticking straight out behind. The legs, ears and snout
land the "lean chase predator" intent well; the spine ridge and tail don't
match their own module doc.

- **Silhouette** (`_sil.png`): the ears and general quadruped shape read,
  but the spine bar and torso merge into one clump at the top, and the
  tail wedge continues the body's line as a straight spike rather than
  dropping away like a tail.
- **Proportion**: legs, snout and ears read correctly lean and jackal-like.
  The module doc calls the spine ridge "low... a smouldering mane," but
  what's built is a stiff rectangular bar standing proud above the back —
  it reads as a mounted rail or handle, not fur.
- **Build hygiene**: 1180/2600 tris (lightest of this batch), one mesh,
  legs and ridge both appear to join the torso cleanly in the side view.
- **Colour & read**: CHARCOAL head against RUST/TANGERINE body, AMBER eyes,
  and the GOLD sigil all separate cleanly even at small size — this is the
  best colour read of the four beasts scored this pass.
- **Style consistency**: leg and torso construction match the cast's other
  quadrupeds (yoke_ox, flicker_stag).

## Diagnosis — two lowest

1. **Proportion (5).** The "low ember ridge... smouldering mane" described
   in the module doc is built as a rectangular bar standing clear above the
   spine, reading as a rigid attachment rather than fur. Concrete fix: drop
   the ridge bar's base ~0.08–0.10 in Z so it sits flush against the
   torso's own top surface, and taper its ends rather than leaving them
   square, so it reads as raised fur instead of a machined part.
2. **Silhouette (5).** The tail is a flat wedge held level with the torso,
   reading as a horizontal spike continuing the body line rather than a
   tail. Concrete fix: angle the tail down by dropping its far end ~0.15 in
   Z, so in silhouette it visibly breaks away from the body instead of
   extending it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ridge bar's stiff look is actually a budget/style constraint
(this beast is 1180/2600 tris, well under budget, so there's real room to
add a softer, multi-segment ridge instead of one box) or a deliberate
"cinder ember" read I'm misjudging — flagging as a proportion issue rather
than guessing at intent. Also unsure whether the flat tail wedge reads
differently once the beast is mid-attack-animation in the real fight camera
versus this static capture.
