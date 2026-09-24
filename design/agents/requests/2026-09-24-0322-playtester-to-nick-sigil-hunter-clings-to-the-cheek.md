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
issue: 5
synced_comment: 5822696384
---

# At the sigil, the hunter reads as glued to the jackal's cheek, not standing on it

**#5**

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

**From GitHub #5 (nbensen6, 2026-09-24 21:40 UTC):**

do you need any guidance on how to proceed

## Result

## Nick's answer — 2026-09-24 11:47 EDT

**The sigil stays on the head. Do not hunt it further back on the skull.**

You have diagnosed the wrong half. The sigil is where it should be — the
weak point belongs on the head, that is the whole read of the fight. What is
wrong is **where the stones put the hunter**: they leave him beside the face,
so he clings to the cheek instead of standing in front of it.

So this folds into the stone-route work already approved
(`2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`):

- **The stones go IN FRONT of the jackal**, as we agreed — the route climbs up
  and toward the head from the front, not up its side.
- The last hold should leave a hunter **facing the sigil with space between
  him and the skin**, standing on a shelf, not pressed flat against a cheek.
- If a hold cannot be reached from in front, that is the hold to move — not
  the sigil.

Fold this into the same build rather than filing it separately. Close this one
once the route change lands and the top hold reads as standing, not clinging.

## Filed on — playtester, 2026-09-24 12:52 EDT

Already relayed to the fixer, ahead of this run (commit `1a237dc`, 2026-09-24
11:52 EDT): the "stones IN FRONT of the jackal" / "last hold leaves space
between hunter and skin" requirement is now an addendum on the same build
request this was always meant to fold into,
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
(`status: taken`, `taken_by: fixer`). That request's own item 1 (structural
one-directional fix) is done; the front-of-body requirement above is not
built yet as of this run — the fixer's own latest status note (2026-09-24
11:34 EDT) doesn't mention it, so it hasn't been picked up. Leaving this note
`status: open` per Nick's own "close this one once the route change lands"
— closing early would just make someone go hunting for where it's actually
tracked. Whoever verifies the top hold reads as standing (frame against
this note's own before-frames) closes it.

