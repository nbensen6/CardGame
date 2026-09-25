---
tags:
  - agents
issue: 9
---

# Task board

_Generated from the agents' own status notes and the open requests. Do not edit -- the next sync overwrites it._

| agent | | doing now | next | tickets |
|---|---|---|---|---|
| **director** | idle | looked at all three shots again; the stones have bulk now, nothing else you asked for has … | your camera-switch ask is with the fixer; then #14, re-aimed after two dead ends it … | #18 |
| **artist** | 🟢 running | cut the Cinder Jackal's own geometry to 2,639 tris (was 11,999), flat-shaded — style C's … | #13 stays open (blocked on #18/#14, not touched this run); say if the three cast members … | #13 #? |
| **playtester** | idle | full 3-mode baseline (no regressions, matches last run exactly); added … | #14 (open the gap, lay the stones) is still the fixer's; nothing moved on it this run. | — |
| **fixer** | 🟢 running | took #14 (open the gap, lay the stones). Proved hunter placement alone can't open a … | #14 needs the director's call on the camera conflict, then a real rewrite (a parametric … | #14 #? |

## Tickets

| # | owner | priority | eta | state | |
|---|---|---|---|---|---|
| #18 | director | high | gap+stones 3-4 fixer runs, camera after, characters with the artist | taken | Own these three to completion. Chase them every run until I … |
| #13 | artist | high | next run | open | The hunters are photoreal models rendered at 40 pixels. … |
| #- | artist | normal | next run | taken | The footholds now read as clay pots with a lid, not boulders |
| #14 | fixer | high | stones need a parametric-path rewrite (2-3 runs) once the camera question below is settled | open | Open the gap between the hunters and the jackal, then lay … |
| #- | fixer | high | — | open | A Dev / Player camera switch in the menu, so Nick can see … |
| #- | nick | normal | — | open | The jackal was re-cut to half its geometry this evening — … |

## Waiting on you

- **#-** The jackal was re-cut to half its geometry this evening — keep it, or put the …

## Last run, in their own words

**director** — 2026-09-24 21:58 EDT

- Did: looked at all three shots again; the stones have bulk now, nothing else you asked for has moved.
- Next: your camera-switch ask is with the fixer; then #14, re-aimed after two dead ends it proved tonight.
- **Needs you:** one word on the re-cut jackal (keep or revert); nothing else.

**artist** — 2026-09-24 21:26 ET

- Did: cut the Cinder Jackal's own geometry to 2,639 tris (was 11,999), flat-shaded — style C's geometry half, the last thing pass 8 skipped.
- Next: #13 stays open (blocked on #18/#14, not touched this run); say if the three cast members now read as one style together.
- **Needs you:** nothing blocking — a look when you have a moment. This is the same "does it actually match" question #13 already burned once, so I did not tick either bar line myself; frames are in `JACKAL-BAR.md`.

**playtester** — 2026-09-24 21:16 EDT

- Did: full 3-mode baseline (no regressions, matches last run exactly); added `hunter-not-facing-beast` — checks a hunter's body actually turns to face the beast, live.
- Next: #14 (open the gap, lay the stones) is still the fixer's; nothing moved on it this run.

**fixer** — 2026-09-24 21:49 EDT

- Did: took #14 (open the gap, lay the stones). Proved hunter placement alone can't open a visible gap — the camera cancels it. Tried moving the stones toward the head, reverted twice.
- Next: #14 needs the director's call on the camera conflict, then a real rewrite (a parametric path, not a raycast-onto-surface tweak) for the stones. 2-3 runs once that's confirmed.
- **Needs you:** director, please read #14's `## Result` — item 1's Done-when ("gap visible in state=3d") looks unsatisfiable without touching the camera; need your call on which one gives.

