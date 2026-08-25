# Art waiting for a second pass

Anything the cloud routine builds in Blender lands here, because a run has no
display and cannot judge what it made. It can prove a model meets the contract —
holds where the data says, sigil at its Height, budget, one mesh, one material —
and it renders three angles so a human can look. It cannot tell you the thing is
a murky blob, or that the base reads as a spring, or that the sigil is hidden
behind the head. Every one of those got past every automated check we had.

So: the routine BUILDS and PROVES. We LOOK.

## How a run adds to this

One block per asset, newest at the top, appended by the run that made it:

```
### <name> — NEEDS A PASS
- built: 2026-08-25 by the routine, from tools/blender/<name>.py
- checks: assetcheck 4/4, holds PASS (3 holds + sigil), 2140 tris, 1 mesh, 1 material
- previews: design/art-previews/<name>_0.png (three-quarter), _1.png (front), _2.png (side)
- intent: one or two lines on what it was TRYING to be, so a reviewer can judge
  it against that rather than against a guess
- unsure about: whatever the run could not verify — silhouette, colour, whether
  the shape reads at fight distance. Say it plainly; this is the useful part.
```

Move the heading to `### <name> — DONE` once someone has looked and either
accepted it or done the pass. Do not delete the block: what a first pass got
wrong is the most useful thing in this file for the next one.

## What a reviewer is actually looking for

The failures that have happened, all of which passed every check:

- **Too dark to read.** The Stone Warden's two zones were dark and darker, so the
  seam that exists to explain its limiter was invisible.
- **Parts that do not touch.** The Vine-Weaver stood on a spike with hoops
  orbiting it; the Goblin's arm was spaced at arm's length and read as a rock
  standing beside him.
- **Detail hidden behind other detail.** The Warden's sigil sat on the crown
  behind its own head, invisible from the angle you fight it.
- **Slabs that overhang the silhouette**, reading as handles bolted on rather
  than as ledges cut from the body.

---

### goblin_mech — NEEDS A PASS
- built: 2026-08-25 by hand, from tools/blender/goblin_mech.py
- checks: 1484 tris (84 over the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/goblin_mech_0.png (three-quarter), _1 (front),
  _2 (side)
- intent: the rebuild onto the wider vocabulary. The organic half stays soft —
  ball body, cone ears, ball head — and the rig is entirely bevelled boxes and
  cylinders, so the two halves of the silhouette disagree with each other and
  the asymmetry survives being 40px tall.
- unsure about: **the rig arm, and it is the weakest thing in the cast.** From
  the front it works. From three-quarters it still reads as three grey boxes
  stacked beside him rather than as an arm attached to him, and four passes of
  shrinking, swinging and angling it did not fix that. This is a proportion
  problem, which is the exact thing a reference settles and guessing does not —
  see design/art-references/README.md. Any picture of a mech arm, a piston claw
  or a power loader would end it.
  Also unjudged: whether the ears are now too large, and whether the exhaust
  pipe reads as a pipe or as an orange handle.

### frog — NEEDS A PASS
- built: 2026-08-25 by hand, from tools/blender/frog.py
- checks: 1456 tris (56 over the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/frog_0.png (three-quarter), _1 (front), _2 (side)
- intent: the head is now ONE broad wedge that narrows to a blunt snout, split
  across its full width by a grin with a jaw under it, rather than a ball with a
  stripe painted on. Legs bend — one limb() each, folded at the knee — and every
  foot has three splayed toes. Eyes bulge through the skull with a brow capping
  the back of each, so gold still faces the camera.
- unsure about: whether the head now overhangs the body too far (it was widened
  to fix a pinched look and may have gone past it), and whether the pupils read
  as pupils or as heavy black eyebrows at fight distance. The muzzle went
  through three shapes — brick, then shelf, then wedge — and only the last one
  is defensible from the side.

### What the first two rebuilds taught

Worth keeping, because both cost several passes:

- **A box half-extent is not a sphere radius.** Converting a model from
  ellipsoids to boxes one-for-one inflates every part by its corners. About 0.72
  of the old radius matches the old volume.
- **A bevel changes the silhouette width.** The Frog's jaw and grin were given
  the head's nominal width and came out sticking past it on both sides, because
  the head carried a heavy bevel that pulled its outline in and they did not.
