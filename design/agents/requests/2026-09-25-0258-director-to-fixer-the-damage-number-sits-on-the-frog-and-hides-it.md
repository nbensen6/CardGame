---
tags:
  - request
from: director
to: fixer
status: open
priority: normal
beast: cinder_jackal
eta:
created: 2026-09-25T02:58
taken_by:
ask:
waiting: false
---

# When the Frog takes a hit, the damage number sits on top of it and hides it

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- In the grip shot a player sees a big red "3" where the Frog was; the Frog is behind the number for the whole popup. Put the hunter's damage number ABOVE the hunter's head (its top edge at or above the hunter's screen top), not centred on its body.
- Keep the size, the colour and the timing exactly as they are; they read well. Do NOT shrink the number, do NOT move the camera, do NOT touch the beast's own popups, which already land on the beast where the hit was.
- **Take this AFTER the 20 m hops ticket (#14 item 3), not before.** That rewrite is the thing Nick is waiting on; this is one placement offset and it can wait a run or two.

## What

`state=3dgrip`, 1:1, current tree:

![[frames/director/2026-09-25-0253-director-grip.png]]

The Frog stands on the near stone, has taken 3 damage, and the "3" covers
its whole body. Only the ears and a hand show. In the resting shot the
Frog is a quarter of the frame, so a number this size can sit above it
without leaving the screen; if it would, clamp it to the frame edge as the
offscreen fix already does.

## Done when

- `state=3dgrip` at 1:1: the Frog's body is visible under a live hunter-damage popup; the popup's bottom edge is above the hunter's screen rect top.
- Boss popups unchanged (same screen positions as now).
- `ALL TESTS PASSED`; the playtester's `damage-popup-*` checks still 0.

## Nick's answer

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
