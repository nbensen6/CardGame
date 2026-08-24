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
9. **Fetch before trusting `origin/main`.** A fresh container's cached
   `origin/main` ref can be behind the real GitHub tip (seen 2026-08-23: 17
   commits behind, including a prior session's own finished work on the item
   this session picked). Run `git fetch origin main` and diff
   `design/BACKLOG.md` against `origin/main` before starting — not just before
   pushing — or unsupervised work can silently redo something already done.

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
- [x] **9. More events** — 10 today, the EA target is 12–15. Hand-written, they `cloud-safe`
  bruise but never kill, stakes printed on the button.
- [x] **10. Relics to ~30** — 26 today. Rule-changing, not number-changing `cloud-safe`
  (§3.4 of depth-plan).

- [x] **11. Beast move patterns** `cloud-safe` — seven beasts run 2–3 moves and
  the Crag Pup is literally two attacks, so a fight has no shape to read. Ten
  move types exist; use them. *Done when:* no beast has fewer than 4 moves or
  only one kind, and a test asserts it.
  [measured 2026-08-22]
- [x] **12. The enchantment ENGINE** `cloud-safe` — the data-and-rules half of
  item 3, split out because only the card FACE needs a screen.
  `data/enchants.json` plus one generic apply on `Card`, the same trick
  `upgraded_copy()` already uses. *Done when:* enchants are data, apply
  generically to any card, round-trip through save/load, and are covered by
  tests. Do NOT touch the card face — that half is tagged needs-a-screen.
- [x] **13. Relics that change a rule** `cloud-safe` — all 26 relics are the
  same `{effect, value}` number bump. depth-plan §4 asked for rule-changers and
  none exist. *Done when:* at least 6 relics alter a RULE (an extra timing
  window, climbing without losing grip, exhaust returning a card) rather than
  adding to a number, with tests.
  [measured 2026-08-22]
- [x] **14. Mid-combat saving** `cloud-safe` — promoted from Later. Today the
  slot is only written between fights, so quitting mid-fight replays it.
  `Combat` is the one thing `Run.to_dict()` skips. *Done when:* hands, piles,
  footholds, block and the boss's pattern all survive a round trip, and the
  "refuses mid-fight" guard is replaced rather than deleted.
- [x] **15. Save coverage for the other phases** `cloud-safe` — the save tests
  only exercise a run parked on the map. Shop stock, campfire progress and an
  in-flight event are all serialized and none are tested.
  *Done when:* a run saved in SHOP, CAMPFIRE and EVENT reloads intact.
- [x] **16. Every card field a player must understand has a keyword**
  `cloud-safe` — keywords are derived from fields by `GameHost._keywords_of`;
  a field added without one silently ships an unexplained card.
  *Done when:* a test walks every field used by any card and fails on one that
  needs explaining and has no entry in keywords.json.
- [x] **17. Events that touch the DECK** `cloud-safe` — the 10 events trade in
  HP and gold only. The interesting ones in this genre cost or change CARDS.
  *Done when:* at least 4 events add, remove, sharpen or burn a card, and the
  stakes are still printed on the button.
- [x] **18. Content integrity test** `cloud-safe` — every card id named by a
  starter deck, a reward pool, a `create`/`prepare` field or an event resolves
  to a real card; same for beast ids and relic ids. A typo in data currently
  fails silently at runtime. *Done when:* one test proves the whole graph.
- [x] **24. Named holds on a beast — the climb ENGINE** `cloud-safe` —
  Nick, 2026-08-22: the climb should have *spots* you choose, not just a number
  that goes up. Today a climb card adds N Height and that is the whole decision.
  Generalise `Boss.ledges` (a bare int array) into named holds — height, whether
  it is safe, and which moves it is exposed to — and let a climb card TARGET a
  hold rather than blindly add. That makes climbing positional: the high hold is
  closer to the sigil but in reach of the sweep, the low one is safe but slow.
  It is also the thing that makes item 25's drag meaningful, so build it first.
  *Done when:* holds are data, a card can name one, reaching one is tested, and
  the old "just add Height" path still works for cards that don't target.
- [x] **33. Graded timing accuracy — the rules half** `cloud-safe` —
  Nick, 2026-08-22: make the timing osu-like. Today it is binary: `nailed` is a
  bool, so a hit dead-centre pays exactly what a hit scraping the edge does.
  Widen that to a quality tier (perfect / good / miss) and let the timed bonus
  scale with it. This is the whole rules half of the idea and needs no display:
  the seam is already narrow — `timing_resolved(hit)` -> `play_card(timing_hit)`
  -> `preview(nailed)`, four files.
  *Done when:* quality is carried end to end, the bonus scales, save/load is
  unaffected, and the existing 38 timing assertions still hold with "perfect"
  behaving exactly as today's "nailed" did.
- [x] **19. Shop and campfire test coverage** `cloud-safe` — buying, price
  rises on repeat removals, and each campfire action are rules nobody tests.
  *Done when:* covered, including that you cannot buy what you cannot afford
  and cannot thin a deck below `MIN_DECK`.
- [x] **20. `weak_point_threshold` audit** `cloud-safe` — the per-visit sigil
  damage cap was tuned when sigils sat at Height 1–8. They now sit at 4–13 and
  nobody re-checked whether the cap still means anything.
  *Done when:* each beast's cap is justified against its new climb, or the field
  is removed as dead.
- [x] **21. Unreachable content report in the Card Lab** `cloud-safe` —
  `tools/cardlab/build.js` already computes reachability. Extend it to name
  every card, relic and event that no pool can offer.
  *Done when:* the Health tab lists them, and the build prints a count.
- [x] **22. Ascension tiers apply what they claim** `cloud-safe` — eight tiers
  exist in data and the sim walks them, but no test proves a tier's modifier
  actually reaches combat. *Done when:* each modifier key is asserted at the
  tier that introduces it.
- [x] **23. Frog's rare shortage** `cloud-safe` — found while fixing #5: the `cloud-safe`
  Frog sits at 4 rares (`flurry_hop`, `crescendo`, `finale`, `grand_leap`), one
  under the 5-7 band #5 set for Vine-Weaver. Write 1-3 more in her rhythm/climb
  idiom, do not reweight. *Done when:* Frog has 5-7 rares, tested the same way.
  [measured 2026-08-22]

- [ ] **25. Drag a card to the hold you want** `needs a screen` — the UI half of
  24, and Nick's other ask: pull a card out and drag it where you want to climb.
  **Design tension to resolve before building:** a timed card today is tap → the
  bar sweeps → tap to nail it. Adding drag makes that drag → release → bar → tap,
  which is three gestures for one card. Decide whether the release *starts* the
  bar, or whether targeted cards are simply never timed, before writing any of it.
  Still single-pointer, so CLAUDE.md §5 holds and it works on a phone.
- [x] **26. Potions** `cloud-safe` (engine only) — the biggest Slay-the-Spire
  staple we do not have. Three slots, consumable, found from fights and shops;
  they are what lets a bad hand still be survivable, and their absence is why a
  bad draw here feels flat rather than tense. Data plus a generic apply, same
  shape as relics. *Done when:* potions are data, can be held, used and thrown
  away, persist through save/load, and are tested. The slots UI is a separate
  needs-a-screen item.
- [x] **27. Status and curse cards** `cloud-safe` — cards that clog your deck
  rather than help it (StS's Burn, Dazed, Wound). We have no way for an event, an
  elite or a Titan to *punish* you into your own deck, which is a whole pressure
  the genre uses and we don't. Fits our idiom: a Titan that shakes you could
  shuffle in "Bruised Grip", a dead card that costs you a draw.
  *Done when:* they exist as data, can be inflicted, are removable at a campfire
  or shop, and are tested.
- [x] **28. Retain and Innate** `cloud-safe` — two one-word card properties that
  StS gets enormous play out of. Retain: not discarded at end of turn. Innate:
  always in the opening hand. Both are a flag plus one line in the draw/discard
  path, and both create build decisions immediately.
- [x] **29. X-cost cards** `cloud-safe` — spend ALL remaining energy, scale with
  how much. The classic end-of-turn dump, and it interacts well with our energy
  relics. `cost: -1` as the sentinel, resolved in `effective_cost`/`play_card`.
- [ ] **29b. X-cost card face** `needs a screen` — item 29's engine landed but
  no real card uses `cost: -1` yet: `game_host.gd`'s reward-choice and
  deck-view dicts (lines building `"cost": rc.cost` / `"cost": c.cost`, unlike
  the combat-hand list which already calls `effective_cost`) and the three
  view casts that print it (`card_view.gd`'s cost label, `combat_3d.gd`,
  `location_3d.gd`) all do a raw `int(cost)` — an X-cost card there would show
  a literal "-1". Needs a screen to fix (render "X" instead) and confirm
  before any real card can safely use the sentinel outside a live hand.
  *Done when:* those three spots show "X", at least one real card ships with
  `cost: -1`, and it's been looked at.
- [x] **30. Relics with a downside** `cloud-safe` — every one of our 26 is pure
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

- [x] **34. osu-style hit circle at the hold** `needs a screen` — the display
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

- [ ] **35. Migrate saves instead of throwing them away** `cloud-safe` — the
  save carries `VERSION := 1` and `run_save.gd` **rejects** any file that does
  not match it. Every field the routine adds is a change to the run's shape, so
  the day someone bumps that constant every run in progress is silently deleted.
  Rejection is the right default for a corrupt file and the wrong one for an old
  one. *Done when:* an older save is upgraded field-by-field to the current
  shape rather than discarded, a genuinely unreadable file still refuses
  cleanly, and a test loads a fixture written in the previous shape.

- [ ] **36. Frail, Artifact and Thorns** `cloud-safe` — the debuff axis we do
  not have. Today a hunter carries Strength, Wound and Vulnerable: everything
  points at the damage number. Nothing touches BLOCK, nothing RESISTS a debuff,
  and nothing punishes the act of attacking. Those three are one field each and
  they change what a turn is worth rather than how big it is. Thorns in
  particular reads naturally on a Titan — a spined beast that costs you to touch
  it. *Done when:* each is a field, at least two cards or relics and one beast
  apply them, and each has a test.

- [ ] **37. Events that know potions exist** `cloud-safe` — 17 events, and not
  one of them mentions a potion, because all 17 were written before item 26
  landed. The genre's best events trade in every currency the run has — HP, gold,
  cards, relics, potions — and ours only trade in four of the five. *Done when:*
  at least four events grant, take, or gamble a potion, and the content
  integrity test proves every potion id they name resolves.

- [ ] **38. A seed you can share** `cloud-safe` — runs are seeded, but the seed
  is an internal number nobody can see or set. Being able to type one in is how
  a bug report becomes reproducible and how two people race the same run — worth
  far more to us than to a single-player game, because we are co-op. *Done
  when:* the seed is readable, a run can be started from a given one, and a test
  proves two runs from the same seed make identical maps, shops and rewards.

- [ ] **39. A run summary worth showing at the end** `cloud-safe` — nothing is
  counted over a run: not damage dealt, not the highest climb reached, not cards
  played, turns taken, or what killed you. So a finished run says nothing about
  itself, and we have no way to tell a close win from a walkover. This is the
  DATA half only; the screen that shows it is someone else's item. *Done when:*
  a stats block accumulates through the run, survives save and load, and is
  tested.

- [ ] **40. Beast moves that react to where you are** `cloud-safe` — every move
  fires on a fixed rotation regardless of the board. A Titan cannot notice that
  you are clinging to its sigil. One optional `when` condition on a move (above
  or below a height, at the sigil, a hunter undefended) turns the climb into
  something the beast answers, and it is the cheapest depth available because
  the moves are already data. *Done when:* the condition is a data field with a
  fallback move when it fails, at least three beasts use it, and it is tested.

- [ ] **41. Shops and campfires should trade in potions** `cloud-safe` — item 26
  built potions and nothing sells them. `Run.shop_stock` offers cards and a
  removal; the campfire offers rest and the other options. So the only way to
  hold a potion is whatever grants one in a fight, which makes three slots of
  inventory mostly decorative. *Done when:* the shop stocks potions at a price,
  a full inventory is handled rather than silently dropping the purchase, and
  both are tested.

- [ ] **42. Something to unlock between runs** `cloud-safe` — `Progress` remembers
  your ascension, your hints, your keybinds and your wins, and nothing else. A
  loss therefore leaves you with exactly what you started with, which is the one
  thing the genre never does: StS drips new cards and relics into the pool for
  dozens of hours. We have 152 cards and 30 relics all available from run one.
  *Done when:* a gated subset unlocks on defined events, the pool respects it,
  it persists, and it is tested. Keep the gate small — this is a hook to hang
  progression on, not a rebalance of what is offered.

- [ ] **43. One trigger point instead of scattered special cases** `cloud-safe` —
  there is no generic "when X happens, run Y". Every timed effect, relic and
  passive is wired at its own call site, so each new one costs another branch in
  `combat.gd` and the file grows a special case per idea. A small set of named
  moments (turn start, turn end, card played, damage taken, hunter climbs) that
  relics, potions and cards all subscribe to would make the next twenty pieces
  of content data rather than code. *Done when:* the moments exist, at least
  three existing effects are moved onto them with no behaviour change, and the
  suite proves the behaviour did not change.

- [ ] **44. Titans that change their pattern when hurt** `cloud-safe` — every
  beast runs one fixed rotation from full health to zero, so the back half of a
  fight is the front half with smaller numbers. A second move list that takes
  over below a health threshold is the genre's standard answer and ours is
  cheap, because moves are already data. It also suits the fiction: a beast that
  has been climbed for five rounds should start behaving like it. *Done when:*
  the threshold and the second list are data fields, at least three beasts use
  them, the switch is visible in the telegraph, and it is tested.

- [ ] **45. Prove the new mechanics cross the client/server boundary**
  `cloud-safe` — potions, curses, Retain, Innate, named holds and graded timing
  all landed as `/core` rules with `/core` tests. This is a CO-OP game: the
  thing that actually breaks is the snapshot boundary, where a field exists on
  the host and never reaches the peer, or reaches only the peer who owns it.
  `game_host.gd` decides what each peer sees, and none of these were added with
  a two-peer test. *Done when:* each of those six is exercised through a real
  host/client pair, including what the ALLY should and should not see.

- [ ] **46. A robustness sweep that is not balance tuning** `cloud-safe` — we
  have `balance_sim.gd`, which the standing rule says not to tune to, and that
  rule has left the whole simulation unused. But there is a question it can
  answer that has nothing to do with win rates: does a run ever get STUCK. No
  playable card and no energy, a climb that cannot progress, a shop that offers
  nothing affordable with no exit, an event with no valid choice. *Done when:*
  a sweep of many seeded runs asserts every state has at least one legal action
  and every run terminates, and it fails loudly on a soft-lock. Report crashes
  and dead ends only — never win rates.

## Working alongside the cloud routine

Two of us push to `main`: the routine every two hours, and Nick-and-Claude in a
session. That works, but it has an order to it.

**The routine builds engines; the session builds faces.** Almost everything
tagged `needs a screen` is the visible half of something the routine already
built invisibly — enchantments have rules but no card face, potions will have
rules but no slots. So the queue is ordered so the ENGINE lands before the
session that puts a face on it. Items 24 and 33 were promoted to the front on
2026-08-23 for exactly this reason: 25, 32 and 34 are their faces, and building a
face for an engine that does not exist yet is the one way to waste a session.

**Before a session, pull.** The routine always starts from `origin/main`, so it
picks up session work automatically — but the session does not pick up the
routine's work unless someone fetches.

**If a push is rejected**, a routine run landed while the session was working.
Fetch, rebase on top, re-run the tests, push again. Never force.

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

- **2026-08-24** — #30 Relics with a downside: a downside is just a SECOND
  `{effect, value}` pair on the same relic — `downside_effect`/`downside_value`,
  optional keys read by `Run.relic_totals()` through the exact same
  `_apply_relic_effect()` match statement the primary effect already used
  (pulled out into its own function so both calls share it, rather than
  duplicating the match arm), so a downside needed zero new mechanic, only a
  second pass through an existing generic rule — matches rule 7. Four new
  relics, each a real StS-boss-relic-style trade rather than a token cost:
  `Warlord's Girdle` (+6 attack / -1 Energy each round), `Bottomless Quiver`
  (+3 draw / -3 attack), `Fortress Ward` (+10 round Block / -1 draw), and
  `Adrenal Surge` (+2 Energy / -4 round Block). Found a real bug chasing this:
  `Combat._begin_round()` set `ps.combatant.block = _round_block + carried`
  and `ps.energy = BASE_ENERGY + _energy_bonus` with no floor — harmless while
  every relic was additive, but a downside relic pushing either negative
  would have handed `Combatant.take_damage()` a negative starting `block`,
  and its `absorbed := mini(block, remaining)` line assumes block is never
  negative: a negative block makes `absorbed` negative too, which then
  *adds* to `remaining` (damage taken) instead of reducing it, compounding
  worse each hit taken that round. Added `maxi(0, ...)` at both assignments
  before shipping anything that could trigger it — a genuine correctness fix
  the item's own "done when" didn't name, but the sentinel demanded once a
  relic could actually drive either stat negative. `draw`'s downside needed
  no equivalent fix — `_begin_round()`'s own draw call already reads
  `maxi(0, HAND_SIZE + _mod("draw") - innate_drawn)` — and `attack_bonus`'s
  needed none either, since `resolve_preview()` already floors the final
  damage number at 0 regardless of how negative the bonus gets. New test
  proves both the additive stacking (two relics' round_block downside/upside
  net out correctly through `relic_totals()`) and the floor itself (a
  synthetic -5/-20 bonus through `_relic_combat()` lands at exactly 0, not
  negative). `run_tests.gd` all green (213 assertions incl. the new one);
  `node tools/cardlab/build.js` confirms all four new relics reachable
  (34 relics, `unreachable: 0`); `balance_sim.gd` ran clean as a smoke test
  only — its policies pick relics by existing logic unrelated to this item,
  so nothing here was tuned to its win-rate output.
- **2026-08-24** — #34 osu-style hit circle: built as a SECOND FACE over the
  grading #33 already shipped, not a replacement. `ui/hit_circle.gd` opens an
  approach ring on the beast at the Height the card would take you to (reusing
  `_place_hunters`' own Height->world mapping, so it can't drift from the body),
  and emits the same `resolved(quality)` the card face does — nothing downstream
  can tell which face the player used. Toggle in Settings; the bar stays, because
  the bar is the part Nick has already said feels good and swapping it out on a
  hunch would throw that away. Surprise: `tools/screenshot.gd` writes to
  `Progress`, so every screenshot ever taken has been editing the designer's real
  settings — it would have flipped this new one too. `Progress.path` is now
  redirectable like `RunSave.path` and the harness uses a scratch file. New
  `3dosu` / `3dbar` states; the grading probes assert perfect/good/miss at three
  offsets, which caught that a GDScript lambda captures by value and my first
  probe could never have reported anything.

- **2026-08-24** — #29 X-cost cards: `cost == -1` is the sentinel, resolved in
  exactly the two places the item named. `Combat.effective_cost()` now returns
  the hunter's CURRENT energy for an X-cost card instead of `card.cost` minus
  permanent reductions — Burn Coal-style reductions don't apply to a cost
  that isn't a fixed number, which a dedicated test pins deliberately rather
  than leaving implicit. `Combat.play_card()` captures that amount (`x_spent`)
  BEFORE draining `ps.energy` to zero, then threads it into `preview()` as a
  new optional param so the same formula used for the live card-face preview
  (energy still full, reads `ps.energy` directly) also resolves the actual
  play (energy already spent, needs the captured value instead) — one formula,
  two callers, same shape the file's own doc comment already insists on for
  every other scaling field. Two new `Card` fields, `damage_per_x`/
  `block_per_x`, same shape as the existing `damage_per_exhausted`/
  `block_per_exhausted` pair. Two smaller correctness fixes the item's own
  text didn't spell out but the sentinel demands: `_meld_cards()` used to sum
  `a.cost + b.cost - 1`, which would silently turn `-1` into a real (wrong)
  number the moment an X-cost card was ever melded with anything — it now
  keeps the sentinel if either side has it, and sums the two new per_x fields
  like every other numeric field already does; `upgraded_copy()`'s "nothing to
  scale, make it cheaper" fallback only fires when `cost > 0`, so it already
  left `-1` alone without needing a guard, and its bump list now includes the
  two new per_x fields so sharpening an X-cost card does something. Wired a
  `x_cost` entry into `keywords.json` and `GameHost._keywords_of` — #16's
  reflection test forces this for any new field, caught automatically since it
  probes `damage_per_x`/`block_per_x` in isolation.
  **Deliberately no real card**: chasing down where a card's cost actually
  gets displayed found three spots that never learned about the sentinel —
  `game_host.gd`'s reward-choice and deck-view dicts both send the card's raw
  `.cost` (unlike the combat-hand list a few lines above them, which already
  calls `effective_cost()` for exactly this reason), and `card_view.gd` /
  `combat_3d.gd` / `location_3d.gd` all print it with a bare `int(cost)`. A
  real X-cost card offered as a reward or sitting in a deck would show a
  literal "-1" on screen — a real, visible bug I can't fix blind and can't
  verify without a screen (hard rule 3), so rather than ship it and hope,
  proved the mechanic entirely against `Combat` with synthetic test cards
  (`_x_strike`/`_x_brace`, the same shape every other test-only card in this
  suite already uses) and logged the gap as new queue item **29b** (`needs a
  screen`) rather than silently leaving the engine unreachable-by-design
  forever. 5 new tests: live cost reads current energy, damage/block scale
  with what was actually spent, playable (and inert, not crashing) at zero
  energy, a permanent reduction is ignored, and the meld interaction. Also
  covered the upgrade-bump path directly. `run_tests.gd` all green (7 new
  assertions on top of the existing suite, no regressions); `balance_sim.gd`
  ran clean as a smoke test only — no policy calls an X-cost card since none
  exists in `cards.json` yet, so the printed win rates are from other
  sessions' content growth, not anything touched here.
  **Also:** confirmed `git fetch origin main` matched the container's
  initial detached-HEAD checkout exactly (`47464f8`, 42 commits ahead of a
  stale cached ref this session almost trusted at first) before starting —
  rule 9 held, no duplicate work this time.
- **2026-08-24** — #28 Retain and Innate: two `bool` fields on `Card`
  (`retain`, `innate`), each a flag plus one line in the draw/discard path,
  same shape rule 7 asks for. `retain`: `Combat.end_turn()`'s discard loop now
  splits kept cards from discarded ones (`if c.retain: kept.append(c) else:
  discard_pile.append(c)`) instead of unconditionally emptying the hand — a
  retained card doesn't reduce next round's draw, so it sits ON TOP of a full
  fresh hand, same as StS. `innate`: a new `_draw_innate()` pulls every innate
  card straight out of the (already-shuffled) draw pile into the opening hand,
  gated to `round_num == 1` only, and the normal `_draw()` call right after it
  is shortened by however many it pulled — so an innate card fills a slot in
  the guaranteed hand rather than adding a 6th card, which is what "guaranteed
  in the opening hand" actually means (confirmed against StS's own Innate,
  not invented). Two new global cards prove both end-to-end rather than
  leaving the fields unconsumed: `Bunker Down` (retain, common, in the
  existing "Brace" defensive slot but weaker block for the flexibility) and
  `First Strike` (innate, uncommon, a slightly-worse Slash traded for
  guaranteed turn-1 access) — both added to `data/cards.json`'s global
  `reward_pool`, confirmed reachable with `node tools/cardlab/build.js`
  (`unreachable: 0 cards`). Wired `retain`/`innate` into
  `GameHost._keywords_of` and `keywords.json` (#16's reflection test forces
  this for any new bool field — caught it immediately when the two fields
  were declared with no keyword branch yet). 4 new tests: retain keeps a card
  in hand at end of turn while an ordinary one still discards, a retained
  card survives into next round on top of the fresh draw (hand size
  `HAND_SIZE + 1`, proving it isn't a one-shot skip), innate is present in
  the opening hand at the normal hand size (NOT `HAND_SIZE + 1` — my first
  draft of that assertion was wrong and the run caught it as a real FAIL,
  not a rubber-stamp), and innate does not reappear every round once played
  and gone. `run_tests.gd` all green (205 assertions incl. the four new
  ones); `balance_sim.gd` ran clean as a smoke test only — neither new card
  is drafted by the sim's own logic paths differently from any other common/
  uncommon, so the printed win rates are unaffected, not tuned to.
  **Also:** this session's `git checkout -B main origin/main` (before any
  fetch, per the task's own step 0) again pinned to a stale cached ref —
  landed on 32dc550, 36 commits behind the real tip (e6f952f). Built and
  committed a full duplicate of #1 (exhaust scaling for the Goblin, already
  `[x]` upstream — just missing test coverage for `block_per_exhausted`,
  which this session's version happened to add too) before `git push` was
  rejected as non-fast-forward. Per rule 9: fetched, branched off the
  unpushed commit as `stale-work-f00ac60` rather than deleting it outright
  (in case the block_per_exhausted test coverage gap it fixed is worth
  someone cherry-picking later — it isn't merged into `main` and isn't
  pushed), reset `main` cleanly to the real `origin/main`, and re-read the
  queue fresh before picking #28. Same recurring pattern the log has now
  named at least ten times; not re-investigating the container-init root
  cause here either, but it is still happening on the newest, largest gap
  yet and step 0 of this routine's own instructions still does the naive
  checkout before any fetch — that step, not just rule 9's advice, may be
  worth revising.
- **2026-08-24** — #27 Status and curse cards: added a `status: bool` field to
  `Card` (data/rules only — no new mechanic needed, since a card with no
  effect fields set already resolves to "cost energy, do nothing" for free)
  and one card, `bruised_grip` (cost 1, status, no fields). Kept it OUT of
  every starter deck and reward pool — the whole point is you don't draft a
  curse, something inflicts it on you — and proved that with a dedicated
  test walking every status card against every pool. The inflicting path
  reuses #17's exact shape: a new event effect key, `curse_card: "<id>"`,
  handled in `Run.pick_event()` right next to `remove_card`/`sharpen_card` —
  each hunter's deck gets one copy, unconditionally (unlike the other two,
  never a coin flip, since opting out would defeat the point). Wired it to
  one real event, `the_shaken_pitch` (push on rattled for gold + a curse, or
  stop and eat a small heal cost) rather than leaving the mechanic
  reachable-in-theory-only. Removability needed no new code at all — the
  existing campfire/shop "remove" paths already operate on a deck index
  without caring what the card is — but added explicit tests proving it
  anyway rather than assuming. Did add one real guard: campfire "upgrade"
  now refuses a status card (nothing to sharpen on a card with no numbers),
  tested. First pass shipped a second card, `winded`, before checking it
  against anything — `node tools/cardlab/build.js` flagged it unreachable
  (nothing in `starter_deck`/`reward_pool`/`create`/`prepare` OR the new
  `curse_card` path pointed at it), so it was dead content by the exact
  standard #21 exists to catch; deleted it rather than inventing a second
  use to justify keeping it. That check needed a small extension of its
  own first — `build.js`'s reachability graph only knew about
  `create`/`prepare` chains, so `bruised_grip` itself briefly read as
  unreachable too until a `cursedBy` set (same shape `createdBy`) was added
  alongside it; `unreachable: 0 cards` after. 4 new test functions: the event effect
  itself, the campfire sharpen-refusal (and that removal still works there),
  shop removal, and the never-drafted sweep; extended `_test_content_integrity_graph`
  (#18) to validate `curse_card` refs the same way it already validates
  `create`/`prepare`. `run_tests.gd` all green (201 assertions incl. the new
  ones); `balance_sim.gd` ran clean as a smoke test only (its policies
  don't touch events, so the numbers are unchanged, not tuned to).
  **Also:** this session's initial `git checkout -B main origin/main` (before
  any fetch) again reported the stale-detached-HEAD pattern rule 9 already
  names — 31 commits this time, past 2026-08-24's own prior record of 30.
  A fetch confirmed the real GitHub tip already had every one of them
  (merge-base *was* the old cached tip, a clean fast-forward, nothing to
  push) — the same false alarm logged five times running now, just still
  growing. Not re-investigating the root cause again here either, but five
  in a row on a monotonically growing gap is past "noise" — worth Nick
  looking at the container-init snapshotting directly rather than this
  routine keep re-discovering the symptom.
- **2026-08-24** — #26 Potions: the engine half, same shape as relics
  (`data/potions.json` — `{name, effect, value, text}` — plus one generic
  dispatch), but held PER-HUNTER rather than team-wide, since a potion is a
  private resource like a hand or a deck. Added `Run.potions` (`Array[Array]`,
  `POTION_SLOTS = 3` per hunter), `Combat.use_potion(pi, effect, value)`
  (heal/block/strength/energy/draw, reusing the exact methods a relic or card
  already calls — `Combatant.gain_block`, `PlayerState.strength/energy`,
  `Combat._draw`), and on `Run`: `use_potion` (mid-fight only — forwards to
  Combat, empties the slot on success), `discard_potion` (any time, no
  effect), and `_grant_potions` (every beast felled pays each hunter with a
  free slot one potion, same unconditional shape gold already uses — a coin
  flip would've been harder to test for no real benefit). Shops also stock one
  potion per hunter (`PRICE_POTION = 45`) through the same `buy()` dispatch
  cards/relics/removals already use. A full 3-slot inventory refuses both a
  win's drop and a shop purchase rather than silently discarding — "can be
  held" implied a real cap, not an infinite bag. 10 potions across the 5
  effect types (2 per type, a cheap/strong pair) — deliberately not gated
  behind rarity or a character's pool the way cards are, since nothing in the
  item asked for that and every hunter can use any of them. Left the potion
  SLOTS UI (seeing/tapping them) untouched — that's item #32, already split
  out as `needs a screen`, and this item's own "done when" only asked for
  held/used/thrown-away/persisted/tested, all of which are true with zero
  view code. 13 new tests: data integrity, each effect in isolation plus an
  unknown-effect refusal, three gating cases (bad player index, already-ended
  turn, wrong phase — set `combat.phase` directly rather than fighting the
  real turn loop, since `_enemy_turn()` always lands back on `PLAYERS` before
  `end_turn()` even returns), Run-level use+discard, a shop purchase, the
  full-inventory cap against both acquisition paths, the win-grants-a-potion
  path, and a save/load round trip through the actual file (JSON's
  one-number-type gotcha, same reason the existing save tests go through
  `RunSave` rather than a bare `to_dict()`/`from_dict()` pair). `run_tests.gd`
  all green (196 assertions incl. the 13 new ones); no old
  save predates this field, but `Run.from_dict` backfills empty potion arrays
  for hunter counts anyway, matching the defensive pattern `combat`'s own
  from_dict fallback already uses. `balance_sim.gd` ran clean as a smoke test
  only — the sim's policies don't call `use_potion` at all yet (they're a
  separate concern, not this item's scope), so the numbers it printed are
  unchanged from before this landed, not tuned to.
  **Also:** this session's initial `git checkout -B main origin/main` (before
  any fetch) warned about leaving 30 commits behind on a detached HEAD — by
  far the largest gap logged yet for this pattern, and worth Nick's attention
  even though rule 9 already exists for it: a `git fetch origin main` showed
  the real GitHub tip was `56809ae` (#23, the log entry directly below),
  already containing all 30 — nothing was actually lost, just a badly stale
  container-init snapshot. This is the same false alarm named seven times
  before (2026-08-22 through 2026-08-24), just at a new size record; not
  re-investigating the root cause again here, but the growing gap size is a
  signal the container's initial checkout is drifting further behind between
  routine firings than it used to.
- **2026-08-24** — #23 Frog's rare shortage: hit the exact same stale-`origin/main`
  failure the two log entries below already name — checked out a cached tip that
  didn't have items 11-33 on it yet, redid #4 (per-beast limiters) a third time
  with yet another design (`Boss.limiter` {type, value} dict), tests green, push
  rejected non-fast-forward. Fetched, diffed, found the real #4 already merged;
  discarded the unpushed commit with `git reset --hard origin/main` (never
  reached the remote) and re-read the queue against the real tip. #23 was the
  true topmost open `cloud-safe` item: Frog sat at 4 rares
  (`flurry_hop`/`crescendo`/`finale`/`grand_leap`) against the 5-7 band #5 set
  for the Vine-Weaver. Added two, reusing only existing card fields (no new
  engine scope): `Ripple Leap` (a climb/ally-support rare — every existing Frog
  rare was an attack, so this is her first support payoff) and `Encore` (an
  attack combining `damage_per_rhythm` and `damage_per_vulnerable`, a scaling
  pair none of her other rares used). Brings her to 6, matching the
  Vine-Weaver's count. Added `_test_frog_has_enough_rares`, same shape as the
  Vine-Weaver's existing test. `run_tests.gd` and `balance_sim.gd` (smoke test
  only) both ran clean.
- **2026-08-24** — #22 Ascension tiers apply what they claim: same failure mode
  rule 9 warns about bit this session too — checked out a stale cached
  `origin/main`, redid #4 (per-beast limiters) from scratch with a different
  approach (extra moves instead of a `limiter` field) than the version another
  session had already landed, tests green, push rejected as non-fast-forward.
  Fetched, diffed, found the real #4 already merged and incompatible with
  mine; discarded the unpushed commit with `git reset --hard origin/main`
  (never reached the remote, so nothing lost) instead of trying to reconcile
  two different designs for the same item. Re-read the queue against the real
  tip and picked #22, the true topmost open `cloud-safe` item: all six
  ascension effect keys (`boss_hp_pct`, `heal_between`, `boss_strength`,
  `reward_choices`, `rest_heal`, `player_hp`) were already wired into
  `run.gd`, just never proven end-to-end — the existing test only checked
  `Content.ascension_mods()`'s dictionary and one jump to Ascension 7. Added
  `_test_ascension_tier_effects_reach_the_run()`: one before/after pair per
  tier (same seed either side, so the same map/beast), asserting the SPECIFIC
  effect that tier claims to add actually changes run behavior — boss max HP,
  boss strength, HP banked after a win, reward count, campfire rest amount,
  and starting max HP. All eight passed on the first try; no code changes
  needed, only the missing test. `balance_sim.gd` ran clean as a smoke test —
  not tuned against.
- **2026-08-24** — #21 Unreachable content report in the Card Lab: this session
  also duplicated #4 (per-beast limiters) again before checking `origin/main`
  first — same failure mode rule 9 already names, and already logged at
  length below; caught by the rejected push, discarded before it reached the
  remote, re-fetched, re-read the queue, and picked #21 as the true topmost
  open item. `build.js` already computed card reachability (`reachable` +
  the "unreachable card" Health finding); extended the same pattern to
  relics: a relic in `relics.json`'s `relics` dict missing from its `pool`
  array is now a Health-tab finding, same shape as the card check. Events
  turned out not to need the same treatment — `Content.list_events()` draws
  directly from every key in `events.json`; there is no separate offer-pool
  an event can fall out of, so "unreachable event" isn't a state that can
  exist under the current architecture (unlike cards/relics, which both have
  a real pool an entry can be missing from). Rather than inventing a pool
  concept for events that nothing asked for (rule 6), added the count for
  visibility/future-proofing and documented in code why the check is
  currently always empty. Also added `counts.unreachable` (`{cards, relics,
  events}`) to the JSON payload and a second summary line so the build
  actually **prints** the count the item's "done when" asked for, not just
  the Health tab. Verified the relic check fires by temporarily dropping one
  entry from `relics.json`'s `pool` (findings 4→5, `unreachable.relics`
  0→1), confirmed it reverted cleanly (`git checkout --`), then regenerated
  the real `cardlab.html` clean (0/0/0). No JS test harness exists for this
  tool (never has — it's `node tools/cardlab/build.js`, run and read), so
  verification was this manual before/after rather than an automated test;
  `run_tests.gd` (unaffected by this change, but required before every
  commit) still all green.
- **2026-08-24** — #20 `weak_point_threshold` audit: also started this run by
  duplicating #1 and #4 (a full second "per-beast limiter" build, same failure
  mode rule 9 already names) — caught by a rejected push, discarded before
  anything reached the remote, re-fetched and re-read the queue fresh, and
  picked #20 as the actual next open item. The audit's own worry — that the
  per-visit cap was tuned when sigils sat at Height 1-8 and never rechecked
  now that they sit at 4-13 — turned out to rest on a wrong assumption: the
  cap was never really a function of sigil HEIGHT, it's a function of typical
  hit damage at the sigil (`card.damage + SIGIL_BONUS`), and that hasn't
  moved even as climbs got deeper. Computed "hits to buck" per beast from the
  real card pool's average cheap (cost<=1) attack card (2.86 avg damage) +
  `SIGIL_BONUS` (5) = 7.86/hit: every weak-point beast lands between 1.78
  (Crag Pup/Bounder) and 5.34 (Sunken Warden) hits, rising with beast tier —
  more than a single tap, bucked off within a normal turn's reach, exactly
  what "climb, strike for a CHUNK, get thrown" (GDD) describes. Nothing was
  numerically wrong, so no values changed and the field is not dead — this
  closes the gap between "the cap happens to still make sense" and "a test
  proves it," the same shape as #13/#18's audits. Added
  `_test_weak_point_threshold_still_means_something`, which computes the
  average live (not a hardcoded number) so it stays honest if the card pool's
  damage curve shifts later, and asserts every beast lands in [1.5, 6] hits —
  a band a genuinely dead (huge) or trivial (sub-1) cap would fail.
  `run_tests.gd` all green (181 assertions incl. the new one); `balance_sim.gd`
  ran clean as a smoke test only, not tuned to.
- **2026-08-24** — #19 Shop and campfire test coverage: this session picked
  #1 and #4 first, built a full "per-beast limiter" feature for #4, then hit
  a push conflict and discovered (via rule 9, added exactly for this) both
  were already done on `origin/main` by a prior run — `git reset --hard
  origin/main` threw the duplicate work away before anything was pushed, no
  harm done. Re-picked from the real, current queue and landed #19 instead:
  a relic purchase, the "can't thin a deck past `MIN_DECK`" guard (shop AND
  campfire — only the shop's card/removal paths and the campfire's
  remove/upgrade *succeeding* had tests before), `buy()`/`campfire_action()`
  refusing to act outside their own phase, a campfire "rest" actually
  healing by `REST_HEAL` and capping at max HP, a hunter acting twice in one
  campfire visit, and re-upgrading an already-upgraded card on a later
  visit. 5 new test functions, all passing; `_test_rest_node_heals_and_returns_to_map`
  is still a pre-existing weak test (its substantive branch never fires on
  the fixed seed — "no rest offered on this seed") but fixing that is a
  different item, left alone. `balance_sim.gd` still runs clean (smoke test
  only).
- **2026-08-23** — #33 Graded timing accuracy, the rules half: widened the
  bare hit/miss timing bool into a 3-tier quality (`Combat.TIMING_MISS` /
  `TIMING_GOOD` / `TIMING_PERFECT`) carried through the whole seam the item
  named: `CardView._fire()` now grades the throw, `GameClient.play_card` /
  `GameHost`'s `"play_card"` command carry it over the wire as a new
  `"quality"` key, and `Combat.play_card`/`preview()` scale the timed bonus
  by it (`TIMING_GOOD` pays `TIMING_GOOD_SCALE` = half; `TIMING_PERFECT` pays
  it in full). Landed it as a strict ADD rather than a replacement: every
  changed function signature grows a new trailing parameter defaulting to
  `TIMING_PERFECT`/omitted-`"quality"`-means-`PERFECT`, so every existing
  caller — all 40-ish pre-existing timing call sites in `run_tests.gd`, the
  old `true`/`false` network wire shape, `game_host.gd`'s `bool(...,true)`
  default — keeps behaving byte-identical with zero edits, which is what
  "perfect behaving exactly as today's nailed did" actually required. Best
  find: `card_view.gd`'s `_build_timing_strip()` already drew a brighter
  "bullseye" core rectangle at 0.47-0.53 of the bar with a comment calling it
  "the aim point" — purely decorative until now. Reused those exact bounds
  (`CardView.CORE_MIN`/`CORE_MAX`) as the PERFECT threshold instead of
  inventing new ones, so the on-screen strip is pixel-identical to before —
  genuinely needs no display work, not just "doesn't need NEW UI." A
  multi-hit chain (Satchel Charge) grades on its WORST window, not its last,
  via `CardView._worst_quality`, so a shaky opening hit still costs the whole
  throw. Did not touch `hold_target`/#24's targeting param, and did not wire
  the "wide" enchant or any relic's `timing_zone` mod into the grading (they
  widen which taps register as a HIT, not how they're graded once landed —
  orthogonal, no interaction to resolve). 4 new tests: half-bonus GOOD,
  PERFECT-matches-old-nailed-hit (pinned by comparing both call styles
  directly, not just asserting a number), `preview()`'s quality scaling in
  isolation including that a miss ignores quality entirely, and the omitted-
  argument default. Deliberately did NOT add a test instantiating `CardView`
  itself (the quality-grading math in `_fire()`) — this suite has never stood
  up a `/views` scene headless (per #7's log), and this item's own log is not
  the place to take that on. `run_tests.gd` all green (98 assertions incl.
  the four new ones); `balance_sim.gd` ran clean as a smoke test only — every
  policy call site omits `quality`, so grading has zero effect on it, and the
  win-rate swings visible in this run's output are from other sessions'
  content growth since the sim was last run, not anything tuned here.
  **Also:** this session's initial `git checkout -B main origin/main` pinned
  to a ref later than the container's very first fetch (6d8c01f, through
  #24) but had ALREADY (before any git command in this session) built and
  nearly pushed a full duplicate of #4 against a stale 32dc550 ref — caught
  by the rejected push, not by rule 9's "diff before starting" (which this
  run only started doing after the rejection). Discarded the duplicate,
  re-fetched, re-read the queue fresh, and picked #33 as the actual topmost
  open `cloud-safe` item. Filed here rather than re-logging the by-now
  ninth occurrence of the stale-ref note in detail — rule 9 already exists
  because of it and nothing new was learned about the failure mode itself,
  only that this run still didn't front-load the fetch-and-diff step rule 9
  asks for.
- **2026-08-23** — #24 Named holds on a beast, the climb ENGINE: generalised
  `Boss.ledges` so each element can be either a bare number (legacy: an
  unrestricted safe rest Height — kept working unchanged for all 14 existing
  beasts) or a `{"height", "safe", "exposed_to"}` Dictionary. Three static
  helpers on `Boss` (`hold_height`/`hold_safe`/`hold_exposed_to`) let
  `is_secure`/`next_safe_height`/`_hold_below` in `combat.gd` read both shapes
  the same way; an unsafe named hold correctly does NOT count as a valid rest
  stop. Gotcha the first pass missed: JSON-loaded ledges arrive as `float`,
  not `int`, so branching on `h is int` silently mis-detected every real
  boss's ledges as the Dictionary shape and crashed on cast — caught by
  running the FULL suite (not just the new tests), fixed by branching on
  `h is Dictionary` instead (numeric legacy values, int or float, fall
  through to the `else`). Added one new card field, `Card.targets_hold: bool`
  (wired through `from_dict`/`to_dict`/`_meld_cards`, the same generic spots
  every other flag lives), and a `hold_target` parameter on `Combat.play_card`
  (same shape as the existing `sac_index`/`target_index` per-play choices) —
  a targeting card climbs straight to a named hold instead of adding `grip`;
  an unset or invalid target falls back to the nearest safe hold above
  (`next_safe_height`), and it's a safe no-op with nothing left to reach.
  Deliberately did NOT make the target an absolute height baked into card
  data (bosses' ledge heights vary too much across the roster for one number
  to generalize — a card that only makes sense against specific fights is bad
  content), and did NOT wire `exposed_to` into any move's damage logic yet —
  it's present as real data (satisfying "which moves it is exposed to") but
  UNCONSUMED, same as `wide`/`timing_zone` was left in #12, because rewiring
  `swipe_high`/`swipe_low`'s existing binary foothold>0 check risked changing
  behavior on content this item didn't ask to touch. One new card,
  `route_finder` (uncommon, cost 1, in the shared reward pool), proves the
  field end-to-end rather than leaving it data with no consumer. Also had to
  teach `GameHost._keywords_of` about the new field (the existing reflection
  test — added by #16 — walks every Card field and fails if any produces no
  tooltip) — reused the existing "height" keyword rather than inventing one.
  Left `game/views/combat_3d.gd` and `game/tools/screenshot.gd` (both outside
  `/core`, both read `boss.ledges` as a flat membership list) untouched: no
  real beast's `ledges` was converted to the Dictionary shape in this pass,
  so their behavior is unchanged either way — `Boss.ledge_heights()` exists
  for whichever session eventually needs them to cope with mixed shapes.
  5 new tests (helper shapes, an unsafe named hold, and the four card-targeting
  cases: default/explicit/invalid/no-holds-left); `run_tests.gd` all green;
  `balance_sim.gd` ran clean as a smoke test only, not tuned to.
  **Also:** this session's initial `git checkout -B main origin/main` pinned
  to a stale cached ref 23 commits behind the real tip — the same recurring
  pattern rule 9 above exists to catch. Built a full duplicate implementation
  of #4 (per-beast limiters, already done by a prior session under a
  different but equivalent design) before `git push` was rejected as
  non-fast-forward, which is what surfaced it. Fetched, confirmed items #1
  and #4 were both already `[x]` on the real `origin/main`, discarded the
  redundant commit (nothing had reached the remote, so no history was lost),
  and re-read the queue fresh before picking #24 as the true next item. Rule
  9 already names this exact failure mode from an earlier occurrence; this is
  at least the eighth time it's been logged. Not fixing the root cause here
  either (still out of scope for a single queue item), but flagging again
  since "worth Nick's attention" keeps being true and nobody's acted on it.
- **2026-08-23** — #18 Content integrity test: found the item was mostly
  already covered — `_test_every_referenced_card_id_resolves` already proves
  every card id in starter decks/reward pools, and `_test_relics_all_load`
  already proves the relic pool. Also found events don't reference card ids at
  all (`remove_card`/`sharpen_card` act on a random card already IN the deck,
  not by id), so that part of the item's wording didn't apply. What was
  actually missing: `create` fields (Goblin gadgets building another card by
  id) and `prepare` fields (Goblin Jetpack's delayed effect) had no check that
  the id/key they name actually resolves, and the three beast pools
  (fight/elite/boss) had no check that every id in them builds a real Titan
  rather than `build_boss()`'s empty "Titan, no moves" fallback for a typo.
  Added `_test_content_integrity_graph()` to cover exactly that gap; combined
  with the two pre-existing tests, the whole graph the item asked for is now
  proven. Data itself had no actual typos today — this only guards against one
  landing silently in the future. `Content.all_card_ids()` already existed,
  seemingly added in anticipation of this item but never used for it.
- **2026-08-23** — attempted backlog #4 (per-beast limiters) blind, without
  checking whether `origin/main` had moved past the locally cached ref first:
  this container's initial `git checkout -B main origin/main` pinned to a
  stale `origin/main` (32dc550) that was 17 commits behind the real tip
  (f225695) already on GitHub, including a prior session's own #4 (commit
  `edeb7aa`, 2026-08-22 — `Boss.limiter`, a generic dispatch, one rule per
  Titan; same shape independently arrived at, different specific rules).
  Built a full second implementation before `git push` was rejected as
  non-fast-forward, which is what surfaced the staleness. Reset to the real
  `origin/main` and discarded the duplicate rather than trying to reconcile
  two competing limiter systems. No harm done since nothing had reached the
  remote, but a lesson for next time: fetch and compare against the queue's
  actual current state before trusting a container's starting checkout.
- **2026-08-23** — #17 Events that touch the DECK: the item's own rationale
  ("the 10 events trade in HP and gold only") was already stale by the time it
  was worked — 4 of the current 14 events (`hollow_log`, `friendly_beetle`,
  `old_grapple_line`, `stranded_kite`) already used `reward: "card"`, which
  routes into the normal pick-1-of-3 screen and does add a card, meeting the
  item's literal "at least 4" bar on its own. Didn't just tick it off on that
  technicality, since "add via the existing reward screen" isn't the new
  mechanic the item's text is actually asking for (events that COST or CHANGE
  a card, not just hand one out same as any fight). Built the two genuinely
  missing verbs instead: `remove_card` and `sharpen_card`, two new boolean
  effect keys read generically in `Run.pick_event` (same shape `heal`/`max_hp`
  already use — loop over every hunter, act on each one's own deck), no event
  needs to know how either works. `remove_card` drops one random card per
  hunter's deck, floored at `MIN_DECK` exactly like the campfire's own
  "remove" action; `sharpen_card` upgrades one random un-upgraded card per
  hunter via the existing `upgraded_copy()` trick, and quietly no-ops on a
  deck that's already fully sharpened rather than erroring. Both are random,
  not player-picked, on purpose — a picker would need a screen this routine
  doesn't have. Added 2 new events using them (`scavenger_raid` /
  `remove_card`, `quiet_technique` / `sharpen_card`), stakes stated on the
  button per the item's own rule, not just in the flavor text. That's 14 → 16
  events, over the "12-15 EA band" item #9 aimed for — flagging it rather than
  quietly letting it slide, but not walking it back either, since growing the
  event pool is exactly what this item explicitly asked for, and 16 isn't a
  quality problem, just a stale target from an earlier item. 5 new tests:
  the two effects each in isolation, `remove_card` respecting `MIN_DECK`,
  `sharpen_card`'s no-op case, and a `_test_backlog17_...` walking every event
  in `Content.list_events()` to pin the "at least 4" count itself against
  regression (the same shape #10/#13's content-integrity tests use). One
  GDScript gotcha, same one #10's log already named: `var size_before :=
  run2.decks[0].size()` doesn't type-infer through an untyped `Array` field —
  needed `: int` explicit. `run_tests.gd` all green (73 assertions incl. the
  five new ones); `balance_sim.gd` run as a smoke test only, not tuned to.
  **Also:** before starting, `git checkout -B main origin/main` used a stale
  cached `origin/main` ref 16 commits behind the true tip and briefly reset
  `main` onto it — caught immediately (before any other git operation) by
  the "leaving N commits behind" warning, safety-branched the detached HEAD
  before touching anything else, confirmed with `git fetch origin main` that
  the real GitHub tip already had all 16 commits (a prior session's push had
  already landed — nothing was actually at risk), and reset cleanly. Same
  recurring stale-local-ref pattern this file's log has now named seven
  times; still not fixing the root cause (out of scope here), but seven is a
  lot — worth Nick deciding whether `git fetch` should just be forced before
  the very first `origin/main` reference each run, rather than each session
  re-diagnosing a false alarm by hand.
- **2026-08-23** — #16 Every card field a player must understand has a
  keyword: 6 fields on `Card` had no tooltip at all — `create` (Build),
  `prepare` (Primed), `cheapen_pick`/`cheapen_amount` (Cheapen), `meld`
  (Meld), `hits > 1` (Multistrike), and `ally_energy` (Energy — this one
  also gave the game its first explanation of what Energy even is, not just
  that giving it away is special). Wired all six into
  `GameHost._keywords_of` plus entries in `keywords.json`, and gave
  `timed_damage` a trigger it was missing (it only ever showed up alongside
  `timed` on real cards, so the gap was invisible until tested in
  isolation). The existing `_test_every_derived_keyword_resolves` only
  guards a hand-kept id list — exactly the trap this item warns about, since
  a new FIELD wired to nothing wouldn't show up in that list either. Added
  `_test_every_field_a_player_must_understand_has_a_keyword`, which instead
  walks `Card`'s actual fields by reflection and probes each ALONE (isolated
  from every other field, so one can't hide behind an unrelated tag on the
  same real card) — a field declared tomorrow and forgotten is caught the
  moment it's declared, not the moment someone remembers to update a list.
  `timed_hits`/`draw`/etc. stay unwired on purpose (plain repeat-counts and
  numbers, not jargon) via a short self-evident allowlist in the test.
  `run_tests.gd` all green; `balance_sim.gd` run as a smoke test only.
- **2026-08-23** — #15 Save coverage for the other phases: `Run.to_dict()`/
  `from_dict()` already carried SHOP/CAMPFIRE/EVENT state generically (only
  `Combat` needed its own dict, per #14 — the rest of `Run` was never
  phase-gated), so this was pure test debt, not a missing feature. Added three
  round trips through the actual save FILE, same shape as the existing
  map-level and mid-combat tests: shop (stock + gold survive, and the
  reloaded stock is still purchasable, not a frozen snapshot), campfire
  (one hunter acts, the other hasn't — `campfire_done` reloads as
  `[true, false]`, and the reload still resolves the node when the second
  hunter acts), and event (the picked event and `_seen_events` survive, and
  `pick_event` still resolves on the reload). All three use the same
  `run.node_type = "..."; run._begin_x()` direct-setup pattern the existing
  `_test_gold_and_shop` already used, rather than walking the whole map
  through a mandatory act-opening fight to reach them incidentally.
  `run_tests.gd` all green (68 assertions incl. the three new ones);
  `balance_sim.gd` run as a smoke test only — nothing exploded, not tuned to.
  **Also:** `git fetch origin main` before the checkout showed `origin/main`
  had moved from a stale local ref (32dc550) to 3a282bd (14 commits, through
  #14) — the same recurring stale-checkout pattern logged on 2026-08-22 and
  three times on 2026-08-23; re-fetching and re-running `checkout -B main
  origin/main` picked up the real tip with nothing lost. Not fixing the root
  cause this round (out of this item's scope) but it's now happened five
  times — worth Nick's attention if it keeps costing investigation time.
- **2026-08-23** — #14 Mid-combat saving: `Boss`, `PlayerState` and `Combat`
  each got their own `to_dict()`/`from_dict()` (Boss splits static-from-`id`
  vs. dynamic-per-fight state, the same trick `upgraded_copy()`/`Content`
  already use elsewhere), and `Run.to_dict()`/`from_dict()` now carries an
  in-progress fight instead of skipping it. Replaced the "refuses mid-fight"
  guard in `RunSave.save()` with "refuses only a finished run", and fixed
  `GameHost.resume_run()`, which used to force a COMBAT-phase resume back to
  the map unconditionally — that line was the OTHER half of the old guard, and
  leaving it in place would have made the save work but the resume still
  silently drop the fight. The combat RNG's own state travels too (same
  reroll-button trap the run-level RNG comment already flags), or a reload
  would reshuffle a pile differently than the original fight would have.
  First pass duplicated work another session had already pushed to origin/main
  (backlog #4, per-beast limiters) — origin had moved 13 commits ahead mid-run
  from a concurrent session; caught it before pushing by re-fetching, dropped
  the redundant commit, and re-picked from the (now current) queue.
- **2026-08-23** — #13 Relics that change a rule: turned out mostly already
  done by #10, which wasn't obvious until counted. `relics.json` already had
  7 relics whose effect changes what happens rather than a number — `fall_safe`
  (Feather Harness, pre-existing), `shake_resist` (Anchor Pin, pre-existing),
  `rhythm_keeps` (Drummer's Hide, pre-existing), plus #10's four
  (`block_carries`, `no_buck`, `soft_fall`, `energy_handoff`) — already past
  the "at least 6" bar the item set. What was actually missing: `shake_resist`
  (Anchor Pin) had no behavior test at all, and nothing pinned the *count* of
  rule-changing relics against regression — the existing `_test_relics_all_load`
  counts "not a flat stat bump" (>=12), which is a much looser bar than "changes
  a rule" and would happily pass even if every true rule-changer were removed,
  since the item's own definition (an extra timing window, climbing without
  losing grip, exhaust returning a card) is stricter than that. Added
  `_test_shake_resist_relic` (a sweep still deals damage but no longer shakes
  the hunter down a hold) and `_test_backlog13_six_relics_change_a_rule`, which
  names the actual rule-changing effect set and walks every relic in the data
  file via a new `Content.all_relic_ids()` (mirrors `all_card_ids()`) so a
  future edit that dropped below 6 would fail loudly instead of silently.
  No new relic content — the item's bar was already met by data, so this closes
  the gap between "the rule exists" and "a test proves it," which is what the
  item actually asked for. `run_tests.gd` all green (65 assertions incl. the
  two new ones); `balance_sim.gd` run as a smoke test only — nothing exploded,
  not tuned to (no relic weights or values changed).
  **Also:** before starting, `git checkout -B main origin/main` again warned
  about stranded commits on a detached HEAD; `git fetch origin main` first
  showed `origin/main` already at the tip (bda5c0b, #12's commit) — the same
  stale-local-ref pattern logged three times before, not a real miss. Not
  re-logging the "worth fixing" note again since it's now a known, harmless,
  recurring artifact of how the container's checkout arrives.
- **2026-08-23** — #12 The enchantment ENGINE: added `Card.enchant: String`
  (id of an attached enchant, "" = none) plus `data/enchants.json` with two
  entries — `sure` (`effect: auto_nail`) and `wide` (`effect: timing_zone`),
  the two ideas item #3 itself names. One generic apply, the same trick
  `upgraded_copy()` already uses: `Card.enchanted_copy(id)` works on any card
  without either the card or the caller knowing what the enchant does, and
  never mutates the original. `Card.enchant_data()` reads the id back through
  `Content.make_enchant()` (same `{name, text, effect, value}` shape
  `relics.json` already uses) so a reader keys off `effect`, not a hardcoded
  enchant id. `sure` got a real /core consumer: `Combat.play_card`'s existing
  fumble check (a mistimed `timed` card normally slips away with no effect)
  now also checks for `effect == "auto_nail"` and lets it land anyway — one
  added condition, no new branch. `wide` is valid, tested data with NO
  consumer yet — the timing window itself is rendered client-side
  (`combat_3d.gd`'s `zone_bonus`, already fed by a relic-side `timing_zone`
  mod), so actually widening it per-card is the needs-a-screen half item #3
  still owns; wiring it up without being able to look at it would be
  guessing, which the hard rules forbid. Did NOT touch the card face (name,
  icon, text) or any view/UI file — only `core/card.gd`, `core/content.gd`,
  `core/combat.gd`, `session/game_host.gd` (one line adding an `enchant`
  keyword id, mirroring how `timed`/`burn` etc. are derived) and
  `data/keywords.json`/`data/enchants.json`. New field round-trips through
  save/load for free — `_test_card_dict_round_trips_every_field` walks the
  Card class generically and already covered it without changes. Three new
  tests (generic attach-to-any-card, data-integrity over the whole enchant
  pool, and `sure` actually landing a fumbled timed card); `run_tests.gd` all
  green (61 assertions incl. the three new ones); `balance_sim.gd` run as a
  smoke test only — nothing exploded, not tuned to.
  **Also:** before starting, `git checkout -B main origin/main` warned about
  leaving 11 commits behind on a detached HEAD — the same stale-local-ref
  false alarm logged on 2026-08-22 and 2026-08-23, not a real miss this time:
  a fresh `git fetch origin main` immediately showed `origin/main` already
  at those 11 commits, so nothing was lost or re-pushed. Noting it again only
  because it's now the third time — if a fourth cloud run hits this, it's
  worth actually fixing (e.g. `git fetch` before the very first `git log
  origin/main` check) rather than re-diagnosing it by hand each time.
- **2026-08-23** — #11 Beast move patterns: 7 of 15 beasts had fewer than 4
  moves or only one move kind (`crag_pup` was literally two `attack`s at 7
  and 10). Gave each a 4th (or, for `bounder`, a 3rd and 4th) move reusing
  only the 10 move types the engine already dispatches generically in
  `Combat._enemy_turn()` — no new code, `bosses.json` only — and picked each
  addition to fit the beast's existing idiom rather than at random:
  `crag_pup` gains `block`+`attack_all` (the simplest early fight now has a
  guard beat and a sweep, not just two hits), `bramble_hog` and `sky_snapper`
  gain `enrage` (matching the pattern `frost_sentinel`/`grove_bear` already
  use), `bounder` (a rabbit) gains `swipe_high` + `block`, `mire_snapper` (a
  croc) gains `swipe_low`, `root_lurker` gains `block`, and `riftling` gains
  `shift_sigil` (a rift-creature warping the weak point reads as the same
  idea as its `rift` move, and it's the move `shifting_idol` already uses).
  The four Titans and `frost_sentinel`/`grove_bear`/`shifting_idol` already
  satisfied the rule and were left untouched. Added
  `_test_every_beast_has_a_move_pattern`, walking every beast in all three
  pools and failing if any has <4 moves or only one move kind — the same
  shape as the existing `_test_every_boss_move_type_resolves`, registered
  right after it. `run_tests.gd` all green (58 assertions incl. the new
  one); `balance_sim.gd` run as a smoke test only, not tuned to — numbers
  will have moved since weaker beasts now sometimes block or enrage instead
  of always attacking, which is the point of the item, not a balance pass.
- **2026-08-23** — #10 Relics to ~30: added 4 new relics (26 → 30), each a genuine
  rule flip rather than a bigger number on an existing axis — `riveted_plates`
  (Block halves instead of resetting to 0 each round), `grapnel_clamp` (a weak
  point never bucks you off), `safety_line` (losing your grip lands you on the
  nearest hold below instead of the base), `relay_baton` (unspent Energy at
  end of turn passes to your ally instead of vanishing — leans into the
  co-op-combo goal in CLAUDE.md §6). All four are `{effect, value}` entries in
  `relics.json` read by the same generic `Run.relic_totals()` → `Combat._mod()`
  path every other relic already uses; only `_begin_round()`, `fall()`,
  `_check_weakpoint_buck()` and `end_turn()` each needed one new conditional
  line, no new subsystem. One GDScript gotcha: `var carried := X if cond else
  0` doesn't type-infer inside a `for` loop with `:=` — Godot's parser rejected
  it at import time ("Cannot infer the type"); fixed by declaring `: int`
  explicitly. Added `_test_backlog10_new_rule_changing_relics` covering all
  four; `run_tests.gd` all green, `balance_sim.gd` smoke-tested only (numbers
  moved because the new relics enter the reward pool, not because anything was
  tuned).
  **Also:** before starting, `git checkout -B main origin/main` warned about
  leaving 8 commits behind on a detached HEAD (matching this file's own
  "stranded commits" note from 2026-08-22) — but a fresh `git fetch origin
  main` showed `origin/main` already had all 8 (the prior run's own log entry
  confirms it recovered and pushed them). The local ref was just stale from
  container init; refetching and re-running the checkout fixed it with nothing
  lost or redone. Also found item #1 had already been ticked off and 6 more
  items (#4-#7, #9) completed since this file was last read at the top of a
  stale local clone — re-read the file fresh after fetching before picking
  the next item, which is what surfaced #10 as the true topmost open
  `cloud-safe` item instead of #1.
- **2026-08-22** — #9 More events: added 4 (`rockslide_altar`, `stranded_kite`,
  `the_toll_crow`, `quiet_overhang`), 10 → 14, inside the 12–15 EA band, all
  in the "bruise, don't kill" idiom. `the_toll_crow` is the first event to
  charge gold rather than only pay it out, which surfaced a real bug: nothing
  floored the shared purse at 0, so an early-run team with less gold than the
  toll could go negative. Fixed generically in `Run.pick_event`
  (`gold = maxi(0, gold + ...)`), same spirit as the existing HP floor, and
  added `_test_event_gold_cost_never_goes_negative`. Also tightened
  `_test_events_load_and_are_well_formed`'s count check from >=8 to >=12 so a
  future regression below the EA band fails loudly.
  **Also:** before starting, found this session's checkout arrived with 7
  commits (items #4–#7 plus queue growth) sitting on a detached HEAD that had
  never reached `origin/main` — a real miss this time, not the stale-ref false
  alarm logged below on 2026-08-22 for a 3-commit case. Confirmed on
  `origin/main` it was a true fast-forward, and pushed it before touching
  anything else, so that work stays found instead of getting silently
  redone or lost to container reclamation. Worth Nick knowing the "stranded
  commits" failure mode has now happened twice — if it recurs, the push step
  at the end of an iteration may need a stronger guarantee than "assume the
  next run's checkout will already have it."
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
