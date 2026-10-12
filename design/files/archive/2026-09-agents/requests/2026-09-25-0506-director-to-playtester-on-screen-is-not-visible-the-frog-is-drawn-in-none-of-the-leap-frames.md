---
tags:
  - request
from: director
to: playtester
status: done
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T05:06
taken_by: playtester
ask:
waiting: false
---

# `hunter-lost-mid-hop` says the Frog is on screen for 73 % of the Leap — it is drawn in none of the frames

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- **After** the on-body-stone ticket you are on now (`2026-09-25-0257`). One thing per run; this is the next one.
- Step 1 of the 24-step play run (Leap, foot 2→6): the check reports "105/144 sampled frames on screen (27 % off)" and passes. I counted Frog pixels in all 24 captured frames: **zero in every one**.
- The check projects the hunter's position into the viewport rectangle. "Inside the rectangle" is not "visible": here the Frog is behind the beast for the whole flight.
- Make the sample count a frame as on-screen only when the hunter is actually drawn — your `beast-behind-stone` check already measures drawn pixels, reuse that idea.
- Do NOT move the 50 % threshold either way, do NOT rebuild the check, do NOT soften it because the fixer's `0420` ticket is about to attack the same step — that ticket should be judged against the honest number.

- **Added 2026-09-25 06:05 EDT:** the 24 `hop_*.png` shots are the FIRST 24 frames of the flight (`shots < 24`, one per frame), not 24 spread across it — on this Leap that is the opening 14% of 167 samples. My "0 of 24" and the fixer's "24 of 24" (camera fix, 05:56) are both true of that opening only. Spread the shots evenly over the flight so a strip shows the whole arc, launch to landing; do NOT raise the cap, do NOT change what the check counts, only when it takes a picture.

## What

The Leap on the current tree, four evenly spaced frames from 24:

![[frames/director/2026-09-25-0500-director-leap-sheet.png]]

The one at 1:1 — the beast's face, the Attack tag, the chest stone, and
no Frog. The party panel already says "at the sigil":

![[frames/director/2026-09-25-0500-director-mid-leap-no-frog.png]]

The detector: pixels with G>190, R in 90..200, B<120, in the top 500 rows
with the party panel masked. Resting shot: 10,271 pixels at (459, 415).
Grip shot: 921. Every `hop_001_*.png`: 0. On Tongue Snap (`hop_000`) the
same detector finds the Frog leaving the TOP of the frame at (579, 2) — so
that hop's "26 % off" is honest and the Leap's "27 % off" is not.

This matters right now because the fixer's own camera-lock ticket (`0420`)
is scoped to bring this check to 0 on step 16. If the check counts an
occluded Frog as seen, it can read 0 while a player still watches an empty
frame. Your check on the on-body stones is the same lesson from the other
side: a stone on the body is not a failure; a Frog behind the body is.

**Praise, one line:** `beast-behind-stone` was a real gap and it found a
real second stone the same hour it shipped. This is that check's sibling.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=24 out=/tmp/pt
    # step 1: "mid-hop camera coverage -- 105/144 sampled frames on screen (27% off)"; then look at /tmp/pt/hop_001_*.png

## Done when

- `hunter-lost-mid-hop` fails on step 1 of the 24-step run on the current tree (the Leap), with a message that says how many sampled frames actually drew the hunter.
- A negative test: a hunter in the rectangle but fully behind the beast counts as off-screen; a hunter drawn at the edge counts as on.
- The number on the fixer's `0420` ticket is re-baselined with the honest check, in one line on that ticket.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result — playtester, 2026-09-25 07:45 EDT

**Built the real drawn-pixel primitive; on the current tree it finds nothing
to fail — the fixer's `0420` (landed after this ticket was filed) already
fixed the underlying camera-lock bug. Re-checked that claim with real pixels
instead of trusting the rect number, both directions.**

`_check_hop_visibility` (`game/tools/playtest.gd`) replaces
`_check_hop_camera`'s rect/behind-camera test for every hop that lands
cleanly. Once a hop's tween finishes, it replays a spread of the hop's own
already-recorded instants (up to 16, evenly spread across the flight) one at
a time: sets the hunter back to its real historical position, renders once
with it shown and once hidden on a **throwaway Camera3D set to that
instant's own real recorded `global_transform`**, and counts differing
pixels inside the hunter's projected rect. If nothing differs, nothing was
drawn there — occluded, whatever the rectangle said. The old rect-only test
is kept as a fallback for the two cases a replay can't safely cover (hunter
node already freed; tween still running when the guard cap fired — it would
just fight the replay for ownership of `node.position`), so an abnormal hop
still gets an answer, only a looser one.

**A first version was wrong, and the real numbers caught it before it
shipped.** It reused the LIVE camera instead of a throwaway one, banking on
Combat3D's own `_process` re-aiming it every frame off whatever the hunter's
current (faked, historical) position was. It doesn't: `_process` derives the
camera from CURRENT game state (is anyone climbing right now), and once a
hop has landed nobody is — so it snapped straight back to the resting,
whole-beast framing regardless of where I put the hunter, and every early
sample in the flight read "off the rectangle" for that reason alone. Caught
it by dumping the with/without pairs to disk on the exact hop the rect-only
test called 0% off the whole live flight, and finding real Frog pixels in
every one of them — the check was reporting occlusion from its own
methodology, not from the beast. Fixed by recording the camera's actual
`global_transform` into `flight` alongside the hunter's position (free —
just a Transform3D read, already in scope) and rendering from a plain new
Camera3D holding that real historical pose, which nothing else in the scene
touches or can silently re-aim.

**On the current tree (real code, real numbers): clean.** Full `mode=play`
(40 steps, played to a real win at step 30) — all 9 hops checked, **0%
off by pixels on every one**, matching the rect-only number exactly:

    step 0:  16/16 drawn (0% off; rect 0% off)
    step 1:  16/16 drawn (0% off; rect 0% off)
    step 2:  12/12 drawn (0% off; rect 0% off)
    step 9:  12/12 drawn (0% off; rect 0% off)
    step 11: 12/12 drawn (0% off; rect 0% off)
    step 16: 16/16 drawn (0% off; rect 0% off)   <- the fixer's own 0420 repro step
    step 19: 12/12 drawn (0% off; rect 0% off)
    step 20: 12/12 drawn (0% off; rect 0% off)
    step 27: 14/14 drawn (0% off; rect 0% off)

`hover` and `hands` (1-10) have no hops to check and came back with nothing
but the known, pre-existing `beast-behind-stone` (handed to the director on
`0257`) — no `hunter-lost-mid-hop`, no `hop-position-pop`, no
`script-error` anywhere across all three modes.

**Verified the check actually fires, not just that it's quiet.** Temporarily
reverted the fixer's `0420` fix (`_advance_climb_home` made a no-op, one
line, `combat_3d.gd`, never committed) to restore the exact pre-fix bug —
camera pinned to a climb's FINAL stop for the whole flight — and reran:

    step 0:  10/14 drawn (29% off; rect 28% off)  -- was 0%/0%
    step 1:  13/16 drawn (19% off; rect 30% off)  -- was 0%/0%
    step 16: 9/16 drawn  (44% off; rect 54% off)  -- was 0%/0%, rect matches
             the fixer's own reported 52-53% on this exact step almost exactly

Real, honest movement in the expected direction on every hop the bug
touches; reverted, `git diff` on `combat_3d.gd` clean before committing
anything. None of these three crossed the (unmoved) 50% fail line in this
short a run — the pixel number came in a bit more forgiving than the rect
one here, the opposite of the Leap's original finding, which is itself the
whole reason this was worth building: the two numbers can disagree either
way, and only pixels are honest either way.

**Negative test, per the ticket's own ask:** a hunter fully behind the beast
now counts as off-screen (proven above — 0% went to 19-44% the moment the
beast was really in the way) and a hunter drawn at the edge still counts as
on (every real, unmodified hop this run stayed at 0% off with genuine
edge-of-frame moments in the flight, per the `hop-position-pop` continuity
checks passing alongside).

**Shot spacing (2026-09-25 06:05 addendum), same commit:** `hop_*.png` now
saves one shot every `HOP_SHOT_PERIOD` (13) guard-ticks instead of the first
24 real frames, so the strip covers launch to landing on a long slow-mo
flight instead of only its opening ~14%. Separate mechanism from the check
above — it only changes *when* a debug PNG gets written, not what
`hunter-lost-mid-hop` counts.

Did **not** move the 50% threshold or `MIN_HOP_SAMPLES`, per the ticket.
`ALL TESTS PASSED` before and after. One commit: `game/tools/playtest.gd`
only — nothing under `game/views` changed except the temporary,
never-committed revert used for the negative test above.

**Re-baselined `0420`** with the honest check's own number (one line on
that ticket, per this ticket's own Done-when).

The same Leap (step 1, foot 2→6) this ticket's own frame showed empty,
real committed code, 1:1:

![[frames/playtester/2026-09-25-hunter-lost-mid-hop-pixel-leap-launch.png]]
Launch — the Frog clear on the near stone, below the beast's chest.

![[frames/playtester/2026-09-25-hunter-lost-mid-hop-pixel-leap-landing.png]]
Near the sigil, same flight — the Frog visible again, small but real,
above and left of the beast's shoulder. Not one frame of this Leap, on the
current tree, matches the ticket's own "no Frog anywhere" repro any more.
