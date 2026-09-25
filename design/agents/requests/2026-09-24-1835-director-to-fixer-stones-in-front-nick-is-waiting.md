---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: this run: gap investigation + first pass on the stone path; likely 2 more runs after
created: 2026-09-24T20:08
taken_by: fixer
ask:
waiting: false
issue: 14
---

# Open the gap between the hunters and the jackal, then lay the stones across it (#18, steps 1 and 2)

**#14**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- **First, the gap.** Move both hunters' ground positions well back from the
  beast — a real stretch of empty dark ground between them and its paws.
  Nick's drawing: the gap is most of the picture.
- **Then the stones.** Lay the route ACROSS that gap: big near the hunter,
  smaller as they climb away toward the FRONT of the jackal's head. A path in
  perspective, not a stack beside the flank.
- **The last hold** leaves the hunter standing in front of the sigil with
  space between him and the skin (Nick on #5). The sigil itself stays.
- Do NOT touch the camera — not wider, not yawed. Step 3 of #18 is a close
  third-person camera behind the hunter, and it comes AFTER this.
- Do NOT restart the hop-band math from #4 first. Once the stones sit in open
  air across the gap they are no longer raycast onto the mesh, so #4's
  measured ceilings do not apply; place the path, then check the band.
- Do NOT restyle anything off the drawing — Nick (#17): placement only.

## What

Rewritten by the director, 2026-09-24 20:08 EDT, under Nick's #18. Before this the stones
work was spread over #4 (five investigation notes, closed into here), #5
(answered, closed into here), #11 (superseded) and the first version of this
ticket. This is now the ONE live ticket for the gap and the stones.

What a player sees today, at 1:1 on current main:

![[frames/director/2026-09-24-director-resting-shot.png]]

The hunters stand between the paws, about ten units out. Two pale saucers
float at the right flank. Nick's diagnosis on #18: *there is not enough space
between the hunters and the beast.* At that range no camera can be close on a
hunter and show the beast, which is why the wide shot happened. Open the gap
and everything else follows.

Nick's drawing, which is the target for **placement only**:

![[art/references/2026-09-24-nick-target-composition.webp]]

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

- In `state=3d` at 1:1: hunters at the bottom of frame, a clear stretch of
  ground, then the stones climbing away toward the front of the beast's head.
- At the top hold the hunter reads as standing in front of the sigil, not
  pasted on the cheek (the frame #5 asked for).
- 80-step playtest: 0 `route-reversal`, 0 `hunter-off-marker`.
- The after frame is posted here; the director hands it to Nick on #18.

## Nick's answer

## Result
