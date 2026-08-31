# goblin_mech — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/goblin_mech.py`.** Views:
`design/renders/goblin_mech_pass1_*.png`. First scoring under item #83's
rubric for a **hunter** (1400 tri budget). The build script's own header
states the design intent directly: "one ordinary arm, one enormous
mechanical one... which is exactly what box() and taper() are for" and
"Goblin round, rig square, and the two halves of the silhouette disagree
with each other, which is the character" — that stated intent is the bar
this scoring measures against.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 7 | 7 | **29** |

## What is actually there

A green goblin with a round head, cone ears, goggles on a gold strap, and a
small ordinary green arm on one side, standing next to/under a cluster of
grey mechanical boxes on the other side: a compressor-like box with an
orange exhaust pipe angled up behind the head, a shoulder block, an
upper-arm limb, a wrist joint, and a lower claw/piston assembly near the
feet, with a raised orange bent arm-shape above the shoulder.

- **Silhouette** (`_sil.png`): the asymmetry the module doc calls for is
  present — one side is bulkier than the other — but it doesn't read as one
  arm. A grey block sits directly behind the head (visible as a rectangular
  notch top-left of the silhouette) and other grey mass sits low near the
  feet, so the rig reads as three or four separate lumps distributed around
  the goblin's body rather than a single mechanical limb the goblin is
  wearing.
- **Proportion**: the goblin's own body — head, ears, snout, legs — is
  correctly goblin-proportioned and reads fine on its own. The rig, which is
  supposed to be "enormous" per the module doc, doesn't read as a single
  enormous object; it reads as several medium objects, so the "small goblin
  under an oversized rig" contrast the doc names is present in intent but
  not in the render.
- **Build hygiene**: 1484/1400 tris, 84 over the hunter budget, one mesh.
  The rig is built as a single connected limb chain in the script (shoulder
  box → upper arm → wrist → claw, per `goblin_mech.py`), but the connecting
  cylinder segments between the boxes are thin enough, and the boxes bulky
  enough, that in every lit view the joints disappear and the boxes read as
  independent floating pieces rather than a jointed arm — the same
  "orbiting part" family of failure named for several beasts' sigils in this
  item's other batches, here affecting a whole limb rather than one small
  part.
- **Colour & read**: green goblin against GRAPHITE/PEWTER/STONE rig
  separates cleanly, and the orange/carrot exhaust and piston accents pop
  against the grey. No dark-on-dark. This is the model's strongest line.
- **Style consistency**: the boxy, bevelled-edge machine parts read as
  "machined plate" the way the module doc intends, distinct from the
  goblin's soft organic shapes, and that material/shape contrast fits the
  cast's established look.

## Diagnosis — two lowest

1. **Silhouette (5).** The rig reads as scattered blocks, not one arm. The
   compressor box sits centered behind the head rather than clearly hung off
   the shoulder, which is the single biggest reason the read breaks —
   concrete fix: move the compressor box (currently near x=0.0, the goblin's
   own centerline) fully onto the rig's side of the model, so nothing
   mechanical crosses behind the head in any view.
2. **Proportion (5).** Because the rig doesn't cohere, "enormous" doesn't
   land — it reads as goblin-plus-clutter rather than goblin-under-oversized-
   machine. Concrete fix: thicken the connecting limb segments between the
   shoulder box, wrist, and claw (currently 0.086–0.098 radius against boxes
   roughly 0.12–0.15 half-extent — nearly half the width of the boxes they
   join) so the joints don't visually vanish between the bigger masses.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the raised orange bent arm-shape above the shoulder (clearest in
`_side.png` and `_top.png`) is meant to be visible at all from the fight
camera's default angle, or whether it is mid-animation geometry that
happens to render static here — the module doc doesn't mention it and this
scoring pass has no way to tell intent from an accident without asking.
