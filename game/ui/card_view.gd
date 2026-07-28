## Reusable card widget (CLAUDE.md §5, §8: presentation, single-pointer, scalable).
## The whole card is one tappable Button; its contents are built from a card
## snapshot dict (name/cost/text/target/icon) — no /core types. A silhouette icon
## gives each card an at-a-glance identity (the minimalist Titan-slayer look, and
## a cheap placeholder that can later swap for real art).
class_name CardView
extends Button

## A normal tap (not during timing).
signal tapped
## A timed card's throw resolved: hit = landed in the green zone.
signal timing_resolved(hit: bool)

const ZONE_MIN := 0.40
const ZONE_MAX := 0.60
const SWEEP_SPEED := 1.25  # sweeps per second

var _timing := false
var _t := 0.0
var _dir := 1.0
var _strip: Control
var _marker: ColorRect

const ICONS := {
	"sword": preload("res://ui/icons/sword.svg"),
	"shield": preload("res://ui/icons/shield.svg"),
	"support": preload("res://ui/icons/arrow.svg"),
	"aim": preload("res://ui/icons/aim.svg"),
	"expose": preload("res://ui/icons/sun.svg"),
	"taunt": preload("res://ui/icons/banner.svg"),
	"grip": preload("res://ui/icons/grip.svg"),
	"relic": preload("res://ui/icons/relic.svg"),
}
const ENERGY_ICON := preload("res://ui/icons/energy.svg")

const TINT := {
	"sword": Color(0.82, 0.44, 0.34),   # rust
	"shield": Color(0.56, 0.66, 0.75),  # steel
	"support": Color(0.62, 0.73, 0.51), # moss
	"aim": Color(0.85, 0.78, 0.55),     # gold
	"expose": Color(0.90, 0.78, 0.42),  # sunlight
	"taunt": Color(0.82, 0.56, 0.40),   # ember
	"grip": Color(0.70, 0.62, 0.46),    # stone/earth
	"relic": Color(0.78, 0.66, 0.86),   # arcane violet
}

## Build the card from a snapshot dict. `playable` greys it out when false.
func setup(data: Dictionary, playable: bool = true) -> void:
	custom_minimum_size = Vector2(156, 210)  # thumb-friendly (§5)
	disabled = not playable
	text = ""
	if not mouse_entered.is_connected(_on_hover):
		mouse_entered.connect(_on_hover)
		mouse_exited.connect(_on_unhover)
	_apply_frame()
	for child in get_children():
		child.queue_free()

	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 10)
	add_child(pad)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	pad.add_child(box)

	box.add_child(_header(String(data.get("name", "")), int(data.get("cost", 0)), bool(data.get("no_cost", false))))
	box.add_child(_art(String(data.get("icon", ""))))
	box.add_child(_body(String(data.get("text", ""))))
	var tgt := String(data.get("target", "self"))
	if tgt == "ally" or tgt == "enemy":
		box.add_child(_tag("→ ally" if tgt == "ally" else "→ Titan"))

	_strip = _build_timing_strip()  # hidden until start_timing()
	box.add_child(_strip)
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)


func _header(card_name: String, cost: int, no_cost: bool = false) -> Control:
	if no_cost:  # relics have no energy cost — just a centered name
		var name_only := _label(card_name, 15)
		name_only.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_only.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		return name_only

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)

	var e := TextureRect.new()
	e.texture = ENERGY_ICON
	e.custom_minimum_size = Vector2(16, 16)
	e.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	e.modulate = Color(0.86, 0.72, 0.4)
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(e)

	var cost_lbl := _label(str(cost), 16)
	row.add_child(cost_lbl)

	var name_lbl := _label(card_name, 15)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(name_lbl)
	return row


func _art(icon: String) -> Control:
	var tex := TextureRect.new()
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.custom_minimum_size = Vector2(0, 56)
	tex.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ICONS.has(icon):
		tex.texture = ICONS[icon]
		tex.modulate = TINT.get(icon, Color(0.85, 0.8, 0.7))
	return tex


func _body(text_str: String) -> Control:
	var l := _label(text_str, 13)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _tag(text_str: String) -> Control:
	var l := _label(text_str, 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.modulate = Color(0.72, 0.67, 0.55)
	return l


func _label(text_str: String, size: int) -> Label:
	var l := Label.new()
	l.text = text_str
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	return l


func _apply_frame() -> void:
	add_theme_stylebox_override("normal", _frame(Color(0.152, 0.132, 0.104), Color(0.42, 0.36, 0.25)))
	add_theme_stylebox_override("hover", _frame(Color(0.2, 0.17, 0.13), Color(0.66, 0.54, 0.34)))
	add_theme_stylebox_override("pressed", _frame(Color(0.13, 0.112, 0.088), Color(0.5, 0.42, 0.28)))
	add_theme_stylebox_override("disabled", _frame(Color(0.115, 0.105, 0.092), Color(0.26, 0.23, 0.18)))


## Mark this card as the current (not yet locked) reward selection.
func set_selected(on: bool) -> void:
	if not on:
		return
	var gold := _frame(Color(0.24, 0.20, 0.13), Color(0.90, 0.74, 0.42))
	add_theme_stylebox_override("normal", gold)
	add_theme_stylebox_override("hover", gold)
	add_theme_stylebox_override("pressed", gold)


# --- Timing minigame (on the card) ----------------------------------------

## Begin the timing sweep. The next tap on this card fires it.
func start_timing() -> void:
	if _timing:
		return
	_timing = true
	_t = 0.0
	_dir = 1.0
	# The green zone is anchored (see _build_timing_strip), so it sizes itself once
	# the strip is laid out — no need to compute a width here (which was 0 while the
	# strip was still hidden, making the target invisible).
	_strip.visible = true
	set_process(true)


func _on_self_pressed() -> void:
	if _timing:
		_fire()
	else:
		tapped.emit()


func _fire() -> void:
	_timing = false
	set_process(false)
	_strip.visible = false
	timing_resolved.emit(_t >= ZONE_MIN and _t <= ZONE_MAX)


func _process(delta: float) -> void:
	if not _timing:
		return
	_t += _dir * SWEEP_SPEED * delta
	if _t >= 1.0:
		_t = 1.0
		_dir = -1.0
	elif _t <= 0.0:
		_t = 0.0
		_dir = 1.0
	_marker.position.x = _t * (_strip.size.x - _marker.size.x)


func _build_timing_strip() -> Control:
	var strip := Control.new()
	strip.custom_minimum_size = Vector2(0, 20)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.045)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(bg)
	# Success zone: anchored to ZONE_MIN..ZONE_MAX of the strip so it always spans
	# the target band, whatever the strip's laid-out width is. A brighter "perfect"
	# core in the centre makes the aim point obvious.
	var zone := ColorRect.new()
	zone.name = "Zone"
	zone.color = Color(0.33, 0.72, 0.36)
	zone.anchor_left = ZONE_MIN
	zone.anchor_right = ZONE_MAX
	zone.anchor_top = 0.0
	zone.anchor_bottom = 1.0
	zone.offset_left = 0.0
	zone.offset_right = 0.0
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(zone)
	var core := ColorRect.new()  # the bullseye — centre of the green band
	core.color = Color(0.55, 0.95, 0.55)
	core.anchor_left = 0.47
	core.anchor_right = 0.53
	core.anchor_top = 0.0
	core.anchor_bottom = 1.0
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(core)
	_marker = ColorRect.new()
	_marker.color = Color(1.0, 0.96, 0.82)
	_marker.size = Vector2(5, 20)
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(_marker)
	return strip


func _on_hover() -> void:
	# Optional accelerator only — cards remain fully usable by tap (§5).
	pivot_offset = size / 2.0
	scale = Vector2(1.06, 1.06)


func _on_unhover() -> void:
	scale = Vector2.ONE


func _frame(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(1)
	sb.border_color = border
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(2)
	return sb
