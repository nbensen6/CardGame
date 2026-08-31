"""The game's colour palette, as a sheet you can open in Canva.

    python tools/blender/palette_sheet.py

Writes design/palette.png — every swatch with its name and hex, then a strip per
hunter showing the colours that hunter's own MODEL is built from.

Nick wants a different card border per character. The colours for that already
exist and are not a matter of taste: the palette is one 512x512 atlas
(tools/blender/colormap.png) that every model in the game shares, so a border
mixed from these sits beside the 3D art instead of near it. Every hex here is
sampled from that atlas rather than typed, so the sheet cannot drift from the
game — re-run it after tools/blender/palette.py and it follows.

The per-hunter strips are counted, not chosen. Each one is the five swatches
that appear most often in that character's build script, so the Frog's strip is
green because the Frog is green, and if someone reskins him it changes.
"""
import io
import os
import re
from collections import Counter

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
ATLAS = os.path.join(HERE, "colormap.png")
OUT = os.path.join(ROOT, "design", "palette.png")

## Mirrors kenney.py's own table. Kept here rather than imported because
## kenney.py needs Blender to load and this is a plain Pillow script.
ROWS = [
    (192, ["ORANGE", "TANGERINE", "RED", "RUST", "BLUE", "INDIGO", "ICE", "SKY",
           "LILAC", "VIOLET", "PINK", "ORCHID"]),
    (320, ["STEEL", "SLATE", "WHITE", "SILVER", "PEACH", "CLAY", "BROWN",
           "UMBER", "SAND", "TAN", "CREAM", "WHEAT", "MINT", "GREEN", "GOLD",
           "AMBER"]),
    (448, ["BLUSH", "ROSE", "PERIWINKLE", "IRIS", "LINEN", "BISQUE", "PUMPKIN",
           "CARROT", "CORAL", "BRICK", "CHARCOAL", "GRAPHITE", "PEWTER",
           "STONE", "NAVY", "MIDNIGHT"]),
]

HUNTERS = [
    ("The Frog", "frog"),
    ("The Vine-Weaver", "vine_weaver"),
    ("The Mountain Climbers", "mountain_climbers"),
    ("The Goblin Engineer", "goblin_mech"),
    ("The Lightbearer", "lightbearer"),
]

CELL = 96
GAP = 10
PAD = 34
NAMES = [n for _, row in ROWS for n in row]


def font(size):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def hexes():
    """Every swatch's real colour, sampled from the atlas the game ships."""
    im = Image.open(ATLAS).convert("RGB")
    out = {}
    for y, names in ROWS:
        for i, name in enumerate(names):
            out[name] = im.getpixel((16 + i * 32, y + 16))
    return out


def hunter_palettes():
    """The five swatches each hunter's model actually uses most."""
    want = re.compile(r"\b(" + "|".join(NAMES) + r")\b")
    out = []
    for label, script in HUNTERS:
        path = os.path.join(HERE, script + ".py")
        if not os.path.exists(path):
            continue
        body = io.open(path, encoding="utf-8").read()
        # Skip the import line, or every model looks like it uses everything.
        body = "\n".join(l for l in body.split("\n")
                         if not l.strip().startswith(("from ", "import ")))
        top = [n for n, _ in Counter(want.findall(body)).most_common(5)]
        out.append((label, top))
    return out


def swatch(d, x, y, rgb, name, small, tiny):
    d.rectangle([x, y, x + CELL, y + CELL], fill=rgb, outline=(70, 74, 84))
    # Label under the chip, not on it: half these colours are dark and half are
    # near white, and no single ink reads on both.
    d.text((x + 2, y + CELL + 5), name, fill=(232, 232, 236), font=small)
    d.text((x + 2, y + CELL + 22), "#%02X%02X%02X" % rgb, fill=(150, 154, 164),
           font=tiny)


def main():
    pal = hexes()
    hunters = hunter_palettes()
    cols = max(len(r[1]) for r in ROWS)
    w = PAD * 2 + cols * CELL + (cols - 1) * GAP
    rows_h = len(ROWS) * (CELL + 46 + GAP)
    hunt_h = len(hunters) * (CELL + 46 + GAP + 16)
    h = PAD * 2 + 96 + rows_h + 56 + hunt_h

    im = Image.new("RGB", (w, h), (22, 23, 28))
    d = ImageDraw.Draw(im)
    big, mid, small, tiny = font(30), font(19), font(15), font(13)

    d.text((PAD, PAD), "Titan-Slayers palette", fill=(240, 240, 244), font=big)
    d.text((PAD, PAD + 40),
           "Every colour in the game, sampled from tools/blender/colormap.png. "
           "Mix borders from these and they sit beside the 3D art.",
           fill=(150, 154, 164), font=mid)

    y = PAD + 96
    for _, names in ROWS:
        for i, name in enumerate(names):
            swatch(d, PAD + i * (CELL + GAP), y, pal[name], name, small, tiny)
        y += CELL + 46 + GAP

    y += 18
    d.text((PAD, y), "Per hunter - counted from each model's own build script",
           fill=(240, 240, 244), font=mid)
    y += 38
    for label, names in hunters:
        d.text((PAD, y), label, fill=(232, 232, 236), font=mid)
        y += 26
        for i, name in enumerate(names):
            swatch(d, PAD + i * (CELL + GAP), y, pal[name], name, small, tiny)
        y += CELL + 46 + GAP

    im.save(OUT)
    print("PALETTE %s (%dx%d)" % (OUT, w, h))
    for label, names in hunters:
        print("  %-24s %s" % (label, "  ".join(
            "%s #%02X%02X%02X" % ((n,) + pal[n]) for n in names)))


main()
