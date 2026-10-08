# The builder

## The goal: TARGET, 1:1

Nick, 2026-10-07 and 08: "Reset all rules." "The goal is get to the concept as
close as possible, any means necessary. Use Meshy or whatever is needed." "I
want the builder to focus on aesthetic changes." "Make its own decision till it
gets to the concept." "Build the concept 1:1."

- **The target is `design/art/targets/TARGET.png`, the whole picture: scene,
  HUD and cards.** When Nick says "the concept" he means this picture. Nothing
  else is a target: not `TARGET-UI.png` (a copy of an older painted mockup
  that disagrees with TARGET), not `design/art/targets/cards/`, not the
  jackal concept render, not `JACKAL-BAR.md`, `art-target.md` or the
  2026-09-24 composition drawing, not any older queue item, note or ruling.
  Anything that disagrees with TARGET.png is void, whatever its date.
- **1:1 means** the game's centred square (the middle 720x720 of the 1280x720
  frame) holds TARGET's picture: every element TARGET shows, the same shape,
  proportion, colour, shading, line, size and **place**, HUD and hand
  included. Outside that square is extra scene. Anchor the HUD and hand to
  that square, sized by the smaller of the window's width and height, so it
  holds at any resolution and aspect, tall phones included (this satisfies
  CLAUDE.md §5; no flag to Nick needed).
  `python3 tools/vs_target.py <shot> <pair> --square` is that test, and the
  close-ups (`--beast`, `--stones`, `--hand`) are cut from the same square at
  the same scale.
- **You decide every look question yourself** against TARGET. Never ask Nick
  how something should look, which of two looks to take, or whether to keep
  going. TARGET answers all of them.
- **In scope: everything visible.** Art, models, textures, shaders, lighting,
  camera, framing, scale, the position of anything on screen (the frog and its
  rock, the hunters, the stones, the HUD and the hand), animation look.
  Matching TARGET's layout is in scope even when it moves things the fight
  uses; keep the fight working and update tests that encode the old look or
  layout.
- **Out of scope:** game rules, card numbers, balance.
- **Meshy: use it whenever it gets closer** (image passes, 3D generation,
  anything). No credit cap from this brief. `tools/meshy.py` does text-to-3D
  today; extend it against Meshy's API for image-to-3D, retexture or image
  generation when you need them. In the cloud `MESHY_API_KEY` is normally
  unset because the agent proxy adds the key to Meshy calls itself: call the
  API anyway, and only if the calls fail say so in Found and use another
  means. The script keeps a daily task
  guard as a runaway brake; log every task and its credits in the notes.
- **What else still applies.** From `CLAUDE.md`: the code structure (§2, §8:
  `/core` stays free of views, input and net; data in `game/data`) and
  pointer-only input with no hover-only information (§5). Everything else in
  CLAUDE.md, `design/guide/asset-loop.md`, `art-target.md`, `BACKLOG.md` and
  the queue notes that limits passes, prefers small or simple changes,
  prefers lighting over geometry, sets a poly, atlas or performance budget, or
  sends a look question to Nick does not apply to TARGET work.
- **Tests that assert an old look or layout are rewritten to assert TARGET's.**
  Known ones: the RoR2 camera distance and aim tests, the one-line staircase
  and top-stone pullback tests, the picture-B / A1 glow HUD tests, the rarity
  pip tests, the fixed intent-badge slot, the left-only flank cliffs, the
  obsidian floor.

## The run, every time

1. **Set up.** You are in a fresh worktree on `origin/main`.

   On Windows (Nick's PC, `run.cmd`):

       set GODOT=C:\Users\nbens\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe
       "%GODOT%" --headless --path game --import

   On Linux (the cloud routine): FIRST `LEASE_STALE=10800
   tools/agents/lease.sh claim builder`. Exit 3 means another run is already
   working: stop, say so in one line, touch nothing. The very last thing you
   do, whatever happened, is `LEASE_STALE=10800 tools/agents/lease.sh release
   builder`. Then `python3 tools/needs_nick.py`, then `bash
   tools/cloud_setup.sh`, and use the `.sh` twins wherever this brief says
   `.cmd`: `tools/shot.sh`, `tools/playtest.sh`, `tools/test.sh`. Same
   arguments; `out=` must be an absolute path.

   The import is not optional: without it every `class_name` fails to resolve.

   A line starting `**Nick, <time>:**` on an item is his answer and outranks
   everything else in the item. It departs from TARGET only where it says so
   in words ("unlike TARGET, ..."); otherwise TARGET still decides. An image
   on it shows what Nick means for that item.

2. **Take the top open item under `## Now`** in
   `design/plan/BUILDER-QUEUE.md`: the first `- [ ] **` line WITHOUT 👀.
   A 👀 item is finished; never take it, never wait for Nick to tick it. If there is none,
   **queue your own work**, then take the top new item in the same run:

   Shoot the rest frame (`state=3d beast=cinder_jackal`) and make four pairs
   with `tools/vs_target.py`: `--square`, `--beast`, `--stones`, `--hand`.
   Spawn TWO fresh critic subagents, each blind to the other, each given only
   the four pairs and the critic prompt and checklist from
   `tools/agents/checker.md`. Every difference EITHER critic names at MAJOR
   or MODERATE, and every MINOR one BOTH name, becomes a new item at the top of `## Now`, biggest first, in exactly this
   shape: `- [ ] **Title.**`, then what TARGET shows against what the game
   shows, then `**Done when** the --square and <close-up> pairs show no
   visible difference in <part>.`, then `Test: state=3d beast=cinder_jackal`.
   If neither critic names anything above MINOR and they agree on no MINOR
   difference, add one line
   `Matched check <date>: clean` at the top of `## Now` and stop. When the two
   newest such lines are both clean with no built item between them, the
   game matches TARGET: stop without queueing.

3. **Shoot the BEFORE frame** with the item's named shot (default
   `state=3d beast=cinder_jackal`) to
   `design/agents/frames/builder/<date>-<slug>-before.png`, and pair it:
   `--square` always, plus the close-up for what the item touches
   (`--beast`, `--stones`, `--hand`). Look at the pairs. List every
   difference you see in the item's part of the picture.

   **The picture outranks the words.** An item's prose points at TARGET; it
   never replaces it. Where the words and TARGET disagree, TARGET wins.

4. **Do the item: whatever change makes that part match TARGET.** Not the
   smallest change that moves the frame; the change that lands it. If the
   current approach cannot reach TARGET (a procedural mesh that cannot take
   TARGET's shape, a texture too coarse), replace it: cut the art from
   TARGET.png itself, repaint, model it, or use Meshy. A replacement may look
   worse on its first try: build it on a branch `builder/<slug>`, push the
   branch at the end of every run, name the branch in the item's `Next pass:`
   line so the next run checks it out and carries on, and merge it into
   `main` only once it is at least as close to TARGET as what it replaces. Grep every caller
   before you edit a shared function.

5. **Prove it.**
   - Shoot the AFTER frame (same command, `-after.png`) and make the same
     pairs from it. If the frame did not change, the item is not done.
   - **Get graded.** Run the `grader` agent (Agent tool, subagent_type
     "grader") with exactly: the item's full text; the absolute paths of the
     before frame, the after frame, `TARGET.png` and the after frame's pairs
     (`--square` and the close-ups). Nothing else: not your summary, not the
     diff.
   - **FAIL: fix what it names and grade again. Keep going** until PASS, for
     as long as the run allows (start no new round after about 2.5 hours in).
     If the run ends without a PASS: push what you have if the grader did
     not call it further from TARGET (if it did: a replacement goes on its
     `builder/<slug>` branch as above, anything else is reverted), leave the item
     `- [ ]` open, and put one line under its title, `Next pass: <the
     grader's MISMATCHES and FIX, one line>` (replace any older one), so the
     next run continues from there. Never write a question for Nick.
   - Mark the item 👀 only on PASS. Paste the final VERDICT line into the
     status note's `Worked?` bullet either way.
   - `tools/sprite_match.py` measures against the old concept render, not
     TARGET. Its numbers are not a goal; ignore an OFF that TARGET disagrees
     with.
   - `"$GODOT" --headless --path game --script res://tools/run_tests.gd`
     must print `ALL TESTS PASSED`. Never push red. A test that asserts the
     old look or layout is updated to assert TARGET's.

6. **Commit to `main` and push.** Message starts `builder:`. `git pull
   --rebase origin main` first. Frames go in `design/agents/frames/builder/`,
   1280x720 or smaller.

7. **Write `design/agents/status/builder.md`**, overwrite `## This run`. The
   heading is exactly `## This run`; the time goes on the first line under it:

       ## This run

       2026-10-08 14:05 EDT

       - **Did:** one sentence, 20 words or fewer, no file paths.
       - **Worked?** Yes / No / Partly, and why, with the grader's VERDICT.
       - **Look at:** ![[frames/builder/<date>-<slug>-before.png]] then ![[frames/builder/<date>-<slug>-after.png]]
       - **Ask:** nothing
       - **Found:** anything you noticed and did not fix, one line each.

   Then in `BUILDER-QUEUE.md`, the item you worked. Its shape is fixed:

       - [ ] 👀 **Title.**
             ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Title.|details]]
             Ask: nothing
             Test: state=3d beast=cinder_jackal
             ![[agents/frames/builder/<after>.png|420]] ^block-id

   `Test:` is the exact harness arguments of your after frame (everything
   after `--` minus `out=`), with `+` in place of any space inside a value.
   `^block-id` is always the last thing on the item's last line. Everything
   else (what you tried, measurements, Meshy spend) goes to
   `design/plan/BUILDER-QUEUE-NOTES.md` under `## Title.` Never rewrite the
   title, never touch `^block-id`, never write `- [x]` (Nick ticks).
   Timestamps are US Eastern: `TZ=America/New_York date +"%Y-%m-%d %H:%M %Z"`.
   `Found:` lines that are differences from TARGET become new `- [ ]` items at
   the bottom of `## Now`; anything else goes to
   `design/plan/BUILDER-PROPOSED.md`.

8. **Next item.** After a PASS, if the run is under about 2 hours old, go
   back to step 2 and take the next item. Otherwise stop.

## Rules

- **Never touch rules or balance**, never open a window on the main screen,
  never force-push.
- **Never end the run with a background command running.** Foreground, with a
  timeout. A run that dies mid-flight loses everything unpushed, so push
  after every PASS.
- `CLAUDE.md` still applies to code structure: `/core` must not depend on
  `/views`, `/input` or `/net`; data lives in `game/data/*.json`.
