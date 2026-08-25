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
- **A silhouette that cannot be fixed by fixing the model.** The Vine-Weaver was
  rebuilt once, well, and still read as a lamp — because a stalk with a bloom on
  it is a line with a dot on it. When three passes all land somewhere weak, ask
  whether the design is wrong before tuning it a fourth time.

---

### the fourteen fight grounds — ALL NEED A PASS

Built 2026-08-25, from `tools/blender/env/<beast_id>.py` on the `env.py` helper.
Every beast now fights somewhere rather than on the same blank disc.

| beast | where it fights |
|---|---|
| stone_warden | a quarry somebody stopped working — everything has a straight edge |
| crag_pup | a scree hollow ringed with standing stones, the rock it is made of |
| bounder | a dry riverbed of rounded cobbles, flat so you can watch it land |
| bramble_hog | a thicket floor trodden into a hollow; the brambles at rest |
| root_lurker | forest floor growing the same roots it is hiding among |
| mire_snapper | shallow water over silt, with logs it is pretending to be |
| sky_snapper | bare cliff-top rock, wind-scoured, with its nest and bones |
| frost_sentinel | a frozen lake, cracks running out from where it stands |
| shifting_idol | a plaza somebody built and left; the only made ground |
| grove_bear | a clearing in old woodland it half disappears into |
| gale_serpent | a ridge whose rock winds in the same spiral the beast does |
| drowned_colossus | a tidal flat at low water, pools and kelp and ribs |
| sunken_warden | a drowned temple, the only fight with walls |
| riftling | ground come apart into drifting plates, lit from below |

**What to judge, in this order:**

- **Do they read as fourteen PLACES or as fourteen palettes?** The intent was
  that each beast fights somewhere that explains it — the Pup on its own
  hillside, the Snapper among logs it could be mistaken for. Judge that as a set;
  it is the thing that cannot be seen one at a time.
- **The Mire Snapper's water.** STEEL on CLAY silt is the weakest colour call in
  the batch and may not read as water at all from the fight camera.
- **The Grove Bear may work too well.** It was deliberately made to half
  disappear against its treeline, and there is a real chance that crosses from
  atmospheric into hard-to-read.
- **The Riftling's floating shards.** The only environment with things in mid
  air on purpose. If they read as a bug rather than as the beast's effect on the
  world, they should go.

**Unjudged:** whether the aprons are too visible at the edges of a wide shot,
and whether any ground is busy enough to fight the creature standing on it.

### What building the grounds taught

- **Anything tall belongs BEHIND the beast** (`env.BACK`). The camera sits about
  as far from a beast as its ground is wide, so a standing stone on the front rim
  is not scenery, it is a wall. The first build without that rule filled the
  screen with the inside of a boulder.
- **Size the world off the beast's HEIGHT, not its footprint.** The Mire Snapper
  is mostly jaw and tail; sizing its ground off how far it sprawls gave it a floor
  sixty units across and an apron the camera stood inside.
- **Scale by a constant, not by measured bounds.** An environment's props and
  apron overhang its floor on purpose, so its bounds say nothing about how big
  the floor is.
- **The island check is the wrong tool for a ground.** It exists to catch a limb
  in mid-air on a character; on a field of scattered rocks it reports "35 pieces
  do not touch" and that is how a real warning gets missed. `Env` turns it off
  and says why.

### lightbearer — NEEDS A PASS

The cloud added a fifth hunter (#47) with no model, so it was on screen as a
bunny. `Cast.PLACEHOLDER` did not even have an entry for it, which is why the
fallback was the default rather than something chosen.

- built: 2026-08-25 by hand, from tools/blender/lightbearer.py
- checks: 1312 tris (inside the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/lightbearer_0.png (three-quarter), _1, _2
- intent: the class banks a resource and spends it in one go, so the read is a
  VESSEL — a lantern held high on a staff and a second light already caught in
  the chest. Two lights, one stored and one carried. Silhouette-wise it is the
  shape the cast did not have: a tall narrow triangle, and the only hunter whose
  highest point is not part of its body.
- unsure about: whether the hood reads as a hood or as a party hat (the dark
  face under it is doing all the work), and whether a robe with no legs reads as
  deliberate or as unfinished at fight distance.

### the eleven beasts that had no body — ALL NEED A PASS

Built 2026-08-25 by hand, from `tools/blender/<id>.py`, on the new `beast.py`
helper. Every beast in the game now has its own body: fourteen of fourteen, none
of them a Kenney farm animal.

All eleven pass the hold contract **in Godot**, not just in Blender:
`assetcheck.gd -- file=... beast=<id>` reports "every hold and the sigil have a
shelf at their Height" for all fourteen beasts including the three older ones.

| beast | holds / sigil | tris | the one-line idea |
|---|---|---|---|
| bounder | 2 / 4 | 1580 | almost all legs; a boulder slung between them |
| bramble_hog | 2 / 5 | 1796 | no creature under the brambles — the brambles are it |
| root_lurker | 2 / 5 | 2046 | a cage of roots you can see daylight through |
| mire_snapper | 3 / 6 | 2080 | the only horizontal beast; you stand IN its mouth |
| sky_snapper | 3 / 5 | 1580 | top-heavy: a hooked beak and folded plates on thin legs |
| frost_sentinel | 2,5 / 7 | 1112 | the only angular one; a lit core in an open gap |
| shifting_idol | 2,4 / 6 | 1280 | stacked blocks that never line up — the overhang IS the ledge |
| grove_bear | 3,5 / 7 | 2212 | weight; a hill that stood up, no head, a hollow instead |
| gale_serpent | 3,6 / 9 | 1922 | a spiral — the only shape that says climb AROUND me |
| drowned_colossus | 3,6,9 / 11 | 2506 | three terraces, kelp hanging off each so holds read from below |
| sunken_warden | 3,6,9,11 / 13 | 3054 | four tiers tightening toward the crown; one arm already broken off |

**What a reviewer should look at first**, because these are the calls I made that
could reasonably go the other way:

- **The Mire Snapper's hold is inside its mouth.** That is either the best or the
  worst idea in the roster and I cannot tell which without playing it.
- **The Sunken Warden is 1.2x the beast budget** (3054 of 2600), down from 4302.
  Four tiers of coral is what costs it. Same call as the Ent: accept, or say what
  goes.
- **The ledges are visibly ledges** — grey slabs stepping out of the body. Honest
  about where you stand, but on the Warden and the Colossus they read a little
  like scaffolding. Worth deciding whether that is a feature.
- **Silhouette spread.** The set was designed so no two share an outline: legs,
  bramble, cage, horizontal, top-heavy, angular, stacked, mass, spiral, terraced,
  tower. Judge that as a GROUP rather than one at a time — it is the only thing
  here that cannot be checked one model at a time.

**Not judged at all**: colour at fight distance, whether the amber eyes read as
eyes or as hot spots, and whether any of the eleven is simply boring.

### What building eleven at once taught

- **A sigil that passes every check can still hang in mid air.** Four of the
  first five had the mark floating off the body, because `mark()` placed it at
  80% of the height whether or not there was body there. It now checks for
  geometry near the anchor and says so, and the disc faces OUT rather than lying
  flat — every sigil in the game before today was a gold pancake balanced on the
  beast, inherited from the Stone Warden.
- **Ask the geometry where it is.** The Gale Serpent's ledges were placed by hand
  at the height the data wanted and came out hanging beside the coil, because a
  helix has moved on by the time it reaches that height. Computing the position
  from the coil itself fixed it and cannot drift again.
- **A bevel on a 12-sided drum triples its cost and changes nothing.** Most of
  the Sunken Warden's 4302 triangles were bevels and coral nobody would count.

### vine_weaver — NEEDS A PASS (redesigned as an ENT)

Not a rebuild, a **redesign**, at Nick's call on 2026-08-25: the Vine-Weaver is
now a walking tree rather than a flower on a stalk. The old silhouette was a
vertical line with a dot on top — the same outline as a lamp — and no amount of
rebuilding was going to fix that, because the shape itself was the problem.

- built: 2026-08-25 by hand, from tools/blender/vine_weaver.py
- checks: 1704 tris (**304 over the 1400 hunter budget — see below**), 1 mesh,
  1 material, all parts touching, assetcheck 4/4
- previews: design/art-previews/vine_weaver_0.png (three-quarter), _1, _2
- intent: the Ent read is carried by four things — a face cut INTO the wood with
  a jutting brow so the eyes sit in their own shadow, root feet with three toes
  each reaching the ground at different lengths, arms that FORK rather than
  bend, and a canopy wider than the trunk so the top of the silhouette is a mass
  and not a point. The vines stay, wound up the trunk with leaves on them, so
  the class name still means something.
- **the budget overage is a decision, not an oversight.** An Ent has a canopy,
  two forked arms, six root toes and two vines. Getting it under 1400 means
  losing one of those. Accept it, or say which one goes.
- unsure about: the vines took three passes and are still the weakest part —
  thin they read as moss, thick they read as green shelves, and this is the
  compromise. Also unjudged: whether the canopy is too big for the trunk, and
  whether the amber eyes read as eyes or as knots at fight distance.

### mountain_climbers — NEEDS A PASS
- built: 2026-08-25 by hand, from tools/blender/mountain_climbers.py
- checks: 1436 tris (36 over), 1 mesh, 1 material, all parts touching,
  assetcheck 4/4
- previews: design/art-previews/mountain_climbers_0.png (three-quarter), _1, _2
- intent: the rope is the class, so it is an actual rope — one limb wound twice
  round the chest on a helix whose radius follows the torso's own curve, so it
  lies ON him. Two horizontal tori read as a barrel. The pack is a bevelled box
  because a pack is a box, the beard is a taper, the boots are wedges, and the
  carabiner is a torus you can see through.
- unsure about: whether the beard now reads as a beard or as a bib, and whether
  the rope is legible against the blue at fight distance or just texture.

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
