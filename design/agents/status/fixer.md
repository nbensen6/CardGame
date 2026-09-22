---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: done for this run
---

# fixer

## Now

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

The glyph-missing bug class, the sigil raw-vs-clamped bug class, and now
the flat-hop-on-a-tall-climb case all look closed for now. Two open
threads: (1) the boss-relic-pool request is waiting on Nick — nothing to
do there until he answers. (2) `hop_arc` was tested with real numbers for
the first time this run and immediately found a real bug purely because
prior tests never varied Y — worth asking whether any other "pure shape"
function in this file (or `card_view.gd`'s timing math) has the same
gap: every existing test moving along one axis only, real bugs hiding on
the untested ones.

## Log

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
