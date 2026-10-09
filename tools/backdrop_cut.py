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
import gauge_unblend  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "game/assets/3d/cast/cinder_jackal_backdrop.png"
REST = ROOT / "game/assets/3d/cast/cinder_jackal_2d.png"   # the rig at rest (tools/beast_rig.py)

CUT = rig.CUT          # TARGET's lava line
FADE = 18              # rows past the cut: TARGET's bright lava band runs to ~546 (2026-10-09)
LAVA_ROWS = (515, None)   # TARGET rows of the lava band and its glow
FIG_LAVA = True           # the band carried across the figure's hole as well
KEEP_TARGET = [(796, 505, 836, CUT + FADE)]   # TARGET px kept as is behind the fist's foot
DARK_INV = ([0, 1, 3, 7, 13, 19, 24, 30, 255], [0, 9.3, 10, 12, 15, 20, 25, 30, 255])
FADE_LEN = 6           # the last rows, fading out
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
GAUGE_UNBLEND = True              # the scene behind the see-through gauge recovered (tools/gauge_unblend.py), not a flat shade
GAUGE_SHADE = (9.0, 12.0, 20.0)  # the right cliff's shadow tone, sampled
# Over smooth sky an inpaint is clean: the intent chip and the top frame.
HUD = [(424, 16, 532, 50), (10, 14, 418, 96), (862, 22, 998, 54)]   # the last two are mirrored over after


# Round the raised fist (builder 2026-10-09, "Fist fire"): the figure fill and
# the boss-bar rect were inpainted from TARGET's flame glow and showed as a
# dark red blob with a streak rising above the flame's tip. Rebuilt as
# TARGET's cool slate (the warm pixels kept out of the inpaint's source) plus
# the flame's own glow, a blur of its alpha fitted to TARGET's ring round it.
FIST_REBUILD = True
FIST_AREA = (40, 14, 440, 360)     # TARGET px (x0, y0, x1, y1)
FIST_RING = (6, 60)
FIST_NEAR = 0                     # TARGET px from the flame the glow band is rebuilt
FIST_GLOW = 0.5                    # of the measured median lift (full read as a red band left of the flame)
FIST_RATIO = False                 # local glow strength: made a cool band left of the flame
FIST_RATIO_SIG = 10.0              # TARGET px the glow's local strength is spread over
FIST_EDGE_SIG = 3.0                # TARGET px of the carried-in edge
RIM_KEEP = 0                       # TARGET px past the drawn outline where TARGET's own pixels start, near the fire
RIM_KEEP_FIRE = 60                 # TARGET px from the fire that holds for
BAR_BOTTOM = 50                    # TARGET row: the boss bar panel's last + 1                # TARGET px outside the flame the fit reads


def fist_backdrop(out, img, fig, wide, fire_a, m):
    x0, y0, x1, y1 = FIST_AREA
    H, W = out.shape[:2]
    area = np.zeros((H, W), bool)
    area[y0:y1, x0:x1] = True
    flame = (fire_a > 0.5) & ~m
    # what to replace: the figure fill and the HUD rects inside the area,
    # never the figure (it draws over) beyond what the fill already took
    hud = np.zeros((H, W), bool)
    for (hx0, hy0, hx1, hy1) in HUD:
        hud[hy0:hy1, hx0:hx1] = True
    # Only what TARGET hides behind the figure and the flame: round them,
    # TARGET's own glow pixels are the best backdrop there is.
    # The glow band round the figure (wide, FILL_GROW out) only near the
    # flame: by the left ear it replaced TARGET's own sky 4-14 px past the
    # outline with the cool fill's dark cliff, and past the rig's rim ring
    # that showed as a dark smudge (queue 2026-10-09). Away from the flame
    # TARGET's own pixels stay, as everywhere outside FIST_AREA.
    repl = area & (fig | (wide & ndi.binary_dilation(flame, iterations=FIST_NEAR))) if FIST_NEAR > 0 else area & fig
    # cool slate: warm pixels near the flame kept out of the source
    r, g, b = img[..., 0], img[..., 1], img[..., 2]
    warm = ((r - b) > 25) | ((r > 120) & (r > b + 10))
    near = ndi.binary_dilation(flame | m, iterations=90) & area
    src_mask = repl | (warm & near) | hud
    src_mask &= area
    # the figure already filled in `out`, so no outline leaks in from past the area
    bgr = np.ascontiguousarray(np.clip(out[..., ::-1], 0, 255).astype(np.uint8))
    # whatever lies outside the area stays as source
    cool = cv2.inpaint(bgr, src_mask.astype(np.uint8) * 255, 11, cv2.INPAINT_TELEA)[..., ::-1].astype(float)
    # The boss-bar rect: TARGET's cliffs there are vertical slabs and its sky
    # is smooth, so the cool picture just below is mirrored up over it.
    for (hx0, hy0, hx1, hy1) in HUD[1:2]:
        hx0, hx1 = max(hx0, x0), min(hx1, x1)
        h = hy1 - hy0
        cool[hy0:hy1, hx0:hx1] = cool[hy1:hy1 + h, hx0:hx1][::-1]
    # the glow: TARGET's own warm lift over the cool slate, by distance
    # from the flame (the median of each 2 px ring), so no rim overshoots
    d = ndi.distance_transform_edt(~flame)
    ring = area & ~m & ~hud & ~ndi.binary_dilation(m, iterations=6) & (d > 0) & (d < FIST_RING[1])
    lift = img - cool
    edges = np.arange(0, FIST_RING[1] + 2, 2.0)
    prof = np.zeros((len(edges), 3))
    for i, e in enumerate(edges):
        k = ring & (d >= e) & (d < e + 2)
        if k.sum() > 20:
            prof[i] = np.clip(np.median(lift[k], axis=0), 0, None)
    prof[-1] = 0
    print("fist glow profile", np.round(prof[::5], 1).tolist())
    glow = FIST_GLOW * np.dstack([np.interp(d, edges + 1, prof[:, c]) for c in range(3)])
    # TARGET's glow is not even all round: bright yellow under the fist,
    # dark between the left lobes. Each place takes the ratio of TARGET's
    # own lift to the profile, read off the visible ring near it.
    pl = glow.sum(2)
    have = ring & (pl > 6)
    ratio = np.where(have, lift.sum(2) / np.maximum(pl, 1e-3), 0)
    ratio = np.clip(ratio, 0, 3)
    num = ndi.gaussian_filter(ratio * have, FIST_RATIO_SIG)
    den = ndi.gaussian_filter(have.astype(float), FIST_RATIO_SIG)
    r = np.where(den > 1e-3, num / np.maximum(den, 1e-3), 1.0)
    if FIST_RATIO:
        glow = glow * r[..., None]
    new = np.clip(cool + glow, 0, 255)
    # Right at the edge of what is hidden, TARGET's own pixels carried in
    # (a normalized blur of the visible ring), so the fill meets TARGET's
    # glow at its own tone and no seam rings the flame.
    valid = (area & ~repl).astype(float)
    den = ndi.gaussian_filter(valid, FIST_EDGE_SIG)
    ext = np.dstack([ndi.gaussian_filter(img[..., c] * valid, FIST_EDGE_SIG) for c in range(3)]) / np.maximum(den, 1e-4)[..., None]
    w = np.clip(den / 0.25, 0, 1)[..., None]
    new = new * (1 - w) + ext * w
    # feathered into TARGET's own pixels at the edge of what is replaced,
    # so no seam rings the flame
    wt = np.clip(ndi.distance_transform_edt(repl) / 4.0, 0, 1)[..., None]
    o = out * (1 - wt) + new * wt
    # TARGET's boss bar panel ends at row 50: below it (to the HUD rect's
    # 96) is TARGET's own scene, kept; the panel rows are that scene
    # mirrored up (vertical slabs and smooth sky mirror cleanly).
    bx0, by0, bx1, by1 = HUD[1]
    bx0, bx1 = max(bx0, x0), min(bx1, x1)
    by1 += GROW   # the HUD cut-out was grown by GROW rows too
    keep = ~(m | ndi.binary_dilation(flame, iterations=3))[BAR_BOTTOM:by1, bx0:bx1]
    blk = o[BAR_BOTTOM:by1, bx0:bx1]
    blk[keep] = img[BAR_BOTTOM:by1, bx0:bx1][keep]
    h = BAR_BOTTOM - by0
    o[by0:BAR_BOTTOM, bx0:bx1] = o[BAR_BOTTOM:BAR_BOTTOM + h, bx0:bx1][::-1]
    return o


def build():
    T = np.asarray(Image.open(rig.TARGET).convert("RGB")).astype(float)
    m, line, walls = rig.silhouette(T)
    fire_rgb, fire_a = rig.fire_layer(T, m)
    # The figure and the flame's tongues only: the flame's glow round them
    # (the fire layer's FIRE_HAZE) is TARGET's own pixels here as well, so the
    # backdrop keeps it rather than an inpainted smear.
    fig = m | ndi.binary_dilation(line, iterations=2) & ndi.binary_dilation(m, iterations=12)
    fig = ndi.binary_dilation(fig, iterations=FIG_GROW)
    # The outline's soft cream glow reaches past the grown figure (beside
    # the left ear it stood as a pale wisp in the sky, grader 2026-10-09):
    # warm-light pixels just round the figure go with it.
    r_, g_, b_ = T[..., 0], T[..., 1], T[..., 2]
    glowline = (r_ > 150) & (g_ > 100) & (r_ - b_ > 40) & ndi.binary_dilation(fig, iterations=8)
    glowline &= ~ndi.binary_erosion(ndi.binary_dilation(fire_a > 0.5, iterations=40), iterations=1) | m
    fig |= ndi.binary_dilation(glowline, iterations=2)
    # The flame's tongues, a little inside their edge: the backdrop keeps
    # TARGET's glow right at the tongues, so no dark fill rims the flame.
    fig |= ndi.binary_erosion(fire_a > 0.5, iterations=5)   # past the tongues' sway
    other = np.zeros_like(fig)
    # The gauge panel is near-opaque dark (~(9,11,16) inside): the cliff
    # behind it is lost. It reads as a shadowed face of the right cliff, so
    # it is one flat shadow tone, the lava glow at its foot inpainted.
    gx0, gy0, gx1, gy1 = GAUGE
    T = T.copy()
    if GAUGE_UNBLEND:
        # The scene behind TARGET's see-through gauge, recovered: the fight's
        # panel (same face and alpha) lands back on TARGET's pixels over it.
        T = gauge_unblend.unblend(T)
    shade = np.zeros(T.shape[:2])
    shade[gy0 - 4:GAUGE_GLOW, gx0 + 3:gx1 - 3] = 1.0   # inside the panel's border (run 15)
    rect = shade > 0
    shade = ndi.gaussian_filter(shade, 5.0) * shade.max()
    # Inside the panel only: its blur spilled ~10 px left of the gauge as a
    # dark band over TARGET's lava glow (grader run 15, "feet in the lava").
    shade = np.where(rect, np.clip(shade * 1.6, 0, 1), 0.0)[..., None]
    if not GAUGE_UNBLEND:
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
    # TARGET's lava line is a horizontal band: where a stone hid it, each row
    # is carried across the hole from its clean ends, so the yellow line runs
    # on unbroken behind the fight's slab (grader 2026-10-09: "a dark blot and
    # an orange smear" from the inpaint there).
    # The figure's own hole too (run 15): where a leg meets the lava, its
    # fill was dark cliff and showed as a dark wedge beside the right foot
    # in the band (grader, "Jackal's feet in the lava").
    for y in range(LAVA_ROWS[0], rows):
        hole = (other[y] | fig[y]) if FIG_LAVA else (other[y] & ~fig[y])
        if not hole.any():
            continue
        good = ~(other[y] | fig[y])
        # Not TARGET's dark side frame: carried in, it faded the band to
        # navy ~30 px before the climb gauge (grader run 15).
        good[:SIDE_BORDER[0]] = False
        good[SIDE_BORDER[1]:] = False
        xs_good = np.nonzero(good)[0]
        if len(xs_good) < 2:
            continue
        xs_hole = np.nonzero(hole)[0]
        for c in range(3):
            out[y, xs_hole, c] = np.interp(xs_hole, xs_good, img[y, xs_good, c].astype(float))
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
    # Behind the right fist where it sinks into the lava, TARGET's own
    # pixels (its line included): the fist's cut-out edge there steps at
    # TARGET's pixel grid, and over a lava fill the steps read as an aliased
    # edge (grader run 15). Over TARGET's own pixels the steps vanish.
    for (x0, y0, x1, y1) in KEEP_TARGET:
        keep = np.zeros_like(fig)
        keep[y0:y1, x0:x1] = True
        keep &= ~other
        out[keep] = img[keep]
    if FIST_REBUILD:
        out = fist_backdrop(out, img.astype(float), fig, wide, fire_a[:rows], m[:rows])
    # Within 40 px of the fist fire the rig carries no rim ring
    # (beast_rig.RIM_OUT), so the figure fill's edge showed there as ragged
    # tan flecks beside the shoulder (grader 2026-10-09). Past the drawn
    # outline that fill is only TARGET's own glow: keep TARGET's pixels.
    if RIM_KEEP >= 0:
        fa = fire_a[:rows] > 0.5
        near_fire = ndi.binary_dilation(fa, iterations=RIM_KEEP_FIRE) & ~fa
        # What the rig actually draws at rest (its composite's alpha, 2x
        # TARGET from rig.BOX), not the silhouette masks: beside the fist
        # the rig's arm stops ~5 px inside TARGET's outline, and a dark fill
        # there read as a notch between two outlines (run 18).
        rest = np.asarray(Image.open(REST).convert("RGBA"))[..., 3].astype(float) / 255.0
        bx0, by0 = rig.BOX[0], rig.BOX[1]
        rh, rw = rest.shape[0] // rig.SCALE, rest.shape[1] // rig.SCALE
        rest = rest[:rh * rig.SCALE, :rw * rig.SCALE].reshape(rh, rig.SCALE, rw, rig.SCALE).mean((1, 3))
        cover = np.zeros(fig.shape, bool)
        ry1, rx1 = min(by0 + rh, rows), min(bx0 + rw, cover.shape[1])
        cover[by0:ry1, bx0:rx1] = rest[:ry1 - by0, :rx1 - bx0] > 0.9
        drawn = cover
        if RIM_KEEP > 0:
            drawn = ndi.binary_dilation(drawn, iterations=RIM_KEEP)
        keep = fig & ~drawn & near_fire & ~other
        out[keep] = img[keep]
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
    bottom = np.clip((rows - ys) / FADE_LEN, 0, 1)
    a *= bottom[:, None]
    # The colour table crushes TARGET's darkest values (inputs 0-8 draw 0, 10
    # draws ~3; measured on the fight, builder 2026-10-09): pre-map through
    # the inverse, as tools/floor_cut.py does, so the slate's dark facets show.
    out = np.interp(out, DARK_INV[0], DARK_INV[1])
    rgba = np.dstack([np.clip(out, 0, 255), a * 255]).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(OUT)
    print("backdrop:", OUT.relative_to(ROOT), rgba.shape[1], "x", rgba.shape[0])


if __name__ == "__main__":
    build()
