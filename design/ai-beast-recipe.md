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
6. **Climb points — code, not guesswork.** Raycast straight down on a 0.1
   grid, keep hits with `normal.z > 0.55`: that is every patch a hunter can
   actually stand on. Pick one per Height near the old marker heights (0.19,
   0.97, 1.36, 1.75, 2.1, sigil 2.56) and put `climb_N` / `ledge_N` empties
   there, +0.02 up. On the jackal the standable route is **tail tip → tail →
   hips → back → nape (sigil)**, which is also the route a player would want.
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

## Not done yet

- **No rig.** The beast is a static mesh, same as the Python ones — nothing in
  combat animates bones today, so this is not a regression, but it is the next
  quality step (Rigify quadruped, or Tripo's auto-rig).
- **Select screen and portrait** still show the Python jackal
  (`location_3d.gd`, `portraits.py`).
- The texture carries the ember glow now; the palette-UV `EMBERS` entry for
  this beast is skipped under the toon shader.
- Footprint is much wider than the Python model (tail sweep), so the arena
  camera frames it bigger. Looks right; watch it on other beasts.
