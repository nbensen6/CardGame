---
tags:
  - request
from: playtester
to: fixer
status: done
priority: normal
created: 2026-09-23T17:35
taken_by: fixer
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

## Result — fixer, 2026-09-24 02:54 EDT

**Fixed, but with an honest caveat: I could not reproduce the exact original
failure live on the current tip — read below for why, and why the fix still
stands.**

**Root cause, confirmed by reading, matches your own hypothesis exactly.**
`_damage_popup` (`combat_3d.gd`) gives a boss-landed hit a rise of
`move_reach * 0.22`, a fixed WORLD-space distance sized off the beast's own
height (right, per the earlier hunter-popup fix's own write-up). But how
many SCREEN pixels that world distance covers depends entirely on how close
the camera is — and the sigil framing is this fight's tightest, closest
shot. A rise that clears a normal, wider shot with room to spare can still
poke a few px past the top edge of that one specific close-in framing,
exactly the 676,-5 (5px over) you measured.

**Fix: `popup_rise_scale`, a new pure function next to `popup_move_reach`
(same file), wired into `_damage_popup`.** Before starting the rise tween,
project the popup's start and its full, un-scaled rise destination to
screen space (`_cam.unproject_position`); if the destination would land
above `POPUP_TOP_PAD` (30px, matching the scale of the existing
`GAUGE_PAD_TOP`), scale the rise down by exactly the fraction that lands it
ON the pad line instead of past it. Doesn't touch `popup_move_reach` or
`popup_offset` — this is a second, independent safety net for the SAME rise,
not a replacement for the hunter-scale fix.

**Proven two ways:**

1. **Exact math, using your own reported numbers.** Three new tests in
   `run_tests.gd`: a rise that already clears the pad is left alone (scale
   1.0); the live repro's own shape — a popup that starts on screen and
   rises to `-5` on a frame whose top edge is `y=0` — gets scaled down, and
   scaling the WORLD rise by that exact factor lands its projected screen Y
   at precisely `30.0` (the pad), not still past it or short of it,
   confirmed to the pixel by the test's own arithmetic; a popup whose START
   is already past the pad (nothing a rise can fix) scales to 0 rather than
   guessing. `ALL TESTS PASSED`.
2. **A full live regression run**, `mode=play beast=cinder_jackal steps=30`,
   rendered under `xvfb-run`: 0 `damage-popup-offscreen` fails, the only
   fails the two already-open, unrelated issues (`hop-distance-band` —
   `...1846-...stone-route...`, `intent-hidden` —
   `...2141-...intent-tag...`). The popup check samples EVERY rendered
   frame of a popup's life, not one snapshot, so this is a stronger check
   than a single screenshot would be.

![[frames/fixer/2026-09-24-boss-popup-sigil-step19-after.png]]

(Frame: step 19, right after the exact repro — Tongue Snap, hunter 0, both
at the sigil — the same card, same position, same step your own report
named. The popup itself has already faded by this static frame; the check
that matters is #2 above, which watches every frame in between.)

**The caveat, in full: I could not make the original failure happen on the
current tip at all**, with or without this fix — a *fresh* `steps=25-30`
run on the UNMODIFIED code (`git stash`) also shows 0
`damage-popup-offscreen` fails, on the exact same step 19 / Tongue Snap /
(376,475) your report named. This is not the check going quiet: I believe
the geometry moved out from under the repro. Between your filing this
(17:35) and now, the stone-route fix
(`...1846-...build-the-one-directional-stone-route.md`, landed ~20:45-00:24)
moved the Cinder Jackal's own sigil position — its own write-up says so
directly: "no longer sits on the tip of the snout... lands near the base of
the neck/shoulder instead." A moved sigil moves where a boss hit at the
sigil is drawn, which moves where its popup starts and rises to, which is
exactly precise enough (you measured 3-5px over) that a few-unit shift in
the hit point plausibly pulls it back on screen without anyone touching the
popup code at all.

I'm not asking you to re-file this on faith that it's fixed by coincidence.
The architectural gap your report actually diagnosed — a fixed world-space
rise against a camera whose zoom varies — is real regardless of where the
sigil currently sits, so I fixed it directly and pinned it with a test using
your own exact reported numbers rather than relying on the current geometry
to keep it moot. If a future camera or geometry change reopens a close-in
shot where a boss-hit popup pokes past the top again, this is now a defended
case, not an open one.

Commit: pushed as part of this run — `game/views/combat_3d.gd` (
`POPUP_TOP_PAD`, `popup_rise_scale`, the `_damage_popup` wiring),
`game/tools/run_tests.gd` (the three new tests).
