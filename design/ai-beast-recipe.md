# AI beast recipe — the cinder_jackal template (2026-09-22)

The Python-primitive beasts (`tools/blender/<beast>.py`) hit a ceiling: agent
modelling from code is fine for blockouts, props and collision, and fails for
organic creatures. The research that led here is summarised in the session of
2026-09-22; the short version is **generate the creature, clean it, keep code
for the gameplay parts (climb points, footing).**

`cinder_jackal` is the first beast done this way and is the template.

| file | what |
|---|---|
| `game/assets/3d/cast/cinder_jackal_ai.glb` | the shipped model (+ extracted textures beside it) |
| `tools/blender/ai/cinder_jackal_ai.blend` | the cleaned, editable source — open this to fix anything |
| `game/assets/3d/toon.gdshader` | toon ramp for textured models: 3 hard bands, cool shadow colour, hard rim, glow on hot-orange texels |
| `game/assets/3d/outline.gdshader` | inverted-hull outline, `next_pass` of the toon material |
| `combat_3d.gd` `AI_ART` | beasts listed here load `<id><suffix>.glb` and shade with the toon shader |

The Python model is untouched (`cinder_jackal.glb`), so `build.cmd cast` can
never silently put the old one back. To see it: harness `classic`.

## The steps

1. **Generate.** blender-mcp → Hyper3D Rodin (free trial key) text-to-3D.
   Describe the creature from its design docstring, plus *"hand-painted
   stylized game art"*. Expect to throw away attempts: of two, one had a good
   body with extra legs and a giant ear; the other grew wings and came out
   stocky. **Image-to-3D from a clean concept image is the better input** —
   try it for the next beast.
2. **Orient and scale.** Head to Blender **-Y** (glTF +Z, toward the hunters),
   feet at z=0, centred, height to the old model's (3.06 here). Use
   `mesh.transform(Matrix.Rotation(...))` — `bpy.ops.object.transform_apply`
   silently did nothing when driven over MCP.
3. **Weld, then drop loose parts.** Rodin output is triangle soup (3,000+
   islands). `remove_doubles(dist=0.004)` joins it; after that, every island
   but the biggest is junk — here the two splayed extra legs.
4. **Cut artifacts by bounding region**, then drop anything cut loose, then
   `holes_fill(sides=80)` + `recalc_face_normals`. (The jackal's giant ear:
   `x>1.2 and z>2.15`, then a stub at `x>1.3 and z>1.8 and y<0.5`.)
5. **Decimate to ~10k faces** (`DECIMATE`, ratio = 10000 / faces).
6. **Climb route on the CAMERA side, with grown footholds.** Hunters approach
   from the front (+Z in glTF, -Y in Blender) and the camera sits behind them,
   so a route anywhere else is climbed out of sight — the jackal's first route
   (up the tail) put the whole climb behind the beast and the sigil behind its
   ears. A creature's front is legs and chest: nothing there faces up. So grow
   the footing: a separate `Footholds` mesh of flat-topped basalt outcrops
   (flattened icospheres, jagged underside, one flat colour material),
   sunk ~0.15 into the surface you find by raycasting from the side, one per
   Height. `climb_N` / `ledge_N` sit on each top +0.02; the sigil (`climb_5`)
   on the forehead, found by raycasting down. The jackal's: front-left foreleg
   ×2 → shoulder → withers → brow.
7. **Export** mesh + empties (`use_selection`), add the id to `AI_ART`,
   `--import`, run tests.

## Verifying

```
tools\shot.cmd out=C:\shot.png state=3d beast=cinder_jackal wide
tools\shot.cmd out=C:\shot.png state=3d beast=cinder_jackal wide classic
tools\shot.cmd out=C:\shot.png state=3dclimb beast=cinder_jackal
```

Always through `tools\shot.cmd` (second monitor, no focus steal). Blender's
viewport stops redrawing once its window is moved off-screen — render stills
to files with a scene camera instead of `get_viewport_screenshot`.

## Everywhere the beast appears

- **Fight** — `combat_3d.AI_ART` + `AI_MOTION` (idle life, below).
- **Reward screen** (the felled body) — `location_3d._lay_out_the_felled` reads
  the same table and calls `combat_3d.toon_all`. A long AI model tipped onto
  its back stands up on its tail, so these roll onto their flank instead; roll
  the side that puts a curled tail UP, or it props the body off the ground.
- **Portrait** — `portraits.py` has its own `AI_ART`; renders with specular
  off (studio gloss turns painted fur into wet plastic; FLAT washes it out).
  `blender -b --python tools/blender/portraits.py -- <out> cinder_jackal`,
  then copy into `game/assets/portraits/`.

## Idle life (no rig)

`toon.gdshader` moves the vertices itself: a tail sweep (masked by model-space
X/Z, lagged along its length so it whips), breathing along the normal above
`breath_min_y`, and a pulse on the ember glow. `outline.gdshader` carries an
identical copy so the ink rides the moving tail. Per beast in
`combat_3d.AI_MOTION`; the masks default to the jackal. Check a new beast's
mask in Blender first (glTF x = Blender x, y = Blender z, z = -Blender y) — it
must catch the tail and nothing that touches the ground.

## Not done yet

- **No rig.** Idle life is shader-only; attacks and hits still move the whole
  body. A Rigify quadruped (or Tripo's auto-rig) is the next step.
- The texture carries the ember glow now; the palette-UV `EMBERS` entry for
  this beast is skipped under the toon shader.
- Footprint is much wider than the Python model (tail sweep), so the arena
  camera frames it bigger. Looks right; watch it on other beasts.
