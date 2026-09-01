"""The three pieces that sit ON the card frame: banner, cost orb, type pill.

    blender --background --python tools/blender/plates.py -- <out_dir>

These are separate from frames.py on purpose. The frame is a nine-slice whose
middle stretches to whatever size the card is; these three sit at FIXED points
and overlap its edge — the banner straddles the top border, the orb hangs off
the top-left corner, the pill sits astride the bottom of the art window. None of
that can be part of a stretching texture, which is why Nick's Bash reference has
them as distinct objects and why they are three files here.

    banner.png      the name plate. Nine-sliced HORIZONTALLY: the shaped ends
                    are fixed and the middle stretches, so "Bash" and
                    "Reckless Charge" both sit on a plate that fits them.
    pill.png        the type tag. Same trick, smaller — "Attack" and "Power"
                    are different widths.
    orb_<who>.png   the cost gem, one per hunter. Fixed size, never stretched,
                    so it can be a real disc with a rim.

Lit exactly like frames.py: key up and to the left, coloured fill low right to
catch the inner edge. They have to look like they were milled from the same bar
as the border or the card falls apart into stickers.
"""
import bpy
import bmesh
import math
import os
import sys

BEVEL = 0.010

## Same hues as frames.CHARACTERS, so the orb belongs to the border it sits on.
ORB = {
    "frog": ("2C9858", "7FD9A0"),
    "vine_weaver": ("7750C9", "B79BEE"),
    "mountain_climbers": ("6794D9", "A8C8F2"),
    "goblin_mech": ("E38645", "F7BE8E"),
    "lightbearer": ("FFC044", "FFE9A8"),
    "common": ("5D6171", "9AA0B2"),
}

## Banner and pill are deliberately NEUTRAL. They carry text that has to read on
## all six border colours, and a plate tinted to match the frame turns the name
## into low-contrast noise on the two lightest hunters.
STEEL = ("8A8F9E", "D6DAE4")


def srgb(h):
    return tuple((int(h[i:i + 2], 16) / 255.0) ** 2.2 for i in (0, 2, 4))


def loft(rings):
    bm = bmesh.new()
    made = [[bm.verts.new(p) for p in r] for r in rings]
    n = len(made[0])
    for a, b in zip(made, made[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    # cap the innermost ring so the plate is solid rather than a hoop
    bm.faces.new(made[-1])
    me = bpy.data.meshes.new("plate")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("plate", me)
    bpy.context.collection.objects.link(o)
    return o


def plate_ring(hw, hh, notch, inset, z):
    """One outline of the banner: a bar whose ENDS are notched into a point.

    The notch is what makes it a ribbon rather than a rectangle, and it lives
    entirely inside the nine-slice's fixed end caps so it survives stretching.
    """
    x, y = hw * inset, hh * inset
    n = notch * inset
    return [
        (-x, -y, z), (-x + n, 0.0, z), (-x, y, z),
        (x, y, z), (x - n, 0.0, z), (x, -y, z),
    ]


def rounded_ring(hw, hh, r, inset, z, seg=6):
    x, y, rr = hw * inset, hh * inset, r * inset
    pts = []
    for cx, cy, a0 in ((x - rr, y - rr, 0.0), (-x + rr, y - rr, math.pi * 0.5),
                       (-x + rr, -y + rr, math.pi), (x - rr, -y + rr, math.pi * 1.5)):
        for i in range(seg):
            a = a0 + math.pi * 0.5 * (i / float(seg - 1))
            pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr, z))
    return pts


def disc_ring(r, inset, z, seg=24):
    rr = r * inset
    return [(math.cos(math.tau * i / seg) * rr,
             math.sin(math.tau * i / seg) * rr, z) for i in range(seg)]


def light(lip):
    key = bpy.data.lights.new("key", "AREA")
    key.energy = 300.0
    key.size = 2.0
    key.color = (1.0, 0.98, 0.94)
    ko = bpy.data.objects.new("key", key)
    ko.location = (-2.0, 1.8, 2.6)
    ko.rotation_euler = (0.6, -0.6, 0.0)
    bpy.context.collection.objects.link(ko)
    # A second key from the top RIGHT at less than half strength. With only the
    # left key, the ribbon's right end faced away from all light and rendered
    # as a near-black slab - which on the card read as an untextured black
    # square wedged between the name and the frame corner, and got reported as
    # a border bug. The reference ribbon is bright at BOTH ends; the light rig
    # has to say so.
    key2 = bpy.data.lights.new("key2", "AREA")
    key2.energy = 130.0
    key2.size = 2.0
    key2.color = (1.0, 0.98, 0.94)
    k2 = bpy.data.objects.new("key2", key2)
    k2.location = (2.0, 1.6, 2.4)
    k2.rotation_euler = (0.6, 0.6, 0.0)
    bpy.context.collection.objects.link(k2)

    fill = bpy.data.lights.new("fill", "AREA")
    fill.energy = 110.0
    fill.size = 3.0
    fill.color = lip
    fo = bpy.data.objects.new("fill", fill)
    fo.location = (1.8, -1.6, 1.4)
    fo.rotation_euler = (-0.5, 0.55, 0.0)
    bpy.context.collection.objects.link(fo)


def render(o, colours, res, ortho, path):
    body, lip = srgb(colours[0]), srgb(colours[1])
    m = o.modifiers.new("bevel", "BEVEL")
    m.width = BEVEL
    m.segments = 2
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(25)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.modifier_apply(modifier="bevel")
    for p in o.data.polygons:
        p.use_smooth = True
    mat = bpy.data.materials.new("plate")
    mat.use_nodes = True
    b = mat.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (body[0], body[1], body[2], 1.0)
    b.inputs["Roughness"].default_value = 0.34
    b.inputs["Metallic"].default_value = 0.3
    o.data.materials.append(mat)
    light(lip)

    sc = bpy.context.scene
    ids = [i.identifier for i in sc.bl_rna.properties["render"].fixed_type
           .bl_rna.properties["engine"].enum_items]
    sc.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in ids \
        else "BLENDER_EEVEE"
    sc.render.film_transparent = True
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Standard"
    bpy.ops.object.camera_add(location=(0.0, 0.0, 6.0))
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ortho
    sc.camera = cam
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("PLATE %s" % os.path.basename(path))


def banner(out_dir):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    hw, hh, notch = 1.0, 0.19, 0.16
    o = loft([plate_ring(hw, hh, notch, s, z) for s, z in
              ((1.00, 0.00), (0.97, 0.07), (0.90, 0.07), (0.86, 0.10))])
    render(o, STEEL, (200, 40), 2.0, os.path.join(out_dir, "banner.png"))


def pill(out_dir):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    o = loft([rounded_ring(1.0, 0.30, 0.28, s, z) for s, z in
              ((1.00, 0.00), (0.96, 0.06), (0.88, 0.06), (0.84, 0.085))])
    render(o, STEEL, (96, 30), 2.0, os.path.join(out_dir, "pill.png"))


def orb(out_dir, who):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    o = loft([disc_ring(1.0, s, z) for s, z in
              ((1.00, 0.00), (0.94, 0.13), (0.78, 0.16), (0.66, 0.06))])
    render(o, ORB[who], (48, 48), 2.02,
           os.path.join(out_dir, "orb_%s.png" % who))


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    os.makedirs(out_dir, exist_ok=True)
    banner(out_dir)
    pill(out_dir)
    for who in ORB:
        orb(out_dir, who)
    print("SLICE banner margin 26 (horizontal), pill margin 13 (horizontal), "
          "orb is fixed and never sliced.")


main()
