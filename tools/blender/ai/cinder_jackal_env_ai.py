"""Rehaul the Cinder Jackal's arena with a generated wall, headless.

    blender -b --python tools/blender/ai/cinder_jackal_env_ai.py -- <meshy_wall.glb> [scale]

Nick, 2026-09-23 (answering the arena-wall-accent request): "the environment
needs a rehaul. use meshy to create an environment to replace the one created
in blender." The procedural wall (`tools/blender/env/cinder_jackal.py`,
`env.py`'s shared `enclose("cliff")`) is flat primitive slabs that read as a
generic quarry from every camera the fight actually uses — three passes of
recolouring it (`design/progress/cinder_jackal_ground.md`) made it warmer but
never gave it real silhouette, because primitives were never going to look
like broken rock no matter the palette.

This keeps the FLOOR exactly as it was — `env.py`'s `ground()`/`apron()` is
already correct, tested, and not what was flagged — and replaces only the
enclosing wall with a Meshy-generated crater rim: a real jagged silhouette
with ember cracks baked into its own texture, instead of a flat slab that
needs a colour trick to say "this is hot rock".

## The recipe

1. **Floor**, unchanged: `env.Env(seed=62).ground(UMBER, rim=CHARCOAL,
   dish=0.20)` + `.apron(CHARCOAL, out=2.50, drop=0.60)`, built to the
   project's fixed `RADIUS = 6.0` (every environment is built to this;
   `combat_3d._show_env` scales by `want_r / ENV_RADIUS` and can only do that
   arithmetic if every environment starts the same size).
2. **Wall**, generated: Meshy text-to-3d, prompted for an enclosed crater —
   "a small enclosed volcanic canyon arena: a flat cracked scorched rock
   clearing in the middle surrounded by a low ring of jagged charred cliff
   walls" — then refined with a texture prompt pulled from this ground's own
   palette (charcoal rock, umber-brown cracks, orange-rust embers, no
   snow/moss/green). Comes back as ONE ring-shaped mesh with an open middle —
   there is no floor in it, which is why the Env floor above still does that
   job.
3. **Clean and place the wall**: weld duplicates (Meshy ships triangle soup,
   same as every Rodin/Meshy creature so far), stand it on the floor (lowest
   vertex to z=0), decimate to ~9000 tris (this ground's old budget was 7400
   for 22 primitive pieces; a jagged generated ring earns a little more).
4. **Scale by the wall's own inner radius**, not by eye. `env.py`'s wall
   stood its inner face at `ENCLOSE_CLEAR * RADIUS = 2.55 * 6 = 15.3` — a
   number solved against `combat_3d.CAMERA_MAX_R` (2.40): the camera can
   reach `arena_r * 2.40`, and because both the beast's `arena_r` and this
   environment get the SAME `want_r/6.0` scale, standing geometry has to sit
   outside `6.0 * 2.40 = 14.4` local units to be safe for any beast, ever, not
   just this one. Target 15.5 keeps the same margin the procedural wall used.
5. **Combine**, not join: Floor and Wall are exported as two separate mesh
   objects, not one merged mesh. combat_3d.gd's `_shade_model` shades every
   `MeshInstance3D` it finds independently, picking up each one's own texture
   as its "atlas" — joining them would force one shared texture onto both the
   Floor's palette-atlas UVs and the Wall's own baked photo-texture UVs, and
   whichever lost would render as noise.
6. **Export** `game/assets/3d/env/cinder_jackal_ai.glb`. The old
   `cinder_jackal.glb` stays untouched (same reason `cinder_jackal_ai.glb`
   sits beside `cinder_jackal.glb` in `cast/`): `ENV_AI_ART` in combat_3d.gd
   picks the new one, so `build.cmd env` can never silently put the old wall
   back, and reverting is one dictionary entry.

See `design/guide/ai-beast-recipe.md` for the sibling recipe this borrows its
CLEAR-check and weld/decimate steps from, and
`design/progress/cinder_jackal_ground.md` pass 5 for the scored result.
"""
import bpy, math, os, sys
from mathutils import Vector as V, Matrix

HERE = os.path.dirname(os.path.abspath(__file__))
BLENDER_DIR = os.path.dirname(HERE)
ROOT = os.path.normpath(os.path.join(BLENDER_DIR, "..", ".."))
sys.path.insert(0, BLENDER_DIR)
from env import Env
from kenney import UMBER, CHARCOAL

args = sys.argv[sys.argv.index("--") + 1:]
WALL_SRC = args[0]
SCALE_OVERRIDE = float(args[1]) if len(args) > 1 else None
OUT = os.path.join(ROOT, "game", "assets", "3d", "env", "cinder_jackal_ai.glb")
FLOOR_TMP = "/tmp/cinder_jackal_ai_floor.glb"

RADIUS = 6.0
TARGET_INNER = 15.5   # see step 4 above


def report(k, v):
    print("REPORT %s %s" % (k, v))


# ---------------------------------------------------------------- 1. floor
bpy.ops.wm.read_factory_settings(use_empty=True)
e = Env(seed=62)
e.ground(UMBER, rim=CHARCOAL, dish=0.20)
e.apron(CHARCOAL, out=2.50, drop=0.60)
e.done(FLOOR_TMP, name="Floor")

# ---------------------------------------------------------------- 2/3/4. wall
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=WALL_SRC)
meshes = [o for o in bpy.data.objects if o.type == "MESH"]
if len(meshes) > 1:
    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
wall = [o for o in bpy.data.objects if o.type == "MESH"][0]
wall.name = "Wall"
me = wall.data
me.transform(wall.matrix_world)
wall.matrix_world = Matrix.Identity(4)

bpy.context.view_layer.objects.active = wall
wall.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.mesh.remove_doubles(threshold=0.0008)
bpy.ops.object.mode_set(mode="OBJECT")
report("wall_faces_raw", len(me.polygons))

verts = [v.co for v in me.vertices]
lo = V((min(c.x for c in verts), min(c.y for c in verts), min(c.z for c in verts)))
hi = V((max(c.x for c in verts), max(c.y for c in verts), max(c.z for c in verts)))
cx, cy = (lo.x + hi.x) / 2, (lo.y + hi.y) / 2
low_band = [c for c in verts if c.z < lo.z + 0.05 * (hi.z - lo.z)]
inner_r = min(math.hypot(c.x - cx, c.y - cy) for c in low_band) if low_band else 0.0
report("wall_measured_inner_radius", "%.4f" % inner_r)
report("wall_measured_height", "%.4f" % (hi.z - lo.z))

scale = SCALE_OVERRIDE if SCALE_OVERRIDE else (TARGET_INNER / max(inner_r, 1e-4))
me.transform(Matrix.Translation((-cx, -cy, -lo.z)))
me.transform(Matrix.Scale(scale, 4))
me.update()
report("wall_scale_applied", "%.4f" % scale)

if len(me.polygons) > 9500:
    m = wall.modifiers.new("dec", "DECIMATE")
    m.ratio = 9000 / len(me.polygons)
    bpy.ops.object.modifier_apply(modifier="dec")
report("wall_faces_final", len(me.polygons))

verts = [v.co for v in me.vertices]
d_lo = V((min(c.x for c in verts), min(c.y for c in verts), min(c.z for c in verts)))
d_hi = V((max(c.x for c in verts), max(c.y for c in verts), max(c.z for c in verts)))
report("wall_dims", "%.2f x %.2f x %.2f" % (d_hi.x - d_lo.x, d_hi.y - d_lo.y, d_hi.z - d_lo.z))

# Same rule env.py's own done() checks: nothing above 0.6*RADIUS may sit
# inside the CAMERA_MAX_R-derived clearance (see step 4's docstring).
tall = RADIUS * 0.6
near = min((math.hypot(c.x, c.y) for c in verts if c.z > tall), default=0.0)
clear = 2.55 * RADIUS
if near and near < clear:
    print("WARNING: standing geometry at %.2f, inside the %.2f clearance "
          "CAMERA_MAX_R relies on." % (near, clear))
else:
    print("CLEAR wall keeps tall geometry outside %.2f (nearest %.2f)" % (clear, near))

# ---------------------------------------------------------------- 5/6. combine
bpy.ops.import_scene.gltf(filepath=FLOOR_TMP)
for o in bpy.data.objects:
    if o.type == "MESH" and o.name != "Wall":
        o.name = "Floor"

bpy.ops.object.select_all(action="DESELECT")
for o in bpy.data.objects:
    if o.type == "MESH":
        o.select_set(True)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
bpy.ops.export_scene.gltf(filepath=OUT, use_selection=True, export_format="GLB")
report("exported", OUT)

os.makedirs(HERE, exist_ok=True)
bpy.ops.file.pack_all()
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(HERE, "cinder_jackal_env_ai.blend"), compress=True)
report("blend_saved", os.path.join(HERE, "cinder_jackal_env_ai.blend"))
