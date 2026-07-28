# Tuning knobs — your fine-tuning reference

Everything you'll likely want to adjust for *feel*, and exactly where it lives.
Almost all of it is data (JSON) or a handful of constants — no deep code needed.
After any change, re-measure with the balance simulator (bottom of this doc).

## Difficulty at a glance
Current (measured, 3-Titan run via `tools/balance_sim.gd`):
**naive AI 8% win · coordinated AI 96% · gap +88.**
- Too hard? Lower Titan HP/damage, or raise `PLAYER_HP` / `HEAL_BETWEEN` / energy.
- Too easy? The reverse. Watch the *gap* — a big gap means coordination matters.

## Titans — `game/data/bosses.json`
Per Titan: `max_hp`, `weak_point_height` (0 = no climb; >0 needs Foothold),
and a `moves` pattern that loops. Move types:
- `attack` (hits the telegraphed hunter), `attack_all` (sweeps both + shakes
  Foothold), `block` (guards), `enrage` (permanent +strength), `regen` (heals),
  `leech` (attacks a hunter and heals the Titan for the same).
- Order in the run + which Titans: `Run.ENCOUNTERS` in `game/core/run.gd`
  (currently **4 Titans** per run).
- Today: Stone Warden (108) → Gale Serpent (140, wp 3) → Drowned Colossus
  (170, wp 4) → Sunken Warden (180, wp 4, the final wall).

## Cards — `game/data/cards.json`
Per card: `cost`, and any of `damage`, `block`, `ally_block`, `ally_energy`,
`vulnerable`, `taunt`, `grip`, `damage_per_vulnerable`, `strength` (self buff),
`wound` (Titan bleed), `hits` (multi-strike), `draw`, `target`, `text`.
- `starter_deck` — each hunter's opening 10 cards.
- `reward_pool` — cards offered between Titans.
- Add a new card: add an entry, then list its id in `reward_pool` (and/or starter).

## Characters — `game/data/characters.json`
Per character: `name`, `desc`, `starter_deck` (card ids), and a signature
`passive` ({type, value}). Passive types: `climb_bonus` (+Height per climb),
`attack_bonus` (+attack), `ally_climb` (ally climbs when you do), `none`. `order`
sets the lobby list. Height is PER-HUNTER — cards can lift the ally (`ally_grip`),
build cards (`create`), or scale damage with your Height (`damage_per_foothold`).
Four creatures span a "climbs well ↔ hits hard" dependency axis (Frog/Vine-Weaver
climb & carry; Goblin Mech hits hard but can't climb — needs a lift).

## Relics — `game/data/relics.json`
Per relic: `effect` (`max_energy` | `attack_bonus` | `round_block` |
`heal_on_clear` | `start_strength`) + `value` + `text`. `pool` lists which can be
offered.
- New effect types need a case in `Combat` (`_init` bonuses) or `Run.relic_totals`.

## Core constants
`game/core/combat.gd`:
- `HAND_SIZE` 5, `BASE_ENERGY` 3
- `VULN_BONUS` 4 (Exposed bonus per stack), `SIGIL_BONUS` 5 (climb payoff)
- `FOOTHOLD_MAX` 6, `SHAKE_LOSS` 2

`game/core/run.gd`:
- `PLAYER_HP` 42, `HEAL_BETWEEN` 6, `REWARD_CHOICES` 3
- `ENCOUNTERS` (Titan list/order), reward card-vs-relic alternation in `_begin_reward`

## Grip / stamina (SotC climb tension) — `game/core/combat.gd`
The race from the base to the weak point is gated by grip. All constants live at
the top of `combat.gd`:
- `STAMINA_MAX` 6 — how long a hunter can cling before they must reach the sigil
  or fall (with `STAMINA_DRAIN` 2, that's ~3 rounds of climbing).
- `STAMINA_DRAIN` 2 — grip lost each round spent *mid-climb* (not at the base,
  where it refills, nor at the sigil, where it holds steady). See `_climb_upkeep`.
- `SHAKE_STAMINA_LOSS` 2 — extra grip torn away by a sweep (`attack_all`), on top
  of the `SHAKE_LOSS` Height knock-off.
- `STAMINA_HIT_REFUND` 2 — grip clawed back by a well-timed climb (a timed card
  that lands its throw). Ties the timing skill to the grip economy.
- `FALL_DAMAGE` 3 — the knock a hunter takes when grip runs out and they fall
  (Height resets to 0). A fall *can* be lethal, so it's checked for a loss.
Note: grip only applies to Titans with `weak_point_height > 0`. The balance sim's
AI climbs efficiently and rarely falls, so grip mostly changes *human* feel, not
the sim win-rate — tune it by playtest.

## Reward pacing
`Run._begin_reward` decides card vs relic (currently: card after Titan 1, relic
after Titan 2). Change the rule there for different pacing.

## Colours / theme — `game/ui/theme.tres`
Palette, panel/button styles, progress-bar colour. HP-bar danger thresholds and
intent colours are in `game/views/combat_view.gd` (`_bar_fill`, `_intent_color`).

## Re-measuring after a change
```bash
# balance (win rates, where runs die)
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/balance_sim.gd
# correctness (must stay green)
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/run_tests.gd
```
The sim's "coordinated" AI is near-optimal, so real human co-op sits *below* its
number — treat the naive floor and the gap as the signals, not the absolute coord %.
