---
tags:
  - agents
issue: 9
---

# Task board

_Generated from the agents' own status notes and the open requests. Do not edit -- the next sync overwrites it._

## artist — RUNNING NOW

**Last run:** 2026-09-24 15:17 ET

- **Did:** the fixer closed the intent-tag-vs-hunter residual that was blocking my own last unticked Motion line ("the jump reads") — re-verified it live myself instead of trusting the write-up, then ticked the line.
- **Next:** still waiting on Nick's pick on the art-style request — nothing else on my brief is open or unblocked right now.
- **Needs Nick:** your pick on `2026-09-24-1147-nick-to-artist-find-an-art-style-worth-copying.md`.

| ticket | priority | eta | state | |
|---|---|---|---|---|
| #8 | high | not estimated | taken | Research art styles and bring me ones we could actually use |

## playtester 

**Last run:** 2026-09-24 15:19 EDT

- **Did:** no requests addressed to `playtester` were open this run. Since my last run, the fixer landed the fix for the last thing I had filed (`1002`, the intent-tag-vs-hunter residual at ground-hop start — commit `d443ccd`). Ran the full three-mode baseline fresh against it first, then spent the rest of the run confirming that fix live and, since it closed the last thing blocking JACKAL-BAR's "The jump reads" line, gave that line the fresh eyes-on pass it asks for and ticked it.
- **Next:** watch for the fixer picking up stone-route item 2 (`hop-distance-band`, the only other open item, confirmed a genuine geometric ceiling several runs ago — needs re-authoring the Python reference model or a joint placement rule, not another retry). Also watch for the fixer picking up the "stones IN FRONT of the jackal" / "space between the hunter and the skin" requirement Nick added to the same stone-route build request (`2026-09-23-1846-...`) on 2026-09-24 11:52 ET — still `status: taken`, no movement on that half as of this run's read of it. Once it lands, re-check the sigil-cheek note (`2026-09-24-0322-...`) and close it.

_No open ticket._

## fixer 

**Last run:** 2026-09-24 14:42 EDT

- **Did:** fixed the real, small case the playtester's own margin-guarded check kept finding after my last hunter-clamp fix: at the very start of a ground-level hop, the intent tag's left edge grazed the hunter's own on-screen body for exactly one sampled frame in every full run.
- **Next:** nothing of mine left on this one. Order-of-work for a future run: the stone-route hop-distance item (still `taken`, one real lever left after five ruled-out dead ends) or a fresh read of the fight's code paths if no request is open.

| ticket | priority | eta | state | |
|---|---|---|---|---|
| #3 | high | not estimated | taken | Stones, camera and hunter spacing at the Cinder Jackal |
| #4 | high | not estimated | taken | Build the one-directional stone route: fix the raycast, not just the sigil |

## waiting on Nick

- **#5** At the sigil, the hunter reads as glued to the jackal's cheek, not standing on it

