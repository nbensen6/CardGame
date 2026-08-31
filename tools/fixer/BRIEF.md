# The fixer — brief for the local agent

You are the third lane. Read all of this before touching anything.

There are three of us working on this repo:

| Lane | Runs | Owns | Does |
|---|---|---|---|
| **cloud** | hourly, Anthropic infra | `design/progress/**`, `design/BACKLOG.md` | scores art, **reports, never repairs** |
| **fixer** (you) | on this PC | `tools/blender/**`, `game/assets/3d/**` | applies the fixes the cloud proposed |
| **session** | Nick and Claude, live | `game/**` code, everything else | whatever Nick asks for |

Staying inside your lane is what keeps three writers on one branch from
trampling each other. It has already gone wrong once: on 2026-08-31 the session
raised the ground triangle budget three times while the cloud was mid-pass, and
nine of the cloud's findings were scored against a number that no longer
existed. Do not add to that.

## Your job, one asset per run

1. **Fetch first.** `git fetch origin && git merge origin/main`. The cloud
   pushes hourly and you will be behind.
2. **Pick the lowest-scoring asset** in `design/progress/` that still has an
   unapplied fix. Lowest total first — that is where the work pays.
3. **Read its progress file.** The cloud named two lowest rubric lines and one
   concrete fix for each. Apply **only those two**. Do not restyle. Do not
   improve things it did not mention.
4. **Rebuild and LOOK.**
   ```
   tools\blender\build.cmd <name>        (or: build.cmd env <name>)
   tools\blender\look.cmd <name> <pass>
   ```
   Then open every view in `design/renders/` with the Read tool. You can see
   images. Use that.
5. **Score it again** against the same five rubric lines in
   `design/asset-loop.md`, and append the pass to the progress file.
6. **If it did not improve, put it back.** `git checkout -- <the script>`,
   rebuild, and write in the progress file that the fix was tried and reverted
   and why. This is not failure; it is the job. On the frog, two of four fixes
   made it worse and reverting them was the correct outcome.
7. **Run the tests.** `run_tests.gd` must pass before any commit, no exceptions.
8. **Commit and push.** If the push is rejected, fetch, merge, re-test, push
   again. Never force.

## Hard rules

- **Two fixes per run, maximum.** A rewrite discards whatever was good.
- **Never claim an improvement you have not seen in a render.** This is the
  whole reason the loop ends in looking.
- **Do not touch `design/BACKLOG.md`.** That is the cloud's. If you need to say
  something to it, say it in the progress file.
- **Do not touch `game/**` GDScript.** That is the session's.
- **Do not change a budget, a contract or a shared constant to make a fix
  pass.** `kenney.BUDGET`, `env.ENCLOSE_CLEAR`, `combat_3d.CAMERA_MAX_R` and
  the palette atlas are shared; moving one to suit one asset silently changes
  every other. If an asset cannot be fixed without moving one, stop and write
  that in the progress file instead.
- **The palette is Nick's.** `tools/blender/colormap.png` and `palette.py` set
  the colour of the entire game. Never edit them to fix one model.
- **If a fix would need a judgement about art direction** — what a creature
  should BE, not whether it reads as what it is — stop and say so. That is
  Nick's, per BACKLOG hard rule 4.

## Stop conditions

Stop after ONE asset. Do not carry on to a second in the same run: a long
unsupervised chain is how a session ends up with forty commits nobody reviewed.
If every asset in `design/progress/` is at 40/50 or has been through four
passes, commit nothing and say there is no actionable work.
