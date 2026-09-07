"""Does each card icon actually hold against the card face, at 42px?

    python tools/blender/iconmetrics.py
    python tools/blender/iconmetrics.py fire shield

Plain Pillow — no Blender, no screen. Written 2026-09-07 after Nick said the
icons were not very good looking, and the measurement agreed with him harder
than expected: **36 of 60 icons sit under 3.0:1 contrast against the card face,
median 1.73:1.** `wall` measures 1.00:1, which is the same luminance as the card
it is drawn on.

The split is not subtle. Every flat white icon scores 4.98:1 and loses nothing.
Every shaded 3D icon scores between 1.0 and 2.5, because a lit render of a
tan/grey object is, at 42px, a tan/grey smudge on a brown card.

COLUMNS

  contrast  WCAG contrast ratio of the icon's mean colour against the card face.
            Under 3.0:1 fails. This is the number that decides whether a player
            can tell what the card does at a glance.
  % lost    share of the icon's own pixels within 20 luminance of the card face
            — the part of the drawing that dissolves into the background.
  % cover   share of the 42px box the icon fills. Very low means it is also
            small, which compounds low contrast.

This measures LEGIBILITY, not beauty. A black square scores wonderfully.
"""
import os
import sys
import glob
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ICONS = os.path.join(ROOT, "game", "assets", "icons")

CARD = (139, 105, 74)  # the flat brown card-face standin the icon rubric uses
SIZE = 42              # the size the card actually draws it at
FAIL = 3.0             # WCAG-style ratio below which an icon does not read


def _lin(v):
    v /= 255.0
    return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4


def relative_luminance(c):
    return 0.2126 * _lin(c[0]) + 0.7152 * _lin(c[1]) + 0.0722 * _lin(c[2])


def contrast(a, b):
    l1, l2 = sorted((relative_luminance(a), relative_luminance(b)), reverse=True)
    return (l1 + 0.05) / (l2 + 0.05)


def plain_luminance(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def main(argv):
    only = set(argv) or None
    rows = []
    for f in sorted(glob.glob(os.path.join(ICONS, "*.png"))):
        name = os.path.basename(f)[:-4]
        if only and name not in only:
            continue
        im = Image.open(f).convert("RGBA").resize((SIZE, SIZE), Image.LANCZOS)
        px = list(im.getdata())
        on = [p for p in px if p[3] > 128]
        if not on:
            print(f"{name}: fully transparent at {SIZE}px")
            continue
        mean = tuple(sum(p[i] for p in on) // len(on) for i in range(3))
        card_l = plain_luminance(CARD)
        lost = 100.0 * sum(1 for p in on
                           if abs(plain_luminance(p[:3]) - card_l) < 20) / len(on)
        rows.append([name, contrast(mean, CARD), lost,
                     100.0 * len(on) / len(px), mean])

    if not rows:
        print("no icons matched")
        return 1

    rows.sort(key=lambda r: r[1])
    print(f"{'icon':20}{'contrast':>9}{'% lost':>8}{'% cover':>9}   mean rgb")
    print("-" * 64)
    for name, cr, lost, cover, mean in rows:
        tail = "   <-- FAILS" if cr < FAIL else ""
        print(f"{name:20}{cr:9.2f}{lost:8.1f}{cover:9.1f}   {mean}{tail}")

    bad = [r for r in rows if r[1] < FAIL]
    med = sorted(r[1] for r in rows)[len(rows) // 2]
    print(f"\n{len(bad)} of {len(rows)} under {FAIL:.1f}:1 against the card face"
          f"   median {med:.2f}:1")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
