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
## The player asked what this card actually does. A dedicated button rather than a
## hover or a long-press: CLAUDE.md §5 forbids hover-only information (no hover on
## touch), and a hold would fight the timing tap.
signal inspect_requested(data: Dictionary)

## Rail cards size themselves to the column's width; only the height is fixed, and
## it's set by the live-effect line plus two clipped lines of prose and the timing
## strip. The prose is deliberately allowed to run out of room — the numbers are on
## the effect line and the full rules are one tap away in the inspector.
const RAIL_HEIGHT := 88
const RAIL_TEXT_LINES := 2

const ZONE_MIN := 0.40
const ZONE_MAX := 0.60
const SWEEP_SPEED := 1.9    # sweeps per second — quick; timing should demand focus (Nick)
const WINDOW_SECONDS := 2.5 # max time per timing window; expire = the card fizzles (Nick)

var _timing := false
var _t := 0.0
var _dir := 1.0
var _elapsed := 0.0  # time spent in the current window
## Relic bonus widening the success zone on each side (0.06 = +6% each way).
var zone_bonus := 0.0
var _strip: Control
var _marker: ColorRect
var _count_lbl: Label
var _hits_needed := 1  # sequential timing windows to nail (Satchel Charge = 3)
var _hits_done := 0
var _compact := false  # built in the rail form (see setup)

# Kenney "Board Game Icons" (white-fill SVGs → tint via modulate). Keys are the
# effect roles the host maps cards to (see game_host._card_icon).
const ICONS := {
	"sword": preload("res://assets/icons/sword.png"),
	"shield": preload("res://assets/icons/shield.png"),
	"bow": preload("res://assets/icons/bow.png"),
	"fire": preload("res://assets/icons/fire.png"),
	"skull": preload("res://assets/icons/skull.png"),
	"flask": preload("res://assets/icons/flask_full.png"),
	"climb": preload("res://assets/icons/pawn_up.png"),
	"bomb": preload("res://assets/icons/exploding.png"),
	"gadget": preload("res://assets/icons/structure_tower.png"),
	"draw": preload("res://assets/icons/hand_card.png"),
	"expose": preload("res://assets/icons/flag_square.png"),
	"taunt": preload("res://assets/icons/flag_triangle.png"),
	"support": preload("res://assets/icons/hand.png"),
	"relic": preload("res://assets/icons/award.png"),
	"rally": preload("res://assets/icons/campfire.png"),
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
##
## `compact` builds the RAIL form: a short, wide row instead of a portrait card.
## The fight stacks these down the left edge so the 3D scene keeps the screen
## (Nick, 2026-08-06) — a row of portrait cards ate the bottom third, which is
## exactly where the beast you're climbing stands. Everywhere the cards ARE the
## screen (rewards, shop, campfire, character select) keeps the portrait form.
func setup(data: Dictionary, playable: bool = true, compact: bool = false) -> void:
	# Character/relic cards (no cost pip) carry portraits + longer text — taller frame.
	_compact = compact
	if compact:
		custom_minimum_size = Vector2(0, RAIL_HEIGHT)
	else:
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
	var margin := 6 if compact else 10
	for side in ["left", "top", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, margin)
	add_child(pad)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6 if not compact else 3)
	pad.add_child(box)

	if compact:
		box.add_child(_rail_row(data))
	else:
		box.add_child(_header(String(data.get("name", "")), int(data.get("cost", 0)), bool(data.get("no_cost", false))))
		box.add_child(_art(String(data.get("icon", "")), String(data.get("portrait", ""))))
		box.add_child(_body(face_text(data)))

	_strip = _build_timing_strip()  # hidden until start_timing()
	box.add_child(_strip)
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)


## The rail form: [cost] [icon] [name / rules text], one row. Everything a
## portrait card says, laid out sideways — nothing is dropped, because a card you
## can't read is a card you won't play.
func _rail_row(data: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Cost reads as a pip, not a word — it's the number you scan first.
	var cost := _label(str(int(data.get("cost", 0))), 20)
	cost.custom_minimum_size = Vector2(22, 0)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost.add_theme_color_override("font_color", Color(0.95, 0.82, 0.5))
	row.add_child(cost)

	var icon := String(data.get("icon", ""))
	if ICONS.has(icon):
		var tex := TextureRect.new()
		tex.texture = ICONS[icon]
		tex.modulate = TINT.get(icon, Color(0.85, 0.8, 0.7))
		tex.custom_minimum_size = Vector2(30, 30)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tex)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 1)

	var name_lbl := _label(String(data.get("name", "")), 14)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	col.add_child(name_lbl)

	# ONE description, with live numbers in it. Not a readout plus a formula.
	var body := _label(face_text(data), 12)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.max_lines_visible = RAIL_TEXT_LINES
	body.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	body.add_theme_color_override("font_color", Color(0.9, 0.86, 0.76))
	col.add_child(body)

	row.add_child(col)
	row.add_child(_inspect_button(data))
	return row


## A thumb-sized "?" that opens the full rules. The card face carries the numbers;
## this carries the explanation, so neither has to be crammed onto the other.
func _inspect_button(data: Dictionary) -> Control:
	var b := Button.new()
	b.text = "?"
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(26, 26)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.tooltip_text = "What does this do?"
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(0.72, 0.66, 0.56))
	b.add_theme_color_override("font_hover_color", Color(1, 0.88, 0.55))
	b.pressed.connect(func() -> void: inspect_requested.emit(data))
	return b


## The card's ONE description line, written from what it will actually do.
##
## Slay the Spire never prints a formula and a result side by side: a card says
## "Deal 6 damage", and when Strength makes that 9 the NUMBER changes, in place.
## The first pass at this added a live readout ABOVE the authored text, so Brace
## read "5 blk" and then "Gain 5 Block." — the same fact twice, once abbreviated.
## This replaces both: full words, live numbers, one sentence.
##
## The authored `text` still exists and still explains the card's SHAPE ("+3 per
## Rhythm") — it lives in the inspector, where there is room for it.
static func face_text(data: Dictionary) -> String:
	var pv: Dictionary = data.get("preview", {})
	if pv.is_empty():
		return String(data.get("text", ""))
	var miss: Dictionary = data.get("preview_miss", pv)
	var fx: Dictionary = data.get("fx", {})
	var timed := bool(data.get("timed", false))
	var out: PackedStringArray = []

	var dmg := int(pv.get("damage", 0))
	if dmg > 0:
		var n := int(fx.get("hits", 1))
		var times := "" if n <= 1 else (" twice" if n == 2 else " %d times" % n)
		out.append("Deal %s damage%s." % [_pair(int(miss.get("damage", 0)), dmg, timed), times])
	var blk := int(pv.get("block", 0))
	if blk > 0:
		out.append("Gain %s Block." % _pair(int(miss.get("block", 0)), blk, timed))
	var climb := int(pv.get("grip", 0))
	if climb > 0:
		out.append("Climb +%s." % _pair(int(miss.get("grip", 0)), climb, timed))
	var ally_blk := int(pv.get("ally_block", 0))
	if ally_blk > 0:
		out.append("Ally gains %s Block." % _pair(int(miss.get("ally_block", 0)), ally_blk, timed))
	var ally_climb := int(pv.get("ally_grip", 0))
	if ally_climb > 0:
		out.append("Ally climbs +%d." % ally_climb)

	if int(fx.get("wound", 0)) > 0:
		out.append("Poison %d." % int(fx["wound"]))
	if int(fx.get("vulnerable", 0)) > 0:
		out.append("Expose %d." % int(fx["vulnerable"]))
	if int(fx.get("strength", 0)) > 0:
		out.append("+%d Strength." % int(fx["strength"]))
	if int(fx.get("rhythm", 0)) > 0:
		out.append("+%d Rhythm." % int(fx["rhythm"]))
	if int(fx.get("draw", 0)) > 0:
		out.append("Draw %d." % int(fx["draw"]))
	if bool(fx.get("taunt", false)):
		out.append("Taunt.")
	if int(fx.get("pull_ally", 0)) > 0:
		out.append("Pull your ally up to you.")
	if int(fx.get("sac_ally_grip", 0)) > 0:
		out.append("Burn a card: ally climbs +%d." % int(fx["sac_ally_grip"]))
	elif bool(fx.get("exhaust_pick", false)):
		out.append("Burn a card." if not bool(fx.get("cheapen_pick", false))
			else "Burn a card to cheapen another.")
	if String(fx.get("create", "")) != "":
		out.append("Build a tool into your hand.")
	if String(fx.get("prepare", "")) != "":
		out.append("Primed for next turn.")
	if bool(fx.get("meld", false)):
		out.append("Fuse two cards into one.")

	if out.is_empty():
		return String(data.get("text", ""))
	var body := " ".join(out)
	return ("Time it! " + body) if timed else body


## "15" when nailing it changes nothing, "2→5" when it does — so a timed card shows
## what it's worth AND what landing it is worth, without a parenthesis.
static func _pair(low: int, high: int, timed: bool) -> String:
	if timed and high != low:
		return "%d→%d" % [low, high]
	return str(high)


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
	# Fixed, modest art size — the icon is an accent, not the card's focus (Nick).
	# Portraits (character select) keep a larger pane.
	tex.custom_minimum_size = Vector2(0, 76 if portrait != "" else 42)
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
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
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL  # balance the space below the art
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
	_elapsed = 0.0
	_update_count()
	var zone := _strip.get_node_or_null("Zone")
	if zone != null:  # relics may have widened the window since setup()
		(zone as Control).anchor_left = maxf(0.0, ZONE_MIN - zone_bonus)
		(zone as Control).anchor_right = minf(1.0, ZONE_MAX + zone_bonus)
	_strip.modulate = Color(1, 1, 1)
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
	if _t < ZONE_MIN - zone_bonus or _t > ZONE_MAX + zone_bonus:
		_end_timing(false)
		return
	_hits_done += 1
	if _hits_done >= _hits_needed:
		_end_timing(true)
		return
	_t = 0.0  # reset the sweep for the next window
	_dir = 1.0
	_elapsed = 0.0  # a fresh clock per window
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
	_elapsed += delta
	if _elapsed >= WINDOW_SECONDS:  # hesitated too long — the moment is gone
		_end_timing(false)
		return
	_t += _dir * SWEEP_SPEED * delta
	if _t >= 1.0:
		_t = 1.0
		_dir = -1.0
	elif _t <= 0.0:
		_t = 0.0
		_dir = 1.0
	_marker.position.x = _t * (_strip.size.x - _marker.size.x)
	# The strip reddens as the window runs out — see the timeout coming.
	var urgency := _elapsed / WINDOW_SECONDS
	_strip.modulate = Color(1.0, 1.0 - 0.45 * urgency, 1.0 - 0.45 * urgency)


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
	zone.anchor_left = maxf(0.0, ZONE_MIN - zone_bonus)
	zone.anchor_right = minf(1.0, ZONE_MAX + zone_bonus)
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
	# A rail card slides out of the column instead of scaling: it's already as
	# wide as the rail, so growing it would just clip on the screen edge.
	if _compact:
		position.x = 8.0
		return
	pivot_offset = size / 2.0
	scale = Vector2(1.06, 1.06)


func _on_unhover() -> void:
	if _compact:
		position.x = 0.0
		return
	scale = Vector2.ONE


func _frame(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(1)
	sb.border_color = border
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(2)
	return sb
