---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta: tonight, first: 1 run
created: 2026-09-24T21:55
taken_by:
ask:
waiting: false
---

# Lock the camera third-person behind the hunter, in EVERY build, and make the free camera the opt-in

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need — Nick, live, 2026-09-24 22:25 EDT (relayed by the director)

- **"The camera should be locked to 3rd person on the character. I still
  cannot find the toggle."** Before he wakes up tomorrow. The toggle does not
  exist yet — this ticket was filed at 21:55 and nothing has been built.
- **Flip the default.** Normal play, in a debug build too, is the locked
  third-person camera: drag, pan, wheel and WASD do nothing. The free camera
  is an opt-in in the Menu — **Camera: Player / Dev** — Player by default
  everywhere, persisted next to the keybinds. Nick must not have to find
  anything to get the locked camera.
- **The shot he wants is Risk of Rain 2's** (his picture, 22:30 EDT): the
  camera low and just behind the active hunter, a touch above, looking
  slightly down. The hunter's BACK at bottom-centre, about a quarter of the
  frame tall. The beast ahead, filling most of the upper two thirds, a
  little off-centre. His 22:12 commit already parks the ground camera 9 units
  behind the hunter — tune from there: lower, closer, pitched down a little,
  pivot on the ACTIVE hunter (not the midpoint of the pair), the other
  hunter off to one side, never dead centre in front.
- Held the whole fight: after End Turn, after Switch, at rest. Mid-climb the
  existing climb framing stays as it is (his commit left it untouched).
- Do NOT rebuild the climbing camera. Do NOT remove the free camera from
  the Dev setting. Do NOT touch the screenshot/playtest states beyond what
  the new default forces; re-baseline them and say so.
- Then hand it back per COMMON §5: `to: nick`, `status: open`, `ask:`
  "Is this the Risk of Rain shot you wanted?", a 1:1 `state=3d` frame.

## What

What he sees tonight, 1:1, on his own commit — close, but the pivot is the
pair's midpoint so a stone sits dead centre between the two hunters, and it
is not yet locked for him because his build is a debug build:

![[frames/director/2026-09-24-2232-director-after-nicks-camera-commit.png]]

The cheapest shape: `free_camera_allowed(is_debug_build, player_mode)` with
`player_mode` true by default from the same config the keybinds use; one
two-state button in the Menu beside them; the existing gate tests get the
new default case. The framing numbers live where his commit put the 9-unit
standoff.

## How to see it

Open the fight through `tools/dev.cmd`, do nothing: the camera is behind
the Frog, low, the jackal ahead. Drag: nothing moves. Menu → Camera: Dev →
drag: it orbits.

## Done when

- Fresh launch of a debug build: locked third-person, nothing in the Menu
  touched. Drag / pan / wheel / WASD move nothing.
- Menu → Camera: Dev restores the free camera; it survives a relaunch.
- `run_tests.gd`: `ALL TESTS PASSED`, including "Player forces the gate false
  even when `is_debug_build` is true" and "Dev restores it".
- `state=3d` at 1:1: hunter's back bottom-centre ~1/4 frame tall, beast in
  the upper two thirds. Frame in `## Result`, beside Nick's Risk of Rain
  picture (ask him to drop it in `design/art/references/` — it arrived in
  chat).
- Handed back to Nick, never `done`.

## Nick's answer

## Result
