"""Shared machinery for building cast models in the Kenney style.

Read off their bunny rather than guessed at (see README):

  * the low-poly look is the VERTEX COUNT, not flat shading — 78% of the
    bunny's faces are smooth-shaded, and faceting is what reads as programmer
    art;
  * the whole Kenney set shares ONE material, a 512x512 palette atlas, and
    colour comes from UVs pointing at a flat swatch.

So a whole character is one mesh with one material and as many colours as it
likes. Every hunter script here is a list of ellipsoids with a swatch name
against each, and this module does the rest.

    from kenney import Build, GREEN, CREAM
    b = Build()
    b.ball((0, 0, 0.7), (0.4, 0.4, 0.5), GREEN)
    b.finish(out_path)
"""
import bpy, sys, os, math, mathutils

## The bunny is 1.83 tall. Everyone stands at one eye level or the cast reads as
## a pile of unrelated toys.
TARGET_HEIGHT = 1.85


def swatch(px, py):
    """UV of a palette cell, by its pixel in colormap.png (PNG y runs down)."""
    return (px / 512.0, 1.0 - py / 512.0)


# The palette, sampled from the atlas and named so a model reads as a
# description instead of as coordinates. Three bands of sixteen 32px columns.
ORANGE, TANGERINE, RED, RUST = (swatch(x, 192) for x in (16, 48, 80, 112))
BLUE, INDIGO, ICE, SKY = (swatch(x, 192) for x in (144, 176, 208, 240))
LILAC, VIOLET, PINK, ORCHID = (swatch(x, 192) for x in (272, 304, 336, 368))

STEEL, SLATE, WHITE, SILVER = (swatch(x, 320) for x in (16, 48, 80, 112))
PEACH, CLAY, BROWN, UMBER = (swatch(x, 320) for x in (144, 176, 208, 240))
SAND, TAN, CREAM, WHEAT = (swatch(x, 320) for x in (272, 304, 336, 368))
MINT, GREEN, GOLD, AMBER = (swatch(x, 320) for x in (400, 432, 464, 496))

BLUSH, ROSE, PERIWINKLE, IRIS = (swatch(x, 448) for x in (16, 48, 80, 112))
LINEN, BISQUE, PUMPKIN, CARROT = (swatch(x, 448) for x in (144, 176, 208, 240))
CORAL, BRICK, CHARCOAL, GRAPHITE = (swatch(x, 448) for x in (272, 304, 336, 368))
PEWTER, STONE, NAVY, MIDNIGHT = (swatch(x, 448) for x in (400, 432, 464, 496))


def out_path():
    """The export path, from the args after `--`."""
    return sys.argv[sys.argv.index("--") + 1]


class Build:
    """One character. Add shapes, then finish()."""

    def __init__(self):
        bpy.ops.wm.read_factory_settings(use_empty=True)
        here = os.path.dirname(os.path.abspath(__file__))
        img = bpy.data.images.load(os.path.join(here, "colormap.png"))
        img.name = "colormap"
        self.mat = bpy.data.materials.new("colormap")
        self.mat.use_nodes = True
        bsdf = self.mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Roughness"].default_value = 1.0
        tex = self.mat.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = img
        tex.interpolation = "Closest"   # never blend two swatches together
        self.mat.node_tree.links.new(bsdf.inputs["Base Color"], tex.outputs["Color"])
        self.parts = []

    def _paint(self, o, uv, smooth=True):
        o.data.materials.append(self.mat)
        # The primitives already ship a "UVMap". uv_layers.new() would add a
        # SECOND layer and the renderer would keep using the original unwrap —
        # which is how the first attempt came out looking like a paint splatter.
        layer = o.data.uv_layers[0] if o.data.uv_layers else o.data.uv_layers.new(name="UVMap")
        for loop in layer.data:
            loop.uv = uv
        for poly in o.data.polygons:
            poly.use_smooth = smooth
        self.parts.append(o)
        return o

    # Blender -Y is forward; the glTF exporter turns that into the +Z Godot wants.
    def ball(self, loc, scale, uv, seg=10, ring=6, rot=(0, 0, 0)):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, location=loc)
        o = bpy.context.object
        o.scale, o.rotation_euler = scale, rot
        return self._paint(o, uv)

    def slab(self, loc, scale, uv, rot=(0, 0, 0)):
        bpy.ops.mesh.primitive_cube_add(location=loc)
        o = bpy.context.object
        o.scale, o.rotation_euler = scale, rot
        return self._paint(o, uv, smooth=False)

    def ring(self, loc, scale, uv, major=16, minor=5, rot=(0, 0, 0), thickness=0.16):
        bpy.ops.mesh.primitive_torus_add(major_radius=1.0, minor_radius=thickness,
                                         major_segments=major, minor_segments=minor,
                                         location=loc)
        o = bpy.context.object
        o.scale, o.rotation_euler = scale, rot
        return self._paint(o, uv)

    def finish(self, out, height=TARGET_HEIGHT, name="Hunter"):
        """Join to one mesh, stand it on the floor at `height`, export."""
        bpy.ops.object.select_all(action="SELECT")
        bpy.context.view_layer.objects.active = self.parts[0]
        # Apply BEFORE joining: join leaves the result carrying the first part's
        # object scale, so a later scale multiplies by the wrong number.
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        bpy.ops.object.join()
        who = bpy.context.object
        who.name = name

        co = [v.co for v in who.data.vertices]
        lo = mathutils.Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
        hi = mathutils.Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
        k = height / (hi.z - lo.z)
        mid = mathutils.Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
        for v in who.data.vertices:
            v.co = (v.co - mid) * k     # to scale, and standing on the floor

        who.data.calc_loop_triangles()
        print("TRIS", len(who.data.loop_triangles), "MESHES 1 MATERIALS 1")
        print("SIZE", round((hi.x - lo.x) * k, 3), round((hi.y - lo.y) * k, 3),
              round((hi.z - lo.z) * k, 3))
        bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=False)
        print("WROTE", out)
