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
