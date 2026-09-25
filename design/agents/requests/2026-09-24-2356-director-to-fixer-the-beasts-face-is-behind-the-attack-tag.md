---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: this run
created: 2026-09-24T23:56
taken_by: fixer
ask:
waiting: false
---

# In the new close shot the beast's face is behind the Attack tag and its skull behind the boss bar — a player sees legs and two eyes

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- The resting shot (`state=3d`) is the first real step toward Nick's drawing tonight — keep it. But the beast now runs off the TOP of the frame: its eyes sit just under the "Attack 7" tag and the top of its head is behind the boss bar. The one thing the drawing makes the focal point, the glowing face, is the one thing the player cannot see.
- Fix the visible half in the same lane you just worked: a touch more tilt-up / a little more eye height while grounded (`GROUND_VIEW_PITCH` / `GROUND_VIEW_EYE`, one or two numbers), so the whole head sits BELOW the boss bar with sky above it, as in his picture. Check the Frog stays clear of the card fan when you do — that is the trade you are making.
- If the numbers alone cannot do both, the second lever is the intent tag: hang it beside the head, not on it, whenever the head is within ~120 px of the top. Try the camera numbers first; only reach for the tag if you must.
- Do this as the FIRST thing of your #14 run, not as its own run: #14 narrows the gap, which makes the beast bigger, which pushes the head further off the top — so head clearance is a Done-when of #14's framing, and the two want tuning together. Read the sequencing note on #14 (23:57).
- Do NOT pull the camera back or widen the FOV to fit the beast (that is the exact compensation Nick removed at 22:12). Do NOT move stones or hunters here. Do NOT touch the climb camera. Do NOT rebuild the intent tag.

## What

`state=3d`, 1280x720, tip of main (`ef52a75`), at 1:1:

![[frames/director/2026-09-24-2355-director-resting-shot.png]]

What a player sees: a big green Frog bottom-left (good — a quarter of the
frame, where Nick drew it), the path running diagonally up to the beast
(good), the beast at the top with the "Attack 7" tag sitting on its face
and the boss bar across its skull. Two orange eyes peek out under the tag.
The beast reads as "a pair of legs behind the UI".

Zoomed 2x only to diagnose what I had already seen at play size:

![[frames/director/2026-09-24-2355-director-head-behind-hud-2x-zoom.png]]

Beside Nick's drawing — his beast has sky above it, and the face is the
brightest thing in the picture:

![[frames/director/2026-09-24-2355-director-resting-vs-reference.png]]

Your pass 3 measured the beast's *height* (24-29%) and correctly blamed the
gap for it being small; what it did not say is that the part of that height
that is missing is the head, not the legs. The frame is the check, not the
silhouette scan.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

In `state=3d` at 1280x720 the beast's whole head (ears, both eyes, muzzle)
is below the boss bar and not under the intent tag, with visible sky above
the ears; the Frog is still fully above the card fan; `3dclimb`/`3dgrip`
`CAM` lines unchanged. A 1:1 frame in the Result. Then this rides #14's
handback to Nick — do not close it yourself.

## Nick's answer

## Result
