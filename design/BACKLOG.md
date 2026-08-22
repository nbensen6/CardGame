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
- [x] **5. Vine-Weaver's rare shortage** — 2 rares against the Goblin's 7, so at `cloud-safe`
  the reward weights she almost never sees one. Write rares, do not reweight.
  *Done when:* she has 5–7, in her own idiom (poison, ally-lifting, vines).
  [measured 2026-08-16]
- [x] **6. The `type` field decides what it is** — every card carries `cloud-safe`
  `"attack"` / `"skill"` and nothing reads it. Either give it a mechanical
  meaning or drop it; a field that lies is worse than no field.
- [x] **7. `location_3d.gd` `!is_inside_tree()` guard** — pre-existing, still `cloud-safe`
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
- [ ] **23. Frog's rare shortage** `cloud-safe` — found while fixing #5: the `cloud-safe`
  Frog sits at 4 rares (`flurry_hop`, `crescendo`, `finale`, `grand_leap`), one
  under the 5-7 band #5 set for Vine-Weaver. Write 1-3 more in her rhythm/climb
  idiom, do not reweight. *Done when:* Frog has 5-7 rares, tested the same way.
  [measured 2026-08-22]

- [ ] **24. Named holds on a beast — the climb ENGINE** `cloud-safe` —
  Nick, 2026-08-22: the climb should have *spots* you choose, not just a number
  that goes up. Today a climb card adds N Height and that is the whole decision.
  Generalise `Boss.ledges` (a bare int array) into named holds — height, whether
  it is safe, and which moves it is exposed to — and let a climb card TARGET a
  hold rather than blindly add. That makes climbing positional: the high hold is
  closer to the sigil but in reach of the sweep, the low one is safe but slow.
  It is also the thing that makes item 25's drag meaningful, so build it first.
  *Done when:* holds are data, a card can name one, reaching one is tested, and
  the old "just add Height" path still works for cards that don't target.
- [ ] **25. Drag a card to the hold you want** `needs a screen` — the UI half of
  24, and Nick's other ask: pull a card out and drag it where you want to climb.
  **Design tension to resolve before building:** a timed card today is tap → the
  bar sweeps → tap to nail it. Adding drag makes that drag → release → bar → tap,
  which is three gestures for one card. Decide whether the release *starts* the
  bar, or whether targeted cards are simply never timed, before writing any of it.
  Still single-pointer, so CLAUDE.md §5 holds and it works on a phone.
- [ ] **26. Potions** `cloud-safe` (engine only) — the biggest Slay-the-Spire
  staple we do not have. Three slots, consumable, found from fights and shops;
  they are what lets a bad hand still be survivable, and their absence is why a
  bad draw here feels flat rather than tense. Data plus a generic apply, same
  shape as relics. *Done when:* potions are data, can be held, used and thrown
  away, persist through save/load, and are tested. The slots UI is a separate
  needs-a-screen item.
- [ ] **27. Status and curse cards** `cloud-safe` — cards that clog your deck
  rather than help it (StS's Burn, Dazed, Wound). We have no way for an event, an
  elite or a Titan to *punish* you into your own deck, which is a whole pressure
  the genre uses and we don't. Fits our idiom: a Titan that shakes you could
  shuffle in "Bruised Grip", a dead card that costs you a draw.
  *Done when:* they exist as data, can be inflicted, are removable at a campfire
  or shop, and are tested.
- [ ] **28. Retain and Innate** `cloud-safe` — two one-word card properties that
  StS gets enormous play out of. Retain: not discarded at end of turn. Innate:
  always in the opening hand. Both are a flag plus one line in the draw/discard
  path, and both create build decisions immediately.
- [ ] **29. X-cost cards** `cloud-safe` — spend ALL remaining energy, scale with
  how much. The classic end-of-turn dump, and it interacts well with our energy
  relics. `cost: -1` as the sentinel, resolved in `effective_cost`/`play_card`.
- [ ] **30. Relics with a downside** `cloud-safe` — every one of our 26 is pure
  upside, so taking one is never a decision. StS's boss relics cost you something
  (less energy, no potions, more damage taken) in exchange for power.
  *Done when:* at least 4 relics carry a real cost, and picking one is a choice.
- [ ] **31. A run-start boon** `cloud-safe` — StS opens with Neow: a free
  meaningful choice before the first fight that sets the run's direction. We drop
  you straight onto the map. *Done when:* one choice of 3-4 at run start, saved
  with the run, tested.
- [ ] **32. Potion slots and status feedback** `needs a screen` — the UI for 26
  and 27: three slots you can see and tap, and a clear cue when something clogs
  your deck. Deliberately separate so the engine can land without it.

- [ ] **33. Graded timing accuracy — the rules half** `cloud-safe` —
  Nick, 2026-08-22: make the timing osu-like. Today it is binary: `nailed` is a
  bool, so a hit dead-centre pays exactly what a hit scraping the edge does.
  Widen that to a quality tier (perfect / good / miss) and let the timed bonus
  scale with it. This is the whole rules half of the idea and needs no display:
  the seam is already narrow — `timing_resolved(hit)` -> `play_card(timing_hit)`
  -> `preview(nailed)`, four files.
  *Done when:* quality is carried end to end, the bonus scales, save/load is
  unaffected, and the existing 38 timing assertions still hold with "perfect"
  behaving exactly as today's "nailed" did.
- [ ] **34. osu-style hit circle at the hold** `needs a screen` — the display
  half, and the reason it is worth doing: a shrinking approach circle **placed at
  the hold you are climbing to** answers *where* and *when* in ONE gesture. That
  dissolves the three-gesture problem item 25 flagged, so 24 + 25 + 34 want
  building together rather than separately.
  **Build it behind a setting, keep the sweep bar.** This is the mechanic Nick
  said was landing ("double timing"), and a feel change of this size is not
  something tests can grade — it needs both playable side by side so he can pick.
  **Watch for:** the grip timer is ALREADY a live real-time pressure. An osu
  circle on top is two clocks at once, which may be thrilling or may be
  unplayable. That question is the point of the experiment.

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

- **2026-08-22** — #7 `location_3d.gd`'s `!is_inside_tree()` guard: audited, kept,
  and documented in place rather than removed — it is not masking a bug. Traced
  the actual race: `game_3d.gd` (the router) connects its `state_updated`
  listener before any child view exists, so on every emission the router always
  runs first; when the phase changes it removes+frees the old view *immediately*
  (deliberate, per its own comment, so two views don't render for a frame), but
  `queue_free()` doesn't disconnect signals, so the old view's own handler —
  connected later, so later in call order — still fires this same emission
  against a node that already left the tree. `combat_3d.gd`/`overworld_3d.gd`
  share the router but dodge it because their `_refresh` bails the instant
  `phase` isn't theirs, before touching anything tree-dependent; `location_3d.gd`
  can't use that trick since one scene covers seven different phases, hence its
  own guard. It was added in `0934ea9915b2` and took staging errors from 11 per
  staging to 0 — confirmed real, not speculative. Expanded the code comment with
  this trace so the next person (or the next unattended pass) doesn't have to
  re-derive it. No code behavior changed; `run_tests.gd` still green. Did not add
  a regression test — the existing suite only exercises `/core` and `/session`
  headless, never instantiates a `/views` scene, and standing up that harness for
  one guard is bigger than this item; flagging it here rather than doing it
  quietly.

- **6. The `type` field decides what it is** — gave it the field a real reader:
  `Combat.preview()`'s Strength/attack_bonus lift now gates on `card.type ==
  "attack"` instead of guessing from `card.damage > 0`. Auditing all 146 cards
  found exactly one place the two disagreed — `pollen_drift` was labelled
  `"attack"` with 0 base damage (a Poison-only card, like every other 0-damage
  Wound card in the set, all of which are `"skill"`) — so that was a data typo,
  not a design choice; fixed to `"skill"`. Because the one mismatch is now
  corrected, the new gate produces byte-identical combat numbers to the old one
  for all existing cards — this is a data-consistency and dead-field fix, not a
  balance change. Added `Content.all_card_ids()` (nothing enumerated the whole
  card set before) plus two tests: one walks every card asserting type agrees
  with dealing base damage, one proves Strength no longer lifts a skill-type
  card mechanically. `run_tests.gd` green (all pass, was already green before);
  `balance_sim.gd` smoke-tested only, not tuned to (win rates unchanged, as
  expected from a behavior-preserving fix).
- **(bookkeeping)** The previous run's three commits (items #1, #4, #5 done,
  plus the queue-deepening) looked stranded on a detached HEAD after `git
  checkout -B main origin/main` warned about "leaving 3 commits behind" — but
  a fetch showed `origin/main` already had them; the warning was just a stale
  local remote-tracking ref from before this session's first fetch. Fast-
  forwarded local `main` to match; nothing was actually lost or re-pushed.
  Noting it here since it cost a few minutes of investigation and the next
  run doesn't need to repeat it.
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
- **5. Vine-Weaver's rare shortage** — wrote 4 new rares in her existing idiom
  (poison-scaling `venom_cascade`/`withering_grasp`, ally-lifting `root_bond`,
  vines `verdant_weave`), reusing only existing card fields — no new mechanics,
  no reweighting. Added to her `reward_pool` in `characters.json`; she now has 6
  rares (was 2), in the 5-7 band the item asked for. Added
  `_test_vine_weaver_has_enough_rares`, scoped to her specifically rather than a
  blanket per-character rule — a generic version of that test also flagged the
  Frog at 4 rares, which is real but out of this item's scope, so I narrowed the
  test instead of fixing the Frog too (no new scope). `run_tests.gd` and
  `balance_sim.gd` (smoke test only, not tuned to) both clean.
