# The playable minute — the Cinder Jackal

The art target is reached and retired. **This is what we build toward now**: not
a picture, but sixty seconds that someone would want a second minute of.

It is written as checks, because "make it fun" is not reviewable and a still
frame cannot judge a fight. Each one is something you can watch happen, or
read out of `godot_runtime_state digest`. A check that fails is work.

Read with [[LEARNINGS]] (how to run and read the fight) and [[DECISIONS]].

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

## Status

Nothing here is ticked yet. The next pass is to play the minute and say which
of the ten fail, in order.
