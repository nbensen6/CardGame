"""Mesh-topology hygiene check for a Meshy-built hunter/beast .glb: does the
raw remesh output have any part that is actually floating away from the
body, or is it just unwelded/coincident-vertex fragmentation (harmless)?

Walks the raw edge graph into connected components (same idea `frog_ai.md`
pass 2 used: 193 islands, checked silhouette-safe), then for every island
measures the minimum 3D distance from any of its vertices to the nearest
vertex in a DIFFERENT island (numpy, brute force -- a few thousand verts is
small enough). An island that touches/overlaps its neighbours has a min gap
of ~0; a real floating part has a gap that is a real fraction of the whole
model's own bounding-box diagonal. This is stronger than a silhouette check
alone (a part can hide behind another part in projection and still be
physically separated) and does not need Blender's own topology overlay.

    blender -b --python tools/blender/ai/mesh_gap_check.py -- <src.glb> [gap_frac_threshold]

Prints REPORT lines: total_verts, total_islands, body_diag, then, for
every island with verts>=3, only the ones whose nearest-other-island gap
exceeds the threshold (default 0.01 = 1% of the body diagonal) as
`gap_island_N verts=... min_gap_frac=... centre=(x,y,z)` -- those are the
ones worth opening the render and looking at. `islands_with_real_gap_total`
is the headline number: 0 means the fragmentation is cosmetic-only.
"""
import bpy, sys, collections
import numpy as np

args = sys.argv[sys.argv.index("--") + 1:]
SRC = args[0]
THRESH = float(args[1]) if len(args) > 1 else 0.01

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
me = body.data
me.transform(body.matrix_world)

n = len(me.vertices)
coords = np.array([tuple(v.co) for v in me.vertices], dtype=np.float32)

adj = collections.defaultdict(set)
for e in me.edges:
    a, b = e.vertices
    adj[a].add(b)
    adj[b].add(a)

seen = [False] * n
islands = []
for start in range(n):
    if seen[start]:
        continue
    stack = [start]
    seen[start] = True
    comp = [start]
    while stack:
        v = stack.pop()
        for w in adj[v]:
            if not seen[w]:
                seen[w] = True
                comp.append(w)
                stack.append(w)
    islands.append(comp)

lo = coords.min(axis=0)
hi = coords.max(axis=0)
diag = float(np.linalg.norm(hi - lo))
print("REPORT total_verts %d" % n)
print("REPORT total_islands %d" % len(islands))
print("REPORT body_diag %.4f" % diag)

islands.sort(key=len, reverse=True)
label = np.full(n, -1, dtype=np.int32)
for i, comp in enumerate(islands):
    label[comp] = i

CH = 500
nn_dist = np.full(n, np.inf, dtype=np.float32)
for s in range(0, n, CH):
    e = min(s + CH, n)
    d = np.linalg.norm(coords[s:e, None, :] - coords[None, :, :], axis=2)
    same = label[s:e, None] == label[None, :]
    d[same] = np.inf
    nn_dist[s:e] = d.min(axis=1)

flagged = [i for i, comp in enumerate(islands) if len(comp) >= 3 and float(nn_dist[comp].min()) / diag > THRESH]
print("REPORT islands_with_real_gap_total %d (of %d islands, verts>=3, threshold=%.3f)" % (len(flagged), len(islands), THRESH))
for i in flagged:
    comp = islands[i]
    g = float(nn_dist[comp].min()) / diag
    cen = coords[comp].mean(axis=0)
    print("REPORT gap_island_%d verts=%d min_gap_frac=%.5f centre=(%.3f,%.3f,%.3f)" % (i, len(comp), g, cen[0], cen[1], cen[2]))
