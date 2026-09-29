---
tags:
  - analysis
  - jackal
---

# What the Cinder Jackal fight needs

Nick asked 2026-09-28 for an analysis in three parts: animations, cards and
balance, the climbing loop. Three read-only passes over the code and data
fed this; every number below comes from `game/data/*.json`, `game/core/combat.gd`
or `game/views/combat_3d.gd` unless it says "computed" or "simulated".

The one-line diagnosis: **the fight is over before its own design starts.**
With perfect timing it lasts 1.8 rounds against a design target of 4 to 6,
the Jackal usually dies before its hurt pattern or Enrage ever fire, the
Frog never experiences the grip bar, and the enemy turn resolves in zero
seconds. Almost everything below follows from those four facts.

## 1. Animations

### What exists

| Actor | Has | Missing |
|---|---|---|
| Jackal | 3 clips: idle (4 s loop), attack (1.3 s), hit (0.7 s); recoil, ember pulse, dust, shake | death; roar or intro; any wind-up before its turn; any reaction to a blocked or non-damage move |
| Frog, Goblin | no rig, no clips at all; everything is code: hop arc, crouch, stretch, lean, landing squash, idle bob, turn-to-face, grip jitter | attack lunge; hit flinch; slip or fall pose; downed state. The code already calls `idle`, `attack`, `hit` clips on them and they silently do nothing |
| World and UI | camera shake, hit flash, dust, damage popups, sigil pulse, stone bob, grip bar colour, hit-circle bursts, hover and drag on cards | cards fly out or in (they pop); block, poison and climb have no visual; timing hits never reach the world (`note_hit` is not connected); PERFECT and GOOD share a sound; the `block` sound exists and is never played; win and lose are a hard cut |

### The gaps a player feels, in order

1. **The Jackal bites after the damage.** Its attack clip is triggered by a hunter's HP dropping, so the wind-up plays after the number. Nothing at all plays while its turn is coming. This is the single biggest reason the fight reads as a spreadsheet.
2. **No death.** The killing blow plays `hit`, then the scene cuts to the reward screen where the body is a rotated model.
3. **Hunters don't attack or flinch.** A card that deals 33 damage produces a gold number and nothing on the Goblin.
4. **Cards pop instead of flying.** Playing a card is the most frequent action in the game and it has no motion.
5. **The timing mini-game is silent in the world.** A PERFECT lands on the card, not on the beast.
6. **Falls look like hops in reverse.** No slip, no downed moment, then the fight continues instantly.

### What to build, cheapest first

- **Enemy-turn choreography, no clips needed:** on End Turn, 0.4 s hold, intent badge pulses, the existing `attack` clip plays, damage lands at the bite frame (frame 16), then the popup. Same for the sweep with a camera shake and both hunters hopping down. About two seconds that turn a number into an event.
- **Hunter reactions as tweens, no rig needed:** attack = a 0.15 s lunge toward the beast plus a scale punch; hit = a white flash and a 0.2 s knock-back with a lean. The hop code already proves this style works on these models.
- **Card flight:** the played card scales up and flies to the beast (or to the hunter for block) before its effect resolves; block pops a `◈` shield ring on the hunter; poison drips.
- **Timing echoes:** connect `note_hit` so each PERFECT sparks on the hunter and each GOOD flashes dimmer; give PERFECT its own sound.
- **Death:** a `death` clip from the same Blender script that made the other three (the recipe already exists in `tools/blender/ai_beast.py`), a 0.6 s slow-motion on the final hit, then the fall.
- **Later, with assets:** rig the hunters. The Goblin and Frog are Meshy models with no skeleton; Meshy's rig-and-animate costs about 8 credits each and the third video Nick shared did exactly this. Until then the tween route covers 80 percent of the feel.

## 2. Cards and balance

The standing rule is no balance tuning (BACKLOG #34, builder brief). Nothing
below changes a number. It says what the numbers do today and which ones are
Nick's decisions.

### What the data says

- **Every damage card in both starting decks is timed**, and a miss removes the card for the rest of the fight with no effect. A string of misses leaves a team with no way to deal damage.
- **The default hit circle demands 3 taps per card** and the card's quality is its worst tap. At a 78 percent hit rate per tap a card lands 47 percent of the time. The sweep bar, the other setting, needs 1.
- **Fight length (simulated):** perfect timing wins 100 percent in 1.8 rounds; sweep bar at 78 percent, 2.6 rounds; hit circle at 78 percent, 3.3 rounds and a 72 percent win rate; at 55 percent, 10 percent. Target is 4 to 6 rounds.
- **The Jackal's own design never happens.** Its hurt pattern starts at 16 HP, its Enrage in round 9. A timed Satchel Charge at the sigil is 33 of its 42 HP. Two Satchels melded are 59.
- **The Frog reaches the sigil in round 1 in 97 percent of opening hands.** The Goblin by round 2 in nearly all of them.
- **All three single attacks in the first loop hit the Frog** (a 5-move pattern against 2 alternating targets). The Goblin is untouched until round 6, which never comes.
- **Height 3 is a trap only the Goblin falls into.** One timed Grappling Hook from the ground is +3, a hanging height with a 5 s grip. Every Frog starter climb is even because of its +1 passive, so the Frog never hangs.
- **The Block move shows nothing** and the intent can flip mid-turn when HP crosses 16.

### Decisions for Nick, with a default each

1. **A miss should not delete the card.** Default: a miss plays the printed value with no bonus and the card discards normally. This alone moves the hit-circle win rate from 72 toward the 90s (simulated) without touching any number on a card, and it makes a bad tap a disappointment instead of a punishment.
2. **One tap for one-window cards.** Default: the 3-tap minimum applies only to cards that print more than one window (Satchel). The "double timing" feel is the grip clock against a single timed tap, not three.
3. **Fight length.** The fight ends in two rounds because the sigil bonus, the Goblin passive and Satchel stack on 42 HP. Nick's choice, not the builder's: raise Jackal HP toward 70, or drop the sigil bonus from 5 to 3, or make the buck threshold 12 so the Satchel always ends a visit. Default if nothing is said: HP 70, everything else untouched, so the hurt pattern and Enrage are actually met.
4. **The Frog must hang sometimes.** Default: the +1 passive applies only to Climb cards, not to attacks that climb (Tongue Snap, Pounce), so a Pounce from ledge 2 lands on 3 and the grip starts. Both hunters then live in the mechanic.
5. **Give the Jackal one positional move.** The engine has `swipe_high` and `swipe_low`; the Jackal uses neither. Default: replace the round-4 sweep with swipe_high (throws anyone at 4 or above) so "where am I" is a real question when the intent shows.

### Card ideas that fit the double timing

Each is one line of data, no new system. Costs are placeholders.

- **Anchor** (Goblin, 1, skill): both grip timers pause until your next turn. The co-op card the deck is missing: the Goblin buys the Frog time.
- **Kick Off** (Frog, 0, skill, timed hold): Climb 2, and the ally gains 1 energy on a PERFECT. A slider in the starter deck so the hold feel appears in round 1.
- **Rope** (either, 1, skill): swap Heights with your ally. The pull-up cards only work when the caster is above; this works both ways and reads instantly on the gauge.
- **Ember Bite** (Jackal move): sets the stone the hunter stands on alight; next turn it burns unless they move. A threat that is answered by climbing, not blocking.
- **Second Wind** (either, 1, power): the first fall each fight costs no HP and refunds 1 energy. Softens the loop for casual play without touching damage.
- **Cinder Dust** (Jackal, on Enrage): timing windows shrink by a third for a round. Makes the hurt phase feel different in the hands, not just the numbers.
- **Brace Together** (Frog, 1): both hunters gain 4 Block; +4 more if the ally is hanging. Replaces one Brace in the starter so co-op is in the first hand.

## 3. The climbing loop

### How it plays today

Wide establishing shot, hunters on the ground in front of their own stone
line, five stones each rising 1 to 15 units in five even legs. A climb card
hops the hunter one stone per height with a route that skips the stone of an
unsafe height (0 to 2 flies over height 1's stone). Reaching height 1 or 3
starts a 5 s real-time grip; reaching 2, 4 or the sigil is safe. At the sigil
hits do full damage plus 5, and 16 damage in a visit bucks the hunter to
ledge 4. End Turn flips to the other hunter; when both have ended, the enemy
turn resolves instantly. Round 4's sweep knocks both hunters down one ledge.
A full climb from the ground is four hops and about 3.7 s.

### What is wrong with it

1. **The grip clock runs during time that isn't yours.** It starts at the snapshot and keeps draining through the hop animation, the timing mini-game, the other hunter's turn and the enemy turn. A 5 s grip can be 2 s of real decision time. Fix: pause it whenever the hunter isn't the one being held or a tween or timing window is open. The feel Nick wants is one clock against one tap, not a clock against the UI.
2. **Half the cast never hangs.** See 2.4. The signature mechanic is Goblin-only today, and for the Goblin it is a trap he cannot avoid rather than a choice.
3. **The enemy turn is instant.** See 1. The loop is climb, tap, number, number, new hand. There is no moment where the beast does something you watch.
4. **The timing UI is on the card, not on the hold.** The notes stream from the tapped card; a comment in the code says they open at the hold on the beast and they don't. Moving them to the hold puts the "double" of double timing in one place on screen: grip bar, notes and hunter together.
5. **Position doesn't matter to the Jackal.** Its only knockdown is a scheduled sweep in round 4 that hits everyone. Nothing it does asks "where are you". See 2.5.
6. **The second hunter is furniture.** In solo, the other hunter does nothing until Switch, is usually off-screen (Nick accepted that), and its grip keeps draining. The co-op cards that would make it matter (Grappling Arm, Catapult, Leapfrog) are conditional or rare in the first hand. See the Anchor and Rope ideas.
7. **The fall has no cost that reads.** 3 damage and back to the ground, in reverse hops. The re-climb loop, which is the roguelike's rhythm, almost never happens because the fight ends first.
8. **The scripted playtest never presses Switch.** So the co-op half of the loop has zero automated coverage; only Nick has ever exercised it.

### Order I would put in the queue

Each is one builder item with a frame that proves it. None touches a balance number; the three that would are decisions above.

1. Enemy-turn choreography: hold, telegraph, bite at frame 16, popup, then the new hand. Shot: a strip of four frames across the enemy turn.
2. Grip pauses outside the held hunter's own decision time. Shot: the grip bar at the same value before and after the other hunter's turn.
3. Timing notes open at the hold on the beast, next to the hunter. Shot: state=3dclimb with a timed card open.
4. Hunter attack lunge and hit flinch as tweens. Shot: the strike frame and the hit frame.
5. Card flight and block ring. Shot: mid-flight frame.
6. Death moment. Shot: the last hit and the fallen body.
7. Playtest presses Switch at least once per run, and one check asserts the second hunter's grip did not drain during the first hunter's turn.

Then the four decisions in section 2, which are yours.

## Sources

Animation inventory, card and beast data, and the loop trace were gathered
2026-09-28 from `game/`, `design/agents/JACKAL-BAR.md`, `design/plan/`, and
`design/notes/`. The fight-length figures are from a 3,000-to-6,000-fight
simulation written from the rules, not the game's own `tools/balance_sim.gd`.
