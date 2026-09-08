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

- [ ] **1. Widen the value range — and NOT by swapping swatches.**

      The single biggest remaining gap. Measured, only ~2.4% of the jackal sits
      above 80% luminance and its body sits mid-range everywhere; the reference
      runs near-black so its accents can scream.

      **The swatch-swap route was tried on 2026-09-08 and does not work.**
      Branch `builder/2026-09-08-widen-value-range` swapped RUST→BRICK and
      TAN→UMBER across the body, correctly leaving the ember swatches alone. It
      executed the brief properly and the result barely moved:

      ```
                median   above 80%   below 20%   p01-p99 range
      before     117.9      2.59%      31.05%        209
      after      113.8      2.36%      32.74%        209
      ```

      Four points darker, nothing brighter, range unchanged. Two reasons, and
      they are both structural rather than a matter of picking better swatches:
      the palette's warm cells simply are not very dark, so the reachable move is
      small; and **a swatch swap cannot raise the top of the range at all**,
      which is the half that actually creates contrast.

      **The shader-lever half was tried on 2026-09-08, branch
      `builder/2026-09-08-value-range-shader`, and the darkening half works —
      the brightening half could not be confirmed.** Two new uniforms on
      `creature.gdshader`: `body_gain` (an albedo multiplier applied to
      everything the ember mix does NOT own, default 1.0 = no-op) and the
      existing `ember_gain` made overridable per beast. Both are set from a new
      `combat_3d.VALUE_RANGE` dict beside `EMBERS`, opt-in only, so every other
      beast renders unchanged. `cinder_jackal` set to `body_gain 0.55`,
      `ember_gain 4.5` (up from the shader default 2.6).

      Proof is the same real fight camera as the swatch-swap attempt (state=3d
      beast=cinder_jackal, dist 31.44, identical box):
      `design/renders/cinder_jackal_valuerange_before.png` /
      `_after.png`. The body darkening is visibly obvious side by side — not a
      number nobody could see. Measured in a clean 270×290 crop of the torso
      alone (no HUD, no ground, no embers in it):

      ```
                median   above 80%   below 20%   p01-p99 range   mean
      before     113.6      1.38%      34.23%        199.1       91.4
      after       74.0      0.00%      44.45%        141.7       76.5
      ```

      Median dropped 40 points and the near-black fraction climbed 10 points —
      that half of the lever works and is visible. **What did NOT work:** every
      pixel this run could find that carries the AMBER/TANGERINE ember swatches
      (the gold ear studs, a spec highlight low on the chest) got DARKER after
      the change, same as the rest of the body, not brighter — meaning none of
      them are actually inside the ember UV keying at this camera angle. Hunted
      for any pixel that got brighter anywhere on the beast across the whole
      frame and found none except two stray specular flecks on the hunter
      figurines at the beast's feet (unrelated, camera-idle noise). This is the
      union-remesh cost the brief already named: eyes fell from 18.7% of faces
      to 2.9%, ridge from 2.9% to 0.5%, and from this angle what little survives
      is not facing the camera. So `ember_gain 4.5` is live in the shader and
      genuinely a no-op on every other beast, but **nobody has SEEN it do
      anything yet** — the fix is not a bigger gain, it is getting ember-tagged
      geometry to face the fight camera at all, which is queue item 5 (a face)
      territory, not this item's.

      **Next step for this item:** either re-tag which faces carry the ember
      swatch AFTER the union remesh (so it survives with enough coverage to be
      camera-facing), or orbit the fight camera across a few yaw angles and
      check whether the surviving 0.5–2.9% ever faces it at all before spending
      more on `ember_gain`. Don't re-run the darkening half again — it is
      proven and committed; only the brightening half is still open.

      Ignore the old advice to check `rift` and `drowned`: the builder found
      that cinder_jackal is only ever fought in `quarry`, which was a better
      catch than the instruction it was given.

      **This lever is now MERGED to main** (2026-09-08). The darkening half is
      done and proven; only the brightening half is open, and it is blocked by
      item 1a rather than by anything in the shader.

- [ ] **1a. Make the accents survive the union pass — blocks item 1.**
      `unionremesh.py` holds `union.txt` accent swatches out of the remesh and
      rejoins them, and the face counts said it worked (44 ridge, 288 eye faces
      preserved). But the value-range run found no ember pixel on screen, so
      either those faces are not where the camera looks, or they are being lost
      later in the build. Measure it, do not reason about it: render the beast
      and count pixels whose UV falls in an ember cell, from the actual fight
      camera. Fix whichever half is lying.

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
