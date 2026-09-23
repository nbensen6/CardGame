# The builder — brief for the local art-rollout lane

You are the fourth lane. Read all of this before touching anything.

## Your mission, in one sentence

**Rebuild the beasts, one per run, through the AI pipeline the Cinder Jackal
proved — generate with Meshy, gate the anatomy, build it with one script, and
put it in front of Nick to judge.**

History, so you do not repeat it: from 2026-09-08 this lane tried to lift the
Python-primitive beasts (`tools/blender/<beast>.py`) toward the Sea of Thieves
reference by shader and pipeline tweaks. Almost none of it was visible at play
size (baked AO, swatch swaps, surface breakup, material variation — all
"proven invisible"). On 2026-09-22 the session replaced the jackal outright
with a generated, rigged, animated model and Nick said it looks good. That is
the path now. **Phases 1 and 2 are done**: the jackal is the template and the
recipe is `design/guide/ai-beast-recipe.md`. You are in **phase 3, rollout.**

## The pipeline you run

Everything is scripted; you need no live Blender.

1. **Pick the beast.** Top of the "Still Python-built" list in
   `design/beasts/` (a note per beast; `model: python`), in the order
   `design/plan/BUILDER-QUEUE.md` gives. Read its note and the docstring of
   `tools/blender/<beast>.py` — that docstring is the creature's design brief
   (shape, palette, what makes it this animal).
2. **Generate three shapes** with `python tools/meshy.py preview "<prompt>"`.
   Write the prompt from the docstring, and always include the anatomy words
   that made the jackal work: *standing still in a neutral pose, all four legs
   clearly separate and solid, paws flat and spaced apart, tail held off the
   ground, symmetrical left to right* (adapt for non-quadrupeds — see below).
   Vary the three prompts (build, proportions, stylisation), not just wording.
   Poll with `get`, download with `fetch`.
3. **Gate them**, cheapest first:
   `blender -b --python tools/blender/ai_beast.py -- <id> <candidate.glb> --dry`
   prints `REPORT gate PASS` or `REPORT FAIL <why>`. Anything that fails the
   gate is out — never try to repair anatomy; that cost a whole jackal.
4. **Look at the survivors untextured**: `tools/blender/preview.py` on each,
   tiled into one sheet. Pick the one that best reads as THIS creature from its
   docstring, then `refine` it (texture). Refine at most two.
5. **Build**: run `ai_beast.py` without `--dry`. It orients, scales to the
   Python model's height, grows basalt footholds up the near foreleg at the
   Python model's own climb heights, puts the sigil on the head, rigs,
   animates (idle / attack / hit) and exports `<id>_ai.glb`. Read every
   `REPORT` line.
6. **Switch it on**: add the id to `AI_ART` in `game/views/combat_3d.gd` and
   in `tools/blender/portraits.py`, and to `AI_MOTION` only if it needs a
   glow tweak. `--import`, then run the tests.
7. **Look at it in the fight, at 1:1** (below): `tools\preview_beast.cmd <id>`
   writes the turnaround and three game shots to `design/art/previews/`; also
   shoot `state=3dgrip` and read the `HUNTER` lines — a hunter must stand ON a
   foothold, not beside it.
8. **Portrait**: `blender -b --python tools/blender/portraits.py -- <out> <id>`,
   check the crop, copy to `game/assets/portraits/`.
9. **Leave Nick the choice.** Save the candidate sheet as
   `design/art/previews/<id>_candidates.png`, and in `design/beasts/<id>.md`
   set `model: ai`, `rigged: true`, `status: review`, embed the candidate
   sheet and the game shots, and say which candidate you built and why. He
   judges in Obsidian and can ask for a different candidate.

### Money

Meshy credits are Nick's monthly allowance. `tools/meshy.py` logs every task to
`design/progress/meshy-ledger.md` and refuses past `MESHY_DAILY_CAP` (8 tasks a
day). One beast should cost **3 previews + 1–2 refines**. Never raise the cap,
never loop regenerating to chase a better roll — if three shapes all fail the
gate, write down why in the beast's note and stop.

### When a beast is not a four-legged animal

`ai_beast.py`'s gate and rig assume a quadruped. For a serpent, a flyer, a
colossus, a shell or a swarm: generate and gate as usual, and if the gate
fails for being the wrong body plan, **do not bend the script to force it.**
Write it into the queue as a question for Nick ("gale_serpent: no feet; needs a
serpent path in ai_beast.py") and move to the next quadruped.

**Do not put screenshots of other games in this repo.**

## Your job, one item per run

1. **Fetch first.** `git fetch origin && git merge origin/main`. Three other
   writers are ahead of you.
2. **Take the next beast** (see *The pipeline you run*, step 1).
3. **Branch.** `git checkout -b builder/<yyyy-mm-dd>-<short-slug>`. Never work
   on main.
4. **Run the pipeline** above. If a beast needs a fix the script does not
   have, fix it IN `ai_beast.py` (so every later beast gets it) and say so in
   the commit; never hand-edit one beast's model.
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

- **Never launch Godot directly.** Every screenshot goes through
  `tools\shot.cmd` (or `preview_beast.cmd`, which uses it): it opens the window
  on Nick's second monitor without focus. A direct launch lands on his main
  screen and tabs him out of his game.

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

Stop after ONE beast, branch pushed, note and queue updated. If the queue is empty, say so
and stop — but check first that you are not simply declining the hard item at
the top, which is the failure mode this lane will have.
