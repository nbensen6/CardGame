---
tags:
  - agents
---

# Handoff to Fable — Titan-Slayers

Paste everything below the line. Written to be read cold.

---

## The goal

**Titan-Slayers** is a co-op roguelike deckbuilder in Godot 4.7 / GDScript
(repo `nbensen6/CardGame`). Two small hunters — a Frog and a Goblin Engineer —
climb a huge beast on floating stones and hit its weak point. Nick is the sole
developer. He directs and judges; he is not a programmer by trade.

**One goal, unchanged for days: get the Cinder Jackal fight to Slay the Spire
quality before anything else.** The written bar is
`design/agents/JACKAL-BAR.md`. The visual target is Nick's own drawing,
`design/art/references/2026-09-24-nick-target-composition.webp` — hunter close
to camera in the foreground, beast far away and whole, a staircase of pale
stones climbing the gap between them, dark ground, cool sky.

**Four things he has asked for repeatedly and still does not have:**

1. A camera locked third-person close behind the hunter, in every build.
2. Stones that read as a path in front of the beast, not rocks beside it.
3. Hunters that look good at ~40 screen pixels.
4. A player-mode / dev-mode toggle he can flip while playing.

(3) and (4) are untouched. (1) and (2) were rebuilt by Claude directly on
2026-09-25 — the gap, the stone staircase and a grounded camera that no longer
resizes itself to fit the beast — and he has not yet judged the result.

## What exists

**The game.** Godot 4.7, gl_compatibility. `tools/dev.cmd` runs it,
`tools/shot.cmd` renders a state off-screen, `tools/playtest.cmd` plays the
fight through real input with invariants. `game/tools/run_tests.gd` is a large
unit suite; `ALL TESTS PASSED` is the gate before any push. Assets are
generated (Meshy, ~2,890 credits left) and cleaned in headless Blender.

**Four cloud agents, now all disabled**: artist (assets), playtester (plays and
files, never fixes), fixer (bugs, with a regression test), director (reviews
the others, builds nothing — this one ran on Fable). Briefs in
`tools/agents/`. They coordinate through markdown notes in `design/agents/`,
because they physically cannot do anything else: every external write is
refused by the sandbox policy, and GraphQL is blocked, so no GitHub issue or
project write from an agent. All outward-facing plumbing runs on Nick's PC.

**The board.** `tools/board_sync.py` mirrors each request note to a GitHub
issue and copies his comments back into the note; `tools/board_project.py`
drives a Projects board (Waiting on Nick / Todo / In Progress / Done);
`tools/board_status.py` generates a task board. A scheduled task runs all of
it at :25 and :55. `tools/board_link.py` is a localhost redirector so a GitHub
issue can carry a working "Fight this now" button.

## What actually happened, honestly

Roughly forty agent runs over two days. What they produced:

**Genuinely good, and worth keeping:**

- **Measurement over assertion.** They render the real game, read the frames,
  and attach before/after. When the fixer said moving the hunters back could
  not open the gap, it had pushed the hunter from z=26 to z=544 and projected
  the result to screen pixels at every step. That finding was correct and it
  is what unlocked the fix.
- **Root cause, not symptom.** Told to fix one beast's climb reversal, the
  fixer fixed the generator and found a second beast nobody had reported.
- **Honest reporting.** They say when something failed, when they could not
  reproduce, and when their own last guess was wrong.
- **The director's diagnosis was the best writing of the two days.** It caught
  a playtest check that enshrined a camera the fixer had removed thirty
  minutes earlier — a conflict that would have made the camera oscillate
  forever, and which nobody else was positioned to see.

**Where it went wrong, and this is the part to solve:**

1. **They chose their own work, and chose badly.** The stones ticket sat
   `taken` for a day while the fixer shipped a damage-popup clamp, a slider
   label and an intent-tag sliver — each real, each verified, none of them the
   thing Nick was waiting on. One thing per run plus self-selected work means
   the important item never surfaces.
2. **"Correct but invisible."** The route-reversal fix was the right fix and
   moved exactly one hold. Nick looked at the game and saw no change at all.
   Nobody had scoped what the *visible* half of the ticket was.
3. **Investigation as a substitute for shipping.** Two consecutive fixer runs
   on the stones ended in findings, reverts, and "not done". Real findings —
   but the composition did not move until Claude made the change directly.
4. **Nobody owned the composite.** The artist judged models in its own scoring
   camera, the playtester judged motion, the fixer judged correctness. The
   thing Nick actually looks at — the whole frame, at play size, with the HUD
   over it — was nobody's, and it drifted badly while every individual score
   rose. The director was created to fix exactly this and it helped, but only
   after a day of drift.
5. **"Done" meant the agent's opinion.** #13 was closed while Nick thought the
   characters looked terrible. The rule said "if you finished, set done"; the
   instruction to hand it back was prose in a ticket body, and a rule beats
   prose.
6. **Process outgrew the work.** By the end there were four briefs, a lease
   file, a request template, a GitHub mirror, a Projects board, a task board,
   sub-issues, a localhost redirector and an answer-detection rule. Much of it
   was built to compensate for the previous item. The ratio of coordination to
   game improvement got worse through the day, not better.

## Where I think this can improve

Said plainly, as the person who built most of the above:

- **Fewer agents, not more.** The bottleneck was never capacity. Three
  builders produced more coordination surface than output. One builder and one
  reviewer would have shipped more.
- **Agents should not self-select work.** Ever. One ordered queue that Nick
  controls, top item only. Everything an agent "finds" becomes a proposal at
  the bottom of that queue, not work it starts.
- **Every run opens and closes with the same screenshot compared against his
  reference.** If that image did not change, the run did not succeed, whatever
  else it proved.
- **A ticket is not done until Nick has looked.** No agent may close anything
  whose success is a judgement. This is now written down; it was learned the
  hard way twice.
- **Scope the visible half explicitly.** For anything about how the game
  looks, the ticket should name the screenshot that must change.
- **Be suspicious of new process.** Several hours went into board plumbing
  that made the workflow legible without making the game better. If a rule is
  being added to stop a failure that happened once, prefer fixing the run
  order instead.

## Where the game actually stands

- Camera: grounded shot is now a fixed 9-unit third-person stand-off behind
  the active hunter; it no longer resizes to fit the beast. Free camera is
  still enabled in debug builds, which is why Nick still sees free-cam when he
  plays through `dev.cmd`. **The toggle he asked for does not exist.**
- Stones: a straight, evenly spaced route from in front of the hunters to the
  top hold. Heights 1.1 → 3.1 → 6.3 → 10.6 → 15.1, receding 81 → 0.5.
- Hunters: rebuilt as ~260/310-triangle flat-vertex-colour models. The Frog
  reads; the Goblin is still noise at fight size.
- Art style: "style C" — hard lit/shadow band, low-poly, distance fog, dark
  ground, cool sky. Nick picked it; he has not accepted the result.
- Playtest: `hop-distance-band` and `hunter-off-marker` still fail. Both
  measure the beast's authored anchors rather than the new route, so they are
  measuring a design that no longer exists and must be re-derived.

## Open decisions waiting on Nick

#14 how many stones · #19 gap versus lens · #23 boulder shape · #27 the
weak-point shot. (#13, the hunters, he answered "looks good" for the Frog.)

## What to do with this

He wants a plan for how to run this better — not a defence of what exists.
Assume everything above can be thrown away, including the four agents and most
of the board plumbing, if something simpler gets the fight finished faster.
