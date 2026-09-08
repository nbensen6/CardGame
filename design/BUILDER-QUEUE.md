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

- [x] **1. Widen the value range — and NOT by swapping swatches.**

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

      **Correction, 2026-09-08 (builder, item 1a): the brightening half is
      NOT blocked — it already works, and this item's own committed proof
      shows it.** `design/renders/cinder_jackal_valuerange_after.png` (and
      `_before.png`) both show the two AMBER eyes as a bright white-gold
      highlight punched into the dark charcoal head — sampled directly,
      (255,187,70) at the eye core against (16,8,2) two inches away on the
      same head. That is `hot = mix(base, white, ember_white*ember)` plus
      `EMISSION += hot*ember*ember_gain*beat` doing exactly its job. A zoomed
      crop of the same committed frame is at
      `design/renders/cinder_jackal_embercheck_eyes.png` for anyone who wants
      to see it without doing the pixel-sampling themselves.
      **So: FIXED, not blocked.** See item 1a below for what was actually
      wrong (a measurement bug, not the render) and what is genuinely still
      open (the ridge, not the eyes).

- [x] **1a. Make the accents survive the union pass.** Resolved 2026-09-08,
      builder — narrower and better news than the open item was.

      `unionremesh.py` holds `union.txt` accent swatches out of the remesh and
      rejoins them, and the face counts said it worked (44 ridge, 288 eye faces
      preserved). The item above said the value-range run found no ember pixel
      on screen anywhere and asked to measure the real fight camera rather than
      reason about it. Done — and the "no ember pixel" claim does not survive
      the measurement:

      **The eyes are fine.** They read as a clear, bright accent in the fight
      camera right now, in both of item 1's own already-committed proof
      images (see above). The previous run's own whole-frame brightness diff
      between `_before.png`/`_after.png` was correct on its own terms — zero
      eye pixels got BRIGHTER from the `ember_gain 2.6→4.5` change — but that
      is because the eyes were already white-hot and visually saturated
      *before* the bump, not because they were invisible. A gain increase on
      an already-clipped pixel has no headroom to show. Confirmed by
      re-diffing the two committed PNGs directly: the only pixels that moved
      were on the hunter figurines at the beast's feet, exactly as the
      original run said.

      **The ridge is the real gap, and it is a geometry problem, not a gain
      problem.** Measured directly (not reasoned about): for every held-out
      accent face, cast a ray from just outside it along its own normal and
      count how many times it re-enters the remeshed body before reaching
      open space. On cinder_jackal that comes back 246/288 eye faces exposed
      to open space against only 2/44 ridge faces — the eyes mostly clear the
      remeshed skin, the ridge mostly does not. That is a real, reproducible
      split, and it is why one accent works and the other is invisible: not a
      camera angle (a magenta-flagged Blender render of the built glb from
      five angles spanning a full sphere — front/back/side/above/34 — never
      shows the ridge either), and not a shader gain (`ember_gain` already
      applies to whatever ridge geometry exists; there is just not enough of
      it on screen to move).

      **Tried and did not clear the bar: pushing buried accent shells outward
      after rejoin, gated to shells more than 50% buried** (so the
      already-working eyes are left alone — a first, ungated version of this
      push visibly popped one eye into a detached floating ball, which is a
      worse defect than the one it fixes; checked by rendering it, not
      assumed). Gated, it raised the ridge's exposed-pixel count by roughly
      30% across the same five-angle Blender sweep with the eyes provably
      untouched. But rebuilt into the actual game and shot from the real
      combat camera (`state=3d beast=cinder_jackal`, same box as every proof
      above), the difference is not visible — the ridge sits along the
      spine's top edge and this camera views that edge nearly on end either
      way, so more exposed area does not turn into more screen area. Not
      shipped: a measured improvement that does not clear this lane's own
      bar ("a player would notice") is not a finished item, and the code was
      reverted rather than landed unused. If a future run wants it: the
      approach is a per-shell (not per-accent-object — `union.txt` can name
      several disjoint pieces at once) outward nudge along the direction from
      the remeshed body's own centre, gated on the ray-cast exposure test
      above so it never touches a shell that already reads correctly.

      **What this really argues for is item 4** (a bigger, redesigned ridge)
      **rather than more pipeline work on this one** — the geometry-exposure
      lever is real but caps out too small at fight distance to matter, the
      same shape of finding as the aobake result below.

      **A caution for the next measurement, since this run hit three
      different false negatives before getting a true reading and each one
      looked exactly like a real bug:** (1) creating a new Blender data layer
      (e.g. `mesh.vertex_colors.new()`) can silently invalidate an
      already-fetched reference to another layer on the same mesh — reads
      after that point return stale/zeroed data with no error, not an
      exception. Read everything you need from a layer BEFORE creating a new
      one, not after. (2) Blender's default Filmic view transform desaturates
      bright/saturated debug colours (a pure magenta debug flag rendered as a
      muted grey-pink, undercounting a real signal by roughly 40x in this
      session) — set `scene.view_settings.view_transform = "Standard"` for
      any render whose PIXELS are being measured, not just judged by eye.
      (3) `screenshot.gd`'s `orbit=` flag only calls `_apply_orbit`, which
      only exists on the overworld view — it silently no-ops on Combat3D, so
      "orbiting the fight camera" around a beast does nothing without also
      rotating `_beast` directly.

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
