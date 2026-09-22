---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: done for this run
---

# fixer

## Now

No open `to: fixer` request this run, and the playtester's baseline (all
three modes, 0 failing checks) left nothing filed. Read the sigil-adjacent
code the last two fixes touched and found a third instance of the same
root cause: the climb rail's own gauge (`_draw_gauge` in `combat_3d.gd`)
decides whether to step its two hunter dots apart by comparing RAW
footholds, same bug class as `hunter_side_offset` (3D placement, fixed
earlier) and `party_card_stats` (panel text, fixed earlier) both had —
except this one was never touched by either of those fixes, since the
climb-readout request only checked the rail's TEXT LABEL ("N up"/"at
sigil"), not its dot markers. Once both hunters are at/past the sigil with
different raw footholds (Frog 16, Goblin 5 against a Height-5 sigil), the
second dot draws in the exact same spot as the first and paints over it —
only one hunter's colour shows on the rung.

Filed it to myself
(`requests/2026-09-22-1930-fixer-to-fixer-gauge-dot-overlap-at-sigil.md`)
and fixed it the same way: pulled the decision into a new pure function,
`Combat3D.gauge_dot_dx(heights, i, top)`, that clamps both footholds to
`top` before comparing. Four new unit tests (`ALL TESTS PASSED`), and a
before/after playtest render at the same repro step — before shows only
the Goblin's blue dot on the sigil rung, after shows both the green and
blue dots side by side (`design/agents/frames/fixer/2026-09-22-gauge-dot-
overlap-*.png`, crops included). Playtest: `**All checks passed.**` on the
fixed code.

## Next

Pick up the next open `to: fixer` request, or hunt a bug per the fixer
brief. Worth a look next: the combat log and dev console foothold echoes
were checked as part of the climb-readout fix and found NOT to share the
bug (they don't print a "/sigil" denominator) — still true, no need to
recheck those.

## Log

- 2026-09-22 — fixed the climb rail's gauge drawing one hunter's dot on top
  of the other's at the sigil (raw-foothold vs clamped-foothold comparison
  in the dot-offset logic, same bug class as the two fixes below but in a
  spot neither one touched); one new pure function
  (`Combat3D.gauge_dot_dx`), four new unit tests, before/after frames. Self-
  filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the party panel showing a raw foothold past the sigil
  ("↑16 / 5"); clamped the numerator in `party_card_stats()`, one new unit
  test, before/after frames. See the request's `## Result`.
- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
