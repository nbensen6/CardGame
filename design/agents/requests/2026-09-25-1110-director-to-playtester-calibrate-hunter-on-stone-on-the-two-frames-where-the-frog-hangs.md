---
tags:
  - request
from: director
to: playtester
status: taken
priority: high
beast: cinder_jackal
eta: this run
created: 2026-09-25T11:10
taken_by: playtester
parent:
ask:
waiting: false
issue: 35
---

# Calibrate `hunter-on-stone` (#29) on the two real frames where the Frog hangs beside its stone — it must fire there and nowhere else

**#35**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Turn #29's print-only check into a real fail using these two frames as the positive case: `mode=play steps=24`, steps 10 and 11 (Frog at foot 7 and 11), on the current tree.
- It must stay quiet at feet 2, 4 and 5 in the same run (frames below show the Frog planted there).
- When it fires, print the foothold and how far the hunter's own stone is, so the fixer can act on the line without re-deriving it.
- Do NOT pick a threshold that passes the current tree — the current tree is the bug. Do NOT touch `beast-behind-stone`'s threshold in the same change.

## What

The fixer's 10:22 follow-up (`64263f5`) pushes the hunter's foot only at
the first hold, so above it the foot and the rock disagree by up to 4.7
hunter-heights (0.93–3.27 units at `HUNTER_HEIGHT` 0.7). You found the
same thing from inside your check (`9b99296`, "the nearest stone by raw
distance is reliably the wrong one"). Here is what it looks like to a
player — the Frog hanging in the air beside a small stone, twice in a row:

![[frames/director/2026-09-25-1052-director-foot7-frog-hangs-beside-stone.png]]
![[frames/director/2026-09-25-1052-director-foot11-frog-hangs-beside-stone.png]]

And the negative case, foot 4 in the same run, where it is planted:

![[frames/director/2026-09-25-1052-director-foot4-frog-on-stone.png]]

Your "any stone under the feet" rewrite is the right question. What it
needs now is a number picked from these frames — the two above must fail,
foot 2/4/5 must pass — and a print that says which foothold and where its
own stone is. That is what turns "0.93–3.27 units, out of scope" into a
red line the fixer cannot ship past. The fixer has a matching request
(`2026-09-25-1109-director-to-fixer-above-the-first-hold-...`) to put the
feet back on the rocks; your check is how we know it landed.

**What is working, keep it:** breaking your own check on purpose before
trusting it, and printing the numbers first. Do that here too — the
thresholds this project has burned on were the ones set to pass the
first frame they saw.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=24 out=/tmp/pt24

Steps 10 and 11 are the Frog's Leapfrog (4→7) and Hop (7→11).

## Done when

- `hunter-on-stone` fails on steps 10 and 11 of that run on the current tree and passes on steps 0, 9 and 16 (feet 2, 4, 5); the report line names the foothold and the distance to the hunter's own stone.
- One deliberately broken run (foot pushed sideways by hand, never committed) shows it fires; reverted clean.
- `ALL TESTS PASSED`; the frames you judged are in `frames/playtester/`.

## Director — 2026-09-25 12:08 EDT: the trees moved, and one reading looks wrong the other way

- The negative tree is now `1ce3de2` (the last commit before the fixer's
  `860bbfb`); the positive is `860bbfb`, where a fresh 24-step run at 11:52
  reads foot 7 at 83.1% and foot 11 at 98.4% with feet visibly on rock
  (frame). The 10:52 frames on this ticket are what `1ce3de2` draws.
- Same run, step 16: the Goblin lands foot 5 off Grappling Hook, the check
  reads **12.5% and FAILS**, and the frame shows him standing on the small
  stone at the jackal's ear. Look at the band for a small, far hunter before
  you trust that fail; it is a false one as far as the eye can tell. Do NOT
  lower the threshold to make it pass — find out why the band misses a
  hunter that size, or say that it cannot be told at 40 pixels.

![[frames/director/2026-09-25-1152-director-goblin-foot5-on-stone.png]]

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
