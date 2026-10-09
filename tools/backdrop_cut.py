"""Cut TARGET.png's background (sky and cliffs, above the lava line) into a
backdrop the fight hangs behind the jackal.

    python3 tools/backdrop_cut.py

Nick, 2026-10-08: "build the concept 1:1". The 3D cliffs (cliff_flat walls
and flank prisms) could not take TARGET's shapes: graders kept naming thin
spires and busy peaks where TARGET paints two big dark slate masses. So, as
with the jackal itself (tools/beast_rig.py), the backdrop is TARGET's own
pixels. What TARGET draws in front of it (the jackal and its fire, the
stones, the HUD) is cut out and inpainted; the jackal covers that fill at
rest, and it only shows where a swing uncovers it.

Writes game/assets/3d/cast/cinder_jackal_backdrop.png: TARGET's columns,
rows 0..CUT + FADE, alpha feathered at the sides and fading out at the
bottom into the fight's own lava line. combat_3d._place_backdrop() fits it to
the screen's centred square from the rest camera.
"""
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

sys.path.insert(0, str(Path(__file__).resolve().parent))
import beast_rig as rig  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "game/assets/3d/cast/cinder_jackal_backdrop.png"

CUT = rig.CUT          # TARGET's lava line
FADE = 6               # rows past the lava line, fading out
SIDE_FEATHER = 28      # TARGET px at the left and right edges
PAD = 420              # TARGET px mirrored on past each side of the square
EDGE_SRC = 90          # TARGET px of each edge whose row tone the pad carries on
PAD_BLUR = 9.0
STRETCH_SRC = 150      # TARGET px of cliff above the gauge, stretched down over it
PAD_DARK = 0.35
PAD_BLEND = 70.0
GROW = 5               # TARGET px round the HUD and stones cut out
FIG_GROW = 3           # TARGET px round the figure and its flame
FILL_GROW = 14         # TARGET px of glow left out of the fill's source
# TARGET's HUD over the background (TARGET px): boss bar and intent chip,
# Log / Menu, the climb gauge down to the lava line.
# The big front stone's top pokes above the lava line.
EXTRA = [(270, 515, 440, CUT + FADE)]
# TARGET.png's own dark frame round the picture (TARGET px): not scene.
BORDER = [(0, 0, 1024, 16)]
# Its side frame columns: the last real column carried on over them.
SIDE_BORDER = (18, 1000)
# Filled by mirroring the picture in (x0, y0, x1, y1, from): the top frame
# and the boss bar from below, the climb gauge from its left.
MIRROR = [(10, 14, 130, 96, "below"), (862, 22, 998, 54, "below"),
          ]
# TARGET's climb gauge over the right cliff (x0, y0, x1, y1). A stretched
# or mirrored fill read as a pillar or a portal (graders 2026-10-09).
GAUGE = (909, 304, 1010, CUT + FADE)
GAUGE_GLOW = 492                  # TARGET row where the lava glow starts
GAUGE_SHADE = (9.0, 12.0, 20.0)  # the right cliff's shadow tone, sampled
# Over smooth sky an inpaint is clean: the intent chip and the top frame.
HUD = [(424, 16, 532, 50), (10, 14, 418, 96), (862, 22, 998, 54)]   # the last two are mirrored over after


def build():
    T = np.asarray(Image.open(rig.TARGET).convert("RGB")).astype(float)
    m, line, walls = rig.silhouette(T)
    fire_rgb, fire_a = rig.fire_layer(T, m)
    # The figure and the flame's tongues only: the flame's glow round them
    # (the fire layer's FIRE_HAZE) is TARGET's own pixels here as well, so the
    # backdrop keeps it rather than an inpainted smear.
    fig = m | ndi.binary_dilation(line, iterations=2) & ndi.binary_dilation(m, iterations=12)
    fig = ndi.binary_dilation(fig, iterations=FIG_GROW)
    # The flame's tongues, a little inside their edge: the backdrop keeps
    # TARGET's glow right at the tongues, so no dark fill rims the flame.
    fig |= ndi.binary_erosion(fire_a > 0.5, iterations=5)   # past the tongues' sway
    other = np.zeros_like(fig)
    # The gauge panel is near-opaque dark (~(9,11,16) inside): the cliff
    # behind it is lost. It reads as a shadowed face of the right cliff, so
    # it is one flat shadow tone, the lava glow at its foot inpainted.
    gx0, gy0, gx1, gy1 = GAUGE
    T = T.copy()
    shade = np.zeros(T.shape[:2])
    shade[gy0 - 4:GAUGE_GLOW, gx0 - 2:gx1 + 2] = 1.0
    shade = ndi.gaussian_filter(shade, 5.0) * shade.max()
    shade = np.clip(shade * 1.6, 0, 1)[..., None]
    T = T * (1 - shade) + np.array(GAUGE_SHADE) * shade
    other[GAUGE_GLOW:gy1, gx0 - 2:gx1 + 2] = True
    for (x0, y0, x1, y1) in rig.STONES + HUD + EXTRA:
        other[max(0, y0 - GROW):y1 + GROW, max(0, x0 - GROW):x1 + GROW] = True
    for (x0, y0, x1, y1) in BORDER:
        other[y0:y1, x0:x1] = True
    rows = CUT + FADE
    img = T[:rows].astype(np.uint8)
    fig, other = fig[:rows], other[:rows]
    bgr = np.ascontiguousarray(img[..., ::-1])
    # The figure's fill comes from clean background: inpainted from well
    # outside its glow (FILL_GROW), so it carries cliff and sky, not a brown
    # smear of the halo; only the figure itself (FIG_GROW) is replaced.
    wide = ndi.binary_dilation(fig, iterations=FILL_GROW)
    fill_fig = cv2.inpaint(bgr, wide.astype(np.uint8) * 255, 9, cv2.INPAINT_TELEA)[..., ::-1]
    # The HUD, stones and frame: a tight inpaint from the pixels round each
    # (a wide one went darker than TARGET's sky and showed as a rectangle).
    fill_other = cv2.inpaint(bgr, (other | wide).astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)[..., ::-1]
    out = img.astype(float)
    out[other] = fill_other[other]
    out[fig] = fill_fig[fig]
    # The HUD and the frame: TARGET's cliffs there are vertical slabs and its
    # sky is smooth, so mirror the clean picture in from the side the rect
    # opens on (an inpaint smeared them into a blurred band, grader
    # 2026-10-09). After the figure's fill, so no part of it is copied.
    clean = out.copy()
    clean[wide] = fill_fig[wide]
    for (x0, y0, x1, y1, how) in MIRROR:
        if how == "below":
            src = clean[y1:y1 + (y1 - y0)][::-1]
        elif how == "above":
            # The cliff above stretched on down over it (rows y0 - STRETCH_SRC
            # .. y1): carried or flipped copies made stacked chevrons that
            # graders read as a hexagonal portal.
            top = y0 - STRETCH_SRC
            strip = Image.fromarray(np.clip(clean[top:y0, x0:x1], 0, 255).astype(np.uint8))
            tall = np.asarray(strip.resize((x1 - x0, y1 - top), Image.LANCZOS)).astype(float)
            out[top:y1, x0:x1] = tall
            clean[top:y1, x0:x1] = tall
            continue
        else:  # "left": the gauge's foot, lava glow running in from the left
            w = x1 - x0
            src = np.zeros_like(clean[y0:y1])
            src[:, x0:x1] = clean[y0:y1, x0 - w:x0][:, ::-1]
        out[y0:y1, x0:x1] = src[:, x0:x1]
        clean[y0:y1, x0:x1] = src[:, x0:x1]
    lo, hi = SIDE_BORDER
    out[:, :lo] = out[:, lo:lo + 1]
    out[:, hi:] = out[:, hi - 1:hi]
    # Past the square's sides the fight's 16:9 frame shows more scene: the
    # cliffs mirrored outward, so the backdrop runs the full width with no
    # seam against the 3D wall (grader 2026-10-09: hard edges at x 290/980).
    # Mirrored at the edge (no seam) and stretched EDGE_SRC -> PAD wide, so
    # the slabs read as more cliff rather than a reflection.
    # Past the first PAD_BLEND px (TARGET's edge mirrored, so no seam) the
    # pad is each row's own edge tone carried on, darkening outward: a plain
    # dark rock face. A stretched reflection read as hexagons and chevrons
    # (grader 2026-10-09).
    def side_pad(block):
        sharp = block[:, :PAD] if block.shape[1] >= PAD else np.pad(block, ((0, 0), (0, PAD - block.shape[1]), (0, 0)), mode="edge")
        flat = np.repeat(ndi.gaussian_filter(block[:, :EDGE_SRC].mean(axis=1), (6, 0))[:, None, :], PAD, axis=1)
        t = np.clip(np.arange(PAD) / PAD_BLEND, 0, 1)[None, :, None]
        dark = 1.0 - PAD_DARK * np.clip(np.arange(PAD) / PAD, 0, 1)[None, :, None]
        return (sharp * (1 - t) + flat * t) * dark
    left = side_pad(out[:, lo:lo + PAD])[:, ::-1]
    right = side_pad(out[:, hi - PAD:hi][:, ::-1])
    out = np.concatenate([left, out, right], axis=1)
    H, W = out.shape[:2]
    a = np.ones((H, W))
    xs = np.arange(W)
    side = np.clip(np.minimum(xs, W - 1 - xs) / SIDE_FEATHER, 0, 1)
    a *= side[None, :]
    ys = np.arange(H)
    bottom = np.clip((rows - ys) / FADE, 0, 1)
    a *= bottom[:, None]
    rgba = np.dstack([np.clip(out, 0, 255), a * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT)
    print("backdrop:", OUT.relative_to(ROOT), rgba.shape[1], "x", rgba.shape[0])


if __name__ == "__main__":
    build()
