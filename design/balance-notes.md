# Balance notes

Measured with `tools/balance_sim.gd` (300 runs/policy through the real /core).
Two AI policies: **naive** (dumps hand, no defense/combos) and **coordinated**
(covers the targeted ally, braces, Expose→focus-fire).

## Goal
Coordination should *decide* outcomes (CLAUDE.md §6). Target: naive ≈ 40–55%,
coordinated ≈ 85–100%, with a wide gap.

## Phase 3 result (3-Titan run, with relics)
| Policy | Win rate | Lost at T1/T2/T3 | Avg lowest HP |
|--------|---------:|:----------------:|--------------:|
| Naive | **8%** | 0 / 171 / 105 | 6 / 42 |
| Coordinated | **96%** | 0 / 0 / 13 | 16 / 42 |

Gap **+88 points**. A full three-Titan run is a real gauntlet: sloppy play almost
never finishes; coordinated play (using combos + relics) clears ~96%. Clean ramp
— Titan 1 teaches, Titan 2 is the mid-wall, Titan 3 is the final test.

(Phase 1, the earlier 2-Titan tuning, landed naive 43% / coord 100%, gap +57.)

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
