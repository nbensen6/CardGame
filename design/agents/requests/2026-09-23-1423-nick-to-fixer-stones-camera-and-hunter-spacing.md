---
tags:
  - request
from: nick
to: fixer
status: wontfix
priority: high
created: 2026-09-23T14:23
taken_by: fixer
issue: 3
---

# Stones, camera and hunter spacing at the Cinder Jackal

**#3**

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

## Result — fixer, 2026-09-23 17:38 EDT

**Camera and hunter-spacing (mine alone): done.** Stones: not built yet —
see below, gated on your answer to
`2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`.

**Camera locked.** The resting shot was already auto-following the active
hunter over-the-shoulder (`_process`'s `want_ots` — unconditional on
`_focused`, not on whether you'd touched anything). The ONLY way out of it
was the free camera: drag to orbit, right/middle-drag to pan, wheel to zoom,
WASD/QE to fly, all live in normal play with nothing gating them. Gated all
four behind `OS.is_debug_build()` — the same switch `game/ui/console.gd`'s
own doc comment already names for exactly this case ("when there is a build
to ship, gate it on OS.is_debug_build()"). True in the editor and every
dev/test run (verified: prints `true` here under `--headless`), false only
in an exported Release template — so it stays a working LOCAL dev tool
(proven: `state=3dfreecam` still drags after the change, same as before)
and is simply absent from anything actually shipped. Two new tests pin the
gate itself isn't inverted (`free_camera_allowed`).

**Hunter spacing fixed.** Root cause: the ground-standoff distance
(`GROUND_STANDOFF`, `_place_hunters`) was computed off the beast's FULL
nose-to-tail `size.z`, which double-counts a long quadruped's tail (the
Cinder Jackal's box is symmetric about the origin, so `end.z` already
reflects the whole length once) — so the intended standoff came out at
36.95 units, but the arena itself (`_arena_r`, from `_show_beast`) was sized
only off the beast's own footprint (20.45) and its own clamp
(`_arena_r * 0.86` = 17.59) silently overrode the standoff back down to a
**1.1-unit real gap** — the jackal's legs read as standing on top of the
hunters. Fixed with one shared rule, `ground_standoff_for(front_edge)`,
called from both the arena sizing and the ground clamp, so the arena can
never again be too small to hold the standoff it asks for. Live now:
**9.5-unit gap** (front edge z=16.49, hunters at z=26.72). Before/after,
same camera, same beast:

![[frames/fixer/2026-09-23-hunter-spacing-before.png]]
![[frames/fixer/2026-09-23-hunter-spacing-after.png]]

Proof: 5 new unit tests in `run_tests.gd` (`ground_standoff_for` grows with
the front edge, matches the live jackal numbers exactly, survives the arena
clamp it used to lose to; `free_camera_allowed` pins the debug-build gate
both ways). `ALL TESTS PASSED`. Rendered `state=3d` before and after (above)
and re-ran `state=3dfreecam` to confirm the dev drag tool still works
unchanged. Commit: see `game/views/combat_3d.gd`,
`game/tools/run_tests.gd` in this push.

**Stones: not built.** Per this request's own text ("converge on one rule
between you... do not just move the stones and call it done") I read the
placement code and the Cinder Jackal's own climb-anchor data and sent the
concrete numbers and code paths to the playtester —
`2026-09-23-1736-fixer-to-playtester-stone-route-technical-numbers.md` — to
sit alongside its own proposal in `...-1434-...`. I agree with the
playtester's rule; nothing to arbitrate. That note is still `to: nick`,
unanswered, and says explicitly the build only starts once you say yes —
so I have not touched the climb anchors or stone code itself this run.
Once you answer 1434, whoever picks this back up has the arc-distance
band, the stone/anchor split, and the exact `ai_beast.py` lines the sigil
placement would need to change, already gathered.

Leaving this request `taken` rather than `done` — the camera and spacing
halves are finished and proven above, but the stones half is still
outstanding on your answer elsewhere.

## Result — director, 2026-09-24 21:58 EDT

**Closed as superseded, under #18's authority.** The camera and spacing
halves were finished by the fixer on 2026-09-23 17:38 (above); the stones
half never started here. Every part of this ticket now lives in one place:
the stones and the gap in **#14**, the locked third-person camera in **#18**
(step 3, after #14), and Nick's 19:48 ask for a Dev/Player camera switch in
`2026-09-24-2155-director-to-fixer-player-camera-toggle-...`. Nothing was
dropped; this row just stops showing a day-old `taken` beside the live one.
