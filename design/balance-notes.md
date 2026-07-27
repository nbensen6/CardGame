# Balance notes

Measured with `tools/balance_sim.gd` (300 runs/policy through the real /core).
Two AI policies: **naive** (dumps hand, no defense/combos) and **coordinated**
(covers the targeted ally, braces, Expose→focus-fire).

## Goal
Coordination should *decide* outcomes (CLAUDE.md §6). Target: naive ≈ 40–55%,
coordinated ≈ 85–100%, with a wide gap.

## Phase 1 result (2-Titan run)
| Policy | Win rate | Avg lowest HP |
|--------|---------:|--------------:|
| Naive | **43%** | 7 / 42 |
| Coordinated | **100%** | 21 / 42 |

Gap **+57 points**. Before tuning both policies won 100% (coordination was
decorative). Now sloppy play dies at Titan 2 more than half the time; coordinated
play reliably survives.

## Final numbers (all in `data/bosses.json`, `core/run.gd`)
- Players: 42 HP, 3 energy/round. `HEAL_BETWEEN` = 6.
- **Stone Warden** (Titan 1, the opener): 108 HP; attacks 11 / 14 / block 10 / 22.
- **Gale Serpent** (Titan 2, the wall): 140 HP; attack_all 8 / enrage 2 /
  attack 14 / attack_all 11.

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
