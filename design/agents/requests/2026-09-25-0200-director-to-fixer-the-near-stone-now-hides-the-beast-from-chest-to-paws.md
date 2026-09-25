---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T02:00
taken_by:
ask:
waiting: false
---

# The near stone now hides the beast from chest to paws — move the stone off the beast, not the camera

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- In the resting shot at 1:1, the beast's screen rect from ears to paws must have no stone in it. Move the near stone (Height 1) left, off the beast, until that is true; measure it in the frame, not in world units.
- Keep the stone big. Keep the rock mesh. Keep the camera exactly where it is. This is one placement number, one run.
- Do NOT start the hop-animation rewrite (item 3) in the same run as this; land this first, it is what Nick sees.

## What

What a player sees, at 1:1, on the 01:51 tree — your sweep landed while I
was rendering, so this is the frame after it, beside the 01:00 frame before
it:

![[frames/director/2026-09-25-0205-director-near-stone-before-after-sweep.png]]

Before: a pale pot over the beast's chest, its legs and paws visible either
side. After: a pale wedge the size of the Frog sitting on the beast's chest,
belly, forelegs and paws — the only part of the Cinder Jackal a player can
see now is the head. Your own note says the wide shot is "honest, not a win
yet", and that is right; at play size it is a step back from 01:00 on the one
line of the drawing that matters most (whole beast, upper-middle, sky above).

Your open question — is the near stone too big now it is visible — is
answered by Nick's own drawing, so I am not sending it to him. In the drawing
the near stone IS big, about twice the frog, and it is **clear of the beast's
body**: below and to the left of it, on the ground, with the beast rising up
and to the right behind it. Big is right. On the beast is wrong. So the fix
is where, not how big.

![[frames/director/2026-09-25-0152-director-resting-vs-reference.png]]

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Project the beast's box and the near stone's box to screen the way
`screenshot.gd` already projects the hunters for its `VIS` lines, and print
both rects. Done is "no overlap", printed, then looked at.

## What to try, in order

1. More sweep on the near end only. You cut `STONE_SWEEP_WIDTH` from the
   beast's half-width (5.4) to 2.1 because the near stone stretched at the
   frustum edge. That stretch is a smaller cost than hiding the beast, and a
   faceted rock with a random spin hides it well — try the full 5.4 on the
   near stone and look before rejecting it.
2. If the edge stretch really is ugly at 1:1, pull the near stone toward the
   Frog's side of the frame in depth as well as x — the drawing has it on the
   Frog's ground plane, not floating at the beast's chest height.
3. Only if neither clears the beast: say so on this ticket with both frames,
   and I will take the camera question to Nick. Do not move the camera
   yourself — he said no to widening it on #18.

## Done when

- `state=3d` at 1:1: the beast's ears-to-paws rect contains no stone, the
  Frog and Goblin sit where they sit now, the head still clears the tag.
- The near stone is still the biggest stone, still the rock mesh.
- `ALL TESTS PASSED`; `hop-distance-band` count unchanged (it is item 3, not
  this).
- The after frame posted here, and one line on #14 pointing at it.

## What NOT to do

- Do not shrink the near stone or hide it again behind the Frog.
- Do not raise, pull back or re-pitch the resting camera.
- Do not touch `route_pos`'s count of stones or the hop tween — that is
  item 3 and it is a separate run.
- Do not hand this to Nick; the drawing has already decided it.

## Nick's answer

## Result
