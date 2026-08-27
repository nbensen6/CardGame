"""Capture an asset so it can be JUDGED, not just checked.

    blender --background --python tools/blender/look.py -- <in.glb> <out_dir> <asset> <pass>

Writes six images to <out_dir>:

    <asset>_pass<N>_34.png     three-quarter front — the angle you fight it from
    <asset>_pass<N>_side.png   profile
    <asset>_pass<N>_top.png    plan, orthographic
    <asset>_pass<N>_form.png   matcap — the same shape with the palette off
    <asset>_pass<N>_wire.png   true wireframe — where the triangles went
    <asset>_pass<N>_sil.png    SOLID BLACK at 64px, blown up

The last one is the point of this script existing rather than preview.py.

Every automated check this project has answers "does the model meet the
contract" — budget, one mesh, one material, holds where the data says. Not one
of them answers "is it readable as this creature". The failures listed at the
top of design/ART-REVIEW.md are all of the second kind, and all of them passed
every check: the Vine-Weaver that read as a lamp, the Warden's sigil hidden
behind its own head, two zones of dark and darker.

The silhouette render turns the first rubric line — "readable as this object as
a solid black shape at 64px" — from a judgement call into something you look at.
A stalk with a bloom on it is a line with a dot on it, and that is visible in
black at 64 pixels in a way it is not visible in a lit 512px render where the
palette is doing the explaining.

Backdrop is mid grey on purpose. preview.py uses a dark slate, which flatters
the dark models and is exactly the condition under which the Stone Warden's
invisible seam got approved.
"""
import bpy, sys, os, mathutils

args = sys.argv[sys.argv.index("--") + 1:]
src, out_dir, asset = args[0], args[1], args[2]
npass = args[3] if len(args) > 3 else "1"

SIZE = 512
SIL = 64           # what the eye actually resolves of a beast across the arena
SIL_SHOWN = 256    # blown up so a human can see what 64 pixels contains

# Right, in front, a little above. -Y is the direction every model in this
# project is built to face, so -Y is the front of the camera's arc.
# The three-quarter is perspective, because that is what the fight camera is.
# The profile is dead-on and ORTHOGRAPHIC, because the question it answers is
# "where is the topline" and a perspective camera lifted above the model answers
# that wrong — it drops the near end and raises the far one, which reads as a
# rump taller than the head on a model whose eyes are demonstrably the highest
# point on it.
ANGLES = {
    "34":   (1.15, -1.30, 0.55),
}
PROFILE = (1.0, 0.0, 0.0)


def bounds():
    co = [o.matrix_world @ v.co for o in bpy.data.objects if o.type == "MESH"
          for v in o.data.vertices]
    lo = mathutils.Vector((min(c.x for c in co), min(c.y for c in co),
                           min(c.z for c in co)))
    hi = mathutils.Vector((max(c.x for c in co), max(c.y for c in co),
                           max(c.z for c in co)))
    return lo, hi, (lo + hi) / 2, max(hi.x - lo.x, hi.y - lo.y, hi.z - lo.z)


def shoot(mid, reach, d, name, ortho=False, size=SIZE):
    loc = mid + mathutils.Vector(d).normalized() * reach * 2.1
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    # "-Z", "Y" — and the second argument is the part that is easy to get wrong.
    # to_track_quat names the camera's LOCAL axis that should point toward world
    # up, and for a camera that is +Y, because -Z is already spoken for as the
    # view direction. Passing "Z" asks the solver to point the axis that runs
    # backwards out of the lens at the sky; with any downward tilt it fudges
    # something close enough to look right, and on a dead-level camera it cannot,
    # so it rolls 90 degrees and renders the subject lying on its side. That is
    # what made the first profile of the frog look like a rump taller than a
    # head. preview.py and portraits.py both had this right already.
    cam.rotation_euler = (mid - loc).to_track_quat("-Z", "Y").to_euler()
    if ortho:
        cam.data.type = "ORTHO"
        cam.data.ortho_scale = reach * 1.15
    sc = bpy.context.scene
    sc.camera = cam
    sc.render.resolution_x = sc.render.resolution_y = size
    path = os.path.join(out_dir, "%s_pass%s_%s.png" % (asset, npass, name))
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam, do_unlink=True)
    print("LOOK", os.path.basename(path))
    return path


def main():
    os.makedirs(out_dir, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=src)
    lo, hi, mid, reach = bounds()

    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.render.image_settings.file_format = "PNG"
    sh = sc.display.shading
    sh.light = "STUDIO"
    sh.color_type = "TEXTURE"
    sh.show_shadows = True
    sh.show_cavity = True
    sc.world = bpy.data.worlds.new("W")
    sc.world.color = (0.30, 0.30, 0.31)     # mid grey: flatters nothing

    for name, d in ANGLES.items():
        shoot(mid, reach, d, name)
    shoot(mid, reach, PROFILE, "side", ortho=True)
    shoot(mid, reach, (0.0, 0.0, 1.0), "top", ortho=True)

    # FORM: the same angle with the palette taken away. This is the one that
    # answers "is the colour doing all the work" — a shape that stops being
    # legible the moment it turns grey is a shape that will stop being legible
    # at fight distance, in shadow, or behind a particle effect.
    sh.color_type = "SINGLE"
    sh.single_color = (0.70, 0.70, 0.72)
    sh.light = "MATCAP"
    sh.show_cavity = False
    sh.show_object_outline = True
    sh.show_xray = False
    shoot(mid, reach, ANGLES["34"], "form")

    # WIRE: where the triangles actually went. A budget number says 2600 and
    # says nothing about whether 2000 of them are in one smooth blob while the
    # head is a box. Only worth opening when the budget line looks wrong.
    #
    # This is shading.TYPE, not a show_wireframes flag — there is no such flag
    # on a Workbench render in 4.1, and object.show_wire is a viewport overlay
    # that a background render ignores silently, producing a plausible image
    # with no wires on it and no error to say so.
    sh.type = "WIREFRAME"
    sc.display.render_aa = "OFF"
    shoot(mid, reach, ANGLES["34"], "wire")
    sh.type = "SOLID"

    # The 64px silhouette. Flat black on white, no shading of any kind, from the
    # angle the fight camera uses.
    for o in bpy.data.objects:
        if o.type == "MESH":
            o.show_wire = False
    sh.light = "FLAT"
    sh.single_color = (0.0, 0.0, 0.0)
    sh.show_object_outline = False
    sh.show_shadows = False
    sc.world.color = (1.0, 1.0, 1.0)
    sc.display.render_aa = "OFF"        # a real 64px silhouette has hard edges
    path = shoot(mid, reach, ANGLES["34"], "sil", size=SIL)

    img = bpy.data.images.load(path)
    img.scale(SIL_SHOWN, SIL_SHOWN)
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    print("LOOK %s (%dpx of information, shown at %d)"
          % (os.path.basename(path), SIL, SIL_SHOWN))

    print("SIZE %s is %.2f x %.2f x %.2f, %d tris"
          % (asset, hi.x - lo.x, hi.y - lo.y, hi.z - lo.z,
             sum(len(o.data.loop_triangles) for o in bpy.data.objects
                 if o.type == "MESH" and (o.data.calc_loop_triangles() or True))))


main()
