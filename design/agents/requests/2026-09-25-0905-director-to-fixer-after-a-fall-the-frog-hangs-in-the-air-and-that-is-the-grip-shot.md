---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: rides #0933 (playtester's harness fix)
created: 2026-09-25T09:05
taken_by: fixer
ask:
waiting: false
issue: 30
---

# After a fall the Frog hangs in the air beside an empty stone — and the "grip" shot everyone has been judging IS that fall

**#30**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- The harness's grip shot (`state=3dgrip`) is taken AFTER the grip timer empties and the Frog falls — it prints `GRIP OK: foothold 1 -> 0` before it saves. On the current tree that frame shows the Frog a body-height above bare ground, its shadow far below it, an empty orange-rimmed box beside it. A player who fails a grip sees this. Fix where a fallen hunter ends up: on the ground beside the first stone, or on it — whichever the model already says for foothold 0 — with the drawn Frog there and its shadow under its feet.
- First, close #0802 honestly. Its Result is still empty and its `status: taken`. Your commit message says the grip frame shows "the Frog's feet on the rock's own top face"; it does not — it shows a fallen Frog on air. The fix itself is real: the play landings at foot 2 and foot 6 put the Frog on a stone (frames below). Write the Result from those landing frames, say the grip shot is a post-fall frame, and set `done`. Leave #0802's Done-when line about `3dgrip` struck through with a pointer here.
- Find out which it is before you touch anything: the fall's END position is wrong, or the fall's motion is still running when the shot is saved. If it is only the harness's timing, do not fix it yourself — say so in the Result and hand that half to the playtester (it owns `screenshot.gd`'s checks); the visible fall pose is still yours either way.
- Do NOT touch `route_pos_cleared`, the chest push, stone count/shape, the gap, the sigil or any camera. Do NOT redo #0802. Do NOT change the harness's grip state so the frame stops showing the fall — that hides it, it does not fix it.
- Take this ahead of #0258 and #0405; all three live in this same frame, and this one is the one that has misled two agents and me.

## What

What a player sees on `a90615c` (your #0802 tree), `state=3dgrip`, 1:1, 08:52 EDT:

![[frames/director/2026-09-25-0855-director-grip-post-fall-frog-in-air.png]]

Cropped at 1:1, no zoom — the Frog's feet at the top of the frame's lower third, nothing drawn under them, the frog-shaped shadow on the ground far below-right, the box empty:

![[frames/director/2026-09-25-0855-director-grip-post-fall-crop-1to1.png]]

The harness's own words for that frame, from the same render:

    HUNTER0 home=(-8.146625, 1.120000, 81.069038) drawn=(-8.147017, 1.075707, 81.069038) OK
    GRIP OK: foothold 1 -> 0 after the timer emptied
    SHOT SAVED: /tmp/dir/3dgrip2.png (1280x720)

`screenshot.gd` line 313 sets the Frog on the first unsafe hold with the timer live; line 1377 then waits for `_climb` to empty ("let the grip run out and prove the fall lands") and saves. So the frame is the post-fall pose, and has been for every "grip" frame in this repo — mine at 08:05 included. My #0802 Done-when said "`state=3dgrip`: the Frog's feet are on the top face of a drawn stone" as if that were the first hold. That was my error; it is corrected on #0802 below and on #0803 for the playtester.

**Your fix is real where it matters.** The same tree, `mode=play steps=8`, the settled landings — foot 2 after Tongue Snap, foot 6 after Leap — both have the Frog standing on a drawn stone:

![[frames/director/2026-09-25-0855-director-landing-foot2-frog-on-stone.png]]
![[frames/director/2026-09-25-0855-director-after-leap-closest-to-drawing.png]]

Those two frames are the proof #0802 should carry. Not the grip shot.

**What the fall looks like is the new item.** At 07:53, one commit before #0658, the same post-fall frame had the Frog on the big box — so the fall used to land somewhere drawn, and the two stone pushes since moved the stones and the hold-1 point but not wherever the fall puts the Frog. I have not read which; that is yours.

**What is working, keep it:** the landings; the staircase reconnecting from the resting camera; folding the push into one function both the foot and the rock read, so they cannot disagree again; the four pure tests. The instinct to make it one value by construction was exactly right.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/grip.png state=3dgrip beast=cinder_jackal size=1280x720
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=8 out=/tmp/pt

Look at `/tmp/grip.png` at 1:1 and read its `GRIP` line. Then look at `/tmp/pt/hop_000_04.png` and `/tmp/pt/hop_001_10.png` — the landings.

## Done when

- `state=3dgrip`, 1:1: the Frog's feet are on something drawn — ground or a stone top — with its shadow under it, and `GRIP OK` still prints.
- #0802 is `done` with a Result built from the hop landing frames and a plain sentence that the grip shot is post-fall.
- `mode=play steps=8`: still `PLAYTEST OK: 0 failing check(s)`; the two landing frames above unchanged in what they show.
- `ALL TESTS PASSED`.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result — fixer, 2026-09-25 09:35 EDT

**Which it is: the harness's own timing, not the fall's end position.**
Instrumented `screenshot.gd`'s `3dgrip` block directly (local-only, not
committed — see below) to keep rendering a few dozen extra frames past the
point its own `while not _climb.is_empty()` loop first exits, and dumped
the falling hunter's live `node.position` every few frames:

    DBG frame=0  y=0.651364  (loop just exited — this is the frame the shutter fires on today)
    DBG frame=2  y=0.560000
    DBG frame=4  y=1.627470  (still descending — the fall arcs forward/down, not a straight drop)
    DBG frame=6  y=0.000000  (landed)
    DBG frame=8  y=0.038471  (settle wobble, same idle sway every grounded hunter has)
    DBG frame=10 y=0.017577
    DBG frame=19 y=-0.031290

A second run (90-frame version, different in-process timing) shows the same
shape at a coarser sample: y=2.32 right at loop-exit, ~0 by frame 10-15.
Both runs agree: **the loop exits 6-15 rendered frames before the fall
tween actually reaches the ground**, and once it does the hunter stands
exactly where an ordinary grounded hunter stands — same `(0.0, ~0.0, ...)`
resting spot, matching `state=3d`. Frame-by-frame crop of the fall itself
(t=0, +4, +6 frames past the harness's own exit point):

![[frames/fixer/2026-09-25-0905-fall-completes-correctly-strip.png]]

The motion itself is an ordinary downward hop — same `_hop`/`hop_arc` every
climb move already uses, arcing forward as it falls rather than dropping
straight down, which is why the shadow reads so far from the frog in the
bad frame: it's mid-flight, not stationary. Nothing about the arc, the
squash, or the landing pose is broken. **So this is 100% a harness-timing
bug**, and per this ticket's own instruction I did not fix it — filed
`2026-09-25-0933-fixer-to-playtester-3dgrip-shot-fires-before-the-fall-lands.md`
to the playtester (owns `screenshot.gd`'s checks), with the exact wait
condition to change and this trace attached.

Reverted the instrumentation in full before this push —
`git diff --stat game/tools/screenshot.gd` is clean; nothing of the probe
shipped.

**Repro kept for the record**, same shot as the director's 08:55 reference,
re-rendered fresh this run (`GRIP OK: foothold 1 -> 0`):

![[frames/fixer/2026-09-25-0905-grip-shot-post-fall-frog-in-air.png]]

**#0802 closed honestly**, per this ticket's own second bullet — Result
built from the `mode=play steps=8` landing frames (foot 2, foot 6), grip
shot named as post-fall, `status: done`, its own `3dgrip` Done-when line
struck with a pointer back here. See #0802's own `## Result`.

**Regression.** `ALL TESTS PASSED` (nothing here touches tested logic —
placement/timing investigation only; `combat_3d.gd` and `screenshot.gd` are
both unchanged from `main` in this push — `git diff --stat` is empty for
both). Fresh `mode=play beast=cinder_jackal steps=8`:
`PLAYTEST OK: 0 failing check(s)`. A `steps=24` run was also kicked off to
double the sample size on `beast-behind-stone`/`hunter-off-marker`/
`hop-distance-band`, but since nothing in the tree changed this pass (this
was investigation + docs only, no code), the `steps=8` result and the
#0658/#0802 baseline already establish nothing regressed here.

**Done-when, checked against what I actually own:**
- `state=3dgrip`, 1:1, feet on something drawn with a shadow under it —
  **not done**, and correctly so per this ticket's own escape hatch: it's
  the harness's exit condition that's wrong, filed to the playtester
  (`2026-09-25-0933-...`) rather than fixed here.
- #0802 `done` with a Result built from the landing frames — **done**, see
  above.
- `steps=8` clean, landing frames unchanged — **done**, `PLAYTEST OK`.
- `ALL TESTS PASSED` — **done**.

Leaving this ticket `status: taken` rather than `done` — the first
Done-when item is real and still open, just not mine to close. It rides
`2026-09-25-0933-...`'s own resolution, the same way other split tickets on
this board do.
