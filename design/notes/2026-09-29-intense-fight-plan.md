---
tags:
  - plan
  - jackal
---

# Tonight's plan: a fight that feels intense

Nick asked 2026-09-29 22:30 ET for a builder plan in three parts: make the
fight feel more intense, with a climb that moves side to side instead of
straight up; a HUD that looks like a AAA game; and a volcano environment,
obsidian floor, lava rock under the hunters, lava flowing around the arena,
a real sky. Everything below is queued under `## Now` in
[[BUILDER-QUEUE]] in this order. The builder takes one item per run and
Nick ticks.

What this plan deliberately leaves alone, because Nick decided it today:
no card flight (reverted 20:59), no grip timer (removed 17:14), no balance
numbers. Every item here is motion, light, sound, layout or material.

## Where the fight is now

From the builder's own frames (`agents/frames/builder/2026-09-29-fog-behind-after.png`):

- The five climb stones sit on ONE straight line from the hunters to the
  sigil (`route_pos` in `views/combat_3d.gd`, "one straight line, even
  steps"). A climb reads as walking up a staircase, and from the resting
  camera the stones stack over each other.
- The floor is a flat grey-brown disc. The stones are tan boxes. The wall is
  a good Meshy rock face with lava seams, but nothing in the arena answers
  it: no glow on the floor, no lava, no embers, no heat.
- The sky is a two-colour gradient. Nothing moves in it.
- The HUD is flat panels with a thin outline, the same style the 2D client
  had. The beast's health bar is a plain progress bar. The intent badge is a
  small boxed label. The right-hand ladder is a thin line with ticks.
- Hits: a camera shake and a number. The jackal idles on a 4 s loop and
  does nothing between turns.

## Part 1: intensity

The order is what a player feels first.

1. **The climb zigzags.** Rungs alternate LEFT and RIGHT of the straight
   line, ledges on the outer edges, so every hop is a diagonal traverse
   across the flank. Same even hop length, same endpoints (ground gap and
   sigil are locked by #14). The hunter turns to face where it is going.
2. **The camera swings with each hop.** A sideways hop pans the locked
   camera across with the hunter and settles with a small overshoot, so the
   traverse is felt, not only seen.
3. **Hits stop time.** A landed strike freezes the frame for 0.08 s, shakes
   the camera in proportion to the damage, and bursts embers from the impact
   point; a weak-point hit adds a 0.15 s slow-motion. The jackal's bite gets
   the same hit-stop on the hunter.
4. **The jackal threatens between turns.** Its head tracks the active
   hunter, the ember cracks brighten as its turn comes, it growls once when
   the last hunter turn begins, and the intent badge pulses in step.
5. **Low health shows.** A hunter under 30 % gets a red edge vignette that
   pulses with a heartbeat; the jackal under 30 % streams embers, breathes
   faster and glows hotter. Adds a `hp` console command so the frame can be
   set up.

## Part 2: HUD

Reference: modern card-battlers with a 3D stage (the look Nick keeps
pointing at). One material language: carved obsidian panels, ember-orange
rim light, gold for the sigil and energy, a display face for names.

6. **One HUD style: carved obsidian.** New theme panels for the top bar,
   party cards, intent badge, energy orb and the End Turn / Switch
   buttons: dark glassy fill, bevelled edge, thin ember rim, soft drop
   shadow. Names in the display font already in `assets/fonts`. Nothing
   moves or resizes; this is the material pass.
7. **The beast's health bar reacts.** Wide bar under the name with notch
   marks at each weak-point threshold; damage leaves a pale ghost segment
   that drains after 0.4 s; a threshold crossing cracks the bar with a
   flash.
8. **Cards fan and glow.** The hand fans in a shallow arc with a slight
   tilt; the hovered card lifts, straightens and glows at the edge using
   `foil.gdshader`'s rim; the cost pip pulses when the card is playable.
   No flight (Nick, 20:59).
9. **The intent badge reads like a warning.** Bigger, red-rimmed, an icon
   for the move type, and pinned above the jackal's head at every camera,
   never over a hunter (the proposed "intent badge over the climbing
   hunter's head" is folded in).
10. **The climb gauge stands beside the beast.** The right-rail ladder
    becomes a gauge next to the stage: portrait pips for each hunter's
    height, glowing notches at the ledges, the sigil burning at the top.

## Part 3: the volcano

Scoped to `quarry_ember` and the jackal's own env, so no other beast
changes. Material and light first, then things that move.

11. **Obsidian floor.** The arena floor becomes black glass: dark base,
    sharp toon specular band, faint orange emissive in a crack pattern.
    The plain `Ground` disc gets the same material for beasts with no env.
12. **Lava rock under the hunters.** The climb stones and the hunters'
    standing slabs become dark basalt with an ember glow at the underside
    and edges, replacing the tan boxes.
13. **Lava flows around the arena.** A lava ring between the floor and the
    wall: an emissive scrolling shader with noise, slow flow, orange omni
    lights along it, heat shimmer above it.
14. **Embers in the air.** Rising ember particles across the arena, sparks
    falling from the wall's lava seams, and the seams lit with their own
    omni lights so they throw orange on the rock.
15. **A sky with ash.** A cloud layer over the gradient: slow-moving dark
    ash clouds with a red-lit underside near the horizon, the odd distant
    glow pulse. Fog behind the wall stays as it is.

## What gets measured

Every item names a harness frame. The grader passes or fails on pixels, so
each done-when is something a still can show. Items 2, 3 and 4 also have
motion a still cannot prove; their Test lines put Nick in the exact moment.

## Not in this plan

- Card flight, the grip timer, any number in `data/*.json`.
- Rigged hunters (needs Meshy credits; see the jackal analysis).
- Music layers. Sound is one growl and the hit-stop thud.
