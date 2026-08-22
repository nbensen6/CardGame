# The work queue

> Written 2026-08-16 when Nick asked Claude to keep working on the game
> autonomously, using other card games as reference, resuming on its own after
> his usage limit resets.
>
> **This file is the queue.** An autonomous loop with no queue does not work on
> the game — it works on whatever it thought of last, which is how a codebase
> fills up with plausible things nobody asked for. One item per iteration, top
> of the list first.

## Hard rules for unsupervised work

These exist because nobody is watching. Breaking one is worse than doing nothing.

1. **One item per iteration, finished.** Implemented, tests green, verified by
   screenshot where it is visible, committed, pushed, ticked off here with a
   line in the log. Never leave the tree broken — usage can run out mid-iteration
   and whatever is committed is what Nick wakes up to.
2. **`run_tests.gd` must pass before every commit.** No exceptions, no "I'll fix
   it next round."
3. **Verify by looking.** Anything that changes what is on screen gets a
   screenshot through `tools/screenshot.gd`. Claiming a UI change works without
   looking at it has been wrong before.
4. **Never touch the things that are Nick's.** Art direction, budget, business
   and marketing calls, pricing, what is *fun*, and the shape of the EA box. If
   an item turns out to need one of those, stop it, move it to **Needs Nick**,
   and take the next item.
5. **No balance tuning.** Nick, standing instruction: gameplay is not ready for
   win-rate work. Build feel and content; do not chase numbers. Running
   `balance_sim.gd` as a *smoke test* to prove nothing exploded is fine —
   tuning against its output is not.
6. **No new scope.** Ideas that arrive mid-work go to **Later**, not into the
   build. The roadmap's §0 rule holds: the EA box stays closed.
7. **Data over code.** Cards, beasts, relics and events are data (CLAUDE.md §11).
   If an item can be a JSON change plus a generic rule, it should be.
8. **Log honestly.** If an item was harder than expected, half-done, or turned
   out to be a bad idea, the log says so. A log that only contains wins is not
   worth reading.

## Queue

Ordered. Source in brackets.

- [ ] **1. Exhaust scaling for the Goblin** — one field, immediate depth.
  *Done when:* the field exists, at least three cards use it, tests cover it.
  [sts2-comparison §5.2]
- [ ] **2. Campfire relic upgrades** — a fourth campfire option ("empower a
  relic") on top of the existing Rest / Thin / Sharpen and `Run.relic_totals()`.
  *Done when:* pickable at a campfire, persists, shows in the relic list.
  [sts2-comparison §3.2 — "nearly free"]
- [ ] **3. Card enchantments** — the big one, and the one with a mechanic only
  this game can have: `sure`, a wider timing window, turning the real-time layer
  into a build decision. `data/enchants.json` + the `upgraded_copy()` trick.
  *Done when:* enchants are data, apply generically, are visible on the card
  face, and come from at least one source (campfire).
  [sts2-comparison §3.1 ⭐]
- [ ] **4. Per-beast limiters** — a rule each Titan bends, so four Titans are
  four puzzles rather than four HP bars.
  *Done when:* at least the four Titans each carry one, expressed as data.
  [sts2-comparison §3.4]
- [ ] **5. Vine-Weaver's rare shortage** — 2 rares against the Goblin's 7, so at
  the reward weights she almost never sees one. Write rares, do not reweight.
  *Done when:* she has 5–7, in her own idiom (poison, ally-lifting, vines).
  [measured 2026-08-16]
- [ ] **6. The `type` field decides what it is** — every card carries
  `"attack"` / `"skill"` and nothing reads it. Either give it a mechanical
  meaning or drop it; a field that lies is worse than no field.
- [ ] **7. `location_3d.gd` `!is_inside_tree()` guard** — pre-existing, still
  there. Confirm whether it is masking a real ordering bug or is a legitimate
  guard, and either fix the cause or write down why it stays.
- [ ] **8. Deck view** — you cannot see your own deck mid-run outside a campfire.
  Every deckbuilder has this and its absence is felt.
- [ ] **9. More events** — 10 today, the EA target is 12–15. Hand-written, they
  bruise but never kill, stakes printed on the button.
- [ ] **10. Relics to ~30** — 26 today. Rule-changing, not number-changing
  (§3.4 of depth-plan).

## Needs Nick — do not start these

- **The art pass.** The single biggest gap to a Steam page, and entirely a
  taste-and-budget call. See the timeline discussion of 2026-08-16.
- **Whether iOS/Android testing is worth a Mac.** Costed in
  `design/mobile-setup.md`; the decision is his.
- **Global vs per-class reward pools.** 23 class cards also sit in the global
  pool. Which is authoritative is a design call, not a cleanup.
- **Is it fun.** No amount of unsupervised work answers this. It needs him, and
  then a stranger.

## Later — parked, not forgotten

- A resource-driven class [sts2-comparison §3.5]
- Daily / challenge modes
- Steam integration (lobbies, invites, achievements)
- Pinch-to-zoom on the overworld for touch
- Mid-combat saving (today the slot is written only between fights)

## Log

Newest first. One line per finished item: what, and anything surprising.

- _(nothing yet — the loop appends here)_
