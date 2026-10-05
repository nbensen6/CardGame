"""Split the A1 frame into a tintable base + glow pair, and mock it in use.

Nick picked A1 and asked for two things: the ember colour has to be per
character, and the numbers have to sit inside their sockets.

The generation bakes the orange in, so it is split into two files:

    game/assets/ui/card_frame_a1_base.png   neutral stone, no ember
    game/assets/ui/card_frame_a1_glow.png   white glow on transparent

In game those are two stacked TextureRects; the glow one gets
`self_modulate = <seat colour>` and nothing else changes. That is the same
trick combat_3d.gd already uses for SLOT_TINT.

    python tools/cardframe_a1.py     # writes the pair + design/art/cards/a1-*.png

BOX numbers below are measured off the generation, normalised against the
cropped card, and are what card_view.gd should author once this ships.
"""

import colorsys
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cardframes as cf

SRC = os.path.join("design", "art", "cards", "meshy", "A1-obsidian.png")
ASSETS = os.path.join("game", "assets", "ui")
OUT = os.path.join("design", "art", "cards")
CROP = (168, 18, 858, 1002)          # the card inside the 1024 square
W, H = 160, 224
S = 3

# every box normalised 0-1 against the card; the socket is a circle, so it is
# centre + radius rather than a rect -- the cost has to be centred IN it
SOCKET = (0.126, 0.0874, 0.0478)
TITLE = (0.205, 0.045, 0.945, 0.130)
ART = (0.095, 0.150, 0.905, 0.560)
TYPE = (0.112, 0.585, 0.900, 0.640)
TEXT = (0.112, 0.665, 0.900, 0.925)

# one per seat. The first two are combat_3d.gd's SLOT_TINT, so the cards match
# the markers already on the floor.
TINTS = [
    ("ember", (236, 120, 40)),
    ("frog", (115, 242, 128)),
    ("climber", (140, 209, 255)),
    ("weaver", (186, 126, 236)),
    ("lightbearer", (248, 214, 120)),
]


def split():
    """Separate the baked ember from the stone.

    Returns (base, glow): base is the frame with the ember neutralised back to
    stone, glow is an L mask of where the ember was. Keeping them apart is the
    whole point -- a baked orange PNG cannot be recoloured per character.
    """
    im = Image.open(SRC).convert("RGB").crop(CROP)
    w, h = im.size
    px = im.load()
    glow = Image.new("L", (w, h), 0)
    gp = glow.load()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            hh, ss, vv = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            # ember is the only saturated orange on the card
            # tight: the veins are the ember, the warm cast on the stone is not
            if 0.0 < hh < 0.13 and ss > 0.55 and vv > 0.45:
                gp[x, y] = int(255 * min(1.0, (ss - 0.55) / 0.45 * vv))
    # the WHOLE slab goes neutral, not just the vein. A frame that keeps the
    # generation's warm cast still looks orange once tinted blue, which is the
    # thing Nick asked to be rid of -- all the colour has to come from the glow.
    lum = im.convert("L")
    stone = Image.merge("RGB", [
        lum.point(lambda v: min(255, int(v * 0.96))),
        lum.point(lambda v: min(255, int(v * 0.98))),
        lum.point(lambda v: min(255, int(v * 1.08))),
    ])
    # where the vein was, drop to shadow so it does not read as a white scar
    dark = stone.point(lambda v: int(v * 0.34))
    base = Image.composite(dark, stone, glow)
    return base, glow


def tinted(base, glow, rgb):
    """The frame lit in one colour: glow screened over neutral stone."""
    w, h = base.size
    hot = glow.point(lambda v: min(255, int(v * 1.35)))
    lit = ImageChops.screen(base, Image.merge("RGB", [
        hot.point(lambda v, c=c: int(v * c / 255)) for c in rgb]))
    bloom = glow.filter(ImageFilter.GaussianBlur(w * 0.006))
    return ImageChops.screen(lit, Image.merge("RGB", [
        bloom.point(lambda v, c=c: int(v * c / 255 * 0.30)) for c in rgb]))


def circle_text(d, cx, cy, r, text, fill):
    """A number centred in its socket, shrunk until it fits inside the disc.

    The cost sitting half outside its orb was the single most card-breaking
    fault in the old hand; it does not get to come back.
    """
    size = int(r * 1.5)
    while size > 4:
        f = cf.font("KenneyBold.ttf", size)
        tw = d.textlength(text, font=f)
        if tw <= r * 1.35 and f.size <= r * 1.35:
            break
        size -= 1
    d.text((cx - tw / 2, cy - f.size * 0.62), text, font=f, fill=fill)


def render(base, glow, card, rgb):
    im = tinted(base, glow, rgb).resize((W * S, H * S), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    w, h = im.size

    ax0, ay0 = int(ART[0] * w), int(ART[1] * h)
    ax1, ay1 = int(ART[2] * w), int(ART[3] * h)
    if card["art"]:
        im.paste(cf.art_for(card, (ax1 - ax0, ay1 - ay0)), (ax0, ay0))

    tx0, ty0 = int(TITLE[0] * w), int(TITLE[1] * h)
    tx1, ty1 = int(TITLE[2] * w), int(TITLE[3] * h)
    f = cf.fit(d, card["name"], "KenneyBold.ttf", int((ty1 - ty0) * 0.70), tx1 - tx0)
    d.text((tx0, ty0 + (ty1 - ty0 - f.size) / 2), card["name"], font=f,
           fill=(240, 234, 224))

    cx, cy, cr = SOCKET[0] * w, SOCKET[1] * h, SOCKET[2] * w
    d.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=(16, 14, 16),
              outline=rgb, width=max(2, int(cr * 0.16)))
    # the number reads at hand size only if it is near-white, not the tint
    circle_text(d, cx, cy, cr, card["cost"],
                tuple(min(255, int(c * 0.3 + 178)) for c in rgb))

    yx0, yy0 = int(TYPE[0] * w), int(TYPE[1] * h)
    yy1 = int(TYPE[3] * h)
    f = cf.font("KenneyFutureNarrow.ttf", int((yy1 - yy0) * 0.50))
    d.text((yx0 + 4 * S, yy0 + (yy1 - yy0 - f.size) / 2), card["type"].upper(),
           font=f, fill=(198, 176, 150))

    rx0, ry0 = int(TEXT[0] * w), int(TEXT[1] * h)
    rx1, ry1 = int(TEXT[2] * w), int(TEXT[3] * h)
    cf.rules(d, (rx0 + 3 * S, ry0 + 4 * S, rx1 - 3 * S, ry1), card["text"],
             cf.font("KenneyBold.ttf", 9 * S))
    return im


def sheet(cards, label):
    gap, head = 6 * S, 26 * S
    width = len(cards) * W * S + gap * (len(cards) + 1)
    im = Image.new("RGB", (width, head + H * S + gap + H + gap * 2), (24, 22, 26))
    ImageDraw.Draw(im).text((gap, gap), label,
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
    base, glow = split()

    for d in (ASSETS, OUT):
        if not os.path.isdir(d):
            os.makedirs(d)
    base.save(os.path.join(ASSETS, "card_frame_a1_base.png"))
    white = Image.new("RGBA", base.size, (255, 255, 255, 0))
    white.putalpha(glow)
    white.save(os.path.join(ASSETS, "card_frame_a1_glow.png"))
    print("wrote the base/glow pair into", ASSETS)

    # one card in every seat colour: the proof that the tint is a parameter
    p = os.path.join(OUT, "a1-tints.png")
    sheet([render(base, glow, cf.CARDS[1], rgb) for _, rgb in TINTS],
          "A1  one card, five seat colours").save(p)
    print("wrote", p)

    # the hand, in one colour, to check the alignment fixes
    p = os.path.join(OUT, "a1-hand.png")
    sheet([render(base, glow, c, TINTS[0][1]) for c in cf.CARDS],
          "A1  the hand, cost inside the socket").save(p)
    print("wrote", p)


if __name__ == "__main__":
    main()
