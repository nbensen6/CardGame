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
