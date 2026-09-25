---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: near stone fixed this run; confirming the 80-step regression and the Height-2 remainder next run
created: 2026-09-25T02:00
taken_by: fixer
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

## Result — fixer, 2026-09-25 02:55 EDT

**One number, `STONE_SWEEP_WIDTH` (`combat_3d.gd`), `HUNTER_HEIGHT * 3.0` (2.1)
-> `HUNTER_HEIGHT * 6.5` (4.55).** Mirrored the same change into
`playtest.gd`'s own copy of the const (checks 8/8c call `route_pos` directly
and would otherwise measure a route that no longer exists).

**How the number was picked — option 1, not option 2.** Rendered
`state=3d` at 3.0/3.5/4.0/4.5/5.0/5.5/6.0/7.0, and the full beast-half-width
offset (`_beast_box.size.x * 0.5` = 5.4, the exact value already tried once
and reverted before this ticket) again for the record, and looked at each one
at 1:1:

- 3.0-4.0 still graze or sit on the beast's front leg.
- 4.5 is the first one with a clean gap between the stone and the leg.
- 6.0 already pushes the stone half off the LEFT edge of a 1280-wide frame.
- 5.4 (the full beast-width offset) stretches the near stone into the exact
  "clay pot" silhouette the artist's rock mesh (#16) was built to fix — the
  stretch is a real cost, not a hypothetical one; a zoomed crop of it is
  indistinguishable from the original sphere-pot bug.

Landed on 6.5 (4.55 units): comfortably clear of the leg with margin (not
right at the 4.5 threshold), well short of the 6.0 edge-clip, and nowhere
near the 5.4 stretch. Never touched the camera, the rock mesh, or
`route_pos`'s own count of stones.

**Before / after, `state=3d`, 1:1, fresh `--import`:**

![[frames/fixer/2026-09-25-near-stone-before.png]]
![[frames/fixer/2026-09-25-near-stone-after.png]]

Whole beast — ears, eyes, chest, both front legs, both paws — now clear.
Frog and Goblin unchanged (didn't touch `GROUND_STANDOFF` or the camera).
The head still clears the intent tag (untouched code path; `state=3d` VIS
lines for both hunters print the same coordinates as the unmodified tree).

**Honest gap found, not hidden: a SECOND, smaller stone (Height 2) is now
visible on the chest, previously hidden behind the big Height-1 stone.**
Pulling Height 1 out from directly in front of the camera revealed that
Height 2's own foothold — same `route_pos` line, same rock mesh, much
smaller only because it's further from the camera — was *always* landing on
the torso; it just used to sit exactly behind the big stone from the
camera's point of view. This is not new geometry and not something this
change moved — `route_pos` still places Heights 2-4 on the SAME straight
line to the top hold that Nick's own 22:12 commit set up, and per the
ticket's own "what NOT to do," I didn't touch that line, its stone count, or
the hop tween. I checked whether widening `STONE_SWEEP_WIDTH` further would
also clear Height 2 (it gets 75% of whatever the near stone gets, since it's
lerped at `t=0.25`): at 6.0-7.0 the box is still on the chest while Height 1
is already clipping the frame edge, so one number can't clear both — Height
2 sits close enough to `top.x` (the sigil) that clearing it would mean
pushing the whole line's own near end far past where this ticket's "keep it
one placement number" scope reaches. Cropped detail, showing exactly what's
still there:

![[frames/fixer/2026-09-25-near-stone-height2-remainder.png]]

(That frame is a pixel-diff overlay against a stones-disabled render of the
same shot, used to confirm the near stone itself is genuinely gone from the
beast's rect and not just visually blended with it — red is only pixels that
differ from a no-stones baseline.)

This is much smaller than the original complaint (a fist-sized box on the
chest vs. "the only part of the Cinder Jackal a player can see is the head"),
and it's a pre-existing placement this ticket didn't create, only exposed.
Flagging rather than guessing whether it needs its own ticket — items 2-4 of
the route are still on the single straight line Nick asked for, and giving
each of them their own clearance number is a bigger, multi-point change than
"one placement number, one run."

**Proof.**
- `ALL TESTS PASSED` (`run_tests.gd`, headless, fresh `--import`).
- `state=3d`: both hunters' `VIS` lines print the same screen coordinates as
  the unmodified tree (431,502)/(1014,485) — the fix touches nothing but the
  near stone's own x.
- `state=3dgrip` (the hunter standing on the near stone mid-climb): the
  pre-existing `VIS FAIL hunter1: (546, 81)` baseline (confirmed via `git
  stash`) becomes `(569, 81)` after — same failure, same shape, x shifted by
  the same sweep this ticket asked for, not a new failure.
- Full `mode=play beast=cinder_jackal steps=80` regression, fresh `--import`:
  the fight played to a real ending (`Pounce` landed at step 30, screen
  changed to `Location3D`), and the ONLY failing check across the whole run
  is `hop-distance-band` at **124** — the exact pre-existing baseline count
  this ticket's own Done-when names. Zero `route-reversal`, zero
  `hunter-off-marker`, zero `script-error`, zero `intent-tag-vs-hunter`,
  zero camera-coverage failures. The x-only move to `route_pos`'s near end
  doesn't touch the ~82-unit-deep even-spacing math item 3 owns.

**Done-when, checked against the ticket's own bar:**
- Ears-to-paws rect has no stone from Height 1 — yes, confirmed by eye and by
  pixel diff. A different, smaller, pre-existing stone (Height 2) is still
  there — see above.
- Near stone still biggest, still the rock mesh — yes, untouched other than
  its x.
- `ALL TESTS PASSED` — yes.
- `hop-distance-band` count unchanged — confirmed: 124 before, 124 after.

Not marking this `done` — the Height-2 finding above is a real, open gap
against the literal "ears-to-paws rect contains no stone" bar, even though
everything else the ticket asked for is confirmed. Leaving `status: taken`
for the director to decide whether the Height-2 remainder needs its own
ticket or is small enough to accept, rather than closing it myself against a
Done-when I know isn't fully met.

## Director — 2026-09-25 02:58 EDT: Height 2 stays; this ticket's Done-when is met; close it and take the 20 m hops

Looked at the 02:49 tree at 1:1 before reading your note: the whole beast
is back, ears to paws, sky above, and the near stone is clear of it. That
is the visible half of #14 landed, and it is the first resting shot tonight
that matches the top line of Nick's drawing. Good.

**On the Height-2 stone on the chest: leave it.** Nick's drawing has small
white stones ON the beast — shoulder, arm, foot. A foothold on the body
where the route reaches it is the drawing, not a fault; the fault was a
stone between the camera and the beast, and that one is gone. No ticket.
Do not widen the sweep again to chase it, and do not give each rung its
own clearance number.

Your Done-when here is measured (beast rect clear, stone big, rock mesh,
tests, hop count unchanged) and every line is met, so set `done` yourself;
it is not Nick's call. Then the next thing, ahead of anything else
addressed to you, is the 20 m hops (the playtester's ticket, #14 item 3):
that is what Nick is waiting on. I have filed one small popup placement
fix to you as well; it says on its face to take it AFTER the hops.

![[frames/director/2026-09-25-0253-director-resting-shot.png]]
