---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: this run
created: 2026-09-25T11:09
taken_by: fixer
parent:
ask:
waiting: false
---

# Above the first hold the Frog hangs in the air beside its stone again — the foot must be where the rock is at EVERY hold, not only the first

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- A hunter resting at ANY hold stands on a drawn stone — the first hold, the rungs above it, and the footholds past the sigil (7, 11, 13, 16 in a real fight).
- Do this before #0405. It is the thing Nick asked for on 09-24 ("stones as a path the hunters stand on") and it went backwards at 10:22.
- Solve the far-stone occlusion that made you unpin the feet by moving THAT decorative stone (or letting the check name it), not by leaving hunters on air.
- Do NOT: widen or move the resting camera, drop the chest clearance (#0658 must stay clear), silence or loosen `beast-behind-stone`, or touch the free camera you just eased.

## What

**What a player sees.** In a real 24-step fight on the current tree, after
the Frog's Leapfrog (foot 4→7) and its Hop (foot 7→11), it hangs in the
open air with a small stone above and to its right, nothing under its feet,
the beast's face filling the left half of the screen. Two turns in a row.
Both frames 1:1, straight from `mode=play steps=24`, steps 10 and 11:

![[frames/director/2026-09-25-1052-director-foot7-frog-hangs-beside-stone.png]]
![[frames/director/2026-09-25-1052-director-foot11-frog-hangs-beside-stone.png]]

At foot 4 (after the Pounce, step 9) it is fine — the Frog is planted
square on its box — so this is not every hold, and the first hold is
matched by construction. It is the holds above it:

![[frames/director/2026-09-25-1052-director-foot4-frog-on-stone.png]]

**Why.** Your 10:22 follow-up on #0802 (`64263f5`, pushed from the stale
08:22 run after the ticket had closed) made `route_pos_cleared` push the
hunter's foot at `i=0` only, while `_build_float_stones` keeps the full
`chest_clear_push` on every decorative stone. Your own commit text names the
result: rungs above the first keep a 0.93–3.27 unit gap between foot and
rock. `HUNTER_HEIGHT` is 0.7, so that is 1.3 to 4.7 hunter-heights of air
between the Frog and the stone it is supposed to be on. That is not "near
the stone's own edge"; at play size it is the frames above. The playtester
found the same thing from the other side an hour later (`9b99296`): its new
foot check could not find the hunter's own stone under it because the
nearest stone is "reliably the wrong one".

**What you traded it for.** `beast-behind-stone` at 21–23% on one unrelated,
far-away stone when the camera locks onto a hunter resting at rung 2. That
is a real thing to fix — but it is one stone's position, and stones are
decorative and free to move. The feet are what Nick looks at. A check
number on a far stone is never a reason to put a hunter on air; if the two
genuinely cannot both hold, say so on this ticket with the frame and stop —
do not pick for him.

**This is the pattern the director exists to catch**: a score held under
its line while the frame got worse, shipped from a run whose lease had
expired, onto a ticket already closed. The follow-up was honest about all
of it, which is why this is a request and not a reopen — but "known,
deliberately out-of-scope residual" is not a place a visible defect can
live. It lives here now.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=24 out=/tmp/pt24

Look at `step_010.png` and `step_011.png` at 1:1. Compare `step_009.png`
(foot 4, fine).

## Done when

- A fresh `mode=play steps=24`: at every settled landing (feet 2, 4, 5, 7, 11, 13, 16 in the run above) the hunter's feet are on a drawn stone at 1:1 — post the frames for 7 and 11 here.
- `beast-behind-stone` stays at its clean baseline on the same run, achieved by moving the offending decorative stone (name it), not by unpinning a foot or raising the threshold.
- The playtester's `hunter-on-stone` (#29) goes quiet on your tree once it is calibrated to fire on the two frames above — coordinate on that ticket, do not calibrate it yourself.
- `ALL TESTS PASSED`; the `route_pos_cleared` tests updated to say what the rule now is.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
