---
tags:
  - request
from: session
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# Party panel shows climb height past the sigil ("↑16 / 5")

## What

Once a hunter is at the sigil, the party panel reads e.g. `↑16 / 5  at the sigil`
— the raw foothold (which keeps counting to FOOTHOLD_MAX) over the sigil height.
A player reads "16 of 5", which is nonsense. Seen in the fixer's own
`frames/fixer/2026-09-22-hunters-overlap-at-sigil-before.png` (Frog `↑16 / 5`,
Goblin `↑7 / 5` on a 5-high jackal — the Goblin's 7 is also past 5).

Same root as the overlap fix: a display that reads the raw foothold where it
should read it clamped to the sigil height. Check every place the foothold is
shown (party panel, the climb rail, tooltips, the log).

## How to see it

    playtest.gd mode=play beast=cinder_jackal steps=35  — once both are at the sigil

## Done when

At the sigil the panel reads `↑5 / 5` (or just "at the sigil"), never a number
above the sigil height; a unit test pins the display rule.

## Result

**Cause.** Same root as the hunters-overlap-at-sigil fix, one screen over.
`party_card_stats()` (`combat_3d.gd`) built the party panel's Height line as
`"↑%d / %d" % [foothold, weak_point_height]` from the RAW `foothold` — but
`foothold` keeps climbing to `FOOTHOLD_MAX` (16) after a hunter reaches the
sigil (core/combat.gd never caps it at `weak_point_height`), so a hunter who
kept playing Climb cards past the sigil read `↑16 / 5`. `hunter_side_offset()`
already had to learn this exact lesson for the 3D placement; the text panel
never got the matching clamp.

Reproduced live: `mode=play beast=cinder_jackal steps=35`, step 19 — The
Frog (you) reads `HP 35/42  ↑16 / 5  ×9  at the sigil` against a Height-5
Cinder Jackal, while the Goblin Engineer (foothold exactly 5) correctly reads
`↑5 / 5` (see
`design/agents/frames/fixer/2026-09-22-climb-readout-past-sigil-before.png`).

**Fix.** `party_card_stats(p, slot, me)` now clamps the numerator with
`mini(foot, wp)` before formatting, so any foothold at or past the sigil
reads the sigil height itself, never the raw stored value.
`game/views/combat_3d.gd`.

**Proof.**
- New unit test in `game/tools/run_tests.gd`,
  `_test_backlog86_party_card_stats_clamps_foothold_past_the_sigil_to_the_weak_point_height`,
  pinning foothold 16 and foothold 7 against `weak_point_height` 5 to both
  read `↑5 / 5`, and foothold 3 (still below the sigil) to read `↑3 / 5`
  untouched. `$GODOT --headless --path game --script res://tools/run_tests.gd`
  → `ALL TESTS PASSED`.
- Re-ran the same reproduction (`mode=play beast=cinder_jackal steps=20`) on
  the fixed code: The Frog now reads `HP 35/42  ↑5 / 5  ×9  at the sigil` at
  the same point in the fight, with the Goblin Engineer's `↑5 / 5` unchanged
  — `design/agents/frames/fixer/2026-09-22-climb-readout-past-sigil-after.png`.
  `PLAYTEST OK` / `**All checks passed.**` on both the before and after runs
  (the panel text itself has no playtest check today; the fix is proven by
  the unit test plus the rendered before/after frames).

The climb rail's own readout (`_draw_gauge`'s "N up" / "at sigil" label) and
the dev console's `climb <n>` echo were checked and are not affected: the
rail already derives its label from `top - mine` gated on `left <= 0`
("at sigil" the moment `mine >= top`, never a bare number past it), and the
console command is a developer cheat that intentionally echoes the raw
internal Height it just set, not a player-facing readout. The combat log's
"climbs (+N Height, now M)" lines were also checked; they report the actual
in-fight climb progress as a running count (never phrased as "M / sigil"),
so they carry no denominator to read as nonsense the way the panel's "16 / 5"
did — left as is.

Commit: see the commit that introduces this Result section.

### Frames

![[frames/fixer/2026-09-22-climb-readout-past-sigil-after.png]]
![[frames/fixer/2026-09-22-climb-readout-past-sigil-before.png]]
