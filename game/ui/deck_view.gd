## Your whole deck, and one card at a time — the Slay the Spire deck screen.
##
## Nick, 2026-09-01: "a menu similar to in sts II where you can look at your
## whole deck. then select a single card to look at it and what it looks like
## upgraded. Then in that menu we are going to add the ability to rotate the
## card. that way we can use the full effect."
##
## Three screens' worth of job, in one overlay:
##
##   GRID     every card you own, at a size you can actually read
##   DETAIL   one card, most of the screen tall, with a View Upgrades toggle
##   TURN     drag that card and it turns, which is the only place the 3D
##            window on a rare has ever had the room to be looked at properly
##
## The turn is the reason the other two exist. The window effect follows the
## pointer in a fight, but a card in the fan is 162px wide, half-tucked, and
## you are busy — so the parallax reads as a shimmer rather than as depth.
## Here it is one card at four times the size, and you are holding it.
##
## WHERE THE DECK COMES FROM. The private state's `deck`, which is a list of
## face dicts, not Cards. Each entry carries its own `upgrade` — the SAME dict
## shape, built host-side from the real Card's upgraded_copy(), because a client
## cannot work out what a campfire would do to a card it only has a picture of.
class_name DeckView
extends CanvasLayer

## Pixels of horizontal drag per FULL revolution.
##
## Nick: "when you rotate the card, it doesn't really rotate. It just kind of
## goes slightly on an axis. So you should be able to do a three sixty view."
## Right - the first pass clamped to 38 degrees, which is all the rendered
## window sheet actually covers, so the card wobbled and never turned. The card
## now spins the whole way and the WINDOW is simply along for the ride, at
## whatever view its 24 frames can offer, until the card edges out of sight.
const SPIN_SPAN := 620.0
## Never let the card reach a true zero width - a card exactly edge-on vanishes
## for one frame and reads as a flicker rather than as an edge.
const EDGE_ON := 0.015

var _deck: Array = []
var _dim: ColorRect
var _grid_root: Control
var _detail: Control = null
## The one card in the detail pane, its back, the node carrying the scale, and
## the plain Control both sit in.
var _card: CardView = null
var _back: Control = null
var _scaler: Control = null
var _holder: Control = null
var _scale := 1.0
var _toggle: CheckBox = null
## Which deck entry the pane is showing, so the arrows can step through it.
var _entry: Dictionary = {}
var _at := -1
var _upgraded := false
## The card's yaw, in radians. 0 is face-on; PI is showing you its back.
var _angle := 0.0
var _dragging := false
## Pick mode: what to ask, what the confirm button says, and who to tell.
var _prompt := ""
var _action := ""
var _on_pick: Callable = Callable()


## PICK MODE. Pass a prompt, a button label and a callable and the screen stops
## being a browser and becomes the chooser for "remove a card" and "sharpen a
## card" - the two places the campfire and the trader used to put a grid of text
## buttons reading "Tongue Snap  1".
##
## Choosing from names alone was always a bit thin, and for SHARPEN it was
## actively bad: the one question you are being asked is what the card becomes,
## and the answer was not on screen. This screen already draws a card beside its
## upgraded twin, so pointing the campfire at it is less code AND the better
## answer.
##
## `on_pick` receives the card's index in the deck.
static func open(on: Node, deck: Array, prompt: String = "",
		action: String = "", on_pick: Callable = Callable()) -> DeckView:
	var v := DeckView.new()
	v.name = "DeckView"
	v._deck = deck
	v._prompt = prompt
	v._action = action
	v._on_pick = on_pick
	on.add_child(v)
	return v


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_dim = ColorRect.new()
	_dim.color = Color(0.03, 0.03, 0.045, 0.93)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)
	_build_grid()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE:
		# Escape backs out one level, not all the way. Closing the whole screen
		# when you meant to leave one card is the kind of thing you only forgive
		# a menu once.
		if _detail != null:
			_close_detail()
		else:
			queue_free()
		get_viewport().set_input_as_handled()


# --- the grid --------------------------------------------------------------

func _build_grid() -> void:
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 24)
	_dim.add_child(pad)
	_grid_root = pad

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	pad.add_child(col)

	var head := HBoxContainer.new()
	col.add_child(head)
	var title := Label.new()
	title.text = _prompt if _prompt != "" else "Your Deck  —  %d cards" % _deck.size()
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var hint := Label.new()
	hint.text = ("click a card to inspect it   ·   Esc to go back" if _picking()
		else "click a card to inspect it   ·   Esc to close")
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.62, 0.66, 0.60))
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(hint)
	_picking_note(col)
	var shut := Button.new()
	shut.text = "Cancel" if _picking() else "Close"
	shut.custom_minimum_size = Vector2(90, 34)
	shut.pressed.connect(queue_free)
	head.add_child(shut)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)

	var flow := HFlowContainer.new()
	# HFlow rather than a Grid with a computed column count: the window can be
	# any width and a deck any length, and a flow re-wraps itself. A column
	# count computed once is wrong the moment anything resizes.
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 10)
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(flow)

	# Cards at their NATURAL size, not shrunk to fit more in.
	#
	# The first pass scaled them to 0.72 and every card came out with its rules
	# text cut off mid-word: a CardView lays its contents out against its own
	# size, so putting one in a smaller box is not the same as drawing it
	# smaller, and the two disagreed. A deck screen whose whole job is letting
	# you read your cards must not be the place that clips them. Seven fit
	# across at 162px and the rest scrolls, which is the correct trade.
	for entry in _deck:
		var card := CardView.new()
		card.setup(entry as Dictionary, true, false)
		var e: Dictionary = entry
		card.tapped.connect(func() -> void: _open_detail(e))
		card.inspect_requested.connect(func(d: Dictionary) -> void: _open_detail(d))
		flow.add_child(card)


## The back of the card. Deliberately the same for every card of a hunter: a
## back you can tell apart from another back is a marked deck.
##
## Nick said blank white would do. It would, and this is barely more work: the
## same moulding the front wears, a dark field, and the hunter's own colour in a
## simple rune. What it must not be is white - a white rectangle appearing
## mid-spin reads as the card failing to draw, which is exactly the bug report
## this feature would otherwise generate.
func _card_back(entry: Dictionary, size: Vector2) -> Control:
	var root := Control.new()
	root.custom_minimum_size = size
	root.size = size
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var hue: Color = CardView.EDGE.get(String(entry.get("character", "")),
		CardView.EDGE["common"])

	var ground := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.052, 0.062)
	sb.set_corner_radius_all(13)
	ground.add_theme_stylebox_override("panel", sb)
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ground.offset_left = 1.0
	ground.offset_top = 1.0
	ground.offset_right = -1.0
	ground.offset_bottom = -1.0
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ground)

	# Three nested diamonds, dimmest outward. Rotated ColorRects rather than a
	# texture, so a new hunter colour needs no new art.
	for i in range(3):
		var d := ColorRect.new()
		var w: float = size.x * (0.44 - 0.13 * float(i))
		d.color = Color(hue, 0.16 + 0.16 * float(i))
		d.custom_minimum_size = Vector2(w, w)
		d.size = Vector2(w, w)
		d.pivot_offset = Vector2(w, w) * 0.5
		d.rotation = PI * 0.25
		d.position = (size - Vector2(w, w)) * 0.5
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(d)

	var fr := NinePatchRect.new()
	fr.texture = CardView.FRAMES.get(String(entry.get("character", "")),
		CardView.FRAMES["common"])
	fr.patch_margin_left = CardView.FRAME_MARGIN
	fr.patch_margin_right = CardView.FRAME_MARGIN
	fr.patch_margin_top = CardView.FRAME_MARGIN
	fr.patch_margin_bottom = CardView.FRAME_MARGIN
	fr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fr)
	return root


# --- one card, filling the screen -------------------------------------------
#
# Nick sent Slay the Spire's own card view for reference: ONE card, most of the
# screen tall, arrows either side to step through the deck, and a "View
# Upgrades" toggle at the bottom that swaps the card IN PLACE - Strike becomes
# Strike+ and "Deal 6" becomes "Deal 9" with the 9 in green.
#
# That is better than what I built first, which put the card and its upgrade
# side by side at 1.75x. Side by side makes you compare two objects; swapping in
# place makes the DIFFERENCE jump, because everything that did not change stays
# exactly where your eye already was. It also frees the whole screen for one
# card, which is the only size at which turning it is worth doing.


## Open the detail pane on the Nth card. Public so the dev console can say
## `card 3` and so the screenshot harness can photograph a pane that otherwise
## only opens on a click it has no way to perform.
func inspect(i: int) -> bool:
	if i < 0 or i >= _deck.size():
		return false
	_at = i
	_open_detail(_deck[i] as Dictionary)
	return true


func _open_detail(entry: Dictionary) -> void:
	_close_detail()
	_angle = 0.0
	_upgraded = false
	_entry = entry
	_at = _deck.find(entry)

	var d := ColorRect.new()
	d.color = Color(0.02, 0.02, 0.03, 0.90)
	d.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	d.mouse_filter = Control.MOUSE_FILTER_STOP
	d.gui_input.connect(_detail_input)
	add_child(d)
	_detail = d

	# The card sits in a plain full-rect Control and is centred BY HAND rather
	# than by a CenterContainer. A container lays out its children and resets
	# their scale doing it - the bug that made the first "big" card come out
	# hand-sized - and here the scale changes every frame of a spin, so it would
	# fight continuously rather than only once.
	_holder = Control.new()
	_holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.add_child(_holder)

	if _deck.size() > 1:
		d.add_child(_arrow(false))
		d.add_child(_arrow(true))

	var bar := VBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -92.0
	bar.alignment = BoxContainer.ALIGNMENT_END
	bar.add_theme_constant_override("separation", 8)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.add_child(bar)

	var up: Dictionary = entry.get("upgrade", {})
	if not up.is_empty() and not bool(entry.get("upgraded", false)):
		_toggle = CheckBox.new()
		_toggle.text = "View Upgrades"
		_toggle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_toggle.add_theme_font_size_override("font_size", 17)
		_toggle.add_theme_color_override("font_color", Color(0.94, 0.83, 0.45))
		_toggle.add_theme_color_override("font_pressed_color", Color(1.0, 0.90, 0.52))
		_toggle.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.70))
		_toggle.toggled.connect(func(on: bool) -> void:
			_upgraded = on
			_rebuild_card())
		bar.add_child(_toggle)

	if _picking():
		# The confirm lives HERE, and that is the point of routing the campfire
		# through this screen: you commit to sharpening a card while looking at
		# what it becomes, one View Upgrades click away.
		var go := Button.new()
		go.text = _action
		go.custom_minimum_size = Vector2(260, 40)
		go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		go.pressed.connect(func() -> void:
			var idx := int(_entry.get("index", -1))
			if idx >= 0 and _on_pick.is_valid():
				_on_pick.call(idx)
			queue_free())
		bar.add_child(go)

	var hint := Label.new()
	hint.text = "drag to turn the card   ·   arrows for the next card   ·   Esc to go back"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.62, 0.66, 0.60))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(hint)

	_rebuild_card()


## One of the two arrows either side of the card.
func _arrow(forward: bool) -> Control:
	var b := Button.new()
	b.text = "▶" if forward else "◀"
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 40)
	b.add_theme_color_override("font_color", Color(0.90, 0.74, 0.30))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.45))
	b.set_anchors_preset(Control.PRESET_CENTER_RIGHT if forward
		else Control.PRESET_CENTER_LEFT)
	b.offset_top = -37.0
	b.offset_bottom = 37.0
	if forward:
		b.offset_left = -120.0
		b.offset_right = -46.0
	else:
		b.offset_left = 46.0
		b.offset_right = 120.0
	b.pressed.connect(func() -> void: step(1 if forward else -1))
	return b


## Move to another card without closing and reopening the pane.
##
## The toggle is cleared with set_pressed_no_signal, not by assignment: setting
## `button_pressed` fires `toggled`, which rebuilds the card - so the card would
## be built twice on every arrow press, the second time from a stale _entry.
func step(by: int) -> void:
	if _deck.size() < 2:
		return
	_at = wrapi(_at + by, 0, _deck.size())
	_entry = _deck[_at]
	_angle = 0.0
	_upgraded = false
	if _toggle != null and is_instance_valid(_toggle):
		_toggle.set_pressed_no_signal(false)
		var up: Dictionary = _entry.get("upgrade", {})
		_toggle.visible = not up.is_empty() and not bool(_entry.get("upgraded", false))
	_rebuild_card()


## Draw (or redraw) the one card, as big as the screen allows.
##
## Rebuilt rather than mutated when View Upgrades is toggled: a CardView is
## built from a snapshot dict in setup(), and there is no cheaper way to say
## "now be this other card" than to hand it the other dict.
func _rebuild_card() -> void:
	if _holder == null or not is_instance_valid(_holder):
		return
	for n in _holder.get_children():
		n.queue_free()
	var shown: Dictionary = _entry
	if _upgraded:
		var up: Dictionary = _entry.get("upgrade", {})
		if not up.is_empty():
			shown = up

	_card = CardView.new()
	_card.setup(shown, true, false)
	_card.size = _card.custom_minimum_size
	_card.disabled = true
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_back = _card_back(shown, _card.custom_minimum_size)
	_back.visible = false

	# As tall as the screen allows, which is what the reference does - their
	# card is most of the window. Computed rather than a constant so it is right
	# on a phone, in a 720p window and on a big monitor.
	var space: float = float(get_viewport().get_visible_rect().size.y)
	_scale = clampf((space - 170.0) / maxf(_card.custom_minimum_size.y, 1.0), 1.0, 4.2)

	_scaler = Control.new()
	_scaler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scaler.add_child(_card)
	_scaler.add_child(_back)
	_holder.add_child(_scaler)
	_apply_turn()


## Spin the open card to `deg` degrees of yaw. 0 is face-on, 180 is its back.
## For the dev console and the screenshot harness, neither of which can drag.
func spin_to(deg: float) -> void:
	_angle = deg_to_rad(deg)
	_apply_turn()


## Show the upgraded face, or not. Same reason as spin_to: a screenshot cannot
## click a checkbox, and this is the thing the reference screen is FOR.
func show_upgrade(on: bool) -> void:
	_upgraded = on
	if _toggle != null and is_instance_valid(_toggle):
		_toggle.set_pressed_no_signal(on)
	_rebuild_card()


func _detail_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT:
		_dragging = mb.pressed
		# A press and release that never turned the card is a click, and a click
		# on the backdrop goes back. Judged on the card having MOVED rather than
		# on how long the button was held, because a slow careful turn is still
		# a turn.
		if not mb.pressed and is_zero_approx(_angle):
			_close_detail()
		return
	var mm := event as InputEventMouseMotion
	if mm != null and _dragging:
		_angle += mm.relative.x / SPIN_SPAN * TAU
		_apply_turn()


## Point the card at `_angle`, and keep it centred.
##
## THREE things move together, and they are three different mechanisms:
##
##   the WIDTH   scaled by |cos(yaw)|. This IS the rotation: a card seen at an
##               angle is a card that has got narrower, and at 90 degrees it is
##               a line. Nothing else here does any turning.
##   the FACE    past 90 degrees you are behind it, so the front hides and the
##               back shows. Without this the card just gets wide again and you
##               have watched it squash rather than turn - which is exactly what
##               the first version did, and what Nick reported.
##   the WINDOW  turn_override = sin(yaw), which is how far off-axis the viewer
##               is. Real parallax, baked in Blender, riding along for the half
##               of the spin where the front is facing you.
##
## Centred here rather than by a container because the width changes every frame
## of a spin: a container would re-centre a frame late and the card would swim
## sideways as it turned.
func _apply_turn() -> void:
	if _scaler == null or not is_instance_valid(_scaler):
		return
	var facing: float = cos(_angle)
	var front := facing >= 0.0
	var width: float = maxf(absf(facing), EDGE_ON)
	if _card != null and is_instance_valid(_card):
		_card.visible = front
		_card.turn_override = clampf(sin(_angle), -1.0, 1.0)
	if _back != null and is_instance_valid(_back):
		_back.visible = not front
	_scaler.scale = Vector2(_scale * width, _scale)
	var full: Vector2 = _card.custom_minimum_size * _scale
	var mid: Vector2 = _holder.size * 0.5
	_scaler.position = Vector2(mid.x - full.x * width * 0.5, mid.y - full.y * 0.5)


func _close_detail() -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()
	_detail = null
	_holder = null
	_scaler = null
	_card = null
	_back = null
	_toggle = null
	_dragging = false
	_angle = 0.0


func _picking() -> bool:
	return _on_pick.is_valid()


## Nothing extra in the grid header; kept as a seam so a future pick mode can
## warn about something (a removal being permanent, say) without a layout edit.
func _picking_note(_col: Control) -> void:
	pass
