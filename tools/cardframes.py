"""Mock the three card-frame directions from design/art/card-frame-research.md.

Mockups only -- nothing here is wired into the game. Nick picks one, then the
builder implements it in card_view.gd.

    python tools/cardframes.py            # writes design/art/cards/frames-*.png

Drawn at 3x hand size and downscaled, so the 1:1 strip shows what he will
actually see: a frame that only works at 3x is not a frame.
"""

import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 160, 224          # true hand size
S = 3                    # supersample
OUT = os.path.join("design", "art", "cards")
ART = os.path.join("game", "assets", "cardart")
FONTS = os.path.join("game", "assets", "fonts")

CARDS = [
    {"name": "Tongue Snap", "cost": "1", "type": "Attack", "art": None,
     "rare": True,
     "text": [("Deal ", "w"), ("2", "n"), (" damage and an", "w"),
              ("\nadditional ", "w"), ("3", "n"), (" per ", "w"),
              ("Rhythm", "k"), (".", "w"),
              ("\nClimb ", "w"), ("1", "n"), (".", "w")]},
    {"name": "Leap", "cost": "2", "type": "Skill", "art": "leap.png",
     "rare": True,
     "text": [("Climb ", "w"), ("3", "n"), (".", "w")]},
    {"name": "Scramble", "cost": "0", "type": "Skill", "art": "scramble.png",
     "rare": False,
     "text": [("Climb ", "w"), ("1", "n"), (".", "w")]},
]


def font(name, size):
    try:
        return ImageFont.truetype(os.path.join(FONTS, name), size)
    except OSError:
        return ImageFont.load_default(size)


def fit(d, text, name, size, width):
    """The largest size at or below `size` whose text fits `width`."""
    while size > 5 * S:
        f = font(name, size)
        if d.textlength(text, font=f) <= width:
            return f
        size -= S
    return font(name, size)


def art_for(card, box):
    """The card's art, cropped to fill the window, or a flat placeholder."""
    w, h = box
    if card["art"]:
        p = os.path.join(ART, card["art"])
        if os.path.exists(p):
            im = Image.open(p).convert("RGB")
            scale = max(w / im.width, h / im.height)
            im = im.resize((int(im.width * scale) + 1, int(im.height * scale) + 1),
                           Image.LANCZOS)
            x = (im.width - w) // 2
            y = (im.height - h) // 3
            return im.crop((x, y, x + w, y + h))
    return Image.new("RGB", (w, h), (36, 40, 52))


def bevel(d, box, light, dark, width=2):
    """A raised edge: light on the top-left, dark on the bottom-right. This is
    the single device that turns a painted outline into a plate with
    thickness, and the one our current border is missing."""
    x0, y0, x1, y1 = box
    for i in range(width):
        d.line([(x0 + i, y1 - i), (x0 + i, y0 + i), (x1 - i, y0 + i)], fill=light)
        d.line([(x1 - i, y0 + i), (x1 - i, y1 - i), (x0 + i, y1 - i)], fill=dark)


def rules(d, box, parts, f, light=True):
    """Rules text, centred, with numbers and keywords picked out."""
    colours = {"w": (236, 234, 228) if light else (28, 26, 24),
               "n": (120, 220, 140) if light else (24, 110, 48),
               "k": (226, 176, 92) if light else (150, 92, 20)}
    x0, y0, x1, _ = box
    lines, cur = [], []
    for text, kind in parts:
        for i, chunk in enumerate(text.split("\n")):
            if i:
                lines.append(cur)
                cur = []
            if chunk:
                cur.append((chunk, kind))
    lines.append(cur)
    # shrink until the widest line fits the box -- a frame that clips its own
    # rules text is the fault we are fixing, not a new one
    while f.size > 5 * S:
        if max(sum(d.textlength(t, font=f) for t, _ in l) for l in lines) <= x1 - x0:
            break
        f = ImageFont.truetype(f.path, f.size - S) if hasattr(f, "path") \
            else font("KenneyBold.ttf", f.size - S)
    y = y0
    for line in lines:
        total = sum(d.textlength(t, font=f) for t, _ in line)
        x = x0 + ((x1 - x0) - total) / 2
        for text, kind in line:
            d.text((x, y), text, font=f, fill=colours[kind])
            x += d.textlength(text, font=f)
        y += f.size + 4 * S


# --------------------------------------------------------------------------
# A -- carved obsidian: the fight's own material
# --------------------------------------------------------------------------

def frame_a(card):
    w, h = W * S, H * S
    im = Image.new("RGB", (w, h), (10, 9, 12))
    d = ImageDraw.Draw(im)
    pad = 4 * S
    # hard outer edge, then a bevelled stone plate
    d.rounded_rectangle([0, 0, w - 1, h - 1], 7 * S, fill=(8, 7, 9))
    d.rounded_rectangle([pad, pad, w - pad, h - pad], 5 * S, fill=(33, 31, 36))
    bevel(d, (pad, pad, w - pad, h - pad), (74, 69, 78), (16, 15, 18), 2 * S)
    # keyline colour IS the rarity cue: ember for uncommon, slate for common
    key = (198, 104, 36) if card["rare"] else (104, 110, 122)
    d.rounded_rectangle([pad + 2 * S, pad + 2 * S, w - pad - 2 * S, h - pad - 2 * S],
                        4 * S, outline=key, width=S)
    # art window, contained by its own keyline
    ax0, ay0 = pad + 7 * S, pad + 22 * S
    ax1, ay1 = w - pad - 7 * S, pad + 128 * S
    im.paste(art_for(card, (ax1 - ax0, ay1 - ay0)), (ax0, ay0))
    d.rectangle([ax0 - S, ay0 - S, ax1, ay1], outline=(12, 11, 14), width=S)
    # title plate, with the cost SET INTO it rather than floating outside
    d.rounded_rectangle([pad + 5 * S, pad + 4 * S, w - pad - 5 * S, pad + 19 * S],
                        3 * S, fill=(24, 22, 26))
    bevel(d, (pad + 5 * S, pad + 4 * S, w - pad - 5 * S, pad + 19 * S),
          (66, 61, 70), (14, 13, 16), S)
    d.text((pad + 26 * S, pad + 7 * S), card["name"],
           font=fit(d, card["name"], "KenneyBold.ttf", 11 * S, w - 2 * pad - 33 * S),
           fill=(238, 228, 214))
    d.ellipse([pad + 7 * S, pad + 5 * S, pad + 21 * S, pad + 18 * S], fill=(16, 15, 18),
              outline=key, width=S)
    d.text((pad + 12 * S, pad + 7 * S), card["cost"], font=font("KenneyBold.ttf", 11 * S),
           fill=(246, 198, 120))
    # type bar between art and text
    d.rectangle([ax0, ay1 + S, ax1, ay1 + 13 * S], fill=(24, 22, 26))
    d.text((ax0 + 5 * S, ay1 + 3 * S), card["type"].upper(),
           font=font("KenneyFutureNarrow.ttf", 7 * S), fill=(176, 150, 120))
    # text box: its own inset fill
    d.rounded_rectangle([ax0, ay1 + 15 * S, ax1, h - pad - 5 * S], 2 * S, fill=(20, 19, 23))
    rules(d, (ax0 + 3 * S, ay1 + 22 * S, ax1 - 3 * S, h), card["text"],
          font("KenneyBold.ttf", 9 * S))
    return im


# --------------------------------------------------------------------------
# B -- printed card: Magic's logic, light text box
# --------------------------------------------------------------------------

def frame_b(card):
    w, h = W * S, H * S
    warm = card["type"] == "Attack"
    inner = (122, 46, 36) if warm else (38, 64, 104)
    im = Image.new("RGB", (w, h), (12, 11, 11))
    d = ImageDraw.Draw(im)
    # the black border is the device: a hard edge against any background
    d.rounded_rectangle([0, 0, w - 1, h - 1], 7 * S, fill=(12, 11, 11))
    pad = 6 * S
    d.rounded_rectangle([pad, pad, w - pad, h - pad], 3 * S, fill=inner)
    bevel(d, (pad, pad, w - pad, h - pad),
          tuple(min(255, c + 46) for c in inner), tuple(max(0, c - 28) for c in inner), 2 * S)
    # title plate with the cost right-aligned INSIDE it
    d.rounded_rectangle([pad + 3 * S, pad + 3 * S, w - pad - 3 * S, pad + 17 * S],
                        2 * S, fill=(232, 226, 212))
    d.text((pad + 7 * S, pad + 5 * S), card["name"],
           font=fit(d, card["name"], "KenneyBold.ttf", 10 * S, w - 2 * pad - 28 * S),
           fill=(26, 22, 20))
    d.ellipse([w - pad - 18 * S, pad + 4 * S, w - pad - 5 * S, pad + 16 * S],
              fill=(44, 40, 38))
    d.text((w - pad - 14 * S, pad + 5 * S), card["cost"],
           font=font("KenneyBold.ttf", 10 * S), fill=(240, 232, 216))
    # art window with a keyline
    ax0, ay0 = pad + 5 * S, pad + 20 * S
    ax1, ay1 = w - pad - 5 * S, pad + 120 * S
    im.paste(art_for(card, (ax1 - ax0, ay1 - ay0)), (ax0, ay0))
    d.rectangle([ax0 - S, ay0 - S, ax1, ay1], outline=(20, 18, 17), width=S)
    # type line
    d.rounded_rectangle([pad + 3 * S, ay1 + 3 * S, w - pad - 3 * S, ay1 + 15 * S],
                        2 * S, fill=(232, 226, 212))
    d.text((pad + 7 * S, ay1 + 5 * S), card["type"],
           font=font("KenneyFutureNarrow.ttf", 8 * S), fill=(40, 34, 30))
    # text box, parchment: black on light is the most legible at hand size
    d.rounded_rectangle([pad + 3 * S, ay1 + 18 * S, w - pad - 3 * S, h - pad - 3 * S],
                        2 * S, fill=(238, 232, 216))
    rules(d, (pad + 6 * S, ay1 + 26 * S, w - pad - 6 * S, h), card["text"],
          font("KenneyBold.ttf", 8 * S), light=False)
    # rarity pip, bottom-right, in a fixed place
    pip = (176, 128, 40) if card["rare"] else (120, 120, 124)
    d.regular_polygon((w - pad - 9 * S, h - pad - 9 * S, 4 * S), 4, fill=pip,
                      outline=(32, 28, 24))
    return im


# --------------------------------------------------------------------------
# C -- sculpted relic: Hearthstone's logic, the frame as an object
# --------------------------------------------------------------------------

def frame_c(card):
    w, h = W * S, H * S
    im = Image.new("RGB", (w, h), (18, 14, 11))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, w - 1, h - 1], 10 * S, fill=(14, 11, 9))
    # thick ornate plate
    plate = (96, 72, 38) if card["rare"] else (78, 80, 86)
    lit = (176, 140, 82) if card["rare"] else (156, 160, 168)
    d.rounded_rectangle([3 * S, 3 * S, w - 3 * S, h - 3 * S], 9 * S, fill=plate)
    bevel(d, (3 * S, 3 * S, w - 3 * S, h - 3 * S), lit, (44, 40, 34), 3 * S)
    d.rounded_rectangle([9 * S, 9 * S, w - 9 * S, h - 9 * S], 6 * S, fill=(56, 42, 24))
    # art window: an oval, so the frame reads as a cut object not a rectangle
    ax0, ay0, ax1, ay1 = 16 * S, 24 * S, w - 16 * S, 122 * S
    art = art_for(card, (ax1 - ax0, ay1 - ay0))
    mask = Image.new("L", (ax1 - ax0, ay1 - ay0), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, ax1 - ax0 - 1, ay1 - ay0 - 1], fill=255)
    im.paste(art, (ax0, ay0), mask)
    d.ellipse([ax0 - S, ay0 - S, ax1, ay1], outline=lit, width=2 * S)
    # name on a ribbon across the base of the art
    d.rounded_rectangle([12 * S, ay1 - 12 * S, w - 12 * S, ay1 + 4 * S], 3 * S,
                        fill=(34, 25, 15))
    d.text((18 * S, ay1 - 10 * S), card["name"],
           font=fit(d, card["name"], "KenneyBold.ttf", 10 * S, w - 42 * S),
           fill=(238, 214, 170))
    # the cost as a gem embedded in the frame
    d.ellipse([6 * S, 6 * S, 30 * S, 30 * S], fill=(26, 56, 104), outline=lit,
              width=2 * S)
    d.ellipse([11 * S, 10 * S, 24 * S, 20 * S], fill=(70, 120, 196))
    d.text((14 * S, 10 * S), card["cost"], font=font("KenneyBold.ttf", 12 * S),
           fill=(236, 244, 255))
    # type ribbon + text box
    d.text((16 * S, ay1 + 9 * S), card["type"].upper(),
           font=font("KenneyFutureNarrow.ttf", 7 * S), fill=(198, 166, 112))
    d.rounded_rectangle([14 * S, ay1 + 20 * S, w - 14 * S, h - 14 * S], 4 * S,
                        fill=(30, 23, 14))
    rules(d, (17 * S, ay1 + 27 * S, w - 17 * S, h), card["text"],
          font("KenneyBold.ttf", 8 * S))
    return im


def sheet(fn, label):
    """Three cards in a row, at 3x and again at true hand size underneath."""
    cards = [fn(c) for c in CARDS]
    gap = 6 * S
    big_w = len(cards) * (W * S) + gap * (len(cards) + 1)
    small = [c.resize((W, H), Image.LANCZOS) for c in cards]
    head = 26 * S
    im = Image.new("RGB", (big_w, head + H * S + gap + H + gap * 2), (24, 22, 26))
    d = ImageDraw.Draw(im)
    d.text((gap, gap), label, font=font("KenneyBold.ttf", 13 * S), fill=(236, 230, 220))
    x = gap
    for c in cards:
        im.paste(c, (x, head))
        x += W * S + gap
    x = gap
    y = head + H * S + gap
    for c in small:
        im.paste(c, (x, y))
        x += W + gap
    return im


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    if not os.path.isdir(OUT):
        os.makedirs(OUT)
    for key, fn, label in (("A", frame_a, "A  carved obsidian"),
                           ("B", frame_b, "B  printed card"),
                           ("C", frame_c, "C  sculpted relic")):
        p = os.path.join(OUT, "frames-%s.png" % key)
        sheet(fn, label).save(p)
        print("wrote", p)


if __name__ == "__main__":
    main()
