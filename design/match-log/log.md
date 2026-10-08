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

### iter 07
- Critic A top 3: [MAJOR] HUD restyle — thick glowing borders on boss bar and chip, teal energy box, framed-rectangle End Turn/Switch, glowing gauge; [MAJOR] hand cards too big, green glow, flat fan; [MAJOR] framing (16:9 vs square, dark left side).
- Critic B top 3: [MAJOR] strip the HUD glow borders, energy box brown/gold, End Turn orange pill, Switch navy pill; [MAJOR] shrink the hand ~35%, more fan; [MAJOR] left background black void.
- Changed: HUD styling (both #1). New `tools/hudpanel_flat.py` → `hud_panel_flat_{base,glow}.png`, same nine-patch geometry as A1, swapped in for the A1 carved stone: a flat dark plate with a grey hairline, and the tinted layer is now a thin hairline, not a glow. Energy box: brown face + gold hairline + amber numeral (`ENERGY_FACE`, `ENERGY_GOLD`), no longer seat-coloured. End Turn: amber pill; Switch: navy pill (`PILL_RADIUS`, `SWITCH_FACE`), plates behind both hidden. The climb gauge's own green frame and the cards' glow are untouched.
- Tests: ALL TESTS PASSED (the A1 button test now pins TARGET's two pills). No gameplay position changed.
- Meshy: 0 credits.

### iter 08
- Critic A top 3: [MAJOR] left background a black void under the horizon, no slate cliff; [MAJOR] stones bunched/overlapping over the belly, two lowest thick and blocky; [MAJOR] hand ~1.6x too big, flat fan, green glow.
- Critic B top 3: [MAJOR] stones — bottom two thick blocks with dark sides, upper four dark and bunched into a pile; [MAJOR] sternum seam short and dim; [MODERATE] fist fire a disc.
- Changed: the stones (A #2, B #1 — highest combined rank). `STAIR_EYE_UP` is now derived from the rest camera's constants (the hand-measured 0.93 went stale when iters 01–03 moved pitch and lift, so every slab hung on a sight line from the wrong eye). Slab thickness `STAIR_THICK` 0.3→0.2 of the half-width, with its own floor `STAIR_MIN_THICK` (0.1 HH) instead of a plain slab's 0.28 HH, which had made the small upper slabs nearly as thick as wide. Still open: tops not lighter than sides; one of the Goblin's mirrored slabs shows by the top of the Frog's line.
- Tests: ALL TESTS PASSED (the thickness test now also pins "thin"). Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 09
- Critic A top 3: [MAJOR] stones — middle slabs bunch at belly height, no clean staircase, bottom slab against the frog; [MAJOR] left cliffs a flat near-black mass with no cool edges, top-left sky black; [MAJOR] hand too big, flat, green glow.
- Critic B top 3: [MAJOR] black void in the top-left, no purple sky, no lit left cliff; [MAJOR] jackal too small for the wide frame; [MAJOR] stone staircase broken, clustered, stops at the belly.
- Changed: the left background (A #2, B #1 — highest combined rank). `cliff_flat.gdshader` keys every facet off the better of `key_dir` and its mirror across x, so the left formation's middle-facing planes take the cool lit tone the right one's already did (it was all side/shade tone: the "void").
- Tests: ALL TESTS PASSED. Shader only, no gameplay change.
- Meshy: 0 credits.

### iter 10
- Critic A top 3: [MAJOR] hand ~2x too big, flat, green glow, cost gems inside the card; [MAJOR] stones bunched in a vertical cluster at the belly, top ~40px too low; [MAJOR] End Turn/Switch side by side, not stacked.
- Critic B top 3: [MAJOR] stones clumped in an overlapping column at belly centre, top slab at the navel; [MAJOR] hand too big; [MAJOR] frog pedestal unreadable, frog too high.
- Changed: the stones (A #2, B #1; tied with the hand on rank, picked as the one named MAJOR every iteration since 03). Measured each slab against TARGET in jackal heights (ears→lava, x from the head): they drew 0.04–0.11 too low and s3/s4 0.05–0.07 too far right, s0 0.25 too far left and 0.08 too wide. New `STAIRCASE.adjust` moves each climb point by its measured gap before the sight-line projection; widths of the two low slabs 0.305/0.28 → 0.25/0.23. After: every slab within ~0.04 of TARGET's spot, top slab at the sternum.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs (route-reversal is TARGET's own zig at the top rung), nothing new.
- Meshy: 0 credits.

### iter 11
- Critic A top 3: [MAJOR] a hard horizontal cut across the jackal's torso right of the stones; [MAJOR] white speckle fringe on the right forearm and round the fist; [MAJOR] stones a near-vertical stack, bottom two too small.
- Critic B top 3: [MAJOR] sprite alpha: hard horizontal seam across the lower torso + white fringe on the forearm/fist; [MAJOR] HUD ~1.5–2x too big; [MAJOR] stones a short steep cluster.
- Changed: the torso seam (both #1). It was the ghost of TARGET's own slab left on the belly by `tools/beast_rig.py` — its grey test missed the slabs' orange-lit undersides — with the borrowed patch beside it ending in a hard edge. New `STONES` in beast_rig.py: TARGET's five body slabs as hand-read rects, always counted as stone, and filled by inpainting from the rock round them with the gold rim masked out (borrowed blocks there read as pasted rectangles with a second sternum seam). Regenerated `cinder_jackal_2d.png` / `_torso.png`; the slab ghost and the seam are gone. The dotted speckle columns look like ember particles, not the sprite; left for now.
- Tests: ALL TESTS PASSED. Art only.
- Meshy: 0 credits.

### iter 12
- Critic A top 3: [MAJOR] stones — bottom two too big and thick, staircase a near-vertical stack; [MAJOR] a dark smoky blob with speckles over the lower belly; [MAJOR] hand ~1.4x too big, covers the pedestal.
- Critic B top 3: [MAJOR] a dark smoke column over the abdomen and waist under the stones; [MAJOR] fist fire a round disc; [MAJOR] HUD and hand ~1.5x too big.
- Changed: the belly smudge (A #2, B #1). Iter 11's inpaint filled the slab holes with a dark blur. `beast_rig.py` now lays TARGET's own cracked rock over each hole from the cleanest sideways/diagonal offset (never straight up — that lands on the sternum and paints a second Y; a yellow-heat penalty too), feathered 7 px into the inpaint. Regenerated `cinder_jackal_2d.png` / `_torso.png`.
- Tests: ALL TESTS PASSED. Art only.
- Meshy: 0 credits.

### iter 13
- Critic A top 3: [MAJOR] lower-body artifacts — black shards and a dark gap under the stones, white fringe on the right arm/leg; [MAJOR] staircase steep and bunched over the belly; [MAJOR] frog too high and big, pedestal invisible.
- Critic B top 3: [MAJOR] HUD ~1.5–2x too big, hand covers the pedestal; [MAJOR] hand flat, glowing; [MAJOR] lower torso fades to a dark blob with no cracks or lava up-light.
- Changed: the dark lower body (A #1, B #3 — highest combined rank). TARGET's up-light lives in the sprite's last rows, which the floor's lava strip hides in the fight, so the lower torso read unlit. `beast_rig.py` now screens a warm ramp (`UPLIGHT` 0.75 of (255,105,25), over the 110 px above the cut) onto the body, so the glow starts above what the floor hides. Regenerated the rig PNGs. The "black shards" are the cliffs seen through the gap between the flank and the arm (TARGET's own silhouette); the white specks are falling ember particles — both left.
- Tests: ALL TESTS PASSED. Art only.
- Meshy: 0 credits.

### iter 14
- Critic A top 3: [MAJOR] stones a near-vertical stack from the frog's head to the chest; the bottom slab should be left of the frog's rock at floor level, lower slabs larger; [MAJOR] cracks thin and dim, short sternum seam; [MAJOR] HUD oversized.
- Critic B top 3: [MAJOR] fist too low and tucked in, fire a disc not tongues; [MODERATE] hand too big; [MODERATE] jackal too narrow for the wide frame.
- Changed: the stones (A #1, B #4 [MODERATE] — highest combined rank). Re-measured every slab against TARGET in jackal units: s0 sat 0.07 too far right (crowding the Frog), s1 0.03 high, the top slab 0.06 right. `STAIRCASE.adjust` s0 x 0.25→0.17, s1 y 0.106→0.075, s5 x 0→-0.06; widths of s0/s1 0.25/0.23 → 0.26/0.26. Now (dx, y, w) per slab vs TARGET: (-0.36,1.02,.32)/(-0.31,1.04,.32), (-0.23,.88,.25)/(-0.23,.88,.28), (-0.04,.79)/(-0.05,.81), (.07,.74)/(.08,.76), (.13,.69)/(.15,.71), (.00,.66)/(.02,.66) — one diagonal from left of the Frog up to the sternum.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 15
- Critic A top 3: [MAJOR] stones a near-vertical stack over the frog, the bottom slab should start about a frog-width left of the frog's rock; [MAJOR] framing (16:9, dead sides); [MODERATE] floating black shards beside the jackal.
- Critic B top 3: [MAJOR] 16:9 vs square, jackal ~40% of the width; [MAJOR] stones a column over the frog, bottom slab should be ~15% of the frame width left of it; [MAJOR] HUD/hand oversized.
- Changed: the stones (A #1, B #2). Iter 14 matched each slab to TARGET in *jackal* units, but the Frog draws ~1.6x TARGET's size against the jackal, so the low slabs still sat on top of it. Both critics measure them against the Frog: s0/s1 now step out to ~15% of the frame width left of it (`adjust` x 0.17/0.017 → -0.03/-0.10): one diagonal from left of the Frog's rock to the sternum. Tried and backed out: `FOLLOW_DIST` 8 to shrink the Frog itself (it pulls the Goblin, the arena edge and the climb camera along; a bigger change than one iteration).
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 16
- Critic A top 3: [MAJOR] stones a narrow vertical stack over the belly, top one a stone-height low, bottom one too high and right; slab shadows blotch the body; [MAJOR] HUD panels ~2.5x too tall; [MAJOR] hand too big, flat, cropped.
- Critic B top 3: [MAJOR] stones a vertical stack at screen centre, not TARGET's diagonal, plus dark blotches on the body; [MODERATE] hand too big; [MODERATE] fist fire a ball.
- Changed: the stones (both #1). My slab measurements since iter 10 used the wrong head x (the eyes' 50.5% instead of the ear band's 52.3%), so every slab sat ~0.07 jackal-heights further left than I logged. Re-measured off the ear band and re-set `adjust`: now (dx, y) per slab vs TARGET: s0 (-0.42,1.06)/(-0.31,1.04), s1 (-0.26,.88)/(-0.23,.88), s2 (-0.04,.80)/(-0.05,.81), s3 (.10,.74)/(.08,.76), s4 (.17,.69)/(.15,.71), s5 (.04,.64)/(.02,.66). The staircase slabs also lose their soft drop shadow (TARGET draws them clean on the body).
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 17
- Critic A top 3: [MAJOR] hand ~1.6x too big, flat, green glow; [MAJOR] stones mid-grey with dark undersides, not pale with light tops, compact and steep; [MAJOR] fist fire a round halo.
- Critic B top 3: [MAJOR] stones too dark and too small, bottom two should be ~1.5x; [MAJOR] cliffs flat black spires without cool edges; [MAJOR] HUD too heavy.
- Changed: the stones' tone and size (A #2, B #1). Measured on screen the slab tops peaked at ~155 and the sides at ~89 against TARGET's ~193 / ~108: `SLAB_TOP_TONE` 0.54→0.69, `SLAB_SIDE_TONE` 0.42→0.48 (now ~193 / ~104). The two low slabs' widths 0.26/0.26 → 0.32/0.30.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 18
- Critic A top 3: [MAJOR] framing — jackal ~38% of the width, empty cliff both sides; [MAJOR] floating black shards, stippled right edge, sky streaks; [MAJOR] right arm hangs straight, not bent forward.
- Critic B top 3: [MAJOR] framing — jackal fills less, ~2x TARGET's air over the ears; [MAJOR] hand ~1.6x, flat, cropped; [MAJOR] stones: upper four a column, low two too big.
- Changed: framing (A #1, B #1). `DRAWN_GAP_PER_HEIGHT` 1.05→0.9, `GROUND_VIEW_PITCH` -0.02→-0.06: the jackal draws ~13% bigger (ears→lava 47%→52% of the frame), ears 5.1%→3.5% under the top, lava 52.5%→55.6%. Tried a lower Frog too (lift -0.05/-0.08 → frog 63–65%): its HP bar went behind the hand, so the Frog stays at ~60% until the hand shrinks. The width share stays the 16:9-vs-square difference.
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.

### iter 19
- Critic A top 3: [MAJOR] fist fire an orb behind the fist; [MAJOR] jackal ~43% of the width; [MAJOR] stones: top three tilted and overlapping, bottom two too big and white.
- Critic B top 3: [MAJOR] stones: steep zig-zag, oversized bottom slab, top two tilted over the seam; [MAJOR] hand too big; [MAJOR] frog pedestal hidden.
- Changed: the stones (B #1, A #3 — highest combined rank). Iter 18's bigger jackal left the slabs ~1.35x TARGET's width against it (s0 0.44 vs 0.32, s1 0.37 vs 0.28, s2 0.24 vs 0.17, s3 0.19 vs 0.13 jackal-heights); widths of s0–s3 → 0.23/0.225/0.125/0.094, now 0.28/0.28/0.14/0.13. And the staircase slabs no longer spin in place (`rotation.y += delta*0.25`): turning, their hex outlines read as tilted, overlapping plates; TARGET's lie still. `vs_target.py --beast` crop widened to the larger jackal (x 0.26–0.76, y to 0.60).
- Tests: ALL TESTS PASSED. Playtest: the same pre-existing FAILs, nothing new.
- Meshy: 0 credits.
