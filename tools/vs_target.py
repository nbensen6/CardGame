"""Put a shot of the game next to Nick's drawing, at the same scale.

The builder kept matching *words about* the reference instead of the reference
(2026-10-06: an item said "bold outlines", TARGET.png has a thin warm line, and
the outline got thicker). Words drift; pixels do not. So before grading, the
builder looks at this pair rather than at an adjective.

    python tools/vs_target.py shot.png out.png            whole frame
    python tools/vs_target.py shot.png out.png --beast    just the beast
    python tools/vs_target.py shot.png out.png --hand     just the hand
    python tools/vs_target.py shot.png out.png --square   TARGET vs the centred square of the shot
    python tools/vs_target.py shot.png out.png --stones   just the staircase of slabs, cut from the same square
    python tools/vs_target.py shot.png out.png --fist     the raised fist and its flame, cut from the same square
    python tools/vs_target.py shot.png out.png --chest    the sternum Y and the chest cracks, cut from the same square
    python tools/vs_target.py shot.png out.png --frog     the Frog on its pedestal, cut from the same square
    python tools/vs_target.py shot.png out.png --ear      the left ear and the sky and cliff top beside it, cut from the same square
    python tools/vs_target.py shot.png out.png --floor    the floor from the lava line to the hand, cut from the same square

`--square` is the 1:1 test (Nick, 2026-10-08): TARGET.png is square, the game
is 16:9, so the game's centred 720x720 square must hold TARGET's picture with
everything in the same place. What lies outside that square is extra scene.

Every close-up is TARGET's box mapped through the shot's centred square, so
both halves show the same part of the picture at the same scale: an element
drawn at TARGET's size shows at the same size in the pair.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

TARGET = os.path.join("design", "art", "targets", "TARGET.png")
FONTS = os.path.join("game", "assets", "fonts", "KenneyBold.ttf")

# normalised crops, measured off TARGET.png and off a 1280x720 shot
REGIONS = {
    "--full": {"target": (0.0, 0.0, 1.0, 1.0), "shot": (0.0, 0.0, 1.0, 1.0)},
    # close-ups are TARGET boxes mapped through the centred square, so the
    # game half shows the same part of the square at the same scale
    "--beast": {"target": (0.22, 0.05, 0.85, 0.58), "shot": (0.3425, 0.05, 0.6969, 0.58)},
    "--hand": {"target": (0.12, 0.79, 0.88, 1.0), "shot": (0.2863, 0.79, 0.7137, 1.0)},
    # the centred square of a 1280x720 shot: x 280..1000
    "--square": {"target": (0.0, 0.0, 1.0, 1.0), "shot": (0.21875, 0.0, 0.78125, 1.0)},
    # the slab staircase, from the big lowest slab (above and left of the frog) up to the sternum. The
    # shot box is the target box mapped through the --square test (x 280 +
    # 0.703 t, y 0.703 t), so the close-up zooms the same place 1:1 (builder
    # 2026-10-08; the older box was fitted to the beast, not to the square).
    "--stones": {"target": (0.25, 0.33, 0.66, 0.60), "shot": (0.3594, 0.33, 0.5891, 0.60)},
    # the raised fist and its flame, top left of the square (builder
    # 2026-10-09: --beast cuts the flame off at its left edge)
    "--fist": {"target": (0.06, 0.04, 0.38, 0.36), "shot": (0.2525, 0.04, 0.4325, 0.36)},
    # the floor between the lava line and the hand, the square's full width
    # (builder 2026-10-09: a grader asked for a floor close-up to judge the
    # seams and slabs against)
    # the Frog on its pedestal, cut from the same square
    "--frog": {"target": (0.30, 0.55, 0.70, 0.80), "shot": (0.21875 + 0.30 * 0.5625, 0.55, 0.21875 + 0.70 * 0.5625, 0.80)},
    # the chest: the sternum Y, the seam under it and the pec cracks
    # (builder 2026-10-09: a grader asked for a zoomed chest crop, the 1x
    # pairs being too small to judge the cracks' width and sharpness)
    "--chest": {"target": (0.40, 0.28, 0.64, 0.52), "shot": (0.21875 + 0.40 * 0.5625, 0.28, 0.21875 + 0.64 * 0.5625, 0.52)},
    # the left ear, the sky and cliff top beside it (builder 2026-10-09: the
    # 1x pairs were too small to see a smudge there either way)
    "--ear": {"target": (0.28, 0.04, 0.48, 0.30), "shot": (0.21875 + 0.28 * 0.5625, 0.04, 0.21875 + 0.48 * 0.5625, 0.30)},
    "--floor": {"target": (0.0, 0.52, 1.0, 0.78), "shot": (0.21875, 0.52, 0.78125, 0.78)},
}


def crop(im, box):
    w, h = im.size
    return im.crop((int(box[0] * w), int(box[1] * h),
                    int(box[2] * w), int(box[3] * h)))


def label(d, x, y, text, fill):
    try:
        f = ImageFont.truetype(FONTS, 20)
    except OSError:
        f = ImageFont.load_default(20)
    d.text((x, y), text, font=f, fill=fill)


def main():
    args = [a for a in sys.argv[1:]]
    flags = [a for a in args if a.startswith("--")]
    paths = [a for a in args if not a.startswith("--")]
    if len(paths) != 2:
        print(__doc__)
        return 2
    region = REGIONS[flags[0]] if flags and flags[0] in REGIONS else REGIONS["--full"]

    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    full = Image.open(os.path.join(root, TARGET)).convert("RGB")
    shot_full = Image.open(paths[0]).convert("RGB")
    # Same detail on both sides (builder 2026-10-08): 1:1 means TARGET in the
    # shot's centred square, so TARGET is first brought to that square's
    # pixels (720 for a 1280x720 shot). Cropped from its 1024 original, a
    # close-up showed TARGET with ~1.4x the game's resolution and every
    # line in the game half read thinner and softer than the same pixels are.
    sq = min(shot_full.size)
    if full.height > sq:
        full = full.resize((int(full.width * sq / full.height), sq), Image.LANCZOS)
    tgt = crop(full, region["target"])
    shot = crop(shot_full, region["shot"])

    # one height, so a line weight on the left means the same as on the right
    h = 640
    tgt = tgt.resize((max(1, int(tgt.width * h / tgt.height)), h), Image.LANCZOS)
    shot = shot.resize((max(1, int(shot.width * h / shot.height)), h), Image.LANCZOS)

    gap, head = 14, 40
    im = Image.new("RGB", (tgt.width + shot.width + gap * 3, h + head + gap),
                   (20, 19, 23))
    d = ImageDraw.Draw(im)
    label(d, gap, 10, "NICK'S DRAWING", (226, 196, 120))
    label(d, gap * 2 + tgt.width, 10, "THE GAME", (150, 226, 160))
    im.paste(tgt, (gap, head))
    im.paste(shot, (gap * 2 + tgt.width, head))
    im.save(paths[1])
    print("wrote", paths[1])
    return 0


if __name__ == "__main__":
    sys.exit(main())
