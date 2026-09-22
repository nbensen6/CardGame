---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: done for this run
---

# fixer

## Now

No open `to: fixer` request this run. Ran all three `playtest.gd` modes
(play/hover/hands) fresh against the current tip myself, per the fixer
brief's order of work — all came back `0 failing check(s)`, nothing left to
file from those (the last playtester baseline predated my own gauge-dot fix,
so this wasn't a wasted repeat). Moved to reading the sigil-adjacent code
this rotation keeps finding bugs in and, this time, the HUD text it renders:
both the boss's attack telegraph and the party card's incoming-damage
readout prefix an attack number with "⚔" (U+2694 CROSSED SWORDS) — a
codepoint with no glyph anywhere in this build's font-fallback chain, so it
draws as a bare "×" on exactly the two spots the fight most needs to read
clearly at a glance. Confirmed it's isolated to this one character with a
throwaway probe render: every other symbol this same HUD uses (⚠ ⛨ ◈ ✦ ↑,
and the neighbouring ◆ ▲ ✚ ▼ two lines below the broken one) renders fine.

Filed it to myself
(`requests/2026-09-22-2050-fixer-to-fixer-attack-glyph-missing.md`) and
fixed it: a new `Combat3D.ATTACK_GLYPH` constant (†, DAGGER — probe-confirmed
to render) replaces the literal "⚔" in `intent_text_for` and
`party_card_stats`, with a doc comment recording why so nobody swaps it back
to the more-obviously-right-looking ⚔ without knowing it's broken here.
Updated the three existing string-literal tests to check against the
constant, and added a fourth that pins `ATTACK_GLYPH != U+2694` directly.
`ALL TESTS PASSED`. Before/after frames at the same repro
(`state=3dgrip beast=cinder_jackal`) show "× Attack 7" / "×7" becoming
"† Attack 7" / "†7"
(`design/agents/frames/fixer/2026-09-22-attack-glyph-missing-*.png`, crops
included). Re-ran `mode=hands`/`mode=play` playtests on the fixed code:
`PLAYTEST OK: 0 failing check(s)` both times.

## Next

Pick up the next open `to: fixer` request, or hunt a bug per the fixer
brief. Worth a look next: I only checked the symbols this exact HUD (party
card, intent tag, climb gauge) already uses — card faces, the log, and the
timing minigame (`hit_circle.gd`, `card_view.gd`) use their own separate set
of glyphs/icons and weren't covered by this probe, so a similar missing-glyph
check there hasn't been ruled out.

## Log

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
