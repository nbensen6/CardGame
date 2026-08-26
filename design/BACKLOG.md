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
- [x] **31. A run-start boon** `cloud-safe` — StS opens with Neow: a free
  meaningful choice before the first fight that sets the run's direction. We drop
  you straight onto the map. *Done when:* one choice of 3-4 at run start, saved
  with the run, tested.
- [ ] **32. Potion slots and status feedback** `needs a screen` — the UI for 26
  and 27: three slots you can see and tap, and a clear cue when something clogs
  your deck. Deliberately separate so the engine can land without it.
- [ ] **31b. Wire the run-start boon into a real game** `needs a screen` — #31's
  engine (`Run.offer_run_start_boon()` / `pick_boon()`) is tested but
  deliberately NOT called from `Run.start()`: `game_3d.gd`'s phase router has
  no 3D scene for `"boon"`, and its own doc comment says an unhandled phase
  "holds the current screen and shouts" rather than swapping — every real
  co-op run goes through `GameHost.start_new_run() -> Run.start()`, so wiring
  the trigger in before a screen exists would soft-lock every new run the
  moment it begins. Needs, together: a 3D scene for the offer (or reuse
  `location_3d.tscn`'s event rendering, since a boon is shaped like one event
  choice), `game_3d.gd`'s `SCENES` table gaining `"boon"`, `GameHost` exposing
  `s["boon"]` and a `"pick_boon"` command (mirrors `"pick_event"` exactly), and
  `Run.start()` calling `offer_run_start_boon()`. *Done when:* a fresh run
  shows the offer on screen, picking one is a tap, and it's been looked at.

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

- [x] **35. Migrate saves instead of throwing them away** `cloud-safe` — the
  save carries `VERSION := 1` and `run_save.gd` **rejects** any file that does
  not match it. Every field the routine adds is a change to the run's shape, so
  the day someone bumps that constant every run in progress is silently deleted.
  Rejection is the right default for a corrupt file and the wrong one for an old
  one. *Done when:* an older save is upgraded field-by-field to the current
  shape rather than discarded, a genuinely unreadable file still refuses
  cleanly, and a test loads a fixture written in the previous shape.

- [x] **36. Frail, Artifact and Thorns** `cloud-safe` — the debuff axis we do
  not have. Today a hunter carries Strength, Wound and Vulnerable: everything
  points at the damage number. Nothing touches BLOCK, nothing RESISTS a debuff,
  and nothing punishes the act of attacking. Those three are one field each and
  they change what a turn is worth rather than how big it is. Thorns in
  particular reads naturally on a Titan — a spined beast that costs you to touch
  it. *Done when:* each is a field, at least two cards or relics and one beast
  apply them, and each has a test.

- [x] **37. Events that know potions exist** `cloud-safe` — 17 events, and not
  one of them mentions a potion, because all 17 were written before item 26
  landed. The genre's best events trade in every currency the run has — HP, gold,
  cards, relics, potions — and ours only trade in four of the five. *Done when:*
  at least four events grant, take, or gamble a potion, and the content
  integrity test proves every potion id they name resolves.

- [x] **38. A seed you can share** `cloud-safe` — runs are seeded, but the seed
  is an internal number nobody can see or set. Being able to type one in is how
  a bug report becomes reproducible and how two people race the same run — worth
  far more to us than to a single-player game, because we are co-op. *Done
  when:* the seed is readable, a run can be started from a given one, and a test
  proves two runs from the same seed make identical maps, shops and rewards.

- [x] **39. A run summary worth showing at the end** `cloud-safe` — nothing is
  counted over a run: not damage dealt, not the highest climb reached, not cards
  played, turns taken, or what killed you. So a finished run says nothing about
  itself, and we have no way to tell a close win from a walkover. This is the
  DATA half only; the screen that shows it is someone else's item. *Done when:*
  a stats block accumulates through the run, survives save and load, and is
  tested.

- [x] **40. Beast moves that react to where you are** `cloud-safe` — every move
  fires on a fixed rotation regardless of the board. A Titan cannot notice that
  you are clinging to its sigil. One optional `when` condition on a move (above
  or below a height, at the sigil, a hunter undefended) turns the climb into
  something the beast answers, and it is the cheapest depth available because
  the moves are already data. *Done when:* the condition is a data field with a
  fallback move when it fails, at least three beasts use it, and it is tested.

- [x] **41. Shops and campfires should trade in potions** `cloud-safe` — item 26
  built potions and nothing sells them. `Run.shop_stock` offers cards and a
  removal; the campfire offers rest and the other options. So the only way to
  hold a potion is whatever grants one in a fight, which makes three slots of
  inventory mostly decorative. *Done when:* the shop stocks potions at a price,
  a full inventory is handled rather than silently dropping the purchase, and
  both are tested.

- [x] **42. Something to unlock between runs** `cloud-safe` — `Progress` remembers
  your ascension, your hints, your keybinds and your wins, and nothing else. A
  loss therefore leaves you with exactly what you started with, which is the one
  thing the genre never does: StS drips new cards and relics into the pool for
  dozens of hours. We have 152 cards and 30 relics all available from run one.
  *Done when:* a gated subset unlocks on defined events, the pool respects it,
  it persists, and it is tested. Keep the gate small — this is a hook to hang
  progression on, not a rebalance of what is offered.

- [x] **43. One trigger point instead of scattered special cases** `cloud-safe` —
  there is no generic "when X happens, run Y". Every timed effect, relic and
  passive is wired at its own call site, so each new one costs another branch in
  `combat.gd` and the file grows a special case per idea. A small set of named
  moments (turn start, turn end, card played, damage taken, hunter climbs) that
  relics, potions and cards all subscribe to would make the next twenty pieces
  of content data rather than code. *Done when:* the moments exist, at least
  three existing effects are moved onto them with no behaviour change, and the
  suite proves the behaviour did not change.

- [x] **44. Titans that change their pattern when hurt** `cloud-safe` — every
  beast runs one fixed rotation from full health to zero, so the back half of a
  fight is the front half with smaller numbers. A second move list that takes
  over below a health threshold is the genre's standard answer and ours is
  cheap, because moves are already data. It also suits the fiction: a beast that
  has been climbed for five rounds should start behaving like it. *Done when:*
  the threshold and the second list are data fields, at least three beasts use
  them, the switch is visible in the telegraph, and it is tested.

- [x] **45. Prove the new mechanics cross the client/server boundary**
  `cloud-safe` — potions, curses, Retain, Innate, named holds and graded timing
  all landed as `/core` rules with `/core` tests. This is a CO-OP game: the
  thing that actually breaks is the snapshot boundary, where a field exists on
  the host and never reaches the peer, or reaches only the peer who owns it.
  `game_host.gd` decides what each peer sees, and none of these were added with
  a two-peer test. *Done when:* each of those six is exercised through a real
  host/client pair, including what the ALLY should and should not see.

- [x] **46. A robustness sweep that is not balance tuning** `cloud-safe` — we
  have `balance_sim.gd`, which the standing rule says not to tune to, and that
  rule has left the whole simulation unused. But there is a question it can
  answer that has nothing to do with win rates: does a run ever get STUCK. No
  playable card and no energy, a climb that cannot progress, a shop that offers
  nothing affordable with no exit, an event with no valid choice. *Done when:*
  a sweep of many seeded runs asserts every state has at least one legal action
  and every run terminates, and it fails loudly on a soft-lock. Report crashes
  and dead ends only — never win rates.

- [x] **47. A fifth hunter, driven by a resource** `cloud-safe` — promoted from
  Later. Four classes all spend the same 3 energy; a class with its OWN currency
  (charge, heat, breath — something it banks and spends) is how the genre keeps
  its fifth character from being a re-skin. Expect this to take several runs:
  character entry, starter deck, reward pool, the resource on `PlayerState`, and
  the cards that pay into and out of it. *Done when:* it plays a full run,
  the resource survives save/load, and its cards are tested.
  [sts2-comparison §3.5]

- [x] **48. Relic tiers, and a pool only Titans pay from** `cloud-safe` — all 35
  relics carry `{name, effect, value, text}` and NO rarity, so every one is
  equally likely and felling a Titan feels the same as opening a chest. StS's
  boss relics are the memorable ones precisely because they are gated behind the
  hardest thing you did. #30 already gave some of ours a real downside, which is
  the boss-relic idiom exactly — they just are not gated. *Done when:* relics
  carry a tier, the offer respects it, Titans draw from a pool of their own, and
  it is tested.

- [x] **49. A daily run everyone shares** `cloud-safe` — #38 made seeds
  reproducible and shareable, which is most of the work; a daily is that seed
  derived from the date plus a fixed ascension, so two people can race the same
  map. Cheap now, and the first thing in this game with a reason to come back
  tomorrow. *Done when:* the day's seed is derived and stable, a daily run is
  flagged as one, and a test proves two runs on the same date match.

- [x] **50. Enchantments beyond the two proving ones** `cloud-safe` — #12 built
  the engine and `enchants.json` has exactly two entries, one of which has no
  consumer yet. An engine with two pieces of data is a demo. Write enough that
  enchanting is a decision: cost, draw, target, exhaust, timing. *Done when:*
  at least eight exist, each has a consumer in /core, and each is tested.

- [x] **51. A dropped hunter can come back** `cloud-safe` — `net_link.gd` emits
  `peer_dropped` and nothing rejoins. In a two-player game one dropped phone
  ends the run for BOTH people, which is the worst failure this design has: the
  whole pitch is that you are climbing together. The host is already
  authoritative and already sends per-peer snapshots, so the state to resume
  from exists. *Done when:* a peer that drops can rejoin the same run and
  receive a correct snapshot, and a test drops and restores one mid-fight.

- [x] **52. Potions across the whole effect range** `cloud-safe` — ten potions
  covering five effects, two of each, which is a ladder rather than a choice:
  the big one is always better than the small one. Potions should do things
  cards cannot — remove a debuff, refill grip, move you up the beast, hit every
  hunter at once. *Done when:* at least sixteen exist, no effect has only a
  large-and-small pair, and the new effects are tested.

- [x] **53. Events that branch more than once** `cloud-safe` — all 20 events are
  one screen and one choice. The ones people remember in this genre have a
  second beat: you take the deal, and THEN it asks something. One optional
  `then` on an outcome buys that for the whole file. *Done when:* the field
  exists, at least four events use it, and a test walks a two-step event.

- [x] **54. Keyword coverage for everything added since #16** `cloud-safe` —
  `_keywords_of` derives tooltips from a card's fields, and a great deal has
  landed since: potions, curses, Retain, Innate, X-cost, Frail, Artifact,
  Thorns, boons, named holds, graded timing. A mechanic with no keyword entry is
  a mechanic the player has to guess. *Done when:* every field a player must
  understand resolves to a keyword, and the existing coverage test is extended
  to prove it stays true.

- [ ] **55. More beasts — data first, art follows** `cloud-safe` — fourteen
  beasts across four acts, so a run reuses the same bodies and the map stops
  surprising you by Act 2. Beast DATA (moves, holds, sigil height, limiter) is
  cloud-safe; the model is not, and a new beast without one falls back to a
  stand-in rather than breaking. Write them in the existing idiom — each should
  bend one rule, the way the current fourteen do. *Done when:* at least six new
  beasts exist with holds and limiters, they are in the right pools, and content
  integrity still passes.
  **Checked 2026-08-26: the "falls back to a stand-in" claim above is stale.**
  Backlog #80 added `_test_everyone_wears_their_own_art`
  (`tools/run_tests.gd`), which fails the whole suite if any id in
  `Content.boss_ids()` lacks a same-named `assets/3d/cast/<id>.glb` AND its own
  unshared portrait — there is no beast-side placeholder the way `Cast.PLACEHOLDER`
  covers hunters. So a new `bosses.json` entry cannot land cloud-safe on data
  alone under rule 2 (tests must pass, no exceptions) without also being full
  `cloud-art` work (a Blender build + contract + previews) per beast — six of
  those is not one iteration. Left unchecked and un-skipped; whoever picks this
  up next should either build it as `cloud-art` one beast at a time, or get
  Nick to confirm a real beast-side placeholder is wanted before writing one.

- [x] **56. Ascension 9 and up** `cloud-safe` — eight tiers, and #22 proved they
  do what they claim. StS runs to twenty because the ladder IS the long game for
  the people who finish it. The tiers are data and the harness for them already
  exists. *Done when:* the ladder extends with tiers that change rules rather
  than only numbers, and each new one is tested the way #22 tests the first eight.

### The Slay-the-Spire gap

Checked against the code on 2026-08-25, not listed from memory. Each of these is
something Slay the Spire leans on hard and we do not have at all.

- [x] **57. Powers — cards that stay played** `cloud-safe` — the single biggest
  card category we lack. A Power leaves your hand for good and keeps paying for
  the rest of the fight, which is what makes a deck feel like it *becomes*
  something mid-combat instead of just cycling. We have no concept of a card
  that persists: everything resolves and goes to a pile. *Done when:* a `power`
  card type exists, played powers persist and stack for the fight, they reach
  the snapshot so a face can show them later, and they are tested.

- [x] **58. Ethereal** `cloud-safe` — a card that exhausts if it is still in your
  hand at end of turn. One flag, and it is the counterweight that lets a card be
  pushed well above its cost: powerful, but only if you can use it NOW. The
  exact opposite of Retain (#28), which we already have. *Done when:* the flag
  exists, end of turn honours it, at least three cards use it, and it is tested.

- [x] **59. Scry** `cloud-safe` — look at the top few of your draw pile and bin
  what you do not want. It is how a deck steers itself without drawing, and
  nothing we have touches the draw pile's ORDER at all. It suits co-op too:
  scrying tells your ally what is coming. *Done when:* the effect exists, the
  choice is a command the host validates, and it is tested.

- [x] **60. Dexterity** `cloud-safe` — Strength's counterpart, and we have only
  Strength. Every buff we own points at the damage number, so a defensive build
  has no scaling to find. One field on `Combatant`, applied wherever Block is
  gained. *Done when:* the field exists, cards and relics grant it, Frail (#36)
  interacts correctly, and it is tested.

- [ ] **61. Intangible, Buffer and Plated Armour** `cloud-safe` — the tier above
  Block. Block is all-or-nothing and resets every round; these change the SHAPE
  of taking a hit — reduce any hit to 1, cancel the next attack outright, keep
  armour that does not decay. On a beast that sweeps both hunters, "survive this
  one turn" is a real decision we cannot currently express. *Done when:* all
  three exist, interact correctly with Block and Thorns, and are tested.

- [ ] **62. Cards that reward discarding** `cloud-safe` — the discard archetype
  turns a cost into a resource. We have a discard pile that nothing reads.
  *Done when:* discarding is something a card can do on purpose, at least four
  cards pay off for it, and it is tested.

- [ ] **63. More than one thing to fight at once** `cloud-safe` — every Spire
  fight is two to four enemies and every one of ours is a single beast, which is
  why targeting is never a decision. Our idiom makes this better than a straight
  copy: things ON the beast — parasites, guardians clinging to a hold — that you
  fight while climbing past them. Expect several runs; this touches targeting
  everywhere. *Done when:* a fight can hold more than one combatant, cards target
  among them, sweeps hit correctly, and the per-peer snapshot carries all of them.

- [ ] **64. Keys, and a Titan you can only reach with them** `cloud-safe` — the
  Spire gates its true final fight behind three keys taken from optional, costly
  choices earlier in the run, which is the best structural idea in that game: it
  makes Act 1 decisions matter in Act 4. Ours ends on a fourth Titan everyone
  reaches anyway. *Done when:* keys are run state, three are earnable from
  distinct node types at a real cost, the final encounter checks them, and it is
  tested.

- [ ] **65. Run history** `cloud-safe` — #39 counts a run while it happens and
  then throws the numbers away. Every finished run should be recorded:
  character, seed, ascension, how far, what killed you, the deck you ended with.
  It is what makes a loss feel like data instead of like nothing, and it is the
  only way we will ever see a pattern across runs. *Done when:* finished runs
  persist, the file survives a version bump the way #35 taught, and it is tested.

- [ ] **66. Upgrades that change a rule, not a number** `cloud-safe` — our
  upgrade path bumps values. The upgrades worth remembering change what a card
  DOES: cost to zero, gain Retain, hit everything, stop exhausting. A +2 is not
  a decision; a rule change is. *Done when:* an upgrade can carry an effect
  change rather than only a value, at least six cards use one, and each is tested.

- [ ] **67. Cards that ask a question about the board** `cloud-safe` — "if you
  are above the sigil", "if your ally is hanging", "if this is the third card
  this turn". Every card we own does the same thing every time it is played, so
  a hand never has a right ORDER to play it in. This is the cheapest depth left:
  one optional condition, evaluated at play time. *Done when:* the condition is
  a data field with a fallback, at least six cards use it, and both branches of
  each are tested.

- [ ] **68. Reaching into the draw pile** `cloud-safe` — put a card on top,
  shuffle one in, pull a specific card out. Nothing we have touches the draw
  pile except drawing from it, so deck order is pure luck every single time.
  *Done when:* the operations exist as effects, stay deterministic under a seed,
  and are tested.

- [ ] **69. Beasts that debuff YOU** `cloud-safe` — #36 gave us Frail, Artifact
  and Thorns, #27 gave us curses, and not one beast inflicts any of them. A
  Titan that only ever deals damage is a damage number with a picture on it.
  *Done when:* at least five beasts apply a status or a curse through the
  existing generic move path, the telegraph names it, and it is tested.

- [ ] **70. Things that fire when the fight STARTS** `cloud-safe` — Innate (#28)
  is the only opening-hand effect we have. The Spire opens fights with relics and
  powers already resolving, which is what makes a build feel assembled before
  turn one rather than after turn three. *Done when:* a fight-start moment exists
  that relics, boons and powers can subscribe to, at least four things use it,
  and it is tested. Do #43 first if it is still open — this is one of its moments.

- [ ] **71. A shop worth revisiting** `cloud-safe` — fixed stock and one removal.
  Spire shops rotate, hold a guaranteed rare slot, and sell removal at a rising
  price you have to judge against the cards in front of you. Ours already rises
  (`removes_bought`); the rest is missing. *Done when:* stock is generated per
  visit with a rare slot, prices vary, and it is tested.

- [ ] **72. Rewards that know what you are building** `cloud-safe` — card rewards
  roll flat from a pool, so a deck never compounds into anything. Tag cards by
  archetype and let the roll lean, gently, toward tags you already hold. This is
  not balance tuning: the tags and the lean are structure, and it is done when it
  WORKS, not when a win rate moves. *Done when:* tags exist on cards, the reward
  roll uses them, and a test proves a tagged deck sees more of its own tag.

- [x] **73. osu sliders: notes you hold, not just tap** `needs a screen` — the
  chain of tapped notes landed on 2026-08-25 with #34. The other half of osu's
  vocabulary is the slider: a note you press and HOLD along a path. Our climb
  cards want exactly that — a long haul up the beast should feel sustained, not
  like three separate taps. Build it on the same `resolved(quality)` contract so
  nothing downstream has to learn a new shape.

- [ ] **74. Let the cloud build models — behind a shape contract it can check**
  `cloud-safe` — mechanically this already works: Blender runs `--background`
  with no display, which is how every model in `tools/blender/` was built, and
  it renders preview PNGs headless too (workbench, no GPU). The routine already
  downloads Godot each run, so downloading the Linux Blender tarball is the same
  move.

  What it cannot do is LOOK at the result, and that is the whole job. The Stone
  Warden needed a second pass because it was a murky near-black blob; the
  Vine-Weaver's base was three hoops floating over empty air. Both passed every
  automated check we had. A run that cannot see would have committed them.

  So the useful version is not "generate beasts", it is **give the machine
  enough of a contract that it can fail loudly**:

  * **Holds exist where the data says.** This is the strong one and it is
    genuinely checkable. Hunters stand at `lerp(0.18, 0.80)` of a beast's
    bounding box, so a beast with `ledges: [3, 6, 9]` and `weak_point_height: 11`
    needs standable geometry at 35%, 52% and 69% of its height. Sample the mesh
    at those bands: enough near-horizontal surface, wide enough, or fail.
  * **Sigil present at its Height**, in the shared gold, and visible from the
    front rather than buried behind the body.
  * **Silhouette distinctness.** Render the silhouette and compare against every
    model already in `cast/`. A new beast that matches an existing one above a
    threshold is a re-skin and should fail.
  * **Budget and structure** — the four `assetcheck.gd` rules, triangle count,
    one mesh, one material, palette swatches only.

  With that, a run can build to a spec, prove it met the spec, render previews
  from three angles, and commit both. Nick and Claude judge a batch later on a
  screen — which is far cheaper than building each one by hand, and honest about
  where the taste has to come from.

  *Done when:* Blender installs in the sandbox, the shape contract exists as a
  tool that fails loudly, previews are committed beside each model, and one
  beast is built end to end by a run without a human in the loop.
  **Do not skip the contract and just generate.** A model that passes nothing but
  `assetcheck` is a model nobody has looked at, and we have shipped that mistake
  before.

### Art the cloud can build

**Read `tools/blender/README.md` first.** It carries the vocabulary — `taper`,
`box`, `wedge`, `limb`, `mirror` — measured off Kenney's own models rather than
guessed at, and the two things `finish()` now shouts about (parts that do not
touch, and the triangle budget). A build script that reaches only for `ball()`
is the mistake this whole section exists to stop repeating.

Tagged `cloud-art`: the routine downloads Blender, writes a build script, proves
the model against the contract, renders three angles, and appends a block to
`design/ART-REVIEW.md` saying what it was trying to make and what it could not
check. It never judges its own work. See item 74 for why.

- [x] **75. The other eleven beasts** `cloud-art` — **done 2026-08-25, by hand,
  not by a run.** All fourteen beasts have their own body and all fourteen pass
  the hold contract in Godot. `tools/blender/beast.py` is what made eleven
  tractable: it reads `bosses.json`, gives you `shelf()` which lands a ledge
  exactly where the contract wants one, and runs Godot's own area test in Blender
  before the file is written. Ticked because the models exist and are proven —
  but every one is **unreviewed**, and the eleven review blocks in
  `design/ART-REVIEW.md` say what to look at first.

- [ ] **81. The ledges read as scaffolding** `needs a screen` — every beast now
  has real standable ledges and hunters stand on them (2026-08-25). On the
  terraced ones — the Drowned Colossus and the Sunken Warden especially — the
  slabs are pale grey and step out of the body far enough to read as planks
  bolted on rather than as the creature's own shape. Honest about where you
  stand, which is why they are like that; whether that honesty is worth the look
  is Nick's call. *Done when:* the ledges read as part of the body from fight
  distance, without the climb points moving.

- [ ] **80. The Lightbearer's art, and the rule that a new hunter needs some**
  `cloud-art` — the cloud added a fifth hunter in #47 with no model, so it stood
  on screen as a bunny, and `Cast.PLACEHOLDER` had no entry for it either. The
  model exists now (`tools/blender/lightbearer.py`). What does not exist is the
  habit: **a run that adds a character or a beast must either build its body or
  queue it here and add a deliberate PLACEHOLDER entry.** Falling through to the
  default bunny is how a fifth hunter shipped invisible. *Done when:* that rule
  is written into the routine's brief and the portrait for the Lightbearer is
  ours rather than Kenney's owl.

- [ ] **76. Card icons, rendered rather than borrowed** `cloud-art` — every card
  face wears one of 25 Kenney icons, so cards share pictures and the Card Lab
  already flags how few there are for 155 cards. Build small 3D icons in the same
  palette and render them square and flat to `assets/icons/`. They cost nothing
  at runtime — they are PNGs like the current ones — and they are ours. *Done
  when:* at least eight new icons exist, cards reference them, and the Lab's icon
  finding improves. **One batch per run**, and say in the review block which
  cards you pointed at them.

- [x] **77. Props for the places you walk** `cloud-art` — **the FIGHT grounds are
  done (2026-08-25): all fourteen, one per beast, in `tools/blender/env/`.** The
  overworld map is still Kenney hex tiles and Kenney trees, which is what this
  item originally meant, so it is reopened as #82 rather than pretending the map
  got done too.

- [x] **82. The overworld map, in our own art** — **done 2026-08-25.** All
  seventeen models built by `tools/blender/hexes.py` in one Blender run; nine
  tiles, seven landmarks and the loose tree. `ui/tiles.gd` prefers ours and falls
  back to Kenney's, same rule as `ui/cast.gd`, so the map can be changed one tile
  at a time. Unreviewed — see the block in `design/ART-REVIEW.md`, particularly
  the note about the green.

- [ ] **78. A Light meter for the Lightbearer** `needs a screen` — #47's engine
  landed: `PlayerState.light`, `light_gain`/`light_cost`/`damage_per_light`/
  `ally_heal` on `Card`, and 9 cards that use them. Nothing shows a player their
  banked Light — Energy gets pips in the HUD, Light gets nothing, so a
  `light_cost` card just looks unplayable with no explanation. The card face's
  `text` already says the number ("Spend 3 Light..."), and the keyword tooltip
  explains the mechanic, but there is no running counter the way Energy has one.
  *Done when:* the HUD shows current Light for a Lightbearer hunter, and it's
  been looked at.

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
- `cloud-art` — the routine CAN build it in Blender (headless, no display
  needed) but cannot judge it. It must prove the model against the contract,
  render previews, and write a block in `design/ART-REVIEW.md` saying what it
  was going for and what it could not check. Never tick a `cloud-art` item off
  as finished: a human has to look first.
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
- The boss's own Frail/Artifact/Thorns (and a player's own Thorns/Artifact)
  are real Combatant fields, computed correctly, and never leave the host:
  `GameHost`'s boss dict only forwards `vulnerable`/`strength`/`wound`, so a
  Titan you've Frailed or a hunter carrying Thorns shows nothing to look at.
  Found auditing #54; not itself a keyword-text problem so it wasn't fixed
  there — it's snapshot plumbing (`_players_public()`/the boss dict in
  `game_host.gd`) plus a boundary test, cloud-safe, cheap, but a distinct item.

## Log

Newest first. One line per finished item: what, and anything surprising.

- **2026-08-26** — #60 Dexterity: skipped the `needs a screen` items ahead of
  it (2, 3, 8, 25, 29b, 32, 31b) and left #55 (more beasts) unchecked exactly
  as its own note asks — it needs Blender per-beast, not a data-only pass — so
  this was the topmost item actually buildable cloud-side. Added `dexterity: int`
  to `Combatant` (not PlayerState/Boss, where Strength lives) exactly as the
  item specifies, since it has to apply wherever ANY combatant gains Block —
  self, ally, or (Boss extends Combatant) the Titan's own "block" move — with
  no extra wiring at those call sites. `gain_block()` now adds `dexterity` to
  the raw amount BEFORE Frail's cut, so a Frailed defender keeps a diminished
  benefit rather than losing a banked Dexterity bonus outright — that ordering
  is the "Frail interacts correctly" half of the done-when. Wired three
  sources: a card field (`Card.dexterity`, applied in `play_card` AFTER this
  card's own Block resolves, mirroring how Strength doesn't retroactively lift
  its own card's damage — otherwise a card with both `block` and `dexterity`
  would inflate its own printed number), a relic (`nimble_wraps`, +2 start,
  via the existing generic `_mods`/`_mod("start_...")` plumbing `start_foothold`
  already uses, so no new Combat constructor parameter was needed), and two
  cards (`sure_footing`, dexterity-only; `steady_grip`, block+dexterity) added
  to the global pool AND all five characters' own `reward_pool` arrays — the
  same trap #57/#58/#59 already flagged, and the one I keep having to
  remember. Added the `dexterity` keyword and a `_keywords_of`/`_card_icon`
  fallback so the existing coverage tests still pass, and one line to
  `_meld_cards`' field list (it already carries `strength`/`frail`/`thorns`,
  so leaving `dexterity` out would've reopened the exact gap #58's log flagged
  for `ethereal`). 7 new tests: the base mechanic, the same interaction
  proven on a real second card (not just the same card twice), the Frail
  interaction, the same-card-doesn't-inflate-itself ordering proven two ways,
  and the relic. All green, existing suite untouched.

- **2026-08-26** — #59 Scry: picked up #55 (more beasts) first since it was
  higher in the queue, but Blender turned out to be unreachable this run —
  the egress proxy answered every CONNECT to `download.blender.org` with a
  policy 403 (`/root/.ccr/README.md`: "do not retry or route around it —
  report the blocked host"), so the cloud-art half of that item is genuinely
  blocked here, not stale-checkout or a transient failure. Reverted the
  bosses.json/tools script work for it cleanly (nothing landed, nothing to
  undo later) and moved to #59 instead, which needs no art. Added `scry: int`
  on Card (look at the top N cards of the draw pile without drawing them);
  `PlayerState.scry_pending` holds the reveal until a NEW command,
  `Combat.resolve_scry(pi, bin_indices)`, decides what to do with each —
  binned cards go to the discard pile, kept ones return to the top of the
  draw pile in the same order they were revealed (index 0 stays the next
  card drawn). Wired a `resolve_scry` command through `game_host.gd` the same
  way `use_potion` is (`_acting_slot` gives it the same anti-spoof property:
  a co-op peer claiming another slot still only resolves their own). Backlog
  text says "scrying tells your ally what is coming," so unlike a private
  hand card the reveal rides the PUBLIC per-player snapshot
  (`_players_public()`'s new `scry_pending`), the same reasoning #45 already
  gave potions and #57 gave powers — proved with a two-peer session test, not
  just a single-player one. Two cards shipped (Peer Ahead, common, scry 2;
  Read The Climb, uncommon, scry 4), added to the global reward_pool AND all
  five characters' own reward_pool arrays (the same trap #57's and #58's logs
  both flagged: `Content.reward_pool()` only falls back to the global list
  when a character has none of their own, and all five already do). Added
  the `scry` keyword and a `_keywords_of`/`_card_icon` fallback so the
  existing coverage tests still pass without hand-listing it anywhere else.
  9 new tests: reveal order, resolve_scry binning + keep-order, two bad-input
  cases (out-of-range player, out-of-range bin indices, nothing pending),
  a PlayerState dict round-trip, a real mid-combat save/load, and the
  two-peer visibility + anti-spoof test. First run of the new tests caught a
  real bug in the tests themselves, not the engine: I'd forgotten the played
  scry card ALSO lands in its own discard pile (same as any other skill
  card), so my "binned card is alone in the discard pile" assertions were
  off by one — fixed the assertions, not the engine, once I re-read
  `play_card`'s existing `ps.discard_pile.append(card)` line. All green.

- **2026-08-26** — #58 Ethereal: added an `ethereal: bool` field on Card,
  Retain's exact opposite. `Combat.end_turn` now checks it before Retain
  while sweeping the hand — a card still there at end of turn exhausts
  instead of discarding — with Retain's own `_test_retain_...` tests as the
  template for the three new ones, including a "both flags set" case: when a
  card is somehow both, ethereal wins, so a card can never be an unkillable
  permanent Retain. Wrote 3 uncommon cards pushed hard above the normal curve
  for their cost — Reckless Swing (1-cost, 10 damage, vs. Slash's 6),
  Guarded Instant (1-cost, 10 Block, vs. Brace's 5), Fading Insight (0-cost,
  draw 2, vs. Take Aim's cost 1 for the same draw) — and remembered #57's own
  logged trap: added them to the global `cards.json` reward_pool AND all five
  characters' own `reward_pool` arrays in `characters.json`, since
  `Content.reward_pool()` only falls back to the global list when a
  character has none of their own, and all five already do. Also added the
  `ethereal` keyword (text and the `_keywords_of` mapping) so
  `_test_every_field_a_player_must_understand_has_a_keyword` still passes.
  3 new tests, all green, plus the existing suite untouched. Not done: the
  same `_meld_cards` gap #57 flagged (type-specific fields silently drop on
  a meld) also applies to `ethereal` — no current card carries both `meld`
  and `ethereal`, so it's unreachable today, flagging rather than fixing
  since it's the same pre-existing gap, not new to this item.

- **2026-08-26** — #57 Powers, cards that stay played: added `type: "power"`
  plus `power_effect`/`power_value` fields on Card. Playing a power routes it
  into a new `PlayerState.powers` dict (id -> `{stacks, value}`) instead of
  the discard pile — `_handle_power_effects`, hooked onto #43's `turn_end`
  moment, re-fires it for every remaining turn of the fight, stacking cleanly
  when the same power is played twice. The vocabulary (block/strength/wound/
  vulnerable/frail/thorns/heal) deliberately mirrors `use_potion()`'s effect
  match so a future power needs no new code, just a data entry. Caught one
  real bug before it shipped: the first draft had the recurring payout
  re-derive its value from `Content.make_card(id)` each turn, which is fine
  for the effect KIND (upgraded_copy() never changes that) but would have
  silently thrown away a campfire-upgraded copy's bumped number, since the
  upgrade shares the base card's id — fixed by storing the SUM of what every
  played copy actually carried, and added a test that plays an upgraded
  power and checks the boosted amount, not the base one, actually pays out.
  Wrote 4 cards (Iron Husk, Old Grudge, Seeping Venom, Barbed Hide — block,
  strength, poison, thorns) into the global pool AND every character's own
  reward_pool (reward_pool() only ever draws from a character's own list
  when one exists, and all five already have one, so the global list alone
  would have made them undraftable in a real run — worth remembering for the
  next content item, since it's an easy silent-unreachable trap). Also gave
  `_keywords_of`/`_card_icon` a generic power_effect-based fallback and a
  `powers` array in `_players_public()` (visible to the ally, same as
  potions — a played power is board state, not a secret). 12 new tests, all
  green, including a full host/client snapshot-boundary check. Not done:
  `_meld_cards` doesn't know about power_effect/power_value, so melding a
  power card together with another would silently drop it back to a normal
  attack/skill card — a pre-existing gap in how meld handles ANY type-
  specific field, not new to this item, and no current power card carries
  `meld: true` so it's unreachable today; flagging rather than fixing since
  it's not this item's scope.

- **2026-08-26** — #56 Ascension 9 and up: added two tiers that change a RULE
  rather than a number, same idiom as #13's rule-changing relics — "Cursed
  Start" (level 9, `start_curse`) shuffles a `bruised_grip` status card into
  every hunter's deck before the run begins, reusing the exact card #27's
  event `curse_card` effect already grants; "Sealed Market" (level 10,
  `no_shop_removal`) drops the "Thin the deck" offer from shop stock entirely
  rather than pricing it up further, leaving campfire removal untouched. Both
  wire through the existing generic `_asc.get(key, 0)` pattern with no new
  branch shape, and are proven the same way #22 proved the first eight —
  paired same-seed runs one tier apart, checking the actual deck/shop
  changed, not just `Content.ascension_mods()`. Picked up #55 first ("More
  beasts") but it turned out to be blocked: #80's art-coverage test now fails
  the whole suite on any beast id without its own `.glb` and portrait, so
  cloud-safe data-only beasts aren't buildable under rule 2 any more — left a
  note on #55 itself rather than silently skipping it, and moved to #56.

- **2026-08-26** — #54 Keyword coverage for everything added since #16: the
  field->keyword MAPPING it asked for was already done —
  `_test_every_field_a_player_must_understand_has_a_keyword` (landed
  2026-08-24) walks every `Card` field by reflection and probes each alone,
  so a new field is covered the moment it's declared with no list to keep in
  sync; ran it fresh against HEAD and it, and every other keyword test,
  passed with an empty `missing` list. Rather than tick it off having found
  nothing, checked the other half #54 actually named — "graded timing" — and
  found the "timed" keyword's TEXT had gone stale instead: it was written
  when a hit was binary (nailed or missed) and still reads that way after
  backlog #33 graded it into TIMING_PERFECT (full bonus) and TIMING_GOOD
  (half, `Combat.TIMING_GOOD_SCALE`), so a player reading the tooltip would
  never learn that catching the edge of the bright zone still pays out —
  exactly the "mechanic the player has to guess" #54 is about, just in prose
  rather than a missing field. Reworded it to name both tiers, and added
  `_test_timed_keyword_explains_graded_quality` (asserts the text mentions
  "half") so this specific kind of drift — a keyword whose MEANING moved out
  from under its own tooltip — fails loudly next time rather than silently.
  Also found, while reading the boss/player snapshot code to check nothing
  else had drifted, that Frail/Artifact/Thorns never reach `GameHost`'s boss
  dict at all (only vulnerable/strength/wound do) — a real gap, but plumbing
  rather than a keyword problem, so it went to Later rather than into this
  item. `run_tests.gd`: all green, including the new test.

- **2026-08-26** — #53 Events that branch more than once: added an optional
  `then` key to an event choice — `{text, choices}` shaped exactly like the
  event itself. `Run.pick_event` applies the picked choice's own effects as
  before, and if it carries a `then`, swaps `event` for the follow-up in
  place (same title, new text/choices) and stays in `Phase.EVENT` instead of
  resolving the node — a second `pick_event` call answers the follow-up
  exactly like a fresh event, and would recurse again if that choice also had
  a `then` (none currently do; one level is all four new ones use, but
  nothing stops a longer chain). Reward routing only checks the picked
  choice's own `effects.reward` when there's no `then` to walk into, so a
  branching choice's reward belongs on the FINAL beat — documented in both
  `events.json`'s `_comment` and the function's doc comment, since getting
  that backwards would silently skip the reward screen. Gave four existing
  choices a second beat rather than writing new events, since the item asked
  for the mechanic to exist, not for more content: `napping_beast`'s "Harvest
  the fur" (the beast's eye cracks open — freeze and keep everything, or bolt
  and take the same heal/relic the choice already had), `the_toll_crow`'s
  "Push past" (the crow keeps following — feed it and walk free, or ignore it
  and take the same bruise as before), `the_gambling_crow`'s "Wager a potion"
  (it's still watching your belt — go again for double, or call it even),
  and `rockslide_altar`'s "Dig it free" (the relic feels wrong in your hand —
  keep it, or cast it back for a small heal instead). In every case the
  original choice's own effects were split across the two beats rather than
  bolted on top, so the two-step version isn't strictly more generous than
  the one-step version it replaced — it's the same stakes with a second
  decision in the middle, which is what the item actually asked for. Three
  new tests: one proves a `then` beat replaces `event` in place and the phase
  stays EVENT after the first `pick_event`, one proves both beats' effects
  land and reward-routing waits for the final beat (two `pick_event` calls,
  checked HP, gold, phase and `reward_kind` together), and one walks
  `Content.list_events()` asserting at least 4 events carry a `then` (found
  exactly the 4 written here). `run_tests.gd`: all green, no existing test
  touched. `node tools/cardlab/build.js`: 164 cards, 35 relics, 17 potions,
  0 unreachable — unchanged, since this item touched no card/relic/potion
  data, only event choices.

- **2026-08-26** — #52 Potions across the whole effect range: the ten
  existing potions were exactly five effects times a small/large pair
  (`heal`/`block`/`strength`/`energy`/`draw`), which the item itself named as
  "a ladder rather than a choice." Rather than just tacking more size tiers
  onto the same five, gave each of them a THIRD option that's a co-op choice
  instead of a bigger number: `heal_ally`/`block_ally`/`energy_ally`/
  `strength_ally`/`draw_ally`, the same `ally_index()` hand-off `ally_block`/
  `ally_energy`/`ally_heal` cards already use — so every one of the five old
  effects now has a real decision (help yourself or your ally) rather than
  "which number is bigger," and none of them is a bare pair anymore. Then
  added two effects no card can reach at all: `climb` (Foothold gained
  directly, no card slot, no energy, no timing — Grapple Tonic) and
  `strip_ward` (spends the TITAN's own Artifact stacks directly — Corrosive
  Oil — rather than needing a debuff card that Artifact would just shrug off
  one of; justified against `frost_sentinel`'s seeded `artifact: 2`). All
  seven new effects route through `Combat.use_potion`'s existing generic
  `{effect, value}` match — no per-potion special case, same shape the five
  original effects already used. 17 potions total now (was 10), 7 effect
  families (was 5). Did NOT touch the five existing potions' own values —
  changing those would be re-numbering an already-tuned economy, which reads
  as the balance-tuning the standing rule forbids; the new third option is
  content, not a retune. `_test_potions_all_load`'s `known_effects` allowlist
  was hardcoded to the original five and would have silently failed every new
  potion as "unknown effect" — extended it rather than leaving it stale, since
  that's exactly the kind of drifted test #16/#54 exist to catch. One new
  test, `_test_use_potion_ally_and_beast_effects`, covers all seven: each
  `_ally` effect lands on the ALLY and not the drinker, `climb` moves Height
  with no card/energy and is still capped at `FOOTHOLD_MAX`, and `strip_ward`
  spends Artifact down to (and never below) zero. `run_tests.gd`: all green.
  `tools/cardlab/build.js` doesn't exist in this checkout (Node module not
  found) so it wasn't run as a smoke check this round — not one of the three
  required test commands, so not a blocker.

- **2026-08-25** — #51 A dropped hunter can come back: `GameHost._on_peer_left`
  already paused the run and remembered `_disconnected_slot`, but it never
  cleared the peer's spot in `_slot_of`/`_peers`, so a reconnecting peer (a new
  ENet connection, and therefore a brand-new `peer_id`) had nowhere to land —
  `_handle_join` would see the party already at `_required` and turn it away
  forever. Fixed in `_handle_join`: an unrecognised "join" that arrives while
  `paused` and a slot is on record as dropped now reclaims THAT slot
  (`_reclaim_slot` — erases the dead peer id's mapping, points the slot at the
  new one, clears `paused`/`_disconnected_slot`, rebroadcasts) instead of being
  rejected. Also handled the odd case of a peer landing back on its OLD id
  (the local-loopback transport tests use can do this even though real ENet
  won't): the already-known branch now checks whether that peer owns the
  disconnected slot and unpauses too, rather than sitting recognised-but-frozen.
  Nothing on the view side needed to change — `menu.gd`'s existing "Join" flow
  already ends every connection in `Session.client.join()` (`_on_join()`), so
  the same button that starts a session is the one that resumes one; this was
  a `/net` + `/session` gap, not a missing screen. One known limitation, left
  alone as out of scope for a two-required-player co-op game: `_disconnected_slot`
  only remembers the LAST drop, so two simultaneous drops would lose track of
  the first — not attempted here since `paused` already blocks all play the
  moment either hunter is gone, and reconnecting the second unpauses the game
  with the first still absent. New test
  `_test_dropped_hunter_can_rejoin_mid_fight`: drops hunter 2 mid-combat,
  connects a fresh `GameClient` on a new peer id, joins, and asserts the pause
  clears, the new connection is handed slot 1 (not a rejected join or a new
  slot), it receives hunter 2's actual hand rather than an empty one, a played
  card acts on hunter 2 again, and dropping that same new id re-pauses the
  run — proving the old id was actually forgotten rather than left as a second
  live seat. `run_tests.gd`: all green, 326 assertions (319 prior + 7 new).
  `node tools/cardlab/build.js`: unchanged (164 cards, 35 relics, 0
  unreachable) — this item touched no data files, only `/net`-adjacent code.

- **2026-08-25** — #50 Enchantments beyond the two proving ones: `enchants.json`
  went from 2 entries (only one with a consumer) to 8, covering every category
  the item named — cost (`cheap`: `cost_cut`, read in `effective_cost`), draw
  (`keen`: `bonus_draw`, drawn alongside the card's own `draw` field in
  `play_card`), exhaust (`spent`: `self_exhaust`, routes the played card to
  `exhaust_pile` instead of `discard_pile`), target/co-op (`bonded`:
  `echo_block` mirrors any Block the card grants onto the ally; `generous`:
  `ally_energy_gift` hands the ally a flat amount of energy regardless of the
  card's own `ally_energy` field) and a second timing effect (`true_eye`:
  `quality_up`, upgrades a landed TIMING_GOOD hit to TIMING_PERFECT before
  `preview()` grades it — `wide`/`timing_zone` stays the one entry with no
  `/core` consumer, since widening a timing window is inherently client-side
  and still needs a screen, same as #12's log already said). All six read
  `card.enchant_data().get("effect", ...)` generically off `Card.enchant`, the
  same dispatch `auto_nail` already used — none of them special-case an
  enchant id anywhere. `play_card` now reads `enchant_data()` once into a
  local instead of the three separate calls the old fumble-check line made,
  since six consumers off the same dict made that worth doing. 6 new tests,
  one per new effect, in the same shape `_test_sure_enchant_lands_even_on_a_fumble`
  already used (build a combat, enchant a hand card, play it, assert the one
  behaviour). Two of them (`Card`-typed locals assigned from `enchanted_copy()`
  on an `Array`-typed hand) hit a GDScript static-inference error on `:=` that
  the existing `sure` test's plain-assignment style never tripped — fixed by
  giving those two locals an explicit `: Card` type instead of inferring it.
  `run_tests.gd`: all green, 316 assertions (310 prior + 6 new).
  `node tools/cardlab/build.js`: 164 cards, 35 relics, **8 enchants** (was 2),
  0 unreachable, same 6 pre-existing findings — this item touched no cards,
  relics or events, only `enchants.json` and the two files that read it.

- **2026-08-25** — #49 A daily run everyone shares: built directly on #38's
  shareable seed rather than adding new machinery. `Run.daily_seed(date_string)`
  is a pure `String.hash()` of the date (deterministic in Godot, same guarantee
  the plain typed-in seed already relied on; a hash landing on 0 — which `_init`
  reserves to mean "roll randomly" — is nudged to 1). `Run.new_daily(decks,
  names, date_string, ...)` wraps that seed together with a new
  `DAILY_ASCENSION := 0` constant, pinned rather than left at the caller's own
  ascension, so a race is fair regardless of career-unlock progress (#42) —
  ascension 4+ content would exclude players who haven't earned it, which
  defeats "everyone shares." Two new `Run` fields, `is_daily`/`daily_date`,
  round-trip through `to_dict`/`from_dict` the same additive way `stats` (#39)
  and `potions` (#26) already do — no `SAVE_VERSION` bump, since a missing key
  just defaults to `false`/`""` on an old save. Wired one layer up too:
  `GameHost` takes an optional `daily_date` and, when set, calls
  `Run.new_daily()` instead of `Run.new()` inside `start_new_run()`, and the
  shared snapshot now carries `"is_daily"` next to the `"seed"` key #38 added —
  the same "a getter nobody's snapshot exposes doesn't help" lesson #38's own
  log entry drew. Did NOT touch `menu.gd` or add a way to actually pick "play
  today's daily" on screen — that's a `needs a screen` follow-up (mirrors how
  #38 landed the seed without a "type a seed in" box); what's here is the
  engine a future menu button calls into. 3 new tests: `daily_seed` is stable
  for the same date and differs across two dates, `Run.new_daily()` with a
  shared date produces an identical map/shop/reward roll the same way #38's
  test proves for a typed seed (and a different date re-rolls all three), the
  flag+date+pinned-ascension survive a save/load round trip, and a `GameHost`
  given a `daily_date` actually starts a daily and exposes it in the shared
  snapshot. `run_tests.gd`: all green, 310 assertions (307 prior + 3 new).
  `node tools/cardlab/build.js`: unchanged (164 cards, 35 relics, 0
  unreachable, same 6 pre-existing findings) — this item touched no data files.

- **2026-08-25** — #47 A fifth hunter, driven by a resource: The Lightbearer
  (`design/climbing-and-characters.md`'s stretch-5th concept, an owl portrait
  since no new art was in scope), built on Light — a resource that BANKS
  across turns instead of resetting like energy or Rhythm does, since nothing
  in `_begin_round()` touches it (deliberate — that's the whole point of the
  design ask, "a currency it banks and spends"). Four new `Card` fields
  (`light_gain`, `light_cost`, `damage_per_light`, `ally_heal`) follow the
  exact shape `damage_per_rhythm`/`grip_per_rhythm`/`rhythm` already
  established: `light_cost` is a second cost checked in `can_play` alongside
  energy and spent in `play_card` even on a fumble (same treatment as energy);
  `light_gain` and `ally_heal` (clamped to the ally's max_hp, mirroring the
  existing potion "heal" effect) apply in the main effect body so a fumbled
  timed card doesn't trigger them; `damage_per_light` folds into `preview()`
  the same way every other scaling field does, so it reads Light WITHOUT
  spending it — the deliberate build tension between Flare (spend 5, deal 14
  now) and Sunburst (spend nothing, scale with however much is banked). New
  `light`/`mend` keywords added to `keywords.json` and wired into
  `GameHost._keywords_of` — the reflection-based test added by #16
  (`_test_every_field_a_player_must_understand_has_a_keyword`) would have
  failed loudly on the new fields otherwise, and did until that was in place.
  9 new cards (`spark`, `radiant_bolt`, `warm_glow`, `kindled_strike`,
  `beacon`, `guiding_light`, `steady_flame`, `flare`, `sunburst`) — enough
  for a full 10-card starter deck plus a modest reward pool of its own
  archetype cards + the same shared neutrals every other class drafts from.
  Worth being honest about: this reward pool is ~18 cards against the other
  four classes' ~40-44 — #47 explicitly warned this would take "several
  runs," and this one covered the engine, the starter deck, and a first pass
  of cards, not the deep pool the other four have accumulated over multiple
  sessions. A future session writing more Light cards is exactly that kind of
  follow-up, the same way #50 is still open for enchants. The passive slot
  is `"none"` (already a legal no-op value) — deliberately did NOT hang the
  resource off a character passive the way climb_bonus/poison_lift/etc. do,
  since the design ask was "build it on a resource, not a keyword" (the
  resource itself, not one more passive scalar). 7 new tests: Light banking
  across the round reset (proving it does NOT reset like Rhythm), the
  light_cost gate-and-spend round trip, damage_per_light scaling without
  spending, ally_heal clamping at max_hp, `PlayerState.light` surviving both
  a bare dict round trip and a REAL mid-combat save/load (the #14 seam), and
  a full `Run` played with the Lightbearer's own starter deck through to a
  win, drafting only from its own pool (same proof `_test_per_class_reward_pools`
  uses for the other four). `characters.json`'s `order` array is the only
  place a new character needs registering — `Content.list_characters()` is
  what the content-integrity tests, the robustness sweep, and the host's
  character list all already iterate, so adding one entry there is what pulled
  the new character and its 9 cards into every existing coverage test for
  free, exactly as designed. `run_tests.gd`: all green, 307 assertions (300
  prior + 7 new). `node tools/cardlab/build.js`: 164 cards (155+9), 5 classes,
  0 unreachable — same 6 pre-existing findings as the baseline (checked by
  diffing against a stash of this commit's parent), so nothing new is broken.
  Left the Light meter itself for a `needs a screen` follow-up (#78, new) —
  the card text and keyword tooltip explain the number, but there's no
  running HUD counter the way Energy has pips, and that's a visual claim this
  session can't verify.

- **2026-08-25** — #48 Relic tiers, and a pool only Titans pay from: every
  relic in `relics.json` now carries `"tier"` — `"common"` (31) or `"boss"`
  (4). The boss tier didn't need new content: the four downside relics #30
  already wrote (Warlord's Girdle, Bottomless Quiver, Fortress Ward, Adrenal
  Surge) already read as the StS boss-relic idiom — real power, real cost —
  they just weren't gated, exactly as the item said. `Content.relic_pool()`
  now excludes `tier: "boss"` (so shop, treasure and an elite's payout never
  offer one) and a new `Content.boss_relic_pool()` returns only those four;
  `Run._begin_reward()` picks between them by checking `node_type == "boss"`,
  which is already how the code tells a Titan kill apart from an elite's. 3
  new tests: `relic_pool()`/`boss_relic_pool()` partition all 35 with no
  overlap, a Titan's actual reward (driven through `_force_win`/`_pick_both`
  the same way `_test_elite_pays_a_card_then_a_relic` already does) offers
  only boss-tier ids, and an elite's never does. `run_tests.gd` all green,
  300 assertions (297 prior + 3 new). `node tools/cardlab/build.js` clean (35
  relics, 0 unreachable — the flat `pool` list is untouched, only which
  function reads which slice of it changed). Ran `balance_sim.gd` as the
  standing smoke test and it's worth writing down plainly rather than
  quietly noticing: COORDINATED win rate at A0 dropped from the ~36% prior
  sessions logged to 22%, reproduced by diffing against a stash of this same
  commit's parent (36% before, 22% after, same seeds both times — not
  variance). Root cause isn't a bug in the feature; it's `balance_sim.gd`'s
  own `_pick_reward()` heuristic, which grabs any relic whose `effect` is
  `attack_bonus` or `max_energy` and has never read `downside_effect` — two
  of the four boss relics match that filter, and now that they're the ONLY
  thing on offer after a Titan (not mixed in among 31 safe ones) the
  "coordinated" policy grabs them and eats their downside blind, every
  Titan, every run. `balance_sim.gd` is explicitly not to be tuned against
  (standing rule #5), and this isn't a soft-lock either — #46's sweep policies
  don't special-case relic effect names, so they're unaffected. Left the sim
  and the relics alone; flagging the heuristic gap here in case a future
  session wants a smarter (downside-aware) `_pick_reward` for its own sake.

- **2026-08-25** — #46 A robustness sweep that is not balance tuning:
  `tools/robustness_sweep.gd`, a sibling to `balance_sim.gd` that measures
  nothing about skill — it plays 216 complete seeded runs (all 6 character
  pairs x ascension 0/4/8 x 6 seeds x a "naive" and a "random" legal-action
  policy) and asserts, at every MAP/EVENT/CAMPFIRE/SHOP/REWARD/BOON/COMBAT
  decision point, that a legal action exists and the run reaches WON/LOST
  within a 4000-step guard. It found zero real dead ends, but it did catch
  one false one worth writing down: the sweep's own end-of-turn check first
  read `ended_turn` immediately after calling `Combat.end_turn(pi)` and
  flagged every game where the SECOND hunter to act ended their turn, because
  for the last player `end_turn()` runs the enemy turn synchronously and, if
  the fight continues, `_begin_round()` resets `ended_turn` back to false for
  the new round right there — so the flag being false a moment later is the
  round working correctly, not a stuck hunter. Fixed by also treating a
  round-number change or the fight ending as proof the turn resolved. Also
  added five fast, deterministic regression tests to `run_tests.gd` pinning
  the specific escape hatches the sweep depends on (campfire rest at
  MIN_DECK, leaving an empty shop, every event having a choice, skipping an
  empty reward, ending a turn with an empty hand and no energy) so a
  regression here fails the always-on suite immediately rather than waiting
  for someone to run the sweep by hand. `run_tests.gd`: all green, 297
  assertions (292 prior + 5 new). `balance_sim.gd` run as a smoke test only,
  unchanged from prior sessions (36% coordinated at A0) — nothing here
  touches drafting or spending.

- **2026-08-25** — #45 Prove the new mechanics cross the client/server
  boundary: checked all six named in the item against `game_host.gd`/
  `game_client.gd` rather than assuming they were fine because they had
  `/core` tests. Two were real gaps, not just untested ones. Potions
  (#26) had NO command at all — `Run.use_potion()`/`discard_potion()` sat
  in `/core` completely unreachable over the network, and no snapshot ever
  mentioned a potion, so three slots of inventory were invisible and unusable
  from any client. Added `"use_potion"`/`"discard_potion"` to `GameHost`'s
  command match (routed through the existing `_acting_slot`/`_in_combat_action`
  guards, same as every other per-hunter command — a co-op peer can never
  address another hunter's slot no matter what they send, proved by a spoof
  attempt in the new test), matching `GameClient` methods, and a `potions`
  field in `_players_public()` — shared, not private, since a held potion
  isn't secret information the way a hand is. Graded timing (#33) had a
  narrower gap: the private hand snapshot only ever sent `preview` (PERFECT)
  and `preview_miss` (fumble); a client could never learn what a `TIMING_GOOD`
  hit was worth, so an osu-style approach circle would have nothing honest to
  show for landing off-centre. Added `preview_good` alongside them, same
  formula, third quality tier. The other four (curses, Retain/Innate, named
  holds) turned out to already cross correctly — cards travel whole through
  the existing per-hunter hand snapshot and `ledges` was already sent raw —
  so those became regression tests rather than fixes. 8 new tests, all
  through a real two-peer `GameHost`/`GameClient` pair via `_make_session()`,
  checking both directions: what the ALLY sees (potions, shared) and what
  they don't (the other hunter's exact hand). One test needed a rewrite
  after the fact: the first graded-timing assertion compared a played card's
  raw `preview.damage` against the boss's actual hp drop and failed, because
  `Combat._damage_boss()` runs every hit through the climb's own armor
  divisor when the hunter hasn't reached the sigil — nothing to do with
  timing, so the fix zeroes `weak_point_height` for that one test rather
  than chasing the armor math. `run_tests.gd` all green, 292 assertions
  (280 prior + 12 new); did not run `balance_sim.gd` since nothing here
  touches drafting, spending, or numbers.

- **2026-08-25** — #44 Titans that change their pattern when hurt: two new
  `Boss` fields, `hurt_pct` (fraction of max_hp) and `hurt_moves` (a second
  move list, same shape as `moves` — "when"/"fallback" both still work
  inside it). `current_move()` now reads through a new `_active_moves()`
  that returns `hurt_moves` once `hp <= max_hp * hurt_pct`, `moves`
  otherwise; `hurt_pct` defaults to 0.0, which short-circuits the check, so
  every beast without the new fields (all of them, until this commit) is
  byte-for-byte unchanged. Deliberately did NOT give the switch its own
  index or reset `_move_index` on crossing the threshold: both lists are
  read through the same `_move_index % list.size()`, so a beast that gets
  hurt mid-pattern continues wherever it already was rather than restarting
  its rotation at move 1 — a test (`_test_backlog44_same_move_index_drives_
  both_lists`) proves this by advancing the index once, checking it lands on
  each list's own SECOND move, not first. `Content.build_boss()` loads both
  fields from data the same way `moves`/`ledges` already do, so a resumed
  save recomputes the active list live from hp rather than needing anything
  new persisted — `to_dict()`/`apply_dict()` untouched. No view code needed
  touching either: `current_move()` was already the one place the telegraph
  (`game_host.gd`'s `"intent"`) and the balance sim both read the pattern
  from, so the switch is visible wherever the plain pattern already was,
  automatically. Three beasts, one per pool, matching #40's spread: the Crag
  Pup (`fight`, hurt_pct 0.35) drops its block move and leans harder on its
  sigil bite; the Mire Snapper (`elite`, hurt_pct 0.35) goes leech-heavy,
  trying to heal back what it's lost; the Gale Serpent (`boss`, hurt_pct
  0.35) drops its `enrage` buildup for repeated `attack_all` sweeps — a
  shape change in each case (which moves exist, not just their numbers),
  not a tune. 5 new tests: the switch itself (above/at/below the threshold),
  the same-index proof above, a beast with `hurt_pct` left at its 0.0
  default never switching (the "unchanged for everyone else" guarantee),
  a real `Combat.end_turn()` round trip proving the actual enemy-turn
  resolution picks the hurt pattern once hp crosses the line (not just
  `current_move()`'s prediction), and a content sentinel walking every real
  beast confirming at least three carry a paired `hurt_pct`/`hurt_moves`
  and genuinely switch at the threshold (found 3). `run_tests.gd` all green
  (280 assertions incl. the five new ones); `node tools/cardlab/build.js`
  clean (155 cards, `unreachable: 0` — bosses.json isn't part of its
  reachability graph, ran anyway since the file changed); `balance_sim.gd`
  ran clean as a smoke test only (36% coordinated at A0 this run, within the
  36-42% range seen across prior sessions — nothing here touches drafting
  or spending policy, so this is ordinary run-to-run variance, not tuned to).

- **2026-08-25** — #73 osu sliders: a timed card that climbs 2 or more is now a
  HOLD, not a tap — press on the beat, keep hold while the follower runs the
  path, let go past the rescue mark and it still pays at Good. Two things
  surprised me. The threshold started at Climb 3, where exactly TWO cards in the
  whole game qualified, so the feature would have shipped effectively dead; at 2
  it is five. And the whole path came out flat because `card.grip` is not a
  top-level snapshot key — printed values live under `base`, so every card read
  as Climb 0, silently. The harness could not find a slider card either, which
  is the only reason it surfaced. Chains and sliders both now start AT THE CARD
  and travel to the hold, and the approach is 0.80s (was 0.58).

- **2026-08-25** — #43 One trigger point instead of scattered special cases:
  a small, named set of moments (`Combat.MOMENT_TURN_START`/`_TURN_END`/
  `_CARD_PLAYED`/`_DAMAGE_TAKEN`/`_HUNTER_CLIMBS`) plus a generic `_on(moment,
  handler)` / `_fire(moment, ctx)` pair — a `Dictionary` of moment name ->
  `Array[Callable]`, `ctx` a plain `Dictionary` handlers can both read and
  write (GDScript passes it by reference, so a handler that needs to change
  what the caller does next — see block_carries below — mutates a key on it
  instead of needing its own return-value protocol). Three existing
  special-cased branches moved onto it as the proof, all three already
  covered by pre-existing behavior tests so the suite itself is the "no
  behaviour change" proof rather than anything new: **block_carries**
  (turn_start) used to compute `carried` inline in `_begin_round()` before
  overwriting Block — now `_begin_round()` fires `turn_start` with a
  `carried_block` key defaulting to 0, and `_handle_block_carries()` sets it
  only if the relic total is present, read BEFORE the caller applies it, so
  the actual arithmetic is unchanged. **energy_handoff** (turn_end) used to
  be a straight `if _mod(...) > 0` block inside `end_turn()` — now `end_turn()`
  just fires `turn_end` and `_handle_energy_handoff()` carries the same
  gate, same log line, same early-outs (`ps.energy <= 0`, ally already
  ended). **Timed-card Rhythm** (a fixed core rule, not a relic — included as
  the third proof since it's wired at exactly the same call site a
  relic-driven `card_played` handler would use) moved from
  `if card.timed: ps.rhythm += 1` inline in `play_card()` to
  `_handle_timed_rhythm()`. One real trap caught before it shipped: all
  three handlers had to be registered **unconditionally** in `_init()` and
  read `_mod()` live at FIRE time rather than being registered only when the
  relic total is present at construction — `Combat.from_dict()` builds a
  fresh `Combat` with the default empty `_mods` and only overwrites `_mods`
  *after* `_init()` already returned (mirrors how every other `_mod()` call
  in this file already has to work), so a handler gated at registration time
  would have silently stayed unwired on any fight reloaded from a save,
  which is exactly the kind of bug this item was supposed to make less
  likely to happen again, not introduce one on its own first outing. The two
  moments nothing subscribes to yet (`damage_taken`, `hunter_climbs`) still
  fire with real context at every real damage instance (`_boss_hits()` and
  `_damage_boss()`) and every new climb peak (`_track_climb()`, now gated on
  `foothold > highest_climb` so it fires on an actual new high rather than
  every card play) — they exist and work, just have no consumer content yet;
  future relics/potions/cards are the reason this item was worth doing, not
  something it had to deliver itself. One new test
  (`_test_backlog43_trigger_moments_exist_and_fire`) proves those two
  specifically: a Slash against an armored Titan fires `damage_taken` with a
  positive amount and the correct target, a Grip climb from Height 0 fires
  `hunter_climbs` exactly once with the new foothold, and calling the
  tracker again with nothing moved does NOT re-fire — proving the "new peak"
  gate actually gates rather than firing on every touch. `run_tests.gd` all
  green (276 assertions incl. the one new one, the pre-existing #10/#33
  tests the migration leaned on for regression proof unchanged);
  `balance_sim.gd` ran clean as a smoke test only (36% coordinated at A0
  this run — ordinary run-to-run variance against the 36-42% range seen in
  prior sessions, nothing here touches drafting or spending policy so this
  is not something tuned to).
- **2026-08-25** — #42 Something to unlock between runs: the gate is a single
  career counter, `Progress.total_wins()` — separate from `unlocked_ascension()`,
  which only advances on a NEW hardest tier cleared and so would never
  accumulate anything to gate content on if a player replays an already-won
  tier; `record_win()` now always banks a win toward it, restructured so the
  ascension-ladder check no longer early-returns before that happens. A card or
  relic may carry an optional `unlock_wins` (int) in its data; `Content.
  relic_pool(wins)`/`reward_pool(character_id, wins)` filter it out below that
  bar, both defaulting to a new `Content.UNLOCKED_ALL` sentinel so every one of
  the ~15 existing call sites that doesn't pass `wins` keeps seeing the whole
  pool unchanged — the gate is opt-in per call site, not a global cut. `Run`
  carries the value it was built with (`_unlocked_wins`, threaded through all
  four of its own `relic_pool()`/`reward_pool()` call sites — the shop, an
  event's free-relic grant, and both reward-screen branches) and exposes it
  via `unlocked_wins()`, the same read-only-getter shape `seed_value()` (#38)
  already established; round-trips through `to_dict()`/`from_dict()` the same
  additive-backfill way #35 requires — an older save missing the key backfills
  to `UNLOCKED_ALL` (everything open), never to 0, since a save from before
  this item existed must not retroactively lock content nobody meant to gate.
  Wired all the way live, not left as a dead hook: `GameHost` gained the same
  parameter (mirroring how `ascension` already flows from the menu), threading
  it into `Run.new()` on a new run and restoring it from the save on
  `resume_run()` rather than trusting the fresh constructor default. `menu.gd`'s
  two new-run call sites (`_on_solo`, `_on_host`) now pass `Progress.
  total_wins()` in exactly the slot `_ascension` already occupies — a one-line
  numeric substitution into an existing constructor call, no new UI, so unlike
  #31/#31b's boon (a new phase needing a scene to not soft-lock every run) or
  #29/#29b's X-cost card (a raw `int(cost)` display bug only a screen could
  catch), there's no reason this half needs one: nothing renders differently,
  only which ids a pool can draw from. `_on_continue` (resuming a save) was
  deliberately left passing no gate at its own construction — `resume_run()`
  overwrites it from the save's own value immediately after, so threading it
  there too would've been dead code. Kept the gate genuinely small per the
  item's own instruction: exactly one new relic (`summit_cairn`, start_foothold
  3, unlock_wins 1 — a first-win reward) and one new rare card
  (`trailmasters_cut`, unlock_wins 3), both ADDED to the pool rather than an
  existing relic/card retroactively locked, so no run's available content gets
  worse — only bigger, once earned. `node tools/cardlab/build.js` confirms both
  reachable (`unreachable: 0`); its "offered" flag doesn't distinguish
  gated-but-real from always-available, which is correct for that tool's own
  job (reachability, not runtime gating) and out of this item's scope. 6 new
  tests: `total_wins()` climbs on a replayed already-cleared tier as well as a
  new one (proving it's tracked independently of the ascension ladder, not
  derived from it); `relic_pool()`/`reward_pool()` gate correctly at, below,
  and above the threshold, with the no-arg default unaffected; a real `Run`
  built with 0 unlocked wins never offers the locked relic in a real
  `_begin_shop()` call (deterministic — an excluded id literally isn't in the
  candidate array, not a probabilistic sampling check); a save/load round trip
  proving both the value and the missing-key backfill; and a full `GameHost`
  resume (mirroring `_test_host_autosaves_and_resumes`'s own shape) proving the
  gate survives that trip via the save, not the second host's own constructor
  default. Also redirected `Progress.use_scratch_slot("run_tests")` at the top
  of `run_tests.gd`'s `_init()`, alongside the existing `RunSave` one — a
  pre-existing gap (several older hint/tips tests read/write the DEFAULT
  `user://progress.cfg` with no redirect) that this item's own new tests would
  otherwise have hit too; fixing it at the top level is the same class of bug
  `tools/screenshot.gd` was already flagged for (#34's log) and now nothing in
  the suite can silently corrupt a real designer's progress file just by
  running headless tests on his machine. `run_tests.gd` all green (270
  assertions incl. the six new ones); `balance_sim.gd` ran clean as a smoke
  test only (36% coordinated at A0 this run vs. 40-42% in prior sessions — the
  sim's own policies pass no `unlocked_wins` argument, so `Content.UNLOCKED_ALL`
  applies and both new items are simply in its pool same as any other; this is
  ordinary run-to-run sim variance, not something tuned to or caused by this
  item).
- **2026-08-25** — #41 Shops and campfires should trade in potions: turned out
  already done, as part of item #26's original commit (`2cceb23`) rather than
  its own — that commit's own message says so explicitly ("found from shops:
  one stocked per hunter alongside the existing card/relic/removal offers,
  same buy() path"), which this item's own text didn't anticipate when it went
  on the queue. Confirmed rather than assumed: `Run._begin_shop()` already
  rolls one potion per hunter into `shop_stock` at `PRICE_POTION`, and
  `Run.buy()`'s `"potion"` branch already returns `false` *before* touching
  gold or marking the stock item sold when that hunter's `POTION_SLOTS` is
  full — so a full inventory cleanly refuses the purchase rather than
  silently eating the gold. Both halves were already tested too
  (`_test_shop_buys_a_potion`, `_test_potion_slots_are_capped`, the latter
  explicitly covering "a full potion inventory refuses both a fight's drop
  and a shop purchase"). No code changed for this item; ticking it off so a
  future pass doesn't re-derive or re-build this. The campfire half the
  item's prose mentions was never actually required by its own "*Done when*"
  (which only names the shop) — left alone, not a partial completion.
- **2026-08-25** — #40 Beast moves that react to where you are: one optional
  `when` field on a boss move — `{"type": "min_height"|"max_height"|"at_sigil"
  |"undefended", "value": int}` — checked against every hunter's foothold/Block
  at the moment the move comes up in the pattern; a move with `when` also
  carries a sibling `fallback` move (same `{type, value}` shape) used when the
  condition doesn't hold, and a move with no `when` fires exactly as before.
  All in `Boss.current_move(context)`, one generic evaluator (`_condition_met`)
  reused by all four condition types — no per-beast code, matches rule 7.
  `context` (`{footholds: [...], blocks: [...]}`, one entry per hunter) is
  built by a new public `Combat.boss_context()`, used at every real call site:
  `incoming_for()`'s prediction, `_enemy_turn()`'s actual resolution, AND
  `game_host.gd`'s telegraphed `"intent"` sent to clients — the last one
  mattered as much as the other two, since a client showing the fallback's
  icon while the boss was about to fire the reactive move would be a lying
  telegraph, the exact thing CLAUDE.md §5's "no hidden information" spirit
  argues against. Also threaded into `balance_sim.gd`'s `_threatened()` helper
  for the same reason (consistency, not required by the item). Three beasts,
  one per pool so the mechanic isn't confined to a single difficulty band: the
  Crag Pup (`fight`) bites harder (14 vs 10) if a hunter is camped on its
  sigil; the Frost Sentinel (`elite`) answers a hunter at/above its second
  ledge (Height 5) with a sweeping `attack_all` (10 to both) instead of its
  usual single `attack` (14); the Stone Warden (`boss`) punishes an undefended
  hunter with a heavier hit (17 vs 13). Each reactive value is a genuine swing
  in both directions from the move it replaced (not just the fallback
  restating the old number), and every fallback matches what that move used
  to do unconditionally — so a fight where the condition never triggers plays
  exactly as it did before this item, and `balance_sim.gd`'s printed win rate
  (40% coordinated at A0 this run, 42% last session — ordinary run-to-run
  sim variance, not this item) is a smoke-test confirmation, not something
  tuned to. 7 new tests: each condition type in isolation (met and unmet) via
  `Boss.current_move()` directly, a move with `when` but no `fallback`
  defaulting safely instead of crashing, a full `Combat.end_turn()` round trip
  proving the REAL enemy-turn resolution (not just the prediction) picks the
  reactive move with a hunter on the sigil and the fallback without one, and a
  content sentinel (mirrors #17/#37's "at least N" pattern) walking every real
  beast's data confirming at least three react and that every `when` it finds
  is paired with a `fallback`. `run_tests.gd` all green (267 assertions incl.
  the seven new ones); `node tools/cardlab/build.js` unaffected (bosses.json
  isn't part of the card/relic/event reachability graph it checks) — ran
  clean regardless (154 cards, `unreachable: 0`); `balance_sim.gd` ran clean
  as a smoke test only.
- **2026-08-25** — #39 A run summary worth showing at the end: the data half
  only, as scoped — no view code touched. Three counters on `Combat`
  (`damage_dealt_total`, `cards_played_total`, `highest_climb`), each fed by
  a single existing choke point rather than a new call site per card:
  `_damage_boss()` already returns the dealt amount to its one caller, so it
  now also adds that amount to the running total; `play_card()` already has
  one place a card is confirmed to have resolved (`ps.discard_pile.append(card)`,
  reached only AFTER the fumble-slips-away early return, so a fumbled timed
  card correctly doesn't count as "played"); a new `_track_climb()` helper
  (`highest_climb = maxi(highest_climb, ps.foothold)` for both hunters) is
  called once at the end of `play_card()` and once at the end of
  `_begin_round()` — the second call is the one easy to miss, since a Goblin
  Jetpack's `prepare` effect raises a foothold from `_resolve_prepared()`
  during round-start, outside `play_card()` entirely, so climb-tracking only
  at the end of `play_card()` would silently undercount a jetpack rocket to
  the sigil. `Run.stats` is a plain Dictionary (`damage_dealt`,
  `highest_climb`, `cards_played`, `turns_taken`, `beasts_felled`,
  `died_to`), folded in from `Combat`'s three counters plus `combat.round_num`
  inside `Run.sync()` — the one place a fight's end is already detected, and
  already guarded (by `phase != Phase.COMBAT`) against re-entering once the
  phase has moved on, so the fold-in provably happens exactly once per
  fight. `died_to` is set to `combat.boss.name` on the LOSE branch;
  `beasts_felled` increments only on WIN. Persisted the same additive way
  #35 and #26 already establish — `to_dict` adds one `"stats"` key,
  `from_dict` backfills any missing individual stat (or the whole key, for a
  save from before this item existed) from the defaults `_init` already set,
  no `SAVE_VERSION` bump needed since nothing here changes the MEANING of an
  existing field. `Combat.to_dict`/`from_dict` also carry the three counters,
  so a save mid-fight resumes counting from the right spot instead of
  losing partial credit for the fight in progress. 3 new tests: a real run
  played through one won fight (a real card played, not just a forced win,
  so damage/cards actually fire) then one lost fight, proving the totals
  ADD rather than reset between fights and that a loss records what killed
  it; a save/load round trip through the real file (caught a real test bug
  while writing it — comparing the two stats dicts with `str(a) == str(b)`
  failed on a correct round trip because Godot's JSON parser doesn't
  preserve key insertion order, so the fix compares key-by-key instead, the
  same trap a naive dict-equality check would hit anywhere in this codebase);
  and an older save missing the `"stats"` key entirely still loads with
  every default in place. `run_tests.gd` all green (250 assertions incl. the
  three new ones); `node tools/cardlab/build.js` untouched by this item, not
  re-run; `balance_sim.gd` ran clean as a smoke test only — its policies
  never read `Run.stats`, so the printed win rates (42% coordinated at A0,
  same shape as prior sessions) are unchanged, not tuned to.
- **2026-08-25** — #38 A seed you can share: the engine already accepted a
  seed at construction (`Run.new`/`GameHost.new` both take `seed_value`) and
  already drew every map/shop/reward roll from one seeded `RandomNumberGenerator`
  (confirmed by grepping `run.gd` for every `randi`/`rng` call — all of them go
  through `_rng`, none bypass it), so "started from a given one" was already
  true; what was actually missing was "readable" and a test proving the
  determinism end-to-end rather than assuming it. Added `Run.seed_value()`
  (a public getter over the previously-private `_seed`, same trick as every
  other read-only accessor already on the class) and threaded it into
  `GameHost._build_shared()`'s base dict as `"seed"` — the ONE snapshot key
  every phase already carries unconditionally, so it reaches a peer whether
  they're on the map, mid-fight, or in a shop, not just at the phases that
  happened to need it before. Left `menu.gd`'s three `GameHost.new(transport,
  0, ...)` call sites alone (they hard-code seed 0 = "roll randomly") — a
  text field to type a seed into before starting a run is the visible half of
  this and needs a screen to place and verify; the "done when" only asked for
  readable + startable-from + a determinism proof, all three of which are now
  true with zero view code. Two new tests:
  `_test_backlog38_same_seed_reproduces_map_shop_and_rewards` builds two Runs
  from the same seed and confirms identical `map.rows`, then (reaching into
  `_begin_shop`/`_begin_reward` directly the same way `_test_gold_and_shop`
  and friends already do, rather than fighting through a real fight to get
  past row 0 of the map) identical `shop_stock` and `reward_choices`, plus a
  third Run from a different seed diverging on the map — extending the
  existing map-only determinism test (`_test_map_is_deterministic_per_seed`)
  rather than replacing it, since that one still isolates `RunMap` alone;
  `_test_session_shared_state_exposes_the_seed` proves the seed actually
  rides the host->client snapshot boundary (two `_make_session()` calls at
  seeds 42 and 99, asserting each client's `shared["seed"]` matches what the
  session was built with) rather than just existing as an unused getter.
  `run_tests.gd` all green (243 assertions incl. the two new ones);
  `balance_sim.gd` ran clean as a smoke test only — nothing here touches how
  the sim's policies draft or spend, so the printed win rates (42% coordinated
  at A0, same shape as prior sessions' runs) are unchanged, not tuned to.
- **2026-08-25** — #37 Events that know potions exist: three new effect keys in
  `Run._apply_effect_block()`, each reusing an existing shape rather than
  inventing a mechanic — `potion` (a named id) mirrors `curse_card` naming a
  specific card, `random_potion` (bool) mirrors `relic` rolling from a pool,
  and `take_potion` (bool, the "gamble") removes one random HELD potion per
  hunter and quietly no-ops for a hunter carrying none, the same shape
  `remove_card`'s own MIN_DECK floor already treats "nothing to take" as a
  clean no-op rather than a failure. All three respect `POTION_SLOTS` the way
  `_grant_potions()` already does — a full inventory just doesn't grow, so a
  potion-heavy event can't silently overflow the cap `_test_use_potion`'s own
  sibling tests already enforce elsewhere. Four new events (`abandoned_apothecary`,
  `the_gambling_crow`, `field_medics_kit`, `the_wandering_brewer`), in the
  existing wilderness-climber tone, between them touching all three keys (two
  `potion`, two `random_potion`, one `take_potion` paired with a gold gain —
  the actual "wager" framing item 37 asked for). Extended #18's content
  integrity graph to validate an event or boon's `potion` ref the same way it
  already validates `curse_card`, and extended the events.json header comment
  with the three new keys so the file stays self-documenting. 4 new tests:
  the named-potion grant, the slot-cap respected when a hunter is already
  full, the gamble removing a held potion while no-oping for an empty-handed
  ally, and a sentinel (mirroring #17's `_test_backlog17_four_events_touch_the_deck`)
  proving at least 4 events touch a potion so this can't silently regress.
  `run_tests.gd` all green (239 assertions incl. the four new ones);
  `node tools/cardlab/build.js` confirms all four new events reachable
  (`unreachable: 0`); `balance_sim.gd` ran clean as a smoke test only — its
  policies don't call any of the three new keys (events aren't part of its
  simulated loop at all), so the printed win rates are unchanged, not tuned to.

- **2026-08-25** — #36 Frail, Artifact and Thorns: three fields on `Combatant`
  (the base class both `PlayerState.combatant` and `Boss` share, so one
  implementation covers either side for free). **Frail** cuts Block GAINED,
  not a separate stat to remember to check — `Combatant.gain_block()` itself
  does the cut (1/4, floored), so every existing source of Block (cards,
  relics, potions) feels it automatically with zero call-site changes.
  **Artifact** is a ward: `try_block_debuff()` spends one stack to shrug off
  the next debuff, gated in front of the THREE debuff-application points that
  now exist — Expose, Poison, and the new Frail — so a warded beast resists
  all three the same way, not just the one this item added. **Thorns**
  reflects a landed direct attack back at whoever threw it, both directions:
  `_damage_boss()` reflects a Thorned beast's bite back at the hunter who hit
  it, and a new `_boss_hits()` helper (replacing six raw `take_damage` calls
  across attack/leech/attack_all/swipe_high/swipe_low/rift) reflects a
  Thorned hunter's spikes back at the beast — deliberately NOT wrapping
  `fall()`'s knock or the sigil-fatigue/height-split limiter chip, since
  those are the hunter hurting themselves, not the beast attacking, and
  Thorns has nothing to answer there. Two new cards (`Crippling Blow`:
  damage + Frail on the Titan; `Spinebrace`: Block + Thorns on the caster) in
  the global reward pool, and two existing beasts got a new static trait each
  — the Bramble Hog innate Thorns (a spined hog that bites back fits
  literally), the Frost Sentinel innate Artifact (a warded guardian that
  shrugs off your first Expose/Poison/Frail) — content, not balance: neither
  beast's HP or move numbers changed. Deliberately did NOT add a card or
  relic granting a PLAYER Artifact: nothing in the game debuffs a hunter
  today (Frail only ever targets the Titan, Vulnerable/Wound always have),
  so a player-side Artifact stack would be guaranteed-inert rather than
  situational — the same "reachable but dead" trap #27's `winded` card fell
  into, just a mechanical dead end instead of a content one. Skipped a new
  boss move type for the same reason it would have solved that trap: doable
  without touching a view file, but the payoff (making a beast a source of
  player-facing debuffs) is a real design decision, not a one-field
  mechanical follow-on — left for whoever picks that up on purpose. 9 new
  tests: Frail's Block cut in isolation, Frail applied by a card then
  actually cutting the Titan's own `block` move, Artifact warding one debuff
  off and then lapsing, Thorns reflecting a landed boss attack (both that
  the attack still connects AND that the reflection lands), a Thorned beast
  biting back on card damage, a mid-fight save/load round trip through the
  real file (`RunSave`, not a bare `to_dict`/`from_dict` pair — #14/#15's own
  insistence), and the two beasts' new static data. `run_tests.gd` all green
  (235 assertions incl. the nine new ones); `node tools/cardlab/build.js`
  confirms both new cards reachable (154 cards, `unreachable: 0`);
  `balance_sim.gd` ran clean as a smoke test only — neither new card nor
  either beast's new trait is drafted/played differently by the sim's fixed
  policies, so the printed win rates are unchanged, not tuned to.
- **2026-08-25** — #35 Migrate saves instead of throwing them away: the
  version gate in `run_save.gd` used to reject on `!= VERSION`, which meant a
  save from an older build would silently vanish the day `VERSION` ever got
  bumped — it never had, because nobody wanted to be the run that ate every
  in-progress save doing it. Fixed that by making the version check
  directional: `load_run()` now accepts anything `<= Run.SAVE_VERSION` (the
  save constant moved onto `Run` itself, since `to_dict()`'s literal
  `"version": 1` and `run_save.gd`'s own `VERSION := 1` were two copies of
  the same number in two files — a real latent bug, since bumping one
  without the other would have broken every save silently) and only refuses
  a version ABOVE what this build understands (a save from a later build) or
  a version of exactly 0/missing (no version key at all — not a shape any
  build could have written). A new `_migrate()` walks an old save forward
  one version at a time; today's only real step is v1->v2 (v1 predates
  potions entirely, so a save missing the `potions` key gets an empty slot
  array backfilled per hunter, matching what "never held one" already means
  everywhere else) — most fields need no entry at all, since `from_dict`'s
  own `.get(key, default)` calls already treat "missing" as "didn't exist
  yet" for free, which is the reason this item was cheap rather than a
  rewrite. Bumped `Run.SAVE_VERSION` from 1 to 2 to actually exercise the
  path end-to-end rather than leaving the mechanism theoretical. 3 new
  tests: a real save written straight to the file with `version` rolled back
  to 1 and `potions` stripped out loads and backfills correctly (not just
  `to_dict`/`from_dict` — through `RunSave.path` the same way the existing
  save tests insist on, since that's where the JSON-number and version
  gating actually live); a save claiming a version above `SAVE_VERSION`
  refuses; and a plain corrupt (non-JSON) file refuses cleanly rather than
  throwing — the corrupt-file case wasn't covered by any existing test
  despite the module's own doc comment always claiming it. `run_tests.gd`
  all green (233 assertions incl. the three new ones); `balance_sim.gd` ran
  clean as a smoke test only (a save-format change has nothing to do with
  its win-rate output, and nothing here touches it).
- **2026-08-24** — #31 A run-start boon: `data/boons.json` (4 entries — a max
  HP bump, a free relic, gold, and a bold trade that sharpens a card but
  curses one) plus `Content.list_boons()`/`make_boon()`, same shape
  `list_events()`/`make_event()` already have. A boon reuses events'
  own effect keys (`max_hp`/`heal`/`gold`/`relic`/`remove_card`/
  `sharpen_card`/`curse_card`) verbatim rather than inventing a second
  mini-mechanic — pulled `pick_event()`'s effect-application body out into a
  shared `Run._apply_effect_block()` so `pick_boon()` reads the exact same
  rule instead of a parallel copy (rule 7, and a real simplification: one
  fewer place a new effect key would need wiring twice). `Run.Phase.BOON`
  appended at the END of the enum (value 8) rather than inserted where it
  reads best, so no existing saved `phase` int changes meaning.
  **Deliberately NOT wired into `Run.start()`.** Chased the "done when: at
  run start" requirement into `game_3d.gd` before writing any Run code, since
  every real co-op game reaches `Run.start()` through
  `GameHost.start_new_run()`: its phase router (`SCENES` dict) has no 3D
  scene for `"boon"`, and its own doc comment is explicit that an unrecognised
  phase "holds the current screen and shouts, rather than swapping to
  something arbitrary mid-run" — i.e. flipping `start()` over to auto-offer a
  boon today would soft-lock every new run the instant it began, for every
  real player, not just ship an invisible feature. That's a materially
  different risk than #29b's gap (an unreachable sentinel nothing drafted
  yet) — this one is reachable by construction the moment `start()` calls it.
  So the engine landed as a standalone, fully-tested pair —
  `offer_run_start_boon()` (rolls 3-4 of the pool, opens `Phase.BOON`) and
  `pick_boon()` (applies the effect block, returns to `Phase.MAP`) — callable
  directly today (exactly how `_begin_shop()`/`_begin_campfire()`/
  `_begin_event()` are already called directly in tests, bypassing
  `pick_node()`), with the live trigger + `GameHost` command + a screen left
  as new item **31b** (`needs a screen`) rather than guessing blind at a
  scene nobody can render here. 6 new tests: boons.json well-formedness,
  offer-then-pick applying a synthetic effect block end-to-end, the
  outside-phase guard, save/load through the actual file (mirroring #15's
  per-phase shape — offer a boon, save, reload, confirm the offer is still
  live and pickable, not a frozen snapshot), and — the one that actually
  matters here — a dedicated regression test,
  `_test_start_does_not_auto_offer_a_boon`, pinning that `Run.start()` still
  leaves a fresh run on `Phase.MAP`, so a future edit can't silently flip the
  soft-lock risk back on without a test noticing. Extended #18's content
  integrity graph to check a boon's `curse_card` ref the same way it already
  checks an event's. `run_tests.gd` all green (223 assertions incl. the six
  new ones); `balance_sim.gd` ran clean as a smoke test only — its policies
  never call `offer_run_start_boon()` (nothing does yet, by design), so its
  printed win rates are unchanged, not tuned to.
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
