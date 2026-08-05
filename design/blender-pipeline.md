# Making the art yourself — the Blender pipeline

> Nick, 2026-08-05: chose **learn Blender** over commissioning or style-locking on
> Kenney.

This is the contract between your models and the game: what the code guarantees,
what it needs from you, and what it can't do for you. The short version is that
the game is built to take whatever you make — you should not be reverse-
engineering someone else's units.

## What the code already handles, so you don't have to

These aren't promises for later; they're how it works today.

| You might worry about | The code does this |
|---|---|
| "How big should I build it?" | **Any size.** Models are scaled to a target *world height*, measured off the mesh's own bounds (`_fit_height`). Build at whatever scale is comfortable. |
| "How tall should a Titan be vs. a small beast?" | Not your call — it's **derived from `weak_point_height`**, so a beast you climb 8 holds up is automatically taller than one you hit from the ground. |
| "Where do the hunters stand on it?" | Computed from the beast's **merged AABB** — they flank it on the ground, cling to its flank, and stand on the sigil, whatever shape it is. |
| "Where does the weak point go?" | Placed from the same bounds, high on the back. |
| "Will the camera frame it?" | Yes — distance and pivot come from the model's measured height, at any orbit angle. |
| "Does it need an idle animation?" | **No.** All motion is procedural: breathing, sway, recoil, climb hops, the death of a static prop. See below. |

So the minimum viable contribution is **one mesh, correct orientation, exported
as .glb**. Everything else is inferred.

## The spec

- **Format:** glTF 2.0 binary (`.glb`). Blender exports this natively.
- **Up axis:** Y-up. In Blender's glTF exporter this is the default (`+Y Up`
  checked) — Blender works Z-up internally and converts on export.
- **Facing:** **+Z**. The code turns hunters to face the beast and rotates them
  onto its flanks assuming forward is +Z; a model built facing -Z will appear
  back-to-front. (This is the one thing that is genuinely annoying to fix later,
  so get it right at the start.)
- **Origin:** at the **feet**, centred left-right. Models are positioned by their
  base — an origin at the mesh's centre makes it sink into the ground.
- **Scale:** anything. Apply your transforms before export (`Ctrl+A → All
  Transforms`) so the mesh bounds are real.
- **Textures:** either embed them in the .glb, **or** follow Kenney's pattern and
  ship a `Textures/` folder beside the .glb. See the gotcha below — it has bitten
  this project twice.
- **Rig:** not needed, and currently not used at all.

## Where files go, and how to swap one in

```
game/assets/3d/cast/<name>.glb    hunters and beasts
game/assets/3d/hex/<name>.glb     overworld tiles and landmarks
```

Then one line in `views/combat_3d.gd`'s `MODELS` table maps a character or beast
id to a file stem:

```gdscript
"stone_warden": "elephant",   ->   "stone_warden": "warden",
```

That is the entire swap. Drop `warden.glb` in `cast/`, change the string, done —
no scaling, no repositioning, no camera work.

The overworld's landmark tiles work the same way via `NODE_TILE` in
`views/overworld_3d.gd`.

## Gotchas that have already cost time here

1. **External textures.** Kenney's .glb files reference `Textures/colormap.png`
   *relative to the .glb*. Copy the model without that folder and everything
   renders white. If you export with textures embedded, this can't happen — which
   is the safer default for your own work.
2. **Godot caches imports.** Replacing a `.glb` in place doesn't always reimport.
   Delete the matching `.glb.import` and run:
   ```
   Godot_v4.7.1-stable_win64_console.exe --headless --path game --import
   ```
   A large import pass can take a few minutes — that's normal, not a hang.
3. **`.import` files are gitignored**, so your editor regenerates them on open.
4. **Check it by looking at it.** Every visual change in this project is verified
   with `tools/screenshot.gd`. For a new beast:
   ```
   Godot_v4.7.1-stable_win64_console.exe --path game --script res://tools/screenshot.gd -- out=C:/tmp/shot.png state=3d beast=stone_warden orbit=90
   ```

## Animation: why there is none, and what that means for you

Every moving thing in the fight is driven procedurally from `_process` —
breathing, out-of-phase idle sway, recoil on a hit, hunters scrabbling harder as
their grip runs out. That was a deliberate choice when the models were static
props, and it has a real consequence for your learning path:

**You can ship the whole game without ever rigging anything.** Modelling and
texturing alone is a much smaller skill to acquire than modelling + UV + rigging
+ weight painting + animation, and it's the part that would actually change how
the game looks.

If you later *do* want real animation, the procedural layer is additive — a rig
would replace the idle sway, not fight it.

## A realistic path into Blender for this specific style

The style the game wants is **low-poly, flat-shaded, palette-textured** — the
same family as the Kenney kits currently standing in. That is genuinely one of
the friendliest places to start, because it rewards *shape* and hides detail work
you haven't learned yet.

1. **Box modelling fundamentals** — extrude, loop cut, bevel. A Cube Pets-style
   animal is a handful of boxes; you can rebuild one in an evening as practice.
2. **The palette-texture trick** — instead of UV-unwrapping properly, make one
   small image of colour swatches and point every face's UV at the right swatch.
   This is exactly what Kenney's `colormap.png` is, and it's why those models look
   consistent. It sidesteps the hardest part of texturing entirely.
3. **Flat shading + a good three-point light** does most of the visual work. The
   scene already provides the lighting.
4. **Export early, look at it in-game often.** The screenshot harness means you
   can see a model in real lighting, at real scale, beside the real UI, in about
   thirty seconds.

Order I'd suggest building things: **one hunter** (small, you'll iterate most),
then **one lesser beast**, then a **Titan**. Do not start with the Titan — it's
the most visible model and you'll want your third attempt at a beast, not your
first.

## What this doesn't cover — and the one thing not to defer

Art direction is more than models: UI, cards, fonts, the Steam capsule. The
capsule especially is **marketing, not game art**, and it's the single asset
where recognisably-free art costs real wishlists. That one is worth commissioning
even while you learn everything else.
