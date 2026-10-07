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
	var tex := rig.get_texture()
	body.texture = tex
	var mat := body.material_override as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("tex", tex)
		mat.set_shader_parameter("premul", true)
	for c in get_children():
		var n := String(c.name)
		if n.begins_with("climb_") or n.begins_with("ledge_"):
			var m := rig.find_child("hold_" + n.substr(6), true, false) as Node2D
			if m != null:
				_holds[c] = m


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
		(c as Node3D).position = canvas_to_local(m.global_position, pixel_size, floor_px, mid_px)
