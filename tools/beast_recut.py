"""Re-cut the drawn jackal's rig layers from the clean sprite.

Nick, 2026-10-21: the jackal in the fight still had a rock wall on its left,
painted stones on its belly and a glow round the flame, after the sprite had
been regenerated clean through Meshy (0ac2010a). The fight never draws
cinder_jackal_2d.png: drawn_rig.gd swaps the Body's texture for the Rig
viewport, which draws the seven *_<part>.png layers beast_rig.py cut from
TARGET.png on 2026-10-10 -- wall, stones and glow included. Fixing the
composite could never reach the screen.

This cuts the layers from the clean sprite instead, on beast_rig.py's own
part polygons, joint bands and fire frames, and patches the Art positions in
the .tscn. pixel_size, floor_px, mid_px, the holds and the clips stay.

    python tools/beast_recut.py
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

sys.path.insert(0, str(Path(__file__).resolve().parent))
import beast_rig as R

S = R.SCALE
FLAME_ORANGE = np.array([250, 120, 30], float)


def cv(p):
    """TARGET px -> rig canvas px."""
    return ((p[0] - R.BOX[0]) * S, (p[1] - R.BOX[1]) * S)


def art_span(tscn, part):
    """The span of `position = Vector2(...)` on `part`'s Art sprite."""
    i = tscn.index('[node name="Art" type="Sprite2D" parent="Rig/Root/%s"]' % R.bone_path(part))
    j = tscn.index("position = Vector2(", i)
    return j, tscn.index(")", j) + 1


def old_mask(tscn, parts, thresh=250):
    """Where the current rig's `parts` are solid, on the canvas."""
    H = W = None
    out = None
    for part in parts:
        j, k = art_span(tscn, part)
        ax, ay = (float(v) for v in tscn[j:k][len("position = Vector2("):-1].split(","))
        px, py = cv(R.PIVOT[part])
        x0, y0 = int(round(px + ax)), int(round(py + ay))
        L = np.asarray(Image.open(R.OUT / f"{R.ID}_2d_{part}.png").convert("RGBA"))
        if out is None:
            out = np.zeros((1016, 1560), bool)
        h, w = L.shape[:2]
        out[y0:y0 + h, x0:x0 + w] |= L[..., 3] >= thresh
    return out


def main():
    scene = R.OUT / f"{R.ID}_2d.tscn"
    tscn = scene.read_text()
    im = np.asarray(Image.open(R.OUT / f"{R.ID}_2d.png").convert("RGBA")).astype(float)
    H, W = im.shape[:2]
    rgb, al = im[..., :3], im[..., 3]
    solid = al > 0

    # The flame: the clean sprite's pixels in the fire box that are not the
    # fist or the arm. The fist and the flame meet along the fist's gold line,
    # which a colour key reads as flame, so the fist is the old rig's cut of
    # it (registered to this canvas within a pixel), grown one.
    fist = ndi.binary_dilation(old_mask(tscn, ("arm_l", "fore_l")), iterations=1)
    fire_box = R.poly_mask([tuple(int(v) for v in cv(p)) for p in R.FIRE_BOX], (H, W))
    fire_region = solid & fire_box & ~fist
    lab, n = ndi.label(al > 128)
    sizes = ndi.sum(np.ones_like(lab), lab, range(1, n + 1))
    specks = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s < 400])
    fire_region &= ~specks
    fire_a = np.where(fire_region, al / 255.0, 0.0)
    fire_rgb = rgb.copy()
    # Behind the fist and arm the flame is grown in from its nearest tongue,
    # solid 60 TARGET px in and fading by 120, so the swing never opens a
    # fist-shaped hole in it (beast_rig.fire_layer's rule).
    hid = fire_box & fist & solid
    dist, (iy, ix) = ndi.distance_transform_edt(~(fire_a > 0.5), return_indices=True)
    grown = rgb[iy, ix] * 0.25 + FLAME_ORANGE * 0.75
    fire_rgb = np.where(hid[..., None], grown, fire_rgb)
    fire_a = np.where(hid, np.clip(2.0 - dist / (60.0 * S), 0, 1), fire_a)

    # The body: every other pixel, cut on the part polygons.
    m = solid & ~fire_region
    lab = np.full((H, W), "torso", object)
    for name, _, _, pts in R.PARTS:
        lab[R.poly_mask([tuple(int(v) for v in cv(p)) for p in pts], (H, W)) & m] = name
    lab[~m] = ""
    names = ["torso"] + [p[0] for p in R.PARTS]
    own = {k: lab == k for k in names}
    alpha = {k: own[k].copy() for k in names}
    # Each parent keeps a band of its child's pixels under the cut (short of
    # the rim), so a part that swings off shows rock, not a hole.
    deep = ndi.distance_transform_edt(m) > R.RIM * S
    for name, parent, _, _ in R.PARTS:
        near = ndi.distance_transform_edt(~own[parent]) <= R.UNDERLAY * S
        alpha[parent] |= own[name] & near & deep
    rim = ndi.distance_transform_edt(m) > (R.RIM - 2) * S

    placed = {}
    for name in R.ORDER:
        if name == "fire":
            frames = R.fire_frames(np.dstack([fire_rgb, fire_a * 255.0]))
        else:
            a = alpha[name]
            # The band's own edge, inked: the joint's outline once the child
            # swings off it.
            edge = a & ~ndi.binary_erosion(a, iterations=4 * S) & ~own[name] & rim
            col = rgb.copy()
            col[edge] = R.LINE
            frames = [np.dstack([col, np.where(a, al, 0.0)])]
        ys, xs = np.nonzero(np.max([F[..., 3] for F in frames], axis=0) > 0)
        x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
        strip = np.concatenate([F[y0:y1, x0:x1] for F in frames], axis=1)
        Image.fromarray(np.clip(strip, 0, 255).astype(np.uint8), "RGBA").save(
            R.OUT / f"{R.ID}_2d_{name}.png", optimize=True)
        placed[name] = (int(x0), int(y0))

    for name in R.ORDER:
        px, py = cv(R.PIVOT[name])
        j, k = art_span(tscn, name)
        tscn = tscn[:j] + f"position = Vector2({placed[name][0] - px:g}, {placed[name][1] - py:g})" + tscn[k:]
    scene.write_text(tscn)

    # Self-check: the layers at rest cover the clean sprite and nothing else.
    comp = np.zeros((H, W), bool)
    for name in R.ORDER:
        L = np.asarray(Image.open(R.OUT / f"{R.ID}_2d_{name}.png").convert("RGBA"))
        if name == "fire":
            L = L[:, :L.shape[1] // R.FIRE_FRAMES]
        x0, y0 = placed[name]
        comp[y0:y0 + L.shape[0], x0:x0 + L.shape[1]] |= L[..., 3] > 128
    want = al > 128
    missing, extra = int((want & ~comp).sum()), int((comp & ~want).sum())
    assert missing < want.sum() * 0.002, missing
    print(f"{R.ID}: {len(R.ORDER)} layers recut; {missing} px of the sprite uncovered, {extra} px grown behind the fist")


if __name__ == "__main__":
    main()
