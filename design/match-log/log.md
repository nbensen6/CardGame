# Visual match log — the fight against TARGET.png

One block per iteration, appended by the `checker` agent
(`tools/agents/checker.md`). The pairs are `iter-NN.png` beside this file.

The rule that matters: a fresh critic looks at the pair with no history and
ranks every difference. The checker fixes the top one. Numbers from
`tools/sprite_match.py` are evidence, never the verdict — they read `0 of 5
off` on 2026-10-06 while the cracks were 1px lines with no hot core.

Started 2026-10-06. Iteration count runs across runs.


## iter 01 — 2026-10-07
Critic top 3: (1) MAJOR scale/framing — target is a waist-up, frame-filling golem, game shows a small full body; (2) MAJOR pose — target leans in with a raised fist, game stands in an A-pose; (3) MAJOR missing fireball on the raised fist.
Changed: `tools/beast_sprite.py` now cuts the jackal drawing at the hips (concept row 640) and sinks 18 px of it under the floor. The jackal rises out of the ground at the lava line, as in TARGET, and its climb holds were re-authored from the hips to the face. Test "climb ends at the face" now checks a fraction of the figure's height.

## iter 02 — 2026-10-07
Critic top 3: (1) MAJOR pose — no raised flaming fist; (2) MAJOR fire on the fist missing; (3) MAJOR stones — huge, set beside the jackal, near-white tops over hard black undersides.
Skipped 1–2: Nick ruled them out on 2026-10-06 ("The jackal should be able to move. So the direction doesnt matter. Its the quality that im looking for.") after the cut-and-rotate arm tore the figure. Fixed 3 (shading): the slab side walls were wound and lit inward, so the ink hull's near walls painted every side black. Flipped both and drew the slabs unshaded, with TARGET's tones measured on screen: top (155,147,141) against TARGET's (155,147,138), side (101,96,88) against (105,100,90). Size and placement are untouched.

## iter 03 — 2026-10-07
Critic top 3: (1) MAJOR pose (no raised fist); (2) MAJOR fist fire missing; (3) MAJOR scale/framing — the jackal is small and set back, ears ~20% down the frame, where TARGET's fills it.
Skipped 1–2 (Nick, 2026-10-06, see iter 02). Fixed 3: a billboard Sprite3D reports a CUBE as its AABB, so the flat drawing read as 27 units deep. Its "front edge" stood 13 units out, and that set the hunters' standoff, the camera and the arena, so DRAWN_GAP_PER_HEIGHT never bound. New `drawn_box` flattens it to the drawing's plane, and DRAWN_GAP_PER_HEIGHT 1.0 → 1.2 puts the ear tips just under the top of the frame. The jackal is ~1.3x larger on screen. New test for drawn_box.

## iter 04 — 2026-10-07
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI (intent label, weak-point rings, frog and marker, spark column). Its 4th: MAJOR stones too big and thick, heavy black outlines, too close to the camera.
Skipped 1–2 (Nick, 2026-10-06). Skipped 3: the label, rings and frog are the fight's own HUD, which TARGET also draws (its intent chip, its frog), and they land in the crop only because the layout differs. They are gameplay, not art. Fixed 4: SLAB_SIZE 1.4 → 0.95, and the ink hull went from 1.05x black to 1.025x dark grey (0.20, 0.18, 0.18), TARGET's soft slab edge. Stone placement is untouched.

## iter 05 — 2026-10-07
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR scale/framing. Its 4th: MAJOR stones run up the left arm to the shoulder instead of a stair ending under the sternum. Its 7th: MODERATE cracks thinner and redder than TARGET's, with a dim sternum.
Skipped 1–2 (Nick, 2026-10-06). Skipped 3: the scale now nearly matches (ears at the top, the body filling the crop), and what's left is the raised fist running off the left edge, which is the pose. Skipped 4: the route is gameplay Nick set explicitly (last stone in front of the head, 2026-09-25 and 09-28), so it goes to him, not to the checker. Fixed 7 in `tools/beast_sprite.py`: each crack grows 1 px into the rock in red-orange (222,72,24), and its interior is pulled 40% toward yellow (255,214,96). On screen the chest crack coverage is 25.3% against TARGET's 25%, and the core p90 G channel went from 180 to 189 (TARGET 205).

## iter 06 — 2026-10-07
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI. Then (4) MAJOR framing, which it called "further back, smaller", the opposite of the iter-05 critic's reading of the same scale; (5) MAJOR proportions, which come from the concept drawing; (6) MODERATE cracks; (7) MODERATE outline too thin, halo too wide and diffuse.
Skipped 1–3 as before; 4–5 too, as noted. Fixed 7 in `tools/beast_sprite.py`: LINE_W 7 → 9 and HALO_W 28 → 20.

Stalled on the pose: every critic since iter 01 ranks the raised flaming fist first, and TARGET.png shows it, but Nick ruled it out on 2026-10-06. The loop can't reach its stop condition (no MAJOR) until Nick picks one. Paused here for his call.

## iter 07 — 2026-10-07 (pair iter-08.png; after: iter-09.png)
Nick has not answered the pose question, so the loop carries on below it: the ruled-out items are skipped and the top remaining difference is fixed.
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI. Then (4) MAJOR stone route, (5) MODERATE proportions, (6) MODERATE eyes a dim orange slit where TARGET's are the hottest point on the head.
Skipped 1–5 under the rulings above (Nick's pose call, the HUD, the route Nick set, the concept's proportions). Fixed 6 in `tools/beast_sprite.py`: new per-beast `eyes` boxes; each eye gets a near-white core (255,244,190), a hot orange ring (255,150,40) and a 7 px orange glow over the rock.

## iter 08 — 2026-10-07 (pair iter-09.png; after: iter-10.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR proportions (hunched, asymmetric brute). Its 4th: MAJOR scale/framing — hips, crotch and thighs show above the lava, where TARGET is cut at the waist.
Skipped 1–3 under the rulings above. Fixed 4 in `tools/beast_sprite.py`: the cut moved from concept row 640 to 590, just under the belt. Holds 0–1 moved up to (598,568) and (600,535) so they stay above the cut. The body is refit to the same 1.90, so the jackal is also a little larger on screen.

## iter 09 — 2026-10-07 (pair iter-10.png; after: iter-11.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI (rings on the face and chest, the "…ck 7" chip, the frog). Its 4th: MAJOR scale/framing — the jackal is smaller and centred, with more sky round it.
Skipped 1–3 under the rulings above. Fixed 4 in `game/views/combat_3d.gd`: DRAWN_GAP_PER_HEIGHT 1.2 → 1.1. The ear tips sit just under the top of the frame again, the fists reach both edges, and both hunters are still on screen.

## iter 10 — 2026-10-07 (pair iter-11.png; after: iter-12.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI. Then (4) MAJOR proportions, (5) MAJOR stones (route up the left edge, bigger, flatter), (6) MODERATE outline soft and glowy, bleeding into a halo, where TARGET's is a crisp cel line.
Skipped 1–5 under the rulings above. Stone size was raised in iter 04 and the slabs shrunk then; what reads as "much bigger" now is mostly the near slab's perspective on the route Nick set. Fixed 6 in `tools/beast_sprite.py`: HALO_W 20 → 14 and HALO_A 0.50 → 0.32.

## iter 11 — 2026-10-07 (pair iter-12.png; after: iter-13.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR proportions. Then (4) MAJOR extra UI, (5) MODERATE scale, (6) MODERATE stones, (7) MODERATE outline bloom, (8) MODERATE cracks with no yellow-white sternum hot spot.
Skipped 1–4 under the rulings above. Skipped 5: it called the jackal "smaller, further away" on the framing the iter-10 critic called "a bit closer" — the critics now split either way. Skipped 6 (the route). Left 7 alone: the halo was cut last iteration, and the drawn shader never blooms, so the next critic judges that change. Fixed 8, which every critic since iter 07 has named, in `tools/beast_sprite.py`: a per-beast `hot` spot at the sternum junction (512,355), r 70. Seams inside it swell 3 px and heat toward (255,240,170), and the rock right round it takes a faint orange wash.

## iter 12 — 2026-10-07 (pair iter-13.png; after: iter-14.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI. Then (4) MAJOR proportions, (5) MAJOR scale — now "too big, arms cut off at both sides", the reverse of iter 11's critic, (6) MODERATE stones much larger and thicker than TARGET's thin slabs.
Skipped 1–4 under the rulings above. Skipped 5: since iter 09, critics have split both ways on the same framing. Fixed 6's size, not the route, in `game/views/combat_3d.gd`: SLAB_SIZE 0.95 → 0.8 and SLAB_BLOCK_HEIGHT 0.4 → 0.28 hunter heights.

Run paused after iter 12 (12 of 25 spent). Every critic still ranks the raised flaming fist MAJOR #1–2, so no critic can report "no MAJOR" until Nick rules on the pose. The rest of the iteration budget is kept for after that call rather than spent on items the critics now rank below it, or split on (scale).
Recurring items still open below the pose: dark, low-contrast facets with no warm lava up-light (critics 07–12), black background rocks with no blue-grey facet highlights (07–12), a thinner, dimmer lava band.

## iter 13 — 2026-10-07 (pair iter-15.png; after: iter-16.png)
Nick has still not ruled on the pose, so the loop carries on under it.
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR outline 1.5–2x too thick with a wide hazy halo, a sticker border rather than an inked line. Then (4) MAJOR framing, (5) MODERATE proportions, (6) MODERATE extra UI.
Skipped 1–2 (Nick, 2026-10-06). Fixed 3 in `tools/beast_sprite.py`: measured on the pair at matched height the line was 9 px to TARGET's 6. LINE_W 9 → 7 (now 6 on screen) and HALO_W 14 → 10.
Note for later runs: after rebuilding the sprite, run `godot --headless --path game --import` before `shot.sh`, or the shot shows the old texture.

## iter 14 — 2026-10-07 (pair iter-16.png; after: iter-17.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR stones (route up the left arm, flatter). Then (4) MAJOR extra UI, (5) MAJOR proportions/framing, (6) MODERATE cracks — the chest hot spot a pale, blown-out blob spreading across the chest where TARGET's is a vertical yellow seam, (7) MODERATE outline now "a little thinner" than TARGET's.
Skipped 1–5 under the rulings above. Left 7 alone: iter 13 measured our line at TARGET's 6 px, and the critics now split on it. Fixed 6 in `tools/beast_sprite.py`: the sternum heat is an upright ellipse (HOT_SQUASH 0.45 sideways) and its core is TARGET's yellow (255,222,100), not pale (255,240,170).

## iter 15 — 2026-10-07 (pair iter-17.png; after: iter-18.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR proportions. Then (4) MAJOR extra UI, (5) MAJOR stone route, (6) MODERATE cracks — thin, uniform veins with no glow bleed, where TARGET's seams bleed orange onto the rock (it called the new sternum seam close to TARGET), (7) MODERATE outline thinner than TARGET's.
Skipped 1–5 under the rulings above. Left 7: the line measures TARGET's 6 px (iter 13), and iter 13's critic called the 9 px line too thick. Fixed 6 in `tools/beast_sprite.py`: rock within 5 px of a crack takes a fading orange (200,70,25) wash, up to 45%.

## iter 16 — 2026-10-07 (pair iter-18.png; after: iter-19.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR missing fist. Then (4) MAJOR extra UI, (5) MAJOR framing, (6) MAJOR stone route, (7) MODERATE proportions, (8) MODERATE outline thinner and uneven, breaking along the lower arms, with a weaker glow.
Skipped 1–7 under the rulings above. Fixed 8's glow in `tools/beast_sprite.py`: HALO_W 10 → 14, undoing iter 13's halo cut (the 7 px line stays: it measures TARGET's 6 px). Two critics in a row (iters 14 and 16) read the glow as weak once the line was thinner. Not fixed: small white ticks where the inner arm lines meet the lava.

## iter 17 — 2026-10-07 (pair iter-19.png; after: iter-20.png)
Critic top 3: (1) MAJOR pose; (2) MAJOR fist fire; (3) MAJOR extra UI. Then (4) MAJOR proportions, (5) MAJOR stone route, (6) MODERATE cracks — the sternum now "a narrow strip with less bloom", where iter 14's critic called the round spot blown out, (7) MODERATE surface near-black charcoal, facets barely read, (10) MODERATE palette cooler than TARGET's.
Skipped 1–5 under the rulings above. Skipped 6: the critics split on it. Fixed 7 (named by every critic since iter 07) in `tools/beast_sprite.py`. Measured on the pair, the rock's brightness already matched TARGET's (median 43 vs 44). The hue did not: (59,34,31) against TARGET's maroon (74,32,26). Each rock pixel now keeps its brightness and moves 70% of the way to TARGET's hue. On screen it is now (69,29,25), median 41.
