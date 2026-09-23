---
tags:
  - home
---

# Titan-Slayers

Co-op deckbuilder where hunters climb giant Titans. This vault is the `design/` folder of the repo — every note here is a real design doc, so editing it here edits the project.

## Art overhaul — the beasts

Moving every beast from the Python-primitive models to the AI pipeline: generate, clean, rig, animate. [[beasts/cinder_jackal|The Cinder Jackal]] is the template; the steps live in [[ai-beast-recipe]].

![[Beasts.base#Art overhaul]]

## Start here

- **Every beast note has a ▶ Fight this now link** — click it and the game opens
  solo, Frog and Goblin, straight into that fight. It runs through the Shell
  commands plugin, one command (`play.cmd {{title}}`) shared by every beast, so
  a new beast note works with no setup. Same thing from the keyboard: command
  palette → *Execute: Fight this beast*.
- **[[agents/Agents|Agents]] → the FOR NICK tab** — everything waiting on your
  decision, one plain sentence each. Answer under **Nick's answer** in the note.
- **[[agents/Last sync|Last sync]]** — when this PC last pulled the agents'
  work, and what came in. It syncs hourly on its own; **Sync the agents** on
  the desktop does it now.

## The cloud agents

Artist, playtester and fixer coordinate on [[agents/BOARD|the agent board]] — what each is doing, and requests between them (and to Nick).

Each one opens its status note with **This run**: what it did, whether it
worked, what is next, and what it needs from you. The three latest, live:

![[agents/status/artist#This run]]

![[agents/status/playtester#This run]]

![[agents/status/fixer#This run]]

![[agents/Agents.base#Open requests]]

## Where things are

Six folders, and nothing loose. Links work by name, so `[[BACKLOG]]` still
finds it wherever it lives.

| folder | what is in it |
|---|---|
| **agents** | the board, the three agents' status notes, requests, frames |
| **plan** | where the game is going — [[GDD]] · [[ROADMAP]] · [[OVERHAUL-PLAN]] · [[BACKLOG]] · [[BUILDER-QUEUE]] · [[titan-design]] · [[depth-plan]] |
| **guide** | how things get made — [[asset-loop]] · [[ai-beast-recipe]] · [[blender-pipeline]] · [[blender-learning]] · [[audio-guide]] · [[3d-pivot]] · [[mobile-setup]] · [[climbing-and-characters]] |
| **art** | how it should look — [[ART-REVIEW]] · [[art-target]] · [[card-face-vs-sts]] · [[icon-audit]] · the palette and frame templates, plus `previews/` and `references/` |
| **notes** | thinking out loud — [[feel-and-readability]] · [[tuning-knobs]] · [[balance-notes]] · [[cards-and-classes]] · [[sts2-comparison]] |
| **beasts** · **progress** · **renders** | one note per beast · per-asset work logs · raw render output |

> [!tip] How to use this
> - **Beasts.base** is a live table: change a beast's `status`, `model` or `next` in its note and the table updates.
> - The graph view (left ribbon) shows how the docs link together.
> - Claude can read and write here too — ask it to update a beast's row when work lands.
