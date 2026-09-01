"""Turn a card-art layer exported on white into one with real transparency.

    python tools/artprep.py <in.png> <out.png> [--tol 26]
    python tools/artprep.py --card crescendo Forest Golem Pond Frog

WHY THIS EXISTS
---------------
A layered card needs each layer to be see-through where it is empty. Canva can
export that - there is a "Transparent background" switch - but the first set of
Crescendo layers came out RGB with no alpha channel at all, every empty pixel
solid white. Stacked, they simply hide each other.

Ticking that switch is still the better fix and this is not a reason to skip it.
This exists because the switch is easy to miss, the failure is silent, and
re-exporting four images is a round trip.

WHY NOT JUST THRESHOLD THE WHITE
--------------------------------
Because the art has white IN it. The pond layer's water is drawn with white
highlight strokes and the frog has a pale cream belly; a global "white becomes
transparent" rule punches holes through both, and you get a frog you can see the
forest through.

So this is a FLOOD FILL from the border instead. Only white that is connected to
the outside of the image gets removed - the background, in other words, which is
what "background" means. White surrounded by art stays, because it is art.

The one thing it cannot do is separate a background that TOUCHES the art's own
white: a white highlight running off the edge of the frame would drain. Nothing
in these four layers does that, and if a future one does, the answer is the
Canva switch rather than a cleverer fill.
"""
import os
import sys
from collections import deque

from PIL import Image


## How far from pure white still counts as background, per channel. Canva's
## white is exact, but PNG quantisation and any faint drop shadow are not.
TOL = 26
## Pixels this close to the discovered background are faded rather than cut, so
## the edge of a shape is not a staircase.
FEATHER = 1


def key_white(src, tol=TOL):
    """RGBA with the border-connected white removed."""
    im = src.convert("RGBA")
    w, h = im.size
    px = im.load()

    def bg(p):
        return p[0] >= 255 - tol and p[1] >= 255 - tol and p[2] >= 255 - tol

    seen = bytearray(w * h)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if not seen[y * w + x] and bg(px[x, y]):
                seen[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if not seen[y * w + x] and bg(px[x, y]):
                seen[y * w + x] = 1
                q.append((x, y))

    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx]:
                if bg(px[nx, ny]):
                    seen[ny * w + nx] = 1
                    q.append((nx, ny))

    for y in range(h):
        row = y * w
        for x in range(w):
            if seen[row + x]:
                px[x, y] = (255, 255, 255, 0)

    # Soften the cut by one pixel: a kept pixel touching a removed one is part
    # of the shape's edge and should not be fully opaque against nothing.
    if FEATHER:
        edge = im.copy()
        ep = edge.load()
        for y in range(1, h - 1):
            row = y * w
            for x in range(1, w - 1):
                if seen[row + x]:
                    continue
                near = (seen[row + x - 1] or seen[row + x + 1]
                        or seen[row - w + x] or seen[row + w + x])
                if near:
                    r, g, b, a = px[x, y]
                    ep[x, y] = (r, g, b, int(a * 0.55))
        im = edge
    return im


def main():
    args = sys.argv[1:]
    tol = TOL
    if "--tol" in args:
        i = args.index("--tol")
        tol = int(args[i + 1])
        del args[i:i + 2]

    if args and args[0] == "--card":
        # --card crescendo Forest Golem Pond Frog
        #
        # Named FAR TO NEAR and written as <id>_1.png .. <id>_N.png, which is
        # the order rare3d.py hangs them in. The first layer is the backdrop and
        # is deliberately NOT keyed: it has nothing behind it, and its pale sky
        # is exactly the kind of near-white a fill would eat if it ever reached
        # the border.
        card = args[1]
        names = args[2:]
        root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
        dl = os.path.join(os.path.expanduser("~"), "Downloads")
        out_dir = os.path.join(root, "game", "assets", "cardart")
        for i, name in enumerate(names):
            src = os.path.join(dl, "%s %s.png" % (card.capitalize(), name))
            if not os.path.exists(src):
                src = os.path.join(dl, "%s.png" % name)
            if not os.path.exists(src):
                print("missing: %s" % src)
                continue
            dst = os.path.join(out_dir, "%s_%d.png" % (card, i + 1))
            im = Image.open(src)
            if i == 0:
                im = im.convert("RGBA")
            else:
                im = key_white(im, tol)
            im.save(dst)
            clear = sum(1 for p in im.getdata() if p[3] < 8)
            print("%-22s -> %-28s %d%% transparent"
                  % (name, os.path.basename(dst), 100 * clear // (im.size[0] * im.size[1])))
        return

    if len(args) < 2:
        print(__doc__)
        return
    key_white(Image.open(args[0]), tol).save(args[1])
    print("wrote %s" % args[1])


main()
