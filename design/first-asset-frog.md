# Your first asset: the Frog

A concrete first job, sized so you finish it. `blender-pipeline.md` is the full
contract; this is the one model to build and exactly how to get it on screen.

---

## Why the Frog

`blender-pipeline.md` says hunter → lesser beast → Titan, and never start with the
Titan. The Frog is the best of the hunters to start with:

- **Simplest silhouette.** A body, two eyes, four legs. No horns, no trunk, no shell.
- **Smallest on screen.** Hunters render at `HUNTER_HEIGHT`, roughly a sixth of the
  beast. Your first model's flaws will be about six pixels tall.
- **Reads correctly even when crude.** "Small round thing with big eyes and folded
  back legs" is unmistakably a frog at low poly. That's a very forgiving target.
- **It's currently a bunny.** The Frog stands in as Kenney's `bunny.glb`, so you'll
  see your model replace something and can compare directly.

---

## The five rules that actually matter

Everything else in `blender-pipeline.md` is handled by the code. These five are on you:

1. **Facing +Z.** The single thing that's genuinely annoying to fix later. In Blender's
   viewport that's the direction the green Y axis points *away* from you at default
   orientation — the exporter converts. Build the frog looking that way.
2. **Origin at the feet**, centred left-right. `Object → Set Origin → Origin to 3D
   Cursor` with the cursor on the floor between its feet. An origin in the middle makes
   it sink into the ground.
3. **Apply transforms before export** — `Ctrl+A → All Transforms`. The code measures the
   mesh's real bounds to scale it; unapplied scale makes those bounds lie.
4. **Export as .glb, +Y Up** (the glTF exporter's default), **textures embedded.**
   Embedding makes the external-texture gotcha impossible.
5. **Size doesn't matter.** Build at whatever's comfortable. `_fit_height` rescales it.

---

## Evening one: a grey frog in the game

**Do not texture anything tonight.** The risky part of a first asset is never the
modelling, it's the pipeline. Get an ugly grey blob standing next to a Titan, and
everything after that is just improving a thing that already works.

1. Cube → scale it wide and slightly flat. That's the body; a frog has no neck, so
   this is the head too.
2. Bevel the edges a touch (`Ctrl+B`). Low-poly reads better with a hint of bevel.
3. Two spheres on top-front for eyes. Bulging, larger than feels right — this is the
   whole silhouette at small scale.
4. Back legs: a box for the thigh, a box for the shin, **folded into a Z**. This is
   what makes it a frog rather than a lump. Give them more mass than seems sensible.
5. Front legs: two small thin boxes, angled forward.
6. Flat feet, splayed slightly.

Target **300–800 triangles**. The Kenney models standing in are in that range.

Then: set origin at the feet, apply transforms, export.

## Evening two: colour, the cheap way

Don't UV unwrap. Use the palette trick that makes the Kenney kits look consistent:

1. Make a tiny image — 16×16 is plenty — filled with flat colour swatches. For a frog:
   **green, paler belly green, white, black.**
2. Assign it as the material's base colour texture.
3. In the UV editor, select faces and drag their UVs onto the swatch they should be.
   Every face is a dot on a colour square. No unwrapping, no seams, no bleed.
4. Set the mesh to **flat shading** (`Object → Shade Flat`). The scene's lighting does
   the rest.

---

## Dropping it in

Save as `frog.glb` here:

```
game/assets/3d/cast/frog.glb
```

Then change one line in `views/combat_3d.gd`:

```gdscript
const MODELS := {
	"frog": "bunny",   ->   "frog": "frog",
```

That's the whole swap. No scaling, no repositioning, no camera work.

> **This is newly true for hunters.** Until 2026-08-15, `_spawn_hunter` ignored `MODELS`
> and picked a model by parsing the portrait *filename* — so editing the table did
> nothing for hunters. That's fixed: the snapshot now carries the character id and
> hunters read the same table the beasts do.

If Godot doesn't pick up a replaced file, delete `frog.glb.import` and run:

```bash
Godot_v4.7.1-stable_win64_console.exe --headless --path game --import
```

## Looking at it

```bash
Godot_v4.7.1-stable_win64_console.exe --path game --script res://tools/screenshot.gd -- out=C:/tmp/frog.png state=3d beast=stone_warden orbit=40
```

A window flashes for a couple of seconds and a PNG lands at `out=`. That's your model
at real scale, in real lighting, beside the real UI, in about thirty seconds. Use it
constantly — it's much faster than reasoning about whether something looks right.

`orbit=` is the camera yaw in degrees; try 0, 40, 90 to see it from several sides.

---

## What "good enough" looks like

Stop when it reads as a frog at hunter size and doesn't embarrass you next to the
Kenney beasts. It does **not** need to be better than them — it needs to be *yours*,
because a game built entirely from one free asset pack looks like one.

You'll rebuild this model. Everyone's first is replaced. The point of tonight is that
the pipeline works and you've seen your own art in your own game.

## What not to do yet

- **No rigging.** All motion is procedural — breathing, sway, recoil, climb scrabble.
  You can ship the entire game without ever rigging anything, and skipping it removes
  most of the Blender learning curve.
- **No Titan.** It's the most-looked-at model in the game. You want your third attempt
  at a beast there, not your first.
- **Not the Steam capsule.** That's marketing, not game art, and it's the one asset
  where recognisably-free work costs real wishlists. Worth commissioning even while
  you learn everything else.
