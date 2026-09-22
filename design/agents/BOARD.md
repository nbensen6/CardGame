---
tags:
  - agents
---

# Agent board

Three cloud agents work on the game at once. This folder is how they talk:
each keeps its own status note, and anything one needs from another is a
**request** note. Nick reads the same notes in Obsidian and can file requests
too.

## Current goal — perfect the Cinder Jackal fight

Everything below serves one fight until Nick says it is done: the jackal,
the two hunters in it (Frog, Goblin Engineer), its arena, and the cards those
hunters hold. The bar is Slay the Spire: every card play, jump and hit reads
clearly, nothing flickers, nothing floats, nothing is cut off.

## The three agents

| agent | owns | never does |
|---|---|---|
| [[status/artist\|artist]] | new and improved **assets**: the jackal model, hunter models, the arena, card art | gameplay code, bug fixes outside its assets |
| [[status/playtester\|playtester]] | **does it feel smooth**: card animations, jumps onto the beast, the jump animation, camera framing (third-person). Plays the fight with `tools/playtest.gd`, extends the playtester with new checks, files what it finds | fixing what it finds (it files a request) |
| [[status/fixer\|fixer]] | **bugs**: takes bug requests, fixes them with a regression test and a playtest run that proves it | new features, art |

## How to work together

1. **Start every run here.** Read this note, every `status/*.md`, and every
   request in `requests/` with `to:` your name and `status: open`.
2. **Requests addressed to you come before your own queue.** Take one by
   setting `status: taken` and `taken_by:` in its frontmatter, commit, then
   do it. When done: `status: done`, and a `## Result` section saying what
   changed, the commit, and how it was verified.
3. **Need something from another agent? File a request** — never do its job.
   New file `requests/YYYY-MM-DD-HHMM-<from>-to-<to>-<slug>.md` from
   [[requests/_template]]. One request per file (so two agents never edit
   the same file). Include a way to see the problem: a playtest command, a
   screenshot path, a step number.
4. **Update your status note** at the end of every run: what you did, what you
   are doing next, and anything blocked. Overwrite `## Now`; append one line to
   `## Log`, newest on top.
5. **Never edit another agent's status note.** Comment on its request instead.
6. **Push safely.** `git pull --rebase origin main` before every push; if the
   rebase conflicts on a design/agents file, keep both edits. Never force-push.

## Requests

![[Agents.base#Open requests]]

## Rules that bind all three

- **Proof or it did not happen.** Anything visible gets a rendered frame
  (`tools/playtest.gd`, `tools/screenshot.gd`, rendered under `xvfb-run` —
  see [[status/README]]), and anything logical gets a test in
  `game/tools/run_tests.gd`. `ALL TESTS PASSED` before every push.
- **Judgement calls are Nick's.** What a creature should look like, whether a
  change is more fun, art direction: file a request `to: nick` and move on.
- **Stay on the goal.** Work outside the jackal fight only if a request asks.
- **Money.** Meshy credits (artist only) are capped by `tools/meshy.py`
  (8 tasks/day). Never raise the cap.
- Everything in `CLAUDE.md` and the hard rules in `design/BACKLOG.md` still
  apply.
