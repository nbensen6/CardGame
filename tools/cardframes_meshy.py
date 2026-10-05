"""Put our real cards inside the Meshy-generated frame templates.

The generations in design/art/cards/meshy/ are 1024x1024 pictures of an empty
frame. A frame is only judgeable with content in it at the size it is played
at, so this crops the card out of each generation, drops our art, name, cost,
type and rules into the panels, and lays the three cards out at 3x and again
at true hand size.

    python tools/cardframes_meshy.py

BOXES are measured by eye off each generation, normalised 0-1 against the
cropped card. They are mockup numbers; the real frame will be a nine-patch
with these boxes authored in card_view.gd.
"""

import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cardframes as cf

SRC = os.path.join("design", "art", "cards", "meshy")
W, H = 160, 224
S = 3

# crop: the card's bounds inside the 1024 square
# title/art/type/text: panel boxes, normalised against that crop
# light: True when rules text must be dark on a pale panel
TEMPLATES = {
    "A1-obsidian": {
        "label": "A1  obsidian slab",
        "crop": (168, 18, 858, 1002),
        "cost": (0.055, 0.045, 0.145, 0.110),
        "title": (0.17, 0.045, 0.95, 0.115),
        "art": (0.095, 0.145, 0.905, 0.565),
        "type": (0.11, 0.585, 0.90, 0.640),
        "text": (0.11, 0.665, 0.90, 0.925),
        "light": False,
    },
    "A2-forged": {
        "label": "A2  forged iron and runes",
        "crop": (175, 55, 855, 990),
        "cost": (0.055, 0.055, 0.185, 0.185),
        "title": (0.22, 0.075, 0.93, 0.155),
        "art": (0.115, 0.185, 0.885, 0.565),
        "type": (0.125, 0.600, 0.875, 0.655),
        "text": (0.125, 0.680, 0.875, 0.930),
        "light": False,
    },
    "B1-printed": {
        "label": "B1  printed card",
        "crop": (163, 8, 862, 1010),
        "cost": (0.80, 0.085, 0.905, 0.140),
        "title": (0.20, 0.085, 0.79, 0.140),
        "art": (0.175, 0.160, 0.825, 0.570),
        "type": (0.20, 0.585, 0.80, 0.638),
        "text": (0.20, 0.655, 0.80, 0.915),
        "light": True,
    },
    "B2-foil": {
        "label": "B2  gold and gems - square, proportions off",
        "crop": (0, 0, 1024, 1024),
        "cost": (0.03, 0.03, 0.12, 0.12),
        "title": (0.24, 0.085, 0.75, 0.165),
        "art": (0.115, 0.195, 0.905, 0.530),
        "type": (0.10, 0.555, 0.90, 0.610),
        "text": (0.115, 0.630, 0.885, 0.925),
        "light": True,
        "plate_light": True,
    },
}


def box(spec, key, w, h):
    x0, y0, x1, y1 = spec[key]
    return int(x0 * w), int(y0 * h), int(x1 * w), int(y1 * h)


def build(name, spec, card):
    """One card: the template, cropped and filled."""
    im = Image.open(os.path.join(SRC, name + ".png")).convert("RGB")
    im = im.crop(spec["crop"]).resize((W * S, H * S), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    w, h = im.size

    ax0, ay0, ax1, ay1 = box(spec, "art", w, h)
    if card["art"]:
        im.paste(cf.art_for(card, (ax1 - ax0, ay1 - ay0)), (ax0, ay0))

    tx0, ty0, tx1, ty1 = box(spec, "title", w, h)
    pale = spec.get("plate_light", False)
    f = cf.fit(d, card["name"], "KenneyBold.ttf", int((ty1 - ty0) * 0.78), tx1 - tx0)
    d.text((tx0, ty0 + (ty1 - ty0 - f.size) / 2), card["name"], font=f,
           fill=(28, 22, 18) if pale else (240, 232, 220))

    cx0, cy0, cx1, cy1 = box(spec, "cost", w, h)
    f = cf.font("KenneyBold.ttf", int((cy1 - cy0) * 0.70))
    d.text((cx0 + (cx1 - cx0 - d.textlength(card["cost"], font=f)) / 2,
            cy0 + (cy1 - cy0 - f.size) / 2), card["cost"], font=f,
           fill=(28, 22, 18) if pale else (252, 238, 214))

    yx0, yy0, yx1, yy1 = box(spec, "type", w, h)
    f = cf.font("KenneyFutureNarrow.ttf", int((yy1 - yy0) * 0.52))
    d.text((yx0 + 4 * S, yy0 + (yy1 - yy0 - f.size) / 2), card["type"].upper(),
           font=f, fill=(60, 48, 36) if pale else (206, 176, 136))

    rx0, ry0, rx1, ry1 = box(spec, "text", w, h)
    cf.rules(d, (rx0 + 3 * S, ry0 + 4 * S, rx1 - 3 * S, ry1), card["text"],
             cf.font("KenneyBold.ttf", 9 * S), light=not spec["light"])
    return im


def sheet(name, spec):
    cards = [build(name, spec, c) for c in cf.CARDS]
    gap = 6 * S
    head = 26 * S
    width = len(cards) * W * S + gap * (len(cards) + 1)
    im = Image.new("RGB", (width, head + H * S + gap + H + gap * 2), (24, 22, 26))
    ImageDraw.Draw(im).text((gap, gap), spec["label"],
                            font=cf.font("KenneyBold.ttf", 13 * S),
                            fill=(236, 230, 220))
    x = gap
    for c in cards:
        im.paste(c, (x, head))
        x += W * S + gap
    x, y = gap, head + H * S + gap
    for c in cards:
        im.paste(c.resize((W, H), Image.LANCZOS), (x, y))
        x += W + gap
    return im


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    cf.S = S
    for name, spec in TEMPLATES.items():
        p = os.path.join(SRC, "filled-%s.png" % name)
        sheet(name, spec).save(p)
        print("wrote", p)


if __name__ == "__main__":
    main()
