# Cards & Classes — design reference

> The card combat is **one component** of the larger game (an interactive,
> SotC-style traversal / downtime layer comes later). So we go **deep on classes
> and cards**, and deliberately keep the Titan roster small. Design new cards by
> adding to `game/data/cards.json` and wiring them into a class deck in
> `game/data/characters.json`. Claude implements/tunes anything you spec here.

---

## 1. The card vocabulary (every lever you can pull)

A card is just a bag of fields (`game/core/card.gd`). Any combination is legal —
mix them freely. Unset fields default to 0/false.

| Field | Effect |
|---|---|
| `name` | Display name |
| `type` | `"attack"` or `"skill"` — **flavor/label only** right now, no mechanical effect |
| `cost` | Energy to play (you have 3/turn) |
| `damage` | Damage to the Titan |
| `block` | Block for **you** (absorbs the next hit) |
| `ally_block` | Block for your **ally** (co-op combo) |
| `ally_energy` | Energy given to your **ally** |
| `vulnerable` | **Expose** stacks on the Titan — each consumed hit deals **+4** |
| `taunt` | You become the Titan's target this round (tank for your ally) |
| `grip` | **Height** you climb (toward the weak point) |
| `ally_grip` | **Height** your ally climbs (vines/ropes — shared climbing) |
| `timed` | Runs the on-card timing bar. **Hit** → grants the timed bonuses; **miss** → the card *slips away with no effect* |
| `timed_grip` | Bonus Height on a well-timed climb |
| `timed_damage` | Bonus damage on a well-timed strike |
| `timed_block` | Bonus Block on a well-timed **brace**. Miss and the card slips away as usual — so a mistimed guard means eating the blow bare |
| `timed_ally_block` | Bonus Block for your **ally** on a well-timed anchor (roped defence) |
| `create` | A card id this card **builds** and adds to your hand (Engineer gadgets) |
| `damage_per_vulnerable` | +damage per Expose stack on the Titan |
| `damage_per_foothold` | +damage per Height **you've** climbed |
| `strength` | **Strength** for you — adds to all your attacks for the rest of the fight |
| `wound` | **Displayed to players as "Poison".** The Titan bleeds this much at the start of each of its turns. The field name is historical — every card face and combat log says Poison, so write new card text that way |
| `hits` | How many times the damage lands (multi-strike; default 1) |
| `draw` | Extra cards drawn |
| `target` | `"self"`/`"ally"`/`"enemy"` — **UI label only**, tells the player who it acts on |
| `text` | Rules text on the card face (write it for the player) |

### Key interactions to design around
- **The weak point (climb):** below the sigil the hide is **armored** — attacks
  deal only **¼ damage** and Expose stacks *bank* (aren't spent). At the sigil, a
  strike deals **full damage + 5 (sigil bonus) + 4 per Expose stack consumed**.
  → *Damage is cheap on the ground and huge at the top; climbing is the setup.*
- **Buck-off threshold:** once you've dealt a Titan's `weak_point_threshold`
  damage in one visit, it throws you down a hold. → *Burst damage is capped per
  visit; the loop is climb → strike a chunk → get thrown → climb again.*
- **Grip timer (real-time):** leaving a hold starts a live grip bar; reach the
  next ledge/sigil before it empties or you fall. → *Timed climb cards give the
  "double timing" (card bar + grip bar at once) — the feel we're leaning into.*
- **Multi-hit + Expose:** each of a `hits` card's strikes can consume an Expose
  stack — multi-hit + Expose is a combo.

### Signature scaling fields (added in the overhaul)
- `damage_per_rhythm` / `grip_per_rhythm` — scale with **Rhythm** (Frog: +1 per
  timed card landed this turn, resets each turn).
- `damage_per_wound` — scale with the Titan's **Poison** stacks (Vine-Weaver).
- `damage_per_ally_foothold` — scale with your **ally's Height** (Mountain Climbers).
- passive `poison_lift` — applying Wound climbs your ally (Vine-Weaver).

### Not yet available (ask Claude to add the field if you want it)
Cost-scaling, exhaust/one-shot cards, card-draw-on-hit, energy refund, self-damage,
conditional effects ("if at the weak point…"), block-scaling damage, AoE across
multiple Titans, status on self. These are all easy to add to `card.gd` — just say
what you want and it becomes a new field.

---

## 2. The Goblin Engineer (our focus)

**Fantasy:** the heavy hitter. Wrecks the weak point with huge blows, but **climbs
terribly** — he **builds gadgets** (grapples, and whatever we invent) to haul
himself up, and leans on a partner to carry him. Rewards big timed swings.
**Passive:** `attack_bonus` +2 (every attack he plays hits for +2).

**Current deck** (`characters.json` → `goblin_mech.starter_deck`, 10 cards) — mid-redesign:

| Card | Cost | What it does |
|---|---|---|
| **Goblin Jetpack** | 2 | Prime it; next turn rockets you to the weak point |
| Piston Punch ×2 | 2 | **Timed.** 8 (+8 nailed) — signature big swing *(→ Satchel, pending)* |
| **Grappling Arm** | 1 | Pull an ally up to your Height (if within 3) |
| Sharpen | 1 | +2 Strength *(→ Meld, pending)* |
| Rend | 1 | 4 damage + Wound 2 *(→ Burn Coal, pending)* |
| Build Grapple ×2 | 0 | Builds a **Grappling Hook** into your hand |
| **Build Mech** | 1 | 2 Block, +2 more per prior Build Mech this fight |
| Slash | 1 | Deal 6 *(→ Catapult, pending)* |
| *(built)* Grappling Hook | 0 | **Timed.** Climb +1 (+2 nailed) |

**the designer's redesign — status**
- ✅ **Goblin Jetpack** (was Cleave) — prepare→next-turn auto-climb to the sigil.
- ✅ **Grappling Arm** (was Flurry) — pull ally up to you if within 3 Height.
- ✅ **Build Mech** (was Brace) — Block scales each play.
- ✅ **Burn Coal** (was Rend) — sacrifice a card (exhaust) to permanently −1 another card's cost. Uses the new pick-a-card flow.
- ✅ **Catapult** (was Slash) — sacrifice a card to launch your ally +2 Height. *Note: the CASTER sacrifices (not the ally) — flag if you want the true ally-chooses version.*
- ✅ **Meld** (was Sharpen) — fuse two chosen cards into one: effects add up, cost = sum −1, and if either is timed the result is ONE timed card with both bonuses combined (one timing bar). Selection fields (create/prepare/exhaust) are dropped when melded.
- ✅ **Satchel Charge** (was Piston Punch) — a **chained-timing** card: nail 3 timing windows in a row to detonate for 26; miss any and it fizzles. The 3 windows are client-side (CardView `timed_hits`); core sees one hit/miss. A counter (1/3, 2/3) shows progress on the card.

**The Goblin Engineer is fully redesigned.** New deck: Goblin Jetpack · Satchel Charge ×2 · Grappling Arm · Meld · Burn Coal · Build Grapple ×2 · Build Mech · Catapult.

**His design space (levers that fit the fantasy):**
- **More `create` gadgets** — the engineer's identity. A card that *builds* a
  one-use tool into your hand: a bomb (big timed damage), a winch/spring (climb),
  a turret (repeat damage), a shield-drone (block). `create` is underused — this
  is his richest vein.
- **Timed heavy strikes** — Piston Punch is the template; variants that scale
  (with Strength, with Height, with Exposed).
- **Overcharge / risk** — big payoff with a cost (self-block loss, a downside next
  turn). We'd add a field for the downside.
- **Charge-up** — a card that buffs the *next* gadget/strike (we'd add a field).

*(These are prompts, not prescriptions — design what you like; the levers above
just fit the theme.)*

---

## 3. Full card catalog (everything that exists)

**Neutral / core**
| id | name | cost | effect |
|---|---|---|---|
| slash | Slash | 1 | 6 damage |
| dagger | Dagger | 0 | 3 damage |
| cleave | Cleave | 2 | 10 damage |
| brace | Brace | 1 | 5 Block (self) |
| take_aim | Take Aim | 1 | Draw 2 |
| cover | Cover | 1 | Ally +6 Block |
| rally | Rally | 1 | Ally +1 Energy |
| draw_aggro | Draw Aggro | 1 | Taunt + 6 Block |

**Expose / focus-fire**
| id | name | cost | effect |
|---|---|---|---|
| expose | Expose | 1 | Titan Exposed 2 |
| bowshot | Bowshot | 0 | 3 damage + Expose 1 |
| harpoon | Harpoon | 2 | 8 damage + Expose 1 |
| sunlight_blade | Sunlight Blade | 1 | 5 damage, +3 per Expose stack |

**Buff / damage-over-time / multi**
| id | name | cost | effect |
|---|---|---|---|
| sharpen | Sharpen | 1 | +2 Strength |
| rend | Rend | 1 | 4 damage + Wound 2 |
| spore | Spore Burst | 1 | 2 damage + Wound 2 |
| flurry | Flurry | 2 | 4 damage ×2 |

**Climb (neutral)**
| id | name | cost | effect |
|---|---|---|---|
| scramble | Scramble | 0 | Climb +1 |
| grip | Grip | 1 | Climb +2 |
| leap | Leap | 1 | Climb +3 |

**Frog** — nimble, fast climb, precise timed pokes *(passive: +1 Height per climb)*
| id | name | cost | effect |
|---|---|---|---|
| pounce | Pounce | 1 | **Timed.** 4 (+5) + climb +1 |
| flick | Tongue Flick | 0 | **Timed.** 2 (+3) |
| tongue_lash | Tongue Lash | 1 | 3 damage + climb +1 |

**Vine-Weaver** — vines lift the ally, poison the beast *(passive: `poison_lift` 1 — applying Poison climbs your ally)*
| id | name | cost | effect |
|---|---|---|---|
| vine | Vine | 1 | Climb +1, ally +2 |
| creeper | Creeper Vine | 0 | **Timed.** Climb +1 (+2), ally +1 |
| lash_out | Lash Out | 1 | **Timed.** 3 (+4) + Wound 2 + ally +1 |

**Mountain Climbers** — roped, height-scaling *(passive: ally climbs when you do)*
| id | name | cost | effect |
|---|---|---|---|
| rope_up | Rope Up | 1 | You + ally climb +1 |
| haul | Haul Up | 1 | **Timed.** Both +1 (you +2 nailed) |
| belay_strike | Belay Strike | 1 | 3 damage, +2 per Height |
| piton_drive | Piton Drive | 1 | **Timed.** 2, +2 per Height (+4 nailed) |

**Goblin Engineer** — see §2.
| id | name | cost | effect |
|---|---|---|---|
| piston_punch | Piston Punch | 2 | **Timed.** 8 (+8 nailed) |
| build_grapple | Build Grapple | 0 | Builds Grappling Hook |
| grapple | Grappling Hook | 0 | **Timed.** Climb +1 (+2 nailed) — built, not drawn |

---

### The 3-cost payoff tier (added 2026-08-15)

The catalog had **no cards at cost 3** and 66% of everything at cost 1, so with 3
energy a turn every turn played the same three cards and "what do I cut?" was never
a real question. Each class now has one expensive payoff worth building toward, plus
a neutral one. Cost-1 share is now 54%.

| id | class | cost | effect |
|---|---|---|---|
| grand_leap | Frog | 3 | **Timed.** 4 dmg (+4), climb +3 (+3), +2 Height per Rhythm |
| bloomburst | Vine-Weaver | 3 | 5 damage, +4 per Poison stack. Poison 2 |
| summit_push | Mountain Climbers | 3 | Both climb +2; 5 damage, +3 per ally's Height |
| overload_engine | Goblin Engineer | 3 | **Timed ×2.** 10 damage (+16 nailed) |
| last_stand | neutral | 3 | Both hunters +10 Block; Taunt |

Repriced 1 → 2 at the same time (they were buying too much Height for one energy):
`leap`, `overgrowth`, `leapfrog`, `pitons_in`, `anchor_line`.

### Timed defence (added 2026-08-15)

Nothing in the game made you *time a defensive play* — every timed card was an attack
or a climb. These close that gap, and they carry real stakes: a fumbled timed card
slips away with no effect, so mistiming a brace means taking the hit bare.

| id | class | cost | effect |
|---|---|---|---|
| dig_in | neutral | 1 | **Timed.** 4 Block (+6 nailed) |
| anchor_brace | Mountain Climbers | 1 | **Timed.** You +2 Block; ally +4 (+6 nailed) |
| deploy_bulwark | Goblin Engineer | 1 | Builds **Bulwark** into your hand |
| bulwark | *(built)* | 0 | **Timed.** 3 Block (+8 nailed) |

### Content batch — 40 signature cards (2026-08-15)

Ten per class. **The live catalog is now the Card Lab** (`node tools/cardlab/build.js`)
rather than a hand-maintained table — it reads the JSON directly, so it can't drift.

Where the batch landed, and why the target is what it is:

Two batches of 40 and 36 landed the target:

| | Session start | **Now** | Target |
|---|---|---|---|
| Cards in game | 56 | **142** | — |
| Draftable pool per class | 21–24 | **40–41** | ~40 ✅ |
| Signature cards per class | 5–10 | **25–26** | 25+ ✅ |
| Identity share | 21–42% | **61–65%** | >50% ✅ |
| Cost-1 share | 66% | **51%** | <50% |

**Where the ~40 target comes from.** A run visits 16 nodes (4 acts x 3 rows + a Titan
row). Row 0 of each act is always a fight and the run-up row never is, so only about
**5–6 nodes per run pay a card reward**, each offering `REWARD_CHOICES = 3`. That's
~16 cards seen per run. Against the old 21-card pool you saw ~78% of your class every
single run, which is why drafting converged. At 31 you now see ~52%; at 40 you'd see
~40%, which is where two runs of the same class start to diverge.

**That lever has now been pulled.** Elites and Titans previously paid a relic *instead of*
a card. Every beast now pays a card, and elites/Titans pay a relic on top (the card first,
the relic second — `Run._queued_reward`). Card rewards per run went from ~5.4 to **~10.7**,
which doubles the deckbuilding decisions in a run without authoring anything.

**And here is the honest consequence, which is worth understanding before writing 40 more
cards.** Doubling the rewards also doubles how much of your pool you see:

| | Session start | Now |
|---|---|---|
| Card rewards per run | ~5.4 | **~10.7** |
| Cards seen per run | ~16 | **~32** |
| Pool per class | 21 | **40** |
| **Share of pool seen** | ~76% | **~80%** |

Both numbers doubled, so **the ratio barely moved.** More cards and more rewards are each
good on their own — decision density is up, and class identity went from 21–42% to 61–65% —
but repetition-per-run is roughly where it started.

To actually move that ratio by content alone you'd need **65–80 cards per class**, which is
Slay the Spire territory (~75–100) and a very long grind. **The cheaper answer is card
rarity.** StS doesn't avoid repetition by making you never see a card twice; it weights
commons to appear often and rares to feel like treats. A `rarity` field on cards plus
weighted `_roll_choices()` would deliver more perceived variety than the next 40 cards,
and it is perhaps an hour of work. **Do that before writing more content.**

New fields this batch: `damage_per_exhausted` / `block_per_exhausted` — the Goblin's
sacrifices now compound instead of being a one-off cost. Both count the pile as it stood
**before** the played card's own sacrifice, so Detonator can't pay itself.

## 4. How to add a card (template)

1. Add an entry to `game/data/cards.json` under `"cards"`:
```json
"overload_fist": {
  "name": "Overload Fist", "type": "attack", "cost": 2,
  "damage": 6, "timed": true, "timed_damage": 10, "strength": 1,
  "target": "enemy",
  "text": "Time it! 6 (+10 nailed). Gain 1 Strength."
}
```
2. Put its id in a class deck (`characters.json` → `<class>.starter_deck`, keep it
   ~10 cards) and/or `cards.json` → `reward_pool` (offered between fights).
3. Tell Claude — it'll add any *new field* you invented to `card.gd`, wire the
   effect in `core/combat.gd`, add a test, and confirm it works. (Existing fields
   need no code — data only.)

Sketch ideas right here in this file and Claude will turn them into working cards.
