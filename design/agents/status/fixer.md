---
tags:
  - agent-status
agent: fixer
updated: 2026-09-23
working_on: backlog #86 duty 3 — reward_header_text() told a player to tap a relic when the row was empty; fixed, three new tests, pushed
---

# fixer

## Now

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request from
a prior run is still sitting on `to: nick`, untouched). Order-of-work item 2:
ran a full fresh `mode=play beast=cinder_jackal steps=80`, `mode=hover`, and
`mode=hands` — all three `PLAYTEST OK: 0 failing check(s)` / 0 fails, clean.
Item 3/4: rather than re-reading the same already-scarred `combat_3d.gd`
functions by hand again, dispatched an Explore agent to hunt for a genuinely
untested mechanic for this run's `#86` rotation slot, telling it what the
~30 prior duty-3 log entries already cover so it wouldn't re-suggest one.
Rotation state per `BACKLOG.md`: last commit was duty 2 (`09438cd`, the
sealed-door history fix), so this run owed duty 3 ("verify a mechanic
actually works").

**What it found.** `Location3D.reward_header_text()` (`location_3d.gd:526`)
— already a pure static function, 8 existing tests, but none of them (and no
parameter on the function at all) covered "the reward row has zero choices
in it". That state is real, not hypothetical: my own prior-run request
(`2026-09-22-2245-fixer-to-nick-boss-relic-pool-runs-dry-at-half-the-titans.md`,
still open, Nick's call) already proved 2-player co-op empties the shared
4-relic boss pool by the 3rd Titan. With the pool empty, `picked` false and
`has_selection` false, the function unconditionally returned "Tap a relic to
select" — with nothing on screen to tap and "Lock In Reward" permanently
disabled. That request already flagged this half as "definitely a bug
regardless" of the pool-sizing question; this run is where it got fixed.

**Fix.** Added a `has_choices: bool` parameter. When false (and neither
picked nor mid-selection), the prompt now reads "Nothing left to take — Skip
to continue" — the same "say why the option is gone" pattern the campfire's
"Sharpen — nothing left to sharpen" button already uses. `_render_reward()`
passes `not reward.get("choices", []).is_empty()`.

**Proof.** Updated all 11 existing `reward_header_text` call sites in
`run_tests.gd` to `has_choices=true` (none were testing the empty case).
Added three new tests: the empty-row message text itself; a regression
guard that the word "tap" never appears with zero choices (the literal
string the bug produced — `"Tap a relic to select"` on an empty row); and
that "locked in" still wins over the empty-row message for a player who
already picked (branch-order guard, since the `elif` chain checks `picked`
first). Proved all three against the unfixed behaviour first — temporarily
reverted just the new `elif` branch (kept the new signature so the calls
still matched) and reran: all three failed exactly as predicted. Restored
the fix, reran: `ALL TESTS PASSED`.

**Visual proof.** Rendered `state=3dreward` (`beast=cinder_jackal`) with
both hunters' `reward_choices` forced empty (matches the real drought
state): row empty, "Lock In Reward" correctly disabled, prompt now honest,
"Skip — keep the deck lean" visible and unambiguous.

![[frames/fixer/2026-09-23-reward-empty-choices-prompt.png]]

Re-ran the full `mode=play beast=cinder_jackal steps=80` / `mode=hover` /
`mode=hands` baseline after the fix: all three still `PLAYTEST OK: 0 failing
check(s)` — no regression from the change. Added a `## Result` to the
standing `to: nick` request noting item (2) — the prompt text — is now
fixed, and item (1) — whether the pool itself should be resized for 2-player
co-op — is still his call, untouched.

Full write-up in `design/BACKLOG.md`'s `## Log` (2026-09-23 entry). Next
`#86` turn is duty 2.

## Old: 2026-09-23, duty 2 — sealed-door ending recorded as a win in history

Fresh sandbox. No open `to: fixer` request (the boss-relic-pool request from
a prior run is still sitting on `to: nick`, untouched, and unlike the rest of
this note that one is still someone else's call to make). Order-of-work item
2: ran a full fresh `mode=play beast=cinder_jackal steps=80` (the whole 80
steps; the earlier `run_in_background` mistake from two runs ago did NOT
recur this time — used it correctly from the start), `mode=hover`, and
`mode=hands` — all three `PLAYTEST OK: 0 failing check(s)`, matching
yesterday's clean baseline (the hop_arc fix from two runs ago is holding:
step 17's climb still peaks at 19.56). Item 3: read `hop_arc`,
`hunter_side_offset`, `gauge_dot_dx`, `foothold_anchor`, `stand_offset_x`,
`climb_frame_for`, `popup_offset`, `pattern_shove`, `height_gap_between`,
`react_plan`, and card_view.gd's `_markup`/`_word_index`/`_kw` keyword
markup — nothing new; every one of these already carries an earlier `#86`
fix's scar tissue and reads correct.

Fell through to item 4 (backlog #86 duty — the only one of the four that
isn't scoped to the Cinder Jackal fight, "hunt a bug anywhere"). Rotation
state per `BACKLOG.md`'s own log: last turn was duty 3 (`21734f1`), so this
one owed duty 2 ("find an error and resolve it"). Dispatched an Explore
agent over the files the last several `#86` entries call already "fully
spent" for `game/views`/`game/ui`/`game/session` — pointed it at
`game/core/run.gd`, `run_save.gd`, `run_map.gd`, `progress.gd`, `boss.gd`,
`character.gd`, `card.gd`, `location_3d.gd`, `deck_view.gd`, `console.gd`,
`net/*`, cross-referenced against every existing `_test_backlog86_*` name so
it wouldn't re-find something already fixed. It came back with a real "two
copies of one truth" bug: `game_host.gd`'s `_note_progress()` correctly
gates `Progress.record_win()` on `phase == WON and true_ending` (an earlier
duty-2 fix, because the sealed-door ending — reaching the fourth Titan
without all three keys, backlog #64 — sets `phase = WON` with no fight ever
happening), but the very next line, unconditional
`Progress.record_run(_run.history_entry())`, still built its own `result`
field off the bare `phase == WON` test the sibling fix had already rejected.
A walked-away sealed-door run correctly left the career win counter alone
but still landed in the player's permanent run history reading
`"result": "win"`.

**Reproduced first.** Extended the existing
`_test_backlog86_sealed_door_ending_does_not_bank_a_win` test to also read
`Progress.run_history()` after the sealed-door `_broadcast_state()` call;
ran it against the unfixed tree and it failed exactly as predicted —
`got result=win`.

**Fix.** `Run.history_entry()` (`game/core/run.gd`) now matches
`_note_progress()`'s own condition — `phase == Phase.WON and
stats.get("true_ending", false)` — before setting `result = "win"`. A
sealed-door WON now falls through to the function's existing `""` default,
the same sentinel it already used for "neither WON nor LOST," so this is
the honest state, not a new one.

**Proof.** Reran the extended test on the fixed code: passes, `result=""`.
Full suite (including both pre-existing `history_entry` shape tests for a
real win and a real loss, and every `run_history`/`record_run` test)
unaffected — a real win always has `true_ending` true by the time
`_after_node()` reaches `WON`. `$GODOT --headless --path game --script
res://tools/run_tests.gd` → `ALL TESTS PASSED`. Re-ran `mode=hands` under
`xvfb-run` post-fix as a sanity check (this is a pure logic fix, nothing
rendered changes) — `PLAYTEST OK: 0 failing check(s)`. No frame to attach —
this bug never touched a pixel, only a persisted `ConfigFile` value; the
before/after numeric proof above is the evidence, same convention the
hop-arc trajectory fix used two runs ago.

Full write-up in `design/BACKLOG.md`'s `## Log` (2026-09-23 entry, now
superseded as the newest by this run's duty-3 entry). Next `#86` turn was
duty 3 (done above); the one after that is duty 2.

## Old: 2026-09-22, clean-bill-of-health run

No open `to: fixer` request this run (fresh sandbox; the boss-relic-pool
request from my own prior run is still sitting on `to: nick`, untouched).
Order-of-work item 2 (a playtest failure nobody has filed) and item 3
(bugs found by reading) both came back empty after a genuinely thorough
pass — writing that up honestly rather than manufacturing a fix, per the
brief's own "reproduce it first, or say you can't."

**What I ran.** A full live `mode=play beast=cinder_jackal steps=80` (the
whole 80 steps, fight never quite finished — Goblin Engineer down to 6 HP
at the end), `mode=hands` (every hand size 1-10) and `mode=hover` (the
flicker sweep). All three: `PLAYTEST OK: 0 failing check(s)`. The play
run alone exercised nearly the whole Frog/Goblin Engineer kit for real,
including the two hardest-to-reach paths: Meld (fused `Catapult + Burn
Coal`, played it, resolved cleanly through the two-pick exhaust_cheapen
flow) and Satchel Charge's 3-hit timed chain. Also hit Goblin Jetpack
(fired correctly at the next round start), Leapfrog, Grappling Arm/Hook,
Build Mech, Brace's 3rd-card condition, and a real fall (a boss hit
knocked the Goblin from foothold 10 back to 4, HP 20→14 — landed cleanly
on an intermediate ledge, both hunters still visibly separated, checked
against `step_071.png`). Frame-by-frame look (not just the automated
checks) at several of these — sigil pair-up, the fall/ledge landing, the
low-HP endgame — found nothing wrong: no overlap, no clipped text, no
missing glyphs, hunters always where the HUD says they are.

**What I read.** `core/combat.gd`'s `preview()`/`play_card()` against
every field the Frog and Goblin Engineer starter+reward cards actually
use (`timed_hits`, `pull_ally`, `sac_ally_grip`, `block_per_play`,
`prepare`/`_resolve_prepared`, `meld`/`_meld_cards`, `condition`/
`condition_bonus`), `combat_3d.gd`'s hand-tap/timing/selection flow
(`_on_card_tapped`, `_hold_points`, `selection_mode_for`), and
`card_view.gd`'s live face-text and tap-to-inspect keyword list. All of
it carries `backlog #86 duty 2` scars already — this system has had a
lot of real, careful attention from earlier runs, and it showed: I could
not find a gap that wasn't already closed.

**Two things I chased that turned out NOT to be bugs**, written down so
nobody re-chases them:
- Satchel Charge (`damage: 6`) showing "**Deal 1 damage.**" in a forced
  `hand=satchel_charge` screenshot (`state=3d`, foothold 0). Looked like
  a live bug at first glance. It isn't: `combat.gd:706-710`, the armored-
  hide mechanic — below the weak point, `swing = max(1, dmg /
  ARMORED_DIVISOR)` (`ARMORED_DIVISOR = 4`), so `6/4 = 1`. Correct,
  intended, by design.
- `mode=hands` prints `WARNING: 4 ObjectDB instances were leaked at
  exit` / `ERROR: 2 resources still in use at exit` (an `AudioStreamOggVorbis`
  + its playback, from `combat.ogg` via the static `Music._player`).
  `mode=play` (80 real steps, ~40 min) and `mode=hover` (also long) never
  show it; only the fast-exiting `mode=hands` does. Nothing in the
  shipped game ever calls `SceneTree.quit()` — a real player's process
  just dies, no warning printed to anyone. This is `quit()`-timing noise
  specific to the headless test tool calling `quit()` while
  `Music`'s looping stream is still mid-flight, not a Cinder-Jackal-fight
  bug. Leaving it alone; flagging here in case a future run sees the same
  warning and wonders.

Nothing fixed, nothing pushed to `game/`. Ran
`$GODOT --headless --path game --script res://tools/run_tests.gd` first
and last to confirm the tree was green throughout (`ALL TESTS PASSED`,
unchanged since no code moved).

![[frames/fixer/2026-09-22-clean-audit-meld-catapult-burncoal-sigil.png]]
![[frames/fixer/2026-09-22-clean-audit-fall-onto-ledge.png]]

## Old: 2026-09-22, earlier in the day

No open `to: fixer` request this run (fresh sandbox). Widened the "states
around the fight" look (per my own prior run's "Next" note) to the
campfire/shop/event screens (`location_3d.gd`) that hadn't had one yet:
rendered `state=3dcampfire`, `state=3dshop`, `state=3devent` (desktop and a
forced-mobile/phone-aspect shot) — all read clean, no overlap, no clipped
buttons, no missing glyphs.

While probing `state=3dwon` (drives a full run through all four Titans) to
exercise the reward screen further, found a real bug, but it lives in
`Run`/`location_3d.gd` reward/relic code shared by every fight, not in the
Cinder Jackal's own arena/cards — outside this rotation's scope per the
board's "Work outside the Cinder Jackal fight unless a request asks you to".
Filed rather than fixed:
`requests/2026-09-22-2245-fixer-to-nick-boss-relic-pool-runs-dry-at-half-the-titans.md`
— with exactly 4 `tier: "boss"` relics for a 4-Titan ladder, and BOTH
hunters drawing independently from that same shared pool each boss kill,
2-player co-op exhausts it after just the 2nd Titan: the 3rd and 4th
Titans' reward screens show zero relic choices, "Lock In Reward" stays
permanently disabled, and the header prompt still says "Tap a relic to
select" with nothing to tap. Reproduced with
`state=3dwon beast=cinder_jackal` — the driver script itself got stuck
spinning 400 iterations at the empty 3rd-Titan reward, never reaching WON
(`RUN ended in phase 5`, i.e. still REWARD). Frame:
`design/agents/frames/fixer/2026-09-22-boss-reward-relic-pool-exhausted.png`.
Flagged both the possible content gap (pool sized for solo, not 2p co-op —
Nick's call) and the definite bug regardless (the prompt text has no
"nothing left, Skip" case).

Then ran the play/hover/hands baseline fresh against the tip (order-of-work
item 2 — a failure the current playtest shows nobody has filed). `mode=play
beast=cinder_jackal steps=80` failed twice: `hop-flat` at steps 1 and 17,
"hop peak y=18.13 never rose above its endpoints (8.99 -> 18.17/18.18) --
reads as a slide, not a jump". Both were big single-leg climbs (Leap/Hop,
no intermediate ledge to split the hop) spanning several hunter-heights of
pure world-Y in one tween. Root cause: `Combat3D.hop_arc()` built the
apex's height as `lerp(from, to, 0.58).y + hop`, where `hop` is
deliberately clamped small (≤2.5 hunter heights) so a long haul doesn't
arc absurdly high — fine for a short hop, but for a climb whose own
vertical span already dwarfs that cap, the uncovered 42% of the span left
the apex BELOW the landing height. Reproduced headless with
`hop_arc(Vector3(0,8.99,0), Vector3(0.3,18.17,-0.4), 0.34)`: apex.y was
15.97 (below to.y=18.17). Fixed by taking the apex's height from
`maxf(from.y, to.y) + hop` instead of the lerp (x/z still lean toward the
landing as before) — apex.y is now 19.82, clearing both endpoints. Two new
`hop_arc` tests in `run_tests.gd` (the exact live numbers, plus the general
"apex always clears the higher endpoint" invariant — every prior `hop_arc`
test only ever moved flat, which is exactly why this slipped through).
`ALL TESTS PASSED`. Re-ran the identical `mode=play` repro on the fixed
code: `PLAYTEST OK: 0 failing check(s) {  }`, step 17's climb (same
8.99→~18.1 span) now peaks at 19.56. Self-filed and self-fixed —
`requests/2026-09-22-2300-fixer-to-fixer-hop-arc-reads-as-slide-on-tall-climb.md`,
commit `25804f3`.

Lost some time mid-run to my own harness mistake, worth remembering: I
backgrounded a playtest render with a bare shell `&` instead of the Bash
tool's `run_in_background`, which got reaped the moment that tool call
returned; retried without noticing and ended up with three overlapping
`playtest.gd` processes fighting over the same 4 cores and the same output
directory, which is why the first couple of attempts looked like they died
silently. Always use `run_in_background: true`, never a bare `&`, for
anything meant to outlive the current tool call.

## Next

The Cinder-Jackal-scoped items (1-3) are still clean, same as last run — no
bug survived reproduction there. What's still outstanding: (1) the
boss-relic-pool REQUEST is still waiting on Nick for the sizing/cadence
question, though the prompt-text half of it is now fixed. (2) the "pure
shape function tested on only one axis" question stands unresolved for
`combat_3d.gd`/`card_view.gd` specifically — every function I've personally
read there is clean, but nobody has audited ALL of them. (3) the `mode=hands`
ObjectDB/AudioStreamOggVorbis leak-at-exit noise is still just noise, still
untouched, still low priority. (4) Backlog #86 itself isn't Cinder-Jackal-
scoped and clearly still has real bugs/gaps in it, two runs running now
(the sealed-door history bug, then this run's reward-prompt gap) — the
general `game/core`/`game/session`/`game/views` layer outside the jackal
fight's own hand/climb/camera code keeps paying off faster than re-reading
the same already-scarred `combat_3d.gd` functions, so keep pointing the
Explore-agent hunt there first. (5) Worth someone eventually checking
whether other reward-adjacent screens (event/treasure rolls, not just boss
relics) can also produce an empty choice row — `reward_header_text()` now
handles it correctly wherever `_render_reward()` calls it, but I only
proved the boss-relic case is reachable; didn't chase whether event/treasure
pools can run dry too.

## Log

- 2026-09-23 (latest) — backlog #86 duty 3: fixed
  `Location3D.reward_header_text()` telling a player to "Tap a relic to
  select" when the reward row was empty (2-player co-op runs the boss relic
  pool dry by the 3rd Titan — already filed `to: nick`, still open for the
  sizing call). Added a `has_choices` parameter; empty + not picked/selected
  now reads "Nothing left to take — Skip to continue". Three new tests
  (message text, "tap" never appears, locked-in still wins over the empty
  message); all three fail on the unfixed `elif` chain, pass on the fix.
  Rendered `state=3dreward` with both hunters' choices forced empty to see
  it live. `ALL TESTS PASSED`; full `play`/`hover`/`hands` baseline clean
  before and after. See `## Now` and the request's own `## Result`.
- 2026-09-23 — backlog #86 duty 2: fixed `Run.history_entry()` recording a
  sealed-door ending (fourth Titan reached without all three keys) as
  `"result": "win"` in `Progress.run_history()`, even though the sibling
  `_note_progress()` check correctly kept it out of the real win counter —
  matched `history_entry()`'s condition to that sibling's
  (`phase == WON and true_ending`). Extended the existing sealed-door test
  to check `run_history()` too; failed on the unfixed tree (`got
  result=win`), passes now. `ALL TESTS PASSED`; `mode=hands` playtest clean.
  Full write-up in `design/BACKLOG.md`'s `## Log`. Items 1-3 (Cinder-
  Jackal-scoped) came back clean first, same as yesterday's audit — see
  `## Now`.
- 2026-09-22 — full audit pass, no bug found: live `mode=play` (80
  steps, exercised Meld/Catapult+Burn Coal fusion, Satchel Charge,
  Goblin Jetpack, a real fall onto an intermediate ledge), `mode=hands`,
  `mode=hover` all `PLAYTEST OK: 0 failing check(s)`; read
  `core/combat.gd`, `combat_3d.gd` and `card_view.gd` against every
  Frog/Goblin Engineer card field. Ruled out two apparent bugs (Satchel
  Charge's armored-hide-reduced "Deal 1 damage" preview; a `mode=hands`-
  only audio-resource-leak warning at `quit()`, both by design/harness
  noise, not gameplay bugs). Nothing fixed, nothing pushed to `game/` —
  `run_tests.gd` unchanged and green throughout.
- 2026-09-22 — fixed `Combat3D.hop_arc()` building a hop's apex below the
  landing height on a tall single-leg climb (Leap/Hop spanning several
  hunter-heights in one hop), caught live by the playtester's `hop-flat`
  check; apex height now `maxf(from.y, to.y) + hop` instead of a 58% lerp
  plus a capped hop. Two new unit tests, playtest report before/after
  (`PLAYTEST FAIL: 1 failing check(s)` → `PLAYTEST OK: 0 failing check(s)`).
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — filed (did not fix, outside the Cinder Jackal fight's scope)
  the boss-relic pool running dry by the 3rd of 4 Titans in 2-player co-op
  (only 4 `tier: "boss"` relics, both hunters draw from the same shared
  pool each kill) — reward screen shows nothing to tap while the prompt
  still says to tap one. `to: nick`, frame attached.
- 2026-09-22 — fixed the reward screen's prompt line ("Tap a card to
  select") being painted over by the reward row's own cards and fighting
  the felled beast's 3D corpse for contrast — wrapped it in a
  `PanelContainer` (the same backdrop pattern every combat HUD label
  already uses) and moved its band clear of the row, gated on non-empty
  text so other screens don't gain a stray empty bar; before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the attack icon ("⚔") rendering as a bare "×" on the
  boss's intent telegraph and the party card's incoming-damage readout —
  U+2694 CROSSED SWORDS has no glyph in this build's font-fallback chain.
  Replaced it with a new `Combat3D.ATTACK_GLYPH` constant (†), probe-verified
  to render; four unit tests (three updated, one new); before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the climb rail's gauge drawing one hunter's dot on top
  of the other's at the sigil (raw-foothold vs clamped-foothold comparison
  in the dot-offset logic, same bug class as the two fixes below but in a
  spot neither one touched); one new pure function
  (`Combat3D.gauge_dot_dx`), four new unit tests, before/after frames. Self-
  filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the party panel showing a raw foothold past the sigil
  ("↑16 / 5"); clamped the numerator in `party_card_stats()`, one new unit
  test, before/after frames. See the request's `## Result`.
- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
