---
tags:
  - home
---

# Titan-Slayers

Co-op deckbuilder where hunters climb giant Titans. This vault is the `design/` folder of the repo — every note here is a real design doc, so editing it here edits the project.

**One goal: the Cinder Jackal fight, to Slay the Spire quality.** The bar is [[JACKAL-BAR]]. The picture is yours:

![[art/references/2026-09-24-nick-target-composition.webp|400]]

## The builder

One agent builds. It takes the **top unticked line** of the queue below, shoots the named frame before and after, tests, pushes. It marks a line `[?]` when it wants you to look. **Only you tick `[x]`.** Reorder the list however you like; that is the whole steering wheel.

▶ **[Run the builder now](obsidian://shell-commands/?vault=design&execute=run-builder)** — runs hidden, 10–40 min, then this page updates. Same from the palette: *Execute: Run the builder*.

![[BUILDER-QUEUE#Now — the Cinder Jackal fight]]

### Last run

![[agents/status/builder#This run]]

Full note: [[agents/status/builder|builder]] · frames: `agents/frames/builder/` · defaults it takes when you say nothing: [[BUILDER-QUEUE#Open decisions, with the default the builder takes if Nick says nothing|open decisions]]

## Beasts

[[beasts/cinder_jackal|The Cinder Jackal]] is the template; the recipe is [[ai-beast-recipe]]. Rollout waits until the jackal fight is ticked. Every beast note has a ▶ Fight this now link.

![[Beasts.base#Art overhaul]]

## Where things are

| folder | what is in it |
|---|---|
| **plan** | [[BUILDER-QUEUE]] (live) · [[GDD]] · [[ROADMAP]] · [[OVERHAUL-PLAN]] · [[BACKLOG]] · [[titan-design]] · [[depth-plan]] |
| **agents** | `status/builder` (live) · `frames/builder` (live) · everything else is the 2026-09-22..25 cloud-agent era, archived: [[agents/BOARD|board]] · [[agents/Agents|requests]] · [[agents/HANDOFF-TO-FABLE|what went wrong]] |
| **guide** | [[asset-loop]] · [[ai-beast-recipe]] · [[blender-pipeline]] · [[blender-learning]] · [[audio-guide]] · [[3d-pivot]] · [[mobile-setup]] · [[climbing-and-characters]] |
| **art** | [[ART-REVIEW]] · [[art-target]] · [[card-face-vs-sts]] · [[icon-audit]] · palette and frame templates · `previews/` · `references/` |
| **notes** | [[feel-and-readability]] · [[tuning-knobs]] · [[balance-notes]] · [[cards-and-classes]] · [[sts2-comparison]] |
| **beasts** · **progress** · **renders** | one note per beast · per-asset work logs · raw render output |

> [!tip] How to steer
> - Move a line up in [[BUILDER-QUEUE]] and the next run does it. Delete a line and it never happens.
> - A `[?]` line is waiting on you. Look at the frames in **Last run**, then tick it or write what is wrong under it.
> - Claude reads and writes here too. Ask it to add to the queue rather than describing the work twice.
