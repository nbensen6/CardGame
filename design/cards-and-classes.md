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
| `create` | A card id this card **builds** and adds to your hand (Engineer gadgets) |
| `damage_per_vulnerable` | +damage per Expose stack on the Titan |
| `damage_per_foothold` | +damage per Height **you've** climbed |
| `strength` | **Strength** for you — adds to all your attacks for the rest of the fight |
| `wound` | **Wound** on the Titan — it bleeds this much at the start of each of its turns |
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

**Nathan's redesign — status**
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

**Vine-Weaver** — vines lift the ally, poison the beast *(passive: none)*
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
