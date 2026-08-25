"""Same question, but MERGE first.

glTF splits every vertex on a UV seam, so a naive connected-faces walk sees a
Kenney bunny as 178 loose parts when it is really a handful of lumps. Merge by
distance and the real topology comes back.
"""
import bpy, bmesh, sys, math, os
from collections import Counter
from mathutils import Vector

paths = sys.argv[sys.argv.index("--") + 1:]


def merged(o):
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bm.normal_update()
    return bm


def parts(bm):
    seen, groups = set(), []
    for f in bm.faces:
        if f.index in seen: continue
        stack, g = [f], []
        seen.add(f.index)
        while stack:
            cur = stack.pop(); g.append(cur)
            for e in cur.edges:
                for nf in e.link_faces:
                    if nf.index not in seen:
                        seen.add(nf.index); stack.append(nf)
        groups.append(g)
    return groups


def profile(g):
    """Cross-section radius along the part's LONGEST axis, in 5 slices.

    A taper is the one thing our ball/slab/ring toolkit cannot say, so this is
    the measurement that decides whether the vocabulary needs to grow.
    """
    vs = list({v for f in g for v in f.verts})
    co = [v.co for v in vs]
    lo = Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
    hi = Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
    dims = hi - lo
    ax = max(range(3), key=lambda i: dims[i])
    if dims[ax] < 1e-6: return dims, ax, []
    other = [i for i in range(3) if i != ax]
    mid = [(lo[i] + hi[i]) / 2 for i in range(3)]
    bands = [[] for _ in range(5)]
    for c in co:
        t = (c[ax] - lo[ax]) / dims[ax]
        bands[min(4, int(t * 5))].append(
            math.hypot(c[other[0]] - mid[other[0]], c[other[1]] - mid[other[1]]))
    return dims, ax, [(max(b) if b else 0.0) for b in bands]


def classify(r):
    if not r or max(r) < 1e-6: return "?"
    m = max(r)
    n = [x / m for x in r]
    ends = (n[0] + n[4]) / 2
    if ends > 0.85: return "TUBE/BOX  "          # same width all the way
    if abs(n[0] - n[4]) > 0.35: return "TAPER     "  # one end fat, other thin
    if n[2] > 0.9 and ends < 0.6: return "ELLIPSOID "  # fat middle, thin ends
    return "shaped    "


for p in paths:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=p)
    ms = [o for o in bpy.data.objects if o.type == "MESH"]
    print("\n" + "=" * 72)
    print(os.path.basename(p))
    print("=" * 72)
    kinds = Counter(); allparts = []
    tot_t = 0; ang = Counter(); sm = fl = 0
    for o in ms:
        bm = merged(o)
        tot_t += sum(len(f.verts) - 2 for f in bm.faces)
        for f in bm.faces:
            if f.smooth: sm += 1
            else: fl += 1
        for e in bm.edges:
            if len(e.link_faces) != 2: continue
            a = math.degrees(e.calc_face_angle(0.0))
            ang["flat<5" if a < 5 else "soft5-25" if a < 25 else
                "bevel25-50" if a < 50 else "turn50-80" if a < 80 else "hard>80"] += 1
        for g in parts(bm):
            dims, ax, prof = profile(g)
            k = classify(prof)
            kinds[k] += 1
            allparts.append((o.name, sum(len(f.verts) - 2 for f in g), dims, k, prof))
        bm.free()
    print("objects %d  tris %d  smooth %d%%" % (len(ms), tot_t, 100 * sm // max(1, sm + fl)))
    print("edge angles: %s" % dict(ang))
    print("part shapes: %s" % dict(kinds))
    allparts.sort(key=lambda r: -r[1])
    for nm, t, d, k, prof in allparts[:16]:
        print("   %-18s tris %4d  %s dims %5.2f %5.2f %5.2f  profile %s"
              % (nm[:18], t, k, d.x, d.y, d.z, " ".join("%.2f" % x for x in prof)))
    if len(allparts) > 16: print("   ... %d more parts" % (len(allparts) - 16))
