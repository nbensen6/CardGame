# Balance notes

Measured with `tools/balance_sim.gd` (300 runs/policy through the real /core).
Two AI policies: **naive** (dumps hand, no defense/combos) and **coordinated**
(covers the targeted ally, braces, Expose→focus-fire).

## Goal
Coordination should *decide* outcomes (CLAUDE.md §6). Target: naive ≈ 40–55%,
coordinated ≈ 85–100%, with a wide gap.

## Climb-foundation result (4-Titan run, height-gated)
The big change: **below the weak point the hide is armored** (attacks chip
1/`ARMORED_DIVISOR`); you must build **Height** to reach the sigil, where strikes
land full + bonuses. The shake (attack_all) knocks off `SHAKE_LOSS` Height, so the
loop is climb → strike → get bucked off → re-climb.

| Policy | Win rate | Lost at T1/T2/T3/T4 | Avg lowest HP |
|--------|---------:|:-------------------:|--------------:|
| Naive | **68%** | 0 / 0 / 9 / 86 | 11 / 42 |
| Coordinated | **98%** | 0 / 0 / 0 / 6 | 22 / 42 |

Gap **+30**. Reasonable, tunable state — the feel (climbing) was the goal here;
difficulty is yours to dial. NOTE: the sim's AIs were taught to climb (play grip
cards when below the sigil), else they never deal real damage.

(Earlier tunings for reference: 3-Titan pre-climb landed naive 8% / coord 96%;
2-Titan naive 43% / coord 100%.)

## Final numbers (all in `data/bosses.json`, `data/relics.json`, `core/run.gd`)
- Players: 42 HP, 3 energy/round. `HEAL_BETWEEN` = 6. Run = 3 Titans.
- **Stone Warden** (T1, opener): 108 HP; attacks 11 / 14 / block 10 / 22.
- **Gale Serpent** (T2, mid-wall): 140 HP, weak point 3; attack_all 8 / enrage 2 /
  attack 14 / attack_all 11.
- **Drowned Colossus** (T3, final): 170 HP, weak point 4; attack 13 / attack_all 9 /
  regen 12 / attack 22.
- Rewards: card after T1, relic after T2. ~6 relics in `data/relics.json`.

## Observations / follow-ups
- **All losses are at Titan 2.** Titan 1 is a pushover (a fine "learn the ropes"
  fight). When Titan 3 lands (Phase 3), build a real ramp: easy → medium → hard.
- **Cover carries** the coordinated game (~6 plays/run) — the ally-shield is
  central and very on-theme (protect your partner from the colossus).
- **Rally and Taunt are barely used** by the AI (~0.1 and ~0.0/run) — a signal
  they're underpowered or too situational. Revisit their numbers/design when
  adding mechanics (Taunt should matter vs single big hits; Rally with pricier
  cards).
- Sim "coordinated" AI is near-optimal defense, so real human co-op will sit
  *below* 100% — the 43% naive floor and the big gap are the meaningful signals.
