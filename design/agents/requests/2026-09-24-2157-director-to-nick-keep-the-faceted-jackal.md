---
tags:
  - request
from: director
to: director
status: taken
priority: normal
beast: cinder_jackal
eta: back to Nick once the fixer eases the free camera, 1-2 fixer runs
created: 2026-09-24T21:57
taken_by: director
ask: Keep the jackal at half geometry, or go back to the smooth one?
waiting: false
parent: 18
issue: 21
synced_comment: 5825707284
---

# The jackal was re-cut to half its geometry this evening — keep it, or put the smooth one back?

**#21**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- One word from you: **keep** the new jackal, or **revert** to the smooth one.
- I recommend **keep**. At play size it is the same black dog; it is now on
  budget; nothing about its animation broke.
- The artist asked for your look on this in its status note, where you cannot
  see it, so I am moving the question here. It is not urgent and nobody is
  blocked.

## What

Before (your last resting shot, earlier this evening) and after (now), both
at 1:1:

![[frames/director/2026-09-24-director-resting-shot.png]]
![[frames/director/2026-09-24-2154-director-resting-shot.png]]

What changed: the artist rebuilt the jackal with far fewer, larger faces —
the same treatment the hunters got — so the beast and the hunters are built
the same way. Close up, the body and face are more angular and the orange
markings are bigger panels; at the distance you play at, it reads the same.

- **Keep.** One style across beast and hunters, runs lighter, done.
- **Revert.** The smoother, more animal-looking silhouette up close, at the
  cost of the beast being built differently from the hunters.

You said on #17 that no art direction is needed, so if this is not something
you care about, "keep" is the answer and nothing happens.

## How to see it

Open the fight; the jackal is the black dog. Compare with the two frames
above.

## Done when

You answer below. The director takes it from there: keep = nothing to do;
revert = a one-line request to the artist to restore the previous model.

## Nick's answer

**From GitHub #21 (nbensen6, 2026-09-25 02:30 UTC):**

i cannot properly look at the model without a free cam toggle. 

I also would like the free cam to be more smooth. 

come back to me when this is complete so i can verify the model. 

Also director should look into why i cannot see pngs in git

## Result

## Result — director, 2026-09-25 09:58 EDT (taken back; not answered yet)

Nick's answer is a precondition, not a choice, so this leaves his column
until it is met. Three things in it:

- **"i cannot properly look at the model without a free cam toggle."** The
  toggle has existed since 22:28 last night (#19 pass 1): in the fight, Menu →
  Settings → the button reads **Camera: Player**; press it once and it reads
  **Camera: Dev**, and drag orbits, wheel zooms, WASD/QE flies. It survives a
  relaunch. He had not found it — the ticket that says so was handed to him
  as a lens question, not as "here is the toggle".
- **"I also would like the free cam to be more smooth."** True: in Dev the
  view snaps to the mouse each frame with no easing. Filed to the fixer, high,
  ahead of its other two tickets:
  `2026-09-25-0956-director-to-fixer-the-free-camera-jerks-so-nick-cannot-inspect-the-jackal.md`.
- **"director should look into why i cannot see pngs in git."** Fixed on his
  own PC at 09:50 today (commit `212c725`): mirrored tickets now render their
  frames instead of printing the embed text.

When the fixer's ticket is done this goes back `to: nick`, `status: open`,
with the same one-word question and a line saying where the toggle is.

