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
      First rubric score, 2026-09-24: **40/50** (Sil 8, Prop 8, Hygiene 7,
      Colour 9, Style 8), 4 under the 44 beast stop line. This model
      (`cinder_jackal_ai.glb`) had never been scored before — only two named
      fixes (ear glow, foothold texture) had ever been made to it. The look
      found a real defect no prior pass had caught: a stack of leftover
      basalt foothold geometry (320 faces, pre-dating the 2026-09-23 switch
      to floating in-engine stones) was still fused into the model's own
      chest/foreleg region, contaminating the shipped file because every
      rebuild since has re-fed the beast's own prior export back in as its
      source. Removed it (confirmed fully disjoint from the real body
      first), plus a stray unreferenced icosphere. `design/progress/
      cinder_jackal_ai.md` ("Pass 2"). A fresh, more critical six-view look
      plus an in-fight check, 2026-09-24, confirmed that fix is holding and
      found nothing further on Silhouette/Proportion/Style — score stays
      40/50. The one open gap, Build hygiene's tri-budget overage, is now a
      confirmed structural ceiling shared by all three Meshy-built cast
      members (this beast, `frog_ai`, `goblin_mech_ai`); closing it needs a
      deliberately risk-budgeted decimation/re-unwrap pass, not another
      look. `design/progress/cinder_jackal_ai.md` ("Pass 3").
- [ ] **The weak point is obvious** and stays obvious as you climb toward it.
- [x] **It is alive when idle** (breath, tail, ember pulse) without drifting.
      Verified 2026-09-24: the shipped `idle` clip (4.0s loop) produces real
      motion every render (`state=3d anim=idle@0/@2/@4`), and diffing frame 0
      against 10 and 100 loops later (`@40`, `@400`) shows the same bounded
      amount of change each time rather than a growing one — the motion
      oscillates, it does not accumulate into drift. `design/progress/
      cinder_jackal_ai.md` ("Pass 4").
- [x] **It reacts**: attack, hit and death all read as different events.
      Attack/hit were already known to differ (separate clips, `_strike()`'s
      camera-shake/flash/weak-point emphasis). Death had never been checked:
      no `death` clip exists and `combat_3d.gd` never branches on
      `boss.is_dead()` — but `location_3d.gd`'s own `_lay_out_the_felled()`
      (already tuned specifically for this beast's proportions) lays the
      jackal on its flank in the reward scene, and a real render
      (`state=3dreward beast=cinder_jackal`) confirms it reads as a fallen
      animal — snout/ears, four splayed legs, the same spine markings — not
      an abstract shape. `design/progress/cinder_jackal_ai.md` ("Pass 4").

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
      scored"). Frog was already there. Fidelity is not fully matched yet —
      see the line above. The party rail's portraits were still the OLD
      Python-primitive models for both hunters even after the fight itself
      moved to the Meshy ones (`portraits.py`'s own `AI_ART` table never
      got the hunters added); fixed 2026-09-23, which also closed the last
      open Colour & read question for both — `frog_ai` **42/50, at the
      stop line**; `goblin_mech_ai` **40/50** (was 39), after fixing the
      tank-vs-body contrast at 34px named as the concrete gap — which also
      surfaced and fixed a real bug: the glb's own embedded texture had
      never received the earlier colour-boost pass, so every portrait
      render (party rail, character card, campfire) had shown a dimmer
      goblin than the fight itself for two passes running.
      `design/progress/frog_ai.md` pass 3,
      `design/progress/goblin_mech_ai.md` pass 5. A fresh six-view look,
      2026-09-23, found a bigger colour defect than any prior pass had
      caught: at the true `state=3d` camera, 1:1, not a zoomed crop, the
      Goblin's skin read near-white, not green — every earlier "verified in
      the real fight" frame in this thread had been a 3x crop, which hid it.
      Fixed with a hue-masked saturation boost (skin only, value untouched)
      that now matches the Frog's own saturation range at both the real
      fight camera and the 34px portrait. `goblin_mech_ai` **41/50** (was
      40), one point under the hunter stop line.
      `design/progress/goblin_mech_ai.md` pass 6.

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
