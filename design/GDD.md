# Titan-Slayers — Game Design Document

> **What this doc is.** The single answer to "what *is* this game." Every other
> file in `design/` is a slice — one decision, one system, one plan. This is the
> whole shape, and it is the one to read first and to keep current.
>
> **What it isn't.** Not the schedule (`ROADMAP.md`), not the numbers
> (`tuning-knobs.md`), not the how-to-build rules (`../CLAUDE.md`). §13 maps
> every other doc, including the ones that are now history.
>
> Status: **written 2026-08-06**, describing the build at commit `551f9e4`.
> Marked ⬜ where something is designed but not built.

---

## 1. High concept

**Two small creatures climb a giant beast and kill it together, one card at a
time.**

A co-op roguelike deckbuilder where the enemy is not an HP bar across the table —
it is a *place*. The beast stands in the middle of the world in 3D, and your two
hunters are physically on it, hauling each other up its flank toward the glowing
weak point. Cards are how you climb, how you hold on, and how you strike.

The Slay-the-Spire skeleton (deck, run, branching map, relics, ascension) carries
the replayability. Shadow of the Colossus supplies the fight itself. Co-op supplies
the reason both exist: **you cannot climb it alone.**

**Platform:** PC first, Steam. **Model:** premium, Early Access. **Players:** 1
(driving both hunters) or 2 online. **Engine:** Godot 4.7 / GDScript.

---

## 2. Design pillars

Every feature serves one of these, or it gets cut.

1. **Two hands, one mountain.** The fantasy is *cooperating* to fell something
   enormous. Systems must reward comboing, not two people playing solitaire
   beside each other.
2. **Climb → reveal → strike.** A positional puzzle up each beast, not a damage
   race. Where you *are* matters more than what you drew.
3. **Asymmetric creatures who need each other.** Characters sit on a "climbs well
   ↔ hits hard" axis. The climber hauls the striker up; the striker pays the climb
   off. Neither is complete.
4. **Readable depth.** Easy to see, hard to master. Single-pointer, no hover-only
   information (`CLAUDE.md` §5) — which also keeps a phone/Deck port possible.
5. **Charming but weighty.** Whimsical little creatures against huge, slow,
   deliberate beasts. The tonal contrast *is* the store-page hook in a genre with
   ~212 releases a year.

---

## 3. The player experience

**The fantasy:** you are small. The thing in front of you is not. You get up it by
being clever and by trusting the other player.

**A first run, felt from the outside:** you pick a creature — say the Frog, who
climbs beautifully and hits like a wet leaf. Your partner takes the Goblin
Engineer, who hits like a truck and cannot climb at all. You meet a Crag Pup, a
small beast you can hit from the ground, and the game teaches you one rule at a
time as each first becomes relevant. Then the map opens and you choose a route.
Three fights later you are on the shoulder of a Gale Serpent, your grip bar is
draining in real time, the Goblin is stuck at the base shouting for a rope, and
you have one card that can reach him.

**The emotional beat we're chasing** is the moment the two of you realize the
answer is a combination neither of you could have played alone.

**Session shape:** a run is ~40–60 minutes across 4 acts. A fight is 4–6 rounds.

---

## 4. The core loop

Three nested loops. Each one is a reason to keep going.

**Moment to moment (seconds)** — play a card, watch a timing bar sweep, tap to
land it, climb a rung, feel the grip timer start draining.

**The fight (minutes)** — *climb → reveal → strike → get bucked off → climb again.*
Below the weak point the hide is armored and your hits barely chip it. At the weak
point they land in full. So the fight is a repeated ascent, and the beast is
constantly trying to shake you off.

**The run (an hour)** — walk the overworld to a landmark, take the fight or the
event or the campfire, take the reward, build the deck, meet the act's Titan.
Four acts. Then the ascension ladder asks you to do it again, harder.

---

## 5. Combat

### 5.1 Turn structure

Both hunters act simultaneously in the player phase; the beast acts once **both**
have ended their turn. Per hunter per turn: **5 cards** in hand, **3 energy**.
Unspent energy does not carry.

The beast telegraphs its next move — *which* move and *which hunter* it targets —
before you commit. Reacting to that telegraph is most of the tactical layer.

### 5.2 Height — the climb

Every hunter has a **Height** (0–8), their own, tracked separately. This is the
system everything else hangs off.

- **Armored below the weak point.** Attacks deal **¼ damage** (`ARMORED_DIVISOR 4`)
  anywhere below the beast's sigil. Expose stacks you apply *bank* rather than
  being spent.
- **Full damage at the sigil.** A strike at the weak point deals full damage,
  **+5** sigil bonus, **+4** per banked Expose stack consumed.
- **So damage is cheap at the bottom and enormous at the top.** Climbing is the
  setup; the strike is the payoff.
- **Per-hunter Height is what makes co-op real.** The Goblin genuinely cannot get
  up there. Someone has to lift him.

### 5.3 The grip timer — real time inside a turn-based game

The one real-time system, and deliberate. The instant a hunter leaves a safe hold
a bar starts full and **drains live** (`GRIP_SECONDS 5.0`). Reach the next ledge
or the sigil before it empties, or **fall** to the base and take 3 damage — which
can kill.

Safe holds are the ground (0), any **ledge** the beast has, and the sigil.
Everything between is a race. Fewer ledges and a higher sigil make a longer, more
dangerous climb, which is the main per-beast difficulty lever.

**Confirmed by Nick, 2026-08-06:** in co-op *both* clocks run at once, and that
stays. It needs tuning, not redesign.

### 5.4 Timed cards — "double timing"

Some cards run a **timing sweep on the card face**: a marker crosses a green zone
and you tap. **Hit** grants the card's bonus (`timed_damage` / `timed_grip`);
**miss** and the card *slips away with no effect at all* — not even discarded.
Satchel Charge chains three sweeps and needs all three.

Playing a timed *climb* card while the grip bar is already draining gives two live
clocks at once. **This is the signature feel of the game and the thing to lean
into** when adding content.

### 5.5 The buck-off threshold

Once a hunter has dealt a beast's `weak_point_threshold` in one visit to the
sigil, it throws them down a hold. Burst is capped per visit — you cannot camp the
weak point and win. This is what turns the fight into a *loop* rather than a climb
followed by a beatdown.

### 5.6 Statuses

| Status | On | Effect |
|---|---|---|
| **Expose** (vulnerable) | beast | each consumed stack adds +4 to a hit; banks while you're armored |
| **Wound** | beast | bleeds this much at the start of each of its turns |
| **Strength** | hunter | adds to all your attacks for the rest of the fight |
| **Block** | hunter | absorbs the next hit |
| **Taunt** | hunter | you become the beast's target this round (tank for your ally) |
| **Rhythm** | hunter | +1 per timed card landed this turn, resets each turn (Frog's engine) |

### 5.7 Beast moves

`attack` (the telegraphed hunter) · `attack_all` (sweeps both **and** shakes each
down one hold) · `block` · `enrage` (permanent +strength — a soft timer) · `regen`
· `leech` (heals itself for what it hits you for) · `swipe_high` / `swipe_low`
(only hits hunters off / on the ground) · `rift` (damage scales with the Height
*gap* between hunters — climb together) · `shift_sigil` (moves the weak point
mid-fight).

---

## 6. Characters

Four creatures, placed on the **"climbs well ↔ hits hard"** axis so that any pair
has a gap the other fills.

| Creature | Passive | Identity |
|---|---|---|
| **The Frog** | `climb_bonus` +1 | Nimble. Fast to the weak point, hits soft. Engine: **Rhythm** — chain timed cards within a turn and they scale each other. |
| **The Vine-Weaver** | `poison_lift` +1 | Every Wound applied *lifts the ally*. Engine: **Poison** — strikes scale with the beast's Wound stacks. Climbs by helping. |
| **The Mountain Climbers** | `ally_climb` +1 | Roped together — when you climb, so does your ally. Engine: **Coordination** — damage scales with *both* Heights. |
| **The Goblin Engineer** | `attack_bonus` +2 | The heavy. Wrecks the weak point, climbs terribly. Engine: **Gadgets** — `create`s cards mid-fight (grapples, jetpack, satchel charges), sacrifices cards to cheapen or fuse others. Needs a carry. |

Each has a 10-card starter deck and its **own reward pool**, so drafting builds
*toward* the archetype instead of drawing from one shared bag.

⬜ The roster still wants a dedicated **protector**. 6–8 characters at 1.0.

---

## 7. Cards

**56 cards today**, all data (`data/cards.json`), 31 of them draftable.

A card is a bag of fields — any combination is legal, unset defaults to 0. The
full vocabulary and the how-to-add-a-card template live in
[`cards-and-classes.md`](cards-and-classes.md); the levers in brief:

- **Damage/defence:** `damage`, `block`, `ally_block`, `hits`, `strength`
- **Climb:** `grip`, `ally_grip`, `pull_ally`, `damage_per_foothold`
- **Co-op:** `ally_energy`, `taunt`, `vulnerable` (set up focus fire)
- **Timing:** `timed`, `timed_grip`, `timed_damage`, `timed_hits`
- **Scaling:** `damage_per_vulnerable` / `_wound` / `_rhythm` / `_ally_foothold`
- **Engineer verbs:** `create`, `prepare`, `meld`, `exhaust_pick`, `cheapen_pick`,
  `block_per_play`

**Upgrades** are one generic rule (`Card.upgraded_copy`): +3 to damage-ish stats,
+1 to scaling stats, else cost −1, and the name gains a `+`. New cards get an
upgrade for free, without anyone writing one.

**Deck transformation** happens at campfires: **Rest** (heal 9), **Thin** (remove a
card, floor of 5), **Sharpen** (upgrade one). Rewards can also be **skipped** — a
thin deck is a real strategy.

---

## 8. The run

### 8.1 Structure

**4 acts.** Each act is 3 rows of branching map nodes, then that act's Titan.
The map is seeded, always connected, and generated per run
(`core/run_map.gd`). Routing is a **shared** decision — either hunter can pick.

Node types: **fight** (a lesser beast, pays a card) · **elite** (pays a relic) ·
**rest** (campfire) · **treasure** (a relic outright) · **event** · **shop** ·
**boss** (the act Titan, pays a relic).

In 3D the map *is* a hex island you walk across: you click a landmark, your hunter
physically walks there, and arriving is what commits the choice. You can **look
around the region before committing** — drag to orbit, wheel to zoom — because
routing is the run's biggest decision and you should be able to study it. One
pointer does both jobs: a tap picks, a drag looks, told apart by how far the
pointer moved rather than by which button.

### 8.2 Beasts

**14 today**, in three pools:

- **Titans (act bosses):** Stone Warden (68 HP, sigil 2) → Gale Serpent (148,
  sigil 5) → Drowned Colossus (220, sigil 7) → Sunken Warden (300, sigil 8). The
  climb gets longer as the run goes on; the last one uses the full ladder.
- **Fights:** Crag Pup, Bramble Hog, Bounder, Root Lurker, Sky Snapper, Riftling.
- **Elites:** Mire Snapper, Frost Sentinel, Grove Bear, Shifting Idol.

Every beast has its own 3D body — variety on the map is pointless if fourteen
fights look like the same elephant.

### 8.3 Relics

**26**, team-wide and permanent for the run. The good ones **change a rule**
rather than nudge a number, and they hook *this* game's systems: start already
climbing, survive one fall, resist shakes, keep Rhythm between turns, widen the
timing zone, extend the grip timer, raise the buck threshold, cut the armored
penalty.

### 8.4 Economy, events, difficulty

- **Gold** is a shared purse (25/55/80 per fight/elite/boss). Shops sell cards
  from your own pool, team relics, and card removal at a price that climbs each
  time you use it.
- **10 events** — text choices with real stakes, printed on the button before you
  commit. Events *bruise but never kill*: HP floors at 1.
- **Ascension: 8 cumulative tiers** — more beast HP, beasts starting with
  Strength, less healing between fights, fewer reward choices, less starting HP.
  Clearing a tier unlocks the next.

### 8.5 Onboarding

A contextual **coach**: each rule is taught the first moment it actually matters,
once, and then never again (persisted between runs via `core/progress.gd`).
No wall of text, no separate tutorial mode to maintain.

Hints are **one line, and they dismiss themselves** (`COACH_SECONDS`, 7s) — acting
also dismisses them, because a player who is already playing doesn't need to be
told to play. They sit along the bottom, never over the beast. A tip you have to
click away is a chore, and a tutorial that nags is worse than none.

### 8.6 Knowing who you are

Solo drives both hunters and lets you switch mid-turn, so **which hunter am I** has
to be answerable without reading. Each slot owns a colour, used in exactly three
places that must always agree: the pip floating over that hunter's model in the
scene, the frame around the **portrait** at the top of the card rail, and their
party card. The Switch button wears the face of the hunter you'd swap to. Stats
are symbols — ✦ energy, ♥ health, ↑ Height. The name used to be spelled out in
text at the top and simply didn't register mid-fight.

---

## 9. Presentation

**The game is 3D** (pivoted 2026-08-05). The whole run is 3D end to end — combat,
overworld, and every between-fights screen. There is no 2D client any more.

- **Combat** — the beast stands in a real space; hunters are *on its body*, at the
  Height they've climbed. Free **orbit camera**: drag to swing around it, wheel to
  zoom, with markers so you never lose a hunter behind a leg. The weak point
  glows. Everything that moves is procedural — breathing, idle sway, climb hops,
  recoil, flash, dust, camera shake — so it reads as alive at no animation cost.
- **The beasts are colossal, and the camera refuses to contain them** (Nick,
  2026-08-06). A Titan stands ~17 hunters tall. Crucially the camera frames a
  fixed *window* of world rather than fitting the body, so how much of a beast
  overflows the screen IS how big it is — fitting the whole creature in frame is
  what made them read as pets, and no amount of scaling fixes that on its own.
  From the ground you look up at a wall of animal whose weak point is over the
  horizon of the frame; as you climb, the camera rides up the body with you, so
  the ascent is something you watch rather than a number changing.
- **The fight's screen is the scene** (Nick, 2026-08-06), framed like a Pokémon
  battle. The hand is a **rail down the left edge** — short wide cards instead of
  a row of portraits — because a portrait row ate the bottom third of the screen,
  which is exactly where the beast you're climbing stands. Everything else holds a
  corner: the beast's health across the top, your party and the turn buttons
  bottom-right, the log top-right, the grip bar across the top when it matters.
  The camera trucks sideways (`SCENE_SHIFT`) so the beast centres in the space it
  actually has rather than on the screen. Nothing overlaps the middle.
- **Between fights** — one scene (`location_3d`) stages every non-combat phase,
  because they are all the same shape: your hunters standing somewhere, being
  offered a choice. Character select puts the whole roster on the plot at the size
  they'll actually be.
- **Art direction** — Kenney low-poly placeholders today, sized to a *measured*
  target height so a model built at any scale drops straight in. **Nick is
  learning Blender**; the model contract and pipeline are in
  [`blender-pipeline.md`](blender-pipeline.md). The Steam capsule is marketing,
  not game art — worth commissioning regardless.
- **Audio** — Kenney .ogg over a hand-built in-code synth fallback
  (`tools/gen_sfx.gd`), so every event always has *a* sound. Drop a file in
  `game/audio/<event>.ogg` to override anything.

---

## 10. Multiplayer

**Authoritative host.** One `GameHost` owns the only `Combat` and broadcasts
per-peer snapshots, split into a **shared board** and a **private hand**. Clients
render dictionaries and send commands; they never own state. Listen-server model —
the host plays too.

**Solo** is the same machinery: one player drives both hunters, commands carry an
explicit slot, and the snapshot ships both hands. Every co-op dependency survives
intact, which is the point — solo is not a lesser mode, it's the same puzzle with
both hands on it.

Real-time skill (grip timers, card timing sweeps) is deliberately **client-side**.
The host is told the *outcome*, never the ticking clock, so `/core` stays
deterministic and testable.

⬜ Only localhost and two-process tests so far. **Cross-machine play is untested**
and is a real risk (see `ROADMAP.md` §6). Seamless reconnect is unbuilt; a drop
currently pauses the run.

---

## 11. Technical architecture

The one rule that has paid for itself repeatedly (`CLAUDE.md` §2):

> **`/core` must not depend on `/views`, `/input`, or `/net`.**

`/core` — deterministic rules: `Combat`, `Run`, `RunMap`, `Card`, `Boss`,
`PlayerState`, `Content`. No engine nodes, no rendering.
`/session` — `GameHost` (authority) and `GameClient` (the view's proxy).
`/net` — a `Transport` interface with local-loopback and ENet implementations,
drop-in interchangeable.
`/views` — clients. Disposable by design.

**This is why the 3D pivot was cheap:** the entire game became 3D and `/core` and
`/session` were *not touched*. Only `/views` changed.

**Content is data.** Cards, characters, beasts, relics, events and ascension tiers
are JSON. Adding content with existing fields is a data edit. A genuinely new
mechanic is a new field on `card.gd`, wired in `combat.gd`, plus a test.

**Tooling:**
- `tools/run_tests.gd` — 115 headless unit tests. Exit 0 = green.
- `tools/balance_sim.gd` — plays 300 full runs per policy through the real
  `/core`, modelling human timing and falls. Measures *balance*, never *fun*.
- `tools/screenshot.gd` — boots the game windowed into a named state, saves a PNG,
  and asserts behaviour. **All visual work is verified this way — never shipped
  blind.**
- `tools/net_smoke.gd` — two real processes over ENet.

---

## 12. Scope and status

**Built:** the whole loop. 4 characters, 56 cards, 14 beasts, 26 relics, 10
events, 8 ascension tiers, branching map, campfires, shops, gold, onboarding,
solo + online co-op, and a 3D client for every phase.

**Balance today** (simulated, `balance-notes.md`): naive 7% / coordinated 74% —
a +67 gap, which says coordination decides the run, which is pillar 1 holding.
**Not confirmed by a human**, and per standing direction we are building content,
not tuning numbers.

**Where we are on the ladder:** M1, the vertical slice — the build a stranger can
finish unaided. The remaining M1 gap is the **first real art pass**.

**Deliberately not built yet:**
- ⬜ **The traversal layer.** The card combat is *one component*. The intent is an
  interactive Shadow-of-the-Colossus-style exploration layer between fights, in
  place of menus. This is why we go deep on classes and cards rather than sprawling
  the beast roster — and it is not yet folded into the roadmap's milestones.
- ⬜ Co-op traversal, seamless reconnect, a protector character, biome 2.

**The scope discipline** (`ROADMAP.md` §0): the vision is allowed to sprawl, the
*first release* is not. Nothing new enters the Early Access box once locked; new
ideas go on the post-launch list.

---

## 13. The rest of `design/` — what to read, what is history

| Doc | Authoritative on | Status |
|---|---|---|
| **GDD.md** (this) | what the game is | current |
| `ROADMAP.md` | milestones, EA scope, marketing, risks, who-does-what | current |
| `tuning-knobs.md` | every number and exactly where it lives | current |
| `cards-and-classes.md` | the card field vocabulary, class kits, how to add a card | current |
| `balance-notes.md` | measured win rates and what "balanced" means here | current |
| `blender-pipeline.md` | the model contract and art pipeline | current |
| `depth-plan.md` | the decision-density diagnosis and the six fixes | complete, kept for the reasoning |
| `3d-pivot.md` | how the 3D client was built, and its gotchas | current |
| `titan-design.md` | the original somber SotC framing | **superseded** by the whimsical-creature direction |
| `climbing-and-characters.md` | the pre-3D climb/character pivot | **historical** — outcome is in §5–6 above |
| `OVERHAUL-PLAN.md` | the Kenney asset overhaul phases | **complete** |
| `audio-guide.md` | how to override a sound | current, narrow |

---

## 14. Open questions

**Nick's calls, unanswered:**
- **Monetization** — premium assumed, never confirmed. Price point unset.
- **Does the difficulty *feel* fair?** The sim cannot answer this.
- Real-human playtesting with someone who has never seen it.

**Answered and closed** (kept so they don't get relitigated): engine = Godot ·
authoritative host · online co-op · Early Access · orbit camera · real-time grip,
both clocks live in co-op · learn Blender rather than commission now · 2D client
deleted.
