# Design proposal — "climb the colossus" feel + characters

> **Proposal v1 — Claude's independent take** (before the human shares theirs).
> A direction to react to, not final. Ties to systems we already have (Foothold,
> Expose, shake/attack_all, Strength/Wound). Cites: Shadow of the Colossus combat
> analysis; Across the Obelisk / Slay the Spire class design.

## The problem
Right now you deplete a single HP bar and can damage the Titan from the ground.
That reads as *fighting an enemy*. In Shadow of the Colossus you can barely scratch
the beast — you must **climb to a weak point** and strike it there, while the
colossus **shakes to throw you off** and your **grip** drains. The tension is the
ascent, not the trade of blows. We should move the combat's center of gravity from
"reduce HP" to "**scale the beast and reach the sigil.**"

## Part A — make it feel like climbing

Three altitudes; I recommend the middle one.

### A1. Reframe only (light)
Keep the systems; reflavor. HP bar → "the climb"; lean harder on Foothold; sigils
as the goal. Cheap, but the *feel* barely changes — you can still ground-pound.

### A2. Height-gated climb (RECOMMENDED)
Make the colossus a **structure with zones** you ascend: e.g. **Base → Flank →
Shoulders → Sigil**. The team shares a **Height** (our Foothold, renamed). The core
rule change that fixes the feel:
- **You can't meaningfully damage the colossus until you've climbed to its weak
  point.** Below the sigil, attacks chip "armored stone" (tiny/zero). At the sigil
  (Height ≥ the sigil's zone) *and* Exposed, your strikes land for real — this is
  the SotC "unharmable except at the weak point" rule.
- The colossus **shakes** (our attack_all) to knock the team **down a zone** and
  drain **Grip**; **Brace = cling on**. Run out of Grip on a shake → you **fall**
  (lose all Height + take damage). That's the grip-gauge tension, in cards.
- **Win = destroy the sigil(s)**, not "HP 0". HP becomes "the sigil's integrity"
  once reached; the bar only moves when you're actually up there striking it.

Each colossus gets a distinct **climb shape**: how many zones, where the sigil sits
(higher = longer climb), how often/hard it shakes. Variety comes from the *route*,
not just stat blocks — very SotC.

Cost: a real combat rework + a full balance re-tune (the sim makes that cheap). But
this is the change that makes the game *about* climbing.

### A3. Multi-sigil / phased body (deep, later)
Several weak points at different heights, destroyed in sequence; the colossus
changes behavior as you ascend (phases). The most faithful — each colossus a unique
climb-puzzle — but the largest build. A stretch goal after A2 proves out.

## Part B — characters

**Principle (from the research):** every hunter should **set up** or **pay off**,
so pairs combo; and each needs a **signature resource/passive** so they *feel*
distinct — not just a different deck. And decks become **asymmetric** (today both
hunters share one starter — that's the main thing to change). Roles map onto a
*climbing party*.

### Core roster (4)
1. **The Vanguard (climb leader / setup)**
   - Signature: generates **Height/Foothold** fast and is **hard to shake**
     (anchors the team's climb; her Grip also lifts the ally).
   - Deck: Grip, Brace, hold-on tools. The one who gets the team *up*.
   - Synergy: enables the Striker to reach the sigil.

2. **The Marksman (reveal / ranged setup)**
   - Signature: **Expose** specialist (the sunlight/arrow that reveals sigils);
     hits harder vs exposed; partly **immune to shakes** (fights from range).
   - Deck: Bowshot, Expose, focus-fire.
   - Synergy: reveals the weak point for everyone; safe when the beast bucks.

3. **The Blademaster (payoff)**
   - Signature: **Strength + multi-hit**; little setup of their own, but *huge*
     once the sigil is reached and Exposed. Builds Strength as they strike.
   - Deck: Slash, Cleave, Flurry, Sharpen.
   - Synergy: the finisher — needs the Vanguard (height) + Marksman (expose). Pure
     dependence = pure co-op.

4. **The Warden (anchor / protector)**
   - Signature: **Taunt + block + ally shielding** (Cover, Draw Aggro); high HP;
     "anchors" so shakes hit the team less.
   - Deck: Cover, Draw Aggro, Brace, big block.
   - Synergy: keeps the fragile Blademaster/Marksman alive through the shakes.

### Stretch (5th)
5. **The Lightbearer (enabler/support)** — a "Light" resource that reveals sigils
   and mends allies; Rally (energy). The glue for longer runs. Add once the core
   four feel good.

### Why this set
A 2-player game wants **complementary pairs**: Vanguard+Blademaster (climb→strike),
Warden+Marksman (protect→snipe), etc. Each pairing plays differently → replayability
and real §6 coordination. Distinctness comes from signature resources, not stat
tweaks.

## How it fits our architecture (for when we build)
- Data-driven: a `data/characters.json` — per class: name, starter deck (ids),
  signature passive (effect + value), flavor.
- `PlayerState` gains a `character` + passive state (like relics have effects).
  Passives need a few `Combat` hooks (start-of-fight, on-attack, on-climb) — same
  pattern as relic modifiers.
- `GameHost` assigns each peer their chosen character; the **menu/lobby** gets a
  character-select step. Snapshot carries character name + signature state.
- The climb rework (A2) touches `Combat` (Height gating, fall/grip) + `Boss`
  (zones/sigil position) + `data/bosses.json` + the view (a climb/height indicator).

## Part C — merged roster v2 (human's creatures)

**Tone pivot (human's call, endorsed):** swap the somber SotC archetypes for
**charming creatures climbing giant beasts.** Keeps the climb mechanic; changes the
skin. Rationale: better differentiation (the co-op niche is all serious fantasy),
cheaper/easier art (§9), charm sells in this genre — and the ascend-to-the-weak-point
loop is untouched. The colossi become **giant climbable beasts** (a turtle-mountain,
a great bird, a tusked behemoth); reskin/rename the current Titans as creatures.

**Key principle:** spread the roster along a **"climbs well ↔ hits hard"** axis so
characters DEPEND on each other. If everyone self-climbs, there is no synergy; the
magic is a fast climber hauling a heavy hitter up to the sigil.

| Character | Role | Signature | On the axis |
|---|---|---|---|
| **Goblin Mech** | builder / heavy | *Salvage/Build* temporary Gadget cards (grappling hook = Height, piton = anti-shake); can hand gadgets to the ally | climbs poorly · **hits hard** |
| **Vine-Weaver (Plant)** | setup + DOT | *Vines* give shared Height to BOTH players; *Poison* (= our Wound) ticks the beast; roots resist shakes | climbs well (for team) · hits slow |
| **Frog** | mobility / scout | *Leap* — big self-Height, reaches + Exposes the sigil fast, weak strikes; can drag an ally up a zone | **climbs great** · hits weak |
| **Mountain Climbers** | coordination | *paired cards* — climb moves are incomplete alone; must combine with the ally's card the same round (belay ↔ ascend). Forces true §6 co-op | climbs only **together** |

**Gaps to fill:** the set is climb-heavy — light on a pure PAYOFF striker and a
PROTECTOR. Options: make the Goblin Mech the heavy payoff, and/or add one more
creature (a Beetle/Ram/Yeti-style defender-bruiser).

## Open questions for the human
- **How far on the climb feel?** A2 (recommended) is a real rework + re-tune;
  A1 is cheap but shallow. Your call on ambition.
- **Roster size & which archetypes** — do my four match your instinct, or are you
  picturing something different (elemental? mounts/Agro? a lone-wanderer solo
  option)?
- **Asymmetric decks vs shared pool** — full class decks, or a shared pool with
  class-flavored signature cards?
- Do characters have **meta-progression** (unlocks/levels) or are they fixed?
