# eyrie_hawk — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/eyrie_hawk.py`.** Views:
`design/renders/eyrie_hawk_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 7 | **33** |

## What is actually there

A bipedal bird: a crested head with a curved beak, a rounded blue-grey body
with a tan belly patch, two large triangular wings, spiked tail feathers, and
clawed legs. A yellow-ringed sigil disc sits beside the head.

- **Silhouette** (`_sil.png`): crest, hooked beak, wings and legs are all
  distinct at 64px — reads as a bird of prey immediately, the strongest line
  for this asset.
- **Proportion**: body and legs read as avian; the two wing slabs are wide,
  flat triangles that read more like stiff flaps than folded feathers.
- **Build hygiene**: `_side.png` and `_top.png` both show the sigil disc
  floating in open air beside the beak with no visible mount to the body or
  head — the exact "part spaced away from the body" failure this file already
  names for the Vine-Weaver's orbiting hoops.
- **Colour & read**: blue-grey body, tan belly, brown head separate cleanly;
  the sigil's yellow contrasts well were it actually attached to something.
- **Style consistency**: proportions and primitive shapes fit the rest of the
  cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** The sigil disc has no visible attachment to the
   model. Concrete fix: move the sigil to sit flush against the chest/shoulder
   plumage (reduce its offset from the torso mesh to near zero) instead of
   hovering beside the head with empty space around it.
2. **Proportion (7).** The wings are flat wide triangles that read as bulky
   panels rather than feathered wings. Concrete fix: taper each wing's trailing
   edge by roughly 40% and add 2–3 of the same thin spike shapes already used
   on the tail, so the wing reads as layered pinions instead of one solid slab.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the sigil was intended to sit on the head crest (close by, on a small
mount) rather than the chest — either placement fixes the floating problem,
but they read differently on the model and it isn't this pass's call which.
