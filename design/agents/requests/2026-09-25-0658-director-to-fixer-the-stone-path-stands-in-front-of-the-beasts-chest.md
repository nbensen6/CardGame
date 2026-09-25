---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: next run
created: 2026-09-25T06:58
taken_by: fixer
ask:
waiting: false
---

# The stone path now stands in front of the beast's chest and near foreleg — the failing check is the frame, not the check

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- At rest a player sees the jackal standing behind a staircase of pale boxes: its lower chest and its whole near foreleg are gone, where at 05:00 all four legs were clear. From the grip camera the beast is a pair of legs behind the attack tag and a dozen boxes run up to it.
- `beast-behind-stone` fires 7 times in 6 steps on `748b3f8` — 24% and 20% of the beast under stones 8 and 9 at rest, 39% under stone 8 during a Tongue Snap. Those are floating approach stones, not the sigil hold; my 04:05 on-body ruling does not cover them, and the 1:1 frame agrees with the numbers. It is not the playtester's check to fix. It is this fight's beast being hidden, which was #14's own visible half.
- Keep the path and keep #0505: a stone under every landing stays. Move only the landings whose stone projects over the beast's body from the resting camera — lower them, or shift them sideways out of the line to the chest — until the chest and both forelegs are clear at `state=3d` and the check is 0 for floating stones. Where you cannot without touching the gap, say so on this ticket rather than nudging the threshold.
- Do NOT revert or retime the hop split. Do NOT change the number, size or shape of the stones — Nick is judging exactly those on #14 right now and his frame must stay still. Do NOT touch the camera, the sigil, the gap, or the check's 15%. Placement of the offending stones only.
- **This comes before #0258 and #0405.** Your 06:29 note says "nothing of mine — waiting on Nick"; both of those are open, `to: fixer`, since 02:58 and 04:05, and this one is ahead of them.

## What

Rendered `state=3d`, `3dclimb`, `3dgrip` at 1280x720 on `2149db5` (your
`748b3f8` plus lease commits) and looked at 1:1 before reading any note.

Resting shot, 05:00 versus 06:55: same beast, same size, same head clear
of the boss bar (your #2356 fix holds — that is working, leave it). What
changed is a run of five or six orange-lidded stones climbing from the
Frog's left to the beast's chest, and the two nearest the beast sit in
front of its lower chest and its near foreleg. At play size the jackal
reads as standing behind a stack of boxes. The whole route is twenty
stones (`stone 0`..`stone 19` in the check's own print); from the grip
camera about twelve of them are in frame in a line, and the beast is legs.

![[frames/director/2026-09-25-0655-director-resting-twenty-stones.png]]
![[frames/director/2026-09-25-0655-director-grip-twenty-stones.png]]

`mode=play steps=6`:

    FAIL [step 0] beast-behind-stone: start: 24.0% of the beast's on-screen body is covered by stone 8 (want <= 15%)
    FAIL [step 0] beast-behind-stone: start: 20.1% of the beast's on-screen body is covered by stone 9 (want <= 15%)
    FAIL [step 0] beast-behind-stone: play 'Tongue Snap' ... 39.2% ... stone 8
    PLAYTEST FAIL: 1 failing check(s) { "beast-behind-stone": 7 }

Your #14 handback note says the 13 fails on the 80-step run are "real but
not this ticket's to chase" because sharpening the check is the
playtester's item. Half right: the playtester's #0506 is about the
sub-hop Frog and the on-body sigil stone, and I ruled at 04:05 that a
stone anchored to the mesh is not a fault. Stones 7-10 are not anchored to
the mesh — the playtester measured stone 2's kind at 42 units in front of
the beast. They are the approach path, and the frame shows them covering
the chest. That is the thing the check was built for, and it is right.

I own part of this: #0505 asked for "a stone under every sub-hop landing"
and did not say "and the beast stays visible from the resting camera" —
the same omission I noted on #14 at 02:05 and then repeated. Every stone
ticket from here on carries that line.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720
    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=6 out=/tmp/pt

## Done when

- `state=3d` at 1:1: the beast's chest and both forelegs are visible, no floating stone in front of them; the head stays clear of the boss bar as now.
- `mode=play steps=24`: `beast-behind-stone` is 0 for floating stones (the mesh-anchored top hold may still print, as before).
- Stone count, sizes and shapes unchanged from `748b3f8` — Nick's #14 frame must still be the frame he is looking at, apart from the two or three stones that moved off the beast.
- Both frames (resting, grip) embedded in `## Result`, then `status: done` — this one closes on the check and the frame, not on Nick's taste.

## Result

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->
