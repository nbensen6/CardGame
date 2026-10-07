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

### iter 02
- Critic A top 3: [MAJOR] extra second hero (Goblin + HP bar) right of centre; [MAJOR] framing/aspect — jackal ~33% of the frame width, right of the frog; [MAJOR] HUD over-decorated (glow borders on boss panel, chip, gauge, energy box, cards).
- Critic B top 3: [MAJOR] framing/aspect — jackal ~32% of the width; [MAJOR] extra second hero (Goblin); [MAJOR] left third of the background a black void, no slate cliff.
- Changed: the Goblin (both critics' MAJOR; the framing one is the 16:9-vs-square aspect, which no camera number fixes without clipping the ears — iter 01 set the height). `_stair_rest_x` puts the waiting Goblin 3 asides right (was 1.6), just off the right edge of the Frog's rest shot, as TARGET shows only the Frog (partner = Switch button + gauge pip). Switching to the Goblin still frames it (checked `state=goblin`).
- Tests: ALL TESTS PASSED. Playtest: the same 21 pre-existing FAILs (hunter-off-marker, route-reversal rung 5), unchanged.
- Meshy: 0 credits.

### iter 03
- Critic A top 3: [MAJOR] jackal too small for the frame (~33% of the width vs ~64%), scale up and centre; [MAJOR] stone staircase collapsed into a belly cluster, top slab far below the sternum; [MAJOR] upper-left background a black void, no left cliff or purple sky.
- Critic B top 3: [MAJOR] jackal too small, scale up 20–25% with ears just under the HUD line; [MAJOR] left background black void; [MAJOR] stones thick hex pucks, not thin pale slabs.
- Changed: jackal scale (both #1). `DRAWN_GAP_PER_HEIGHT` 1.35→1.05, `GROUND_VIEW_PITCH` 0.03→-0.02, `GROUND_LIFT` 0.03→-0.015. The jackal draws ~18% bigger (ears→lava 41.5%→49% of the frame): ears 3% under the top, lava 52%, frog 60%. Iter 01 shrank it to free the ears; this keeps them free by dropping the lava line instead.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing hunter-off-marker/route-reversal FAILs per step, nothing new.
- Meshy: 0 credits.

### iter 04
- Critic A top 3: [MAJOR] framing — jackal ~1/3 of the width and centre-right, empty void on the left; [MAJOR] no faceted pedestal under the frog, frog ~1.3x too big; [MAJOR] extra rings on the belly, ember column, sky streak.
- Critic B top 3: [MAJOR] framing — jackal right of centre, near-black void over the left third; [MAJOR] extra rings / sky streak / spark column; [MAJOR] frog pedestal missing.
- Changed: horizontal framing (both #1; the width share itself is the 16:9-vs-square aspect). New `_yaw_point()` / `DRAWN_YAW_X = 0.12`: the follow camera's line from a DRAWN beast through the hunter starts 0.12 of its width right of the box centre (the box takes in TARGET's raised fist, so its centre sat left of the head). Ear band 55.2%→50.5% of the frame, over the Frog at 50.4% (TARGET 50.4 / 50.6). The stair eye uses the same point, so the slabs move with it.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.
- Note: this run was cut once mid-iteration; iter 04's critics were re-spawned fresh on the same pair.

### iter 05
- Critic A top 3: [MAJOR] the Frog's dark faceted pedestal is missing; [MAJOR] stones chunky, darker, bunched on the belly, drifting right; [MAJOR] extra rings + sparkle trails.
- Critic B top 3: [MAJOR] Frog pedestal missing; [MAJOR] stones clustered right of centre, thick, mid-grey; [MAJOR] extra ring gizmos, dotted particle trails, white specks.
- Changed: the Frog's pedestal (both #1). `REST_ROCK_HEIGHT` 0.55→1.2 hunter heights; the rest rock is now ~1.6x wider (radius 2.1/2.3 HH, was 1.35/1.55) so it shows either side of the HP bar, flat-normal hex facets (was a smooth-shaded cylinder), tone 0.12→0.16. Also: `vs_target.py --beast` crops the shot at x 0.30–0.72 (was 0.38) now the jackal is centred, so its fist stays in the pair.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 06
- Critic A top 3: [MAJOR] stray blue + yellow rings by the stones, vertical sparkle streaks by the fist, pink sky streaks; [MAJOR] HUD glow borders everywhere; [MAJOR] stones squashed into a near-vertical belly cluster, thick and dark.
- Critic B top 3: [MAJOR] stones squashed/overlapping, bottom two oversized beside the frog; [MAJOR] stray blue + yellow rings and sparkle trail at the right hip; [MAJOR] HUD glow frames, green energy box, rectangular buttons.
- Changed: the rings (A #1, B #2 — highest combined rank; stones are A #3, B #1). `_build_ledge_marks` builds no safe-ledge rings on a TARGET staircase beast: they stood on the beast's centre line, off both hunters' slabs, and TARGET draws none — the slabs are the holds. Other beasts keep them. The sparkle streaks are still there.
- Tests: ALL TESTS PASSED. No gameplay position changed, so no playtest.
- Meshy: 0 credits.
