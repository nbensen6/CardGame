---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-25T05:05
taken_by:
ask:
waiting: false
---

# The Frog now crosses the gap in three hops and lands on air twice — put a stone under every landing

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- **After** your own camera-lock ticket (`2026-09-25-0420`, now `high`): once the Frog is visible in flight, it is visibly bouncing on nothing.
- The hop split (`f0808f0`) is right and stays. It turned one unseen 20 m hop into three short ones — and only the first and last have a stone under them.
- Draw a foothold at every sub-hop landing between the near stone and the chest stone, using the artist's rock. Big near the Frog, smaller as they recede — the drawing's path.
- Do NOT add gameplay Heights, move the sigil, change the gap, or re-enter the raycast search. Do NOT revert or retime the split. Placement of visible stones only.
- Prove it with the resting `state=3d` frame at 1:1 (the stones should read as a path from the near box toward the chest) and one hop strip where every landing has a stone under it.

## What

What a player sees on the tree at 04:20 (`f0808f0`), 24-step playtest, step 1
(Leap, foot 2→6): the Frog leaves the near stone, and the next thing on
screen is the Frog at the sigil. Between them there is no Frog at all — the
camera swings to the beast's face and the Frog is drawn in **0 of 24
sampled frames** (counted its pixels; the same detector finds 10,000 Frog
pixels in the resting shot). That is your `0420` ticket, and it comes
first, because until it lands nobody can see what the split did.

What the split did: `hop_subpoints` makes the crossing three legs of
~6.8 m instead of one of 20.4 m. Only the first leg starts on a stone and
only the last leg ends on one. The two landings in between are on air.
The resting shot shows why — between the pale near box (left) and the cone
on the chest there is nothing but ground and sky:

![[frames/director/2026-09-25-0500-director-resting-shot.png]]

Nick's line on #14, relayed at 22:25: *"the stones should be in a pattern
from left to right to the head of the jackal."* His drawing: every hop is
stone to stone, four stones before the beast. Two stones is not a pattern,
and a hunter landing on air between them is further from the drawing than
the single long hop was, because now you can see it happen (once `0420`
lands).

Your own #14 note (item 3) already named both halves — "the hop animation
itself ... not just `route_pos` placing more decorative stones". You shipped
the animation half. This is the other half. It is not decoration: it is the
thing Nick asked for by name.

**Praise, one line:** disclosing the 52 % `hunter-lost-mid-hop` regression
and reverting the 0.73 m pop instead of shipping it to clear a percentage
was exactly right. Keep doing that.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720
    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=24 out=/tmp/pt
    # step 1 = Leap foot 2→6; look at /tmp/pt/hop_001_*.png at 1:1

## Done when

- `state=3d` at 1:1: between the near stone and the chest stone there is a stone under every sub-hop landing, receding in size, reading as one path from bottom-left toward the beast.
- A hop strip of the Leap where every landing frame shows the Frog on a stone, not on air.
- `hop-distance-band` still 0; `ALL TESTS PASSED`; no new `hop-position-pop`.
- Then this rides #14's handback to Nick (per #14's own instruction) — do not hand it back yourself from here.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

