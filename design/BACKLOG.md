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

- [x] **1. Exhaust scaling for the Goblin** — one field, immediate depth. `cloud-safe`
  *Done when:* the field exists, at least three cards use it, tests cover it.
  [sts2-comparison §5.2]
- [ ] **2. Campfire relic upgrades** — a fourth campfire option ("empower a `needs a screen`
  relic") on top of the existing Rest / Thin / Sharpen and `Run.relic_totals()`.
  *Done when:* pickable at a campfire, persists, shows in the relic list.
  [sts2-comparison §3.2 — "nearly free"]
- [ ] **3. Card enchantments** — the big one, and the one with a mechanic only `needs a screen`
  this game can have: `sure`, a wider timing window, turning the real-time layer
  into a build decision. `data/enchants.json` + the `upgraded_copy()` trick.
  *Done when:* enchants are data, apply generically, are visible on the card
  face, and come from at least one source (campfire).
  [sts2-comparison §3.1 ⭐]
- [x] **4. Per-beast limiters** — a rule each Titan bends, so four Titans are `cloud-safe`
  four puzzles rather than four HP bars.
  *Done when:* at least the four Titans each carry one, expressed as data.
  [sts2-comparison §3.4]
- [ ] **5. Vine-Weaver's rare shortage** — 2 rares against the Goblin's 7, so at `cloud-safe`
  the reward weights she almost never sees one. Write rares, do not reweight.
  *Done when:* she has 5–7, in her own idiom (poison, ally-lifting, vines).
  [measured 2026-08-16]
- [ ] **6. The `type` field decides what it is** — every card carries `cloud-safe`
  `"attack"` / `"skill"` and nothing reads it. Either give it a mechanical
  meaning or drop it; a field that lies is worse than no field.
- [ ] **7. `location_3d.gd` `!is_inside_tree()` guard** — pre-existing, still `cloud-safe`
  there. Confirm whether it is masking a real ordering bug or is a legitimate
  guard, and either fix the cause or write down why it stays.
- [ ] **8. Deck view** — you cannot see your own deck mid-run outside a campfire. `needs a screen`
  Every deckbuilder has this and its absence is felt.
- [ ] **9. More events** — 10 today, the EA target is 12–15. Hand-written, they `cloud-safe`
  bruise but never kill, stakes printed on the button.
- [ ] **10. Relics to ~30** — 26 today. Rule-changing, not number-changing `cloud-safe`
  (§3.4 of depth-plan).

- [ ] **11. Beast move patterns** `cloud-safe` — seven beasts run 2–3 moves and
  the Crag Pup is literally two attacks, so a fight has no shape to read. Ten
  move types exist; use them. *Done when:* no beast has fewer than 4 moves or
  only one kind, and a test asserts it.
  [measured 2026-08-22]
- [ ] **12. The enchantment ENGINE** `cloud-safe` — the data-and-rules half of
  item 3, split out because only the card FACE needs a screen.
  `data/enchants.json` plus one generic apply on `Card`, the same trick
  `upgraded_copy()` already uses. *Done when:* enchants are data, apply
  generically to any card, round-trip through save/load, and are covered by
  tests. Do NOT touch the card face — that half is tagged needs-a-screen.
- [ ] **13. Relics that change a rule** `cloud-safe` — all 26 relics are the
  same `{effect, value}` number bump. depth-plan §4 asked for rule-changers and
  none exist. *Done when:* at least 6 relics alter a RULE (an extra timing
  window, climbing without losing grip, exhaust returning a card) rather than
  adding to a number, with tests.
  [measured 2026-08-22]
- [ ] **14. Mid-combat saving** `cloud-safe` — promoted from Later. Today the
  slot is only written between fights, so quitting mid-fight replays it.
  `Combat` is the one thing `Run.to_dict()` skips. *Done when:* hands, piles,
  footholds, block and the boss's pattern all survive a round trip, and the
  "refuses mid-fight" guard is replaced rather than deleted.
- [ ] **15. Save coverage for the other phases** `cloud-safe` — the save tests
  only exercise a run parked on the map. Shop stock, campfire progress and an
  in-flight event are all serialized and none are tested.
  *Done when:* a run saved in SHOP, CAMPFIRE and EVENT reloads intact.
- [ ] **16. Every card field a player must understand has a keyword**
  `cloud-safe` — keywords are derived from fields by `GameHost._keywords_of`;
  a field added without one silently ships an unexplained card.
  *Done when:* a test walks every field used by any card and fails on one that
  needs explaining and has no entry in keywords.json.
- [ ] **17. Events that touch the DECK** `cloud-safe` — the 10 events trade in
  HP and gold only. The interesting ones in this genre cost or change CARDS.
  *Done when:* at least 4 events add, remove, sharpen or burn a card, and the
  stakes are still printed on the button.
- [ ] **18. Content integrity test** `cloud-safe` — every card id named by a
  starter deck, a reward pool, a `create`/`prepare` field or an event resolves
  to a real card; same for beast ids and relic ids. A typo in data currently
  fails silently at runtime. *Done when:* one test proves the whole graph.
- [ ] **19. Shop and campfire test coverage** `cloud-safe` — buying, price
  rises on repeat removals, and each campfire action are rules nobody tests.
  *Done when:* covered, including that you cannot buy what you cannot afford
  and cannot thin a deck below `MIN_DECK`.
- [ ] **20. `weak_point_threshold` audit** `cloud-safe` — the per-visit sigil
  damage cap was tuned when sigils sat at Height 1–8. They now sit at 4–13 and
  nobody re-checked whether the cap still means anything.
  *Done when:* each beast's cap is justified against its new climb, or the field
  is removed as dead.
- [ ] **21. Unreachable content report in the Card Lab** `cloud-safe` —
  `tools/cardlab/build.js` already computes reachability. Extend it to name
  every card, relic and event that no pool can offer.
  *Done when:* the Health tab lists them, and the build prints a count.
- [ ] **22. Ascension tiers apply what they claim** `cloud-safe` — eight tiers
  exist in data and the sim walks them, but no test proves a tier's modifier
  actually reaches combat. *Done when:* each modifier key is asserted at the
  tier that introduces it.

## Where the work happens

Two places, and they can do different things.

**Nick's machine** (an interactive session) has Godot with a display, so it can
run `tools/screenshot.gd` and *look* at what it built. Anything whose
correctness is visual belongs here.

**The cloud routine** (fires every 2 hours, survives Nick closing his terminal
and picks up after a usage reset) clones the GitHub repo into a Linux sandbox.
It can read and write code and data, and it can run the headless test suite
after downloading Godot — but it has **no display**, so `screenshot.gd` cannot
run: the harness needs a real rendered frame and says so in its own header.

That is why every queue item is tagged:

- `cloud-safe` — data and logic, provable by the test suite alone.
- `needs a screen` — the cloud routine must **skip it and move down the list**,
  not attempt it blind. Shipping a UI change nobody looked at has been wrong
  before, and doing it unattended is worse.

If every remaining item needs a screen, the routine should stop and say so
rather than inventing work.

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

- **4. Per-beast limiters** — added `Boss.limiter` ({type, value}, data-only) and
  one generic `Combat._apply_limiter()` dispatch, mirroring the existing move-type
  match. Three types: `wound_decay` (sheds Wound/turn — punishes stack-and-wait
  Poison), `sigil_fatigue` (chips a hunter camped at the sigil past an allowance),
  `height_split` (chips a hunter who's climbed far past their ally, unsupported).
  Assigned across the four Titans (stone_warden: height_split, gale_serpent +
  sunken_warden: sigil_fatigue at different thresholds, drowned_colossus:
  wound_decay) so two share a mechanic at different tuning rather than forcing a
  fourth distinct type for its own sake. 4 new tests plus a content-integrity
  check that every Titan's limiter type actually resolves. `run_tests.gd` and
  `balance_sim.gd` (smoke test only, not tuned to) both clean.
- **1. Exhaust scaling for the Goblin** — turned out already done: `cards.json`
  has 5 cards using `damage_per_exhausted`/`block_per_exhausted` (well past the
  "three cards" bar), and `run_tests.gd` already covers it. No code changed —
  ticking it off so the next iteration doesn't re-derive this. Worth a beat: this
  queue was written 2026-08-16 without checking the tree first, so an item can go
  stale between writing and working it.
