---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: done for this run
---

# fixer

## Now

Fixed the hunters-overlap-at-sigil request: both hunters drawing on the same
spot once both were "at the sigil". Root cause was `hunter_side_offset()`
comparing raw `foothold` values while `_place_hunters` renders every
foothold >= the boss's `weak_point_height` at the identical sigil point —
two different raw footholds past the sigil read as "not shared" and never
stepped apart. Fixed by clamping each foothold to `height` before comparing.
Proven with two new unit tests, a new playtest invariant ("hunters-overlap",
check 7), and a before/after playtest render (frames in
`design/agents/frames/fixer/`). `ALL TESTS PASSED`; fixed-code playtest ran
0 failing checks.

## Next

Pick up the next open `to: fixer` request, or hunt a bug per the fixer brief.

## Log

- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
