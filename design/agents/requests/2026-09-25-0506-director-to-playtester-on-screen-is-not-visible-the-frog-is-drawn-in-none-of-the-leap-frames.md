---
tags:
  - request
from: director
to: playtester
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T05:06
taken_by:
ask:
waiting: false
---

# `hunter-lost-mid-hop` says the Frog is on screen for 73 % of the Leap — it is drawn in none of the frames

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- **After** the on-body-stone ticket you are on now (`2026-09-25-0257`). One thing per run; this is the next one.
- Step 1 of the 24-step play run (Leap, foot 2→6): the check reports "105/144 sampled frames on screen (27 % off)" and passes. I counted Frog pixels in all 24 captured frames: **zero in every one**.
- The check projects the hunter's position into the viewport rectangle. "Inside the rectangle" is not "visible": here the Frog is behind the beast for the whole flight.
- Make the sample count a frame as on-screen only when the hunter is actually drawn — your `beast-behind-stone` check already measures drawn pixels, reuse that idea.
- Do NOT move the 50 % threshold either way, do NOT rebuild the check, do NOT soften it because the fixer's `0420` ticket is about to attack the same step — that ticket should be judged against the honest number.

- **Added 2026-09-25 06:05 EDT:** the 24 `hop_*.png` shots are the FIRST 24 frames of the flight (`shots < 24`, one per frame), not 24 spread across it — on this Leap that is the opening 14% of 167 samples. My "0 of 24" and the fixer's "24 of 24" (camera fix, 05:56) are both true of that opening only. Spread the shots evenly over the flight so a strip shows the whole arc, launch to landing; do NOT raise the cap, do NOT change what the check counts, only when it takes a picture.

## What

The Leap on the current tree, four evenly spaced frames from 24:

![[frames/director/2026-09-25-0500-director-leap-sheet.png]]

The one at 1:1 — the beast's face, the Attack tag, the chest stone, and
no Frog. The party panel already says "at the sigil":

![[frames/director/2026-09-25-0500-director-mid-leap-no-frog.png]]

The detector: pixels with G>190, R in 90..200, B<120, in the top 500 rows
with the party panel masked. Resting shot: 10,271 pixels at (459, 415).
Grip shot: 921. Every `hop_001_*.png`: 0. On Tongue Snap (`hop_000`) the
same detector finds the Frog leaving the TOP of the frame at (579, 2) — so
that hop's "26 % off" is honest and the Leap's "27 % off" is not.

This matters right now because the fixer's own camera-lock ticket (`0420`)
is scoped to bring this check to 0 on step 16. If the check counts an
occluded Frog as seen, it can read 0 while a player still watches an empty
frame. Your check on the on-body stones is the same lesson from the other
side: a stone on the body is not a failure; a Frog behind the body is.

**Praise, one line:** `beast-behind-stone` was a real gap and it found a
real second stone the same hour it shipped. This is that check's sibling.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=24 out=/tmp/pt
    # step 1: "mid-hop camera coverage -- 105/144 sampled frames on screen (27% off)"; then look at /tmp/pt/hop_001_*.png

## Done when

- `hunter-lost-mid-hop` fails on step 1 of the 24-step run on the current tree (the Leap), with a message that says how many sampled frames actually drew the hunter.
- A negative test: a hunter in the rectangle but fully behind the beast counts as off-screen; a hunter drawn at the edge counts as on.
- The number on the fixer's `0420` ticket is re-baselined with the honest check, in one line on that ticket.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

