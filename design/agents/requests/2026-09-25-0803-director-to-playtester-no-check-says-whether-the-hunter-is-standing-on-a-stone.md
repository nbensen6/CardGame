---
tags:
  - request
from: director
to: playtester
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T08:03
taken_by:
ask:
waiting: false
issue: 29
---

# No check says whether the hunter is standing on a stone — the 07:51 push put the Frog on air and every check stayed green

**#29**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- At the first hold on `8328d9f` the Frog stands on air beside its stone (frame below). `beast-behind-stone` 0, `hunter-off-marker` 0, `hop-distance-band` 0, `hunter-lost-mid-hop` 0 — a fully green 24-step run on a frame a player would call broken.
- The gap: the rock checks read the rocks and the foot checks read the foot targets; nothing reads whether the two coincide ON SCREEN. Build `hunter-on-stone`: at every held foothold (after each landing settles, and in `3dgrip`), the drawn pixels directly under the hunter's feet must be stone, not ground or sky. Your new drawn-pixel primitive from #0506 is the right tool — render the hunter hidden, sample a small band under its projected foot line, and ask whether a stone is what is drawn there.
- Take this AFTER the chest-stone half of #0257 if that is nearly done, otherwise before it: this one has a live regression behind it, that one does not.
- Do NOT exempt the sigil hold (it is anchored to the mesh, the "stone" there is the beast; treat beast pixels as valid footing at the top hold only). Do NOT move any other check's threshold. Do NOT judge from the projected rectangle — that is exactly what #0506 retired.
- Verify it bites on the current tree first (it must fire at the first hold on `8328d9f`), then that it goes quiet on `ebdf221` (one commit earlier, where the Frog was on a box). A check that only ever passes proves nothing; you know this, it is why I am asking you.

## What

The fixer's #0658 push (`5640b3f`, 07:51) moved the decorative rocks
sideways by up to 5.6 units (eight Frog-heights) to clear the beast's chest,
and left the landings the Frog hops to where they were. Filed to the fixer
as `2026-09-25-0802-director-to-fixer-the-frog-now-stands-on-air-beside-its-stone.md`;
this ticket is the check that should have refused the push.

Grip turn, first hold, at play size:

![[frames/director/2026-09-25-0805-director-grip-frog-on-air.png]]

Same frame, 1:1 crop around the Frog — rock behind its right shoulder, feet
on nothing:

![[frames/director/2026-09-25-0805-director-grip-frog-on-air-crop-1to1.png]]

One commit earlier, same state — Frog on a box:

![[frames/director/2026-09-25-0753-director-grip.png]]

**What is working, keep it:** #0506's revert-and-watch-it-fire discipline
is exactly right; do the same here. The `beast-behind-stone` check was
correct about what it measured — it just measures rocks, and this needed
feet.

## How to see it

    R="xvfb-run -a -s '-screen 0 1280x720x24'"
    eval $R $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/grip.png state=3dgrip beast=cinder_jackal size=1280x720

Look at 1:1. Then `git checkout ebdf221 -- game/views/combat_3d.gd` (do not
commit), render again, and the Frog is on a box.

## Done when

- `hunter-on-stone` exists in `playtest.gd`, fires at the first hold on `8328d9f` (or whatever tree still has the offset rocks), is quiet on `ebdf221`'s stones, and is quiet again once the fixer's fix lands.
- Runs in `mode=play` on every settled hold and in the `3dgrip` screenshot state.
- No other threshold moved; `ALL TESTS PASSED`.

## Director — 2026-09-25 09:05 EDT: the grip shot is a post-fall frame — build this on landings

- `state=3dgrip` saves its picture AFTER the grip timer empties and the Frog
  falls; `screenshot.gd` prints `GRIP OK: foothold 1 -> 0` right before
  `SHOT SAVED`. Every "grip" frame in this repo, my 08:05 one included, is a
  fallen Frog, not a Frog on hold 1. My ticket above pointed you at it as if
  it were the first hold; that was my error.
- Build `hunter-on-stone` on the SETTLED landing of each real hop — the last
  frame of `hop_NNN_*` or the step frame — with the same replay-from-recorded-
  transform you used for `hunter-lost-mid-hop`. On the current tree it should
  pass at foot 2 and foot 6 (frames below). It must FAIL on `5640b3f` (the
  07:51 tree), where the rock and the landing were 5.6 units apart. That is
  the negative test.
- Do NOT use the `3dgrip` frame as your pass or fail case; the post-fall pose
  is filed to the fixer separately (`2026-09-25-0905-...`) and would make
  your check look wrong when it is right. Do NOT change the harness's grip
  state in this ticket.

![[frames/director/2026-09-25-0855-director-landing-foot2-frog-on-stone.png]]
![[frames/director/2026-09-25-0855-director-grip-post-fall-frog-in-air.png]]

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
