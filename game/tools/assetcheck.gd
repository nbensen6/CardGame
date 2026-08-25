## Check a model you made against the pipeline contract, before it ever has to
## look wrong in-game.
##
##   Godot_v4.7.1-stable_win64_console.exe --headless --path game \
##     --script res://tools/assetcheck.gd -- file=res://assets/3d/cast/frog.glb
##
## Why this exists: the five rules in design/blender-pipeline.md (facing, origin,
## applied transforms, .glb, embedded textures) are all invisible until the thing
## is standing in a fight looking wrong, and then it is guesswork which rule you
## broke. This reads the mesh and tells you which one, in seconds.
##
## It never edits your file. It reports.
extends SceneTree

const CAST := "res://assets/3d/cast/"


func _initialize() -> void:
	var path := ""
	var beast := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("file="):
			path = a.substr(5)
		elif a.begins_with("beast="):
			beast = a.substr(6)
	if path == "":
		print("usage: --script res://tools/assetcheck.gd -- file=res://assets/3d/cast/yours.glb")
		print("\nA reference model to compare against:")
		_report(CAST + "bunny.glb", "REFERENCE (Kenney bunny)")
		quit()
		return
	if not path.begins_with("res://"):
		path = CAST + path            # bare filenames mean the cast folder
	if not path.ends_with(".glb"):
		path += ".glb"
	_report(path, "YOUR MODEL", beast)
	print("\n--- compared against a Kenney model that already works ---")
	_report(CAST + "bunny.glb", "REFERENCE (bunny)")
	quit()


func _report(path: String, label: String, beast_id: String = "") -> void:
	print("\n=== %s: %s ===" % [label, path])
	if not ResourceLoader.exists(path):
		print("  MISSING. Export from Blender to that path, then run this again.")
		return
	var scene := load(path) as PackedScene
	if scene == null:
		print("  FAIL  not a loadable scene. Export as glTF 2.0 BINARY (.glb).")
		return
	var root := scene.instantiate() as Node3D
	if root == null:
		print("  FAIL  no 3D root node.")
		return
	get_root().add_child(root)

	var meshes := _meshes(root)
	if meshes.is_empty():
		print("  FAIL  no mesh in the file. Did the export include the selected object?")
		root.queue_free()
		return

	var box := _merged_aabb(root)
	var tris := 0
	var mats := {}
	for m in meshes:
		var mi := m as MeshInstance3D
		if mi.mesh != null:
			for s in range(mi.mesh.get_surface_count()):
				var arr: Array = mi.mesh.surface_get_arrays(s)
				if arr.size() > Mesh.ARRAY_INDEX and arr[Mesh.ARRAY_INDEX] != null:
					tris += (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
				var mat := mi.mesh.surface_get_material(s)
				if mat != null:
					mats[mat.resource_name if mat.resource_name != "" else str(mat)] = true

	print("  meshes %d   triangles %d   materials %d" % [meshes.size(), tris, mats.size()])
	print("  size    x %.3f  y %.3f  z %.3f" % [box.size.x, box.size.y, box.size.z])
	print("  bottom  y %.3f   (origin sits %s the mesh)" % [box.position.y,
		"AT" if absf(box.position.y) < 0.02 else "OFF"])

	# Rule 2 — origin at the feet. The game positions models by their base, so a
	# centred origin buries half the model in the ground.
	if absf(box.position.y) < 0.02:
		print("  PASS  origin is at the feet")
	else:
		print("  FAIL  origin is %.3f from the mesh bottom. In Blender put the 3D" % box.position.y)
		print("        cursor on the floor between the feet, then Object > Set Origin")
		print("        > Origin to 3D Cursor. Otherwise it floats or sinks.")

	# Centred left-right, so it doesn't stand off to one side of where it's placed.
	var cx := box.position.x + box.size.x * 0.5
	if absf(cx) < maxf(0.05, box.size.x * 0.08):
		print("  PASS  centred left-right")
	else:
		print("  WARN  centre is %.3f off in X — it will stand beside its spot, not on it" % cx)

	if beast_id != "":
		_check_holds(root, box, beast_id)
	_check_climb(root, box, beast_id)

	# Rule 3 — applied transforms. An unapplied scale makes the measured bounds
	# lie, and every size in the game is derived from those bounds.
	var s := root.scale
	if absf(s.x - 1.0) < 0.001 and absf(s.y - 1.0) < 0.001 and absf(s.z - 1.0) < 0.001:
		print("  PASS  transforms applied (root scale is 1)")
	else:
		print("  FAIL  root scale is (%.3f, %.3f, %.3f). In Blender: Ctrl+A > All" % [s.x, s.y, s.z])
		print("        Transforms before exporting, or the game mis-measures it.")

	# Facing can't be read from geometry, but a creature is almost always deeper
	# than it is wide, so a much wider silhouette usually means it's turned 90°.
	if box.size.z >= box.size.x * 0.6:
		print("  PASS  proportions look forward-facing (depth vs width)")
	else:
		print("  WARN  %.1fx wider than deep — often means it faces X, not +Z." % (box.size.x / maxf(box.size.z, 0.001)))
		print("        Check it looks along +Z. This is the one that's annoying to fix later.")

	if tris > 6000:
		print("  WARN  %d triangles. The style here is low-poly (the bunny is a few" % tris)
		print("        hundred); this will still work but won't match.")

	root.queue_free()


func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out += _meshes(c)
	return out


func _merged_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for node in _meshes(root):
		var vi := node as VisualInstance3D
		var box: AABB = vi.transform * vi.get_aabb()
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	return out


## The hold contract: a beast whose body has no shelf where its data says there
## is one is a beast you climb by floating.
##
## The view places hunters at lerp(0.18, 0.80) of the model's bounding box, so a
## beast with ledges [3, 6, 9] and a sigil at 11 needs somewhere to STAND at 35%,
## 52% and 69% of its height.
##
## It measures UPWARD-FACING surface, not "is there body here". The first version
## asked whether the model was wide at that height, and a bunny passed as the
## Sunken Warden — of course it did, a solid blob has body everywhere. A hold is
## a shelf: faces whose normals point at the sky. That distinction is the entire
## value of this check, because it is the one thing a run with no eyes cannot
## get right by accident.
func _check_holds(root: Node3D, box: AABB, beast_id: String) -> void:
	var b: Boss = Content.build_boss(beast_id)
	if b == null or b.weak_point_height <= 0:
		print("  WARN  no beast data for '%s' — cannot check holds" % beast_id)
		return
	var tris := _tris(root)
	if tris.is_empty():
		return
	var heights: Array = b.ledge_heights()
	heights.append(b.weak_point_height)
	# A hold worth standing on, as a fraction of the model's footprint. Measured
	# against the three beasts built by hand and against models that should fail.
	var want := box.size.x * box.size.z * 0.020
	var bad := 0
	for h in heights:
		var t := clampf(float(h) / float(b.weak_point_height), 0.0, 1.0)
		var y := box.position.y + box.size.y * lerpf(0.18, 0.80, t)
		var band := box.size.y * 0.055
		var flat := 0.0
		for tri in tris:
			var a: Vector3 = tri[0]
			var c: Vector3 = tri[1]
			var d: Vector3 = tri[2]
			var mid := (a + c + d) / 3.0
			if absf(mid.y - y) > band:
				continue
			var cross := (c - a).cross(d - a)
			var area := cross.length() * 0.5
			if area <= 0.0:
				continue
			if absf(cross.normalized().y) > 0.55:   # points at the sky (or the floor under a lip)
				flat += area
		var what := "sigil" if h == b.weak_point_height else "hold"
		if flat < want:
			print("  FAIL  %s at Height %d (%.0f%% up): %.3f of shelf to stand on, wants %.3f"
				% [what, h, t * 100.0, flat, want])
			bad += 1
	if bad == 0:
		print("  PASS  every hold and the sigil have a shelf at their Height")


## The climb points a model carries with it.
##
## tools/blender/beast.py drops an empty called `climb_<Height>` at every place a
## hunter actually stands, and glTF carries empties through as plain nodes. That
## is the whole mechanism: the route travels WITH the art, so moving a shoulder
## in Blender moves the hunter who stands on it, with nothing to keep in sync.
##
## Without them the view falls back to the bounding box, which is how hunters
## ended up hovering in FRONT of a beast instead of on its ledges.
func _check_climb(root: Node3D, box: AABB, beast_id: String) -> void:
	var found := {}
	_collect_climb(root, root.transform, found)
	if found.is_empty():
		if beast_id != "":
			print("  WARN  no climb points. The view will place hunters off the")
			print("        bounding box, which puts them in front of the body.")
			print("        Add shelf()/anchor()/foot() calls in the build script.")
		return
	var keys: Array = found.keys()
	keys.sort()
	var bits: Array = []
	for h in keys:
		var p: Vector3 = found[h]
		var up: float = (p.y - box.position.y) / maxf(box.size.y, 0.001)
		bits.append("%s@%.0f%%" % ["ground" if int(h) == 0 else "H%d" % int(h), up * 100.0])
	print("  PASS  %d climb points: %s" % [keys.size(), ", ".join(bits)])
	if beast_id == "":
		return
	var b: Boss = Content.build_boss(beast_id)
	if b == null:
		return
	var want: Array = b.ledge_heights()
	want.append(b.weak_point_height)
	for h in want:
		if not found.has(int(h)):
			print("  WARN  Height %d has a hold but no climb point — a hunter" % int(h))
			print("        standing there falls back to the bounding box.")


## Walks the accumulated transform down rather than asking for global_position,
## which needs the node to be inside the tree and reports (0,0,0) when it isn't.
func _collect_climb(n: Node, xf: Transform3D, out: Dictionary) -> void:
	if n is Node3D and String(n.name).begins_with("climb_"):
		var tail := String(n.name).substr(6)
		if tail.is_valid_int():
			out[tail.to_int()] = xf.origin
	for c in n.get_children():
		var next := xf
		if c is Node3D:
			next = xf * (c as Node3D).transform
		_collect_climb(c, next, out)


## Every triangle in world space, for the hold check.
func _tris(root: Node3D) -> Array:
	var out: Array = []
	for m in _meshes(root):
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		for s in range(mi.mesh.get_surface_count()):
			var arr: Array = mi.mesh.surface_get_arrays(s)
			if arr.size() <= Mesh.ARRAY_INDEX or arr[Mesh.ARRAY_VERTEX] == null:
				continue
			var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var idx = arr[Mesh.ARRAY_INDEX]
			var xf := mi.global_transform
			if idx == null:
				for i in range(0, verts.size() - 2, 3):
					out.append([xf * verts[i], xf * verts[i + 1], xf * verts[i + 2]])
			else:
				var ii: PackedInt32Array = idx
				for i in range(0, ii.size() - 2, 3):
					out.append([xf * verts[ii[i]], xf * verts[ii[i + 1]], xf * verts[ii[i + 2]]])
	return out
