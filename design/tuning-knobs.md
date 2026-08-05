# Tuning knobs — your fine-tuning reference

Everything you'll likely want to adjust for *feel*, and exactly where it lives.
Almost all of it is data (JSON) or a handful of constants — no deep code needed.
After any change, re-measure with the balance simulator (bottom of this doc).

## Difficulty at a glance
Current (measured — see `design/balance-notes.md`):
**naive 7% · coordinated 74% · gap +67 · Ascension 8 at 12%.**
- Too hard? Lower beast HP/damage, or raise `PLAYER_HP` / `HEAL_BETWEEN` / energy.
- Too easy? The reverse. Watch the *gap* — a big gap means coordination matters.

## Titans — `game/data/bosses.json`
Per Titan: `max_hp`, `weak_point_height` (0 = no climb; >0 needs Foothold),
and a `moves` pattern that loops. Move types:
- `attack` (hits the telegraphed hunter), `attack_all` (sweeps both + shakes
  Foothold), `block` (guards), `enrage` (permanent +strength), `regen` (heals),
  `leech` (attacks a hunter and heals the Titan for the same).
- Also `swipe_high` / `swipe_low` (hit only hunters off / on the ground),
  `rift` (damage scales with the Height gap between hunters), `shift_sigil`
  (moves the weak point mid-fight).
- Act Titans: `Run.ENCOUNTERS` in `game/core/run.gd` (4 acts). Everything else is
  drawn from `pools` (fight / elite / boss) by the map's node type.
- Today: Stone Warden (68, wp 2) → Gale Serpent (148, wp 4) → Drowned Colossus
  (220, wp 6) → Sunken Warden (300, wp 6). 6 fight beasts + 4 elites besides.

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
Per relic: `effect` + `value` + `text`; `pool` lists what can be offered. 26 today.
- Flat: `max_energy`, `attack_bonus`, `round_block`, `heal_on_clear`, `start_strength`.
- Rule-changing: `start_foothold`, `fall_safe`, `shake_resist`, `rhythm_keeps`,
  `threshold`, `chip`, `sigil_bonus`, `vuln_bonus`, `draw`.
- Client-side (the systems live in the view): `grip_seconds`, `timing_zone`.
- A new effect needs summing in `Run.relic_totals()` and reading via `Combat._mod()`
  (or in the view, from the snapshot's `mods`).

## Core constants
`game/core/combat.gd`:
- `HAND_SIZE` 5, `BASE_ENERGY` 3
- `VULN_BONUS` 4 (Exposed bonus per stack), `SIGIL_BONUS` 5 (climb payoff)
- `FOOTHOLD_MAX` 8, `FALL_DAMAGE` 3, `RIFT_PER_GAP` 2, `ARMORED_DIVISOR` 4

`game/core/run.gd`:
- `PLAYER_HP` 42, `HEAL_BETWEEN` 4, `REST_HEAL` 9 (campfire), `MIN_DECK` 5
- `REWARD_CHOICES` 3, `ENCOUNTERS` (the act Titans)

`game/core/run_map.gd`: `ROWS_PER_ACT` 3, row width 2–3, node-type weights in
`_roll_type` (how often you meet a fight / elite / rest / treasure / event).

`game/data/ascension.json`: the 8 difficulty tiers and what each one does.

## Grip — real-time SotC climb (ledges + live timer)
Climbing between safe holds is a **real-time race**. The timer lives on the CLIENT
(`views/combat_view.gd`); the deterministic core only knows what's safe and how to
drop a hunter.
- **`GRIP_SECONDS`** (`views/combat_view.gd`, default `5.0`) — how long you can
  cling between holds before the timer empties. THE main feel knob; tune first.
- **`Combat.FALL_DAMAGE`** (`core/combat.gd`, `3`) — the knock on a fall. A fall
  resets Height to 0 and *can* be lethal (checked for a loss).
- **Ledges & weak points** (`data/bosses.json`, per titan) — `weak_point_height`
  is the sigil; `ledges` are the safe rest Heights between the base and it. Fewer
  ledges / a higher sigil = a longer, riskier climb. Current: warden 2 / serpent
  4 (ledge 2) / drowned 6 (2,4) / sunken 6 (3). `FOOTHOLD_MAX` 8.
- A hunter is **secure** on the base (0), any ledge, or the sigil (`is_secure`);
  between holds the client timer runs. A sweep (`attack_all`) shakes each hunter
  **down one hold** (`_hold_below`), not off entirely.
- The sim now MODELS falling (`FALL_CHANCE` in `tools/balance_sim.gd`) rather than
  ignoring it, so grip pressure shows up in the win rates. How the seconds *feel*
  is still a playtest question.

## Weak-point threshold — the climb→strike→climb loop
`data/bosses.json` `weak_point_threshold` per beast (Titans 18/24/33/42): sigil damage a
hunter can deal per visit before the beast **bucks them down a hold** (`_check_weakpoint_buck`
in `core/combat.gd`). Lower = shorter strikes, more re-climbs (a tighter loop);
higher = camp longer. `PlayerState.weak_point_damage` accumulates while reached
and resets on any drop (fall/sweep/buck). Raise these alongside beast HP — if HP
grows and the threshold doesn't, you just get twice as many re-climbs.

## Timed cards (the double-timing feel) — `data/cards.json`
`timed: true` makes a card run its on-card timing sweep; a HIT grants `timed_grip`
(bonus Height) and/or `timed_damage` (bonus damage), a MISS makes the card slip
away with no effect. Class decks lean on these (pounce/flick/lash_out/creeper/
piton_drive/haul/piston_punch). More timed *climb* cards = more double-timing
(card sweep + live grip bar). Tune the base-vs-bonus split so a miss stings but a
whiff-heavy player isn't hopeless; keep ~4-6 reliable non-timed cards per deck.

## Gold & shops — `core/run.gd`
`GOLD_FIGHT` 25 / `GOLD_ELITE` 55 / `GOLD_BOSS` 80 into a **shared purse**; some
events pay gold too. Shop prices: `PRICE_CARD` 55, `PRICE_RELIC` 135,
`PRICE_REMOVE` 70 rising 25 per removal bought in the run. Shop stock is 2 cards
per hunter (own pool) + 2 team relics + a removal per hunter. Shop frequency is
the `shop` weight in `RunMap._roll_type`.

## Reward pacing
Set by map node type in `Run.pick_node`/`sync`: fights pay a **card**, elites and
Titans pay a **relic**, treasure nodes pay a relic outright. Cards come from the
acting hunter's own pool (`characters.json` → `reward_pool`) so each class drafts
its own archetypes. Rewards can be **skipped** (`Run.skip_reward`).

## Colours / theme — `game/ui/theme.tres`
Palette, panel/button styles, progress-bar colour. HP-bar danger thresholds and
intent colours are in `game/views/combat_view.gd` (`_bar_fill`, `_intent_color`).

## Difficulty targets (what "balanced" means here)
Hit these and the design pillar is holding — see `design/balance-notes.md`:
- **Coordinated ~75–80%** at Ascension 0 (a good team usually wins, not always)
- **Naive under ~15%** (solo-style play loses)
- **A gap of +60 or more** — coordination must DECIDE the run
- **Losses skew late** (act 3–4, not act 1) — a run should be decided deep
- **Fights last 4–6 rounds** — short fights mean the beast never threatens
- **Ascension 8 around 20%** — a real wall, still beatable

The sim models human timing (`TIMING_HIT`) and falls (`FALL_CHANCE`) at the top
of `tools/balance_sim.gd`. Those two constants matter more than any beast stat:
with perfect timing every policy wins, which is what made the old numbers useless.

## Re-measuring after a change
```bash
# balance (win rates by policy + the full ascension ladder)
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/balance_sim.gd
# one tier only
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/balance_sim.gd -- ascension=4
# correctness (must stay green)
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/run_tests.gd
```
The sim's "coordinated" AI is near-optimal, so real human co-op sits *below* its
number — treat the naive floor and the gap as the signals, not the absolute coord %.
