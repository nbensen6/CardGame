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
##   DETAIL   one card, big, beside what a campfire would turn it into
##   TURN     drag that card and it turns, which is the only place the 3D
##            window on a rare has ever had the room to be looked at properly
##
## The turn is the reason the other two exist. The window effect follows the
## pointer in a fight, but a card in the fan is 162px wide, half-tucked, and
## you are busy — so the parallax reads as a shimmer rather than as depth.
## Here it is one card, four times the size, and you are holding it.
##
## WHERE THE DECK COMES FROM. The private state's `deck`, which is a list of
## face dicts, not Cards. Each entry carries its own `upgrade` — the SAME dict
## shape, built host-side from the real Card's upgraded_copy(), because a client
## cannot work out what a campfire would do to a card it only has a picture of.
class_name DeckView
extends CanvasLayer

## How much bigger a card is in the detail pane than in a hand.
const BIG := 1.75
## Drag this far across the screen to turn the card from edge to edge.
const DRAG_SPAN := 420.0

var _deck: Array = []
var _dim: ColorRect
var _grid_root: Control
var _detail: Control = null
## The two cards in the detail pane, so a drag can turn both at once.
var _turning: Array[CardView] = []
var _turn := 0.0
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


## One card at `s` times its natural size.
##
## THREE nodes, and each one is load-bearing:
##
##   sizer    plain Control the container lays out. Carries the scaled-up
##            minimum size, so the row reserves the right amount of room.
##   scaler   plain Control carrying the scale. It has to be a child rather
##            than the sizer itself, because a Container LAYS OUT its direct
##            children and resets their scale doing it - the first version put
##            the scale on the node in the VBox and the "big" card came out
##            exactly the same size as the grid cards. One level of remove and
##            the container never touches it.
##   card     the CardView, at its natural size.
##
## Scaling rather than just asking for a bigger CardView, because the card's
## font sizes are in pixels: a bigger box would lay out correctly and still
## have hand-sized text in it, which is the opposite of what a "look closely at
## this card" pane is for.
func _slot(entry: Dictionary, s: float, clickable: bool) -> Control:
	var card := CardView.new()
	card.setup(entry, true, false)
	card.size = card.custom_minimum_size

	var scaler := Control.new()
	scaler.scale = Vector2(s, s)
	scaler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scaler.add_child(card)

	var sizer := Control.new()
	sizer.custom_minimum_size = card.custom_minimum_size * s
	sizer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sizer.add_child(scaler)

	if clickable:
		card.tapped.connect(func() -> void: _open_detail(entry))
	else:
		card.disabled = true
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sizer.set_meta("card", card)
	sizer.set_meta("scaler", scaler)
	return sizer


# --- one card, and its upgrade ---------------------------------------------

## Open the detail pane on the Nth card. Public so the dev console can say
## `card 3` and so the screenshot harness can photograph a pane that otherwise
## only opens on a click it has no way to perform.
func inspect(i: int) -> bool:
	if i < 0 or i >= _deck.size():
		return false
	_open_detail(_deck[i] as Dictionary)
	return true


func _open_detail(entry: Dictionary) -> void:
	_close_detail()
	_turn = 0.0
	_turning.clear()

	var d := ColorRect.new()
	d.color = Color(0.02, 0.02, 0.03, 0.86)
	d.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	d.mouse_filter = Control.MOUSE_FILTER_STOP
	d.gui_input.connect(_detail_input)
	add_child(d)
	_detail = d

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.add_child(centre)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centre.add_child(col)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 46)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(row)

	row.add_child(_captioned(entry, "In your deck"))
	var up: Dictionary = entry.get("upgrade", {})
	if not up.is_empty() and not bool(entry.get("upgraded", false)):
		row.add_child(_captioned(up, "Sharpened at a campfire"))
	elif bool(entry.get("upgraded", false)):
		var done := Label.new()
		done.text = "already\nsharpened"
		done.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		done.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		done.add_theme_font_size_override("font_size", 14)
		done.add_theme_color_override("font_color", Color(0.55, 0.60, 0.54))
		row.add_child(done)

	if _picking():
		# The confirm lives HERE, not on the grid tile, and that is the point of
		# routing the campfire through this screen: you commit to sharpening a
		# card while looking at what it turns into.
		var go := Button.new()
		go.text = _action
		go.custom_minimum_size = Vector2(240, 40)
		go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var idx := int(entry.get("index", -1))
		go.pressed.connect(func() -> void:
			if idx >= 0 and _on_pick.is_valid():
				_on_pick.call(idx)
			queue_free())
		col.add_child(go)

	var hint := Label.new()
	hint.text = "drag left and right to turn the card   ·   Esc to go back"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.66, 0.70, 0.64))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(hint)
	_apply_turn()


## A big card under a caption, and registered as something the drag turns.
func _captioned(entry: Dictionary, caption: String) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cap := Label.new()
	cap.text = caption
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_font_size_override("font_size", 14)
	cap.add_theme_color_override("font_color", Color(0.86, 0.82, 0.70))
	col.add_child(cap)
	var sizer := _slot(entry, BIG, false)
	col.add_child(sizer)
	_turning.append(sizer.get_meta("card") as CardView)
	return col


func _picking() -> bool:
	return _on_pick.is_valid()


## Nothing extra in the header; kept as a seam so a future pick mode can warn
## about something (a removal being permanent, say) without touching the layout.
func _picking_note(_col: Control) -> void:
	pass


## Turn the open card to `t`, -1..+1. What a drag does, said outright — for the
## dev console and the screenshot harness, neither of which can drag.
func turn_to(t: float) -> void:
	_turn = clampf(t, -1.0, 1.0)
	_apply_turn()


func _detail_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT:
		_dragging = mb.pressed
		# A click that never became a drag is a click, and a click on the
		# backdrop goes back. Judged on the drag having moved the card, not on
		# time, because a slow careful turn is still a turn.
		if not mb.pressed and is_zero_approx(_turn):
			_close_detail()
		return
	var mm := event as InputEventMouseMotion
	if mm != null and _dragging:
		_turn = clampf(_turn + mm.relative.x / DRAG_SPAN, -1.0, 1.0)
		_apply_turn()


## Turn every card in the detail pane to `_turn`.
##
## Two things happen at once, and they are different mechanisms:
##
##   the WINDOW   turn_override picks the rendered view, so the picture inside
##                a rare parallaxes against its frame. Real depth, baked in
##                Blender, and the only part of this that is not a trick.
##   the CARD     scaled horizontally by cos(angle). A Control cannot be given
##                a perspective transform, but a turning card is mostly a card
##                getting narrower, and doing that in step with the parallax is
##                enough for the eye to read the two as one object.
##
## Without the squash the picture slides around inside a card that is plainly
## still facing you, which reads as the art being loose rather than the card
## being turned.
func _apply_turn() -> void:
	var squash: float = cos(_turn * deg_to_rad(38.0))
	for c in _turning:
		if not is_instance_valid(c):
			continue
		c.turn_override = _turn
		# The scaler, not the card: the card sets its own scale on hover and
		# would stamp on anything written here.
		var scaler := c.get_parent() as Control
		if scaler != null:
			scaler.scale = Vector2(BIG * squash, BIG)


func _close_detail() -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()
	_detail = null
	_turning.clear()
	_dragging = false
	_turn = 0.0
