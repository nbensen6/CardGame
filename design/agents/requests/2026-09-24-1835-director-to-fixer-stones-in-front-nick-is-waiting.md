---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T18:35
taken_by:
ask:
waiting: false
---

# The stones are still beside the jackal, not in front of it — Nick asked for this at 11:52 and is waiting

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Take the visible half of #4 next: move the stone route to the FRONT of the
  jackal, as Nick wrote on #4 at 11:52 ET. Prove it with the wide resting shot.
- Do NOT spend the run on the Height 3→4 / 4→5 spacing math (items 2 and 3)
  first — Nick said "take it before 2 and 3".
- Do NOT write a fifth investigation note. If a front hold cannot be found,
  show Nick a frame and two options on #4 the same run.
- Nick asked on #5 at 17:40 ET: "do you need any guidance on how to proceed" —
  that is him waiting on this. Answer him on #4 when you take it.

## What

What a player sees in the resting shot right now (fresh render at 1:1,
current main, your #11 camera fix included):

![[frames/director/2026-09-24-director-resting-shot.png]]

The two footholds sit at the jackal's right flank, level with its belly.
Nothing on screen says "climb up the front to the head". Zoomed only to
diagnose what the shapes are (the 1:1 frame above is the one that counts):

![[frames/director/2026-09-24-director-stones-zoom-diagnosis.png]]

Since Nick's 11:52 note on #4 the fixer has shipped #6 (intent-tag graze)
and #11 (camera). Both are real and verified, and both were smaller than
this. #4's last two entries are investigations dated 02:54 and 08:35, both
BEFORE Nick's requirement landed. So the thing he asked for most has had no
work since he asked for it, while two smaller things finished past it. That
is the pattern to break this run.

Nick's own words on #4 (11:52 ET), so you do not have to scroll:

- the stones go IN FRONT of the jackal, climbing up the front toward the head
- the last hold leaves the hunter facing the sigil with space between him
  and the skin, on a shelf, not pressed flat on the cheek
- if a hold cannot be reached from the front, move the hold, not the sigil

## What is working — keep it

The route-direction rule (`keep_route_going`, item 1) is right and the
evidence discipline on #4 is exactly what Nick wants. Do not undo item 1 to
get the front route; build the front route on top of it.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Compare with `design/art/references/2026-09-24-nick-target-composition.webp`:
his stones climb a diagonal from the frog up to the beast's front.

## Done when

- In the `state=3d` resting shot the footholds sit between the hunters and
  the jackal's chest/face, not at its flank.
- The 80-step playtest still shows 0 `route-reversal`.
- A reply under `## Nick's answer` on #4 tells Nick what changed, with the
  frame.

## Nick's answer

## Result
