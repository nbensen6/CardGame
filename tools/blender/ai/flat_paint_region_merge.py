"""Flat vertex-colour hunter pipeline, step 2 of 3 (see flat_paint_dump.py).
Merge a mesh's faces into K spatially-CONTIGUOUS colour regions.

Per-face colour clustered by colour-similarity ALONE still checkerboards:
two neighbouring facets of the same body part often land in different-but-
close clusters (the source texture has baked micro-shading/AO per Meshy),
and once the mesh is only ~900 screen pixels that near-miss alternation
reads as noise, same as the photoreal texture did. This instead only ever
merges ADJACENT faces (graph-constrained, greedy nearest-colour-pair
agglomeration), so a final region is always one connected patch of the
actual mesh, the way a person paints by body part. A shipped low-poly cast
model is typically NOT one connected mesh (Meshy leaves small greeble --
bolts, spikes -- unwelded to the body, see goblin_mech_ai.md pass 9), so once
adjacency is exhausted within each connected piece, whatever pieces are left
merge by nearest colour alone (a stray unwelded bolt is tiny and reads fine
wearing its closest neighbour's colour).

Input JSON (flat_paint_dump.py): {"uvs": [[ [u,v]x3 ]...], "adjacency": [[a,b]...]}
Source texture supplies the per-face starting colour. Output: {face_index: [r,g,b]}.

    python3 flat_paint_region_merge.py <src_tex> <face_data.json> <out_colors.json> <k>
"""
import json, sys
import numpy as np
from PIL import Image, ImageDraw

def face_colors_from_texture(src_tex, tris):
    src = Image.open(src_tex).convert("RGB")
    W, H = src.size
    arr = np.asarray(src, dtype=np.float32)
    colors = np.zeros((len(tris), 3), dtype=np.float32)
    mask_img = Image.new("L", (W, H), 0)
    draw = ImageDraw.Draw(mask_img)
    for i, uvs in enumerate(tris):
        pts = [(u * W, (1.0 - v) * H) for (u, v) in uvs]
        draw.polygon(pts, fill=255)
        bbox = mask_img.getbbox()
        if bbox is None:
            colors[i] = [128, 128, 128]
            continue
        x0, y0, x1, y1 = bbox
        sub_mask = np.asarray(mask_img)[y0:y1, x0:x1] > 0
        if sub_mask.sum() == 0:
            cx = int(sum(p[0] for p in pts) / 3)
            cy = int(sum(p[1] for p in pts) / 3)
            cx, cy = min(max(cx, 0), W - 1), min(max(cy, 0), H - 1)
            colors[i] = arr[cy, cx]
        else:
            sub = arr[y0:y1, x0:x1]
            colors[i] = sub[sub_mask].mean(axis=0)
        draw.rectangle([0, 0, W, H], fill=0)
    return colors


def region_merge(face_colors, adjacency_pairs, target_k):
    n = len(face_colors)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    color_sum = face_colors.astype(np.float64).copy()
    count = np.ones(n)
    edges = set()
    for a, b in adjacency_pairs:
        if a != b:
            edges.add((min(a, b), max(a, b)))
    edges = list(edges)

    num_regions = n
    while num_regions > target_k:
        best, best_d = None, None
        seen = set()
        any_pair = False
        for a, b in edges:
            ra, rb = find(a), find(b)
            if ra == rb:
                continue
            any_pair = True
            key = (min(ra, rb), max(ra, rb))
            if key in seen:
                continue
            seen.add(key)
            ca = color_sum[ra] / count[ra]
            cb = color_sum[rb] / count[rb]
            d = float(np.sum((ca - cb) ** 2))
            if best_d is None or d < best_d:
                best_d, best = d, (ra, rb)
        if not any_pair:
            print("REPORT adjacency_exhausted_at", num_regions,
                  "-- falling back to nearest-colour merging across the",
                  "remaining disconnected parts (small greeble Meshy never",
                  "welded to the body, see goblin_mech_ai.md pass 9)")
            break
        ra, rb = best
        color_sum[ra] += color_sum[rb]
        count[ra] += count[rb]
        parent[rb] = ra
        num_regions -= 1

    # Phase 2: whatever's left is disconnected from everything else (isolated
    # islands with no shared edge to merge across) -- merge those purely by
    # nearest colour, since a stray unwelded bolt/spike is tiny and reads
    # fine wearing its closest neighbour's colour rather than its own cluster.
    while num_regions > target_k:
        roots_now = sorted(set(find(i) for i in range(n)))
        best, best_d = None, None
        for ai in range(len(roots_now)):
            for bi in range(ai + 1, len(roots_now)):
                ra, rb = roots_now[ai], roots_now[bi]
                ca = color_sum[ra] / count[ra]
                cb = color_sum[rb] / count[rb]
                d = float(np.sum((ca - cb) ** 2))
                if best_d is None or d < best_d:
                    best_d, best = d, (ra, rb)
        ra, rb = best
        color_sum[ra] += color_sum[rb]
        count[ra] += count[rb]
        parent[rb] = ra
        num_regions -= 1

    roots = [find(i) for i in range(n)]
    final = np.zeros((n, 3))
    for i in range(n):
        r = roots[i]
        final[i] = color_sum[r] / count[r]
    return final, roots


def brighten_floor(colors_rgb, min_v=0.55):
    """A region's colour is the average of the SOURCE texture, which already
    has Meshy's own baked shadow/AO in it -- mixed again with toon.gdshader's
    real-time shadow band, a naturally-dark patch (a boot, a leg) crosses
    into looking like a hole in the silhouette rather than a dark colour.
    Floors HSV value so no final swatch reads as near-black; hue/saturation
    (the actual colour identity) are untouched."""
    import colorsys
    out = colors_rgb.copy()
    for i in range(len(out)):
        r, g, b = (out[i] / 255.0).tolist()
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        if v < min_v:
            v = min_v
            r, g, b = colorsys.hsv_to_rgb(h, s, v)
            out[i] = [r * 255.0, g * 255.0, b * 255.0]
    return out


def main(src_tex, face_data_json, out_json, k):
    data = json.load(open(face_data_json))
    tris = data["uvs"]
    adjacency = data["adjacency"]
    face_colors = face_colors_from_texture(src_tex, tris)
    final_colors, roots = region_merge(face_colors, adjacency, k)
    final_colors = brighten_floor(final_colors)
    n_regions = len(set(roots))
    print("REPORT final_region_count", n_regions)
    result = {i: [int(final_colors[i][0]), int(final_colors[i][1]), int(final_colors[i][2])]
              for i in range(len(tris))}
    json.dump(result, open(out_json, "w"))
    print("REPORT saved", out_json)


if __name__ == "__main__":
    src_tex, face_data_json, out_json, k = sys.argv[1:5]
    main(src_tex, face_data_json, out_json, int(k))
