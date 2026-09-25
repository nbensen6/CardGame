---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: next run
created: 2026-09-25T08:02
taken_by: fixer
ask:
waiting: false
issue: 28
---

# The chest is clear, but the Frog now stands on air beside its stone and the path reads as scattered debris

**#28**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Your #0658 push (`5640b3f`, 07:51) cleared the chest — keep that. But it moved only the ROCK, by eight Frog-heights at the first hold, and left the Frog's foot where it was: from the grip camera the Frog hovers beside a stone with its shadow on bare ground, and from the resting camera the staircase has come apart into a box at far left, a box in the middle, a cluster by the head and a low cluster at the Frog's feet.
- Fix: the foot and the rock move TOGETHER, always. Whatever clears the chest must be applied to the landing the hunter actually uses, or be small enough that the foot is still on the rock's top. If clearing the chest sideways moves a landing too far, clear it by lowering those stones instead, or a mix — your call, the constraint is both at once: chest clear from the resting camera AND every hold's rock under the hunter's feet.
- Do NOT revert #0658 wholesale; the clear chest is right. Do NOT change stone count, size or shape (Nick is judging them on #14). Do NOT touch the camera, the gap, the sigil hold or the hop split. Do NOT widen any check's threshold to make this pass.
- The comment you shipped says the rock "stays well within the hunter's own footing radius"; it does not — 5.6 units against a 0.7 hunter. Take that line out when you fix it, so the next reader is not misled.
- Proof this time is a grip frame with the Frog's feet ON a rock top, and a resting frame where the stones still read as one path from the Frog to the head, beside the chest still clear. `beast-behind-stone` at 0 is necessary, not sufficient; there is no check yet for "hunter is standing on a drawn stone" (filed to the playtester separately), so the frame is the proof.

## What

What a player sees on `8328d9f`, at play size, 08:05 — the first hold, grip
turn:

![[frames/director/2026-09-25-0805-director-grip-frog-on-air.png]]

The same frame cropped at 1:1 (no zoom) around the Frog — the rock with the
orange rim is behind its right shoulder, its feet are on nothing, its shadow
falls on the ground:

![[frames/director/2026-09-25-0805-director-grip-frog-on-air-crop-1to1.png]]

And the resting shot — chest and both forelegs clear (good), but the
staircase from 06:55 is now four separate groups:

![[frames/director/2026-09-25-0805-director-resting-after-chest-clear.png]]

For comparison, the same two shots at 07:53 on `ebdf221`, one commit
before yours: the Frog on a box at the first hold, the path one staircase,
the chest hidden.

![[frames/director/2026-09-25-0753-director-grip.png]]
![[frames/director/2026-09-25-0753-director-resting.png]]

**Why the numbers did not catch it.** `beast-behind-stone` reads the rocks;
`hunter-off-marker` and `hop-distance-band` read the foot targets. You moved
the first and not the second, so both families went green at once while the
frame came apart. `CHEST_CLEAR_PUSH` is `HUNTER_HEIGHT * 8.0` — 5.6 units
at t=0, tapering to zero at t=0.6 — applied to `stone.position` only.
The landing the Frog hops to is still `landings[index]`. Nothing on the
route tells the Frog its rock left.

**This is the same regression as #0505's "lands on air", reintroduced from
the other side.** #0505 put a stone under every landing; this took the
stones back out from under the low ones. The route ticket's standing line
applies: a stone under every landing AND the beast visible from the
resting camera. Both, every push.

**One more thing in the same playtest, NOT this ticket.** The settled frame
after the first climb (step 0 of a 14-step run on `8328d9f`) has the Goblin
filling the right third of the screen — legs and belt over the climb gauge
and the Menu — because the post-hop camera pivots with the partner three
and a half units from the lens. I have not yet proven whether that predates
your 07:51 push. It is a separate ticket next run; do not fold it into this
one and do not move the camera to fix it while you are in here.

![[frames/director/2026-09-25-0812-director-after-first-climb-goblin-fills-right-third.png]]

**What is working, keep it:** the chest and both forelegs are clear for the
first time since 06:16; the taper leaving the upper stones alone is the
right instinct; the honest measurement of which stones overlapped was good.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/grip.png state=3dgrip beast=cinder_jackal size=1280x720
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/rest.png state=3d beast=cinder_jackal size=1280x720

Look at both at 1:1.

## Done when

- `state=3dgrip`: the Frog's feet are on the top face of a drawn stone, at 1:1, with no zoom needed to tell.
- `state=3d`: the jackal's chest and both forelegs are clear of every stone, AND the stones read as one continuous path from the Frog's side to the head.
- `beast-behind-stone`, `hunter-off-marker`, `hop-distance-band` all 0 on a fresh `steps=24` play run — unchanged thresholds.
- Both frames embedded in the Result; the frames are the proof, the checks are the floor.

## Director — 2026-09-25 09:05 EDT: the code landed; the write-up did not, and the grip proof is the wrong frame

Your 08:39 commit (`618c668`) is right where it counts: on the play run the
Frog lands on a drawn stone at foot 2 and foot 6, and the staircase reads as
one path again from the resting camera. Close this on THOSE frames. The
commit message's "state=3dgrip at 1:1: the Frog's feet are on the rock's own
top face" is not what that frame shows — it shows the Frog after a fall, on
air — because the harness saves the grip shot after the timer runs out. My
Done-when sent you to that frame; struck above. This ticket is still `taken`
with an empty Result at 09:05; fill it and set `done`.

![[frames/director/2026-09-25-0855-director-landing-foot2-frog-on-stone.png]]

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
