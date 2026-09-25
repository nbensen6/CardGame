---
tags:
  - request
from: director
to: fixer
status: open
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T21:55
taken_by:
ask:
waiting: false
---

# A Dev / Player camera switch in the menu, so Nick can see the camera a player gets

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- Relayed from Nick, #18, 2026-09-24 19:48 EDT: *"have an agent create a dev
  mode vs player mode option so I can see the camera angle the player will
  see. I would like to be able to toggle this in the settings."*
- Add one toggle to the in-fight Menu, beside the keybinds: **Camera: Dev /
  Player**. On Player, the free camera (drag-orbit, pan, wheel, WASD) is off
  even in a debug build, exactly as it is in a release export. Nothing else
  changes.
- Persist it the way the keybinds are persisted, so it survives a relaunch.
  Default: Dev in a debug build, Player in a release build — so every harness
  screenshot and playtest is byte-identical to today with nothing set.
- **Order:** finish the #14 pass you are on now, then take this as your ONE
  thing next run — it is a run's work — then back to #14.
- Do NOT build the close third-person camera in this ticket. That is step 3
  of #18 and comes after #14. This switch only makes today's *player* camera
  visible to Nick; it does not change what that camera does.
- Do NOT remove the free camera from dev builds, and do NOT touch the
  screenshot/playtest states.

## What

What Nick sees today: he plays through `tools/dev.cmd`, a debug build, so
`free_camera_allowed()` is always true for him and the lock shipped on #3 has
never once applied to him. He has no way to look at the fight the way a
player will, which is why every camera ticket ends with him unable to say
whether it is right. Until this exists he cannot judge #18 step 3 at all, so
it goes in before that camera work, not after.

The cheapest shape: `free_camera_allowed(is_debug_build)` gains the setting
as a second input (`false` wins), the menu gets one two-state button, the
value lives next to the keybinds in the same config file. The existing
`free_camera_allowed` tests get a third case.

## How to see it

Open the fight, Menu, flip Camera to Player, close the menu, drag on the
arena: the view must not move. Flip back to Dev: it orbits again.

## Done when

- The toggle is in the Menu and Nick can flip it in play without restarting.
- With Player set, none of drag-orbit / pan / wheel / WASD moves the camera in
  a debug build; with Dev set, all of them still work.
- It survives a relaunch.
- `run_tests.gd`: `ALL TESTS PASSED`, including a case that Player forces the
  gate false even when `is_debug_build` is true.
- `state=3d`, `3dclimb`, `3dgrip` screenshots pixel-identical to before with
  nothing set; frames in `## Result`.
- Then set `to: nick`, `status: open`, `ask:` "Flip Camera to Player in the
  menu — is that the view you wanted to check?" and let him close it.

## Nick's answer

## Result
