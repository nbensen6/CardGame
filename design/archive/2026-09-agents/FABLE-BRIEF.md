---
tags:
  - agents
---

# Brief for Fable: how should we be directing these agents?

Copy everything below the line into Fable. It is written to be read cold, with
no other context.

---

## The ask

I run three autonomous cloud agents on a game project. They work, they ship,
they push to main — but the *direction* is going wrong in specific, repeating
ways. **I want a plan for how to direct them better.** Not a rewrite of the
setup: a plan for the briefs, the ticket flow, and the rules of engagement, so
the work they do is the work that matters.

Read the whole brief before answering. End with a concrete plan I can apply.

## The project

**Titan-Slayers** — a co-op roguelike deckbuilder in Godot 4.7 / GDScript.
Two small hunters (a Frog and a Goblin Engineer) climb a huge beast and hit its
weak point. Think Slay the Spire's card legibility, Shadow of the Colossus's
premise. Repo `nbensen6/CardGame`, private, single developer (Nick, not a
programmer by trade — he directs, judges feel, and plays).

**Current focus, and it has not changed for days:** one fight, the Cinder
Jackal, brought to Slay the Spire quality before anything else gets attention.
The written definition of done is `design/agents/JACKAL-BAR.md`.

## The three agents

Each is a scheduled Claude Code cloud session. Fresh Ubuntu sandbox per run,
clones the repo, does work, pushes to `main`, exits.

| agent | cadence | owns |
|---|---|---|
| artist | hourly | how it LOOKS: models, textures, shaders, the arena |
| playtester | every 2h | how it FEELS: plays the fight, judges, files findings — never fixes |
| fixer | every 3h | what is BROKEN: bugs, with a regression test and a playtest that proves it |

They share `tools/agents/COMMON.md` and each has its own brief
(`tools/agents/<agent>.md`). They coordinate through markdown notes in
`design/agents/`: a status note each, and one file per request.

**Hard constraints on what an agent can do** (all discovered by probing, not
assumed):

- It can run Godot headless, render the real game under `xvfb-run`, run
  Blender, and call the Meshy 3D-generation API.
- It **cannot write to any external system** — creating a GitHub issue is
  refused by the sandbox policy as "[External System Writes]".
- It **cannot use GraphQL**, so `gh issue ...` and GitHub Projects are out.
  Only `gh api repos/...` REST reads work.
- Therefore: **agents write markdown, full stop.** Everything outward-facing
  (GitHub Issues, the Projects board, the mirror of Nick's replies) runs on
  Nick's PC on a half-hourly sync.

**A lease file stops two runs of the same agent overlapping** — one claims,
works, releases; a stale lease expires after 40 minutes. This exists because
two artist runs once collided and the second spent its whole run merging.

## How work reaches them

1. Nick writes a request note (or an agent files one to another agent).
2. The half-hourly sync on his PC mirrors every open request to a GitHub
   issue — its number becomes the ticket number — sets labels, assigns the
   ones addressed to him, and puts a card on a Projects board with columns
   Waiting on Nick / Todo / In Progress / Done.
3. Nick can answer from his phone by commenting on the issue; the sync copies
   the comment back into the note under `## Nick's answer`.
4. Agents read only the markdown. An answered request is top of their queue.

## What is going wrong — the actual symptoms

These are observed, with examples. This is the material for your plan.

1. **Requirements land where the wrong agent will read them.** Nick said
   "the stones should be IN FRONT of the beast". It went into a note addressed
   `to: nick`, so the fixer — the one building it — had no reason to open it.
   It sat unbuilt for six hours while everyone believed it was tracked.

2. **Agents do the structurally correct thing and call it done.** Asked to fix
   a climbing route that doubled back, the fixer fixed the *generator* so no
   future beast can produce a bad route. Genuinely the right fix. It moved
   exactly one hold. Nick looked at the game and saw no change at all, because
   the visible half was never scoped as a deliverable.

3. **They pick the easy open ticket over the important one.** The stones
   ticket sat `taken` for a day while the fixer finished a damage-popup clamp,
   a slider label, and an intent-tag sliver — each real, each verified, none of
   them the thing Nick was waiting to see.

4. **"Nothing open" runs.** An agent reported no actionable work while a
   high-priority ticket addressed to it was open, because it had handed a
   request back to Nick and then treated the whole queue as blocked.

5. **They write too much.** One "what I did this run" bullet was 470
   characters. Nick reads these to decide what to chase; a wall of text is the
   same as no report. He has said "the agents are writing too much" in those
   words.

6. **Taste changes ship before Nick sees them.** An art style was chosen and
   applied to every model in one run. Nick's reaction: "I actually really
   didn't like the art change." The work was competent and the direction was
   his own pick — but it went from decision to shipped with no look in between.

7. **Nobody owns the composite.** The artist judges a model in its own scoring
   camera; the playtester judges motion; the fixer judges correctness. The
   thing Nick actually looks at — the whole frame, at play size, with the HUD
   over it — was nobody's, so it drifted badly while every individual score
   went up.

## What already works, and should not be thrown away

- **Evidence discipline.** They render the real game, look at the frames, and
  attach before/after. Claims are usually backed.
- **Root-cause instinct.** They fix the generator, not the symptom, and they
  find second instances of a bug nobody reported.
- **Honest reporting.** They say when something failed, when they could not
  reproduce, and when their own previous guess was wrong.
- **The lease, the tests, and the playtest harness.** `ALL TESTS PASSED` plus a
  scripted playthrough before every push.

## Nick's standing rules

- Never open the game or Blender on his main screen; render off-screen.
- Concise, bulleted reports. What happened, what is next.
- No bought asset packs — everything generated or built here.
- He steers direction and judges feel; he does not want to be asked about
  every small call, but he must see anything that changes how the game looks
  before it becomes the default.
- Do not tune balance; the game is not ready for win-rate work.

## Open tickets right now

- **#3, #4** (fixer, high) — stone placement, camera, hunter spacing; the
  camera half just landed, the stone path has not.
- **#5** (Nick) — a hunter reads as glued to the beast's cheek; tracking, will
  close when the route lands.
- **#11** (Nick) — his own reference drawing of the target composition:
  hunters well back, stones a visible staircase in the air, whole beast in
  frame. Half done.
- **#13** (artist, high) — the hunters are photoreal 2MB models rendered at 40
  pixels; they need to be simpler, not more detailed.

## What I want from you

A plan, specific enough to apply this week, covering at least:

1. **Routing** — how a requirement reaches the agent that will act on it, and
   how we stop "it is tracked" from meaning "nobody is building it".
2. **Scoping a deliverable** so "correct but invisible" cannot be the whole of
   a run's output when the ticket was about something visible.
3. **Priority** — how the agents choose between an open ticket and their own
   found work, and how Nick's "this is the one I am waiting on" outranks both.
4. **Reporting** — what a run must say, in how few words, for Nick to decide
   in ten seconds whether to look.
5. **The taste gate** — where a human look is mandatory before something
   becomes the default, without stalling the agents in between.
6. **Ownership of the composite** — who is accountable for the whole frame at
   play size, and how that is checked every run rather than per-asset.

Where you would change the briefs (`COMMON.md` and the three agent files),
quote the rule you would write. Be concrete; these are the actual instructions
the agents follow.
