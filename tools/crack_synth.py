"""Carry TARGET's crack network on under the stones the cut-out lifts off.

beast_rig.py removes TARGET's slabs from the jackal's body and fills the
holes. An inpaint alone leaves a dark rock smudge there, and wherever the
fight's slab sits a few px off TARGET's the smudge shows: the sternum seam
stops dead under the top stone and the belly between the stones reads as
murk (builder, 2026-10-09, queue "Cracks: wide hot cores and a long sternum
seam"). This rebuilds the hole the way TARGET's painter drew the rest of
the body: crack-free rock, then every crack that runs into a hole carried
on through it, at its own width and colour, joined to the crack it meets on
the far side or run on and tapered out.

Deterministic (seeded). Coordinates are TARGET.png's 1024 px.
"""
import numpy as np
import cv2
from scipy import ndimage as ndi


def crack_mask(T):
    r, g, b = T[..., 0], T[..., 1], T[..., 2]
    mx, mn = T.max(2), T.min(2)
    sat = (mx - mn) / np.maximum(mx, 1)
    # Bright channels, and the dim red ones low on the belly: a thin line
    # redder than the rock round it.
    hat = r - ndi.grey_opening(r, size=(9, 9))
    return ((r > 135) & (sat > 0.62) & (r - b > 100)) | ((hat > 12) & (sat > 0.55) & (r > 45))


def rock_base(T, hole, m, allowed):
    """The hole filled with plain plate rock: no crack smears into it."""
    cr = crack_mask(T) & m
    near = ndi.binary_dilation(hole, iterations=14)
    kill = ndi.binary_dilation(cr & near, iterations=2) | ~m | ~allowed
    src = np.clip(T, 0, 255).astype(np.uint8).copy()
    fill = (kill & near) | hole
    base = cv2.inpaint(src, fill.astype(np.uint8) * 255, 7, cv2.INPAINT_TELEA).astype(float)
    return base


def entries(T, hole, m, allowed):
    cr = crack_mask(T) & m & allowed & ~hole
    dist = ndi.distance_transform_edt(~hole)
    ring = cr & (dist <= 3)
    lab, n = ndi.label(ring, structure=np.ones((3, 3)))
    hl, _ = ndi.label(hole)
    crl, _ = ndi.label(cr, structure=np.ones((3, 3)))
    edt = ndi.distance_transform_edt(cr)
    out = []
    for i in range(1, n + 1):
        ys, xs = np.nonzero(lab == i)
        if len(ys) < 3:
            continue
        cy, cx = ys.mean(), xs.mean()
        comp = crl[int(round(ys[0])), int(round(xs[0]))]
        # The crack behind the contact: pixels of the same crack 4-14 px off
        # the hole and within 14 px of the contact.
        yy, xx = np.nonzero((crl == comp) & (dist > 4) & (dist < 14))
        near = (yy - cy) ** 2 + (xx - cx) ** 2 < 14 ** 2
        if near.sum() < 3:
            continue
        by, bx = yy[near].mean(), xx[near].mean()
        d = np.array([cx - bx, cy - by])
        L = np.hypot(*d)
        if L < 1e-3:
            continue
        d /= L
        # Contact point: the ring pixel nearest the hole.
        k = np.argmin(dist[ys, xs])
        p = np.array([xs[k], ys[k]], float)
        p = np.array([cx, cy]) * 0.5 + p * 0.5
        # Width: twice the deepest crack pixel near the contact.
        w = 2.0 * edt[ys, xs].max() + 0.6
        cols = T[ys, xs]
        bright = cols.sum(1)
        core = cols[bright >= np.percentile(bright, 70)].mean(0)
        edge = cols[bright <= np.percentile(bright, 40)].mean(0)
        # Which hole: the hole pixel nearest the contact.
        sy, sx = int(round(p[1] + d[1] * 4)), int(round(p[0] + d[0] * 4))
        sy, sx = np.clip(sy, 0, hole.shape[0] - 1), np.clip(sx, 0, hole.shape[1] - 1)
        win = hl[max(sy - 5, 0):sy + 6, max(sx - 5, 0):sx + 6]
        ids = win[win > 0]
        if not len(ids):
            continue
        out.append(dict(p=p, d=d, w=min(max(w, 2.0), 9.0), core=core, edge=edge,
                        hole=int(np.bincount(ids).argmax())))
    return out


def plan(E, rng, extra=()):
    """Pair the entries that face each other; the rest run on and taper."""
    E = list(E) + list(extra)
    pairs, used = [], set()
    cand = []
    for i in range(len(E)):
        for j in range(i + 1, len(E)):
            a, b = E[i], E[j]
            if a["hole"] != b["hole"]:
                continue
            v = b["p"] - a["p"]
            L = np.hypot(*v)
            if L < 6:
                continue
            u = v / L
            fa, fb = a["d"] @ u, -(b["d"] @ u)
            if fa < 0.25 or fb < 0.25:
                continue
            cand.append((L * (2.2 - fa - fb), i, j))
    for c, i, j in sorted(cand):
        if i in used or j in used:
            continue
        used |= {i, j}
        pairs.append((i, j))
    singles = [i for i in range(len(E)) if i not in used]
    return E, pairs, singles


def seg_dist(X, Y, a, b):
    v = b - a
    L2 = max(v @ v, 1e-6)
    t = np.clip(((X - a[0]) * v[0] + (Y - a[1]) * v[1]) / L2, 0, 1)
    return np.hypot(X - (a[0] + t * v[0]), Y - (a[1] + t * v[1])), t


def row_colours(T, m, allowed, hole):
    """TARGET's crack core and edge colour by row, read off the visible
    cracks beside the holes: bright orange at the chest, dim red low down."""
    cr = crack_mask(T) & m & allowed & ~hole
    near = ndi.binary_dilation(hole, iterations=70) & cr
    H = T.shape[0]
    core = np.zeros((H, 3))
    edge = np.zeros((H, 3))
    ys, xs = np.nonzero(near)
    cols = T[ys, xs]
    lum = cols @ np.array([0.3, 0.59, 0.11])
    for y in range(H):
        k = np.abs(ys - y) < 14
        if k.sum() < 8:
            continue
        c, l = cols[k], lum[k]
        core[y] = c[l >= np.percentile(l, 75)].mean(0)
        edge[y] = c[l <= np.percentile(l, 45)].mean(0)
    # rows without samples take the nearest row that has them
    have = core.sum(1) > 0
    idx = np.nonzero(have)[0]
    if len(idx):
        for y in range(H):
            if not have[y]:
                j = idx[np.argmin(np.abs(idx - y))]
                core[y], edge[y] = core[j], edge[j]
    return core, edge


def network(hole, E, pairs, singles, rng, rows, spacing=19.0, longest=30.0):
    """Polylines for one fill: paired entries, entries run on to the nearest
    junction ahead, and a sparse web of junctions so a large hole reads as
    TARGET's plates, not a smudge."""
    from scipy.spatial import Delaunay
    core_r, edge_r = rows
    H, W = hole.shape
    lines = []
    for i, j in pairs:
        a, b = E[i], E[j]
        lines.append((a["p"], b["p"], a["w"], b["w"], a["core"], b["core"], a["edge"], b["edge"], a["d"], b["d"]))
    inner = ndi.distance_transform_edt(hole)
    hl, n = ndi.label(hole)
    J = []
    for h in range(1, n + 1):
        ys, xs = np.nonzero((hl == h) & (inner > 4))
        if len(ys) < 60:
            continue
        order = rng.permutation(len(ys))
        pts = []
        for k in order:
            q = np.array([xs[k], ys[k]], float)
            if all(np.hypot(*(q - p)) >= spacing for p in pts):
                pts.append(q)
        J += [(q, h) for q in pts]
    # the web between junctions
    jw = []
    if len(J) >= 3:
        P = np.array([q for q, _ in J])
        try:
            tri = Delaunay(P)
            seen = set()
            for t in tri.simplices:
                for u, v in ((t[0], t[1]), (t[1], t[2]), (t[0], t[2])):
                    key = (min(u, v), max(u, v))
                    if key in seen:
                        continue
                    seen.add(key)
                    if J[u][1] != J[v][1]:
                        continue
                    L = np.hypot(*(P[u] - P[v]))
                    if L > longest:
                        continue
                    # stay inside the hole
                    ok = all(hole[int(round(P[u][1] + (P[v][1] - P[u][1]) * t)),
                                  int(round(P[u][0] + (P[v][0] - P[u][0]) * t))] for t in np.linspace(0, 1, 7))
                    if ok and rng.random() < 0.6:
                        jw.append((u, v))
        except Exception:
            pass
    for u, v in jw:
        p, q = J[u][0], J[v][0]
        yp, yq = int(p[1]), int(q[1])
        w = rng.uniform(1.6, 2.6)
        lines.append((p, q, w, w, core_r[yp] * 0.85 + edge_r[yp] * 0.15, core_r[yq] * 0.85 + edge_r[yq] * 0.15,
                      edge_r[yp], edge_r[yq], None, None))
    # unpaired entries run to the best junction ahead of them, else taper out
    for i in singles:
        a = E[i]
        best, sc = None, -1e9
        for q, h in J:
            if h != a["hole"]:
                continue
            v = q - a["p"]
            L = np.hypot(*v)
            if L < 4 or L > 40:
                continue
            f = a["d"] @ (v / L)
            if f < 0.35:
                continue
            s_ = f * 2 - L / 30.0
            if s_ > sc:
                best, sc = q, s_
        if best is not None:
            y = int(best[1])
            w1 = max(a["w"] * 0.75, 1.8)
            lines.append((a["p"], best, a["w"], w1, a["core"], core_r[y], a["edge"], edge_r[y], a["d"], None))
        else:
            end = a["p"].copy()
            t = 0.0
            L = 18.0 * (0.6 + 0.12 * a["w"])
            while t < L:
                q = a["p"] + a["d"] * (t + 1)
                qy, qx = int(round(q[1])), int(round(q[0]))
                if not (0 <= qy < H and 0 <= qx < W) or (t > 4 and not hole[qy, qx]):
                    break
                end, t = q, t + 1
            lines.append((a["p"], end, a["w"], 0.4, a["core"], a["core"], a["edge"], a["edge"], a["d"], None))
    return lines, [q for q, _ in J]


def draw(img, hole, lines, rng):
    H, W = hole.shape
    Y, X = np.mgrid[0:H, 0:W].astype(float)
    core_a = np.zeros((H, W))
    edge_a = np.zeros((H, W))
    core_c = np.zeros((H, W, 3))
    edge_c = np.zeros((H, W, 3))
    for p0, p1, w0, w1, c0, c1, e0, e1, d0, d1 in lines:
        v = p1 - p0
        L = max(np.hypot(*v), 1e-3)
        nrm = np.array([-v[1], v[0]]) / L
        k = p0 + v * rng.uniform(0.4, 0.6) + nrm * L * rng.uniform(-0.12, 0.12)
        if d0 is not None:
            k = 0.75 * k + 0.25 * (p0 + d0 * L * 0.5)
        if d1 is not None:
            k = 0.8 * k + 0.2 * (p1 + d1 * L * 0.5)
        pts = [p0, k, p1]
        x0 = int(max(min(p[0] for p in pts) - 10, 0)); x1 = int(min(max(p[0] for p in pts) + 10, W))
        y0 = int(max(min(p[1] for p in pts) - 10, 0)); y1 = int(min(max(p[1] for p in pts) + 10, H))
        if x1 <= x0 or y1 <= y0:
            continue
        Xs, Ys = X[y0:y1, x0:x1], Y[y0:y1, x0:x1]
        best = np.full(Xs.shape, 1e9)
        bs = np.zeros(Xs.shape)
        for a, b, s0, s1 in ((pts[0], pts[1], 0.0, 0.5), (pts[1], pts[2], 0.5, 1.0)):
            d, t = seg_dist(Xs, Ys, a, b)
            take = d < best
            best = np.where(take, d, best)
            bs = np.where(take, s0 + (s1 - s0) * t, bs)
        w = w0 * (1 - bs) + w1 * bs
        sm = bs[..., None]
        cc = np.asarray(c0) * (1 - sm) + np.asarray(c1) * sm
        ec = np.asarray(e0) * (1 - sm) + np.asarray(e1) * sm
        half = w / 2.0
        ca = np.clip(half * 0.5 + 0.5 - best, 0, 1)
        ea = np.clip(half + 0.5 - best, 0, 1)
        sl = (slice(y0, y1), slice(x0, x1))
        upd = ca > core_a[sl]
        core_c[sl][upd] = cc[upd]
        core_a[sl] = np.maximum(core_a[sl], ca)
        upd = ea > edge_a[sl]
        edge_c[sl][upd] = ec[upd]
        edge_a[sl] = np.maximum(edge_a[sl], ea)
    out = img.copy()
    # plates: each piece of rock between the cracks a slightly different tone
    lab, n = ndi.label(hole & (edge_a < 0.3))
    if n:
        off = np.concatenate([[0], rng.uniform(-9, 11, n)])
        out = out + (off[lab] * hole)[..., None] * np.array([1.0, 0.4, 0.25])
    # a short warm glow round each crack, as TARGET's channels light the rock
    glow = ndi.gaussian_filter(edge_a, 1.6)
    gcol = ndi.gaussian_filter(edge_c * edge_a[..., None], (1.6, 1.6, 0)) / np.maximum(glow[..., None], 1e-4)
    hm = hole[..., None].astype(float)
    g = np.clip(glow * 0.35, 0, 0.35)[..., None] * hm
    out = out * (1 - g) + gcol * g
    ea = edge_a[..., None] * hm
    out = out * (1 - ea) + edge_c * ea
    ca = core_a[..., None] * hm
    out = out * (1 - ca) + core_c * ca
    return out


def fill(T, hole, m, allowed, seed=7, extra=()):
    """TARGET with each hole rebuilt: plate rock, cracks carried on."""
    rng = np.random.default_rng(seed)
    base = rock_base(T, hole, m, allowed)
    # lift the inpaint to the ring's plate tone (it pulls in the stones'
    # shadows and reads as a dark smudge)
    ring = ndi.binary_dilation(hole, iterations=10) & ~hole & m & allowed & ~crack_mask(T)
    hl, n = ndi.label(hole)
    for h in range(1, n + 1):
        hm_ = hl == h
        rg = ring & ndi.binary_dilation(hm_, iterations=10)
        if rg.sum() > 20:
            tone = np.median(T[rg], 0)
            cur = base[hm_].mean(0)
            base[hm_] = base[hm_] + (tone - cur) * 0.6
    E = entries(T, hole, m, allowed)
    E, pairs, singles = plan(E, rng, extra)
    rows = row_colours(T, m, allowed, hole)
    lines, J = network(hole, E, pairs, singles, rng, rows)
    out = T.astype(float).copy()
    out[hole] = base[hole]
    return draw(out, hole, lines, rng), E, pairs, singles
