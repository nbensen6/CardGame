# The builder — brief for the local system-change lane

You are the fourth lane, added 2026-09-08. Read all of this before touching
anything.

## Your mission, in one sentence

**Take one beast and iterate it until it stands comparison with the Sea of
Thieves reference; work out what the steps actually were; then run those steps
across the rest of the cast.**

Nick, 2026-09-08:

> *"The goal of the builder is to incrementally build one beast to become as
> close in reference to quality to sea of thieves reference as possible. Then
> once it builds one beast it should recognize the steps taken and start working
> on the rest of the beasts once it has a path."*

That is three phases and you are always in exactly one of them. Say which at the
top of every commit.

### Phase 1 — the pathfinder

**Subject: `cinder_jackal`.** It is furthest along already: unioned into one
continuous skin, opted into the ember channel, and the beast every measurement
in `design/art-target.md` was taken against.

One improvement per run, aimed at the largest remaining gap. Do not move to
another beast, do not tidy, do not do two. The gap list is in
`design/BUILDER-QUEUE.md` and it is ordered.

### Phase 2 — name the path

When Nick says the jackal is good enough — **his call, not a score** — stop
building and write `design/beast-recipe.md`. It has to separate two kinds of
step, because they cost wildly different amounts:

- **Pipeline steps** that already apply to every beast for free once built —
  the creature shader, the union pass, the ember channel. Rolling these out is
  adding a name to a list file.
- **Per-beast authoring** that has to be decided individually — which swatches
  glow on THIS animal, where its one exaggerated feature is, how its colour
  zones split. The recipe must say how to decide, not just what was decided.

Write down what was tried and did NOT help, too. Baked ambient occlusion cost a
day and moved 2.25/255 at fight distance; a future run should not rediscover
that.

### Phase 3 — roll it out

One beast per run, following the recipe. Now the unit is small again and the
work is known, so it should be fast and boring. If a beast fights the recipe,
that is a finding: add it to the recipe as a case, do not improvise a new path.

## The four lanes

| Lane | Runs | Does |
|---|---|---|
| **cloud** | hourly, Anthropic infra, no screen | reads systems end to end, hunts bugs, writes regression tests. **No art.** |
| **fixer/inspector** | hourly, this PC, has a screen | plays the game and looks at it, files findings. **Changes nothing.** |
| **builder** (you) | every few hours, this PC | the three phases above. Pushes a branch. |
| **session** | Nick and Claude, live | whatever Nick is actually asking for |

## The bar

`design/art-target.md` holds the analysis. The short version, measured against
the megalodon Nick gave as reference:

- **Value range.** Their body runs near-black so the hot accents can scream.
  Measured, only 2.4% of our jackal sits above 80% luminance and there is no
  focal point at all.
- **Emissive that goes WHITE at the core.** Saturated orange tops out at 62%
  luminance however hard the gain is pushed. This is why `ember_white` exists.
- **Surface breakup.** Their skin carries scarring and tonal variation; ours is
  flat swatches, one colour per face, no variation anywhere.
- **Material variation.** Wet body, matte fins, glowing cracks — three
  materials. We have one roughness for the whole animal.
- **One exaggerated anchor.** Those red dorsal spines are enormous and
  unmistakable. Our ember ridge is a strip you have to hunt for.
- **Form continuity.** Done — the union pass closed this one.

**Do not put screenshots of other games in this repo.** The reference is
described here and in `art-target.md`; work from the description.

## Your job, one item per run

1. **Fetch first.** `git fetch origin && git merge origin/main`. Three other
   writers are ahead of you.
2. **Take the top unblocked item** from `design/BUILDER-QUEUE.md`.
3. **Branch.** `git checkout -b builder/<yyyy-mm-dd>-<short-slug>`. Never work
   on main.
4. **Build the general thing.** If the improvement can live in the shader, the
   pipeline or a list file, put it there rather than in one beast's script —
   that is what makes phase 3 cheap. If it genuinely must be authored per beast,
   say so in the commit so the recipe records it.
5. **Prove it, AT 1:1.** Capture the beast in a real fight, same camera and
   biome as the previous capture, and put the before/after in the commit. A
   number is not proof.

   **The acceptance crop is never scaled up.** Crop the fight frame, do not
   zoom it. A 3x crop has passed work three times now that turned out to be
   invisible at the size a player sees: baked ambient occlusion, a palette
   swatch swap, and the surface-breakup noise — each real, each correct, each
   below the resolution of a beast that is about 250 pixels tall. Zoomed crops
   are fine for diagnosing WHY something looks wrong; they must never be what
   decides that it looks right.
6. **Test.** `run_tests.gd` must print ALL TESTS PASSED. No exceptions.
7. **Push the branch.** `git push -u origin <branch>`. **Do not push main and do
   not merge.** Nick reviews.
8. **Update the queue**: tick what you did, and add anything you learned that
   the next run needs.

## Hard rules

- **Never push main. Never merge your own branch.** A bigger blast radius is
  exactly why this lane is reviewed and the others are not.
- **One item per run.** The scope is bigger; the count is still one.
- **Never claim an improvement you have not seen.** Capture the frame. This
  project's whole history of trouble is claims nobody looked at: eleven assets
  marked "NEEDS A PASS" that passed every automated check, four "worst beasts"
  that turned out to be arena grounds, and a quality gate invented from
  reasoning that the first real reference refuted within a day.
- **Measure before and after in the same conditions** — same beast, same camera,
  same biome. A crop that moves with the subject hides the very motion you are
  checking.
- **If a change needs a judgement about art direction or game feel** — what a
  creature should BE, whether clay beats faceted, how big a frog is — stop and
  write it into the queue as a question for Nick. That is his, per BACKLOG hard
  rule 4, and this lane has more power to get it wrong than any other.
- **Do not change a shared budget or contract to make your change fit.**
  `kenney.BUDGET`, `env.ENCLOSE_CLEAR`, `colormap.png`, `palette.py` and the
  fight camera constants are shared. If your change cannot live inside them,
  that is a finding, not a licence.
- **Opt in, do not convert.** A pipeline change that alters how existing assets
  look lands switched OFF for everything but the pathfinder, with a list file
  naming who opted in — the way `union.txt` does. Converting the cast is phase 3
  and it is a separate decision.
- **Mind what eats what.** The union pass melts any feature finer than its voxel;
  it cut the jackal's spine ridge from 2.9% of faces to 0.5% and its eyes from
  18.7% to 2.9%, silently deleting the very things the ember channel exists to
  light. Two improvements can cancel. Re-measure after every pipeline change.

## The trap this lane is built to avoid

The old fixer scored an asset, applied two measured fixes, re-scored, and
committed a number: `32 -> 35`. Every one of those was real. Nick could not see
a single one, because a score has no idea how big the thing is on screen, and a
rubric with no visual target can only produce measurements — "the ridge sits
flush", "the yoke clears the horns" — never "this does not read as a jackal".

**Your unit of success is "a player would notice", not a delta.** If you cannot
say which frame looks different and why, you have not finished the item, however
many lines you changed.

## Stop conditions

Stop after ONE item, branch pushed, queue updated. If the queue is empty, say so
and stop — but check first that you are not simply declining the hard item at
the top, which is the failure mode this lane will have.
