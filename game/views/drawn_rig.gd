## A drawn beast that moves (Nick, 2026-10-07: "the rest pose and design must
## match his drawing ... and the jackal must be animated").
##
## tools/beast_rig.py cuts the jackal out of TARGET.png into parts and writes
## the scene this runs on: the parts are Sprite2Ds on a Node2D skeleton inside
## the `Rig` SubViewport, posed by the AnimationPlayer's idle/attack/hit/death
## clips, and the viewport is the texture the `Body` billboard draws. The
## arena, the camera and the fight's beast code see one flat Sprite3D, as
## before. The climb_/ledge_ markers ride the part each hold sits on.
class_name DrawnRig
extends Node3D

## World units per rig-canvas pixel, the canvas row of the floor, and the
## canvas column the body is centred on: the map from the 2D rig to this
## node's space (tools/beast_rig.py writes all three).
@export var pixel_size := 0.003
@export var floor_px := 0.0
@export var mid_px := 0.0
## The canvas columns the figure spans at rest. The canvas is wider (the
## swung fist needs room on the left), and the fight must frame the figure,
## not the room it swings in.
@export var figure_x0 := 0.0
@export var figure_x1 := 0.0

var _holds := {}


func _ready() -> void:
	var rig := get_node_or_null("Rig") as SubViewport
	var body := get_node_or_null("Body") as Sprite3D
	if rig == null or body == null:
		return
	# Render the rig at about the size it reaches the screen (2026-10-08,
	# queue "Cracks: wide hot cores"). The parts are cut at 2x TARGET, and a
	# 2x viewport drawn at ~0.4 with no mipmaps skipped texels: the thin
	# crack cores broke up, read thinner and lost their yellow. The canvas
	# keeps its 2x coordinates (size_2d_override), so the poses, the holds
	# and every *_px export are unchanged; only the target shrinks, and the
	# billboard's pixel_size grows by the same factor so the world size holds.
	var down := rig_downsample()
	if down > 1.0:
		var full := rig.size
		rig.size_2d_override = full
		rig.size_2d_override_stretch = true
		rig.size = Vector2i(roundi(full.x / down), roundi(full.y / down))
		# The parts are then drawn shrunk inside the viewport: mipmapped so
		# the 2D pass filters, not skips. Built here, not in the imports
		# (*.import is not in git, so an import setting never ships).
		rig.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		for n in rig.find_children("*", "Sprite2D", true, false):
			_mipmap(n as Sprite2D)
		var k := float(full.x) / float(rig.size.x)
		body.pixel_size *= k
	var tex := rig.get_texture()
	body.texture = tex
	var mat := body.material_override as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("tex", tex)
		mat.set_shader_parameter("premul", true)
		if down > 1.0:
			# halo_px is in texture pixels.
			var hp = mat.get_shader_parameter("halo_px")
			if hp != null:
				mat.set_shader_parameter("halo_px", float(hp) * float(rig.size.x) / float(rig.size_2d_override.x))
	for c in get_children():
		var n := String(c.name)
		if n.begins_with("climb_") or n.begins_with("ledge_"):
			var m := rig.find_child("hold_" + n.substr(6), true, false) as Node2D
			if m != null:
				_holds[c] = m


## Slide the drawing and its holds by `px` canvas pixels (x right, y up),
## so the fight can put the figure where TARGET draws it in the
## square without moving the camera every other part is placed by.
var view_shift := Vector2.ZERO


func shift_view(px: Vector2) -> void:
	var dv := (px - view_shift) * pixel_size
	var d := Vector3(dv.x, dv.y, 0.0)
	view_shift = px
	var body := get_node_or_null("Body") as Node3D
	if body != null:
		body.position += d
	for c in get_children():
		var n := String(c.name)
		if n.begins_with("climb_") or n.begins_with("ledge_"):
			(c as Node3D).position += d


## Give a part's texture mipmaps (a copy; the imported one stays as it is).
static func _mipmap(sp: Sprite2D) -> void:
	if sp.texture == null or sp.texture.has_mipmaps():
		return
	var img := sp.texture.get_image()
	if img == null:
		return
	if img.is_compressed():
		img.decompress()
	img.generate_mipmaps()
	sp.texture = ImageTexture.create_from_image(img)


## How much smaller than its 2x canvas the rig renders: the canvas reaches
## a 720-row screen at 0.35 (TARGET's jackal in the centred square), so
## 1 / 0.35 there, rendering it 1:1 with the screen; less on a taller
## window so the line stays sharp there.
const RIG_SCREEN_SCALE := 0.35
func rig_downsample() -> float:
	var h := 720.0
	if is_inside_tree():
		h = maxf(get_viewport().get_visible_rect().size.y, 1.0)
	return clampf(720.0 / (RIG_SCREEN_SCALE * h), 1.0, 4.0)


## Where a point on the rig canvas sits in this node's space. Static so the
## test can check it against the markers the tool wrote.
static func canvas_to_local(p: Vector2, px: float, floor_row: float, mid_col: float, z := 0.25) -> Vector3:
	return Vector3((p.x - mid_col) * px, (floor_row - p.y) * px, z)


## `box` (the fight's merged, global AABB of this beast) cut to the columns
## the figure spans at rest.
func trim_box(box: AABB) -> AABB:
	if figure_x1 <= figure_x0:
		return box
	var a := global_transform * canvas_to_local(Vector2(figure_x0, 0), pixel_size, floor_px, mid_px, 0.0)
	var b := global_transform * canvas_to_local(Vector2(figure_x1, 0), pixel_size, floor_px, mid_px, 0.0)
	return AABB(Vector3(minf(a.x, b.x), box.position.y, box.position.z),
		Vector3(absf(b.x - a.x), box.size.y, box.size.z))


func _process(_dt: float) -> void:
	for c in _holds:
		var m: Node2D = _holds[c]
		(c as Node3D).position = canvas_to_local(m.global_position, pixel_size, floor_px, mid_px) \
				+ Vector3(view_shift.x, view_shift.y, 0.0) * pixel_size
