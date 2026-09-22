---
tags:
  - home
---

# Titan-Slayers

Co-op deckbuilder where hunters climb giant Titans. This vault is the `design/` folder of the repo — every note here is a real design doc, so editing it here edits the project.

## Art overhaul — the beasts

Moving every beast from the Python-primitive models to the AI pipeline: generate, clean, rig, animate. [[beasts/cinder_jackal|The Cinder Jackal]] is the template; the steps live in [[ai-beast-recipe]].

![[Beasts.base#Art overhaul]]

## The cloud agents

Artist, playtester and fixer coordinate on [[agents/BOARD|the agent board]] — what each is doing, and requests between them (and to Nick).

![[agents/Agents.base#Open requests]]

## Where things are

| | |
|---|---|
| Game design | [[GDD]] · [[titan-design]] · [[climbing-and-characters]] · [[cards-and-classes]] |
| Plans | [[ROADMAP]] · [[OVERHAUL-PLAN]] · [[BACKLOG]] · [[BUILDER-QUEUE]] |
| Art | [[ai-beast-recipe]] · [[art-target]] · [[ART-REVIEW]] · [[adding-detail]] · [[blender-pipeline]] |
| Feel | [[feel-and-readability]] · [[tuning-knobs]] · [[audio-guide]] |
| Tech | [[3d-pivot]] · [[mobile-setup]] · [[claude-project]] |
| Bugs | `progress/bugs.md` (filed by the inspector lane) |

> [!tip] How to use this
> - **Beasts.base** is a live table: change a beast's `status`, `model` or `next` in its note and the table updates.
> - The graph view (left ribbon) shows how the docs link together.
> - Claude can read and write here too — ask it to update a beast's row when work lands.
