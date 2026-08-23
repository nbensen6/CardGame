# Learning Blender, aimed at this game

> Nick, 2026-08-22: chose to learn Blender and build his own style rather than
> commission or buy a pack.
>
> `blender-pipeline.md` is the technical contract. `first-asset-frog.md` is the
> first model. **This** is the learning path and the loop that makes it fast.

## Why this is a more reasonable plan than it sounds

The style this game already wears is **low-poly** — Kenney's bunny is **575
triangles**. That matters more than anything else here:

- Low-poly is the most forgiving 3D style to learn. No sculpting, no retopology,
  no UV unwrapping nightmares, no PBR texturing. Boxes, spheres, and flat colours.
- Your models render **small**. A hunter is about a sixth of the beast's height;
  early flaws are a few pixels tall.
- The game measures and scales whatever you give it, so there is no "correct
  size" to get wrong.

You are not learning Blender. You are learning **one narrow slice of Blender**:
box-modelling a stylised creature and exporting it. That is a genuinely
achievable evenings-and-weekends skill.

## The loop that makes this fast

The usual beginner tax is not knowing whether an export is right until it looks
wrong in-game, then guessing which of five rules you broke. Two tools remove it.

**1. Check the file before it goes anywhere:**

```
Godot_v4.7.1-stable_win64_console.exe --headless --path game \
  --script res://tools/assetcheck.gd -- file=frog.glb
```

It reads the mesh and tells you, per rule, what passed and what to do about what
didn't — origin at the feet, transforms applied, facing, poly count — and prints
the working Kenney bunny beside it to compare against.

**2. Your art wins automatically.** Export to
`game/assets/3d/cast/<character>.glb` — `frog.glb`, `vine_weaver.glb`,
`mountain_climbers.glb`, `goblin_mech.glb` — and the game uses it everywhere:
the fight, the campfire, the overworld. No code change (`ui/cast.gd`). Delete the
file and the placeholder comes back, so you can always compare.

**3. Ask Claude to put it on screen.** Say "screenshot my frog in a fight" and
you get it at real size, in real lighting, next to a Titan, in under a minute.
Judging a model in Blender's viewport is not the same as judging it in the game.

## What to learn, in order

Do not do a 12-hour "Blender for beginners" course. Learn these, in this order,
and stop when the frog is done.

1. **Navigation and the basics** — orbit, pan, zoom, and the difference between
   Object and Edit mode. (~1 hour)
2. **Box modelling** — add a cube, extrude, loop cut, bevel, mirror modifier.
   The mirror modifier is the single biggest win for creatures: build half, get
   the other half free, and it is symmetric by construction. (~2 hours)
3. **Flat-colour materials** — one material per colour, no textures. This is how
   Kenney's models work and it is why they read cleanly at small sizes. (~30 min)
4. **Origin, transforms, and glTF export** — the five rules in
   `first-asset-frog.md`. (~30 min, and `assetcheck.gd` marks your homework)

That is roughly **four hours before your first model is in the game**, not four
weeks. Everything after that is practice and taste.

## The order to build things

From `blender-pipeline.md`: hunter -> lesser beast -> Titan. Never start with a
Titan.

1. **The Frog** (see `first-asset-frog.md`) — simplest silhouette, currently a
   bunny, so you can compare directly.
2. **The other three hunters** — by then you are repeating a process you know.
3. **One lesser beast** — bigger, but the same skills. The Crag Pup.
4. **A Titan** — only once the rest look like a set.

## The thing worth knowing early

**Capsule art can be a Blender render.** Plenty of indie games pose their models
in a scene, light it, and render the Steam capsule straight out of Blender. That
means this path also unblocks the Steam page — you do not need to separately
learn 2D illustration.

It also means the four hunters plus one beast is not just "some assets", it is
**the shot**. Keep that in mind while you build: they will need to stand together
in one frame and read at thumbnail size.

## The honest trade

Commissioning or buying a pack puts a Steam page up in weeks. This path is
months. You have chosen months in exchange for the game looking like *yours*,
which is a legitimate trade and the main reason small games get noticed at all.

The risk to manage is not skill, it is stall: an unfinished art pass blocks the
page, the page blocks wishlists, and wishlists take months of their own. So the
one rule worth holding is **finish the Frog before starting anything else**, even
if it is ugly. A finished ugly frog can be improved. A half-built beautiful
Titan blocks everything behind it.
