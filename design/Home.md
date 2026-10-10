---
tags:
  - home
---

# Titan-Slayers

> [!todo] **[[Needs Nick]]** is the only page you have to read. Everything on it is a tick or a one-line answer.

**The goal:** the Cinder Jackal fight, matching this picture 1:1. It is the only target:

![[art/targets/TARGET.png|400]]

The target beside the latest game shot (the builder refreshes this after every run it pushes):

![[agents/frames/builder/latest-square.png|800]]

## How work happens

One builder. It takes the top open line of [[BUILDER-QUEUE]], builds it, shoots the named frame before and after, gets graded by a second model, and marks the line with 👀. You tick it or send it back on [[Needs Nick]]. Only you tick. To ask for something new, fill a slot at the bottom of [[Needs Nick]]; it becomes a queue line by itself.

The builder runs **in the cloud**, once an hour, all day. When the queue is empty it does nothing, and [[Needs Nick]] shows a list of things it could build: tick one to start it again. Nothing on this PC moves; this PC pulls its pushes hourly, and again before every fight you launch from here. Pause or fire it from the desktop app's Routines panel ("Titan-Slayers — builder").

- ▶ **[Send my answers](obsidian://shell-commands/?vault=design&execute=send-answers)** after ticking or typing on Needs Nick, so the next cloud run sees them
- Local, only while the cloud routine is paused: [Run the builder once](obsidian://shell-commands/?vault=design&execute=run-builder) · [Run until the queue is empty](obsidian://shell-commands/?vault=design&execute=run-builder-loop) · [Stop after this run](obsidian://shell-commands/?vault=design&execute=stop-builder-loop)

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
