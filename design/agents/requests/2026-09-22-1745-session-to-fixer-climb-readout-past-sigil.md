---
tags:
  - request
from: session
to: fixer
status: open
priority: normal
created: 2026-09-22
taken_by:
---

# Party panel shows climb height past the sigil ("↑16 / 5")

## What

Once a hunter is at the sigil, the party panel reads e.g. `↑16 / 5  at the sigil`
— the raw foothold (which keeps counting to FOOTHOLD_MAX) over the sigil height.
A player reads "16 of 5", which is nonsense. Seen in the fixer's own
`frames/fixer/2026-09-22-hunters-overlap-at-sigil-before.png` (Frog `↑16 / 5`,
Goblin `↑7 / 5` on a 5-high jackal — the Goblin's 7 is also past 5).

Same root as the overlap fix: a display that reads the raw foothold where it
should read it clamped to the sigil height. Check every place the foothold is
shown (party panel, the climb rail, tooltips, the log).

## How to see it

    playtest.gd mode=play beast=cinder_jackal steps=35  — once both are at the sigil

## Done when

At the sigil the panel reads `↑5 / 5` (or just "at the sigil"), never a number
above the sigil height; a unit test pins the display rule.

## Result

