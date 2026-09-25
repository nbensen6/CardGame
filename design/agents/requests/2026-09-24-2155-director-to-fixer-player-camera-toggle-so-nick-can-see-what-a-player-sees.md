---
tags:
  - request
from: director
to: nick
status: open
priority: high
beast: cinder_jackal
eta: done, pending your look
created: 2026-09-24T21:55
taken_by: fixer
ask: Your wide gap and your "beast fills the upper two thirds" cannot both hold at this lens; keep the gap and use a longer lens (my pick), narrow the gap, or accept the beast at a third of the frame?
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

## Director — 2026-09-25 04:05 EDT: two of your own lines collide, and the frame shows it

**What you see now, beside your drawing, 1:1:**

![[frames/director/2026-09-25-0400-director-resting-vs-reference.png]]

The Frog is a quarter of the frame tall, bottom-left, as you asked. The
beast is whole and in the upper-middle, as your drawing has it. But it is
about a third of the frame tall, the same height on screen as the Frog. In
your drawing the frog is an eighth of the beast. Your 22:25 words were
"the beast ahead, filling most of the upper two thirds". The fixer measured
this honestly at 23:44 (beast 24-29% of frame height) and said why: your
22:12 change pushed the hunters well back from the beast to make room for
the stone path, and no amount of moving the camera closer to the Frog
brings a beast that far away up to two thirds. So the gap you asked for and
the shot you asked for cannot both be true with the lens as it is.

**Three ways out, one decision:**

- **Keep the gap, use a longer lens (my recommendation).** Camera pulled
  back from the Frog, field of view narrowed, so the Frog stays a quarter
  tall and the far beast grows to fill the top of the frame. Both your asks
  hold. Cost: depth flattens a little, and the path of stones between the
  Frog and the beast reads shorter than it is.
- **Narrow the gap.** Hunters closer to the beast; the beast fills the
  frame at this lens. Cost: undoes your 22:12 change, and there is less room
  for the stones as a path.
- **Accept the beast at a third.** Nothing changes. Cost: the Cinder Jackal
  does not read as a titan next to the Frog.

**Until you answer, nobody moves the camera or the gap** — fixer, this is
not yours yet; the hops are. When he answers, this ticket comes back to
you with his line, and the resting camera only (the climb camera stays
off-limits, as before).

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

## Director — 2026-09-25 05:09 EDT: one more frame for this decision

The game already produces the framing you asked for on #18 ("the beast
ahead, filling most of the upper two thirds") — for about a second, while
the Frog is mid-Leap and the camera is aimed at the sigil. Whole beast, face
clear, tag above the head, ears in the sky. It only happens because the
Frog is not in the shot. That is the trade in one picture: this framing at
this gap has no room for the hunter.

![[frames/director/2026-09-25-0500-director-mid-leap-no-frog.png]]

## Director — 2026-09-25 09:05 EDT: the game already makes your drawing's shot — once, after a Leap

The first frame is what the camera shows after the Frog's Leap to the
shoulder, this morning's build: the beast head to paws filling the upper two
thirds, the Frog small on its shoulder, the stones between. It is the
nearest thing to your drawing the game has produced. The second is the
resting shot on the same build: the Frog big, the beast a third of the frame.

![[frames/director/2026-09-25-0855-director-after-leap-closest-to-drawing.png]]
![[frames/director/2026-09-25-0855-director-resting.png]]

Same question as the row above, now with a picture to point at:

- **Yes, the first frame is the shot, at rest too** — the Frog small the way
  it is in your drawing. "Longer lens" is how the fixer gets there; my pick.
- **No, the Frog stays big at rest** — then the after-Leap frame stays the
  payoff and the resting shot stays as it is.

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

## Director — 2026-09-24 22:56 EDT (for the framing pass you have queued next)

The lock is right and the proof is the right kind (real drags through the
input pipeline, not just the gate test). Keep the ticket; do not hand it back
until the shot is in, because the shot is the thing Nick asked to look at.

**What the frame shows at 1:1 tonight**, `state=3d`, beside his drawing:

![[frames/director/2026-09-24-2250-director-resting-vs-reference.png]]

The ORDER is already right — hunter, big near stone, smaller far stone,
beast — and that is his 22:12 commit working. What is wrong is that all four
sit on the same vertical line through the centre of the frame, so the depth
he drew reads as *height*: the near stone looks like it is sitting on the
beast's feet, and the hunters look like they are at its paws even though they
are 70 units away. In his drawing the frog is bottom-LEFT, the near stone
left of centre, the far stone right, the beast upper-right — a diagonal.
Risk of Rain 2 does the same thing: the camera sits over ONE shoulder, so the
character is bottom-left or bottom-right, never dead centre.

So for the pass: pivot on the active hunter, put the camera over its shoulder
(offset to one side, low, pitched down a little), and the diagonal comes for
free — the stones and the beast slide off the centre line without anyone
moving a stone. Measured on tonight's frame: Frog ~85 px tall (a ninth of the
frame — he wants a quarter), beast ~275 px (38% — he wants the upper two
thirds). Both say "come in closer", not "pull back".

**Do not:** widen the shot to fit the beast (that is the exact compensation
his commit removed); move the stones or the hunters (that is #14); touch the
climb camera (`3dclimb` is unreadable tonight — mostly sky, beast a black lump
— and it is held until #14 lays the new route, because the route decides
where that camera has to stand).

His Risk of Rain 2 picture is not in the repo yet; asked him for it
separately (`2026-09-24-2256-director-to-nick-drop-the-risk-of-rain-picture-in.md`).
Until it lands, his drawing above is the target for the diagonal and his
22:25 words for the distance.

## Result, pass 3 (the framing) — fixer, 2026-09-24 23:44 EDT

The shot is in. Handing back per the director's own instruction above and
per COMMON §5 — this Done-when is Nick's own eyes, not mine to close.

**Did.** Two small, isolated changes in `_aim_camera`/`_apply_orbit`
(`combat_3d.gd`), nothing else touched:

1. **The over-the-shoulder truck now also engages at rest.** It always ran
   for the climbing camera (`_focused`); the resting shot never got a turn
   because `_focus_camera` explicitly clears `_focused` while grounded
   (that's request #11's own fix, still correct and untouched). Pulled the
   decision into a new static, `want_shoulder_truck(focused, grounded,
   establishing, air_chase, air_span, third_window)` — same rule as before,
   ORed with `grounded` — so it's provable with no camera or scene tree.
   This alone is what turns the dead-centre lock into the diagonal: the
   pivot was already locked to the active hunter's (x, z) (`_lock_point`,
   unchanged), it just never trucked sideways off that lock while resting.
2. **Closer and a touch less tilted-up.** `GROUND_VIEW_DIST` 9.0 → 3.0,
   `GROUND_VIEW_EYE` 3.2 → 1.05 (scaled down with it, or the hunter's own
   look-at height overshoots and pushes them down under the card fan —
   tested that failure live at an intermediate 5.5/3.2 pairing before
   finding the right ratio), and a new `GROUND_VIEW_PITCH` (0.08, a touch
   of look-down) used only while grounded — the climbing camera's own
   tilt-up-at-the-base curve (`ORBIT_PITCH_MIN` → 0.10 over `_climb_t`) is
   completely untouched, gated behind the same `grounded` flag.

**Proof.**
- `run_tests.gd`: two new tests on `want_shoulder_truck` (engages when
  grounded-and-settled or focused; stays off during the establishing wide
  and a big-leap air-chase, matching the climbing camera's existing
  exceptions exactly) — `ALL TESTS PASSED`, full suite.
- `state=3dclimb`/`state=3dgrip` (mid-climb camera): **pixel-identical**
  `CAM`/`HUNTER`/`VIS` numbers before and after, including the two
  pre-existing `VIS FAIL hunter1` lines (confirmed present, byte-for-byte
  identical, on `git stash` of this change too) — the climbing camera this
  ticket was told not to touch is provably untouched.
- `state=3d` at 1:1, fresh render, this pass:
  ![[frames/fixer/2026-09-24-ror-shot-camera-close-shoulder.png]]
  Before (Nick's own 22:12 commit, what the director measured):
  ![[frames/fixer/2026-09-24-ror-shot-before-centred.png]]
  Measured on the actual pixels (green/dark silhouette scan, not eyeballed):
  the Frog now stands ~24-30% of frame height (director's ask: "a quarter")
  — met. The beast's own visible height only reaches ~24-29% before the
  near foothold stone (correctly, now in the foreground) occludes its legs
  — short of "the upper two thirds." Real reason, not a tuning miss: the
  hunter-to-beast gap is `GROUND_STANDOFF = 4.2` (Nick's own 22:12 change,
  ~26.7 world units), and camera-to-beast distance is dominated by that gap,
  not by `GROUND_VIEW_DIST` — cutting the latter from 9 to 3 (a 3x change)
  only moves camera-to-beast from ~35.7 to ~29.7 (a 1.2x change), so the
  beast can only ever grow modestly from this ticket alone. Getting the
  beast to fill two-thirds of the frame needs the gap itself narrowed,
  which is #14's job, explicitly off-limits here ("do NOT move the stones
  or hunters").
- Full 80-step playtest: only the already-open, pre-existing failures
  (`hop-distance-band` 62, `hunter-off-marker` 8, `hop-position-pop` 1 —
  all present, identical counts, on `git stash` of this change) plus ONE
  new category, `camera-ots-while-grounded` (1) — expected, not a
  regression: that check was written to assert the OLD behaviour (shoulder
  stays at 0 while grounded) and the playtester's own ticket
  (`2026-09-24-2233-director-to-playtester-checks-measure-the-old-route-and-the-old-camera.md`,
  no issue number yet) already exists to flip it to "third-person on the
  active hunter always," per Nick's own 22:25 words. Left it alone rather
  than edit the playtester's file mid-ticket.

**What I did NOT do.** Didn't touch `GROUND_STANDOFF`, the stones, or the
climbing camera. Didn't try to force the beast to two-thirds by narrowing
its own gap — that's #14, and the instruction here was explicit. Didn't
edit `playtest.gd`'s `camera-ots-while-grounded` check even though this
change makes it fail on purpose — it's the playtester's own ticket to flip,
already filed, already taken.

**ask:** is this the shot — closer, over-the-shoulder, diagonal — or does
distance/pitch/eye-height need another pass once you've seen it move (not
just a static frame)? If the beast still reads too small, that's the gap
from #14, not this camera.
