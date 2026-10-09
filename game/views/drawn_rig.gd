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
		mat.set_shader_parameter("sharpen", RIG_SHARPEN)
		mat.set_shader_parameter("footprint", RIG_SUPERSAMPLE > 1.0)
		mat.set_shader_parameter("footprint_lanczos", RIG_LANCZOS)
		mat.set_shader_parameter("screen_sharpen", RIG_SCREEN_SHARPEN)
		mat.set_shader_parameter("screen_sharpen_px", RIG_SCREEN_SHARPEN_PX)
		mat.set_shader_parameter("crack_grow", RIG_CRACK_GROW)
		mat.set_shader_parameter("crack_heat", RIG_CRACK_HEAT)
		mat.set_shader_parameter("crack_orange", RIG_CRACK_ORANGE)
		mat.set_shader_parameter("hot_glow", RIG_HOT_GLOW)
		# The crack radii are in texture pixels; the viewport is supersampled.
		mat.set_shader_parameter("crack_px", RIG_CRACK_PX * RIG_SUPERSAMPLE)
		mat.set_shader_parameter("hot_glow_px", RIG_HOT_GLOW_PX * RIG_SUPERSAMPLE)
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
	if FIRE_OVERLAY and rig.find_child("fire", true, false) != null:
		_make_fire_overlay(tex)


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


## Grow the drawing by `z` about the rig-canvas point `pivot` (x right, y
## down, canvas pixels), holds untouched: the fight's height fit lands the
## figure a hair small of TARGET (2026-10-09, registered on the square:
## 0.5% under, ~2 px at the fist and the right forearm, every line and crack
## doubled against TARGET's), and a zoom about the chest closes it without
## moving the slabs registered on it.
var view_zoom := 1.0


func zoom_view(z: float, pivot: Vector2) -> void:
	var body := get_node_or_null("Body") as Sprite3D
	if body == null or is_equal_approx(z, view_zoom):
		return
	var tex_w := float(body.texture.get_width()) if body.texture != null else 0.0
	var canvas_w := tex_w
	var rig := get_node_or_null("Rig") as SubViewport
	if rig != null and rig.size_2d_override.x > 0:
		canvas_w = float(rig.size_2d_override.x)
	var ps := body.pixel_size * (tex_w / canvas_w if canvas_w > 0.0 else 1.0)   # world per canvas px
	var size := Vector2(canvas_w, float(rig.size_2d_override.y if rig != null and rig.size_2d_override.y > 0 else body.texture.get_height()))
	var off := (pivot - size * 0.5) * ps
	var f := z / view_zoom
	body.pixel_size *= f
	# keep the pivot where it was: the body's centre moves away from it
	body.position -= Vector3(off.x, -off.y, 0.0) * view_zoom * (f - 1.0)
	view_zoom = z


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
## How many rig pixels per screen pixel: the viewport renders this much
## above screen size and the billboard box-filters each pixel's footprint
## (drawn_sprite.gdshader `footprint`), so the parts reach the screen as
## one clean downsample of TARGET's pixels, not two soft resamples.
const RIG_SUPERSAMPLE := 2.857
## The billboard's unsharp mask (drawn_sprite.gdshader `sharpen`). Off since
## the footprint filter: at 2.2 it rang round every crack (an orange rim on
## both sides of a dark middle, 2026-10-08 run 3).
const RIG_SHARPEN := 0.0
## Unsharp mask after the footprint filter, at screen-pixel reach (see
## drawn_sprite.gdshader screen_sharpen): the box footprint is softer than
## TARGET's own resample.
const RIG_SCREEN_SHARPEN := 0.0
## The footprint as a Lanczos-2 kernel, not a box (drawn_sprite.gdshader
## footprint_lanczos): TARGET's square is a Lanczos resample.
const RIG_LANCZOS := true
const RIG_SCREEN_SHARPEN_PX := 1.0
## TARGET's cracks are wide channels with yellow cores; the shader grows
## each crack over the plate next to it and heats its brightest pixels.
## Off since 2026-10-09: its 16 taps stippled the channels, and with the
## fight's bloom off TARGET's own pixels match; tools/beast_rig.py's
## crack_glow adds the soft spill instead.
const RIG_CRACK_GROW := 0.0
const RIG_CRACK_HEAT := 1.0
const RIG_CRACK_ORANGE := 0.0
const RIG_HOT_GLOW := 0.6
## Their reach, in screen pixels.
const RIG_CRACK_PX := 1.5
const RIG_HOT_GLOW_PX := 5.0
func rig_downsample() -> float:
	var h := 720.0
	if is_inside_tree():
		h = maxf(get_viewport().get_visible_rect().size.y, 1.0)
	return clampf(720.0 / (RIG_SCREEN_SCALE * h * RIG_SUPERSAMPLE), 1.0, 4.0)


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


## The fist's flame drawn in 2D over the fight, past the tonemapper (see
## assets/3d/drawn_fire_overlay.gdshader): ACES could not show TARGET's
## lemon flame core through the billboard's LUT (builder 2026-10-09, queue
## "Fist fire", graders R1-R13: "core paler, cream near the knuckles").
## Under the HUD's layer, so cards and panels stay on top.
const FIRE_OVERLAY := true
const FIRE_OVERLAY_LAYER := 0
var _fire_layer: CanvasLayer
var _fire_rect: ColorRect


func _make_fire_overlay(tex: Texture2D) -> void:
	_fire_layer = CanvasLayer.new()
	_fire_layer.name = "FireOverlay"
	_fire_layer.layer = FIRE_OVERLAY_LAYER
	_fire_rect = ColorRect.new()
	_fire_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fire_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/3d/drawn_fire_overlay.gdshader")
	mat.set_shader_parameter("rig_tex", tex)
	_fire_rect.material = mat
	_fire_layer.add_child(_fire_rect)
	add_child(_fire_layer)


## Map screen UV to the billboard's UV: the homography through its four
## projected corners (the quad under a pitched camera is a keystone).
func _update_fire_overlay() -> void:
	if _fire_rect == null:
		return
	var body := get_node_or_null("Body") as Sprite3D
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	var show := body != null and cam != null and body.is_visible_in_tree() and body.texture != null
	_fire_layer.visible = show
	if not show:
		return
	var vp := get_viewport().get_visible_rect().size
	var w := float(body.texture.get_width()) * body.pixel_size
	var h := float(body.texture.get_height()) * body.pixel_size
	# The billboard's shader has no vertex billboarding: the quad lies in the
	# Body's own XY plane, centred on its offset.
	var off := body.offset * body.pixel_size
	var src: Array[Vector2] = []
	for k in [Vector2(-0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.5, -0.5), Vector2(-0.5, -0.5)]:
		var wp: Vector3 = body.global_transform * Vector3(off.x + k.x * w, off.y + k.y * h, 0.0)
		if cam.is_position_behind(wp):
			_fire_layer.visible = false
			return
		src.append(cam.unproject_position(wp) / vp)
	var dst: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	var hm := homography(src, dst)
	if hm.is_empty():
		_fire_layer.visible = false
		return
	var mat := _fire_rect.material as ShaderMaterial
	# mat3 columns: GLSL mat3 * vec3 with column-major Basis rows as columns.
	mat.set_shader_parameter("screen_to_uv", Basis(Vector3(hm[0], hm[3], hm[6]), Vector3(hm[1], hm[4], hm[7]), Vector3(hm[2], hm[5], hm[8])))
	var a := body.modulate.a
	mat.set_shader_parameter("strength", a)


## The 3x3 homography (row-major, h[8] = 1) taking four points to four
## points; empty if they are degenerate. Static so a test can check it.
static func homography(src: Array[Vector2], dst: Array[Vector2]) -> PackedFloat64Array:
	var m := []
	for i in 4:
		var x := src[i].x
		var y := src[i].y
		var u := dst[i].x
		var v := dst[i].y
		m.append([x, y, 1.0, 0.0, 0.0, 0.0, -u * x, -u * y, u])
		m.append([0.0, 0.0, 0.0, x, y, 1.0, -v * x, -v * y, v])
	for col in 8:
		var piv := col
		for r in range(col + 1, 8):
			if absf(m[r][col]) > absf(m[piv][col]):
				piv = r
		if absf(m[piv][col]) < 1e-12:
			return PackedFloat64Array()
		var tmp = m[col]
		m[col] = m[piv]
		m[piv] = tmp
		for r in 8:
			if r == col:
				continue
			var f: float = m[r][col] / m[col][col]
			for c2 in range(col, 9):
				m[r][c2] -= f * m[col][c2]
	var out := PackedFloat64Array()
	for i in 8:
		out.append(m[i][8] / m[i][i])
	out.append(1.0)
	return out


## Turn the drawing to face the camera square on, every frame. Its shader
## does no billboarding, so the quad stood upright under the fight's pitched
## camera and drew TARGET keystoned: registered against TARGET, the raised
## fist sat ~1.7 px right and 1 px down, the head 0.8 px high (builder
## 2026-10-09 run 15; graders' "fist ~1 px right/down" since run 9). Square
## on, with DRAWN_ZOOM 1.008, every part lands within ~0.2 px of TARGET.
const FACE_CAMERA := true


func _process(_dt: float) -> void:
	if FACE_CAMERA:
		var body := get_node_or_null("Body") as Node3D
		var cam := get_viewport().get_camera_3d()
		if body != null and cam != null:
			var gb := cam.global_transform.basis.orthonormalized()
			var sc := body.global_transform.basis.get_scale()
			body.global_transform = Transform3D(gb.scaled(sc), body.global_transform.origin)
	_update_fire_overlay()
	for c in _holds:
		var m: Node2D = _holds[c]
		(c as Node3D).position = canvas_to_local(m.global_position, pixel_size, floor_px, mid_px) \
				+ Vector3(view_shift.x, view_shift.y, 0.0) * pixel_size
