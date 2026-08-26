## The pure, data-only half of the model shape contract (design/BACKLOG.md #74).
##
## Everything here takes plain triangle/UV arrays and returns numbers or bools —
## no file IO, no SceneTree, no Blender. That is deliberate: `assetcheck.gd`
## wires these to a real loaded .glb, but `run_tests.gd` can exercise the exact
## same logic against a handful of hand-built triangles, headless and in
## milliseconds, which is the only way this contract gets real regression
## coverage instead of "looked fine when I last ran it by hand."
##
## A triangle is `[Vector3, Vector3, Vector3]` in world space throughout.
class_name AssetContract
extends RefCounted

## kenney.py's own budget table (tools/blender/kenney.py BUDGET). Kept in sync
## by hand — there are three numbers, not worth a JSON file for.
const BUDGET := {"hunter": 1400, "beast": 2600, "prop": 500}

## The sigil is `taper(..., GOLD, ...)` in every beast script (tools/blender/
## beast.py `mark()`), and kenney.py's `_paint()` stamps EVERY loop of a part
## with the exact same UV point — swatch(464, 320) — so a correctly-painted
## sigil's average UV should land almost exactly here, not just "nearby."
##
## NOT `1.0 - 320.0/512.0`, even though that is what `swatch()` itself returns.
## `swatch()`'s result is a BLENDER uv (V=0 at the bottom), and Blender's glTF
## exporter flips V on the way out so the file matches glTF's V=0-at-top
## convention — which Godot then loads as-is. So the V that actually lands in
## the imported mesh is the un-flipped `320.0 / 512.0`: flip cancels flip.
## Measured against a real exported beast (crag_pup) while building this check,
## whose sigil cluster landed at (0.910, 0.630) against this cell's (0.906,
## 0.625) — a first version used the swatch()-literal V and found gold nowhere
## on any of the 14 already-shipped beasts, which was this bug, not fourteen
## unpainted sigils.
const GOLD_UV := Vector2(464.0 / 512.0, 320.0 / 512.0)
## Half the size of one 32px cell in the 512px atlas (32/512/2), minus a
## margin so a UV that has drifted into a NEIGHBOURING swatch — the actual
## failure this exists to catch — reads as outside, not as a near miss.
const UV_CELL_HALF := 0.02


static func budget_for(kind: String) -> int:
	return BUDGET.get(kind, BUDGET["hunter"])


## Average of a set of UVs lands within `half` of `cell_center`. Used both for
## the sigil-is-gold check and, generically, for "is this UV a palette swatch
## at all" (any of kenney.py's named cells, not just gold).
static func uv_in_cell(uvs: Array, cell_center: Vector2, half: float = UV_CELL_HALF) -> bool:
	if uvs.is_empty():
		return false
	var avg := Vector2.ZERO
	for uv in uvs:
		avg += uv
	avg /= uvs.size()
	return absf(avg.x - cell_center.x) <= half and absf(avg.y - cell_center.y) <= half


## Rasterise triangles' FRONT-ON (XY) silhouette into an n*n occupancy grid,
## uniformly scaled and centred on the triangles' OWN bounds — so two models of
## different size or position still compare on SHAPE, which is the only thing
## "is this a re-skin" should care about.
##
## XY, not XZ: every model is built facing +Z and stood on the XZ ground plane
## (tools/blender/README.md — "Blender -Y is forward... the export lands facing
## the camera"), so XY is the silhouette a PLAYER actually judges a re-skin by.
## A first version used XZ — the top-down footprint — and flagged pairs (the
## Gale Serpent against the Riftling) that share a similar FOOTPRINT while
## looking nothing alike face-on, which is the wrong axis for "does this read
## as the same creature."
static func silhouette_grid(tris: Array, n: int = 20) -> PackedByteArray:
	var grid := PackedByteArray()
	grid.resize(n * n)
	if tris.is_empty():
		return grid
	var minx := INF
	var maxx := -INF
	var miny := INF
	var maxy := -INF
	for tri in tris:
		for v in tri:
			minx = minf(minx, v.x)
			maxx = maxf(maxx, v.x)
			miny = minf(miny, v.y)
			maxy = maxf(maxy, v.y)
	var span: float = maxf(maxx - minx, maxy - miny)
	if span <= 0.0001:
		return grid
	var cx := (minx + maxx) * 0.5
	var cy := (miny + maxy) * 0.5
	var half := span * 0.5
	for gy in range(n):
		var py: float = cy + ((float(gy) + 0.5) / float(n) * 2.0 - 1.0) * half
		for gx in range(n):
			var px: float = cx + ((float(gx) + 0.5) / float(n) * 2.0 - 1.0) * half
			if _point_in_any_tri_xy(px, py, tris):
				grid[gy * n + gx] = 1
	return grid


## Jaccard index of two same-sized occupancy grids: 1.0 is identical silhouette,
## 0.0 is no overlap at all.
static func silhouette_similarity(a: PackedByteArray, b: PackedByteArray) -> float:
	if a.size() != b.size() or a.is_empty():
		return 0.0
	var inter := 0
	var uni := 0
	for i in range(a.size()):
		var av := a[i] != 0
		var bv := b[i] != 0
		if av or bv:
			uni += 1
		if av and bv:
			inter += 1
	if uni == 0:
		return 0.0
	return float(inter) / float(uni)


static func _point_in_any_tri_xy(px: float, py: float, tris: Array) -> bool:
	for tri in tris:
		if _point_in_tri_xy(px, py, tri[0], tri[1], tri[2]):
			return true
	return false


static func _point_in_tri_xy(px: float, py: float, a: Vector3, b: Vector3, c: Vector3) -> bool:
	var d1 := _sign_xy(px, py, a, b)
	var d2 := _sign_xy(px, py, b, c)
	var d3 := _sign_xy(px, py, c, a)
	var has_neg := d1 < 0.0 or d2 < 0.0 or d3 < 0.0
	var has_pos := d1 > 0.0 or d2 > 0.0 or d3 > 0.0
	return not (has_neg and has_pos)


static func _sign_xy(px: float, py: float, a: Vector3, b: Vector3) -> float:
	return (px - b.x) * (a.y - b.y) - (a.x - b.x) * (py - b.y)
