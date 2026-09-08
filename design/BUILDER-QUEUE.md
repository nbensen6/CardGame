# Builder queue

The builder lane's work list. See `tools/builder/BRIEF.md`.

**Phase 1 — pathfinder.** Subject: `cinder_jackal`. One item per run, in order.
The order is by how much of the gap to the Sea of Thieves reference each closes,
measured where it could be measured (`design/art-target.md`).

Tick an item when the branch is pushed. Add what you learned underneath it.

---

## Done, and already general

These are pipeline steps: they apply to every beast that opts in, at no
per-beast cost. Phase 3 rolls them out by adding names to a list.

- [x] **Form continuity.** `tools/blender/unionremesh.py` voxel-remeshes the
      overlapping primitives into one continuous skin, so limbs grow out of the
      body instead of ending inside it. Opt in via `tools/blender/union.txt`.
      Costs the crisp faceting — the model reads softer, closer to clay. Whether
      that trade is right for the whole cast is Nick's, and it is why exactly one
      beast is opted in.
- [x] **Lighting response.** `game/assets/3d/creature.gdshader` — rim light,
      specular, ground tint on downward faces, per-biome rim colour. Already on
      for every beast, hunter and ground. Measured 8.8% of the beast's pixels.
- [x] **Emissive.** Named palette swatches glow, keyed on the swatch's UV, with
      a white-hot core because saturated orange tops out at 62% luminance. Per
      beast, wire the swatches in `combat_3d.EMBERS`.

## Next up

- [ ] **1. Widen the value range.** The single biggest remaining gap. Measured,
      only 2.4% of the jackal sits above 80% luminance and its body sits in the
      middle of the range everywhere. The reference runs near-black so its
      accents can scream. Try: darken the body swatches for this beast, and let
      the embers carry all the brightness. Watch that it stays readable against a
      dark biome — check `rift` and `drowned`, not just `quarry`.

- [ ] **2. Surface breakup.** Ours is flat swatches, one colour per face, no
      variation anywhere; theirs carries scarring and tonal variation. Cheapest
      route that needs no textures and no per-asset work: a subtle triplanar or
      world-space noise in the shader, modulating value only, never hue. Keep it
      under the threshold where it reads as noise rather than as surface.

- [ ] **3. Material variation.** One roughness for the whole animal is why it
      reads as one substance. Give the atlas a second channel, or key off swatch
      the way the embers do, so chitin can shine and fur cannot.

- [ ] **4. One exaggerated anchor.** The reference hangs off enormous dorsal
      spines you could identify from any distance. The jackal's ember ridge is a
      strip you have to hunt for. This is per-beast authoring and it is a
      DESIGN question — propose it in this file with a render, do not just
      enlarge the ridge.

- [ ] **5. A face.** Measured against the CC0 Kenney animals, the biggest gap in
      the whole cast is that theirs have eyes, a snout and ears on a head that is
      its own colour block, and ours have a featureless head with a sigil where a
      face would be. The jackal has two eye balls and nothing else. Per-beast
      authoring; see `design/adding-detail.md`.

## Tried, did not pay off

Recorded so nobody spends the day again.

- **Baked ambient occlusion into vertex colours** (`tools/blender/aobake.py`).
  Works, and moved 2.25/255 at fight distance — invisible next to the shader's
  6.22. Two reasons: the beast is about 250px tall on screen, and these models
  are built from overlapping primitives so a great many vertices sit inside
  another part and bake almost fully occluded. Kept for portraits and card art,
  where the camera is close enough for a crease to survive. Not for the fight.

- **Solidity and distinctness as quality gates** (`tools/blender/silmetrics.py`).
  Both thresholds were reasoned out rather than measured, and the CC0 Kenney
  reference refuted them within a day: it runs solidity 0.82–0.95 against our
  0.46–0.90, and its dog and pig share 96% of a silhouette. Our beasts have MORE
  negative space and are MORE distinct than professional art in this style and
  still look worse. The tool is still useful for finding near-twins inside our
  own cast; its numbers are not a quality bar.

## Questions for Nick

Answer these and the builder stops guessing.

- **Is the clay look right?** The union pass trades crisp low-poly faceting for
  continuous form. It is the biggest single change to how a beast reads and it
  is currently on for one beast only.
- **How far toward the reference is far enough?** Phase 2 starts when the jackal
  is good enough, and that is a judgement only Nick can make.
