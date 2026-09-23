---
tags:
  - agents
---

# The bar for the Cinder Jackal fight

Nick, 2026-09-23: **no bought asset packs — everything here is generated or
built by us** — and the Cinder Jackal fight reaches Slay the Spire quality
before anything else gets attention.

This is the definition of done. Every agent works items from it when no
request is open; tick one only when a frame or a test proves it, and say
which. Nick has the final word on every line: he can untick anything.

## What "Slay the Spire quality" means here

StS is not a pretty game; it is a *legible* one. Everything below is about
reading the fight at a glance, at play size, in motion.

### The cards — the thing you look at most
- [ ] **Every card in both decks has art.** No bare icons. Generated here.
- [ ] **A card reads at hand size** (~160px tall): name, cost, art and effect
      all legible without hovering.
- [ ] **Card art says what the card does** before the text does.
- [ ] **One consistent style across the whole deck** — not a mix of painted
      and flat icons.
- [ ] **Play feedback**: a card visibly leaves the hand, the effect lands on
      the beast, and a number or state change follows. No silent plays.

### The fight, read at a glance
- [ ] **The beast's intent is unmissable** — what it will do next turn, and
      to whom, readable without hunting for it.
- [ ] **Damage and climb numbers** appear where the thing happened.
- [ ] **Both hunters are always findable**, including mid-climb.
- [ ] **Nothing important is behind the hand**, the rail or the party panel,
      in any state, at any hand size.

### The creature
- [ ] **Silhouette reads at 250px** — the jackal is recognisable as one shape.
- [ ] **The weak point is obvious** and stays obvious as you climb toward it.
- [ ] **It is alive when idle** (breath, tail, ember pulse) without drifting.
- [ ] **It reacts**: attack, hit and death all read as different events.

### Motion
- [ ] **The jump reads** — anticipation, arc, landing, at the size it plays.
- [ ] **The camera never loses the active hunter**, including mid-jump.
- [ ] **No pops**: nothing teleports, flickers, or snaps between frames.

### The hunters
- [ ] **Frog and Goblin match the jackal's fidelity.** Today they are
      Python-primitive models beside a textured, rigged beast — the loudest
      style break in the fight.
- [x] **Each is readable at fight distance** as itself, not a green blob.
      The Goblin Engineer's Meshy rebuild was wired in and unreadable at true
      size (a near-solid black blob) until the shared ink-outline width was
      given a per-model scale, 2026-09-23 — verified in the real fight and
      the campfire row. `design/progress/goblin_mech_ai.md` ("Shipped and
      scored"). Frog was already there. Fidelity is not fully matched yet
      (37/50, under the hunter stop line) — see the line above.

### The arena
- [x] **It frames the beast** rather than competing with it. Meshy-generated
      crater wall replaced the primitive `enclose()` slabs, 2026-09-23 —
      verified in every 3D camera state the fight uses, beast stays the
      clear subject with the wall reading as backdrop. `design/progress/
      cinder_jackal_ground.md` pass 6, 37/50.
- [x] **It says where this fight is**, not "generic ground". The sigil
      close-up now shows real glowing ember cracks in the rock itself, not a
      flat slab — same evidence as above.

## How to work it

One item per run. Prove it with a rendered frame at 1:1 (never a zoomed
crop) and, where it is a rule, a test. Put the frame in the beast's note and
in your status note. If an item needs a judgement about taste, build the
strongest version you can, show it, and file `to: nick`.
