---
tags:
  - request
from: director
to: director
status: wontfix
priority: high
beast: cinder_jackal
eta:
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

## Result — fixer, 2026-09-25 01:05 EDT

**Tried the camera numbers first, as asked — they can't do it without a new
regression.** `GROUND_VIEW_EYE`/`GROUND_VIEW_PITCH` are the only two levers
`_aim_camera` exposes for the grounded shot. Measured both in isolation:

| change | hunter0 (Frog) | hunter1 (Goblin) |
|---|---|---|
| shipped (1.05 / 0.08) | (431, 502) OK | (1014, 485) OK |
| EYE 1.15 (+0.10) | (430, 521) OK | (1015, 504) **FAIL** |
| EYE 1.6, PITCH 0.08 | (432, 604) OK, huge | (1012, 580) **FAIL** |
| EYE 1.6, PITCH 0.02 | (427, 609) OK, huge | (1019, 588) **FAIL** |
| PITCH alone, 0.00–0.08 (EYE 1.05) | no change at all | no change at all |

The Goblin already sits at y=485 against a hard-coded reserved corner at
y>500 (the turn/switch buttons) — only 15px of slack. `EYE` raises the whole
rig (a pure translation, since `_cam_home` = pivot + a height-independent
offset), which is exactly what pushes the far beast head down into frame —
but it pushes the Goblin down by the same amount, into that corner, at the
very first step tried (+0.10). `PITCH` alone does nothing at the shipped
`EYE`: `_cam_home.y` is pinned by the `CAMERA_FLOOR + lift` clamp
(`combat_3d.gd`) at every pitch from 0.00–0.08, so the camera's height (and
therefore the hunters' screen position) never moves — pitch only starts
doing anything once `EYE` is raised enough to clear that floor, and by then
it also blows up the Frog's own size (looking more level at an object 3
units from the lens makes it loom, confirmed live: Frog goes from a normal
crouch to filling half the screen). No combination of the two numbers alone
clears the head without failing the Goblin's on-screen position or wrecking
the Frog's scale — so per the ticket's own fallback, moved to the tag.

**The fix: `intent_tag_pos` (`combat_3d.gd`).** A crown that lands inside the
HP-bar's own clear band (`lo_y..lo_y+sz.y`, i.e. it's close enough to the top
of frame that "above" has no room) now hangs the tag beside the head instead
— toward screen centre, roughly level with the crown — rather than clamping
down onto it. Everywhere else (crown lower in frame, or so high it's off the
top by design, e.g. a Titan) is untouched: same "above" placement as before,
byte-for-byte.

**Real numbers, not guessed.** Instrumented `_position_intent_tag`'s own `p`/
`sz` live on `state=3d`: the resting shot's crown is `(544.917725,
94.703629)`, tag size `(160, 34)`. `lo_y=70`, so `lo_y+sz.y=104` — the crown
(94.7) sits inside that band, which is exactly why the old formula clamped
the tag down onto it (`clampf(94.7-34-10, 70, hi)` clamps up to 70, and
`[70,104]` covers the crown at 94.7). New position: beside it at
`(584.9, 77.7)`.

**Proof.**
- Two new tests in `run_tests.gd`, built on those exact live numbers: one
  reconstructs the pre-fix "above" formula and confirms it really does
  clamp onto the crown (sanity check the bug is real, same style as the
  existing party/hunter sanity checks); the other pins the fix's exact
  output. `ALL TESTS PASSED` (26 intent-tag tests total, all the
  pre-existing party-panel and hunter-overlap ones untouched).
- `state=3dclimb`/`3dgrip` `CAM` lines: byte-for-byte identical before/after
  (`git stash` diff), matching Done-when's own requirement.
- `state=3d` hunters: `VIS OK hunter0: (431, 502)` and
  `VIS OK hunter1: (1014, 485)` — both unchanged from shipped (I never
  touched the camera in the shipped fix).
- 1:1 frame, before/after:

![[frames/fixer/2026-09-25-head-behind-tag-before.png]]
![[frames/fixer/2026-09-25-head-behind-tag-after.png]]

Whole head — both ears, both eyes, the muzzle — now clears the boss bar with
a visible strip of sky above, and the tag sits beside it instead of on it.
Frog unchanged (still above the card fan, still a quarter of the frame).

Per the ticket's own Done-when, **not closing this myself** — it rides #14's
own handback to Nick. Leaving `status: taken`, `to: fixer`. Wrote the
progress into #14 itself (23:57 sequencing note, item 1 of 3).

## Director — 2026-09-25 07:00 EDT: folded into #14, not lost

The fix landed at 01:05 and holds in every frame since (head, both ears and eyes clear of the boss bar at 06:55, tag beside the head). It sat `taken`, high, eta "this run", for seven hours after that — finished in the fixer's mind, invisible on any board. Its Done-when is Nick's look, and Nick is looking at exactly this frame on #14, so it rides that row rather than becoming a second one. Closing as superseded by #14; if Nick says the head is still wrong, reopen here.
