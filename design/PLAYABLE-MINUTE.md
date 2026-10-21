# The playable minute — the Cinder Jackal

The art target is reached and retired. **This is what we build toward now**: not
a picture, but sixty seconds that someone would want a second minute of.

It is written as checks, because "make it fun" is not reviewable and a still
frame cannot judge a fight. Each one is something you can watch happen, or
read out of `godot_runtime_state digest`. A check that fails is work.

Read with [[LEARNINGS]] (how to run and read the fight) and [[DECISIONS]].


> [!tip] ▶ **[Play the minute](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal)**
> Straight into the Cinder Jackal, solo, Frog and Goblin. It pulls, reimports
> and launches on your main screen with focus and sound — `override.cfg` (which
> keeps agent runs off your screen) is moved aside for the length of the game
> and put back after.
>
> Have this note open beside it. The ten checks are below; mark the ones that
> fail as you go.

## The fight as it actually stands

Verified against the code, 2026-10-19, not from memory:

- **The Jackal** has 70 HP. Its **sigil — the weak point — is at Height 5.**
  Safe ledges at **2 and 4**; the base is 0. Everything between is a cling.
- **Its pattern** is attack 7 → block 5 → attack 9 → **claw sweep 6** → attack 8.
  The claw only catches hunters at **Height 4 or above** and throws them down.
- **Under 40% HP it changes gear**: attack 12 → attack-all 9 → attack 14 →
  enrage. The fight gets meaner exactly when you are closest to winning.
- **Two hunters, 42 HP each, 3 energy a round.** In solo you hold both and
  Switch between them. **Any hunter dying loses the fight.**
- **Off a hold, the grip timer runs** (`Feel.GRIP_SECONDS`, 5s). Empty it and
  you fall to the base: **3 damage, and your weak-point progress resets to 0.**
- **A timed card opens a sweep** (`Feel.WINDOW_SECONDS` 2.5s at
  `Feel.SWEEP_SPEED` 1.9/s). Land in the zone for the bonus, the core for all
  of it. **A landed timed card builds Rhythm**; a missed one plays plain.
- **Deal 16 at the sigil and the beast bucks you down a hold.** You cannot camp
  the weak point. This is the designed loop: **climb → strike → get thrown →
  climb again.**

That loop is the game. The minute below is that loop being legible and tense.

## The checks

**1. The first decision happens inside ten seconds.**
Opening hand, 3 energy, the Jackal telegraphing Attack 7 at slot 0. A new
player should be able to see that climbing costs them the block they'd need —
and choose anyway. *Fails if the first turn has an obviously correct play.*

**2. Leaving a hold feels like a commitment.**
The moment a hunter goes off 0/2/4, the grip bar is the loudest thing on
screen. *Fails if a player can be mid-climb and not notice.*

**3. The sweep is a reaction, not a formality.**
At 1.9 sweeps/sec with a 0.40–0.60 zone, a timed card should be missable by a
distracted player and reliable by an attentive one. *Fails if you can land the
core without looking, or if landing it feels like luck.*

**4. Reaching the sigil is an event.**
Height 5 should read as arriving somewhere, not as a number changing. *Fails if
nothing about the frame, the sound or the beast says "you are on its face".*

**5. Getting bucked is a setback you understand.**
At 16 damage on the sigil the beast throws you down a hold. The player must
know **why** it happened and that it was earned, not random. *Fails if it reads
as the game taking a turn away.*

**6. The claw sweep punishes the greedy, visibly.**
It is the fourth move and it only catches hunters at Height 4+. A player who
read the telegraph and dropped to a ledge should feel clever; one who climbed
anyway should feel it was fair. *Fails if the telegraph does not say "get down".*

**7. Switching hunters is a tactic, not bookkeeping.**
Solo holds two climbers. The minute should contain one moment where switching
is clearly right — one hunter clinging, the other safe to spend. *Fails if
Switch is only ever used to tidy up a turn.*

**8. The 40% gear change lands as a threat.**
Attack 7 becoming Attack 12 is the fight's second act. *Fails if the player
cannot tell the fight just changed.*

**9. A loss is traceable to a choice.**
A hunter dies and the player can name the turn it went wrong — the climb they
should not have made, the block they skipped. *Fails if losing feels arbitrary.*

**10. Minute two is a different minute.**
By 60 seconds the player should have climbed, struck, been thrown, and be
deciding whether to go again or steady first. *Fails if the minute is the same
turn five times.*

## How to check them

Drive the fight through the Godot MCP (recipe in [[LEARNINGS]]): boot frozen,
step time in slices, read `_mcp_state()` rather than screenshots. The knobs for
2, 3 and 5 are in `game/core/feel.gd` and can be changed in the running game —
try a value, feel it, keep it or put it back.

Checks 1, 4, 6, 8 and 9 are **Nick's to judge by playing**. No agent should
mark those passed; the drawing-versus-words mistake has a gameplay twin.


## What I found driving it, 2026-10-19

Measured in the running fight through the Godot MCP. Nick, 2026-10-19: "focus
less on balancing and more on the design" — so what follows is read as design.
The numbers are evidence, not the fix.

### The climb and the fight are two games that barely touch

This is the one that matters. Height is a **gate**, not a dimension: reach 5 to
hit the sigil. Everything else plays exactly the same at 0 as at 5.

- **10 of 187 cards** read the hunter's height (`damage_per_foothold`), and
  **none of them are in either starting deck.** Nothing you play in minute one
  changes because of where you are.
- **1 of the Jackal's 9 moves** cares where you are — the claw sweep, which
  catches hunters at 4 and above. The other eight hit the same whether you are
  on its face or standing on the floor.

So the climb costs cards and risk and gives back one thing: permission to
attack the sigil. A player who never climbs plays a normal deckbuilder; a
player who climbs plays the same deckbuilder higher up.

**The design question:** what should being high up *mean*, besides access? The
obvious candidates — it changes what your cards do, it changes what the beast
can do to you, it changes what you can see coming.

### The grip timer has no decision attached to it

The Frog's +1 Climb and ledges at 2 and 4 mean **one climb in eighteen leaves
it clinging**:

    from 0:  Tongue Snap->2  Leap->4  Hop->2  Pounce->2  Leapfrog->3 CLING
    from 2:  Tongue Snap->4  Leap->6  Hop->4  Pounce->4  Leapfrog->5
    from 4:  everything ->6 or higher, at or past the sigil

The numbers are the symptom. The design problem is that **hanging is never a
choice** — it is an accident of arithmetic. A timer that only punishes bad
luck is noise; a timer you choose to start, because hanging buys you something,
is tension. Right now there is no reason to ever be between holds.

### The timed sweep rewards the wrong thing

The band is 105 ms wide and the "full bonus" core inside it is **31 ms — 1.9
frames**, narrower than human reaction variance. But widening it is the balance
answer. The design answer is that **the core is a second helping of the same
reward**: both tiers pay damage, so the inner one is invisible and the outer
one makes it pointless. A timing hit could instead change *what the card does*
— the thing a player would notice and aim for.

### The Goblin's minute one is "wait"

No climb card, one damaging card in ten. The deck is Build Grapple, Build Mech,
Grappling Arm, Jetpack — gadgets that pay off later. In a co-op game about two
climbers, **the two hunters do not interact at all in the first minute.**
Switching is bookkeeping until something fires.

### What does work

Two hits at the sigil pass the threshold of 16 and the beast bucks the hunter
from 7 down to 4, counter reset. **The climb -> strike -> thrown -> climb loop
exists and is quick.** It is the one part of the minute that is already a
rhythm, and everything above is about giving it stakes.

### Still yours to judge

1, 4, 6, 8, 9 — the opening decision, arriving at the sigil, the claw's
telegraph, the 40% gear change, and whether a loss reads as your fault.

## Scorecard

Tick as you play. **1, 4, 6, 8, 9 are yours alone** — I will not mark those.

- [ ] 1 · first decision inside ten seconds — *yours*
- [x] 2 · leaving a hold feels like a commitment — **FAILS**, the grip bar barely runs
- [x] 3 · the sweep is a reaction — **FAILS**, the core is 1.9 frames wide
- [ ] 4 · reaching the sigil is an event — *yours*
- [x] 5 · getting bucked is a setback you understand — mechanic works; legibility is yours
- [ ] 6 · the claw punishes the greedy, visibly — *yours*
- [x] 7 · switching is a tactic — **SHAKY**, the Goblin cannot climb or hit in minute one
- [ ] 8 · the 40% gear change lands as a threat — *yours*
- [ ] 9 · a loss is traceable to a choice — *yours*
- [ ] 10 · minute two is a different minute

Anything you can say in a sentence is enough — "the grip bar is invisible",
"the claw killed me and I never saw it coming". That sentence is the next task.

## The look, 2026-10-21

Not a check — the frame the ten checks are played in. Nick's list for the
jackal, done the second time because the first time changed a PNG the fight
never draws (see [[LEARNINGS]]):

- Just the jackal: no rock wall at its left, no stone outlines on its belly,
  no glow round the fist's flame. The rig's seven layers are cut from the
  clean sprite now (`tools/beast_recut.py`).
- The beast stands IN the lava: past the ground's edge, inside the ring,
  sunk to its feet. The stones hang where they were, so the top of the
  climb has open air and lava between it and the chest. (First try put it
  0.9 of its height back on dark ground, twenty units short of the lava;
  Nick: "put it back into the lava. This is a visual change, not a
  mechanism change.")
- The Frog and the Goblin each have their own staircase to it.

![[shots/2026-10-21-in-lava-rest.png|800]]

![[shots/2026-10-21-in-lava-climb.png|800]]

(The Tongue Flick card over both frames is the shot harness catching the
real mouse on the second monitor, not the game.)

▶ **[Play it again](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal)**
