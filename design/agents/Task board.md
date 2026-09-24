---
tags:
  - agents
issue: 9
---

# Task board

_Generated from the agents' own status notes and the open requests. Do not edit -- the next sync overwrites it._

| agent | | doing now | next | tickets |
|---|---|---|---|---|
| **artist** | 🟢 running | Nick answered the art-style request from my last two runs — "take C, and steal one thing … | the Cinder Jackal itself still needs the same low-poly cut — didn't risk it this run … | #12 #13 |
| **playtester** | 🟢 running | no requests addressed to `playtester` were open this run. Since my last run, the fixer … | watch for the fixer picking up stone-route item 2 (`hop-distance-band`, the only other … | — |
| **fixer** | 🟢 running | fixed the real, small case the playtester's own margin-guarded check kept finding after … | nothing of mine left on this one. Order-of-work for a future run: the stone-route … | #3 #4 #11 |

## Tickets

| # | owner | priority | eta | state | |
|---|---|---|---|---|---|
| #12 | artist | high | — | open | The palette in the reference is the point: pale stones, … |
| #13 | artist | high | — | open | The hunters are photoreal models rendered at 40 pixels. … |
| #3 | fixer | high | — | taken | Stones, camera and hunter spacing at the Cinder Jackal |
| #4 | fixer | high | — | taken | Build the one-directional stone route: fix the raycast, not … |
| #11 | fixer | high | — | open | THIS is what the fight should look like: hunters far back, … |
| #5 | nick | normal | — | open | At the sigil, the hunter reads as glued to the jackal's … |

## Waiting on you

- **#5** At the sigil, the hunter reads as glued to the jackal's cheek, not standing on …

## Last run, in their own words

**artist** — 2026-09-24 16:34 ET

- Did: Nick answered the art-style request from my last two runs — "take C, and steal one thing from B: a light distance fog purely for depth." Built the real thing instead of just scoping it: turned the shared toon shader's …
- Next: the Cinder Jackal itself still needs the same low-poly cut — didn't risk it this run because it's rigged and animated (the hunters aren't), so it needs its own careful pass to make sure the animations still play right …
- **Needs you:** nothing blocking — just say if you want the jackal's geometry done next, or something else first.

**playtester** — 2026-09-24 15:19 EDT

- Did: no requests addressed to `playtester` were open this run. Since my last run, the fixer landed the fix for the last thing I had filed (`1002`, the intent-tag-vs-hunter residual at ground-hop start — commit `d443ccd`). …
- Next: watch for the fixer picking up stone-route item 2 (`hop-distance-band`, the only other open item, confirmed a genuine geometric ceiling several runs ago — needs re-authoring the Python reference model or a joint …

**fixer** — 2026-09-24 14:42 EDT

- Did: fixed the real, small case the playtester's own margin-guarded check kept finding after my last hunter-clamp fix: at the very start of a ground-level hop, the intent tag's left edge grazed the hunter's own on-screen …
- Next: nothing of mine left on this one. Order-of-work for a future run: the stone-route hop-distance item (still `taken`, one real lever left after five ruled-out dead ends) or a fresh read of the fight's code paths if no …

