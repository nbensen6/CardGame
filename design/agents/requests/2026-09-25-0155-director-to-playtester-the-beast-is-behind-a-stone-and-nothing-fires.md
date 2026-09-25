---
tags:
  - request
from: director
to: playtester
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-25T01:55
taken_by:
ask:
waiting: false
---

# The beast's body is behind a stone in the resting shot, and nothing you run fires on it

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- One live check: in the resting shot (`state=3d`) and after every hop, how much of the beast's on-screen body is covered by footholds — fail when it is more than a fraction you measure on the current tree and name in the log.
- Report it as a number a fixer can read ("torso 61% behind stone 1"), not a boolean.
- Do NOT fix the placement — that is #14, the fixer's, and it is being rewritten right now. Do NOT tune the threshold to pass the current frame; the current frame is the failure.

## What

**Update 02:00 EDT:** the fixer's stone sweep (#14 item 2) landed at 01:51,
after I rendered. The pot is now the artist's rock, and it hides MORE of the
beast — chest to paws, only the head clear. Frame below re-rendered on that
tree. This check is more needed, not less: the fixer proved that change with
`hop-distance-band` unchanged and zero `route-reversal`, which is true, and
neither number knew the beast had vanished.

What a player sees, at 1:1, on the tree as of 01:51 EDT: the near stone sits
exactly over the Cinder Jackal's chest and forelegs. Head, ears and eyes are
clear (the fixer's 00:52 fix); everything from the shoulders to the knees is a
pale pot with an orange lid. In the climb shot the beast is a black lump in
the corner and the Frog stands on a pot in the sky. In the grip shot only the
legs are in frame.

![[frames/director/2026-09-25-0152-director-resting-shot.png]]

Your baseline says 0 fails on everything except `hop-distance-band`. It is
telling the truth about what it measures, and none of what it measures is
this. You have `sigil-behind-hunter`, `hunter-offscreen`, `intent-hidden`,
`hand-over-hud` — every one asks whether the HUNTER or the HUD is hidden.
Nothing asks whether the BEAST is. Nick's drawing is the whole beast, upper
middle, sky above its ears; that is the shot the fight is being rebuilt
toward, and the one thing that would tell an agent it regressed is missing.

The timing matters: #14 is a rewrite of the stone path, live now. When it
lands, the fixer will prove it with `hop-distance-band` going to 0 and
`route-reversal` staying at 0 — the counts it has. A path can pass both of
those and still put a stone over the torso. This check is what stops that,
and it is worth more if it exists BEFORE the stones land than after.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Look at the frame at 1:1. Then project the beast's AABB and each foothold's
AABB the same way `sigil-behind-hunter` projects the sigil, and measure the
overlap of the beast's screen rect with any foothold rect that is nearer the
camera than the beast. The current tree should fail: that is the point.

## Done when

- The check exists in `playtest.gd`, fires on the current tree with a
  percentage in its message, and goes quiet when you move the near stone
  aside on purpose (revert the move; the placement is the fixer's).
- It runs in `play` after every hop, not only at step 0 — the climb shot
  above is the worst case and it is mid-route.
- One line on #14 telling the fixer the check exists and what it reads
  today, so it is in the fixer's baseline when the stones land.

## What NOT to do

- Do not move a stone, change the camera, or touch `combat_3d.gd`.
- Do not pick a threshold that the current frame passes.
- Do not add a second check in the same run. One thing.

## Nick's answer

## Result
