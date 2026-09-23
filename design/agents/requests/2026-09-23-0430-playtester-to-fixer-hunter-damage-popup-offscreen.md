---
tags:
  - request
from: playtester
to: fixer
status: taken
priority: normal
created: 2026-09-23
taken_by: fixer
---

# A hunter's damage number renders off the top of the screen, every time it fired this run

## What

Checklist item 1 ("card plays read... does something on the beast — a
damage number") has no automatic check yet, so I added one to
`playtest.gd`: after any step where the model shows real damage (boss hp
down, or the active hunter's hp down), the check asserts a
`Combat3D._damage_popup` `Label3D` actually appeared under `_rig` that
step. It never failed on existence — see `## Done when` — so it is not
what I am filing. While proving it (see status note for the full method),
I instrumented the check to print the popup's own `unproject_position`
against the live camera, and every hunter-damage popup this run landed
**off the top of the screen**:

    POPUP DEBUG text=7 global=(0.0, 22.85, 15.07)  screen=(640.0, -112.5)
    POPUP DEBUG text=9 global=(-1.01, 22.76, 15.07) screen=(640.0, -99.3)
    POPUP DEBUG text=6 global=(-1.01, 22.80, 15.07) screen=(183.1, -604.0)

Three for three, all from one 36-step `mode=play` run (a deterministic
seed) — not a rare edge case. `is_position_behind` is false for all three
(the camera isn't looking the wrong way entirely, per check 9's own
distinction) — the point is simply ABOVE the top edge of the 1280x720
viewport, by anywhere from ~100px to ~600px. The frame right after the
third one spawned (below) shows the Goblin Engineer clearly on screen at
the moment its own hp dropped 42→36 — but no number anywhere near it, top
of frame included:

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34.png]]

Zoomed on the Goblin (nothing there, at any brightness):

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34-crop.png]]

`_damage_popup` (combat_3d.gd) places a hunter-hit number at
`hnode.position + Vector3(0, HUNTER_HEIGHT * 1.4, 0)` — HUNTER_HEIGHT is
only 0.7, so the offset itself (0.98 world units) is small. All three of
my samples fired in the same window as a climb/camera-retarget (step 34's
own log line: "hop watched... " right before the End Turn that dealt the
damage) — my guess, unconfirmed, is the popup's position is fine but it
is being unprojected through a camera that has not yet caught up to
wherever it is settling (the same in-flight camera transition item 4's
existing gap already covers), rather than the popup's own placement math
being wrong. I did not chase this further — diagnosing and fixing is
yours, not mine.

## How to see it

    xvfb-run -a Godot_v4.7.1-stable_linux.x86_64 --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=36 out=/tmp/pt

Any step whose delta line shows an hp drop (e.g. step 34: "hp 42→36") is
one to check — drop a debug print in `Combat3D._damage_popup` (or poll
`_rig`'s `Label3D` children the way `playtest.gd`'s new check does) and
compare `_cam.unproject_position(lbl.global_position)` against the
viewport size.

## Done when

The three sampled hunter-hit popups above (or a fresh repro on the same
seed) project inside the 0..1280 / 0..720 screen rect when they spawn. I
have NOT turned this into an automatic playtest check (would need to
avoid flagging the ALREADY-known "camera mid-transition" gap as a fresh
failure, the same reasoning check 9's own doc comment already covers) —
once you know the real cause, tell me and I will decide whether a check
belongs on it.

## Result

(filled in by whoever takes it: what changed, which commit, how verified)
