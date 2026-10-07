# Visual match log — the whole frame against TARGET.png

**Fresh start, 2026-10-07.** Round 1 (25 iterations on the old concept-cut
sprite) is archived in `round-1/`. Its rulings no longer apply.

**Nick, 2026-10-07:** "Override and start with a clean fresh slate. The goal is
get to the concept as close as possible, any means necessary. Use Meshy or
whatever is needed."

The target is `design/art/targets/TARGET.png`, the whole frame, every box in
the Round 2 checklist in `tools/agents/checker.md`. Every earlier ruling that
conflicts with TARGET is overridden: the pose, the stone route, the HUD.

The builder first ships the two top queue items (the rigged jackal in TARGET's
pose, TARGET's stones), then appends the `## Round 2` heading below. That
heading starts the checker. Until then this log ends in DONE on purpose.

## DONE
Waiting for the builder's `## Round 2` heading.

## Round 2 — rigged jackal, TARGET stones (2026-10-07)

### iter 01
- Critic A top 3: [MAJOR] framing (ears touch top, jackal fills only top half, frog mid-frame not lower third); [MAJOR] fist fire is a round sun disc, not flame tongues; [MAJOR] stone staircase veers right over the right forearm, bottom stone floats at the lava line.
- Critic B top 3: [MAJOR] framing/scale (16:9, jackal ~40% of width); [MAJOR] extra second hero (goblin) at right; [MAJOR] stone staircase ends at the right pec, starts mid-left.
- Changed: framing (both critics' #1). `DRAWN_GAP_PER_HEIGHT` 1.1→1.35, `GROUND_VIEW_PITCH` 0.08→0.03, `GROUND_LIFT` 0.07→0.03. Measured on the shot: ears 0%→6.4% below the top, lava band 44%→48%, frog 54%→57% (TARGET, scaled to the space above the hand: ~6 / ~46 / ~57).
- Tests: ALL TESTS PASSED. Playtest: the same 21 FAILs (hunter-off-marker, route-reversal on rung 5) before and after this change — they come with the builder's stones commit, not with this one.
- Meshy: 0 credits.
