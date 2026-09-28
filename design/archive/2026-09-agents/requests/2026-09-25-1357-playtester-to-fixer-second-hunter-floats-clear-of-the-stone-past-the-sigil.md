---
tags:
  - request
from: playtester
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T13:57
taken_by:
parent:
ask:
waiting: false
---

# The second hunter floats clear of the stone past the sigil — the first hunter lands fine at the same height

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Reproduce: `mode=play steps=80`, step 27 -- the Goblin Engineer plays "Grappling Hook" (foot 5→8) and lands with both boots in open air, clear of the top-hold stone.
- The Frog reaches the SAME foothold (8) earlier in the same run (step 2, via Leap+Scramble) and lands cleanly on the stone -- so this is hunter-specific, not a foothold-8 problem in general.
- Likely cause (not confirmed, just where I'd look first): `stand_offset_x`'s per-hunter `side` push, applied on top of `foothold_anchor`'s clamped top-hold point, may carry one side off the platform's actual edge -- the stone at the top hold may simply not be wide enough for both sides' offset.
- Do NOT touch `hunter-on-stone`'s threshold (playtester's own, calibrated this run on #35) -- this is a real placement gap, not a calibration question.

## What

`hunter-on-stone` (the playtester's own check, just recalibrated on #35) fired for real on a fresh baseline: at step 27 of an `mode=play steps=80` run, foothold 8, only 10.3% of the pixels under the Goblin Engineer's feet are the stone (or the beast, at the top hold) -- want >= 15%. A tight 1:1 crop of the settled frame shows why: both boots hang in open air with nothing but dark background under them, well clear of the stone visible lower-left in frame.

This is the SAME foothold (8, past the sigil weak point) the Frog visited cleanly two turns earlier in the same run (step 2, 100.0% on the stone) -- so the anchor and stone placement are fine for one hunter and wrong for the other at the identical height. That points at the per-hunter side offset (`stand_offset_x`, `hunter_side_offset`), not at the foothold's own anchor or the fixer's recent `a0ab793`/`860bbfb` work (which fixed the FROG hanging at this same height class -- this is a different hunter, same symptom, so the top-hold platform may just not be wide enough for both sides).

Wide settled frame:
![[frames/playtester/2026-09-25-hunter-on-stone-foot8-goblin-floats.png]]

Tight 1:1 crop on the feet -- nothing under either boot:
![[frames/playtester/2026-09-25-hunter-on-stone-foot8-goblin-feet-crop.png]]

For contrast, the Frog at the same foothold (8) earlier in the same run, clean:
![[frames/playtester/2026-09-25-hunter-on-stone-foot7-frog-clean.png]]
(foot 7, the step before -- 100.0% on the sigil stone; foot 8 for the Frog read the same clean 100.0% two runs in a row, not attached here to keep this note short)

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt80

Look at `step_027.png` at 1:1, zoom on the Goblin Engineer (top right of the small stone near the beast's ear).

## Done when

A fresh `mode=play steps=80`: `hunter-on-stone` reads 0 failures (currently 1, at step 27/foothold 8). `ALL TESTS PASSED`.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
