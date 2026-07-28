## Timing minigame for "timed" cards (the Goblin Engineer's grapple). A marker
## sweeps a track; the player taps FIRE — landing in the green zone is a hit
## (the card gets its timed bonus). Emits `resolved(hit)` then frees itself.
## Single-pointer friendly (§5): the whole interaction is one FIRE tap.
class_name TimingBar
extends Control

signal resolved(hit: bool)

const ZONE_MIN := 0.40   # green zone start (fraction of the track)
const ZONE_MAX := 0.60
const SPEED := 1.25      # sweeps per second
const TRACK_W := 520.0

var _t := 0.0
var _dir := 1.0
var _marker: ColorRect
var _done := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)

	var title := Label.new()
	title.text = "Fire the grapple — tap FIRE in the green zone!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var track := Control.new()
	track.custom_minimum_size = Vector2(TRACK_W, 44)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(track)

	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.09, 0.07)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track.add_child(bg)

	var zone := ColorRect.new()
	zone.color = Color(0.35, 0.62, 0.32, 0.9)
	zone.position = Vector2(TRACK_W * ZONE_MIN, 0)
	zone.size = Vector2(TRACK_W * (ZONE_MAX - ZONE_MIN), 44)
	track.add_child(zone)

	_marker = ColorRect.new()
	_marker.color = Color(0.96, 0.9, 0.75)
	_marker.size = Vector2(5, 44)
	track.add_child(_marker)

	var fire := Button.new()
	fire.text = "FIRE"
	fire.custom_minimum_size = Vector2(200, 48)
	fire.pressed.connect(_on_fire)
	box.add_child(fire)

	set_process(true)


func _process(delta: float) -> void:
	if _done:
		return
	_t += _dir * SPEED * delta
	if _t >= 1.0:
		_t = 1.0
		_dir = -1.0
	elif _t <= 0.0:
		_t = 0.0
		_dir = 1.0
	_marker.position.x = _t * (TRACK_W - _marker.size.x)


func _on_fire() -> void:
	if _done:
		return
	_done = true
	set_process(false)
	var hit := _t >= ZONE_MIN and _t <= ZONE_MAX
	resolved.emit(hit)
	queue_free()
