# Balance notes

Measured with `tools/balance_sim.gd` (200 full runs per policy, through the real
`/core`). Rerun any time:

```bash
Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/balance_sim.gd
```

## The thing that made the numbers honest

The sim used to report ~100% for everyone, and it was **lying** — it played a
perfect solver. The grip timer and card timing live on the *client*, so a
headless run nailed every timed card and never once fell off a beast.

The sim now models a human:

| | naive | coordinated |
|---|---|---|
| chance a timed card lands (per window) | 55% | 78% |
| chance a climb ends in a fall | 30% | 16% |

A chained card like Satchel Charge needs all three windows, so its real success
rate is `rate³` — about 47% even for a good player. That single change is what
turned "everything wins" into numbers worth tuning against.

`naive` also stopped preferring damage cards. Preferring damage was *worse* than
naive: it systematically refused to climb, which no real player does. It now
plays the hand in order with no plan — an honest floor.

## Where it landed (Ascension 0)

| | naive | coordinated |
|---|---|---|
| win rate | **7%** | **74%** |
| losses by act | 64 / 111 / 10 / 2 | 0 / 22 / 22 / 8 |
| avg rounds per Titan | 3.9 → 7.2 | 2.3 → 5.3 |
| avg lowest HP | 6 / 42 | 14 / 42 |

*(Re-measured after shop nodes landed — shops displaced some treasure and rest
nodes, which cost the coordinated team a few points.)*

**Coordination is worth +67 points.** That's the design pillar holding: two
hunters playing as a team win most runs; two playing solo-style lose almost all.

Shape checks that matter as much as the headline:
- **A good team's losses skew late** (0 / 22 / 22 / 8) — runs are decided deep,
  not at the door. Act 1 teaches; act 2 onward tests.
- **Fights last 2–5 rounds**, up from 2–3. Beasts now get turns, so their
  telegraphs and the climb actually matter.
- **You finish bloodied** (14/42), not comfortable.

## The ascension ladder

| tier | coordinated win | avg lowest HP |
|---|---|---|
| 0 | 74% | 14 |
| 2 | 51% | 10 |
| 4 | 37% | 8 |
| 6 | 28% | 7 |
| 8 | **12%** | 7 |

A smooth slide. A8 sits a little below the ~20% target — steep, but the top tier
of a ladder should be; soften a tier in `data/ascension.json` if it reads as
hopeless in play.

## What was changed to get here

Starting point: coordinated **100%**, fights over in 2–3 rounds, beasts dying
before they could threaten.

- **Beast HP up** — Titans ×~2 (68 / 148 / 220 / 300), elites ×1.8, fodder ×1.65.
  This was the big one: it buys the beast enough turns to be dangerous.
- **Beast damage up ~20–25%** on everything that hurts (block/regen/enrage kept).
- **Weak-point thresholds ×1.4–1.5**, so the buck-off cadence survived the HP rise
  instead of doubling the number of re-climbs.
- **Healing trimmed** — `HEAL_BETWEEN` 6 → 4, `REST_HEAL` 12 → 9.
- **Act 1 softened deliberately** — The Stone Warden went back to weak point 2 and
  68 HP. It is the game teaching you to climb; it should be survivable while you
  are still learning. (Naive's wall moved from act 1 to act 2, which is right.)
- **Ascension tiers softened** — `boss_hp_pct` 15 → 10, `boss_strength` 2 → 1 per
  tier. The stacked version reached 2% at A8, which is not a ladder.

## The sim earns its keep: a real bug it caught

Adding shops sent every coordinated run to 0%. Three suspects turned out to be
wrong (shop policy, greedy elite-hunting, route choice) before the real one:

`Content.relic_pool()` returned the **cached** array, and the shop filtered it
with `erase()`. So visiting shops permanently drained relics from the entire
session; once empty, relic rewards offered nothing, `pick_reward` rejected the
empty choice, and the run **hung in REWARD forever**.

That is a player-facing bug — relics quietly disappearing from a session — and
nothing but a full-run simulation would have surfaced it. Pools now hand out
copies, with a regression test.

## Caveats worth remembering

- The coordinated AI is **near-optimal at card sequencing** while only being human
  at timing. Real players sequence worse, so treat 74% as a ceiling — a good human
  is probably 60–70%.
- The sim measures **balance, not fun**. It cannot tell you whether the climb
  feels good, only whether the numbers are survivable.
- Route and campfire policy are modelled simply (heal when hurt, otherwise take
  risks / sharpen). A player drafting a real archetype should beat these numbers.
- Every knob lives in data — see `design/tuning-knobs.md`.

## Older results, for reference
Pre-climb 3-Titan runs landed naive 8% / coord 96%; the first height-gated
4-Titan pass landed naive 68% / coord 98% (gap +30) before the map, campfires,
relics and ascension existed.
