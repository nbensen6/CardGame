"""Card art, rendered from the models rather than painted.

    blender --background --python tools/blender/cardart.py -- <out_dir> [card_id ...]

Same argument portraits.py already won: a picture MADE FROM the model stays
right when the model changes, which a Canva painting never would, and this
project already has a hunter/beast for every fight it needs art for. The
Frog has four painted cards (game/assets/cardart/); the Goblin Engineer,
this fight's other hunter, has zero. This is the first one made this way
instead of asked of Nick.

Differs from portraits.py in three ways, because a card's art is a
different job than a 34px party-panel face:

  * FULL BODY, not head-and-shoulders — a card has room, and StS's own bar
    (design/art/card-face-vs-sts.md) is a scene, not a headshot.
  * The 620x870 CARD_ART_SIZE aspect (CardView.CARD_ART_SIZE), not a square,
    so the camera is set up VERTICAL-fit: the vertical span is the number
    that means something (how much of the model's height fills the frame)
    and the width follows from the render's own aspect ratio.
  * Rendered on transparency and left there — tools/cardbg.py composites the
    themed backdrop as a separate, PIL-side step, the same division artprep.py
    already draws between "Blender renders the subject" and "a plain script
    finishes the pixels." Keeps this script re-runnable without re-deciding
    background colour, and keeps colour decisions in one place.

CARDS below is deliberately short. One card, verified end to end (rendered,
composited, checked in the real hand at 1:1), is worth more than a batch
nobody looked at — see design/guide/asset-loop.md's own case for that, which
applies just as much to a new pipeline as to a fifth pass on an old one.
"""
import bpy, math, os, sys
from mathutils import Vector

## card_id -> (model name, height-fraction to centre on, vertical span as a
## multiple of the model's own height, optional XY focus override).
## Full body, so `at` sits near mid-height rather than portraits.py's
## near-the-top default, and `span` is generous enough to leave a hand's
## worth of margin above and below rather than crop for a tight face.
CARDS = {
    "piston_punch": ("goblin_mech", 0.48, 1.43, None),
}

## The angle every character in this game is built to be seen from (shared
## with portraits.py and the fight camera itself) — reusing it means the card
## art and the in-fight model agree on which side is "the good side."
EYE = Vector((0.62, -1.0, 0.30))

## CardView.CARD_ART_SIZE (game/ui/card_view.gd) — kept in lockstep by hand,
## the same as portraits.py's own SIZE constant, because /core and this
## Blender-side tool cannot share a GDScript const.
OUT_W, OUT_H = 620, 870


def render(model_path, out_path, at, span, xy=None):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=model_path)
    for ob in [ob for ob in bpy.data.objects if ob.name.startswith("Footholds")]:
        bpy.data.objects.remove(ob)

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
    sc.display.shading.show_shadows = False
    sc.display.shading.show_cavity = True
    sc.render.film_transparent = True
    sc.view_settings.exposure = 0.75
    sc.render.resolution_x = OUT_W
    sc.render.resolution_y = OUT_H
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"

    loc = focus + EYE.normalized() * max(6.0, tall * 4.0)
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.data.type = "ORTHO"
    # VERTICAL fit: ortho_scale is the frame's height in world units, and the
    # width follows OUT_W/OUT_H automatically. Left at Blender's AUTO default
    # (fits the LARGER pixel dimension) ortho_scale would set the WIDTH
    # instead on this taller-than-wide canvas, and span would silently mean
    # the wrong axis.
    cam.data.sensor_fit = "VERTICAL"
    cam.data.ortho_scale = max(0.05, tall * span)
    cam.rotation_euler = (focus - loc).to_track_quat("-Z", "Y").to_euler()
    sc.camera = cam
    sc.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print("CARDART", os.path.basename(out_path))


def main():
    out_dir = sys.argv[sys.argv.index("--") + 1]
    here = os.path.dirname(os.path.abspath(__file__))
    cast = os.path.normpath(os.path.join(here, "..", "..", "game", "assets", "3d", "cast"))
    only = sys.argv[sys.argv.index("--") + 2:]
    missing = []
    for card_id, (model, at, span, xy) in CARDS.items():
        if only and card_id not in only:
            continue
        src = os.path.join(cast, model + ".glb")
        if not os.path.exists(src):
            missing.append(card_id)
            continue
        render(src, os.path.join(out_dir, card_id + ".png"), at, span, xy=xy)
    if missing:
        print("NO MODEL for %s" % ", ".join(missing))


if __name__ == "__main__":
    main()
