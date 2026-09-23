---
tags:
  - request
from: nick
to: fixer
status: open
priority: high
created: 2026-09-23T14:23
taken_by:
---

# Stones, camera and hunter spacing at the Cinder Jackal

## What I want

Fix the placement of the stones. and the camera angle should be changed locked
to the character in 3rd person. move the characters away from the titan.

**The camera, clarified (Nick, 2026-09-23 14:35 EDT):** in normal play the
camera is LOCKED in third person on the active hunter — it does not drift back
to the wide shot and the player cannot leave it. A free camera is fine as a
LOCAL dev tool (the drag-to-orbit / freecam path that exists today), just not
something normal play can end up in.

Note before you start: the resting camera became over-the-shoulder earlier
today (`d99a80d`, SHOULDER_TRUCK / SHOULDER_AIM in `combat_3d.gd`). That is the
shot he wants held — this request is about it being held ALWAYS, plus the two
staging problems around it. Do not rebuild the shot itself.

## The stones: agree them with the playtester first

Nick, 2026-09-23 14:40 EDT. He has also asked the **playtester** to design the
climbing route — where the stones go, how many, how far apart, at what heights,
and what makes a climb feel continuous
(`2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`).

So do not just move the stones and call it done. **Write down what YOU think
the placement should come out as, and send it to the playtester**, before or
alongside your own work:

- File a request `to: playtester` with your proposed rule in it — the actual
  rule, in numbers ("a stone sits N units in front of the climb point it
  serves, offset M to the hunter's side", or whatever you conclude), plus what
  in the code forces it and what the code cannot currently express.
- You know things it does not: where `stone_point` puts a stone today and why,
  what `_build_float_stones` can and cannot place, what the jump arc will and
  will not reach. That is the half of the answer it cannot see from playing.
- It knows things you do not: whether the result reads as a route.

Converge on one rule between you, then build it. If you disagree, say so in
the note and file `to: nick` — do not split the difference silently.

The camera and hunter-spacing halves of this request are yours alone; only the
stones need agreeing.

## How to see it

click fight now on cinder jackal

## Done when

all stones are spaced in front of the beast so you can climb upwards and
towards the top sigil of the beast.

- The camera is over-the-shoulder on the active hunter for the whole fight,
  including after End Turn and after a switch, with no way to leave it in
  normal play.
- The hunters do not start on top of the beast — there is space between them
  and it.
