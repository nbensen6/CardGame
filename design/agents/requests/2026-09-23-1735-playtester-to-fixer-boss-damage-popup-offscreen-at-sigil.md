---
tags:
  - request
from: playtester
to: fixer
status: open
priority: normal
created: 2026-09-23T17:35
taken_by:
ask:
waiting: false
---

# A hit landing on the boss itself pops its damage number off the top of the screen at the sigil

## What I need

- A damage number for a hit that lands ON THE BOSS (not a hunter — that
  case was already fixed, `2026-09-23-0430-...`) needs to stay on screen
  when both hunters are "at the sigil" — the close-in camera framing this
  fight's own climb ends on.
- Reproduces 3/3 runs, same step, same on-screen position each time — not
  a flake.

## What

Checklist item 1 covers this ("a card... does something on the beast — a
damage number... where it happened"), and the existing
`damage-popup-offscreen` check (added for the earlier hunter-popup bug)
just caught a second, different case: a **boss**-damage popup going
off-screen. Until today this code path had never actually been exercised
by the playtest bot — every timed-hit-circle attempt was fumbling (see
`playtest.gd`'s own new comment on `_drive_timing`, fixed this run), so
the boss had never taken a point of damage in any prior playtest run.
Once hits started landing for real, this showed up immediately.

Three separate 80-step runs, all `mode=play beast=cinder_jackal`, all hit
this at **step 19**, same card, same on-screen position within a couple
pixels:

    FAIL [step 19] damage-popup-offscreen: play 'Tongue Snap' [timed]
    (hunter 0) at (376.0, 475.0): a damage number projects to
    (676.0, -5.0), off the (1280.0, 720.0) screen entirely

(676,-5 / 675,-3 / 676,-5 across the three runs — same spot, off the top
edge by 3-5px, not hundreds like the old hunter bug.) Both hunters are
"at the sigil" when it fires — the frame right after (popup already
faded, but shows the exact camera framing it happened under):

![[frames/playtester/2026-09-23-boss-damage-popup-offscreen-sigil.png]]

**This is probably not the same root cause as the hunter-popup bug.** That
fix's own write-up says the boss-scaled rise distance (`reach * 0.22`,
sized off the Titan's own height) is *correct* for a hit landing on the
beast itself — the bug there was hunter-sized hits inheriting the same
Titan-scale rise. Here the hit really is on the beast, so the rise amount
is presumably right; the likely culprit is the **camera**, not the
popup — the sigil shot is a tight close-up (see the frame: the jackal's
head/ears fill most of the top of the screen already), so a boss-scaled
rise that would clear the frame fine from the game's normal wider shots
carries the label off the top of THIS specific close, near-vertical
framing. Worth checking whether it also fires at other close-in camera
states, not just the sigil, once you're in the code.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=30 out=/tmp/pt

Fails at step 19 every time on the current tip.

## Done when

A fresh `mode=play beast=cinder_jackal steps=30`+ run reaches the sigil
with 0 `damage-popup-offscreen` fails.

## Nick's answer

## Result
