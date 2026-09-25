---
tags:
  - request
from: playtester
to: fixer
status: done
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T11:42
taken_by: fixer
parent:
ask:
waiting: false
issue: 36
---

# The Frog hangs in open air at the sigil after a multi-height jump (Leap card)

**#36**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- After "Tongue Snap" (foot 0→2) then "Leap" (foot 2→6, skipping past the top named rung), the settled Frog hangs in open air near the top-right of frame, clear of the beast and every stone -- see the frame below, play size, no zoom needed.
- Repros the same way on a fresh 40-step baseline at foot 8 (step 2, another jump landing at/past the top).
- Not the already-fixed near-stone bug (#0658/#0802) -- this is a hunter climbing PAST the highest named rung via a multi-height card, not a single ordinary hop.
- My new `hunter-on-stone` check (#0803, `game/tools/playtest.gd`) catches this live: 0.0% of the pixels under the hunter's feet are stone or beast, both times, on a real, current, full 40-step run. 8 other real landings the same run (Height 4 through 16 across both hunters) read 90-100%, so this isn't the check being loose -- it's a real, isolated miss.

## What

`route_pos`/`_stand_on_model` place a hunter beyond the top named rung (any
foot ≥ `weak_point_height`) at the mesh-anchored sigil point. Whatever
happens when a SINGLE card jumps a hunter there directly from a lower foot
(here: foot 2 → 6 in one "Leap") isn't landing them at that point -- the
settled position measures nowhere near the sigil stone or the beast's own
mesh. An ordinary one-Height-at-a-time climb wasn't tested here; every
OTHER real landing in the same run (all one-Height hops) read clean.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=3 out=/tmp/pt

Step 1 (`report.md`/stdout: `hunter-on-stone -- foothold 6, 0.0%...`) is the
repro. `step_001.png` in that run's own `out=` dir is the play-size frame.

![[frames/playtester/2026-09-25-hunter-on-stone-sigil-floating-step001.png]]
Play size, real committed code: the Frog floating clear of the beast and
every stone, right after the Leap card lands it at foot 6.

## Done when

`hunter-on-stone` (check name in `game/tools/playtest.gd`) reads ≥15% at
every settled foothold on a full `mode=play` baseline, including a
multi-height jump straight to or past the top hold -- not just ordinary
one-Height climbs.

## Director — 2026-09-25 12:08 EDT: this is the narrow case of #14 — do it there

Nick, 10:45 EDT on #14: "make sure the last stone is at the sigil and the
character lands on each stone." That is this bug by name. Fixer: build the
five-stone routes on #14 and close both tickets on the same
`hunter-on-stone` run; do not patch the Leap landing separately first and
then rebuild the route under it.

Reproduced 12:00 EDT on `860bbfb`, a fresh `mode=play steps=24`: foot 6
after Leap 0.0%, foot 8 after Scramble 0.0%; foot 7 after Leapfrog 83.1%
and foot 11 after Hop 98.4% — so the every-rung push works and the landing
past the top rung is a separate miss, exactly as the playtester says. Play
size, the Frog hanging above the ear:

![[frames/director/2026-09-25-1152-director-foot6-after-leap-frog-above-the-ear.png]]

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result — fixer, 2026-09-25 13:00 EDT

Fixed as the same work as #14 (director's 12:08 EDT note above: "do not
patch the Leap landing separately first and then rebuild the route under
it"). Full writeup is on #14's own `## Result`
(`2026-09-24-1835-director-to-fixer-stones-in-front-nick-is-waiting.md`).

Root cause, in short: the decorative stones only ever existed at
`hop_subpoints()` sub-hop landings between named climb rungs. A card that
jumps a hunter straight to or past the top named rung in ONE play (this
ticket's Leap, foot 2→6) never passed through any of those sub-landings —
it settled at the correctly-computed sigil point, but with no stone built
there at all, so `hunter-on-stone` correctly read 0%. Rebuilding the
decorative stones to one-per-named-Height (Nick's #14 ask, independently)
puts a real stone exactly at that same top-hold point, closing this at the
same time.

**Proof, this exact repro:** fresh `mode=play beast=cinder_jackal steps=8`
on the fixed tree — `hunter-on-stone -- foothold 6, 22.2%` (was 0.0%
before this run, per the director's 12:00 EDT repro on `860bbfb`) and
`foothold 8, 22.2%` (this ticket's own "repros the same way... at foot 8").
Both clear the 15% floor. `ALL TESTS PASSED`, 0 `script-error`,
0 `route-reversal`, 0 `hunter-off-marker`.

![[frames/fixer/2026-09-25-1300-fixer-five-stone-route-at-sigil.png]]
Foot 6, right after Leap, real committed code: HUD reads "at the sigil",
no longer hanging in open air.
