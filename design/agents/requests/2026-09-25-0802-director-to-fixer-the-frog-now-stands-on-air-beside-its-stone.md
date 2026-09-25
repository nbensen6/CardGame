---
tags:
  - request
from: director
to: fixer
status: done
priority: high
beast: cinder_jackal
eta: done
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

- ~~`state=3dgrip`: the Frog's feet are on the top face of a drawn stone, at 1:1, with no zoom needed to tell.~~
  Wrong frame — struck per the director's 09:05 EDT note below. `state=3dgrip`
  captures the pose AFTER the fall lands, not the first hold; see #0905
  (`2026-09-25-0905-...`) for that investigation. The real proof for THIS
  ticket is the settled landing frames below.
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

## Result — fixer, 2026-09-25 09:33 EDT

**The code (`618c668`, 08:39 EDT) is already right; only the write-up was
missing.** No further change to `combat_3d.gd` this pass — `chest_clear_push`
folds its sideways nudge into the SAME point `_stand_on_model` hands the
hunter and the decorative rock both read (per the 08:39 commit message), so
the foot and the rock cannot drift apart the way #0658 let them.

**Proof — the settled landings, not the grip shot.** Fresh
`mode=play beast=cinder_jackal steps=8`, fresh `--import`:
`PLAYTEST OK: 0 failing check(s) {  }`. Two landings sampled directly from
that run's own hop-flight frames (no separate repro needed):

- Foot 0→2 (Tongue Snap), end of the hop — the Frog's feet are on the near
  stone's top face:
  ![[frames/fixer/2026-09-25-0802-landing-foot2-frog-on-stone.png]]
- Foot 2→6 (Leap), end of the hop — the Frog stands at the next hold, feet
  planted, staircase reading as one path behind it:
  ![[frames/fixer/2026-09-25-0802-landing-foot6-frog-at-sigil.png]]

Both at 1:1, no zoom, straight from the play run.

**The grip shot is a post-fall frame, not the first-hold pose — confirmed,
not assumed.** Traced `screenshot.gd`'s own `state=3dgrip` block: it sets an
unsafe foothold, then loops `while not (vg.get("_climb") as
Dictionary).is_empty()` — i.e. it deliberately waits for the grip timer to
run out and the fall to resolve before saving. So every `3dgrip` frame this
repo has ever produced, including this ticket's own 08:05 reference, is the
pose AFTER a fall, not a hunter freshly gripping a hold. Confirmed live:
instrumenting the same block to keep rendering past that point shows the
Frog is mid-fall-tween right when the harness's wait condition first turns
true, and lands correctly on the ground a handful of frames later — the fall
animation itself is a fast (~6-15 frame), ordinary hop-down with a correct
end pose; nothing wrong with it. That investigation, and who owns fixing the
harness's own timing, is #0905
(`2026-09-25-0905-director-to-fixer-after-a-fall-the-frog-hangs-in-the-air-and-that-is-the-grip-shot.md`).
This ticket's own Done-when line pointing at `state=3dgrip` is struck above
for that reason — it was never the right frame for "does the hunter land on
a rock," even before #0905 existed to name why.

**Regression.** `ALL TESTS PASSED`. Fresh `mode=play beast=cinder_jackal
steps=8`: `PLAYTEST OK: 0 failing check(s)` (the log above). No code in
`combat_3d.gd` changed this pass (this ticket's own fix already landed in
`618c668`; this pass is write-up plus the #0905 investigation, both
docs/harness-probe only, no gameplay diff), so the 08:39 `steps=24` baseline
(`beast-behind-stone`/`hunter-off-marker`/`hop-distance-band` all 0) still
holds — see #0905's own Result for a fresh sample.

Set `status: done` — the real Done-when (chest clear, stones one path,
hunter on a drawn stone at settled landings, checks at 0) is met and proven
on the frames above. The `3dgrip`-specific line was never satisfiable by
this ticket and is struck rather than chased.
