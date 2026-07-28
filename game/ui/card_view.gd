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
var _count_lbl: Label
var _hits_needed := 1  # sequential timing windows to nail (Satchel Charge = 3)
var _hits_done := 0

# Kenney "Board Game Icons" (white-fill SVGs → tint via modulate). Keys are the
# effect roles the host maps cards to (see game_host._card_icon).
const ICONS := {
	"sword": preload("res://assets/icons/sword.svg"),
	"shield": preload("res://assets/icons/shield.svg"),
	"bow": preload("res://assets/icons/bow.svg"),
	"fire": preload("res://assets/icons/fire.svg"),
	"skull": preload("res://assets/icons/skull.svg"),
	"flask": preload("res://assets/icons/flask_full.svg"),
	"climb": preload("res://assets/icons/pawn_up.svg"),
	"bomb": preload("res://assets/icons/exploding.svg"),
	"gadget": preload("res://assets/icons/structure_tower.svg"),
	"draw": preload("res://assets/icons/hand_card.svg"),
	"expose": preload("res://assets/icons/flag_square.svg"),
	"taunt": preload("res://assets/icons/flag_triangle.svg"),
	"support": preload("res://assets/icons/hand.svg"),
	"relic": preload("res://assets/icons/award.svg"),
	"rally": preload("res://assets/icons/campfire.svg"),
}
const ENERGY_ICON := preload("res://ui/icons/energy.svg")

const TINT := {
	"sword": Color(0.82, 0.44, 0.34),   # rust
	"shield": Color(0.56, 0.66, 0.75),  # steel
	"bow": Color(0.85, 0.78, 0.55),     # gold
	"fire": Color(0.90, 0.55, 0.35),    # ember
	"skull": Color(0.62, 0.80, 0.52),   # sickly green (poison/wound)
	"flask": Color(0.80, 0.68, 0.88),   # potion violet
	"climb": Color(0.72, 0.63, 0.46),   # stone/earth
	"bomb": Color(0.90, 0.50, 0.40),    # blast red
	"gadget": Color(0.74, 0.62, 0.44),  # bronze/build
	"draw": Color(0.85, 0.78, 0.55),    # gold
	"expose": Color(0.90, 0.78, 0.42),  # sunlight
	"taunt": Color(0.82, 0.56, 0.40),   # ember
	"support": Color(0.62, 0.73, 0.51), # moss
	"relic": Color(0.78, 0.66, 0.86),   # arcane violet
	"rally": Color(0.90, 0.62, 0.35),   # firelight
}

## Build the card from a snapshot dict. `playable` greys it out when false.
func setup(data: Dictionary, playable: bool = true) -> void:
	# Character/relic cards (no cost pip) carry portraits + longer text — taller frame.
	custom_minimum_size = Vector2(176, 264) if bool(data.get("no_cost", false)) else Vector2(164, 224)
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
	box.add_child(_art(String(data.get("icon", "")), String(data.get("portrait", ""))))
	box.add_child(_body(String(data.get("text", ""))))
	if String(data.get("target", "self")) == "ally":
		box.add_child(_tag("→ helps your ally"))  # enemy-targeting is the default; only flag ally cards

	_strip = _build_timing_strip()  # hidden until start_timing()
	box.add_child(_strip)
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)


func _header(card_name: String, cost: int, no_cost: bool = false) -> Control:
	if no_cost:  # relics have no energy cost — just a centered name
		var name_only := _label(card_name, 14)
		name_only.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_only.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_only.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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

	var name_lbl := _label(card_name, 14)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS  # long names never overflow
	row.add_child(name_lbl)
	return row


func _art(icon: String, portrait: String = "") -> Control:
	var tex := TextureRect.new()
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.custom_minimum_size = Vector2(0, 56)
	tex.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # a big PNG must not force the card taller
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if portrait != "" and ResourceLoader.exists(portrait):
		tex.texture = load(portrait)  # character portrait, full colour
	elif ICONS.has(icon):
		tex.texture = ICONS[icon]
		tex.modulate = TINT.get(icon, Color(0.85, 0.8, 0.7))
	return tex


func _body(text_str: String) -> Control:
	var l := _label(text_str, 12)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_SHRINK_END  # sit low; never push past the frame
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


const FRAME_NORMAL := preload("res://assets/ui/card_normal.png")
const FRAME_HOVER := preload("res://assets/ui/card_hover.png")
const FRAME_PRESSED := preload("res://assets/ui/card_pressed.png")
const FRAME_DISABLED := preload("res://assets/ui/card_disabled.png")
const FRAME_GOLD := preload("res://assets/ui/card_gold.png")


func _apply_frame() -> void:
	add_theme_stylebox_override("normal", _tex_frame(FRAME_NORMAL))
	add_theme_stylebox_override("hover", _tex_frame(FRAME_HOVER))
	add_theme_stylebox_override("pressed", _tex_frame(FRAME_PRESSED))
	add_theme_stylebox_override("disabled", _tex_frame(FRAME_DISABLED))


## Ornate 9-slice card frame (baked from Kenney Fantasy UI Borders).
func _tex_frame(tex: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.set_texture_margin_all(14)  # keep the corner ornaments un-stretched
	sb.set_content_margin_all(8)
	return sb


## Mark this card as the current (not yet locked) reward selection.
func set_selected(on: bool) -> void:
	if not on:
		return
	var gold := _tex_frame(FRAME_GOLD)
	add_theme_stylebox_override("normal", gold)
	add_theme_stylebox_override("hover", gold)
	add_theme_stylebox_override("pressed", gold)


# --- Timing minigame (on the card) ----------------------------------------

## Begin the timing sweep. `hits` sequential windows must all land (Satchel = 3);
## the next tap fires each one. The green zone is anchored (see _build_timing_strip)
## so it sizes itself once the strip is laid out.
func start_timing(hits: int = 1) -> void:
	if _timing:
		return
	_timing = true
	_hits_needed = maxi(1, hits)
	_hits_done = 0
	_t = 0.0
	_dir = 1.0
	_update_count()
	_strip.visible = true
	set_process(true)


func _on_self_pressed() -> void:
	if _timing:
		_fire()
	else:
		tapped.emit()


## One tap during timing. A miss ends the whole chain (fizzle); a hit either
## advances to the next window or, on the last one, resolves as a success.
func _fire() -> void:
	if _t < ZONE_MIN or _t > ZONE_MAX:
		_end_timing(false)
		return
	_hits_done += 1
	if _hits_done >= _hits_needed:
		_end_timing(true)
		return
	_t = 0.0  # reset the sweep for the next window
	_dir = 1.0
	_update_count()


func _end_timing(success: bool) -> void:
	_timing = false
	set_process(false)
	_strip.visible = false
	timing_resolved.emit(success)


func _update_count() -> void:
	if _count_lbl == null:
		return
	if _hits_needed > 1:
		_count_lbl.visible = true
		_count_lbl.text = "%d/%d" % [_hits_done, _hits_needed]
	else:
		_count_lbl.visible = false


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
	# Chain counter (only shown for multi-window cards like Satchel), pinned left.
	_count_lbl = Label.new()
	_count_lbl.add_theme_font_size_override("font_size", 12)
	_count_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	_count_lbl.anchor_top = 0.0
	_count_lbl.anchor_bottom = 1.0
	_count_lbl.offset_left = 4.0
	_count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_lbl.visible = false
	strip.add_child(_count_lbl)
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
