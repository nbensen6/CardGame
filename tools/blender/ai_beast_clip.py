"""Add a clip to a beast ai_beast.py already built, and re-export it, headless.

    python3 tools/blender/ai_beast_clip.py <beast_id> death      (pip bpy)
    blender -b --python tools/blender/ai_beast_clip.py -- <beast_id> death

ai_beast.py needs the Meshy source, which is not kept; this opens its saved
tools/blender/ai/<id>_ai.blend instead, keys the clip from beast_clips.py the
same way ai_beast.py's make() does, and writes game/assets/3d/cast/<id>_ai.glb
with ai_beast.py's own export settings. Replaces the clip if it is there.
"""
import bpy, math, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import beast_clips

args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
BID, CLIP = args[0], args[1]
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
BLEND = os.path.join(HERE, "ai", BID + "_ai.blend")
OUT = os.path.join(ROOT, "game", "assets", "3d", "cast", BID + "_ai.glb")
R = math.radians

bpy.ops.wm.open_mainfile(filepath=BLEND)
rig = [o for o in bpy.data.objects if o.type == "ARMATURE"][0]
pb = rig.pose.bones
legs = {b.name[:2] for b in rig.data.bones if b.name.endswith("_upper")}
frames = getattr(beast_clips, CLIP)(legs)

for tr in list(rig.animation_data.nla_tracks):
    if tr.name == CLIP:
        rig.animation_data.nla_tracks.remove(tr)
for a in list(bpy.data.actions):
    if a.name.split("_")[0] == CLIP:
        bpy.data.actions.remove(a)

act = bpy.data.actions.new(CLIP)
rig.animation_data.action = act
for f, pose in frames:
    for b in pb:
        b.rotation_mode = "XYZ"
        b.rotation_euler = (0, 0, 0)
    for n, (x, y, z) in pose.items():
        pb[n].rotation_euler = (R(x), R(y), R(z))
    for b in pb:
        b.keyframe_insert("rotation_euler", frame=f)
tr = rig.animation_data.nla_tracks.new()
tr.name = CLIP
tr.strips.new(CLIP, 0, act)
rig.animation_data.action = None
for b in pb:
    b.rotation_euler = (0, 0, 0)
bpy.context.scene.frame_set(0)

# What ai_beast.py exports: the rig, the body and the climb markers. Not any
# stray object the saved .blend picked up since (it has an Icosphere).
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.data.objects:
    if o == rig or o.parent == rig or (o.type == "EMPTY" and o.name.split("_")[0] in ("climb", "ledge")):
        o.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.export_scene.gltf(filepath=OUT, use_selection=True, export_format="GLB",
                          export_animations=True, export_animation_mode="ACTIONS",
                          export_skins=True, export_force_sampling=True, export_frame_range=False)
bpy.ops.wm.save_as_mainfile(filepath=BLEND, compress=True)
print("REPORT clip %s %d frames -> %s" % (CLIP, frames[-1][0], OUT))
