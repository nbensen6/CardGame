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

## What was measured on 2026-09-07

`tools/blender/silmetrics.py` scores every committed silhouette. First run:

| asset | solidity | distinct | nearest twin |
|---|---|---|---|
| gale_serpent | 0.93 | **0.09** | stone_warden |
| stone_warden | 0.92 | **0.09** | gale_serpent |
| crag_pup | 0.92 | **0.13** | gale_serpent |
| bounder | 0.90 | **0.10** | stone_warden |
| … | | | |
| flicker_stag | 0.50 | 0.48 | eyrie_hawk |
| mire_snapper | 0.50 | 0.49 | drowned_colossus |

**12 of 36 fail a gate.** Two things fall out of it:

1. **A serpent and a stone warden share 91% of their outline.** So do a pup and
   a serpent. These are not the same *kind* of creature and they should not be
   confusable at any distance, let alone the 64px the eye actually resolves of
   a beast across the arena.
2. **The four worst models in the game had never been scored at all** — no
   progress file, never in the queue, while the loop spent 09/07 on 42px card
   icons. The queue was never ordered by anything that correlates with quality,
   because nothing measured quality.

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

### Layer 1 — measured gates (automatic, either lane, no screen)

```
python tools/blender/silmetrics.py <asset>
```

- **solidity < 0.80.** At or above, the model is a shape assembly with no
  negative space. This is a gate, not a score line: fail it and the diagnosis
  *must* be about carving space into the form, not about a detail.
- **distinctness > 0.25.** At or below, something else in the cast has nearly
  the same outline. Fail it and name the twin in the progress file; the fix is
  to change the anchor shape, not to nudge a part.

A failing gate outranks every rubric line. It is the reason the pass exists.

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

1. **Score the unscored.** `gale_serpent`, `stone_warden`, `crag_pup`,
   `bounder` have no progress file and are the four worst models in the game.
   They come first, ahead of anything already at 34/50.
2. **Write the ANCHOR line for every beast.** Cheap, one sentence, and it is
   what every later judgement hangs off. Several will fail at this step, which
   is information, not failure.
3. **Fix gate failures before rubric points.** A beast at 0.92 solidity does not
   need its sigil nested; it needs a leg gap, a neck, and a tail that leaves the
   body.
4. **Break the twins.** Four models share one outline. Two of them should change
   anchor shape entirely — that is a rebuild, and rebuilds are Nick's call.
5. **Then, and only then, chase points.** Detail work on a model that passes the
   gates is worth doing. Detail work on one that fails them is what produced six
   beasts that each gained 3 points and still look like boxes.

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
