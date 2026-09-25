---
tags:
  - request
from: director
to: playtester
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T02:57
taken_by:
ask:
waiting: false
---

# The tree moved under your occlusion check: the near stone is off the beast, and a foothold ON the body is not a failure

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- You claimed the beast-behind-stone ticket at 02:46; the fixer's fix landed at 02:49. Whatever you measured, re-baseline on the 02:49 tree (commit `2f9813c`) before you trust the number.
- Your check must tell two things apart: a stone BETWEEN the camera and the beast (the near stone was; a failure) and a foothold sitting ON the beast's body (Height 2 on the chest now; that is Nick's drawing, where the small stones sit on the beast's shoulder and arm). Only the first is a failure.
- Do NOT set a threshold that fires on the chest stone, and do NOT ask the fixer to move it — it stays.

## What

What a player sees on the current tree, 1:1: the whole beast, ears to
paws, with one small stone at its chest and the big near stone clear to the
left.

![[frames/director/2026-09-25-0253-director-resting-shot.png]]

Beside the drawing — note the white stones on the beast's own body:

![[frames/director/2026-09-25-0253-director-resting-vs-reference.png]]

The simplest split I can think of, and you may have a better one: a stone
whose world position is in front of the beast's near face (between the
camera and the beast's bounding box) is occluding; a stone whose position is
inside or behind the box's front face is a foothold on the body. Report the
occluding fraction as before ("torso 61% behind stone 1"); report the
on-body stones as a separate count so a reader can see both.

## Done when

- The check fails on the 01:51 tree (commit `b2a5c21`'s frame, beast hidden chest to paws) and passes on `2f9813c`, with the chest stone present, and the log says so with the two numbers.
- Nothing under `game/views` changed.

## Nick's answer

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)

## Director — 2026-09-25 04:05 EDT: your 03:22 check is exactly the case above, now with numbers

You could not have seen this ticket; it was filed at 02:57 and your run
began at 02:46. The check you landed at 03:22 is good and the numbers are
real: 23.9% on stone 2, 45-48% on stone 5. Both are false positives in the
drawing's own terms. Stone 2 is the small stone on the beast's chest; stone
5 is the head hold the Frog stands on at the sigil. Both sit on the body,
both are the picture. So this ticket is your next thing: the on-body split,
reported as its own count. The threshold is not the lever; a stone in front
of the beast's near face is occluding, a stone inside or behind that face is
a foothold. Done-when above stands. I have told the fixer on #14 not to
move either stone on your numbers.

