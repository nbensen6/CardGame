"""Portraits, rendered from the models rather than borrowed.

Fifteen Kenney animal photos have been standing in for five hunters and fourteen
beasts — and there were only fifteen for nineteen characters, so the Mire
Snapper and the Root Lurker were the same crocodile and two beasts shared a
penguin. They are also the last Kenney art on screen during a fight: the party
panel shows one every second you play.

Every one of those characters now has a body, so the portrait can just BE the
character:

    blender --background --python tools/blender/portraits.py -- <out_dir>

Rendered orthographic, three-quarter, on transparency, framed on the part of the
model that reads as its face. Because they come from the models, they stay
right: change a beast and its portrait changes with it, which a painted one
never would.

FOCUS below is the one hand-tuned thing. "The face" is not a fraction of the
bounding box on a creature that is mostly jaw, or mostly tail, so a few models
say where to look.
"""
import bpy, math, os, sys
from mathutils import Vector

## Who gets a portrait, and how to frame it: (fraction of the height to centre
## on, how much of the height to fit in the frame). Default is head-and-
## shoulders near the top; the exceptions are creatures whose face is not there.
FOCUS = {
    "frog": (0.71, 0.75), "vine_weaver": (0.77, 0.67),
    "mountain_climbers": (0.73, 0.72), "goblin_mech": (0.67, 0.84),
    "lightbearer": (0.69, 0.78),

    "stone_warden": (0.73, 0.67), "gale_serpent": (0.87, 0.44),
    "drowned_colossus": (0.83, 0.49), "sunken_warden": (0.81, 0.49),
    "crag_pup": (0.60, 0.90), "bramble_hog": (0.54, 1.01),
    "bounder": (0.64, 0.84), "mire_snapper": (0.53, 1.13),
    "frost_sentinel": (0.70, 0.75), "grove_bear": (0.64, 0.81),
    "root_lurker": (0.60, 0.96), "sky_snapper": (0.66, 0.84),
    "riftling": (0.75, 0.67), "shifting_idol": (0.72, 0.70),
    "husk_beetle": (0.42, 1.15), "gloom_moth": (0.55, 1.05),
    "bog_leech": (0.45, 1.35), "thrasher": (0.35, 1.10),
    "silk_widow": (0.45, 1.35), "boulder_ram": (0.34, 1.35),
    "cinder_jackal": (0.45, 1.60), "brine_urchin": (0.62, 1.30),
    "clot_toad": (0.48, 1.35), "flicker_stag": (0.80, 0.62),
    "eyrie_hawk": (0.78, 0.60), "glyph_tortoise": (0.58, 1.00),
    "riptide_eel": (0.873, 0.62), "yoke_ox": (0.55, 1.00),
}

## Per-character override of the focus point's X/Y, for a body the bounding-
## box-centre assumption below gets wrong. Every other character's head sits
## close enough to its own bounding box's X/Y centre that FOCUS's "at" alone
## (which only moves the focus up/down in Z) is enough. Riptide Eel breaks
## that: it is reared up AND long in Y (tail at +1.6, head at -1.7), so the
## bbox-centre in X/Y lands near the SIGIL on its neck, not the face - a
## generic render centred there was caught only by looking at it, not by
## anything that checks the model. Name an explicit focus point here rather
## than bend the shared formula for one outlier.
FOCUS_XY = {
    "riptide_eel": (0.02, -1.35),
}

## Three-quarter and a little above: the angle every character in this game was
## built to be seen from, because it is the angle the fight camera uses.
EYE = Vector((0.62, -1.0, 0.30))
SIZE = 512


def look(model_path, out_path, at, span, xy=None):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=model_path)

    co = [o.matrix_world @ v.co for o in bpy.data.objects if o.type == "MESH"
          for v in o.data.vertices]
    lo = Vector((min(c.x for c in co), min(c.y for c in co), min(c.z for c in co)))
    hi = Vector((max(c.x for c in co), max(c.y for c in co), max(c.z for c in co)))
    tall = hi.z - lo.z
    fx, fy = xy if xy is not None else ((lo.x + hi.x) * 0.5, (lo.y + hi.y) * 0.5)
    focus = Vector((fx, fy, lo.z + tall * at))

    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.display.shading.light = "STUDIO"
    sc.display.shading.color_type = "TEXTURE"
    sc.display.shading.show_shadows = False      # a portrait is not a diorama
    sc.display.shading.show_cavity = True        # but the creases should show
    sc.render.film_transparent = True            # the UI draws its own frame
    # Lifted, because these are shown at 34 PIXELS in the party panel and again
    # small on a card. Studio lighting that reads fine on a 500px preview turns
    # a dark beast into a smudge at that size.
    sc.view_settings.exposure = 0.75
    sc.render.resolution_x = sc.render.resolution_y = SIZE
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"

    # EYE is where the camera STANDS relative to the subject, the same way
    # preview.py reads: out to the right, in FRONT (-Y, which is the direction
    # these models are built to face) and a little above. Subtracting it instead
    # puts the camera behind and below, which renders the back of a head from
    # underneath and is not obviously wrong until you look at nineteen of them.
    loc = focus + EYE.normalized() * max(6.0, tall * 4.0)
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = max(0.05, tall * span)
    cam.rotation_euler = (focus - loc).to_track_quat("-Z", "Y").to_euler()
    sc.camera = cam
    sc.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print("PORTRAIT", os.path.basename(out_path))


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    here = os.path.dirname(os.path.abspath(__file__))
    cast = os.path.normpath(os.path.join(here, "..", "..", "game", "assets",
                                         "3d", "cast"))
    missing = []
    for name, (at, span) in FOCUS.items():
        src = os.path.join(cast, name + ".glb")
        if not os.path.exists(src):
            missing.append(name)
            continue
        look(src, os.path.join(out_dir, name + ".png"), at, span,
             xy=FOCUS_XY.get(name))
    if missing:
        print("NO MODEL for %s — those keep whatever portrait they had"
              % ", ".join(missing))


if __name__ == "__main__":
    main()
