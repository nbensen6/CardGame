"""Put a shot of the game next to Nick's drawing, at the same scale.

The builder kept matching *words about* the reference instead of the reference
(2026-10-06: an item said "bold outlines", TARGET.png has a thin warm line, and
the outline got thicker). Words drift; pixels do not. So before grading, the
builder looks at this pair rather than at an adjective.

    python tools/vs_target.py shot.png out.png            whole frame
    python tools/vs_target.py shot.png out.png --beast    just the beast
    python tools/vs_target.py shot.png out.png --hand     just the hand

Both halves are scaled so the beast is the same height in each, which is the
only way an outline weight or a crack width can be compared at all.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

TARGET = os.path.join("design", "art", "targets", "TARGET.png")
FONTS = os.path.join("game", "assets", "fonts", "KenneyBold.ttf")

# normalised crops, measured off TARGET.png and off a 1280x720 shot
REGIONS = {
    "--full": {"target": (0.0, 0.0, 1.0, 1.0), "shot": (0.0, 0.0, 1.0, 1.0)},
    "--beast": {"target": (0.22, 0.05, 0.85, 0.58), "shot": (0.38, 0.0, 0.72, 0.52)},
    "--hand": {"target": (0.12, 0.79, 0.88, 1.0), "shot": (0.12, 0.68, 0.80, 1.0)},
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
    tgt = crop(Image.open(os.path.join(root, TARGET)).convert("RGB"), region["target"])
    shot = crop(Image.open(paths[0]).convert("RGB"), region["shot"])

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
