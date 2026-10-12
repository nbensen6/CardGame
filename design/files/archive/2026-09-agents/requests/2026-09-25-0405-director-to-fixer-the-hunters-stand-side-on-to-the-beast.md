---
tags:
  - request
from: director
to: fixer
status: wontfix
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-25T04:05
taken_by: director
ask:
waiting: false
issue: 26
---

# At rest the Frog stands side-on, looking off the right edge of the screen; Nick's shot wants its back to us and its eyes on the beast

**#26**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- In the resting shot the Frog is in full profile facing screen-right and the Goblin faces three-quarters toward the camera; neither looks at the Cinder Jackal, which stands ahead of both.
- Nick's camera spec (the 22:25 lines on the player-camera ticket) is the hunter's BACK at bottom-centre, eyes on the beast — Risk of Rain 2. The camera is there; the bodies are not.
- Turn the bodies to face the beast at rest. Do NOT touch the camera, the stones, the gap, or the models; if the models' forward axis turns out to be the cause, file that to the artist rather than compensating in code.
- Take this AFTER the 20 m hops (`2026-09-24-2344-...`), same as the popup ticket. It is small; the hops are what Nick is waiting on.

## What

At 1:1, on the 03:22 tree (game code unchanged since the 02:49 fix):

![[frames/director/2026-09-25-0400-director-resting-shot.png]]

The Frog's flank is what a player sees, a frog looking at nothing on the
right; the boss is upper-middle. The Goblin, on the right, faces the
camera. Two characters standing around, not two hunters squaring up to a
titan.

Where I would look first, and you may find otherwise: the per-frame
"hunters keep their eyes on the boss" yaw in `_process` computes the
target angle in world space and applies it to the `body` child, while the
holder node above it is itself turned at rest (`PI + 0.7 * side` on the
ground). The two compose into roughly ninety degrees off, a different
ninety for each hunter, which is exactly the two poses in the frame. If
that is it, the fix is a few lines, not a rebuild. If the holder's rest
yaw is intentional (a three-quarter pose for the party), then the
eyes-on-the-boss rule and the rest pose are fighting and one has to win;
say which you picked and why on this ticket.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

- In `state=3d` at 1:1 both hunters face the beast: the Frog's back or back-quarter to the camera, the Goblin likewise, with the beast where they look.
- `state=3dclimb` and `state=3dgrip` CAM/HUNTER lines unchanged; `ALL TESTS PASSED`; a full playtest with no new fail category.

## Director — 2026-09-25 09:58 EDT: Nick's Risk of Rain picture is in, and it is this ticket's target

`design/art/references/hKsXNZ9zAbYXR7QxaDZBoY-1920-80.jpg`, landed 09:50.
Our resting shot over it, both at 1:1 (ours 1280x720 on top):

![[frames/director/2026-09-25-0952-director-resting-over-nicks-ror-picture.png]]

The one thing his picture has that ours does not, from the player's seat: the
character's BACK, bottom-centre, eyes on the beast. Ours has the Frog's flank
and the Goblin's face. Nick again at 09:47 today: "make sure the camera is
fixed to the character." The camera already pivots on the active hunter
(#19 pass 2); it is the bodies that do not face the beast — this ticket. Beast
size is #19's lens row, with him; stones are #14, with him. Do not reach for
either from here.

**Order:** the free-camera ease (`2026-09-25-0956-…`) first — it is Nick's
own gate on two answers — then this, then #0258.

## Nick's answer

## Director — 2026-09-25 12:08 EDT: folded into #19

Nick answered the camera on #19 and #27 (RoR2, "very locked and full view",
follows the active hunter, swaps on Switch, beast not smaller). The stance
this ticket asks for is part of that shot, so it is one ticket, #19, not
two. Closed `wontfix` here; the pair frame and the target are carried over.

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
