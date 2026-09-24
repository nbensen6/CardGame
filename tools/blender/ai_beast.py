"""Turn a generated creature (Meshy .glb) into a game-ready beast, headless.

    blender -b --python tools/blender/ai_beast.py -- <beast_id> <meshy.glb> [--dry]

Everything that was done by hand to the Cinder Jackal on 2026-09-22, as one
repeatable pass, so the builder lane can run it without a live Blender:

  1. orient (head to Blender -Y), scale to the Python model's height, centre,
     feet on z=0, decimate to ~12k faces
  2. ANATOMY GATE: exactly four foot clusters, two either side, or it stops.
     Rodin's jackal had a tail standing in for a hind leg; nothing downstream
     can fix that, so do not build on it.
  3. climb markers up the near (+X, camera-side) side, heights taken from the
     Python model's own markers; the top marker is the sigil, on the head.
     NO footholds are modelled: combat_3d floats a stone at every climb point
     for every boss (Nick, 2026-09-23), so a beast that grows its own would
     have two.
  4. 20-bone rig from the measured feet and topline, region-gated weights
  5. idle / attack / hit actions
  6. export game/assets/3d/cast/<id>_ai.glb, save tools/blender/ai/<id>_ai.blend

Prints REPORT lines the builder reads back. --dry stops after the gate.
See design/guide/ai-beast-recipe.md.
"""
import bpy, bmesh, math, os, random, sys
from mathutils import Vector as V, Matrix

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route import route_direction, route_progress, keep_route_going

args = sys.argv[sys.argv.index("--") + 1:]
BID, SRC = args[0], args[1]
DRY = "--dry" in args
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
CAST = os.path.join(ROOT, "game", "assets", "3d", "cast")
R = math.radians


def report(k, v):
    print("REPORT %s %s" % (k, v))


def fail(why):
    report("FAIL", why)
    sys.exit(2)


# ---------------------------------------------------------------- reference
# Height and climb markers come from the Python-built model, so the new beast
# stands the same size in the arena and keeps the same ledges and sigil.
bpy.ops.wm.read_factory_settings(use_empty=True)
ref_h, ref_marks = 3.0, {}
py_glb = os.path.join(CAST, BID + ".glb")
if os.path.exists(py_glb):
    bpy.ops.import_scene.gltf(filepath=py_glb)
    co = [o.matrix_world @ v.co for o in bpy.data.objects if o.type == "MESH" for v in o.data.vertices]
    lo = min(c.z for c in co)
    ref_h = max(c.z for c in co) - lo
    for o in bpy.data.objects:
        if o.type == "EMPTY" and (o.name.startswith("climb_") or o.name.startswith("ledge_")):
            ref_marks[o.name] = (o.matrix_world.translation.z - lo) / ref_h
report("ref_height", "%.2f" % ref_h)
report("ref_markers", ",".join(sorted(ref_marks)) or "none")
if not any(k.startswith("climb_") for k in ref_marks):
    fail("no climb_ markers on %s.glb to copy the route from" % BID)

# ---------------------------------------------------------------- 1. import
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
meshes = [o for o in bpy.data.objects if o.type == "MESH"]
if len(meshes) > 1:
    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
body = [o for o in bpy.data.objects if o.type == "MESH"][0]
body.name = "Body"
for o in list(bpy.data.objects):
    if o is not body and o.type != "MESH":
        bpy.data.objects.remove(o)
me = body.data
me.transform(body.matrix_world)
body.parent = None
body.matrix_world = Matrix.Identity(4)

def verts():
    return [v.co for v in me.vertices]

def bounds():
    vs = verts()
    return (V([min(c[i] for c in vs) for i in range(3)]), V([max(c[i] for c in vs) for i in range(3)]))

# The long axis is the spine. Meshy has put it on Y every time so far; if it
# ever comes out on X, turn it.
lo, hi = bounds()
if hi.x - lo.x > hi.y - lo.y:
    me.transform(Matrix.Rotation(R(90), 4, "Z"))
# Head end: the ears/crest are the highest points and sit over the head.
vs = verts()
top = sorted(vs, key=lambda c: -c.z)[:80]
if sum(c.y for c in top) / len(top) > (bounds()[0].y + bounds()[1].y) / 2:
    me.transform(Matrix.Rotation(R(180), 4, "Z"))
lo, hi = bounds()
me.transform(Matrix.Translation(-V(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))))
me.transform(Matrix.Scale(ref_h / (hi.z - lo.z), 4))
me.update()
bpy.context.view_layer.objects.active = body
body.select_set(True)
if len(me.polygons) > 13000:
    m = body.modifiers.new("dec", "DECIMATE")
    m.ratio = 12000 / len(me.polygons)
    bpy.ops.object.modifier_apply(modifier="dec")
report("faces", len(me.polygons))
report("dims", "%.2f x %.2f x %.2f" % tuple(body.dimensions))

# ---------------------------------------------------------------- 2. gate
H = ref_h
feet_pts = [c for c in verts() if c.z < 0.08 * H]
clusters = []
for c in feet_pts:
    for g in clusters:
        if (g["c"] - c).length < 0.17 * H:
            g["p"].append(c)
            g["c"] = sum(g["p"], V()) / len(g["p"])
            break
    else:
        clusters.append({"c": c.copy(), "p": [c]})
feet = [g["c"] for g in clusters if len(g["p"]) >= 12]
report("feet", " ".join("(%.2f,%.2f)" % (f.x, f.y) for f in feet))
if len(feet) != 4:
    fail("anatomy: %d feet on the ground, need exactly 4" % len(feet))
front = sorted(feet, key=lambda f: f.y)[:2]
hind = sorted(feet, key=lambda f: f.y)[2:]
for pair, name in ((front, "front"), (hind, "hind")):
    if not (pair[0].x * pair[1].x < 0):
        fail("anatomy: both %s feet on the same side" % name)
report("gate", "PASS four feet, two per side")
if DRY:
    sys.exit(0)

# topline: middle height of the body at a given y, for bone placement
def mid_z(y, band=0.25):
    zs = [c.z for c in verts() if abs(c.x) < 0.1 * H and abs(c.y - y) < band and c.z > 0.4 * H]
    return (max(zs) + min(zs)) / 2 if zs else 0.62 * H

y_front = sum(f.y for f in front) / 2
y_hind = sum(f.y for f in hind) / 2
lo, hi = bounds()

# ---------------------------------------------------------------- 3. footholds
random.seed(hash(BID) & 0xFFFF)
climbs = sorted((k for k in ref_marks if k.startswith("climb_")), key=lambda k: int(k.split("_")[1]))
top_i = int(climbs[-1].split("_")[1])
near_front = max(front, key=lambda f: f.x)   # the camera-side foreleg

def side_x(y, z):
    xs = []
    for dz in (-0.03 * H, 0.0):
        ok, loc, n, _ = body.ray_cast(V((hi.x + 5, y, z + dz)), V((-1, 0, 0)))
        if ok:
            xs.append(loc.x)
    return max(xs) if xs else None

bm = bmesh.new()
marks = {}
MIN_ROUTE_STEP = 0.03 * H   # see route.py: real progress, not zigzag noise


def _prev_xy(k, back):
    """The (x, y) of the rung `back` positions below `k` in the climb, or
    None if the climb hasn't placed that many rungs yet."""
    j = climbs.index(k) - back
    if j < 0:
        return None
    p = marks.get(climbs[j])
    return None if p is None else (p.x, p.y)


for k in climbs:
    i = int(k.split("_")[1])
    z = ref_marks[k] * H
    if i == 0:
        marks[k] = V((near_front.x + 0.18 * H, near_front.y, 0.0))
        continue
    if i == top_i:
        # the sigil: on top of the head, found by raycasting down. Every
        # upward-facing candidate in the sweep is collected first -- not
        # just the one nearest the nose, which is how this used to reverse
        # the whole climb back past the haunch to reach the head (Nick,
        # 2026-09-23) -- and the one that best continues the direction the
        # rest of the climb already established wins. Swept further back
        # than a bare head-hunt needs (0.85*H past the nose, was 0.55*H) so
        # a real continuing surface has room to be found instead of only
        # ever the tip of the snout. keep_route_going is still the final
        # guarantee: if nothing the raycast found reaches far enough, the
        # pick is nudged forward exactly like a middle rung's would be. See
        # route.py.
        candidates = []
        for y in [lo.y + t * 0.05 * H for t in range(2, 18)]:
            ok, loc, n, _ = body.ray_cast(V((0, y, hi.z + 5)), V((0, 0, -1)))
            if ok and n.z > 0.6:
                candidates.append(loc)
        if not candidates:
            fail("no upward-facing head surface for the sigil")
        p2, p1 = _prev_xy(k, 2), _prev_xy(k, 1)
        direction = route_direction(p2, p1)
        if p1 is not None and direction != (0.0, 0.0):
            best = max(candidates, key=lambda c: route_progress(p1, (c.x, c.y), direction))
        else:
            best = candidates[0]
        bx, by = keep_route_going(p2, p1, (best.x, best.y), MIN_ROUTE_STEP)
        if (bx, by) == (best.x, best.y):
            marks[k] = best   # the raycast's own point already continued the route
        else:
            # keep_route_going moved the pick past every real candidate -- put
            # it back ON the body with one more raycast at the corrected (x,
            # y) rather than keeping the old candidate's z, which belongs to
            # a different point on the surface.
            ok, loc, n, _ = body.ray_cast(V((bx, by, hi.z + 5)), V((0, 0, -1)))
            marks[k] = loc if ok else V((bx, by, best.z))
        continue
    # A leg slants, so its foot is not under its knee: sweep along Y from the
    # foot back toward the chest and take the most outward surface at this
    # height (the leg, or higher up, the shoulder).
    best = None
    for t in range(0, 16):
        y = near_front.y - 0.05 * H + t * 0.03 * H
        sx = side_x(y, z)
        if sx is not None and sx > 0 and (best is None or sx > best[1] + 0.01 * H):
            best = (y, sx)
    if best is None:
        fail("no body surface on the near side at climb height %.2f" % z)
    y, sx = best
    # alternate a little either side so the route zigzags instead of stacking
    y += 0.03 * H if i % 2 else -0.03 * H
    r = 0.105 * H   # ponytail: kept only to place the marker; no mesh is built
    # Never let this rung double back past the one below it (route.py).
    px, py = keep_route_going(_prev_xy(k, 2), _prev_xy(k, 1), (sx + r * 0.55, y), MIN_ROUTE_STEP)
    p = V((px, py, z))
    marks[k] = p
    if True:   # stones float in-engine now; no foothold geometry is exported
        continue
    ret = bmesh.ops.create_icosphere(bm, subdivisions=2, radius=1.0)
    vs2 = ret["verts"]
    for v in vs2:
        c = v.co
        nn = 1.0 + random.uniform(-0.12, 0.12)
        c.x *= r * nn * 1.1
        c.y *= r * nn * 0.85
        c.z = 0.0 if c.z > 0 else c.z * 0.22 * (1.0 + random.uniform(0, 0.8))
    bmesh.ops.transform(bm, matrix=Matrix.Rotation(random.uniform(0, math.pi), 4, "Z"), verts=vs2)
    bmesh.ops.translate(bm, vec=p, verts=vs2)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)
fme = bpy.data.meshes.new("Footholds")
bm.to_mesh(fme)
bm.free()
for p in fme.polygons:
    p.use_smooth = False
mat = bpy.data.materials.new("Basalt")
mat.use_nodes = True
mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.07, 0.055, 0.05, 1)
fme.materials.append(mat)
footholds = bpy.data.objects.new("Footholds", fme)
bpy.context.scene.collection.objects.link(footholds)
for k in ref_marks:
    base = "climb_" + k.split("_")[1]
    if base in marks:
        e = bpy.data.objects.new(k, None)
        bpy.context.scene.collection.objects.link(e)
        e.location = marks[base] + V((0, 0, 0.02))
report("markers", " ".join("%s@%.2f" % (k, marks[k].z) for k in climbs))

# ---------------------------------------------------------------- 4. rig
arm = bpy.data.armatures.new("Rig")
rig = bpy.data.objects.new("Rig", arm)
bpy.context.scene.collection.objects.link(rig)
bpy.ops.object.select_all(action="DESELECT")
bpy.context.view_layer.objects.active = rig
rig.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
B = {}

def bone(n, h, t, p=None, deform=True):
    b = arm.edit_bones.new(n)
    b.head, b.tail, b.use_deform = V(h), V(t), deform
    if p:
        b.parent = arm.edit_bones[p]
        b.use_connect = (V(h) - arm.edit_bones[p].tail).length < 1e-4
    B[n] = (V(h), V(t))

yh, yc = y_hind + 0.05 * H, y_front + 0.08 * H
y_neck = y_front - 0.15 * H
y_head = lo.y + 0.12 * H
bone("root", (0, 0, 0), (0, -0.2 * H, 0), None, False)
bone("hips", (0, yh, mid_z(yh)), (0, (yh + yc) / 2, mid_z((yh + yc) / 2)), "root")
bone("spine", B["hips"][1], (0, yc, mid_z(yc)), "hips")
bone("chest", B["spine"][1], (0, y_neck, mid_z(y_neck)), "spine")
bone("neck", B["chest"][1], (0, (y_neck + y_head) / 2 + 0.05 * H, mid_z(y_neck) + 0.12 * H), "chest")
bone("head", B["neck"][1], (0, lo.y + 0.02 * H, mid_z(lo.y + 0.1 * H, 0.15)), "neck")
tail_pts = [V((0, yh + 0.05 * H, mid_z(yh)))]
for t in (0.33, 0.66, 1.0):
    y = yh + (hi.y - yh) * t
    zs = [c.z for c in verts() if abs(c.y - y) < 0.06 * H and abs(c.x) < 0.2 * H]
    tail_pts.append(V((0, y - (0.03 * H if t == 1.0 else 0), (max(zs) + min(zs)) / 2 if zs else tail_pts[-1].z)))
for i in range(3):
    bone("tail%d" % (i + 1), tail_pts[i], tail_pts[i + 1], "hips" if i == 0 else "tail%d" % i)
legs = {}
for f in feet:
    k = ("f" if f in front else "h") + ("l" if f.x > 0 else "r")
    top_z = mid_z(f.y) - 0.08 * H
    hock = 0.17 * H if k[0] == "h" else 0.0   # canine hind leg bends back
    pts = [V((f.x * 0.6, f.y, top_z)),
           V((f.x * 0.8, f.y - hock * 0.6, top_z * 0.62)),
           V((f.x * 0.92, f.y + hock, top_z * 0.25)),
           V((f.x, f.y - 0.1 * H, 0.01))]
    par = "chest" if k[0] == "f" else "hips"
    bone(k + "_upper", pts[0], pts[1], par)
    bone(k + "_lower", pts[1], pts[2], k + "_upper")
    bone(k + "_foot", pts[2], pts[3], k + "_lower")
    legs[k] = par
bpy.ops.object.mode_set(mode="OBJECT")

def segd(p, a, b):
    ab = b - a
    t = max(0, min(1, (p - a).dot(ab) / ab.length_squared))
    return (p - (a + ab * t)).length

groups = {n: body.vertex_groups.new(name=n) for n in B if n != "root"}
spine = ["hips", "spine", "chest", "neck", "head"]
tail = ["tail1", "tail2", "tail3"]
for v in me.vertices:
    p = v.co
    cands = spine
    if p.z < 0.5 * H:
        best = min(legs, key=lambda k: min(segd(p, *B[k + s]) for s in ("_upper", "_lower", "_foot")))
        if min(segd(p, *B[best + s]) for s in ("_upper", "_lower", "_foot")) < 0.13 * H:
            cands = [best + "_upper", best + "_lower", best + "_foot"] + ([legs[best]] if p.z > 0.4 * H else [])
    if cands is spine and p.y > yh + 0.1 * H and p.z > 0.3 * H:
        cands = tail + ["hips"]
    ds = sorted((segd(p, *B[n]), n) for n in cands)[:3]
    ws = [(1.0 / (d ** 4 + 1e-4), n) for d, n in ds]
    tot = sum(w for w, _ in ws)
    for w, n in ws:
        if w / tot > 0.02:
            groups[n].add([v.index], w / tot, "REPLACE")
mod = body.modifiers.new("Armature", "ARMATURE")
mod.object = rig
body.parent = rig
report("rig", "%d bones" % len(arm.bones))

# ---------------------------------------------------------------- 5. actions
pb = rig.pose.bones
rig.animation_data_create()
bpy.context.scene.render.fps = 30

def rest():
    for b in pb:
        b.rotation_mode = "XYZ"
        b.rotation_euler = (0, 0, 0)

def make(name, frames):
    act = bpy.data.actions.new(name)
    rig.animation_data.action = act
    for f, pose in frames:
        rest()
        for n, (x, y, z) in pose.items():
            pb[n].rotation_euler = (R(x), R(y), R(z))
        for b in pb:
            b.keyframe_insert("rotation_euler", frame=f)
    tr = rig.animation_data.nla_tracks.new()
    tr.name = name
    tr.strips.new(name, 0, act)
    rig.animation_data.action = None

idle = []
for f in range(0, 121, 10):
    t = f / 120 * 2 * math.pi
    p = {"chest": (math.sin(t * 2) * 1.0, 0, 0), "spine": (-math.sin(t * 2) * 0.5, 0, 0),
         "neck": (math.sin(t) * 3, 0, math.sin(t) * 4), "head": (math.sin(t + 1) * 3, 0, math.sin(t + 0.6) * 7)}
    for i in (1, 2, 3):
        p["tail%d" % i] = (math.sin(t * 2 - i * 0.5) * 4, 0, math.sin(t - i * 0.55) * (8 + i * 3))
    idle.append((f, p))
make("idle", idle)
# The near foreleg (the ledge leg) never moves: hunters are standing on it.
far_f = "fr" if "fr" in legs else "fl"
make("attack", [(0, {}),
                (10, {"neck": (-18, 0, 0), "head": (-12, 0, 0), "chest": (-3, 0, 0), "tail1": (12, 0, 0), far_f + "_upper": (6, 0, 0)}),
                (16, {"neck": (26, 0, 0), "head": (22, 0, 0), "chest": (5, 0, 0), "tail1": (-6, 0, 0), far_f + "_upper": (-8, 0, 0)}),
                (20, {"neck": (22, 0, 0), "head": (8, 0, 0), "chest": (4, 0, 0)}),
                (24, {"neck": (26, 0, 0), "head": (22, 0, 0), "chest": (5, 0, 0)}),
                (40, {})])
make("hit", [(0, {}),
             (4, {"neck": (-22, 0, -10), "head": (-18, 0, -12), "chest": (-5, 0, 0), "tail1": (14, 0, 8), "tail2": (10, 0, 10)}),
             (10, {"neck": (-6, 0, 8), "head": (-4, 0, 10), "tail1": (4, 0, -6)}),
             (20, {})])
rest()
bpy.context.scene.frame_set(0)

# ---------------------------------------------------------------- 6. export
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.data.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = rig
out = os.path.join(CAST, BID + "_ai.glb")
bpy.ops.export_scene.gltf(filepath=out, use_selection=True, export_format="GLB",
                          export_animations=True, export_animation_mode="ACTIONS",
                          export_skins=True, export_force_sampling=True, export_frame_range=False)
os.makedirs(os.path.join(HERE, "ai"), exist_ok=True)
bpy.ops.file.pack_all()
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(HERE, "ai", BID + "_ai.blend"), compress=True)
report("exported", out)
