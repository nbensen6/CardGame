"""Card frames, per rarity, rendered rather than painted.

    blender --background --python tools/blender/frames.py -- <out_dir>

Nick, 2026-08-31: "I don't see any rarity borders on cards. How can I make
cards look similar to Slay the Spire where the card looks almost 3d."

Two things in that. The rarity treatment was there and far too timid — a frame
tint you had to be told about and four-pixel pips. And the 3D look he means is
not a trick: look at the reference cards and the border has a real highlight
along its top edge, a real shadow under its bottom, and a rounded lip catching
the light. That is a bevel lit from above.

So the frames are BUILT and LIT rather than drawn. A rounded frame with a
genuine bevel, an inset well for the art, a key light up and to the left, and an
orthographic camera. Blender does the shading; nothing has to be hand-painted,
and a new rarity is one line in RARITY below.

Output is a 9-slice: the corners hold the bevel and must not stretch, so
card_view sets a texture margin matching MARGIN here.

Rendered 1:1 with the largest card, NOT at 2x. A StyleBoxTexture draws its
corners at the texture's own pixel size no matter how big the control is, so a
46px margin off a 352px render put 92 pixels of border on a 148px card and the
frame ate the face. The margin has to be the number of screen pixels you want
the border to be.
"""
import bpy
import bmesh
import math
import os
import sys

W, H = 176, 264          # the biggest card the game lays out, 1:1
MARGIN = 15              # the 9-slice border, in rendered pixels
BEVEL = 0.030
DEPTH = 0.09

## name -> (frame colour, lip highlight, how bright the gloss runs)
##
## Common is deliberately plain — if every rarity glitters, none of them reads as
## rare. The step from common to uncommon is a colour you notice; uncommon to
## rare is a colour AND a brighter lip, so the top of the card catches light.
RARITY = {
    "common":   ((0.30, 0.29, 0.31), (0.52, 0.51, 0.54), 0.25),
    "uncommon": ((0.20, 0.34, 0.50), (0.46, 0.68, 0.92), 0.45),
    "rare":     ((0.52, 0.36, 0.10), (0.98, 0.80, 0.36), 0.75),
}


def rounded_frame(inner=0.84, radius=0.14):
    """A rounded rectangular ring: the card's border, with a hole for the face."""
    bm = bmesh.new()

    def ring(sx, sy, r, z):
        pts = []
        for cx, cy, a0 in ((sx - r, sy - r, 0.0), (-sx + r, sy - r, math.pi * 0.5),
                           (-sx + r, -sy + r, math.pi), (sx - r, -sy + r, math.pi * 1.5)):
            for i in range(7):
                a = a0 + math.pi * 0.5 * (i / 6.0)
                pts.append(bm.verts.new((cx + math.cos(a) * r,
                                         cy + math.sin(a) * r, z)))
        return pts

    outer_lo = ring(1.0, 1.42, radius, 0.0)
    outer_hi = ring(1.0, 1.42, radius, DEPTH)
    inner_lo = ring(inner, 1.42 * inner + 0.10, radius * 0.7, 0.0)
    inner_hi = ring(inner, 1.42 * inner + 0.10, radius * 0.7, DEPTH)
    n = len(outer_lo)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((outer_lo[i], outer_lo[j], outer_hi[j], outer_hi[i]))   # outside
        bm.faces.new((inner_hi[i], inner_hi[j], inner_lo[j], inner_lo[i]))   # inside
        bm.faces.new((outer_hi[i], outer_hi[j], inner_hi[j], inner_hi[i]))   # top
        bm.faces.new((inner_lo[i], inner_lo[j], outer_lo[j], outer_lo[i]))   # bottom
    me = bpy.data.meshes.new("frame")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("frame", me)
    bpy.context.collection.objects.link(o)
    return o


def build(name, out_dir):
    body, lip, gloss = RARITY[name]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    o = rounded_frame()

    # The bevel IS the 3D look. Without it the border is a flat colour ring and
    # no amount of lighting will make it read as raised.
    m = o.modifiers.new("bevel", "BEVEL")
    m.width = BEVEL
    m.segments = 3
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(35)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.modifier_apply(modifier="bevel")
    bpy.ops.object.shade_smooth()
    for p in o.data.polygons:
        p.use_smooth = True

    # The card BODY, filling the frame's opening. A 9-slice stretches its centre,
    # so if the middle of this texture is transparent the card has no background
    # at all and the scene shows through the rules text. One quad, sitting just
    # behind the frame's front face, dark enough for cream text to sit on.
    bm = bmesh.new()
    z = DEPTH * 0.45
    v = [bm.verts.new(p) for p in ((-0.94, -1.36, z), (0.94, -1.36, z),
                                   (0.94, 1.36, z), (-0.94, 1.36, z))]
    bm.faces.new(v)
    back_me = bpy.data.meshes.new("body")
    bm.to_mesh(back_me)
    bm.free()
    back = bpy.data.objects.new("body", back_me)
    bpy.context.collection.objects.link(back)
    body_mat = bpy.data.materials.new("body")
    body_mat.use_nodes = True
    bb = body_mat.node_tree.nodes["Principled BSDF"]
    # Tinted a little toward the frame's own colour, so a rare card is warm all
    # over rather than a gold ring around a neutral grey slab.
    # Dark. Cream rules text sits on this, and the first pass came out a mid
    # grey that the text had to fight. A card body is nearly black with a hint of
    # the frame's colour in it.
    bb.inputs["Base Color"].default_value = (0.045 + body[0] * 0.075,
                                             0.040 + body[1] * 0.075,
                                             0.042 + body[2] * 0.075, 1.0)
    bb.inputs["Roughness"].default_value = 0.88
    back.data.materials.append(body_mat)

    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (body[0], body[1], body[2], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.62 - gloss * 0.34
    bsdf.inputs["Metallic"].default_value = gloss * 0.55
    o.data.materials.append(mat)

    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE_NEXT" if hasattr(
        bpy.types, "SceneEEVEE") and "BLENDER_EEVEE_NEXT" in [
            i.identifier for i in sc.bl_rna.properties["render"].fixed_type
            .bl_rna.properties["engine"].enum_items] else "BLENDER_EEVEE"
    sc.render.film_transparent = True
    sc.render.resolution_x, sc.render.resolution_y = W, H
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"

    # Key from up and to the LEFT, which is where every card in the reference
    # images is lit from — the top-left of the border is the bright edge and the
    # bottom-right carries the shadow. Getting this backwards makes a raised
    # frame read as a groove.
    key = bpy.data.lights.new("key", "AREA")
    key.energy = 260.0
    key.size = 3.0
    key.color = (1.0, 0.97, 0.92)
    ko = bpy.data.objects.new("key", key)
    ko.location = (-2.2, -1.6, 3.4)
    ko.rotation_euler = (0.55, -0.5, 0.0)
    bpy.context.collection.objects.link(ko)

    rim = bpy.data.lights.new("rim", "AREA")
    rim.energy = 90.0
    rim.size = 4.0
    rim.color = (lip[0], lip[1], lip[2])
    ro = bpy.data.objects.new("rim", rim)
    ro.location = (2.0, 2.0, 2.2)
    bpy.context.collection.objects.link(ro)

    bpy.ops.object.camera_add(location=(0.0, 0.0, 6.0))
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 2.92
    sc.camera = cam
    path = os.path.join(out_dir, "frame_%s.png" % name)
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("FRAME %s -> %s" % (name, os.path.basename(path)))


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    os.makedirs(out_dir, exist_ok=True)
    for name in RARITY:
        build(name, out_dir)
    print("MARGIN %d  (card_view must use this as the 9-slice texture margin, "
          "or the bevelled corners stretch and the frame reads as a smear)" % MARGIN)


main()
