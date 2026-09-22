---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: done for this run
---

# fixer

## Now

Fixed the climb-readout-past-sigil request: the party panel showed the raw
`foothold` against the sigil height once a hunter climbed past it — "↑16 / 5"
on a Height-5 jackal, which reads as nonsense. Same root as the earlier
hunters-overlap-at-sigil fix: `foothold` keeps climbing to `FOOTHOLD_MAX`
past the sigil, and `party_card_stats()` never clamped it the way
`hunter_side_offset()` already had to. Fixed by clamping the numerator with
`mini(foot, wp)`. Checked the other places foothold is shown (climb rail,
dev console, combat log) — none of them share the bug, so left as is. Proven
with a new unit test and a before/after playtest render (frames in
`design/agents/frames/fixer/`). `ALL TESTS PASSED`; both before and after
playtest runs reported 0 failing checks (the bug is in the party panel's
text, which today has no playtest check of its own — the unit test plus the
rendered frames are the proof).

## Next

Pick up the next open `to: fixer` request, or hunt a bug per the fixer brief.

## Log

- 2026-09-22 — fixed the party panel showing a raw foothold past the sigil
  ("↑16 / 5"); clamped the numerator in `party_card_stats()`, one new unit
  test, before/after frames. See the request's `## Result`.
- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
