## The overworld — the run map as a PLACE you walk, not a column of buttons.
##
## Step 3 of design/3d-pivot.md. `RunMap` is already a DAG of rows and edges;
## this renders it as a hex field. Each node is one Kenney Hexagon Kit tile whose
## landmark tells you what it is (watchtower = fight, castle = elite, cabin =
## rest, market = shop, wizard tower = event, mine = treasure, mountain = Titan),
## the gaps between connected nodes are laid with dirt road, and everything else
## is terrain — so the route reads as a journey through a region.
##
## Choosing a route stops being a click on a button: you click a reachable
## location, your hunter WALKS the road to it, and arriving is what commits
## `pick_node()`. The rules never change — /core still owns the map, the edges
## and the node types; this is only a different way to stand on them.
extends Node3D

const HEX := "res://assets/3d/hex/"
const CAST := "res://assets/3d/cast/"

## Hexagon Kit tiles measure 1.0 across the flats (X) and 1.1547 point-to-point
## (Z) — a pointy-top hex — with the walkable surface at y = 0.2.
const HEX_W := 1.0
const HEX_D := 1.154701
const ROW_STEP := HEX_D * 0.75  # 0.866 — how far one hex row advances in Z
const TILE_TOP := 0.2

## Node type -> the landmark tile that says what happens there.
const NODE_TILE := {
	"fight": "building-tower",
	"elite": "building-castle",
	"rest": "building-cabin",
	"shop": "building-market",
	"event": "building-wizard-tower",
	"treasure": "building-mine",
	"boss": "stone-mountain",
}
const NODE_LABEL := {
	"fight": "Beast", "elite": "Elite", "rest": "Camp", "shop": "Trader",
	"event": "Omen", "treasure": "Cache", "boss": "TITAN",
}
const FILLER := ["grass", "grass", "grass", "grass", "grass-forest",
	"grass-hill", "grass-hill", "stone", "stone-hill"]
const ROAD_W := 0.13  # roads are drawn between node centres, not laid as tiles —
                      # a tile is far too coarse to say WHICH edges exist
## Which model plays each hunter — same table the combat view uses.
const HUNTER_MODEL := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey",
}
const HUNTER_HEIGHT := 0.5  # world units — measured, not guessed, so any
                            # cast model reads at the same size beside a tile
const WALK_SPEED := 2.6  # hexes per second along the road

var _client: GameClient
var _nodes := {}       # col -> {node: Node3D, pos: Vector3, type: String, open: bool}
var _act := -1
var _laid_row := -99   # the map row the field was last built for
var _avatar: Node3D
var _walking := false
var _time := 0.0

@onready var _field: Node3D = %Field
@onready var _markers: Node3D = %Markers
@onready var _cam: Camera3D = %Camera
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle


func _ready() -> void:
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	if not _client.shared.is_empty():
		_refresh()


func _process(delta: float) -> void:
	_time += delta
	# available locations breathe so the eye finds them without a UI overlay
	for c in _markers.get_children():
		var m: Node3D = c
		m.position.y = float(m.get_meta("base_y", 0.0)) + sin(_time * 3.0) * 0.09
		m.rotation.y += delta * 1.4


func _unhandled_input(event: InputEvent) -> void:
	if _walking or not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	var col := _node_under_mouse(mb.position)
	if col >= 0 and bool(_nodes[col]["open"]):
		_travel_to(col)


# --- building the field ---------------------------------------------------

func _refresh() -> void:
	var s: Dictionary = _client.shared
	if String(s.get("phase", "")) != "map":
		return
	var m: Dictionary = s.get("map", {})
	var rows: Array = m.get("rows", [])
	var cur_row := int(m.get("row", -1))
	var cur_col := int(m.get("col", 0))
	var avail: Array = m.get("available", [])
	if rows.is_empty():
		return
	var act := 0
	if cur_row >= 0 and cur_row < rows.size():
		act = int((rows[cur_row] as Array)[cur_col].get("act", 0))
	else:
		act = int((rows[0] as Array)[0].get("act", 0))
	_title.text = "Act %d of %d" % [act + 1, int(s.get("total_encounters", 4))]
	_subtitle.text = "Walk to where you'll go next"
	if act != _act or cur_row != _laid_row:
		_act = act
		_laid_row = cur_row
		_lay_field(rows, act, cur_row, cur_col, avail)
	_place_avatar(s, cur_row, cur_col)


## Rebuild the region for the act you're in. Node rows land on EVEN hex rows so
## the odd rows between them are free for the road.
func _lay_field(rows: Array, act: int, cur_row: int, cur_col: int, avail: Array) -> void:
	for c in _field.get_children():
		c.queue_free()
	for c in _markers.get_children():
		c.queue_free()
	_nodes.clear()
	var act_rows: Array = []  # map-row index of each row in this act, in order
	for r in range(rows.size()):
		if int((rows[r] as Array)[0].get("act", 0)) == act:
			act_rows.append(r)
	if act_rows.is_empty():
		return
	# where each map row/col sits on the hex grid
	var spot := {}  # "r,c" -> Vector2i(hex_col, hex_row)
	var min_hc := 99
	var max_hc := -99
	for i in range(act_rows.size()):
		var r: int = act_rows[i]
		var row: Array = rows[r]
		var hex_row: int = i * 2
		for c in range(row.size()):
			var hex_col: int = (c * 2) - (row.size() - 1)
			spot["%d,%d" % [r, c]] = Vector2i(hex_col, hex_row)
			min_hc = mini(min_hc, hex_col)
			max_hc = maxi(max_hc, hex_col)
	# terrain under everything, so the route sits IN a region
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d/%d" % [act, _client.shared.get("seed", 0)])
	var taken := {}
	for key in spot:
		taken[spot[key]] = true
	for hr in range(-1, act_rows.size() * 2):
		for hc in range(min_hc - 2, max_hc + 3):
			var at := Vector2i(hc, hr)
			if taken.has(at):
				continue
			_place_tile(FILLER[rng.randi() % FILLER.size()], hc, hr,
				rng.randi_range(0, 5) * (PI / 3.0))
	# the landmarks themselves
	for i in range(act_rows.size()):
		var r: int = act_rows[i]
		var row: Array = rows[r]
		for c in range(row.size()):
			var at: Vector2i = spot["%d,%d" % [r, c]]
			var type := String((row[c] as Dictionary).get("type", "fight"))
			var node := _place_tile(String(NODE_TILE.get(type, "building-tower")), at.x, at.y, 0.0)
			var pos := Vector3(_hex_x(at.x, at.y), TILE_TOP, -at.y * ROW_STEP)
			var open: bool = (r == cur_row + 1 and avail.has(c))
			if open:
				_nodes[c] = {"node": node, "pos": pos, "type": type, "open": true}
				_add_marker(pos)
			_add_label(pos, String(NODE_LABEL.get(type, "?")), type == "boss",
				at.y, _height_of(node) if node != null else 1.0)
	_draw_roads(rows, act_rows, spot, cur_row, cur_col)
	_frame_camera(act_rows.size())


## One road per EDGE, drawn between the two landmarks it joins. Roads you can
## take right now are bright; the rest are faint, so the route can be read
## several rows ahead exactly like the 2D map's edges.
func _draw_roads(rows: Array, act_rows: Array, spot: Dictionary,
		cur_row: int, cur_col: int) -> void:
	var bright := ImmediateMesh.new()
	var faint := ImmediateMesh.new()
	bright.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	faint.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var any_bright := false
	for i in range(act_rows.size() - 1):
		var r: int = act_rows[i]
		var row: Array = rows[r]
		for c in range(row.size()):
			var from: Vector2i = spot["%d,%d" % [r, c]]
			for n in (row[c] as Dictionary).get("next", []):
				var key := "%d,%d" % [act_rows[i + 1], int(n)]
				if not spot.has(key):
					continue
				var to: Vector2i = spot[key]
				var a := Vector3(_hex_x(from.x, from.y), TILE_TOP + 0.012, -from.y * ROW_STEP)
				var b := Vector3(_hex_x(to.x, to.y), TILE_TOP + 0.012, -to.y * ROW_STEP)
				var walkable: bool = (r == cur_row and c == cur_col)
				any_bright = any_bright or walkable
				_ribbon(bright if walkable else faint, a, b)
	bright.surface_end()
	faint.surface_end()
	_add_ribbon_mesh(faint, Color(0.55, 0.44, 0.3, 0.85))
	if any_bright:
		_add_ribbon_mesh(bright, Color(1.0, 0.87, 0.5, 0.95))


func _ribbon(mesh: ImmediateMesh, a: Vector3, b: Vector3) -> void:
	var side := (b - a).cross(Vector3.UP).normalized() * ROAD_W
	# leave the landmark tiles clear so the road runs BETWEEN them
	var dir := (b - a).normalized()
	var p0 := a + dir * 0.42
	var p1 := b - dir * 0.42
	for v in [p0 - side, p0 + side, p1 + side, p0 - side, p1 + side, p1 - side]:
		mesh.surface_add_vertex(v)


func _add_ribbon_mesh(mesh: ImmediateMesh, color: Color) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_field.add_child(mi)


func _hex_x(hex_col: int, hex_row: int) -> float:
	# odd hex rows are offset half a tile — that's what makes it a hex grid
	return (hex_col * 0.5 + (0.25 if absi(hex_row) % 2 == 1 else 0.0)) * HEX_W * 2.0


func _place_tile(name: String, hex_col: int, hex_row: int, spin: float) -> Node3D:
	var scene: PackedScene = load(HEX + name + ".glb")
	if scene == null:
		return null
	var inst: Node3D = scene.instantiate()
	inst.position = Vector3(_hex_x(hex_col, hex_row), 0.0, -hex_row * ROW_STEP)
	inst.rotation.y = spin
	_field.add_child(inst)
	return inst


## A floating gold ring over every location you may step to next.
func _add_marker(pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.16
	torus.outer_radius = 0.26
	mesh.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.35)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.78, 0.3)
	mat.emission_energy_multiplier = 2.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = mat
	mesh.position = pos + Vector3(0, 1.15, 0)
	mesh.set_meta("base_y", mesh.position.y)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_markers.add_child(mesh)


## Two things decide where a label sits. It must clear its OWN landmark, which
## is measured — a Titan's mountain is far taller than a watchtower, so a fixed
## height either buries the short ones or throws the tall ones off the top of the
## screen. And perspective compresses the far rows toward each other, so each row
## gets a little extra lift to pull them apart again.
func _add_label(pos: Vector3, text: String, big: bool, hex_row: int,
		landmark_height: float) -> void:
	var l := Label3D.new()
	l.text = text
	l.font_size = 110 if big else 84
	l.pixel_size = 0.0036
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.outline_size = 26
	l.modulate = Color(1, 0.9, 0.72) if big else Color(0.98, 0.96, 0.92)
	l.outline_modulate = Color(0.08, 0.06, 0.05)
	l.position = pos + Vector3(0, landmark_height + (0.55 if big else 0.42)
		+ hex_row * 0.1, 0)
	_field.add_child(l)


func _frame_camera(row_count: int) -> void:
	var depth := (row_count - 1) * 2.0 * ROW_STEP
	_cam.position = Vector3(0.0, depth * 0.70 + 2.4, depth * 0.50 + 1.9)
	_cam.look_at(Vector3(0.0, 0.0, -depth * 0.55), Vector3.UP)


# --- the hunter you move --------------------------------------------------

func _place_avatar(s: Dictionary, cur_row: int, cur_col: int) -> void:
	if _avatar == null:
		var players: Array = s.get("players", [])
		var id := ""
		if not players.is_empty():
			id = String((players[0] as Dictionary).get("character", "frog"))
		var scene: PackedScene = load(CAST + String(HUNTER_MODEL.get(id, "bunny")) + ".glb")
		if scene == null:
			return
		_avatar = scene.instantiate()
		add_child(_avatar)
		var tall: float = maxf(_height_of(_avatar), 0.001)
		_avatar.scale = Vector3.ONE * (HUNTER_HEIGHT / tall)
	if _walking:
		return
	_avatar.position = _stand_at(cur_row, cur_col) + Vector3(0, 0, 0.3)


## Where the party stands: on the current node, or at the trailhead before the
## run has started (row -1 means nothing has been stepped on yet).
func _stand_at(cur_row: int, cur_col: int) -> Vector3:
	if cur_row < 0:
		return Vector3(0.0, TILE_TOP, ROW_STEP * 1.6)
	var rows: Array = _client.shared.get("map", {}).get("rows", [])
	var act_index := 0
	for r in range(rows.size()):
		if int((rows[r] as Array)[0].get("act", 0)) == _act:
			if r == cur_row:
				break
			act_index += 1
	var row_size: int = (rows[cur_row] as Array).size() if cur_row < rows.size() else 1
	var hex_col: int = (cur_col * 2) - (row_size - 1)
	var hex_row: int = act_index * 2
	return Vector3(_hex_x(hex_col, hex_row), TILE_TOP, -hex_row * ROW_STEP)


## Walk there, THEN commit the choice — arriving is the decision.
func _travel_to(col: int) -> void:
	_walking = true
	for c in _markers.get_children():
		c.visible = false
	var target: Vector3 = (_nodes[col]["pos"] as Vector3) + Vector3(0, 0, 0.3)
	var from: Vector3 = _avatar.position
	var mid := (from + target) * 0.5 + Vector3(0, 0.28, 0)  # a small hop over the road
	_avatar.look_at_from_position(from, target + Vector3(0, 0.001, 0), Vector3.UP)
	_avatar.rotation.y += PI  # the models face +Z
	var dur: float = maxf(from.distance_to(target) / WALK_SPEED, 0.35)
	var tw := create_tween()
	tw.tween_property(_avatar, "position", mid, dur * 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_avatar, "position", target, dur * 0.5).set_trans(Tween.TRANS_SINE)
	tw.finished.connect(func() -> void:
		_walking = false
		Sfx.play("lock")
		_client.pick_node(col))


## Which reachable location the mouse is over: cast the camera ray at the tile
## plane and take the nearest node. No physics bodies needed for a flat field.
func _node_under_mouse(screen: Vector2) -> int:
	var origin := _cam.project_ray_origin(screen)
	var dir := _cam.project_ray_normal(screen)
	if absf(dir.y) < 0.0001:
		return -1
	var t := (TILE_TOP - origin.y) / dir.y
	if t <= 0.0:
		return -1
	var hit := origin + dir * t
	var best := -1
	var best_d := 0.62  # a hex is 1.0 across, so this is "on that tile"
	for col in _nodes:
		var d: float = hit.distance_to(_nodes[col]["pos"] as Vector3)
		if d < best_d:
			best_d = d
			best = int(col)
	return best


## The cast models are all different sizes, so measure rather than assume — in
## the instance's own space, since the meshes sit under transformed parents.
func _height_of(node: Node3D) -> float:
	var top := 0.0
	for m in _mesh_children(node):
		var mi: MeshInstance3D = m
		var local: Transform3D = node.global_transform.affine_inverse() * mi.global_transform
		top = maxf(top, (local * mi.get_aabb()).end.y)
	return top


func _mesh_children(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		out += _mesh_children(c)
	return out
