# What the art is aiming at

Written 2026-09-07, because Nick asked the question the loop could not answer:
*"The beasts are really low quality. What is it scoring against?"*

## The honest answer was: nothing you can look at

`design/asset-loop.md` has said so since it was written:

> **Reference:** the Kenney models still in `game/assets/3d/` as stand-ins, and
> `dissect.py` output. There is no reference image per creature — that is the
> single biggest quality ceiling here.

So a pass scored a model against **a written rubric and a polygon-count
statistic**. That explains the shape of every pass in the log: "the ridge sits
flush", "the yoke clears the horns", "the gem nests in the coil". All true, all
verified in a render, and all *measurements* — because a measurement is the only
kind of fix you can derive without a picture of where you are going.

Nobody ever wrote "this does not read as a jackal", because there was nothing to
read it against.

## What was measured — and the first result was wrong

`tools/blender/silmetrics.py` reads every committed silhouette. Its first run,
2026-09-07, reported `gale_serpent`, `stone_warden`, `crag_pup` and `bounder`
as the four worst models in the game — solidity 0.90+, distinctness 0.09–0.13,
twins of each other — and claimed none had ever been scored.

**All four are arena grounds, not beasts.** Four rings of standing stones are
of course near-identical in silhouette and of course have no negative space.
Each already had a `<name>_ground.md` scoring it correctly as a ground. The
cloud caught it on 2026-09-08 by opening the render before writing the
diagnosis, which is the rule that saved it; the root cause was `look.sh` and
`look.cmd` sending a beast and its same-named ground to the identical
`design/renders/<name>_pass<N>_*.png` files, whichever ran last winning
silently. Fixed in `b2d5d63` — grounds now write `<name>_env_*` — and the whole
cast was re-captured on 2026-09-08 so every asset has a render that can be
trusted.

The corrected numbers are in Layer 1 below, and they refuted the thresholds
this document originally proposed. Read that section rather than reasoning from
this one.

## What the games we want to look like actually do

Common ground across the writing on stylized, readable game art — TF2 and
Overwatch are the canonical case studies, and the low-poly literature says the
same thing more bluntly because it has fewer polygons to hide behind:

- **The silhouette is the whole test, and it is a pass/fail one.** A silhouette
  study in solid black is the *first* acceptance test: if it is not recognisable
  as black-on-white, the shape language has failed and no amount of texture or
  colour polish recovers it. In low-poly work the outline carries more of the
  load than anywhere else, because there is nothing else to carry it.
- **Exaggerate one anchor per character.** Reinhardt's hammer, Lúcio's
  headphones, D.Va's mech profile — a single oversized feature that reads at
  every distance and in every pose. Not overall detail: one anchor.
- **Negative space is sculpted deliberately, not left over.** Detach the head
  from the torso, hold the limbs off the body, put a readable void where the eye
  can find it. Genshin's Azhdaha is divided into three clearly distinct sections
  with voids between them so the player can tell instantly which part is about
  to strike. This is precisely what the solidity number measures, and 0.93 means
  there is no negative space at all.
- **Shape language carries personality before anything else does.** Round reads
  friendly, angular reads dangerous, boxy reads stable and slow. Pick one and
  commit; a creature built from neutral boxes reads as nothing.
- **Value and hue point the eye at the part that matters.** TF2 makes the
  Heavy's bandolier and drum magazine the contrastiest thing on him, so the eye
  is led to the dangerous end. Our palette is flat and shared, which is a
  strength — but only if each beast decides *where the contrast goes*.
- **Lighting does a great deal of the perceived quality.** The usual observation
  about Deep Rock Galactic is that the geometry is not especially low-poly and
  it is the lighting that makes it look good. The game already does this per
  biome (`combat_3d.gd`, sun/fill/ambient/fog). The **render harness does not** —
  `look.py` shoots a flat studio render on grey. Keep that for scoring
  silhouettes, but do not conclude from it how the beast looks in a fight.

## What the reference actually has that we do not

Put five Kenney animals beside five of our beasts, lit render over 64px
silhouette, and the difference is not subtle and not what the metrics were
looking for. Three things, in order of size:

1. **Kenney's animals have FACES. Ours do not.** Big flat eyes, a defined
   snout, ears that read as ears — placed on a head that is a distinct colour
   block from the body. Our beasts have a featureless head and a sigil disc
   roughly where a face would go. In a style with this little geometry, the
   face is the single strongest readability device available, and we are not
   using it at all. This is almost certainly the biggest quality gap in the
   cast.
2. **Kenney's proportions are chunky; ours are spindly.** Their limbs are thick
   stubs; ours are thin sticks. Thin limbs on a low-poly model read as fragile
   and cheap, and they are also what drags our solidity down — the number that
   looked like "we have good negative space" is partly just "our legs are too
   thin".
3. **Kenney separates head from body by colour.** Ours are largely one brown
   mass with a slightly different brown on top. The palette is shared and flat,
   which is right, but each creature still has to decide where its contrast
   goes.

None of this is a silhouette problem, which is why a silhouette metric could
not see it. All three are cheap to act on and none of them is a rebuild.

## The reference set — and why it is legal

Do not download screenshots of other games into this repo, and do not score
against a memory of one.

Use what is already here and already CC0: **the Kenney packs in
`game/assets/3d/`**, which `asset-loop.md` already names as the reference and
which `tools/blender/dissect.py` already measures (~575 tris median, ~80% of
faces smooth-shaded, ~30% of edges in a 25–50° bevel band). Run `silmetrics.py`
over Kenney silhouettes and you get the target numbers from art a professional
made and sold, in the exact style this game is built in, with no licensing
question at all.

Anything beyond that is **Nick's to supply**. A reference image per creature is
the single biggest lever on quality here and no agent can invent one. Until it
exists, a pass can fix *defects* but cannot chase a *look*.

## The system: three layers, in this order

### Layer 1 — measurement, and what it turned out to be worth

```
python tools/blender/silmetrics.py <asset>
```

**This layer shipped as two gates and the reference destroyed both of them
within a day. Read this before trusting any number in it.**

The gates were solidity < 0.80 ("at or above, the model is a shape assembly
with no negative space") and distinctness > 0.25. Both numbers were reasoned
out, not measured. On 2026-09-08 the whole cast was re-captured — including the
eighteen unused Kenney animal packs, which are CC0 and are what this project
already calls its reference:

```
KENNEY REFERENCE  n=18  solidity 0.82-0.95 median 0.92   distinct 0.04-0.15
OUR CAST          n=36  solidity 0.46-0.90 median 0.75   distinct 0.15-0.69
```

**Every Kenney animal fails both gates.** Kenney's dog and pig share 96% of
their silhouette; cat and tiger 95%. Our beasts have *more* negative space and
are *more* distinct from one another than art a professional made and sold in
this exact style — and they still look worse. So whatever "a blocky mess" is,
solidity and distinctness are not measuring it.

The instructive part is the direction. **Kenney's animals are simpler than
ours, not more complex** — one confident body, a clear head, few parts, strong
colour blocks. Our beasts are busier and gappier and read worse for it. If
there is a lesson in the numbers it is the opposite of the one the gates
assumed: the fix for a beast that reads badly is more likely to be *simplify
and commit to the primary form* than *carve more negative space into it*.

So:

- **Solidity and fill are descriptive.** Report them against the reference
  band. They fail nothing.
- **Near-twins inside our own cast are worth acting on**, because two beasts a
  player meets across one run reading identically is a gameplay problem even
  when it is stylistically defensible. As of 2026-09-08: `boulder_ram`/`yoke_ox`,
  `riftling`/`sunken_warden`, `root_lurker`/`shifting_idol`.
- **No number here outranks the eye.** That was the mistake.

The tool's real value so far has not been its metrics at all: it was pointing
at four "worst beasts" that turned out to be arena grounds, which is how the
`look.sh`/`look.cmd` filename collision was found. A measurement that is wrong
in a checkable way is still worth having.

### Layer 2 — the named anchor (a sentence, written once per creature)

Before any pass, the progress file must carry one line:

> **ANCHOR:** *a low slung wedge with one oversized shoulder ridge — angular,
> front-heavy, reads as a charging thing.*

One primary form, one exaggerated feature, one word of personality. If that
sentence cannot be written, the creature is not designed yet and the correct
output is `VERDICT: REBUILD`, not a pass. Every later pass is judged against
this sentence — which is what turns "improve the silhouette" into something a
scorer can actually be wrong about.

### Layer 3 — the rubric

Unchanged in shape, five lines out of 50, with the anchors and tier stop lines
in `design/asset-loop.md`. It runs **after** the gates, and it may not be used
to argue a gate away.

## How we get from here to there

1. **Write the ANCHOR line for every beast.** Cheap, one sentence, and it is
   what every later judgement hangs off. Several will fail at this step, which
   is information, not failure. This is now step one because it is the only
   layer of the three that the reference did not knock down.
2. **Score the beasts that have never had a bare-name progress file.** Nine of
   them as of 2026-09-08. They now have trustworthy renders for the first time.
3. **Look at Kenney beside our worst, at 64px, before proposing anything.** The
   reference is eighteen models in `game/assets/3d/cast` and it is free to open.
   The gap is not negative space — measured, we already have more of it than
   they do. It is confidence of form and separation of colour.
4. **Break the three near-twin pairs** — `boulder_ram`/`yoke_ox`,
   `riftling`/`sunken_warden`, `root_lurker`/`shifting_idol`. Changing an
   anchor shape is a rebuild, and rebuilds are Nick's call.
5. **Then chase rubric points.** Detail work on a model whose ANCHOR sentence
   is honest is worth doing. Detail work on one that has no such sentence is
   what produced six beasts that each gained 3 points and still look like boxes.

## Card icons — a different problem with a sharper answer

```
python tools/blender/iconmetrics.py
```

First run, 2026-09-07: **36 of 60 icons sit under 3.0:1 contrast against the
card face. Median 1.73:1.** `wall` measures **1.00:1** — the same luminance as
the card it is drawn on. On `gadget`, 48% of the icon's own pixels are within
20 luminance of the background, so half the drawing dissolves.

The split is absolute and it is not a matter of taste:

| style | contrast | example |
|---|---|---|
| flat white silhouette | **4.98:1**, 0% lost | `pawns`, `puzzle`, `structure_wall`, `flask` |
| shaded 3D render | 1.0–2.5:1 | `wall`, `gadget`, `peak`, `fire`, `shield`, `cog` |

Every flat icon passes. Every 3D icon fails. A lit render of a tan or grey
object is, at 42px on a brown card, a tan or grey smudge.

**This is the same structural fault as the beasts.** Contrast is one line of
five, so `fire` climbed 23 → 41/50 while sitting at 1.41:1 — four lines
improving averaged away the one line that decides whether a player can read the
card. At 42px on a brown card, contrast is not a fifth of the value. It is most
of it.

So for icons, contrast is a **gate**, not a score line:

- **3.0:1 minimum** against `RGB(139,105,74)` at 42px, measured, before any
  other judgement about the icon is worth making.
- **Two values maximum plus one accent.** A 42px icon cannot carry a lighting
  ramp. Flat fill, hard edge.
- **The silhouette is the icon.** If it does not read in solid black at 42px it
  does not read.

**But the real answer is not to keep polishing icons.** Two reasons, and Nick
should decide between them rather than have a lane guess:

1. **The set is in two clashing styles right now** — half flat white, half
   shaded 3D — which reads worse than either style would alone. Committing to
   one is a bigger visual win than any number of passes. On the measurement,
   flat wins 4.98 to 1.73, and that is before considering that flat is also
   what Slay the Spire does.
2. **Every card Nick paints deletes an icon for good.** A card with its own art
   never draws its icon again. 36 of 88 scored assets are icons; work on them
   has a shelf life measured in however long the card art takes.

## The cheapest real quality wins, ranked

Asked for on 2026-09-07: *"any suggestions on how to up the quality of the
game?"* In order of visible change per hour, on the evidence above:

1. **Card art.** 187 cards, roughly four painted. Card art is the biggest
   element on the biggest thing the player looks at, it deletes a failing icon
   every time one lands, and it is the one place where more effort reliably
   shows. Nothing else on this list is close.
2. **Pick one icon style and convert the set.** Measured, flat wins. This is a
   day of work and it fixes 36 failing icons at once.
3. **Break the four twinned silhouettes.** `gale_serpent`/`stone_warden` share
   91% of their outline. Two beasts reading as one is a gameplay problem, not
   only an art one.
4. **Fix the eight blocky beasts at the form level**, not the detail level —
   gates first, per this document.
5. **Lighting in the render harness.** The game already lights per biome; the
   scoring harness shoots flat grey. Keeping it flat for silhouettes is right,
   but nobody has ever scored a beast as it actually appears in a fight, and the
   usual observation about Deep Rock Galactic is that lighting is doing most of
   the work its geometry gets credit for.

## The thing this system still cannot do

It cannot tell you the beast is boring. Solidity, distinctness and a rubric will
all pass a perfectly readable, perfectly distinct, entirely forgettable animal.
That judgement is Nick's, it needs reference images to be worth anything, and no
amount of scoring machinery substitutes for it.
