# Every cloud agent — read this first, every run

You are one of three cloud agents working on Titan-Slayers (a co-op roguelike
deckbuilder, Godot 4.7, GDScript) while Nick, the designer, is not watching.
The three are **artist**, **playtester** and **fixer**. Your own brief is
`tools/agents/<you>.md`; this file is what all three share.

## 0. Start on the real tip

The checkout arrives detached and often stale:

    git fetch --prune origin main && git checkout -B main FETCH_HEAD && git log --oneline -3

## 0b. Claim the lease, or stop

    tools/agents/lease.sh claim <you>

**Exit 3 means another run of you is already going. Stop there — do nothing,
push nothing, write nothing.** Say so in one line and end the run; the next
scheduled fire picks the work up.

Two of you cannot share a status note. On 2026-09-23 the hourly artist and a
manual one overlapped, both rewrote `status/artist.md`, and the second spent
its entire run untangling the merge instead of making anything. You cannot see
the other run — separate sandboxes, separate machines — so the lease is a file
in the repo, and the remote is the only thing that arbitrates.

At the very end of your run, whatever happened, including when you gave up:

    tools/agents/lease.sh release <you>

A lease goes stale by itself after 40 minutes, so a run that dies mid-flight
costs one skipped fire, never a wedged agent.

## 1. Set up (every run — the sandbox is fresh)

Follow `design/agents/status/README.md`: download Godot, `--import` (required,
or every class_name fails), and render with `xvfb-run` + `--rendering-driver
opengl3`. Rendering WORKS here (probed 2026-09-22: real frames, ~14s a shot).
`pip install pillow numpy` if you need to read or tile images.

## 1b. Answered requests come first of all

Nick answers in the request's own `## Nick's answer` section, in whatever words
he likes — he does not touch frontmatter, and he should never have to. **Any
request with text under that heading is the top of your queue, ahead of an
`open` one.** When you take it: set `status: taken`, do the work, and do the
bookkeeping yourself.

If his answer is not enough to act on, do not guess and do not sit on it: do
the part you can, then add one more bullet under `## What I need` saying
exactly what is still missing, and leave the answer in place.

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
  can see what you saw. **Embed them** in the request's `## Result` and in
  your status note's `## Now` with Obsidian syntax — `![[frames/<you>/<file>.png]]`
  — or Nick only sees a path he has to go hunting for.
- You cannot see motion in one frame. For motion, render a strip of frames and
  tile them into one sheet.

## 4b. Never end a run waiting on a background command

A run that ends while a `run_in_background` playtest is still going **loses
everything it did** — the 2026-09-23 16:05 artist run recoloured the
footholds, rendered the before/after, and pushed nothing. The sandbox is
destroyed when the run stops; there is no "resume automatically".

So: **commit and push your work first, verify second.** If the playtest then
contradicts the change, revert it in the next run — a pushed mistake is
recoverable, an unpushed fix is not. Run the long verification in the
FOREGROUND with a real timeout (`timeout: 600000` on the Bash call, 10 min)
rather than backgrounding it; a 40-step playtest takes 3-5 minutes.

## 5. Write it down, then push

- If you finished a request: `status: done` and fill its `## Result` (what
  changed, the commit, how verified, the frame).
- Need something another agent owns? File a new request from
  `design/agents/requests/_template.md`, one problem per file. Something only
  Nick can decide (taste, art direction, is it fun)? `to: nick`.
- **Every request opens with `## What I need` — bullets, one line each.** The
  body below it is for whoever has to do the work; those bullets are for
  whoever has to DECIDE, and they have to stand alone. A request whose ask is
  buried in paragraph four gets read late or not at all (Nick, 2026-09-23).
- **A `to: nick` request also fills `ask:` and `waiting:` in its frontmatter.**
  `ask:` is one plain sentence naming the decision — it is the entire row he
  sees in the FOR NICK table, so it must make sense with nothing else around
  it. `waiting: true` only when you genuinely cannot get on with your work
  until he answers; crying wolf here makes the flag worthless.
- **A `to: nick` request is written for a person, not an agent.** No file
  paths, no function names, no scores out of 50. Say what you are asking in
  one sentence, say what you RECOMMEND, and if it is a choice, give him the
  options as bullets with the trade-off on each. Show, do not describe: embed
  the frame. If you cannot put the ask in two bullets a non-programmer
  understands, you do not understand it yet.
- Overwrite `## Now` in `design/agents/status/<you>.md`, update `updated:` and
  `working_on:` in its frontmatter, and add one line to its `## Log` (newest on
  top). Honest: say if it went badly or you gave up.
- **Timestamp everything, to the minute, in UTC** (Nick, 2026-09-23). A bare
  date is useless here: three agents write these notes several times an hour,
  and Nick reads them in Obsidian to find out what is CURRENT. On a day with
  eight artist runs, "2026-09-23" cannot tell him whether a note is from before
  or after the thing he just played. Get the time from the machine, never guess
  it: `date -u +%Y-%m-%dT%H:%M`.
  - status frontmatter: `updated: 2026-09-23T16:33` (ISO, so Obsidian reads it
    as a real date and can sort on it).
  - every `## Log` line starts `- 2026-09-23 16:33 UTC — ...`.
  - every section you add to a `design/progress/*.md` note says the same in its
    heading, e.g. `## Pass 11 — artist, 2026-09-23 16:33 UTC`.
  - requests: `created:` carries the time the same ISO way, and a `## Result`
    says when it was filled in.
- `git pull --rebase origin main`, then push. On a conflict in
  `design/agents/`, keep both sides. Check it landed: `git log origin/main -1`.
- Last thing, always: `tools/agents/lease.sh release <you>`.

## Never

- Edit another agent's status note, or take a request not addressed to you.
- Tune balance (Nick's standing rule: gameplay is not ready for win-rate work).
- Raise the Meshy cap or loop regenerating assets.
- Launch anything that needs a real monitor; it is always `xvfb-run`.
- Work outside the Cinder Jackal fight unless a request asks you to.

`CLAUDE.md` (architecture: /core must not depend on /views, /input or /net;
data lives in game/data/*.json) and the hard rules in `design/BACKLOG.md`
still apply.
