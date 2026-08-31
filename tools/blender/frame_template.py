"""A Canva template for the card border, marked with what may and may not stretch.

    python tools/blender/frame_template.py

Writes design/card-frame-template.png — open it in Canva as a locked background
layer, design on top of it, then export the frame alone at the same size.

WHY A TEMPLATE AND NOT JUST "MAKE A BORDER". A card is not one size. It is
176x264 on a desktop, 148x224 in a normal hand, and 124x186 on a phone, so the
frame is drawn as a NINE-SLICE: the four corners are pinned at their real pixel
size and never stretch, the four edges stretch along their length only, and the
middle stretches both ways. Nothing in Canva knows that, and it is the one thing
that decides whether a border survives contact with the game.

What it means in practice:

  * Ornament belongs in the CORNERS. A corner is never stretched, so anything
    there arrives intact at every card size.
  * Edges must be able to stretch. A plain band, a bevel, a gradient — all fine.
    A repeating motif along the top edge will smear, and a single centred jewel
    on an edge will slide off-centre as the card resizes.
  * The MIDDLE is the card body. It stretches both ways, so it wants to be flat
    colour or a very soft gradient. Detail there turns to mush.

The bands are drawn at FRAME_MARGIN (15px at card size, 60 here at 4x). Design
right up to the lines; just keep the fiddly bits inside the corner squares.
"""
import os

from PIL import Image, ImageDraw, ImageFont

## The card is 2:3 (176x264, 148x224, 124x186 — all of them), and that ratio is
## the only thing about this template that is not negotiable: design a frame at
## any other shape and it arrives in the game stretched.
##
## The SIZE is negotiable and 704x1056 is 4x the largest card, so the 9-slice
## margin lands on a whole pixel. It briefly became 768x1152 to match a canvas
## Nick had already made — then he resized to 704x1056 himself while that was
## being written, so it is back. Any 2:3 works; only the ratio matters.
OUT_W, OUT_H = 704, 1056
CARD_W, CARD_H = 176, 264
SCALE = OUT_W / float(CARD_W)
MARGIN = 15                      # must match card_view.FRAME_MARGIN
ART_ASPECT = 0.75                # must match card_view.CARD_ART_ASPECT

W, H = OUT_W, OUT_H
M = int(round(MARGIN * SCALE))

GUIDE = (255, 92, 92, 210)
SOFT = (120, 200, 255, 150)
FILL_CORNER = (255, 92, 92, 26)
FILL_EDGE = (120, 200, 255, 20)
INK = (255, 255, 255, 235)
DIM = (255, 255, 255, 130)
## The two corner callouts sit ON the pale edge band, not on the dark body,
## so they need dark ink. White on white was unreadable exactly where the
## guide has its most important thing to say.
ONPALE = (28, 30, 38, 255)


def font(size):
    """A real face at a real size.

    NOT one of the game's Kenney fonts, tempting as it was: they are display
    faces with a partial character set, so every hyphen, colon and bracket in
    the guide came out as an empty box. Pillow's built-in has been scalable
    since 10, covers ASCII, and this is a technical drawing rather than
    something that needs to look like the game.
    """
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.normpath(os.path.join(here, "..", "..", "design",
                                        "card-frame-template.png"))
    im = Image.new("RGBA", (W, H), (26, 27, 32, 255))
    d = ImageDraw.Draw(im, "RGBA")

    # the four corners — the safe places for ornament
    for x0, y0 in ((0, 0), (W - M, 0), (0, H - M), (W - M, H - M)):
        d.rectangle([x0, y0, x0 + M, y0 + M], fill=FILL_CORNER)
    # the four edges
    d.rectangle([M, 0, W - M, M], fill=FILL_EDGE)
    d.rectangle([M, H - M, W - M, H], fill=FILL_EDGE)
    d.rectangle([0, M, M, H - M], fill=FILL_EDGE)
    d.rectangle([W - M, M, W, H - M], fill=FILL_EDGE)

    # the slice lines themselves
    for x in (M, W - M):
        d.line([(x, 0), (x, H)], fill=GUIDE, width=2)
    for y in (M, H - M):
        d.line([(0, y), (W, y)], fill=GUIDE, width=2)
    d.rectangle([0, 0, W - 1, H - 1], outline=GUIDE, width=2)

    # where the art window lands, so the border is designed around real content
    pad = int(round(13 * SCALE))
    aw = W - pad * 2
    ah = int(aw * ART_ASPECT)
    top = int(H * 0.20)
    d.rectangle([pad, top, pad + aw, top + ah], outline=SOFT, width=3)
    big, mid, small = font(22), font(17), font(14)
    d.text((pad + 12, top + 12), "ART WINDOW  1024 x 768  (4:3)", fill=SOFT,
           font=small)

    d.text((M + 16, M + 14), "EDGE - stretches sideways.", fill=INK, font=mid)
    d.text((M + 16, M + 46), "No repeating motif along here: it smears.",
           fill=DIM, font=small)

    # Corner callouts sit just INSIDE the corner pointing at it. The corner
    # square is only 60px on this template and any text placed in it is a
    # smudge — which would make the guide illegible exactly where it matters.
    d.text((M + 16, 18), "^ CORNER: put ornament here, it never stretches",
           fill=ONPALE, font=small)
    d.text((M + 16, H - M + 22), "^ CORNER: fixed size at every card size",
           fill=ONPALE, font=small)

    d.multiline_text((M + 16, top + ah + 34),
                     "MIDDLE - stretches both ways.\n"
                     "Flat colour or a soft gradient only.\n"
                     "Detail here turns to mush. This is\n"
                     "the card body behind the rules text.",
                     fill=DIM, font=mid, spacing=8)

    d.multiline_text((M + 16, H - M - 96),
                     "Card is %dx%d at its largest, %dx%d on a phone.\n"
                     "Design here at %dx%d and export the frame\n"
                     "with the middle TRANSPARENT."
                     % (CARD_W, CARD_H, 124, 186, W, H),
                     fill=DIM, font=small, spacing=6)
    im.save(out)
    print("TEMPLATE %s  (%dx%d, 9-slice margin %dpx at card size)"
          % (out, W, H, MARGIN))
    print("Open it in Canva as a locked background, design on top, export the "
          "frame alone at %dx%d with a transparent middle." % (W, H))


main()
