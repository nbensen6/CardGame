"""Shared machinery for building cast models in the Kenney style.

Read off their models rather than guessed at. Run `tools/blender/dissect.py`
against `cast/bunny.glb` and `cast/fox.glb` and three things come back that the
first version of this file got wrong:

  * **The low-poly look is the VERTEX COUNT, not flat shading.** 80% of the
    bunny's faces are smooth. Faceting a model is what reads as programmer art.
  * **Kenney bevels everything.** Of the bunny's 833 edges, 246 sit in the
    25-50 degree band - the signature of a bevelled hard edge. Our slabs were
    razor cubes, which is why they read as debug boxes.
  * **Their parts are TUBES, BOXES and TAPERS. Ours were all ellipsoids.**
    The fox's ears taper 0.23 -> 0.10 along their length. Every part of our Frog
    classified as a squashed sphere, and the Stone Warden spent 3744 triangles -
    six times Kenney's whole budget - making spheres rounder rather than making
    shapes.

That last one is the diagnosis for the whole cast: detail does not come from
more triangles, it comes from a vocabulary that can say more than "ellipsoid".
So this module now speaks:

    ball    an ellipsoid                     bodies, heads, joints
    box     a BEVELLED cube                  plates, slabs, blocks, teeth
    taper   a cone or frustum                snouts, horns, claws, legs, spikes
    wedge   a box with one end shrunk        beaks, fins, blades, jaws
    limb    a tapered tube along a path      tails, vines, tentacles, serpents
    ring    a torus                          mouths, collars, bands

    mirror  build once, get both sides
    aim     point a box or wedge along a direction
    point   point a cone along a direction

Colour still comes from UVs pointing at a flat swatch of one shared 512x512
atlas, so a whole character is one mesh with one material and as many colours as
it likes.

    from kenney import Build, out_path, GREEN, CREAM
    b = Build()
    b.ball((0, 0, 0.7), (0.4, 0.4, 0.5), GREEN)
    b.taper((0, -0.4, 0.9), 0.18, 0.02, 0.5, CREAM, rot=(math.pi / 2, 0, 0))
    b.finish(out_path(), name="Frog")
"""
import bpy, bmesh, sys, os, math, mathutils
from mathutils import Vector

## The bunny is 1.83 tall. Everyone stands at one eye level or the cast reads as
## a pile of unrelated toys.
TARGET_HEIGHT = 1.85

## Kenney's bunny is 575 triangles and his fox is 566. A hunter can afford more
## than a decoration and a Titan more than a hunter, but the Stone Warden's 3744
## was not detail - it was smoothness nobody could see. finish() prints where a
## model lands against this and says so out loud when it is over.
BUDGET = {"hunter": 1400, "beast": 2600, "prop": 500}

## Above this angle an edge reads as a crease and stops sharing a normal. Kenney's
## own edges cluster in the 25-50 band (bevels, which stay smooth) and 50+ (real
## turns, which do not), so the line goes between them.
CREASE = 50.0


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

## Every swatch, by name, so an imported model's colours can be matched against
## the palette instead of being hand-translated. Built from the constants above
## so it can never drift from them.
PALETTE = {k: v for k, v in list(globals().items())
           if k.isupper() and isinstance(v, tuple) and len(v) == 2
           and all(isinstance(c, float) for c in v)}

## Where the Kenney bundle was extracted. 15,109 models across 54 packs, already
## on disk and already the exact vocabulary this project was reverse-engineered
## from — dissect.py measured THESE to work out what the style is. Building a
## rock by hand when Nature Kit ships 329 of them is work nobody needed to do.
KITS = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "3D assets"))


def kit_path(pack, name):
    """A model in the bundle, by pack and file stem."""
    return os.path.join(KITS, pack, "Models", "GLTF format", name + ".glb")


def out_path():
    """The export path, from the args after `--`."""
    return sys.argv[sys.argv.index("--") + 1]


def mirror(fn):
    """Build a part on both sides. `fn(-1)` then `fn(1)`.

    Symmetry by hand is symmetry that drifts: the Goblin's arms were placed
    twice and ended up at different heights. Say it once instead.
    """
    fn(-1)
    fn(1)


def aim(d, up=(0, 0, 1)):
    """Euler that swings a part's FORWARD (-Y) onto direction `d`.

    For box() and wedge(), whose narrow end points -Y. `up` decides the roll:
    which way the part's flat side faces. Petals in a ring want up=(0, -1, 0),
    so their broad face turns toward the camera instead of their edge.
    """
    d = Vector(d).normalized()
    y = -d                                       # local +Y is the far end
    u = Vector(up)
    if abs(y.normalized().dot(u.normalized())) > 0.999:
        u = Vector((0, 1, 0)) if abs(y.z) > 0.9 else Vector((0, 0, 1))
    z = (u - y * y.dot(u)).normalized()
    x = y.cross(z)
    m = mathutils.Matrix.Identity(3)
    for i, v in enumerate((x, y, z)):
        m[0][i], m[1][i], m[2][i] = v.x, v.y, v.z
    return m.to_euler("XYZ")


def point(d, up=(0, 0, 1)):
    """Euler that swings a cone's axis (+Z) onto direction `d`. For taper()."""
    z = Vector(d).normalized()
    u = Vector(up)
    if abs(z.dot(u.normalized())) > 0.999:
        u = Vector((0, 1, 0)) if abs(z.z) > 0.9 else Vector((0, 0, 1))
    x = u.cross(z).normalized()
    y = z.cross(x)
    m = mathutils.Matrix.Identity(3)
    for i, v in enumerate((x, y, z)):
        m[0][i], m[1][i], m[2][i] = v.x, v.y, v.z
    return m.to_euler("XYZ")


def _frames(points):
    """A non-twisting frame at each point of a path (parallel transport).

    Rebuilding the frame from scratch at each point makes a limb spin around its
    own axis wherever the path turns; carrying the previous frame forward does
    not. This is why a tail built the naive way looks like a drill bit.
    """
    pts = [Vector(p) for p in points]
    tans = []
    for i in range(len(pts)):
        a = pts[max(0, i - 1)]
        c = pts[min(len(pts) - 1, i + 1)]
        t = (c - a)
        if t.length < 1e-9:
            t = Vector((0, 0, 1))
        tans.append(t.normalized())

    ref = Vector((0, 0, 1))
    if abs(tans[0].dot(ref)) > 0.9:
        ref = Vector((1, 0, 0))
    u = tans[0].cross(ref).normalized()
    frames = [(u, tans[0].cross(u).normalized())]
    for i in range(1, len(tans)):
        rot = tans[i - 1].rotation_difference(tans[i])
        u = (rot @ frames[-1][0]).normalized()
        frames.append((u, tans[i].cross(u).normalized()))
    return pts, frames


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

    # ------------------------------------------------------------------ paint

    def _paint(self, o, uv, smooth=None):
        """Point every loop at one swatch, and crease by angle.

        `smooth=None` means "decide by angle", which is what Kenney does and what
        gives a sphere soft shading and a box hard corners from the same rule.
        Pass True or False only to overrule it for one part.
        """
        o.data.materials.append(self.mat)
        # The primitives already ship a "UVMap". uv_layers.new() would add a
        # SECOND layer and the renderer would keep using the original unwrap -
        # which is how the first attempt came out looking like a paint splatter.
        layer = o.data.uv_layers[0] if o.data.uv_layers else o.data.uv_layers.new(name="UVMap")
        for loop in layer.data:
            loop.uv = uv

        for poly in o.data.polygons:
            poly.use_smooth = smooth is not False
        if smooth is None:
            # 4.1 dropped mesh.use_auto_smooth; a sharp edge on a smooth face is
            # now the whole mechanism, and the glTF exporter honours it.
            bm = bmesh.new()
            bm.from_mesh(o.data)
            for e in bm.edges:
                if len(e.link_faces) == 2:
                    e.smooth = math.degrees(e.calc_face_angle(0.0)) < CREASE
            bm.to_mesh(o.data)
            bm.free()

        self.parts.append(o)
        return o

    def kit(self, path, at=(0.0, 0.0, 0.0), size=1.0, rot=(0.0, 0.0, 0.0),
            uv=None, up_z=True):
        """Fold a model from the Kenney bundle into this build.

        Nick, 2026-08-31: "instead of manually building objects can we pull
        objects from somewhere?" Yes — 15,109 of them are already in the repo
        root, and they are the same models dissect.py measured to work out what
        this project's style even is. A hand-coded boulder was always an
        impression of one of these.

            from kenney import kit_path
            e.kit(kit_path("Nature Kit", "rock_largeA"), at=(3, 4, 0), size=1.6)

        The one thing that has to happen on the way in is COLOUR. A Kenney model
        carries two or three flat materials of its own; this project is one mesh
        with one material and colour carried in the UVs. So each incoming
        material is matched to its nearest palette swatch by RGB and the faces
        wearing it are re-pointed there. The model keeps its shape and joins the
        single atlas material like everything else — no second draw call, no
        second texture, and `finish()` still exports one mesh.

        Pass `uv` to override the match and paint the whole thing one colour.

        Kenney models are authored Y-up; `up_z` rotates them into this project's
        Z-up world, which is what every other part here assumes.
        """
        if not os.path.exists(path):
            print("WARNING: no kit model at %s — skipped" % path)
            return []
        before = set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=path)
        fresh = [o for o in bpy.data.objects if o not in before]
        meshes = [o for o in fresh if o.type == "MESH"]
        made = []
        for o in meshes:
            # Remember each polygon's colour BEFORE the material slots go away.
            want = []
            for poly in o.data.polygons:
                if uv is not None:
                    want.append(uv)
                else:
                    want.append(self._nearest_swatch(o, poly.material_index))
            o.data.materials.clear()
            for m in fresh:
                if m.type != "MESH":
                    continue
            bpy.ops.object.select_all(action="DESELECT")
            o.select_set(True)
            bpy.context.view_layer.objects.active = o
            bpy.ops.object.transform_apply(location=True, rotation=True,
                                           scale=True)
            if up_z:
                o.rotation_euler = (math.pi * 0.5, 0.0, 0.0)
            o.scale = (size, size, size)
            o.location = at
            bpy.ops.object.transform_apply(location=True, rotation=True,
                                           scale=True)
            if rot != (0.0, 0.0, 0.0):
                o.rotation_euler = rot
                bpy.ops.object.transform_apply(rotation=True)
            layer = (o.data.uv_layers[0] if o.data.uv_layers
                     else o.data.uv_layers.new(name="UVMap"))
            for poly, cell in zip(o.data.polygons, want):
                for li in poly.loop_indices:
                    layer.data[li].uv = cell
            o.data.materials.append(self.mat)
            self.parts.append(o)
            made.append(o)
        # Empties and armatures the import dragged in are not geometry.
        for o in fresh:
            if o not in made:
                bpy.data.objects.remove(o, do_unlink=True)
        return made

    def _nearest_swatch(self, o, slot):
        """The palette cell closest in RGB to an imported material's colour."""
        colour = (0.6, 0.6, 0.6)
        if slot < len(o.data.materials) and o.data.materials[slot] is not None:
            m = o.data.materials[slot]
            if m.use_nodes:
                for n in m.node_tree.nodes:
                    if n.type == "BSDF_PRINCIPLED":
                        c = n.inputs["Base Color"].default_value
                        colour = (c[0], c[1], c[2])
                        break
            else:
                colour = tuple(m.diffuse_color)[:3]
        best, best_d = None, 1e9
        for cell, rgb in self._palette_rgb().items():
            d = sum((a - b) ** 2 for a, b in zip(colour, rgb))
            if d < best_d:
                best_d, best = d, cell
        return best

    def _palette_rgb(self):
        """Every swatch's actual colour, read once out of colormap.png.

        Sampled from the atlas rather than kept as a second hand-written table,
        because a second table is a thing that drifts.
        """
        if getattr(self, "_pal_cache", None) is not None:
            return self._pal_cache
        img = bpy.data.images.get("colormap")
        out = {}
        if img is not None:
            px = list(img.pixels)
            w, h = img.size
            for name, cell in PALETTE.items():
                x = min(int(cell[0] * w), w - 1)
                y = min(int((1.0 - cell[1]) * h), h - 1)
                # nudge into the middle of the 32px cell, off its border
                x = min(x + 8, w - 1)
                y = min(y + 8, h - 1)
                i = ((h - 1 - y) * w + x) * 4
                if i + 2 < len(px):
                    out[cell] = (px[i], px[i + 1], px[i + 2])
        self._pal_cache = out
        return out


    def _settle(self, o, scale, rot):
        """Bake scale and rotation into the mesh.

        Everything downstream - bevel width, joining, the final fit to height -
        assumes a part's vertices already sit where they look like they sit. A
        bevel of 0.05 on a cube scaled (2, 0.1, 1) is 0.1 wide on one axis and
        0.005 on another, because a modifier works in local space and knows
        nothing about object scale.
        """
        o.scale, o.rotation_euler = scale, rot
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        return o

    def _bevel(self, o, width, seg=1):
        if width <= 0:
            return o
        m = o.modifiers.new("bev", "BEVEL")
        m.width, m.segments = width, seg
        m.limit_method = "ANGLE"
        m.angle_limit = math.radians(30.0)
        m.use_clamp_overlap = True
        bpy.ops.object.modifier_apply(modifier="bev")
        return o

    # ------------------------------------------------------------- primitives

    # Blender -Y is forward; the glTF exporter turns that into the +Z Godot wants.
    def ball(self, loc, scale, uv, seg=10, ring=6, rot=(0, 0, 0), smooth=None):
        """An ellipsoid. Bodies, heads, joints, eyes."""
        bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=ring, location=loc)
        o = self._settle(bpy.context.object, scale, rot)
        return self._paint(o, uv, smooth)

    def box(self, loc, scale, uv, rot=(0, 0, 0), bevel=0.035, seg=1, smooth=None):
        """A BEVELLED cube - the Kenney workhorse.

        The bevel is the whole point. A razor cube catches one flat highlight and
        reads as a debug volume; a 3cm bevel catches a bright line along every
        edge and reads as a moulded plastic part, which is the entire look.
        """
        bpy.ops.mesh.primitive_cube_add(location=loc)
        o = self._settle(bpy.context.object, scale, rot)
        self._bevel(o, bevel, seg)
        return self._paint(o, uv, smooth)

    def slab(self, loc, scale, uv, rot=(0, 0, 0)):
        """A hard-edged cube. Kept for the scripts written before box() existed;
        prefer box(), which is what the Kenney set actually does."""
        bpy.ops.mesh.primitive_cube_add(location=loc)
        o = self._settle(bpy.context.object, scale, rot)
        return self._paint(o, uv, smooth=False)

    def taper(self, loc, r0, r1, depth, uv, seg=8, rot=(0, 0, 0), bevel=0.0,
              bevel_seg=1, smooth=None):
        """A cone or frustum, pointing +Z before rotation.

        Snouts, horns, claws, legs, spikes, teeth, shells. This is the shape the
        old toolkit could not say at all, and the reason every part of the Frog
        classified as a squashed sphere.
        """
        bpy.ops.mesh.primitive_cone_add(vertices=seg, radius1=r0, radius2=r1,
                                        depth=depth, location=loc)
        o = self._settle(bpy.context.object, (1, 1, 1), rot)
        self._bevel(o, bevel, bevel_seg)
        return self._paint(o, uv, smooth)

    def wedge(self, loc, scale, uv, rot=(0, 0, 0), narrow=(0.25, 0.25),
              bevel=0.03, seg=1, smooth=None):
        """A box whose -Y end is shrunk to `narrow` of its width and height.

        Beaks, jaws, fins, blades, buttresses - anything that is a slab at one
        end and an edge at the other. -Y is forward, so the narrow end points at
        the camera by default.
        """
        bpy.ops.mesh.primitive_cube_add(location=loc)
        o = bpy.context.object
        for v in o.data.vertices:
            if v.co.y < 0:                      # the forward end
                v.co.x *= narrow[0]
                v.co.z *= narrow[1]
        o = self._settle(o, scale, rot)
        self._bevel(o, bevel, seg)
        return self._paint(o, uv, smooth)

    def limb(self, points, radii, uv, seg=6, cap=True, flat=1.0, smooth=None):
        """A tapered tube threaded through a path. Tails, vines, tentacles, necks.

        `points` is three or more positions, `radii` one radius per point (or a
        single number for an even tube). `flat` squashes the cross-section across
        the path, so a fin is the same call as a tail.

        This is the shape that makes a serpent a serpent. Approximating one with
        a row of spheres gives a caterpillar: the lumps are visible, the
        silhouette pulses, and it costs more triangles than doing it properly.
        """
        if not hasattr(radii, "__len__"):
            radii = [radii] * len(points)
        pts, frames = _frames(points)

        bm = bmesh.new()
        rings = []
        for p, (u, v), r in zip(pts, frames, radii):
            ring = []
            for i in range(seg):
                a = 2 * math.pi * i / seg
                off = u * (math.cos(a) * r) + v * (math.sin(a) * r * flat)
                ring.append(bm.verts.new(p + off))
            rings.append(ring)
        for a, b in zip(rings, rings[1:]):
            for i in range(seg):
                j = (i + 1) % seg
                bm.faces.new((a[i], a[j], b[j], b[i]))
        if cap:
            bm.faces.new(list(reversed(rings[0])))
            bm.faces.new(rings[-1])

        me = bpy.data.meshes.new("limb")
        bm.to_mesh(me)
        bm.free()
        o = bpy.data.objects.new("limb", me)
        bpy.context.collection.objects.link(o)
        bpy.context.view_layer.objects.active = o
        o.select_set(True)
        return self._paint(o, uv, smooth)

    def ring(self, loc, scale, uv, major=16, minor=5, rot=(0, 0, 0), thickness=0.16,
             smooth=None):
        """A torus. Mouths, collars, bands, hoops."""
        bpy.ops.mesh.primitive_torus_add(major_radius=1.0, minor_radius=thickness,
                                         major_segments=major, minor_segments=minor,
                                         location=loc)
        o = self._settle(bpy.context.object, scale, rot)
        return self._paint(o, uv, smooth)

    # ----------------------------------------------------------------- export

    def _islands(self):
        """Groups of parts that touch. More than one group means something floats.

        "Parts that do not touch" is the failure this project keeps shipping: the
        Vine-Weaver stood on a spike with hoops orbiting it, the Goblin's arm hung
        at arm's length and read as a rock standing beside him, and both passed
        every check we had. Bounding boxes overlapping is a loose test - two
        spheres can share a box corner without touching - but it catches the case
        that actually happens, which is a limb placed in mid-air.
        """
        boxes = []
        for o in self.parts:
            co = [o.matrix_world @ v.co for v in o.data.vertices]
            boxes.append((Vector((min(c.x for c in co), min(c.y for c in co),
                                  min(c.z for c in co))),
                          Vector((max(c.x for c in co), max(c.y for c in co),
                                  max(c.z for c in co)))))

        seen, groups = set(), []
        for i in range(len(boxes)):
            if i in seen:
                continue
            stack, g = [i], []
            seen.add(i)
            while stack:
                a = stack.pop()
                g.append(a)
                for j in range(len(boxes)):
                    if j in seen:
                        continue
                    lo_a, hi_a = boxes[a]
                    lo_b, hi_b = boxes[j]
                    if all(hi_a[k] >= lo_b[k] - 1e-4 and hi_b[k] >= lo_a[k] - 1e-4
                           for k in range(3)):
                        seen.add(j)
                        stack.append(j)
            groups.append(sorted(g))
        return groups

    def _part_bounds(self, idx):
        """World bounds of a group of parts, as (lo, hi)."""
        co = [self.parts[i].matrix_world @ v.co
              for i in idx for v in self.parts[i].data.vertices]
        return ([min(c[k] for c in co) for k in range(3)],
                [max(c[k] for c in co) for k in range(3)])

    def _nearest_part(self, group, body):
        """Smallest gap between any part of `group` and any part of `body`.

        PAIRWISE, which is the whole point. Measuring the group's bounding box
        against the body's overall bounding box reported 0.00 for parts that
        plainly do not touch — a lump can sit well inside the body's total
        extent while touching none of it. That is the same mistake the island
        check exists to catch, made by the thing reporting it.
        """
        best, who = 1e9, -1
        for i in group:
            a = self._part_bounds([i])
            for j in body:
                b = self._part_bounds([j])
                d = max(0.0,
                        max(a[0][k] - b[1][k] for k in range(3)),
                        max(b[0][k] - a[1][k] for k in range(3)))
                if d < best:
                    best, who = d, j
        return best, who

    def finish(self, out, height=TARGET_HEIGHT, name="Hunter", budget="hunter"):
        """Join to one mesh, stand it on the floor at `height`, export."""
        groups = self._islands()
        if len(groups) > 1:
            groups.sort(key=len, reverse=True)
            # WHERE, not just which index. "Parts [28, 29, 30] float free" tells
            # you nothing you can act on without counting b.ball() calls down a
            # hundred-line script; the location and size of the offending lump
            # names it on sight, and the gap says how far it has to move.
            for g in groups[1:]:
                lo, hi = self._part_bounds(g)
                mid = [(lo[k] + hi[k]) * 0.5 for k in range(3)]
                gap, near = self._nearest_part(g, groups[0])
                print("WARNING: %s has %d part(s) floating free at "
                      "(%.2f, %.2f, %.2f) — parts %s. The nearest body part is "
                      "%d, %.3f away: close that and they are one body. A model "
                      "in pieces reads as clutter beside a character, not as "
                      "part of one."
                      % (name, len(g), mid[0], mid[1], mid[2], g, near, gap))

        bpy.ops.object.select_all(action="SELECT")
        bpy.context.view_layer.objects.active = self.parts[0]
        # Apply BEFORE joining: join leaves the result carrying the first part's
        # object scale, so a later scale multiplies by the wrong number. Most
        # parts already came through _settle, but limb() can still be untouched.
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        bpy.ops.object.join()
        who = bpy.context.object
        who.name = name

        co = [v.co for v in who.data.vertices]
        lo = mathutils.Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
        hi = mathutils.Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
        # height=None means "leave it where it was authored". A character is fitted
        # to a common eye level so the cast reads as one set; a piece of GROUND is
        # not a character — its size is the whole point of it, and normalising it
        # would throw away the one measurement the game needs.
        if height is None:
            k = 1.0
            mid = mathutils.Vector((0.0, 0.0, 0.0))
        else:
            k = height / (hi.z - lo.z)
            mid = mathutils.Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
        for v in who.data.vertices:
            v.co = (v.co - mid) * k     # to scale, and standing on the floor

        who.data.calc_loop_triangles()
        tris = len(who.data.loop_triangles)
        cap = BUDGET.get(budget, BUDGET["hunter"])
        print("TRIS", tris, "MESHES 1 MATERIALS 1")
        print("PARTS", len(self.parts), "BUDGET", cap,
              ("OVER by %d" % (tris - cap)) if tris > cap else "ok")
        if tris > cap:
            # Loud on purpose: the Stone Warden shipped at 3744 and nobody
            # noticed, because nothing was counting.
            print("WARNING: %s is %.1fx the %s budget. Kenney's whole bunny is "
                  "575 triangles - spend them on shapes, not on smoother balls."
                  % (name, tris / float(cap), budget))
        print("SIZE", round((hi.x - lo.x) * k, 3), round((hi.y - lo.y) * k, 3),
              round((hi.z - lo.z) * k, 3))
        # Anything that is not mesh - climb anchors, say - goes in here, in the
        # same space the vertices just landed in. Default does nothing.
        self._decorate(k, mid)
        bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=False)
        print("WROTE", out)

    def _decorate(self, k, mid):
        """Hook for non-mesh nodes, after the mesh is scaled and stood up.

        `k` and `mid` are the transform finish() just applied, so a subclass can
        place a marker at a point it recorded in BUILD space and have it land
        where that point actually ended up.
        """
        return
