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
