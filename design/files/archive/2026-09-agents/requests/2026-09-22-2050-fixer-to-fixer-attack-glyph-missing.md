---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# The attack "⚔" icon draws as a bare "×" on the party card and boss intent

## What

Filed by myself, found while hunting bugs per the fixer brief (no open
`to: fixer` request this run, and `mode=play|hover|hands` playtests all came
back clean — nothing left to file from those). Both the boss's attack
telegraph (`_set_intent`/`intent_text_for`) and the party card's
incoming-damage readout (`_party_card`/`party_card_stats`) prefix an attack
number with "⚔" (U+2694 CROSSED SWORDS). On this build that codepoint has no
glyph anywhere in Godot's font-fallback chain and draws as a bare, generic
"×" — indistinguishable from a rendering error, right on the two places the
game most needs to be readable at a glance ("the single most time-critical
fact on the screen", the party card's own doc comment). Every other symbol
this same HUD leans on — ⚠ ⛨ ◈ ✦ ↑, and the neighbouring ◆ ▲ ✚ ▼ used for
block/enrage/regen/frail two lines below the broken one — renders correctly;
only this one codepoint is missing.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dgrip beast=cinder_jackal size=1280x720

Both the "Attack 7" tag above the beast and the Frog's party card
("HP 39/42  ↑0/5  ×7") show a plain × where the attack icon should be.

## Done when

The attack icon renders as an actual glyph, not a "×"-shaped placeholder, in
both places — a unit test pins the choice so a future edit can't silently
revert to the broken codepoint.

## Result

**Cause.** Confirmed with a throwaway probe scene (`Control._draw()` +
`ThemeDB.fallback_font`, screenshotted the same way as everything else) that
draws a column of candidate codepoints side by side: U+2694 alone comes out
as a bare "×" while ⚠ ⛨ ◈ ✦ ↑ — everything else this HUD already uses —
render correctly, so this isn't "emoji don't work here", it's this one
codepoint. `font.has_char()` reports `false` for all of them, including the
ones that visibly render fine (↑), so it can't be used to test this —
Godot's TextServer resolves missing glyphs through a system-fallback chain
that `has_char()` on the base font doesn't see; only an actual render proves
it either way.

**Fix.** Added `Combat3D.ATTACK_GLYPH := "†"` (†, DAGGER — confirmed
rendering in the same probe, and a plausible "this will cut you" reading next
to the move name it always sits beside) right above `intent_text_for`, with
a doc comment recording the probe result so nobody "fixes" this back to the
more-obviously-correct-looking ⚔ without knowing it's broken here. Both
`intent_text_for`'s two attack/rift branches and `party_card_stats`'s
incoming-damage line now use the constant instead of a literal "⚔".

**Proof.**
- `run_tests.gd`'s three existing string-literal assertions for this text
  (`_test_backlog86_intent_text_for_attack_adds_boss_strength`,
  `_test_backlog86_intent_text_for_rift_adds_the_height_gap_times_two`,
  `_test_backlog86_party_card_stats_incoming_damage_shows_through_or_blocked`)
  now check against `Combat3D.ATTACK_GLYPH` instead of a literal "⚔", so they
  catch a regression to the wrong character. Added a fourth,
  `_test_backlog86_attack_glyph_is_not_the_font_s_missing_crossed_swords_glyph`,
  that pins `ATTACK_GLYPH != "⚔"` directly — the specific regression a
  well-meaning revert would cause. `$GODOT --headless --path game --script
  res://tools/run_tests.gd` → `ALL TESTS PASSED`.
- Re-ran the identical repro (`state=3dgrip beast=cinder_jackal`) on the
  fixed code: both the intent tag ("† Attack 7") and the Frog's party card
  ("HP 39/42  ↑0/5  †7") now show a real dagger glyph, not a "×".
  `design/agents/frames/fixer/2026-09-22-attack-glyph-missing-before.png` /
  `-after.png` (full frames) and `-before-crop.png` / `-after-crop.png`
  (1:1 crops of the boss intent tag / the fixed party card).
- Re-ran `mode=hands` and `mode=play` playtests on the fixed code:
  `PLAYTEST OK: 0 failing check(s)` both times — the character swap doesn't
  touch layout width enough to trip the offscreen/text-cut/hand checks.

Commit: see the commit that introduces this Result section.

### Frames

![[frames/fixer/2026-09-22-attack-glyph-missing-after-crop.png]]
![[frames/fixer/2026-09-22-attack-glyph-missing-after.png]]
![[frames/fixer/2026-09-22-attack-glyph-missing-before-crop.png]]
![[frames/fixer/2026-09-22-attack-glyph-missing-before.png]]
