---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: this run
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

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
