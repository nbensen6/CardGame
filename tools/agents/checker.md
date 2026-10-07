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
       python3 tools/vs_target.py /tmp/now.png design/match-log/iter-NN.png --full
       python3 tools/vs_target.py /tmp/now.png design/match-log/iter-NN-beast.png --beast

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

   **Round 2 (2026-10-07): spawn TWO fresh critics**, each blind to the
   other, each given both pairs (`--full` and `--beast`) and the checklist
   below. Act only on a difference both name at MAJOR or MODERATE. One critic
   alone is noise: in round 1 they split both ways on framing, outline width
   and the sternum glow, and the loop undid its own fixes.

3. **Fix the single top-ranked difference.** Edit the model, materials,
   shaders, lighting or scene directly — `tools/beast_sprite.py`,
   `game/views/combat_3d.gd`, the `.gdshader` files, the scene. Do not build
   new tools, checkers or queues unless the fix itself needs one. One
   difference per iteration; the next critic decides what is top after that.

4. **Append to `design/match-log/log.md`**: the iteration number, the critic's top
   three, and what you changed. One short block, no essays.

## Stopping

Stop when **two iterations in a row** have both critics report no MAJOR and
no MODERATE differences, or after **25 iterations**, whichever comes first. The count runs
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

## Round 2 — the whole frame (Nick, 2026-10-07)

Round 1 (iters 01–25) could not finish. It tuned a front-facing sprite cut
from the concept drawing, so TARGET's pose, fist and proportions were out of
reach, and it skipped the stones and HUD as out of scope. **Nick, 2026-10-07:
"make sure you are checking all the boxes to get to the concept. Ie stone
design and placement."** Nothing in TARGET.png is out of scope now.

Round 2 starts when the builder appends `## Round 2` to
`design/match-log/log.md` (after the rigged jackal and TARGET's stones ship);
until then there is nothing to check. **The 25-iteration cap counts from that
heading.** Shoot at rest (idle) so the jackal is in its rest pose.

**The checklist.** Both critics grade every box, every iteration:

1. **Jackal:** pose and gesture (hunched, three-quarter turn, left fist raised
   and on fire), proportions and silhouette, outline, cracks and the sternum
   hot seam, eyes, facets and shading, rim and lava up-light.
2. **Stones:** design (six thin pale grey slabs, soft edges, light tops) and
   placement (one staircase from left of the frog's rock up and right across
   the body to just under the sternum; face clear).
3. **Frog and its rock:** the frog centred low on a dark faceted pedestal, the
   green marker over it, its HP bar under it.
4. **Ground and lava:** dark cracked hex floor with faint warm seams; the
   bright lava band behind at the jackal's waist.
5. **Background:** dark slate cliffs both sides with cool edge highlights,
   purple sky, embers.
6. **HUD:** boss name and segmented HP bar top left, the intent chip beside
   it, Log and Menu top right, the climb gauge on the right edge, the energy
   box and draw/discard/burn bottom left, the fanned hand, End Turn and Switch
   bottom right. Compare look and placement; `TARGET-UI.png` is the close-up.
7. **Framing:** jackal waist-up filling the top two thirds, ears just under
   the top edge, frog centred in the lower third.

- **If you are blocked on a call only Nick can make**, do not pause silently in
  the log. Put it as the `Ask:` line on the top 👀 item in
  `design/plan/BUILDER-QUEUE.md` so it reaches him, and carry on with the next
  difference.
- A fix that changes gameplay (where a hold or the sigil sits, a camera
  number) is allowed when TARGET shows it; run the playtest as well as the
  tests before pushing.
