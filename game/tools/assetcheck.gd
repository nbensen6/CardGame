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
	for a in OS.get_cmdline_user_args():
		if a.begins_with("file="):
			path = a.substr(5)
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
	_report(path, "YOUR MODEL")
	print("\n--- compared against a Kenney model that already works ---")
	_report(CAST + "bunny.glb", "REFERENCE (bunny)")
	quit()


func _report(path: String, label: String) -> void:
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
