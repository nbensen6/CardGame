# Slay the Spire 2 — comparison & what to take

**Written 2026-08-15.** Research snapshot; StS2 is in Early Access and changing fast,
so re-check anything load-bearing before building on it.

---

## 0. The headline you need first

**Slay the Spire 2 shipped co-op for up to four players.** It also migrated to
**Godot**, added two new classes, and sold **3 million+ copies in its first week** of
Early Access (launched 2026-03-05) — 177,000 concurrent players on day one, past
400,000 the next, breaking the roguelike concurrent record previously held by Hades 2.

That matters more than any mechanic on this page: **"co-op deckbuilder" is no longer
an empty niche you're walking into — the genre's defining title now occupies it.**
The market pitch in `CLAUDE.md` §10 ("the best co-op-vs-boss deckbuilders are almost
all PC/Steam — nobody owns this") needs updating. Mega Crit owns it now, by default,
on name recognition alone.

This is not fatal, but it changes what the pitch has to be. See §2.

Also worth noting, because it's quietly reassuring: **StS2 runs on Godot.** The engine
choice in §4.1 is validated at the highest possible level — a $92M deckbuilder ships
on the same engine you're using.

---

## 1. What StS2 actually added

| System | What it does |
|---|---|
| **Card Enchantments** | Modifiers applied to individual cards — Sharp, Swift, Slither, etc. Buff damage, change cost, randomize cost. A customization layer *on top of* upgrades. |
| **Campfire relic upgrades** | Campfires can now permanently empower a **relic**, not just a card. |
| **Boss limiters** | Boss mechanics explicitly designed to punish infinite loops and force adaptation. |
| **Deeper exhaust interactions** | Many more ways to interact with the exhaust pile; dual-type cards scale off what's currently exhausted. |
| **The Necrobinder** | New class built on *graveyard manipulation* — your discard pile is a resource you spend to summon and trigger. |
| **The Regent** | New class with a unique personal resource powering his cards. |
| **Co-op, up to 4** | The big one. |
| **Nerfed boss relics** | The originals smoothed the difficulty curve too much; they were pulled back. |

**Stated design philosophy:** stop players hitting autopilot. Reduce reliance on narrow
"optimal" builds. Keep new combinations appearing dozens of hours in. Reviewers agree
it works — *"instantly familiar, but already bursting with new ideas… hasn't reinvented
the wheel, but made it spin better."* One reviewer specifically notes StS2 has a
**better offense/defense balance, with defense more critical** than in StS1.

### 1.1 Deck and pool sizes, measured

Our numbers below are from the Card Lab (`node tools/cardlab/build.js`), 2026-08-15.

| | StS1 | **StS2** | **Us** |
|---|---|---|---|
| Playable characters | 4 | 5 | 4 |
| **Starting deck** | 10 | **10–12** | **10** |
| **Total cards in game** | ~350 | **569** | **65** |
| Draftable pool per character | ~75 | ~100 (569 ÷ 5, less shared colorless) | **21–24** |
| …of which are *signature* to that class | most | most | **5–10** |

**StS2 starter decks, exact:**

| Character | Size | Composition |
|---|---|---|
| Ironclad | 10 | 5 Strike, 4 Defend, **1 Bash** |
| Silent | 12 | 5 Strike, 5 Defend, **1 Neutralize, 1 Survivor** |
| Defect | 12 | 4 Strike, 4 Defend, **1 Zap, 1 Dualcast** |
| Regent | 12 | 4 Strike, 4 Defend, **1 Falling Star, 1 Venerate** |
| Necrobinder | 12 | 4 Strike, 4 Defend, **1 Bodyguard, 1 Unleash** |

**Ours, exact:**

| Class | Starter | Signature in starter | Pool | Signature in pool |
|---|---|---|---|---|
| The Frog | 10 | 8 | 21 | 5 |
| The Vine-Weaver | 10 | 8 | 21 | 6 |
| The Mountain Climbers | 10 | 8 | 22 | 6 |
| The Goblin Engineer | 10 | 10 | 24 | 10 |

#### Three things fall out of this

**1. Our starting deck size is right.** 10 matches StS1 exactly, and sits at the low end
of StS2's 10–12. No reason to change it. Note StS2 moved *most* characters up to 12 by
adding a **second** signature starter — a small nudge toward earlier class identity.

**2. Our starters are far more distinctive than theirs — deliberately or not.** An
Ironclad opens with 9 generic cards and 1 signature. Our Frog opens with 8 signature
cards out of 10, and the Goblin's entire starting deck is his own kit.

This is a real design fork, not a mistake, and it has a cost worth naming. StS's arc —
*"5 Strikes and 4 Defends" → a finished machine* — **is** a large part of the
satisfaction. Deck **transformation** is the payoff; you start as nobody and become
something. We start you already being somebody. That gives instant class feel and
immediate co-op interdependence (which we need, because the Goblin must be carried from
turn one), but it flattens the transformation arc. Given our runs are shorter and our
hook is execution rather than build-crafting, this is probably the right trade — but it
means our reward screens have to do more work, because they're not the thing that
*creates* your identity, only refines it.

**3. The pool size is the real content warning.** 21–24 draftable cards per class, of
which only 5–10 are ours-alone, against StS2's ~100. Two consequences:

- **Run-to-run variety is thin.** With a pool that small, you see most of it every run,
  and drafting converges on the same handful of picks. This is the number that most
  limits "one more run."
- **The gap is bigger than 65 vs 569 suggests**, because a big share of every pool is the
  same shared neutrals — the Card Lab reports only 24–42% signature.

The realistic target is not 569. It's **roughly 40 draftable cards per class with 25+
signature** — enough that two runs of the same class diverge. That's ~60–80 new cards,
which is a lot, and it's why §3.1 (enchantments) matters: enchantments multiply the
pool you already have instead of demanding you author a hundred more.

---

## 2. Where we are genuinely different

Being honest about which of these are real moats and which are just differences.

| Axis | StS2 | Us | Real moat? |
|---|---|---|---|
| **Real-time execution** | None. Pure turn-based. | Grip timer (5s live drain) + timed cards (2.5s window) — the "double timing" | **Yes.** This is the sharpest difference. StS has never had an execution layer, and its audience's entire skill expression is decision-making, not timing. |
| **Vertical space** | Flat. You fight a row of enemies. | Height is a per-hunter resource; the beast IS the board; armored below the sigil, full damage at it | **Yes.** Climbing-as-setup is structurally different from any StS combat. |
| **Interdependence** | Co-op, but almost certainly parallel play — four decks against shared enemies. *(Unverified — worth playing to confirm.)* | The Goblin is literally stuck at Height 0 without a partner hauling him up | **Probably.** Verify by playing StS2 co-op. If its co-op is side-by-side, this is our strongest claim. |
| **Failure that isn't HP** | Lose by dying. | Lose your grip and **fall** — a physical failure state with its own tension | **Yes.** |
| **Co-op at all** | 4 players | 2 players | **No longer.** Was our headline; now table stakes. |
| **Content depth** | Enormous, 8 years of iteration | 65 cards, 4 classes, 4 titans | **No.** Never compete here. |

**The revised pitch:** not "a co-op deckbuilder" — that's now Mega Crit's. It's
**"the deckbuilder where you're climbing the boss and can fall off it, and your partner
is the only reason you can reach the top."** Real-time + vertical + genuine
interdependence. Any two of those alone is a variant; all three is a different game.

---

## 3. What to take — ranked by value per unit of work

### 3.1 Card Enchantments → **build this** ⭐ highest value

StS2's enchantment layer is the single most stealable idea, and our architecture is
already shaped for it. `Card.upgraded_copy()` is *one generic rule* that bumps whatever
numbers a card uses — an enchantment is that same trick with a named modifier.

Sketch, fitting our existing pattern:

```gdscript
# core/card.gd
var enchant: String    # "sharp" | "swift" | "roped" | ...

# data/enchants.json — data, per CLAUDE.md §11
{ "sharp":  { "name": "Sharp",  "damage": 3, "text": "+3 damage" },
  "swift":  { "name": "Swift",  "cost": -1,  "text": "Costs 1 less" },
  "roped":  { "name": "Roped",  "ally_grip": 1, "text": "Also lifts your ally +1" },
  "sure":   { "name": "Sure",   "timing_zone": 0.25, "text": "Wider timing window" } }
```

Two reasons this is worth more to us than to StS2:

1. **`sure` (a wider timing window) is an enchantment only our game can have.** It turns
   our real-time layer into a build decision — do I make this card hit harder, or make it
   easier to *land*? That's a genuinely novel axis and it's ours alone.
2. It multiplies existing content instead of requiring new content. 65 cards × a handful
   of enchants is far more variety per hour of work than 20 more cards.

Where they'd come from: campfires (a third option beside Thin/Sharpen), shops, events,
and rare rewards.

### 3.2 Campfire relic upgrades → **build this**, it's nearly free

We already have campfires (Rest / Thin / Sharpen) and 26 relics with a `Run.relic_totals()`
sum. Adding "empower a relic" is a fourth campfire option and a `+value` on one relic id.
Small work, real decision density, and it makes relics feel owned rather than collected.

### 3.3 Exhaust as a resource → **strong fit, underused today**

We have `PlayerState.exhaust_pile`, but the only thing that writes to it is `exhaust_pick`
(Burn Coal, Catapult). StS2 built whole cards that scale off the exhaust pile.

For us the obvious version is **the Goblin Engineer**: he already sacrifices cards for
value, so `damage_per_exhausted` / `block_per_exhausted` turns his sacrifice identity into
a scaling engine rather than a one-shot cost. It's one new field and one line in
`play_card` — the cheapest depth on this list.

### 3.4 Boss limiters → **we already have this instinct; extend it**

Our `weak_point_threshold` (deal N at the sigil and the beast bucks you off) *is* a boss
limiter — it caps burst per visit and forces the climb→strike→fall→climb loop. StS2
arrived at the same idea from the opposite direction.

The extension worth stealing: **per-beast limiters that punish a specific strategy**, so
each titan asks a different question. One that sheds Poison each turn. One that punishes
staying at the sigil. One that gets harder the more Height a single hunter has, forcing
you to split. This is the cheapest way to make four titans feel like more than four HP bars.

### 3.5 A resource-driven class → **later, but note the direction**

Both new StS2 classes are built on an unusual *resource* (the Regent's personal resource,
the Necrobinder's discard pile) rather than an unusual card type. Our four classes are
built on mechanics — Rhythm, Poison, coordination, gadgets. Rhythm is the closest to a
resource and it's the most distinctive of the four. Worth remembering if a fifth class ever
gets designed: **build it on a resource, not a keyword.**

---

## 4. What NOT to copy — the expensive lessons

### 4.1 Do not reduce energy

StS2 reduced energy availability. Player reaction: gameplay became **"tedious
optimization."** The complaint is that lower energy didn't create interesting decisions,
it created *fiddly* ones, and pushed players toward engine/infinite builds as the only
way to escape the pressure.

**Direct relevance:** we just spread the cost curve (66% → 54% at cost 1, a new 3-cost
tier). That was the right structural move, but it means our effective energy just got
tighter. **Do not also lower the 3-energy budget.** If playtesting says turns feel
cramped, the fix is more 0-cost cards or energy generation, not fewer expensive ones.

### 4.2 Do not balance-patch a live audience without a pressure valve

StS2 took **~21,000 negative reviews in five days** in April, and an earlier patch drew
~13,000 more, dropping the game to "Mostly Negative" — during a *beta branch* patch that
was explicitly meant to gather feedback. Mega Crit was caught off guard.

Lessons for our Early Access, which `design/ROADMAP.md` commits to:
- Balance changes to a live game are a **communications** problem at least as much as a
  design one. Ship them with the reasoning, not just the numbers.
- An opt-in beta branch is not automatically safe — StS2's was the thing that got bombed.
- The deckbuilder audience is expert and invested. They will notice, and they will not be
  gentle. This is an argument for getting the fundamentals right *before* EA, not for
  patching your way there in public.

### 4.3 Do not assume returning players want familiarity

Casey Yano's original direction was Dark Souls-inspired: keep much of the card pool
consistent so players could rebuild favourite builds across games, with the *encounters*
providing the novelty. Playtesters **rejected it outright** — *"We need new stuff!"*

Not directly applicable (we have no first game), but it validates a call we've already
made: **per-class reward pools that make each run feel different are worth the work.**
The instinct behind them is the same one that overruled Yano.

### 4.4 Watch the reward-quality trap

Players complained that in StS2 **most rare cards are trash and elite fights aren't
rewarding**. Our current equivalent risk: the Card Lab reports class pools are only
24–42% signature cards, and elites pay relics from a shared pool. If a hard fight pays
out something you didn't want, the difficulty reads as unfair rather than earned.

---

## 5. Recommended order

1. **Verify StS2 co-op firsthand.** Is it interdependent or parallel? Our entire
   differentiation claim in §2 rests on the answer, and it's a couple of hours of play.
2. **Exhaust scaling for the Goblin** — one field, one line, immediate depth.
3. **Campfire relic upgrades** — small, uses everything we already have.
4. **Card enchantments** — the big one. Includes `sure` (wider timing window), which
   is a mechanic only this game can offer.
5. **Per-beast limiters** — makes four titans feel like four puzzles.
6. Update `CLAUDE.md` §10 and `design/GDD.md` — the "nobody owns co-op deckbuilders"
   market claim is now false and shouldn't keep steering decisions.

---

## Sources

- StS2 new mechanics — https://www.dualshockers.com/slay-the-spire-2-changes-that-completely-redefine-how-deckbuilding-roguelikes-work/
- Mechanics, co-op & classes — https://games.gg/slay-the-spire-2/guides/slay-the-spire-2-new-mechanicsmode-classes-explained/
- Early access review — https://www.gamesradar.com/slay-the-spire-2-review/
- Review bombing — https://www.gamespot.com/articles/slay-the-spire-2-is-fantastic-so-why-is-it-being-review-bombed/1100-6539724/
- Balance criticism — https://yorchtorchgames.substack.com/p/the-2-mistakes-that-could-derail
- Yano on the card pool — https://www.pcgamer.com/games/roguelike/slay-the-spire-2-dev-says-an-early-idea-was-to-actually-reduce-the-card-pool-but-players-hated-it-we-need-new-stuff/
- Starter decks & card system (wiki) — https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Cards
- Full card list, 569 cards — https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Cards_List
- Sales & concurrents — https://en.wikipedia.org/wiki/Slay_the_Spire_II
- Dark Souls influence — https://www.gamesradar.com/games/roguelike/slay-the-spire-2-almost-had-fewer-new-cards-because-of-the-co-creators-love-for-dark-souls-but-testers-were-not-jiving-with-that-at-all/
