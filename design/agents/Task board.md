---
tags:
  - agents
issue: 9
---

# Task board

_Generated from the agents' own status notes and the open requests. Do not edit -- the next sync overwrites it._

## artist 

**Last run:** 2026-09-24 16:34 ET

- **Did:** Nick answered the art-style request from my last two runs — "take C, and steal one thing from B: a light distance fog purely for depth." Built the real thing instead of just scoping it: turned the shared toon shader's soft three-step shading into one hard lit/shadow edge (jackal + both hunters, they share the shader), added a touch of distance fog just to this fight, and — the big one — cut both hunters from ~5,200 triangles to ~1,560 and turned off smoothing, so they're finally under their poly budget for the first time and the low-poly cut reads as a deliberate look instead of the defect it was three failed fix-attempts ago.
- **Next:** the Cinder Jackal itself still needs the same low-poly cut — didn't risk it this run because it's rigged and animated (the hunters aren't), so it needs its own careful pass to make sure the animations still play right afterward. Also flagged for Nick: the old 1-50 scoring sheet doesn't fit this new style, worth a quick conversation.
- **Needs Nick:** nothing blocking — just say if you want the jackal's geometry done next, or something else first.

| ticket | priority | eta | state | |
|---|---|---|---|---|
| #- | high | not estimated | open | The palette in the reference is the point: pale stones, cool sky, dark ground |

## playtester — RUNNING NOW

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
| #- | high | not estimated | open | THIS is what the fight should look like: hunters far back, stones a visible path in the air |

## waiting on Nick

- **#5** At the sigil, the hunter reads as glued to the jackal's cheek, not standing on it

