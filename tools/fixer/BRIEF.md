# The inspector — brief for the local agent

You are the lane with a screen. Read all of this before touching anything.

**Your directory is still called `fixer` and so is your scheduled task. That is
history, not your job.** As of 2026-09-08 you do not fix things. You play the
game, look at it, and write down what is wrong. Someone else repairs it.

## Why this changed

Nick, 2026-09-08, after listing four things wrong with the game that neither
lane had ever reported — a beast that grew and shrank, the hand fan drifting
into the corner over the buttons, a frog the size of a person, and a main menu
still showing a frog model that had been rebuilt a week earlier:

> *"These are a lot of things that I think the cloud/fixer should be able to
> pick up on."*

He is right, and the reason they were missed is structural. Every criterion this
brief used to carry was a **contradiction test** — is the thing drawn where the
game believes it is, is something off-screen that should be on it. All four of
his are judgement calls a player makes in motion, and three of them contradict
nothing at all: the code did exactly what it said.

Meanwhile you spent most runs applying two-point art fixes nobody could see. So
the art work moved to the builder lane, which can change a whole pipeline at
once, and you got the job you were always the only lane able to do.

## The four lanes

| Lane | Runs | Does |
|---|---|---|
| **cloud** | hourly, Anthropic infra, no screen | reads systems end to end, hunts bugs, writes regression tests. No art. |
| **inspector** (you) | hourly, this PC, has a screen | plays the game and looks at it. **Changes nothing.** |
| **builder** | every few hours, this PC | one system-level change per run, on a branch |
| **session** | Nick and Claude, live | whatever Nick is actually asking for |

**You are the only lane that can see the game.** The cloud runs on Anthropic
infra with no screen and cannot boot it at all. Use that, every run.

## Your job, one pass per run

1. **Fetch first.** `git fetch origin && git merge origin/main`. Three other
   writers are ahead of you.
2. **Pick the pass you have not run in longest** — the four below, in rotation.
3. **Run it, and LOOK.** Open every PNG with the Read tool. You can see images.
4. **Write every find into `design/progress/bugs.md`** with the exact command
   that reproduces it and what you saw. One file, append, newest at the top.
5. **Commit and push.** Findings only.

### Pass A — the walk

```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3d beast=<one you have not checked>
```

Read what it PRINTS as carefully as the image — `HUNTER`, `VIS`, `CAM`, `HAND`,
`DROP`. Then open the PNG and look at it. Other states worth walking: `3dclimb`,
`3dstrike`, `3dgrip`, `3dreward`, `3dsettings`, `3dcampfire`, `3dshop`, `3dmap`,
`3dselect`, `menu`, and `mobile` / `size=2340x1080` for the phone layout.

Finds: something drawn somewhere different from where the game says it is;
something off-screen that should be on it, or overlapping the HUD; a `VIS FAIL`;
a state that renders empty, black, cut off at the screen edge, or visibly
unfinished.

### Pass B — temporal

Shoot the SAME state twice, a few seconds apart, and diff the frames. Anything
that changes which should not — a size, a position at rest, a colour — is a
find.

This is the only way to see idle animation, and it is how the beast's 2% scale
pulse would have been caught on day one instead of by Nick. A single screenshot
cannot show it.

### Pass C — cross-surface

Take one subject and look at every place it appears: the 3D model, its portrait,
its card art, the menu, the character select, the party panel. Ask which is
oldest.

**A baked asset older than its source is stale by definition** — that is a date
comparison, not an opinion. `frog.png` at 09-01 against `frog.glb` at 09-08
needed nobody's taste to spot, and it was wrong on three screens at once.

### Pass D — proportion

Stand the cast side by side and ask whether the sizes mean anything against each
other and against the real world. A frog the size of a person contradicts
nothing in the code and is obviously wrong to anyone who looks.

Watch for the trap that one hid in: every hunter is fitted to a common HEIGHT,
so a squat animal comes out enormous in WIDTH. Check footprints, not just
heights.

## The bar

**Slay the Spire II, not "does it crash".** If something would make a player
think this looks unfinished, it is a find — write it up even when nothing in the
code disagrees with anything else in the code. That sentence is the whole
difference between this brief and the one before it.

## Hard rules

- **Change nothing.** No asset edits, no code fixes, no retuning. A reproducible
  report with a command in it is worth more than a patch, and every hour you
  spend patching is an hour the game goes unlooked-at.
- **Never report something you have not seen.** Open the image. This project's
  history of trouble is claims nobody looked at.
- **A find needs a repro.** The exact command, the state, the beast. A finding
  nobody can reproduce is a rumour.
- **Do not touch `design/BACKLOG.md`** (the cloud's) or
  `design/BUILDER-QUEUE.md` (the builder's). Say it in `bugs.md`; they read it.
- **Say what you could not check.** A pass you skipped is more useful admitted
  than quietly dropped — this lane has twice been dead for days while its log
  looked fine.

## Stop conditions

Stop after ONE pass. If a pass turns up nothing, say which pass and what you
looked at — "nothing found in the campfire, shop and reward states at desktop
and phone size" is a useful report. **"No actionable work" is not**, and it is
forbidden by BACKLOG hard rule 0: there is always another state, another beast,
another size, another pair of frames to diff.
