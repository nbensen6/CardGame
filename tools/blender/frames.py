"""Card frames, built and lit rather than painted.

    blender --background --python tools/blender/frames.py -- <out_dir>

Nick sent two Slay the Spire cards as reference (Bash, and the upgraded Break)
and asked for a border per CHARACTER, each with its own palette.

What makes those cards read as "almost 3D" is not shading painted on a flat
shape. Look along the top edge of the border: there is a bright line where the
surface turns toward the light, a flat face, then a RAISED INNER LIP with its
own highlight, and then a drop into the dark card body. That stepped profile is
the whole effect, and it is why a flat coloured rectangle with a gradient never
looks like it.

So PROFILE below is a real moulding, lofted as concentric rounded rectangles at
different heights and lit from the top left:

    inset  z       what it is
    1.00   0.00    outer edge, at the card's boundary
    0.97   0.11    top of the outer bevel — the bright line
    0.86   0.11    the flat face of the border
    0.83   0.16    the raised inner lip, the second highlight
    0.80   0.10    inner wall of that lip
    0.78   0.02    the drop into the body

COLOURS are the game's own, sampled from tools/blender/colormap.png. Five hunters
get five clearly separated hues — green, violet, blue, orange, gold — because
copying each model's own palette gave five borders nobody could tell apart:
CHARCOAL appears in all five models and the Frog and Vine-Weaver are both green.
The Vine-Weaver's violet is her POISON rather than her body, which is the thing
that separates her from the Frog.

Output is a 9-slice at MARGIN, rendered 1:1 with the largest card. A
StyleBoxTexture draws its corners at the texture's own pixel size whatever the
control's size, so the margin has to be the number of screen pixels you want the
border to actually be.
"""
import bpy
import bmesh
import math
import os
import sys

W, H = 176, 264          # the biggest card the game lays out, 1:1
MARGIN = 13              # the 9-slice border, in rendered pixels
ASPECT = 1.5             # 264 / 176
BEVEL = 0.012
CORNER = 0.13

## (inset, height). See the module docstring — this profile IS the 3D look.
## Thinner than the first pass. Set the original next to Finisher and the
## difference is immediate: their border is a slim rail - roughly 5% of the
## card's width - and the art and text panel are the card. Ours was a picture
## frame from a furniture shop, over 10% a side plus a fat lip, and a thick
## frame makes everything inside it feel smaller, which is half of why Nick
## said their cards "still feel larger".
PROFILE = [
    (1.000, 0.00),
    (0.975, 0.09),
    (0.905, 0.09),
    (0.885, 0.13),
    (0.865, 0.07),
    (0.850, 0.02),
]

## hunter -> (border colour, lip highlight colour)
##
## Sampled from the palette atlas: GREEN #2C9858, VIOLET #7750C9, BLUE #6794D9,
## CARROT #E38645, GOLD #FFC044. The lip is a lifted version of the same hue, so
## the highlight belongs to the border rather than looking like a white pen line
## drawn over it.
def srgb(h):
    return tuple((int(h[i:i + 2], 16) / 255.0) ** 2.2 for i in (0, 2, 4))


## Muted, deliberately. The first set used the palette hues at full strength
## and the frames came out toy-bright next to the reference - Slay the Spire's
## borders are desaturated, closer to painted wood than to plastic, and the
## saturation belongs to the ART, not the thing around it. Each hue is pulled
## roughly a third of the way toward grey and slightly darkened; the identity
## survives, the shout does not.
CHARACTERS = {
    "frog":              ("3F7A55", "7FB894"),
    "vine_weaver":       ("6B58A6", "A794D6"),
    "mountain_climbers": ("5F82B5", "9CB8DC"),
    "goblin_mech":       ("C07E4F", "E0AE85"),
    "lightbearer":       ("D9A94E", "F2D492"),
    # The fallback, for a card with no owner - rewards and neutral cards.
    "common":            ("5D6171", "9AA0B2"),
}


def ring(bm, inset, z):
    """One rounded rectangle of verts at a given inset and height."""
    sx, sy = inset, inset * ASPECT
    r = CORNER * inset
    pts = []
    for cx, cy, a0 in ((sx - r, sy - r, 0.0), (-sx + r, sy - r, math.pi * 0.5),
                       (-sx + r, -sy + r, math.pi), (sx - r, -sy + r, math.pi * 1.5)):
        for i in range(6):
            a = a0 + math.pi * 0.5 * (i / 5.0)
            pts.append(bm.verts.new((cx + math.cos(a) * r,
                                     cy + math.sin(a) * r, z)))
    return pts


def moulding():
    """Loft the profile into a solid ring — the border itself."""
    bm = bmesh.new()
    rings = [ring(bm, s, z) for s, z in PROFILE]
    n = len(rings[0])
    for a, b in zip(rings, rings[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    me = bpy.data.meshes.new("frame")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("frame", me)
    bpy.context.collection.objects.link(o)
    return o


def body(colour):
    """The card face the border surrounds.

    A 9-slice stretches its centre, so if the middle of this texture were
    transparent the card would have no background at all and the fight would
    show through the rules text.
    """
    bm = bmesh.new()
    s, z = 0.80, 0.02
    for p in ((-s, -s * ASPECT, z), (s, -s * ASPECT, z),
              (s, s * ASPECT, z), (-s, s * ASPECT, z)):
        bm.verts.new(p)
    bm.verts.ensure_lookup_table()
    bm.faces.new(bm.verts)
    me = bpy.data.meshes.new("body")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("body", me)
    bpy.context.collection.objects.link(o)
    mat = bpy.data.materials.new("body")
    mat.use_nodes = True
    b = mat.node_tree.nodes["Principled BSDF"]
    # Nearly black with a hint of the border's hue in it, so a violet card is
    # violet all over rather than a purple ring around a neutral slab. Cream
    # rules text has to sit on this and win.
    b.inputs["Base Color"].default_value = (0.030 + colour[0] * 0.10,
                                            0.028 + colour[1] * 0.10,
                                            0.032 + colour[2] * 0.10, 1.0)
    b.inputs["Roughness"].default_value = 0.92
    o.data.materials.append(mat)
    return o


def engine(sc):
    ids = [i.identifier for i in sc.bl_rna.properties["render"].fixed_type
           .bl_rna.properties["engine"].enum_items]
    return "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in ids else "BLENDER_EEVEE"


def build(name, out_dir):
    hexes = CHARACTERS[name]
    col, lip = srgb(hexes[0]), srgb(hexes[1])
    bpy.ops.wm.read_factory_settings(use_empty=True)

    o = moulding()
    m = o.modifiers.new("bevel", "BEVEL")
    m.width = BEVEL
    m.segments = 2
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(25)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.modifier_apply(modifier="bevel")
    for p in o.data.polygons:
        p.use_smooth = True

    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (col[0], col[1], col[2], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.46
    bsdf.inputs["Metallic"].default_value = 0.12
    o.data.materials.append(mat)
    # NO body quad: the middle of this texture is TRANSPARENT on purpose.
    #
    # Nick, on the Bash and Break references: "it looks like they started with a
    # full art card then put the border around it." That is what those cards
    # are - the painting is full bleed and the frame sits ON it - and a frame
    # with an opaque centre cannot do that, because it hides the picture it is
    # supposed to be framing.
    #
    # card_view draws the art at its own ART_LAYER and this frame above it. A
    # card with no painting yet gets a dark ground layer instead.

    sc = bpy.context.scene
    sc.render.engine = engine(sc)
    sc.render.film_transparent = True
    sc.render.resolution_x, sc.render.resolution_y = W, H
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Standard"

    # Key up and to the LEFT. Every card in the reference is lit that way — the
    # top-left of the border is the bright edge, the bottom-right carries the
    # shadow. Reversed, a raised frame reads as a groove instead.
    key = bpy.data.lights.new("key", "AREA")
    key.energy = 420.0
    key.size = 2.2
    key.color = (1.0, 0.98, 0.94)
    ko = bpy.data.objects.new("key", key)
    ko.location = (-2.6, 2.4, 3.2)
    ko.rotation_euler = (0.62, -0.62, 0.0)
    bpy.context.collection.objects.link(ko)

    # A second, coloured light low on the right. This is what puts a highlight on
    # the INNER lip — the key alone lights the outer bevel and leaves the lip
    # flat, and the lip is half of why the reference cards look moulded.
    fill = bpy.data.lights.new("fill", "AREA")
    fill.energy = 160.0
    fill.size = 4.0
    fill.color = lip
    fo = bpy.data.objects.new("fill", fill)
    fo.location = (2.4, -2.2, 1.8)
    fo.rotation_euler = (-0.5, 0.6, 0.0)
    bpy.context.collection.objects.link(fo)

    bpy.ops.object.camera_add(location=(0.0, 0.0, 6.0))
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ASPECT * 2.0 + 0.04
    sc.camera = cam
    path = os.path.join(out_dir, "frame_%s.png" % name)
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("FRAME %-18s #%s  ->  %s" % (name, hexes[0], os.path.basename(path)))


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    os.makedirs(out_dir, exist_ok=True)
    for name in CHARACTERS:
        build(name, out_dir)
    print("MARGIN %d — card_view.FRAME_MARGIN must match, or the 9-slice cuts "
          "through the moulding and the corners smear." % MARGIN)


main()
