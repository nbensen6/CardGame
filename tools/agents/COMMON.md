# Every cloud agent — read this first, every run

You are one of three cloud agents working on Titan-Slayers (a co-op roguelike
deckbuilder, Godot 4.7, GDScript) while Nick, the designer, is not watching.
The three are **artist**, **playtester** and **fixer**. Your own brief is
`tools/agents/<you>.md`; this file is what all three share.

## 0. Start on the real tip

The checkout arrives detached and often stale:

    git fetch --prune origin main && git checkout -B main FETCH_HEAD && git log --oneline -3

## 1. Set up (every run — the sandbox is fresh)

Follow `design/agents/status/README.md`: download Godot, `--import` (required,
or every class_name fails), and render with `xvfb-run` + `--rendering-driver
opengl3`. Rendering WORKS here (probed 2026-09-22: real frames, ~14s a shot).
`pip install pillow numpy` if you need to read or tile images.

## 2. Read the board

`design/agents/BOARD.md` (the goal and the rules), every
`design/agents/status/*.md` (what the others are doing), and every file in
`design/agents/requests/` whose frontmatter says `to: <you>` and
`status: open`. **Requests to you come before your own work.** Take ONE: set
`status: taken`, `taken_by: <you>`, commit and push that before doing the work,
so nobody else takes it.

## 3. Do ONE thing, well

One request, or one item of your own brief. Not two. Finish it: proven,
tested, pushed, written up. A half-done second thing is worth less than
nothing.

## 4. Prove it

- Anything logical: a test in `game/tools/run_tests.gd`; the suite must print
  `ALL TESTS PASSED` before you push. Never push a red tree.
- Anything visible: render it and LOOK at the frame at 1:1. Commit the frames
  you judged into `design/agents/frames/<you>/<yyyy-mm-dd>-<slug>*.png`
  (small: 1280x720 or less, a handful per run) so Nick and the other agents
  can see what you saw. Embed them in your write-up.
- You cannot see motion in one frame. For motion, render a strip of frames and
  tile them into one sheet.

## 5. Write it down, then push

- If you finished a request: `status: done` and fill its `## Result` (what
  changed, the commit, how verified, the frame).
- Need something another agent owns? File a new request from
  `design/agents/requests/_template.md`, one problem per file. Something only
  Nick can decide (taste, art direction, is it fun)? `to: nick`.
- Overwrite `## Now` in `design/agents/status/<you>.md`, update `updated:` and
  `working_on:` in its frontmatter, and add one line to its `## Log` (newest on
  top). Honest: say if it went badly or you gave up.
- `git pull --rebase origin main`, then push. On a conflict in
  `design/agents/`, keep both sides. Check it landed: `git log origin/main -1`.

## Never

- Edit another agent's status note, or take a request not addressed to you.
- Tune balance (Nick's standing rule: gameplay is not ready for win-rate work).
- Raise the Meshy cap or loop regenerating assets.
- Launch anything that needs a real monitor; it is always `xvfb-run`.
- Work outside the Cinder Jackal fight unless a request asks you to.

`CLAUDE.md` (architecture: /core must not depend on /views, /input or /net;
data lives in game/data/*.json) and the hard rules in `design/BACKLOG.md`
still apply.
