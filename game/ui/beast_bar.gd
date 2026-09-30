extends Control
## The beast's health bar, reacting (queue, "The beast's health bar reacts").
##
## Drawn over the plain ProgressBar it is parented to, full rect, clicks pass
## through. Three things the bar alone never said:
##   notches  - one every `weak_point_threshold` of HP down from full (a full
##              sigil visit's worth of damage), and a taller ember one where the
##              beast turns to its hurt pattern (`hurt_pct`).
##   ghost    - after a blow, the lost HP stays as a pale segment behind the new
##              value for GHOST_HOLD s, then drains down to it over GHOST_DRAIN s.
##   crack    - a blow that crosses a notch flashes a white crack at that notch.
## Presentation only: the numbers come from the snapshot, the clock is its own.

const GHOST_HOLD := 0.4
const GHOST_DRAIN := 0.35
const CRACK_TIME := 0.5
const GHOST_COLOR := Color(1.0, 0.93, 0.8, 0.8)
const NOTCH_COLOR := Color(0.05, 0.03, 0.02, 0.9)
const HURT_COLOR := Color(1.0, 0.45, 0.12, 1.0)

var hp := 0
var max_hp := 1
var ghost_from := 0      # HP the ghost segment starts at (0 = no ghost)
var t := 0.0             # seconds since the last blow landed
var crack_hp := -1       # the notch the last blow crossed (-1 = none)
var notches: Array = []  # [{hp, major}], from notch_marks()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## HP values to notch: every `threshold` down from full while above zero, and
## the hurt-pattern line (`major`). A threshold notch within 1 HP of the hurt
## line is dropped for it. Empty for a beast with neither.
static func notch_marks(max_hp_: int, threshold: int, hurt_pct: float) -> Array:
	var out: Array = []
	var hurt := int(floor(max_hp_ * hurt_pct)) if hurt_pct > 0.0 else -100
	if threshold > 0:
		var v := max_hp_ - threshold
		while v > 0:
			if absi(v - hurt) > 1:
				out.append({"hp": v, "major": false})
			v -= threshold
	if hurt > 0 and hurt < max_hp_:
		out.append({"hp": hurt, "major": true})
	out.sort_custom(func(a, b): return int(a["hp"]) > int(b["hp"]))
	return out


## The highest notch a drop from `old_hp` to `new_hp` crossed, or -1.
static func crossed_notch(old_hp: int, new_hp: int, marks: Array) -> int:
	for m in marks:
		var v := int(m["hp"])
		if new_hp <= v and v < old_hp:
			return v
	return -1


## Where the ghost's top edge is, `since` s after a blow from `from_hp` to `to_hp`:
## held at `from_hp` for GHOST_HOLD, then eased down to `to_hp` over GHOST_DRAIN.
static func ghost_value(from_hp: float, to_hp: float, since: float) -> float:
	if from_hp <= to_hp or since <= GHOST_HOLD:
		return maxf(from_hp, to_hp)
	var k := clampf((since - GHOST_HOLD) / GHOST_DRAIN, 0.0, 1.0)
	return lerpf(from_hp, to_hp, 1.0 - pow(1.0 - k, 2.0))


func set_marks(max_hp_: int, threshold: int, hurt_pct: float) -> void:
	notches = notch_marks(max_hp_, threshold, hurt_pct)
	queue_redraw()


## A new value from the snapshot. A drop starts (or extends) the ghost; a heal
## or a new fight clears it.
func set_hp(new_hp: int, new_max: int) -> void:
	if new_max != max_hp or new_hp > hp:
		ghost_from = 0
		crack_hp = -1
	elif new_hp < hp:
		# A second blow inside the ghost keeps the ghost's current top.
		var top := hp if ghost_from <= 0 else int(ceil(ghost_value(ghost_from, hp, t)))
		ghost_from = maxi(top, hp)
		var c := crossed_notch(hp, new_hp, notches)
		if c >= 0:
			crack_hp = c
		t = 0.0
	hp = new_hp
	max_hp = maxi(new_max, 1)
	queue_redraw()


func _process(delta: float) -> void:
	if ghost_from <= 0 and crack_hp < 0:
		return
	t += delta
	if t > GHOST_HOLD + GHOST_DRAIN:
		ghost_from = 0
	if t > CRACK_TIME:
		crack_hp = -1
	queue_redraw()


func _x(v: float) -> float:
	return size.x * clampf(v / float(max_hp), 0.0, 1.0)


func _draw() -> void:
	if ghost_from > hp:
		var top := ghost_value(ghost_from, hp, t)
		draw_rect(Rect2(_x(hp), 1.0, _x(top) - _x(hp), size.y - 2.0), GHOST_COLOR)
	for m in notches:
		var x := roundf(_x(int(m["hp"])))
		if bool(m["major"]):
			draw_rect(Rect2(x - 1.5, -3.0, 3.0, size.y + 6.0), NOTCH_COLOR)
			draw_rect(Rect2(x - 0.5, -3.0, 1.0, size.y + 6.0), HURT_COLOR)
		else:
			draw_rect(Rect2(x - 1.0, 0.0, 2.0, size.y), NOTCH_COLOR)
	if crack_hp >= 0 and t <= CRACK_TIME:
		var a := 1.0 - t / CRACK_TIME
		var x := _x(crack_hp)
		var h := size.y
		var col := Color(1, 1, 1, a)
		var pts := PackedVector2Array([Vector2(x, -4), Vector2(x - 3, h * 0.3),
			Vector2(x + 3, h * 0.55), Vector2(x - 2, h * 0.8), Vector2(x + 1, h + 4)])
		draw_polyline(pts, col, 2.0, true)
		draw_line(Vector2(x - 3, h * 0.3), Vector2(x - 8, h * 0.15), col, 1.5, true)
		draw_line(Vector2(x + 3, h * 0.55), Vector2(x + 9, h * 0.7), col, 1.5, true)
		draw_rect(Rect2(x - 6, 0, 12, h), Color(1, 0.95, 0.8, 0.5 * a))
