---
tags:
  - home
---

# Titan-Slayers

> [!todo] **[[Needs Nick]]** is the only page you have to read. Everything on it is a tick or a one-line answer.

**The goal:** the Cinder Jackal fight, to Slay the Spire quality. The bar is [[JACKAL-BAR]]. The picture is yours:

![[art/references/2026-09-24-nick-target-composition.webp|400]]

## How work happens

One builder. It takes the top open line of [[BUILDER-QUEUE]], builds it, shoots the named frame before and after, gets graded by a second model, and marks the line `[?]`. You tick it or send it back on [[Needs Nick]]. Only you tick.

- ▶ **[Run the builder once](obsidian://shell-commands/?vault=design&execute=run-builder)**
- ▶ **[Run until the queue is empty](obsidian://shell-commands/?vault=design&execute=run-builder-loop)** · [Stop after this run](obsidian://shell-commands/?vault=design&execute=stop-builder-loop)
- ▶ **[Send my answers](obsidian://shell-commands/?vault=design&execute=send-answers)** after ticking or typing on Needs Nick

## Last run

![[agents/status/builder#This run]]

## Where things are

| | |
|---|---|
| [[Needs Nick]] | what is waiting on you |
| [[BUILDER-QUEUE]] | the ordered work list; details fold under each line |
| [[BUILDER-PROPOSED]] | things the builder noticed and did not do; move a line into the queue to make it real |
| [[agents/status/builder\|builder]] | the builder's last run, in full |
| `agents/frames/builder/` | every before and after frame |
| [[JACKAL-BAR]] · [[GDD]] · [[ROADMAP]] · [[BACKLOG]] | what the game is and where it goes |
| [[ai-beast-recipe]] · [[asset-loop]] · [[blender-pipeline]] | how assets get made |
| `art/` · `beasts/` · `notes/` · `progress/` | references, one note per beast, thinking, work logs |
| `archive/` | the September cloud-agent era, kept, ignored by search |
