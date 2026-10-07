# checker — close the gap to Nick's drawing, one difference at a time

**Nick, 2026-10-06**, replacing the measurement loop that came before:

> Set up an autonomous visual-matching loop to make the game look like my
> reference drawing. Don't use numeric matcher scores as the goal or stop
> condition — they passed while the art was still clearly wrong.

`tools/sprite_match.py` reported `0 of 5 off` on a sprite whose cracks were
1px pen strokes with no hot core, whose facets had no tonal separation, and
which had no rim light at all. Coverage counts pixels, not width; edge density
counts edges, not contrast. **The numbers are not the goal and not the stop
condition.** A fresh pair of eyes on the picture is.

The reference is `design/art/targets/TARGET.png` — not the concept render.
Aiming at the concept was the earlier mistake.

## Each iteration

1. **Shoot and pair.** Capture the fight with the same framing as the
   reference and build the side-by-side, reference LEFT, game RIGHT:

       bash tools/cloud_setup.sh
       bash tools/shot.sh out=/tmp/now.png state=3d beast=cinder_jackal
       python3 tools/vs_target.py /tmp/now.png design/match-log/iter-NN.png --beast

   `NN` is two digits, continuing from the highest already in `design/match-log/`.

2. **Spawn a FRESH critic subagent** (Agent tool). Give it **only** the
   side-by-side image and the text below. No history, no notes, no earlier
   critic's findings, no account of what you just changed. A critic that knows
   what you were trying to do will tell you that you did it.

   > Left is the target art. Right is the game. List every visible
   > difference, comparing each of these explicitly: silhouette and body
   > proportions, pose and gesture, missing or extra elements (props,
   > effects, fire, UI), outline thickness/color/glow, crack width/color/
   > brightness/hot spots, surface shading and facets, lighting and rim
   > light, color palette, props (stones) shading and size, background
   > rocks, sky, lava and ground, scale and framing. Rate each difference
   > MAJOR / MODERATE / MINOR. Rank biggest first. Do not say it matches
   > unless you have checked every category.

3. **Fix the single top-ranked difference.** Edit the model, materials,
   shaders, lighting or scene directly — `tools/beast_sprite.py`,
   `game/views/combat_3d.gd`, the `.gdshader` files, the scene. Do not build
   new tools, checkers or queues unless the fix itself needs one. One
   difference per iteration; the next critic decides what is top after that.

4. **Append to `design/match-log/log.md`**: the iteration number, the critic's top
   three, and what you changed. One short block, no essays.

## Stopping

Stop when **two fresh critics in a row** report no MAJOR and no MODERATE
differences, or after **25 iterations**, whichever comes first. The count runs
across runs, not within one — read it from `design/match-log/log.md`.

**Never declare it done yourself.** Only a critic's verdict ends the loop. When
it ends, write a final block in `design/match-log/log.md` headed `## DONE` holding the
remaining difference list, and name `design/match-log/iter-01.png` and the last one so
the session can send both to Nick.

## Rules

- **Take the `builder` lease, not a `checker` one.** You now edit the same art
  code the builder does, and two writers at once is how a run spends itself
  untangling a merge. `tools/agents/lease.sh claim builder`; exit 3 means stop
  in one line.
- Tests before pushing: `"$(cat /tmp/GODOT)" --headless --path game --script
  res://tools/run_tests.gd` must print `ALL TESTS PASSED`. Never push red.
- Never force-push. Never open a window. Never end with a background command.
- Never ask Nick how a thing should look. The drawing answers that.
- `tools/sprite_match.py` still exists and is still worth a glance, but it is
  evidence, never the verdict.
