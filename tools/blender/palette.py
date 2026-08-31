"""Push the palette apart.

    python tools/blender/palette.py            apply the adjustments below
    python tools/blender/palette.py --report   print every swatch, change nothing

Nick, 2026-08-31: "Darken the rock family, warm the organics, and give each
biome a dominant hue."

The biome hue is done in light (combat_3d.BIOME) because that costs no rebuild.
This file does the other half, and the measurement is what makes it necessary:

    STEEL 169   SLATE 160   SILVER 217   PEWTER 140   STONE 116

Every usable rock swatch sits in the upper half of the range, and the next one
down is CHARCOAL at 56. So a stone beast has no dark end to be modelled in — it
is built out of five shades of light grey, which is exactly why the Crag Pup and
the Stone Warden read as pale blobs no matter how they are lit.

ADJUST below is the whole edit. Each entry is (luminance multiplier, warmth),
where warmth rotates the colour toward orange and lifts saturation a little; it
is deliberately small, because the palette is shared by nineteen characters and
a big shove would restyle the entire cast at once.

A warning for anyone changing a swatch by a large amount. Until 2026-08-31 the
UVs in kenney.swatch() sampled the FIRST TEXEL ROW of a cell rather than its
middle, flush against whatever sat in the row above. That was invisible while
neighbouring swatches were close in value, and darkening the rock family opened
a real gap across the boundary — which came back as fine speckle crawling over
every large curved surface in the game. The UV is centred now, so there are 16
pixels of margin, but it is the kind of thing that only shows up when a change
is big enough. Look at a render after touching this file.

IDEMPOTENT, on purpose. The first run copies colormap.png to colormap_base.png
and every run after derives from that base, so running it twice does not darken
the rock twice and the numbers below always mean what they say.

Every model carries the atlas embedded in its .glb, so after this run:

    tools/blender/build.cmd all
"""
import os
import shutil
import sys
import colorsys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
LIVE = os.path.join(HERE, "colormap.png")
BASE = os.path.join(HERE, "colormap_base.png")

## Where each named swatch sits in the atlas. Mirrors kenney.py's own table —
## kept here rather than imported because kenney.py needs Blender to load.
CELLS = {
    192: ["ORANGE", "TANGERINE", "RED", "RUST", "BLUE", "INDIGO", "ICE", "SKY",
          "LILAC", "VIOLET", "PINK", "ORCHID"],
    320: ["STEEL", "SLATE", "WHITE", "SILVER", "PEACH", "CLAY", "BROWN", "UMBER",
          "SAND", "TAN", "CREAM", "WHEAT", "MINT", "GREEN", "GOLD", "AMBER"],
    448: ["BLUSH", "ROSE", "PERIWINKLE", "IRIS", "LINEN", "BISQUE", "PUMPKIN",
          "CARROT", "CORAL", "BRICK", "CHARCOAL", "GRAPHITE", "PEWTER", "STONE",
          "NAVY", "MIDNIGHT"],
}

## (brightness multiplier, warmth). warmth > 0 turns a colour toward orange and
## saturates it; warmth < 0 turns it toward blue and cools it.
ADJUST = {
    # Rock. Down, and slightly cooler, so the family finally spans dark to light
    # instead of light to lighter. STONE and PEWTER take the biggest cut because
    # they are the two doing most of the work on every stone creature.
    "STEEL":    (0.78, -0.04),
    "SLATE":    (0.74, -0.05),
    "SILVER":   (0.82, -0.03),
    "PEWTER":   (0.70, -0.05),
    "STONE":    (0.66, -0.06),
    "NAVY":     (0.92, -0.03),
    "MIDNIGHT": (0.92, -0.03),

    # Organics. Warmer and a touch richer — the greens were cold and chalky next
    # to the browns, which made every forest read as one flat mass.
    "GREEN":    (0.94, 0.10),
    "MINT":     (0.92, 0.09),
    "BROWN":    (1.00, 0.08),
    "UMBER":    (0.96, 0.08),
    "CLAY":     (1.00, 0.07),
    "TAN":      (1.00, 0.05),
    "SAND":     (1.00, 0.04),
    "WHEAT":    (1.00, 0.04),
}


def warm(rgb, amount):
    """Rotate hue toward orange (h=0.08) and lift saturation, gently."""
    r, g, b = [c / 255.0 for c in rgb]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    target = 0.08 if amount > 0 else 0.58
    step = abs(amount)
    # shortest way round the wheel
    d = target - h
    if d > 0.5:
        d -= 1.0
    elif d < -0.5:
        d += 1.0
    h = (h + d * step) % 1.0
    s = min(1.0, s * (1.0 + step * 0.9))
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return (r * 255.0, g * 255.0, b * 255.0)


def lum(rgb):
    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]


def cell_colour(im, x, y):
    return im.getpixel((x + 8, y + 8))


def main():
    report = "--report" in sys.argv
    if not os.path.exists(BASE):
        if report:
            print("no colormap_base.png yet — reporting the live atlas")
        else:
            shutil.copy2(LIVE, BASE)
            print("kept the untouched atlas as colormap_base.png")
    src = Image.open(BASE if os.path.exists(BASE) else LIVE).convert("RGB")
    out = src.copy()
    px = out.load()

    changed = 0
    for y, names in sorted(CELLS.items()):
        for i, name in enumerate(names):
            x = 16 + i * 32
            was = cell_colour(src, x, y)
            if name not in ADJUST:
                if report:
                    print("     %-11s rgb%-16s lum %5.1f" % (name, str(was), lum(was)))
                continue
            mul, w = ADJUST[name]
            now = warm(was, w) if w else tuple(float(c) for c in was)
            now = tuple(max(0, min(255, int(round(c * mul)))) for c in now)
            print("%-4s %-11s rgb%-16s lum %5.1f  ->  rgb%-16s lum %5.1f"
                  % ("ROCK" if mul < 0.95 and w <= 0 else "ORG", name,
                     str(was), lum(was), str(now), lum(now)))
            if report:
                continue
            # Transform EVERY pixel in the cell, not just the ones matching the
            # centre sample.
            #
            # The first version repainted only exact matches, on the theory that
            # a swatch is one flat colour with maybe a border. It is not: STONE's
            # cell holds seventeen shades and GREEN's holds twenty-nine — the
            # atlas paints each swatch as a slight gradient. So that version
            # changed 96 pixels of STONE's 1024 and none of GREEN's at all,
            # leaving cells that were half old and half new. Sampled through a
            # mipmap that reads as fine speckle crawling over every curved
            # surface, which is exactly what turned up on the Crag Pup's head.
            for dy in range(32):
                for dx in range(32):
                    at = (x - 16 + dx, y + dy)
                    c = src.getpixel(at)
                    c = warm(c, w) if w else tuple(float(v) for v in c)
                    px[at] = tuple(max(0, min(255, int(round(v * mul)))) for v in c)
            changed += 1

    if report:
        return
    out.save(LIVE)
    print("\nrewrote %d swatches in %s" % (changed, os.path.basename(LIVE)))
    print("Every model has the atlas embedded in its .glb, so nothing on screen "
          "changes until:  tools\\blender\\build.cmd all")


main()
