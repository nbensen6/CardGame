---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-23T15:00
taken_by: fixer
ask:
waiting: false
---

# Chain Lift / Tongue Grab go fully unplayable when only the pull is out of range

## What I need

- Fixed: `can_play()`'s `pull_ally` range gate was blocking the WHOLE card
  (greyed out in hand, can't tap it at all) whenever the pull itself was out
  of grapple range — even for cards that pair the pull with a second,
  position-independent effect.
- Two real, reachable cards hit this: **Chain Lift** (Goblin Engineer reward
  pool, `pull_ally: 5, ally_block: 5`) and **Tongue Grab** (Frog reward pool,
  `pull_ally: 4, rhythm: 1`). Out of pull range, a player lost the Block/
  Rhythm too, not just the pull.
- Fix keeps Nick's own existing rule intact for a pull_ally-only card
  (Grappling Arm): still hard-unplayable out of range, nothing else it could
  do. Only cards that carry another live effect now fall through to the
  existing graceful "no ally in grapple range" no-op the pull already had.

## What

Found by an Explore agent's read of `core/combat.gd` (item 3, no open
`to: fixer` request this run), confirmed myself before touching anything.

`can_play()` (`game/core/combat.gd:331-339`):

```gdscript
if card.pull_ally > 0 and has_ally(pi):
    var gap: int = ps.foothold - int(players[ally_index(pi)].foothold)
    if gap <= 0 or gap > card.pull_ally:
        return false   # blocked the ENTIRE card
```

Every sibling ally field (`ally_block`, `ally_grip`, `ally_energy`,
`sac_ally_grip`) is never gated in `can_play()` at all — each one just no-ops
gracefully inside `play_card()` if its own condition isn't met, the explicit
"playable-and-inert" pattern this same function's own comments already
describe for the has_ally case (#86 duty 2, the prior fix here). `play_card()`
already has that graceful fallback for `pull_ally` too
(`"%s plays %s — no ally in grapple range."`, combat.gd:1225) — but
`can_play()` never let a mixed card reach it.

Confirmed both cards are real and reachable: `chain_lift` in the Goblin
Engineer's `reward_pool` (`characters.json:299`), `tongue_grab` in the Frog's
(`characters.json:39`). A third card, Guide Rope (`pull_ally: 4,
ally_block: 4`), has the identical shape but I didn't chase where it's
offered from — same fix covers it either way.

**Fix.** `can_play()`'s gate now only hard-blocks when the pull really is the
card's entire reason to exist (`card.ally_block == 0 and card.rhythm == 0`) —
Grappling Arm (neither field set) keeps today's exact behaviour. Chain Lift/
Guide Rope (`ally_block`) and Tongue Grab (`rhythm`) fall through; the pull
itself still no-ops gracefully and logs it, same as it already did for a
solo fight with no ally at all.

**Rules call, smallest sane version, flagging per fixer.md's own limits
section:** I kept Grappling Arm's existing "simply unplayable" behaviour
rather than flipping every `pull_ally` card to playable-and-inert, since an
existing test explicitly attributes that call to Nick
(`_test_grappling_arm_pulls_ally`, "the card is simply UNPLAYABLE (Nick)").
If he'd rather ALL pull_ally cards (Grappling Arm included) go
playable-and-inert for consistency with every other ally field, that's a one-
line change (drop the `pull_ally_only` check) — small enough I don't think it
needs its own `to: nick` note, but calling it out here in case he disagrees
with which way I defaulted.

**Reproduced first.** Two new tests against the unfixed tree failed exactly
as predicted: Chain Lift/Tongue Grab both came back `can_play() == false`
when level with the ally (gap 0), and playing them anyway (bypassing
`can_play`) showed the Block/Rhythm never landed either — the whole card was
inert, not just the pull.

**Proof.** Three new tests in `run_tests.gd`:
- Chain Lift stays playable out of range, its Block lands on the ally, the
  ally's Height doesn't move, and the pull's own no-op line is still in the
  log (right before the Block line, not after — fixed a wrong assumption in
  my first draft of this test that it'd be the LAST log line).
- Tongue Grab stays playable out of range and its Rhythm lands.
- Regression guard: Grappling Arm (no other effect) is still unplayable out
  of range, unchanged.

All three failed on the unfixed tree, pass on the fixed one. Full suite:
`ALL TESTS PASSED`.

No live frame: this is a pure `core/combat.gd` rule, same as the melded-
slider and `note_hit` fixes earlier today — `Dev`/`hand=` can force which
cards are dealt but has no switch to force a specific foothold gap, so there
is no harness path to put Chain Lift in hand exactly level with an ally
on-screen. Same convention every other pure-logic card-rule fix in this file
already uses.

## How to see it

    $GODOT --headless --path game --script res://tools/run_tests.gd

## Done when

`ALL TESTS PASSED` with the three new tests included (done).

## Result

Fixed in `game/core/combat.gd`'s `can_play()`. Three new tests in
`game/tools/run_tests.gd`. `ALL TESTS PASSED`. Full fresh
`mode=play beast=cinder_jackal steps=80` / `mode=hover` / `mode=hands`
baseline (run before this fix, on the same tip) was already clean — this is
a positional-rule fix with no rendering surface, general regression covered
by the pre-fix baseline plus the unit-test proof above. Commit: see the
fixer status note's `## Log` for the hash.
