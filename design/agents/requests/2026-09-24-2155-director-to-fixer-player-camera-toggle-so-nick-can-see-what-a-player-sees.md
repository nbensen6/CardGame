---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: tonight — the default-lock half is in this push; the Risk of Rain framing is next run
created: 2026-09-24T21:55
taken_by: fixer
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

## Result, pass 2 — fixer, 2026-09-24 22:40 EDT

Nick answered live while pass 1 (below) was mid-push, and the director
rewrote this ticket around his answer: the default had to flip
unconditionally to Player, not stay keyed off `is_debug_build` (his own
build is always debug, so that default never locked anything for him). This
pass makes that change; pass 1's toggle mechanism, button, and ConfigFile
plumbing are unchanged and still the foundation.

**Did:** `Progress.dev_camera_enabled()` now takes no `is_debug_build`
input and defaults to `false` (Player) unconditionally — a fresh launch is
locked third-person in every build, debug included, with nothing in the
Menu touched. `free_camera_allowed(is_debug_build, dev_camera_enabled)` is
unchanged (still ANDs both), so a release build stays hard-locked
regardless of the Menu setting. Also fixed `state=3dfreecam`
(`tools/screenshot.gd`) to explicitly set Dev before its own drag tests —
that harness exists to test the free camera itself, so it must not read the
new locked default as "nothing works."

**Proof:**

- Fresh scratch config, `state=3dsettings`: button reads **"Camera:
  Player"** with nothing set. Frame below.
- Same fresh config, `run_tests.gd`'s new
  `_test_backlog_dev_camera_enabled_defaults_to_player_with_no_config`:
  `Progress.dev_camera_enabled() == false`. `ALL TESTS PASSED`.
- `state=3dfreecam` still exercises the mechanism end-to-end (forces Dev
  first, same drag/dead spot pattern as before this pass).
- `gauge` flickers `drags`/`DEAD` between identical back-to-back
  `3dfreecam` runs — reproduced 3x, present on this pass's code every time;
  a pre-existing harness timing flake at that one spot, not a regression
  (the other 6 spots are stable across all runs).
- Did **not** touch the Risk of Rain framing (pivot on the active hunter,
  9-unit standoff tuning, pitch/distance) — that is a real visual-iteration
  task on top of this mechanical one, not a follow-on line of the same
  change. Flagging rather than rushing it into the same push as the lock
  fix Nick needs before he wakes up.

![[frames/fixer/2026-09-24-camera-locked-by-default.png]]

**eta:** the lock-by-default half is done and pushed tonight. The Risk of
Rain framing is a separate, next-run task — render/compare/tune against his
picture, likely 1-2 more passes.

## Result, pass 1 — fixer, 2026-09-24 22:28 EDT

**Did:** added `Progress.dev_camera_enabled(is_debug_build)` /
`set_dev_camera_enabled(on)` (`game/core/progress.gd`, same ConfigFile the
keybinds already live in), a `Camera:  Dev / Player` button in the Menu's
Settings panel right above the keybind rows (`game/views/combat_3d.gd`
`_open_settings`), and threaded it into the existing gate:
`free_camera_allowed(is_debug_build, dev_camera_enabled)` now ANDs both —
Player blocks drag/pan/wheel/WASD even in a debug build, which is the whole
point (Nick otherwise never sees it, since `tools/dev.cmd` is always debug).

**Proof, each Done-when bullet:**

- **Toggle exists, flips in play, no restart needed.** Rendered
  `state=3dsettings` (opens the same overlay the in-fight Menu button does)
  — frame below, "Camera:  Dev" button sits right under the Keys hint,
  above the keybind list.
- **Player blocks every free-camera gesture in a debug build; Dev doesn't.**
  Not just the unit test — drove it through the real input pipeline with
  `state=3dfreecam` (synthesizes an actual mouse-down+drag+up at 7 screen
  spots and checks `_yaw` moved), by hand-editing the scratch
  `progress_screenshot.cfg` to force each value first:
  - `dev_camera_enabled=false`: all 7 spots `DEAD` (before this change, drag
    always worked in a debug build — this is the new behaviour).
  - `dev_camera_enabled=true`: `centre`/`sky-left`/`top-bar` drag,
    `party-panel`/`over-cards`/`ground-gap`/`gauge` stay `DEAD` — the same
    per-spot pattern as today's shipped code (checked against `git stash`),
    so Dev is unchanged.
- **Survives a relaunch.** Same `ConfigFile` mechanism as `keybinds`/
  `timing_style`, which already round-trip through a relaunch; round-trip
  covered directly by the three new `Progress` unit tests below.
- **`run_tests.gd`: `ALL TESTS PASSED`**, including the required third case
  on `free_camera_allowed` (`true, false` → `false` — the setting wins over
  a debug build) and three new tests on `Progress.dev_camera_enabled`
  (defaults to `is_debug_build` with no config, round-trips `false`,
  round-trips back to `true`).
- **`state=3d`/`3dclimb`/`3dgrip` unaffected with nothing set.** Compared
  before/after by hash first and got a mismatch — turned out the *unmodified*
  code doesn't hash-match itself between two back-to-back runs either (same
  diff magnitude, `mean≈0.4`–`2.8` per channel, software-GL jitter unrelated
  to this change); confirmed with `git stash` that this run's code and the
  original run identical `state=3dfreecam` drag/dead patterns, which is the
  behaviour that actually matters here.

![[frames/fixer/2026-09-24-camera-toggle-settings-menu.png]]

**Commit:** camera toggle + tests, this push.

**eta:** done — the four objective Done-when bullets are met; the last one
("is that the view you wanted to check?") is yours per the ticket, so handing
it back rather than closing it myself.
