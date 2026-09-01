"""The 3D window for rare cards — backlog #84, from design/rare-card-3d-effect.md.

    blender --background --python tools/blender/rare3d.py -- \
        --art game/assets/cardart/grand_leap.png \
        --out game/assets/cardart3d --name grand_leap

Produces `<name>.png` (a sprite sheet) and `<name>.json` (its grid) — one
texture per rare card, played back by CardView as an ANGLE LOOKUP rather than as
an animation. See the note on playback at the bottom of this file.

WHAT THIS IS
------------
Nick sent valdosh's "Blender 3D card effect" tutorial and asked to keep it for
the rares. The tutorial's card is a slab with a hole boolean'd through it and a
diorama behind; turning the card gives the contents real parallax against the
frame, because they really are behind it.

Two deliberate departures from the tutorial, both because of where this has to
end up — inside a Control, under a banner, an orb and a rules panel that do NOT
turn:

**Only the window is rendered, never the card.** The tutorial bakes the card
body into all 120 frames. Do that here and the frame in the sprite sheet would
rotate while card_view's real banner and cost orb sat still on top of it — two
cards fighting. So the render is exactly the contents of the hole, and the
existing layer stack draws the rest. It drops into ART_LAYER and nothing above
it changes. That is why ART_LAYER is a named index.

**No holdout, and no card geometry to hold out.** The tutorial needs the
Holdout/Backfacing split to punch the card's silhouette transparent. Here the
aperture IS the render border, so every pixel is inside the window and the
alpha channel has nothing to do.

THE TURN — the whole effect
---------------------------
The camera never moves. It is orthographic, framed exactly on the aperture, and
identical in all 24 renders. What moves is the CONTENTS, and it moves as a
shear: each plane slides sideways in proportion to how far behind the opening it
sits, and the window's inner wall opens by that same amount on the side you are
turning away from. `set_shear()` is the entire effect, and it is three lines.

That is the second construction. The first was the textbook one — a perspective
camera sliding sideways with its lens shifted by exactly the amount that pins
the aperture plane, the same off-axis frustum stereo rendering uses — and it
went in the bin because I could not make it agree with Blender's units: the end
views came back 45% black with the painting shoved most of the way off frame.
The shear needs no calibration, is exact, and leaves every number in this file
measured in card-widths, which means a render can be checked against them with a
ruler. See SHIFT.

WHAT THE ART HAS TO BE
----------------------
The same 620x870 export as every other card (card_view.CARD_ART_SIZE), with one
extra rule: **keep the subject inside the middle ~80%.** The painting is hung
behind the window and slid around, so its outer edges are off-screen by
construction — that is what being behind a window means. A composition that
runs to the very edge loses those edges.

Optionally pass `--fg <png>` (with alpha) for a second plane close to the
aperture: leaves, a rim of rock, a rope. THAT is where this stops looking like
a slightly wobbly picture and starts looking like a diorama, because two planes
at different depths move by different amounts and one occludes the other. One
plane parallaxes against the walls; two parallax against each other.

PLAYBACK
--------
Frame 0 is the leftmost view, frame N-1 the rightmost, evenly spaced. CardView
picks the frame from the same `tilt` the foil shader uses — the pointer on a
desktop, the accelerometer on a phone — so the window follows the player's hand
instead of looping on a timer. A loop would read as a GIF; tracking the hand
reads as a card being turned, which is the thing the tutorial's card does and
the reason it is worth doing at all.
"""
import bpy
import bmesh
import json
import math
import os
import sys

import numpy as np

# The aperture, in Blender units. Width is 1.0 by definition — every other
# number here is a multiple of it — and the height is the card-art ratio.
AW = 1.0
AH = AW * 870.0 / 620.0

## How far behind the aperture the painting hangs. Only the SHADING reads this
## now (the wall's front-to-back ramp, and how much less a foreground plane
## travels than the back one); the parallax itself is SHIFT, below.
DEPTH = 0.38
## The foreground plane, when one is supplied, sits close to the glass so it
## barely moves and the painting slides underneath it.
FG_DEPTH = 0.10

## The parallax, end to end, as a fraction of the card's width. The painting
## travels this far across the window between the two extreme views, and the
## window's inner wall opens to half of it on whichever side you turn away from.
##
## This is now a DIRECT measurement rather than something that falls out of a
## camera. The first version built an off-axis perspective frustum — camera
## sliding sideways, lens shifted by exactly the amount that pins the aperture
## plane — which is the textbook construction and which I could not get to
## agree with Blender's own units: the end views came back 45% black, the
## painting shoved most of the way off the frame, the pin plainly not pinning.
##
## What replaced it needs no calibration at all. An ORTHOGRAPHIC camera has no
## projective term, so "the card is turned" is exactly a shear: every plane
## slides sideways in proportion to how far back it sits, and the window's
## reveal opens by the same amount. Placing that shear by hand is one
## multiplication per object, it is exact, and every number in this file is now
## in card-widths and can be read off the render with a ruler.
##
## The one thing it gives up is the perspective foreshortening of the wall
## faces. They are flat dark slabs either way — the emission ramp already
## carries their depth — so it is not visible.
SHIFT = 0.11
## Ortho camera pull-back. Nothing depends on it; it only has to clear the
## deepest plane.
CAM_Y = -3.0

## Oversize on the back plane: it has to still cover the frame at the extremes,
## which is the same statement as "its edges are never seen". 1.0 + SHIFT plus a
## little. The painting therefore shows about 86% of its width at rest — see
## "WHAT THE ART HAS TO BE" above.
BACK_FIT = 1.0 + SHIFT + 0.05

## Cell size, and how many views. 24 is enough that the sweep has no visible
## steps at hand size; the sheet is 6x4 of them.
CELL = (310, 435)
FRAMES = 24
COLS = 6


def srgb(h):
    return tuple((int(h[i:i + 2], 16) / 255.0) ** 2.2 for i in (0, 2, 4))


def quad(name, w, h, y, flip_normal=False):
    """A UV-mapped rectangle in the XZ plane at distance `y`, centred."""
    bm = bmesh.new()
    x0, x1 = -w * 0.5, w * 0.5
    z0, z1 = -h * 0.5, h * 0.5
    vs = [bm.verts.new((x0, y, z0)), bm.verts.new((x1, y, z0)),
          bm.verts.new((x1, y, z1)), bm.verts.new((x0, y, z1))]
    if flip_normal:
        vs.reverse()
    f = bm.faces.new(vs)
    uv = bm.loops.layers.uv.new()
    for loop in f.loops:
        p = loop.vert.co
        loop[uv].uv = ((p.x - x0) / (x1 - x0), (p.z - z0) / (z1 - z0))
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(o)
    return o


def walls(depth):
    """The LEFT and RIGHT inner faces of the window — the reveal, in a joiner's
    sense: the returns you see down the side of an opening.

    Two, not four. The camera only ever moves horizontally, so there is no
    vertical parallax and a top and bottom wall can never be revealed by the
    turn — they can only sit there as two permanent black bands across the art,
    which is exactly what the first render did. What is not revealed is not
    modelled.

    Each one is a trapezoid: the card's own height at the front, and the FULL
    height the camera can see at the back. That last part matters — cut it to
    the same height as the front and the corners open onto the painting with a
    notch missing out of the wall.

    They are what makes this a recess rather than a picture on a wall. Their
    edges are the ruler the parallax is measured against; without them the
    sliding painting is just a camera wobble.
    """
    hx, hz = AW * 0.5, AH * 0.5
    bm = bmesh.new()
    for s in (-1.0, 1.0):
        # Straight, not splayed. A window cut through a card has square returns,
        # and their apparent WIDTH is the depth cue.
        #
        # Vertex order matters: the two BACK verts of each side are the ones
        # set_shear() slides, and it finds them by index. 2 and 3 on the left
        # wall, 6 and 7 on the right.
        f0 = bm.verts.new((s * hx, 0.0, -hz))
        f1 = bm.verts.new((s * hx, 0.0, hz))
        b1 = bm.verts.new((s * hx, depth, hz))
        b0 = bm.verts.new((s * hx, depth, -hz))
        bm.faces.new((f0, f1, b1, b0))
    me = bpy.data.meshes.new("walls")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("walls", me)
    bpy.context.collection.objects.link(o)

    # Emissive with a front-to-back ramp, and NO light in the scene at all.
    #
    # The first version lit everything with an area key, which blew the painting
    # out to a pale wash — a rare's window has to show the SAME picture as the
    # framed printing of that card, and re-lighting it guarantees it will not.
    # So nothing here is lit: the art emits its own colours exactly as authored,
    # and the walls carry a baked gradient that does the job the key light was
    # there for. It is also deterministic, which a light rig at this scale is
    # not.
    mat = bpy.data.materials.new("walls")
    mat.use_nodes = True
    nt = mat.node_tree
    b = nt.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (0.0, 0.0, 0.0, 1.0)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    rng = nt.nodes.new("ShaderNodeMapRange")
    rng.inputs["From Min"].default_value = 0.0
    rng.inputs["From Max"].default_value = depth
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    near, far = srgb("5A606D"), srgb("101218")
    ramp.color_ramp.elements[0].color = (near[0], near[1], near[2], 1.0)
    ramp.color_ramp.elements[1].color = (far[0], far[1], far[2], 1.0)
    nt.links.new(geo.outputs["Position"], sep.inputs["Vector"])
    nt.links.new(sep.outputs["Y"], rng.inputs["Value"])
    nt.links.new(rng.outputs["Result"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Emission Color"])
    b.inputs["Emission Strength"].default_value = 1.0
    o.data.materials.append(mat)
    return o


def painted(o, path, dim=1.0):
    """Put a PNG on an object as pure EMISSION, so it renders as authored.

    Not lit. The painting inside a rare's window has to be the same picture as
    the one on the framed printing of that card, and any light rig at all
    guarantees it will not be: the first render came back a pale wash of the
    source. Emission at strength `dim` against a black base is a straight
    passthrough, and `dim` below 1.0 is how a plane gets pushed BACK in depth —
    which is the only thing that should ever darken it.
    """
    mat = bpy.data.materials.new(os.path.basename(path))
    mat.use_nodes = True
    mat.blend_method = "HASHED"          # so a --fg plane's alpha cuts out
    nt = mat.node_tree
    b = nt.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (0.0, 0.0, 0.0, 1.0)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(os.path.abspath(path))
    tex.image.colorspace_settings.name = "sRGB"
    tex.interpolation = "Cubic"
    nt.links.new(tex.outputs["Color"], b.inputs["Emission Color"])
    nt.links.new(tex.outputs["Alpha"], b.inputs["Alpha"])
    b.inputs["Emission Strength"].default_value = dim
    o.data.materials.append(mat)


def engine(sc):
    ids = [i.identifier for i in sc.bl_rna.properties["render"].fixed_type
           .bl_rna.properties["engine"].enum_items]
    return "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in ids else "BLENDER_EEVEE"


def build(art, fg):
    bpy.ops.wm.read_factory_settings(use_empty=True)

    # The painting, hung behind the aperture and oversized so its edges are
    # never in frame.
    span = AW * BACK_FIT
    back = quad("art", span, span * AH / AW, DEPTH)
    # 0.86, not 1.0: the back of a recess is in its own shade, and a painting
    # that reads at exactly the same brightness as the card around it is not
    # behind anything.
    painted(back, art, dim=0.86)

    wall = walls(DEPTH)

    front = None
    if fg:
        # Close to the glass, so it barely moves while the painting slides
        # underneath it. Two depths is where this stops being a wobble.
        fspan = AW * (1.0 + SHIFT * FG_DEPTH / DEPTH + 0.04)
        front = quad("fg", fspan, fspan * AH / AW, FG_DEPTH)
        painted(front, fg, dim=1.0)

    bpy.ops.object.camera_add(location=(0.0, CAM_Y, 0.0),
                              rotation=(math.pi * 0.5, 0.0, 0.0))
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    # HORIZONTAL, not AUTO. The render is portrait, so AUTO would fit
    # ortho_scale to the HEIGHT — and AW is a width.
    cam.data.sensor_fit = "HORIZONTAL"
    cam.data.ortho_scale = AW
    bpy.context.scene.camera = cam
    return cam, back, wall, front


def set_shear(back, wall, front, t):
    """Turn the card by `t` in -1..+1.

    Under an orthographic camera a turn is exactly a shear: each plane slides
    sideways in proportion to its depth, and the window's inner wall opens by
    the same amount on the side you are turning away from. Three lines, no
    projection to get wrong.
    """
    d = t * SHIFT * 0.5 * AW
    back.location.x = d
    if front is not None:
        front.location.x = d * (FG_DEPTH / DEPTH)
    # The wall's BACK edge travels with the painting; its front edge is the
    # card's own opening and never moves. Whichever side ends up outside the
    # frame simply is not seen — no need to hide it.
    hx = AW * 0.5
    for i, s in ((2, -1.0), (3, -1.0), (6, 1.0), (7, 1.0)):
        wall.data.vertices[i].co.x = s * hx + d
    wall.data.update()


def render_views(scene, tmp):
    cam, back, wall, front = scene
    sc = bpy.context.scene
    sc.render.engine = engine(sc)
    sc.render.film_transparent = False    # every pixel is inside the window
    sc.render.resolution_x, sc.render.resolution_y = CELL
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Standard"

    out = []
    for i in range(FRAMES):
        # -1 .. +1 across the turn. Frame 0 is the leftmost view.
        t = (i / float(FRAMES - 1)) * 2.0 - 1.0
        set_shear(back, wall, front, t)
        path = os.path.join(tmp, "view_%02d.png" % i)
        sc.render.filepath = path
        bpy.ops.render.render(write_still=True)
        out.append(path)
        print("VIEW %2d/%d  t=%+.3f  slide=%+.4f card-widths"
              % (i + 1, FRAMES, t, t * SHIFT * 0.5))
    return out


def pack(views, out_png):
    """Every view into one texture, so a rare card costs ONE texture unit.

    Godot reads a sprite sheet top-down and Blender hands back its pixels
    bottom-up, so the cell rows are written in reverse and the whole buffer is
    handed over in Blender's order. Getting this backwards produces a sheet that
    animates correctly but upside down, which is a confusing thing to debug from
    a screenshot.
    """
    rows = int(math.ceil(len(views) / float(COLS)))
    w, h = CELL
    sheet = np.zeros((rows * h, COLS * w, 4), dtype=np.float32)
    buf = np.zeros(w * h * 4, dtype=np.float32)
    for i, path in enumerate(views):
        img = bpy.data.images.load(path)
        # foreach_get, not pixels[:] — the slice builds a 540,000-element Python
        # list per view and the pack step ends up costing more than the render.
        img.pixels.foreach_get(buf)
        r, c = divmod(i, COLS)
        top = (rows - 1 - r) * h        # r counts down from the TOP of the sheet
        sheet[top:top + h, c * w:(c + 1) * w] = buf.reshape(h, w, 4)
        bpy.data.images.remove(img)
    out = bpy.data.images.new("sheet", COLS * w, rows * h, alpha=True)
    out.pixels.foreach_set(sheet.ravel())
    out.file_format = "PNG"
    out.filepath_raw = os.path.abspath(out_png)
    out.save()
    return rows


def one(art, out_dir, name, fg=None):
    """Render one card's window. Paths must already be absolute."""
    tmp = os.path.join(out_dir, "_views")
    os.makedirs(tmp, exist_ok=True)
    scene = build(art, fg)
    views = render_views(scene, tmp)
    png = os.path.join(out_dir, "%s.png" % name)
    rows = pack(views, png)
    for p in views:
        os.remove(p)
    os.rmdir(tmp)
    meta = {
        "frames": FRAMES, "cols": COLS, "rows": rows,
        "cell_w": CELL[0], "cell_h": CELL[1],
        # How much of the card's width the painting travels, end to end. The
        # game does not need it to play the sheet back; it is here so a future
        # pass can tell whether a rebuild changed the feel or only the picture.
        "parallax": SHIFT,
        "source": os.path.basename(art),
    }
    with open(os.path.join(out_dir, "%s.json" % name), "w") as fh:
        json.dump(meta, fh, indent=2)
    print("SHEET %s  %dx%d cells, %d frames, parallax %.1f%% of card width"
          % (os.path.basename(png), COLS, rows, FRAMES, meta["parallax"] * 100.0))


def repo_root():
    return os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                        "..", ".."))


def rarity_of(card_id):
    """What cards.json says this card is, or "" if it says nothing.

    Read rather than assumed, because the WINDOW IS A RARITY EFFECT. Nick,
    2026-09-01: "All rares will have the window effect." That makes the sheet a
    consequence of the card's rarity rather than a thing somebody remembered to
    render, and a rule that is only mostly followed is worse than no rule - so
    this file checks, and --all builds the whole set from the data.
    """
    path = os.path.join(repo_root(), "game", "data", "cards.json")
    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except (IOError, ValueError):
        return ""
    cards = data.get("cards", data)
    entry = cards.get(card_id)
    return entry.get("rarity", "") if isinstance(entry, dict) else ""


def every_rare_with_art():
    """(card_id, art path) for each RARE that has a painting to hang."""
    root = repo_root()
    path = os.path.join(root, "game", "data", "cards.json")
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
    cards = data.get("cards", data)
    out = []
    for cid, entry in sorted(cards.items()):
        if not isinstance(entry, dict) or entry.get("rarity") != "rare":
            continue
        art = os.path.join(root, "game", "assets", "cardart", "%s.png" % cid)
        if os.path.exists(art):
            out.append((cid, art))
    return out


def main():
    argv = sys.argv[sys.argv.index("--") + 1:]

    def opt(flag, default=None):
        return argv[argv.index(flag) + 1] if flag in argv else default

    out_dir = os.path.abspath(opt("--out",
                                  os.path.join(repo_root(), "game", "assets",
                                               "cardart3d")))
    os.makedirs(out_dir, exist_ok=True)

    if "--all" in argv:
        # Every rare that has art. Run it after a batch of paintings lands and
        # the rule "all rares have the window" is true again with one command.
        todo = every_rare_with_art()
        if not todo:
            print("no rare has art yet - nothing to build")
            return
        print("BUILDING %d rare window(s): %s"
              % (len(todo), ", ".join(c for c, _ in todo)))
        for cid, art in todo:
            one(art, out_dir, cid)
        return

    art = opt("--art")
    if not art:
        print("usage: rare3d.py -- --art <png> --name <card_id> [--out <dir>] "
              "[--fg <png>]")
        print("       rare3d.py -- --all        every rare that has art")
        return
    # ABSOLUTE, before anything touches the filesystem. Blender resolves a
    # relative render filepath against its own idea of the current blend rather
    # than the shell's cwd, and the first run of this wrote 24 frames to
    # C:\gamessets\... on the drive root while the pack step looked for them
    # under the repo. Every path from here down is absolute.
    art = os.path.abspath(art)
    name = opt("--name") or os.path.splitext(os.path.basename(art))[0]
    fg = opt("--fg")
    if fg:
        fg = os.path.abspath(fg)

    rarity = rarity_of(name)
    if rarity and rarity != "rare" and "--force" not in argv:
        print("REFUSED %s is %s, and the window is a RARE-only effect." % (name, rarity))
        print("        Pass --force if you mean it - but a common wearing a")
        print("        rare's treatment is how a rarity signal stops meaning")
        print("        anything.")
        return

    one(art, out_dir, name, fg)


main()
