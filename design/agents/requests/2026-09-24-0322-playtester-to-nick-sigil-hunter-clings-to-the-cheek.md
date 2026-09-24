---
tags:
  - request
from: playtester
to: nick
status: open
priority: normal
beast: cinder_jackal
created: 2026-09-24T03:22
taken_by:
ask: The route fix moved the Cinder Jackal's sigil off the snout tip onto the cheek, and up close the climbing hunter now reads as pasted flat against the face rather than standing on it — is that OK, or should the sigil be hunted further back on the skull?
waiting: false
---

# At the sigil, the hunter reads as glued to the jackal's cheek, not standing on it

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- **Decide, or tell us who should:** is a hunter pressed flat against the
  cheek, right beside the glowing eye, an acceptable "you made it to the
  weak point" pose — or does it need to look more like standing?
- If not OK: the fixer already named the fix — hunt the sigil further back
  along the skull/neck instead of straight down from above — but called it
  a design call, not something to guess at. Say yes/no/try something else
  and it'll get built.
- If OK as-is: say so and we'll leave it — closing this out either way.

## What

The fixer's stone-route fix (2026-09-23, `.../1846-...build-the-one-
directional-stone-route.md`) made every climb hold sweep the same direction
with no reversal — a real, needed fix, and it works. One side effect of
that fix, which the fixer flagged in their own write-up but which never
made it to you as a decision: forcing the sigil to keep sweeping forward
moved it off the tip of the snout (where it used to sit) onto the
cheek/neck area instead, because that's the nearest real head surface that
doesn't reverse the route.

Read purely as coordinates, that's a small, defensible move. Seen live, up
close, in the fight's own focused camera, it reads worse than that
description suggests: the Frog doesn't stand ON anything at the sigil —
there's no stone there (only the in-between holds get a floating stone) —
it's placed flush against the cheek surface, right next to the eye, and at
that camera distance it looks pasted on rather than perched. Every other
hold in the climb has the hunter clearly standing on a floating stone;
this one doesn't, and it's the last hold of the whole climb — the one the
whole fight builds up to.

![[frames/playtester/2026-09-24-sigil-frog-cheek-full.png]]
The real in-game state: Frog "at the sigil" (†5/5), Goblin Engineer one
step below on a stone. Full 1:1 frame, the actual camera a player sees.

![[frames/playtester/2026-09-24-sigil-frog-cheek-crop.png]]
Same frame, cropped in for detail only (not the basis for the finding by
itself — the frame above already shows it at 1:1). The Frog reads as
stuck to the cheek beside the eye, not standing.

This is not a bug in the placement math — I extended `playtest.gd`'s
`hunter-off-marker` check this run to also verify the sigil position (it
used to skip it entirely, on a stale assumption; see this run's own status
note) and it passes clean: the hunter's world position matches the
authored anchor exactly, within the same tolerance every other hold uses.
The anchor itself is just placed somewhere that doesn't read well at this
distance, and depth clearance isn't something that check tests (only
x/y). So this is squarely a "does it look right" call, not something to
autofix.

## How to see it

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=30 out=/tmp/pt

Any step where the HUD shows a hunter "at the sigil" (e.g. step 19/20 on
this run's own seed) — or `screenshot.gd -- state=3dclimb beast=cinder_jackal`
for a quick repro without playing a full fight (note: that state uses the
wide establishing camera, which doesn't show the problem as clearly — the
close/focused camera during real play is what reveals it).

## Done when

You've said yes (leave it), no (re-hunt the sigil further back on the
skull — the fixer's own suggested fix), or something else, under "Nick's
answer" below. Whoever picks up your answer will do the work and mark this
done.

## Nick's answer

<!-- Type below this line. Anything, one word is fine. Then run
     tools\board_push.cmd. Leave the frontmatter alone. -->

## Result
