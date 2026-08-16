## The places between fights, staged in 3D.
##
## Step 6 of design/3d-pivot.md — the phases the 2D client still owned. Routing
## the run through 3D made those handovers jarring: you walk a region in 3D,
## climb a beast in 3D, and then a flat 2D panel appears.
##
## This is one scene for several phases, because they are all the same thing —
## your hunters standing somewhere, being offered a choice. What changes is the
## place (a felled beast, a campfire) and the choice on the HUD. Building them as
## one scene is what keeps the remaining phases cheap to add.
##
## Like every other client here, it owns no rules: it reads the same snapshot and
## sends the same commands the 2D screens do.
extends Node3D

const CAST := "res://assets/3d/cast/"
const HEX := "res://assets/3d/hex/"
const HEX_W := 1.0
const HEX_D := 1.154701
const ROW_STEP := HEX_D * 0.75
const TILE_TOP := 0.2
const HUNTER_HEIGHT := 0.62
## The felled beast is laid out behind the hunters, sized from the SAME input the
## fight used — how far you had to climb it — so the thing lying here is
## recognisably the thing you just beat.
##
## Not at combat's literal ratio. There a Titan stands ~17 hunters tall; 17x here
## would bury the reward cards this scene exists to frame, and you'd be reading
## three cards against a wall of flank. So it's compressed into a range the plot
## can hold, while a Titan still sprawls about three times a Crag Pup. Before
## this, EVERY beast lay at 1.7 — you felled a colossus and got a knee-high
## trophy, which quietly undercut the fight you'd just won.
const FELLED_MIN := 1.8
const FELLED_MAX := 5.0
## Weak-point Heights run 1..8 across the roster; that span maps onto the range.
const FELLED_MAX_WP := 8.0
## Where the body's centre lands — behind the hunters (who stand at z -0.15),
## still on the tiles.
const FELLED_Z := -1.25
## Hex neighbours around the centre tile — pointy-top, so odd rows step half a
## tile sideways. Same grid the overworld uses.
const _PLOT := [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(-1, -1),
	Vector2i(2, 0), Vector2i(-2, 0),
	Vector2i(1, 1), Vector2i(-2, 1), Vector2i(1, -1), Vector2i(-2, -1),
	Vector2i(0, 2), Vector2i(-1, 2), Vector2i(0, -2), Vector2i(-1, -2),
	Vector2i(1, 2), Vector2i(-2, 2), Vector2i(1, -2), Vector2i(-2, -2),
]
const HUNTER_MODEL := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey",
}
## Reuses the combat view's table, so a beast swapped there is swapped here too.
const BEAST_MODEL := preload("res://views/combat_3d.gd")

var _client: GameClient
var _built := ""        # the phase the scene was staged for
var _active_slot := 0
var _selected := -1     # reward choice tapped but not yet locked in
var _kw_popup: CanvasLayer = null  # the keyword explainer, when one is open
var _deck_pick := ""    # campfire: "remove" | "upgrade" while choosing a card
var _shop_pick := -1    # shop: the removal being resolved, -1 when idle
var _time := 0.0
var _hunters: Array = []
var _felled_span := 0.0   # size of the body on the plot; the shot backs off for it

@onready var _plot: Node3D = %Plot
@onready var _cam: Camera3D = %Camera
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _prompt: Label = %Prompt
@onready var _row: HBoxContainer = %Row
@onready var _controls: HBoxContainer = %Controls


func _ready() -> void:
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	if not _client.shared.is_empty():
		_refresh()


func _process(delta: float) -> void:
	_time += delta
	for i in range(_hunters.size()):
		var n: Node3D = _hunters[i]
		if is_instance_valid(n):
			n.position.y = TILE_TOP + sin(_time * 2.1 + i * 1.7) * 0.035


# --- solo helpers, identical to the combat views --------------------------

func _is_solo() -> bool:
	return bool(_client.shared.get("solo", false))

func _me() -> int:
	return _active_slot if _is_solo() else _client.you

func _cmd_slot() -> int:
	return _active_slot if _is_solo() else -1

func _my_private() -> Dictionary:
	if _is_solo():
		var slots: Array = _client.private.get("slots", [])
		return slots[_active_slot] if _active_slot < slots.size() else {}
	return _client.private


# --- staging --------------------------------------------------------------

func _refresh() -> void:
	# A snapshot can land while the router is swapping this view out — the signal
	# is still connected for that window. Staging a detached scene aims a camera
	# that isn't in the tree and measures props that aren't either; nothing good
	# comes of it, and the frame it would build is about to be thrown away.
	if not is_inside_tree():
		return
	var s := _client.shared
	var phase := String(s.get("phase", ""))
	if phase == "":
		return
	if phase != _built:
		_built = phase
		_selected = -1
		_deck_pick = ""
		_shop_pick = -1
		_stage(s, phase)
	match phase:
		"select": _render_select(s)
		"reward": _render_reward(s)
		"event": _render_event(s)
		"campfire": _render_campfire(s)
		"shop": _render_shop(s)
		"won", "lost": _render_over(s, phase)


## Build the place. A small hex plot the hunters stand on, plus whatever the
## phase is *about* — for a reward, the beast lying behind them.
func _stage(s: Dictionary, phase: String) -> void:
	for c in _plot.get_children():
		c.queue_free()
	_hunters.clear()
	_felled_span = 0.0   # only a reward has a body to make room for
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(phase + String(s.get("felled", "")))
	# The inner ring stays PLAIN grass: forest tiles carry trees, and trees where
	# the hunters and the body stand simply swallow them. Scenery goes outside.
	_tile("grass", 0, 0, rng)
	for i in range(_PLOT.size()):
		var at: Vector2i = _PLOT[i]
		var tile := "grass"
		if i >= 6:
			tile = ["grass", "grass", "grass-forest", "grass-hill"][rng.randi() % 4]
		_tile(tile, at.x, at.y, rng)
	if phase == "select":
		pass  # the roster itself is the staging — see _show_roster
	elif phase == "reward":
		var felled_id := String(s.get("felled", ""))
		# Ground first, and enough of it: a felled Titan sprawls wider than this
		# little plot, and a carcass overhanging open water is the same "floating"
		# read this whole fix exists to kill. Sized off the body that's coming.
		_widen_plot(rng, _felled_height(felled_id) * 0.78)
		_lay_out_the_felled(felled_id)
	elif phase == "event":
		_landmark("building-wizard-tower", Vector3(-1.0, 0.0, -1.55))
	elif phase == "campfire":
		_landmark("building-cabin", Vector3(-1.0, 0.0, -1.55))
	elif phase == "shop":
		_landmark("building-market", Vector3(-1.0, 0.0, -1.55))
	if phase != "select":
		_place_hunters(s)
	# the card row owns the bottom of the screen here too, so the scene is
	# aimed and offset to sit clear of it — same trick as the combat view.
	# A felled Titan sprawls several times a Crag Pup, so the shot backs off to
	# hold it rather than cropping the body the reward is FOR.
	# Derived from the body's measured sprawl and the lens, not hand-tuned offsets:
	# a felled Crag Pup and a felled Titan differ by three times, and coefficients
	# that framed one cropped the other.
	var need := maxf(4.5, _felled_span * 1.9)
	var back := need / (2.0 * tan(deg_to_rad(_cam.fov) * 0.5))
	_cam.position = Vector3(0.0, back * 0.55, back * 1.05)
	_cam.look_at(Vector3(0.0, 0.4 + _felled_span * 0.22, -1.1), Vector3.UP)


func _hex_x(hex_col: int, hex_row: int) -> float:
	return hex_col * HEX_W + (HEX_W * 0.5 if absi(hex_row) % 2 == 1 else 0.0)


func _tile(name: String, hex_col: int, hex_row: int, rng: RandomNumberGenerator) -> void:
	var path := HEX + name + ".glb"
	if not ResourceLoader.exists(path):
		return
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	inst.position = Vector3(_hex_x(hex_col, hex_row), 0.0, -hex_row * ROW_STEP)
	inst.rotation.y = float(rng.randi_range(0, 5)) * (PI / 3.0)
	_plot.add_child(inst)


## The beast you just brought down, on its side. It is the only reason the
## reward exists, and a flat panel never said so.
func _lay_out_the_felled(beast_id: String) -> void:
	var key: String = String((BEAST_MODEL.MODELS as Dictionary).get(beast_id, ""))
	var path := CAST + key + ".glb"
	if key == "" or not ResourceLoader.exists(path):
		return
	var body: Node3D = (load(path) as PackedScene).instantiate()
	_plot.add_child(body)
	var tall := _felled_height(beast_id)
	_fit_height(body, tall)
	_felled_span = tall
	# Onto its BACK, feet toward the camera — a cube pet tipped onto its flank
	# still reads as sitting, but belly-up is unmistakable.
	body.rotation = Vector3(-PI * 0.5, 0.35, 0.0)
	body.position = Vector3.ZERO
	# Measure, then correct. A toppled body sprawls by its full standing height,
	# and where a model's origin sits inside that sprawl differs per beast — the
	# old fixed offset sent it off the BACK of the island to hang over the sea,
	# which is why the trophy looked like it was floating. Place it, look at where
	# it actually landed, and shift by the difference.
	var b := _bounds_in_parent(body)
	body.position += Vector3(-b.get_center().x,
		TILE_TOP - b.position.y,
		FELLED_Z - b.get_center().z)
	# What the shot has to hold: the body's real sprawl, not the height we asked
	# for. These models are near-cubic, so a beast scaled to 2.3 tall still lies
	# 2.8 across — frame off the target and the trophy gets its head cropped.
	_felled_span = maxf(b.size.x, maxf(b.size.y, b.size.z))


## Extra ground out to `radius`, filling in whatever _PLOT doesn't already cover.
## Circular rather than following _PLOT's hand-placed shape, so it stays right at
## any size — and the other phases, which need no extra room, never call it and
## keep the plot exactly as it was.
func _widen_plot(rng: RandomNumberGenerator, radius: float) -> void:
	if radius <= 2.2:   # _PLOT already reaches about this far
		return
	var have := {Vector2i(0, 0): true}
	for at in _PLOT:
		have[at] = true
	for row in range(-6, 7):
		for col in range(-6, 7):
			var key := Vector2i(col, row)
			if have.has(key):
				continue
			if Vector2(_hex_x(col, row), -row * ROW_STEP).length() > radius:
				continue
			_tile(["grass", "grass", "grass", "grass-forest"][rng.randi() % 4],
				col, row, rng)


## How big the body lying here should be, from the climb the beast demanded.
## Reads the beast's own data rather than anything the snapshot happens to carry,
## so it stays right if the reward payload ever changes shape.
func _felled_height(beast_id: String) -> float:
	var boss: Boss = Content.build_boss(beast_id)
	if boss == null:
		return FELLED_MIN
	var t := clampf((float(boss.weak_point_height) - 1.0) / (FELLED_MAX_WP - 1.0), 0.0, 1.0)
	return lerpf(FELLED_MIN, FELLED_MAX, t)


## A hex landmark stood up as scenery — the same tile the overworld uses for
## that node type, so arriving somewhere looks like the place you walked to.
func _landmark(name: String, at: Vector3) -> void:
	var path := HEX + name + ".glb"
	if not ResourceLoader.exists(path):
		return
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	inst.position = at
	_plot.add_child(inst)


func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	for i in range(players.size()):
		var id := String((players[i] as Dictionary).get("character", ""))
		if id == "":
			id = String((players[i] as Dictionary).get("portrait", "")) \
				.get_file().get_basename()
		var key: String = String(HUNTER_MODEL.get(id, "bunny"))
		var path := CAST + key + ".glb"
		if not ResourceLoader.exists(path):
			continue
		var n: Node3D = (load(path) as PackedScene).instantiate()
		_plot.add_child(n)
		_fit_height(n, HUNTER_HEIGHT)
		n.position = Vector3(-0.78 + 1.56 * float(i), TILE_TOP, -0.15)
		# facing the camera, angled toward each other — models face +Z, so PI
		# here would show you nothing but their backs
		n.rotation.y = 0.4 if i == 0 else -0.4
		_hunters.append(n)


## Scale a model to a target world height, measured — see design/blender-pipeline.md.
func _fit_height(node: Node3D, want: float) -> void:
	node.scale = Vector3.ONE * (want / maxf(_bounds(node).size.y, 0.001))


## Bounds of everything under `node`, in NODE'S OWN space.
##
## Deliberately not `global_transform`. That needs the node to be inside the
## scene tree, and staging measures a model the instant it is built — including
## on snapshots that land while this view is being swapped out, which threw about
## a dozen errors per staging and left the first drawn frame mis-framed. Walking
## the local chain needs no tree at all.
##
## Measuring in the node's own space is also the honest answer: a model's size
## should not change because something above it happens to be scaled.
func _bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for m in _meshes(node):
		var mi: MeshInstance3D = m
		var b: AABB = _relative_xform(mi, node) * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


## The same bounds seen by the node's PARENT — so it includes the node's own
## rotation and scale. What you want after toppling something on its back: only
## then is its upright height lying sideways.
func _bounds_in_parent(node: Node3D) -> AABB:
	return node.transform * _bounds(node)


## Transform of `from` expressed in `to`'s space, by walking the parent chain.
## Pure arithmetic on local transforms — works on a node that was built a moment
## ago and has never been in the tree.
func _relative_xform(from: Node3D, to: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var n: Node = from
	while n != null and n != to:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t


func _meshes(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		out += _meshes(c)
	return out


## Right-clicking a keyword on a card you are being offered explains it, the same
## as it does in a fight. Its own small overlay: this scene has no card inspector,
## and the question ("what is Poison") does not need one.
func _show_keyword(kw: Dictionary) -> void:
	if kw.is_empty() or _kw_popup != null and is_instance_valid(_kw_popup):
		if _kw_popup != null and is_instance_valid(_kw_popup):
			_kw_popup.queue_free()
			_kw_popup = null
		if kw.is_empty():
			return
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.03, 0.02, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			shade.queue_free()
			_kw_popup = null)
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	layer.add_child(shade)
	_kw_popup = layer

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 16.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)
	var title := RichTextLabel.new()
	title.bbcode_enabled = true
	title.text = "[u]%s[/u]" % String(kw.get("name", ""))
	title.fit_content = true
	title.scroll_active = false
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("normal_font_size", 18)
	title.add_theme_color_override("default_color", Color(1, 0.86, 0.5))
	col.add_child(title)
	var body := Label.new()
	body.text = String(kw.get("text", ""))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(328, 0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color(0.86, 0.82, 0.74))
	col.add_child(body)


# --- the reward ------------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	var reward: Dictionary = _my_private().get("reward", {})
	var is_relic := String(reward.get("kind", "card")) == "relic"
	var picked := bool(reward.get("picked", false))
	var noun := "relic" if is_relic else "card"
	var solo := _is_solo()
	# The REWARD phase is reached three ways — a felled beast, a felled Titan, or a
	# treasure cache you simply walked up to — and only one of them involves
	# felling a Titan.
	match String(s.get("node_type", "boss")):
		"boss":
			_title.text = "Titan felled!   (%d / %d)" % [
				int(s.get("encounter", 1)), int(s.get("total_encounters", 1))]
		"elite":
			_title.text = "The elite falls."
		"treasure":
			_title.text = "A cache in the rocks"
		_:
			_title.text = "The beast falls."
	_subtitle.text = ("Choose a RELIC — a lasting boon for the team."
		if is_relic else "Choose a card to strengthen your deck for the next Titan.")
	if picked:
		_prompt.text = "Locked in — waiting for your ally"
	elif _selected >= 0:
		_prompt.text = "Tap another to change, or Lock In your %s" % noun
	else:
		_prompt.text = "%sTap a %s to select" % [
			("%s picks:   " % _hunter_name(_active_slot)) if solo else "", noun]

	for c in _row.get_children():
		c.queue_free()
	for choice in reward.get("choices", []):
		var idx := int(choice["index"])
		var cv := CardView.new()
		_row.add_child(cv)
		cv.setup(choice, not picked)
		cv.modulate = Color(1, 1, 1) if (_selected == idx or _selected < 0) \
			else Color(0.62, 0.6, 0.56)
		cv.keyword_requested.connect(_show_keyword)
		cv.tapped.connect(func() -> void:
			if picked:
				return
			Sfx.play("card")
			_selected = idx
			_render_reward(_client.shared))

	for c in _controls.get_children():
		c.queue_free()
	# selection is client-side; the host only ever hears the locked choice
	var lock := _button("Lock In Reward", func() -> void:
		Sfx.play("lock")
		_client.pick_card(_selected, _cmd_slot())
		_selected = -1)
	lock.disabled = picked or _selected < 0
	_controls.add_child(lock)
	if not picked:
		_controls.add_child(_button("Skip — keep the deck lean", func() -> void:
			Sfx.play("lock")
			_client.skip_reward(_cmd_slot())
			_selected = -1))
	if solo:
		_controls.add_child(_button("▶ Switch to %s" % _hunter_name(1 - _active_slot),
			func() -> void:
				_active_slot = 1 - _active_slot
				_selected = -1
				_render_reward(_client.shared)))


# --- wayside events --------------------------------------------------------

func _render_event(s: Dictionary) -> void:
	var ev: Dictionary = s.get("event", {})
	_title.text = String(ev.get("title", "On the way"))
	_subtitle.text = String(ev.get("text", ""))
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()
	# an event can offer more than two choices, so they stack in the card row
	# rather than crowding the single control strip
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_END
	stack.add_theme_constant_override("separation", 8)
	_row.add_child(stack)
	for i in range(ev.get("choices", []).size()):
		var ch: Dictionary = (ev["choices"] as Array)[i]
		var idx := i
		var b := _button("%s     %s" % [String(ch.get("label", "…")),
			_stakes(ch.get("effects", {}))], func() -> void:
				Sfx.play("card")
				_client.pick_event(idx))
		b.custom_minimum_size = Vector2(560, 44)
		stack.add_child(b)


## Spell the stakes out on the button — an event should never be a blind pick.
## Same rule the 2D screen follows, and the same wording.
func _stakes(eff: Dictionary) -> String:
	var bits: Array[String] = []
	var h := int(eff.get("heal", 0))
	if h > 0:
		bits.append("+%d HP" % h)
	elif h < 0:
		bits.append("%d HP" % h)
	var mh := int(eff.get("max_hp", 0))
	if mh != 0:
		bits.append("%+d max HP" % mh)
	var g := int(eff.get("gold", 0))
	if g != 0:
		bits.append("%+d gold" % g)
	if bool(eff.get("relic", false)):
		bits.append("relic")
	var rw := String(eff.get("reward", ""))
	if rw != "":
		bits.append("choose a " + rw)
	return "(%s)" % "  ·  ".join(bits) if not bits.is_empty() else ""


# --- the run ending --------------------------------------------------------

func _render_over(s: Dictionary, phase: String) -> void:
	var won := phase == "won"
	_title.text = "The last Titan falls." if won else "The hunt ends here."
	# `result` is a bare token for the log, not something to show a player
	_subtitle.text = ("Every Titan in the range has been brought down. Ascension %d cleared."
		% int(s.get("ascension", 0))) if won else 		"The range keeps its Titans. Take what you learned and climb again."
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()
	_controls.add_child(_button("Hunt again", func() -> void: _client.restart()))
	_controls.add_child(_button("Return to menu", func() -> void:
		get_tree().change_scene_to_file("res://views/menu.tscn")))


func _button(text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(190, 40)
	b.pressed.connect(on_press)
	return b


func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	if slot < 0 or slot >= players.size():
		return "Hunter %d" % (slot + 1)
	return String((players[slot] as Dictionary).get("name", "Hunter %d" % (slot + 1)))


# --- choosing your hunter --------------------------------------------------

## The lobby, staged like everywhere else. Picking a hunter in 3D means you see
## the body you'll be climbing with, at the size it'll actually be — which a row
## of portrait cards never told you.
func _render_select(s: Dictionary) -> void:
	var roster: Array = _client.private.get("characters", [])
	var solo := bool(s.get("solo", false))
	var slot := int(s.get("current_slot", 0)) if solo else _client.you
	_title.text = "Choose your hunter" if not solo \
		else "Choose Hunter %d's climber" % (slot + 1)
	var joined := int(s.get("joined", 1))
	var required := int(s.get("required", 1))
	_subtitle.text = "Waiting for hunters — %d of %d here." % [joined, required] \
		if joined < required else "Nobody climbs this alone. Pick who you'll be."
	_clear_ui()
	_show_roster(roster)
	for i in range(roster.size()):
		var c: Dictionary = roster[i]
		var id := String(c.get("id", ""))
		var b := _button("%s\n%s" % [String(c.get("name", id)), String(c.get("desc", ""))],
			func() -> void:
				Sfx.play("lock")
				_client.select_character(id, slot if solo else -1))
		b.custom_minimum_size = Vector2(268, 96)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_controls.add_child(b)


## Line the whole roster up on the plot, so the buttons below name bodies you
## can see rather than words on their own.
func _show_roster(roster: Array) -> void:
	for n in _hunters:
		if is_instance_valid(n):
			(n as Node3D).queue_free()
	_hunters.clear()
	var span := 1.05
	var left := -span * (float(roster.size()) - 1.0) * 0.5
	for i in range(roster.size()):
		var key: String = String(HUNTER_MODEL.get(String((roster[i] as Dictionary).get("id", "")),
			"bunny"))
		var path := CAST + key + ".glb"
		if not ResourceLoader.exists(path):
			continue
		var n: Node3D = (load(path) as PackedScene).instantiate()
		_plot.add_child(n)
		_fit_height(n, HUNTER_HEIGHT)
		n.position = Vector3(left + span * float(i), TILE_TOP, -0.4)
		_hunters.append(n)


# --- the campfire ----------------------------------------------------------

func _render_campfire(s: Dictionary) -> void:
	var cf: Dictionary = s.get("campfire", {})
	var priv := _my_private()
	var deck: Array = priv.get("deck", [])
	var done := bool(priv.get("done", false))
	_title.text = "Campfire"
	_clear_ui()
	if done:
		_subtitle.text = "%s is done — waiting for your ally." % _hunter_name(_me())
		_add_switch()
		return
	if _deck_pick != "":
		_subtitle.text = ("Choose a card to remove — it leaves the deck for good."
			if _deck_pick == "remove" else "Choose a card to sharpen.")
		var action := _deck_pick
		_deck_picker(deck, func(i: int) -> void:
			Sfx.play("reward")
			_client.campfire(action, i, _cmd_slot())
			_deck_pick = "")
		_controls.add_child(_button("Back", func() -> void:
			_deck_pick = ""
			_refresh()))
		return
	_subtitle.text = "%s rests. A quiet hour before the climb — spend it how you like." \
		% _hunter_name(_me())
	var stack := _stack()
	stack.add_child(_button("Rest — recover %d HP" % int(cf.get("heal", 12)),
		func() -> void:
			Sfx.play("reward")
			_client.campfire("rest", -1, _cmd_slot())))
	# thinning past the floor would let a deck shrink away to nothing
	var can_thin: bool = deck.size() > int(cf.get("min_deck", 5))
	var thin := _button("Thin the deck — remove a card" if can_thin
		else "Thin the deck — deck too small", func() -> void:
			_deck_pick = "remove"
			_refresh())
	thin.disabled = not can_thin
	stack.add_child(thin)
	stack.add_child(_button("Sharpen — upgrade a card", func() -> void:
		_deck_pick = "upgrade"
		_refresh()))
	_add_switch()


# --- the trader ------------------------------------------------------------

func _render_shop(s: Dictionary) -> void:
	var shop: Dictionary = s.get("shop", {})
	var stock: Array = shop.get("stock", [])
	var gold := int(s.get("gold", 0))
	_title.text = "A trader on the road"
	_clear_ui()
	if _shop_pick >= 0:
		_subtitle.text = "Choose a card to remove — it leaves the deck for good."
		var idx := _shop_pick
		_deck_picker(_my_private().get("deck", []), func(i: int) -> void:
			Sfx.play("reward")
			_client.buy(idx, i)
			_shop_pick = -1)
		_controls.add_child(_button("Back", func() -> void:
			_shop_pick = -1
			_refresh()))
		return
	_subtitle.text = "Purse: %d gold. One purse between you — spend it well." % gold
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 6)
	# hug the bottom, so eight stock items don't bury the place you walked to
	grid.size_flags_vertical = Control.SIZE_SHRINK_END
	_row.add_child(grid)
	for i in range(stock.size()):
		grid.add_child(_stock_button(stock[i], i, gold))
	_controls.add_child(_button("Move on →", func() -> void:
		Sfx.play("end_turn")
		_client.leave_shop()))
	_add_switch()


func _stock_button(item: Dictionary, index: int, gold: int) -> Button:
	var price := int(item["price"])
	var sold := bool(item["sold"])
	var owner := int(item.get("slot", -1))
	var who := "" if owner < 0 else "  (%s)" % _hunter_name(owner)
	var b := Button.new()
	b.custom_minimum_size = Vector2(258, 74)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.text = "%s\n%s%s\n%s" % ["SOLD" if sold else "%d gold" % price,
		String(item.get("name", "?")), who, String(item.get("text", ""))]
	b.disabled = sold or gold < price
	if not b.disabled:
		var idx := index
		b.pressed.connect(func() -> void:
			# a removal has to name a card too, so it opens the deck picker
			if String(item.get("kind", "")) == "remove":
				_shop_pick = idx
				_refresh()
			else:
				Sfx.play("reward")
				_client.buy(idx))
	return b


# --- shared UI helpers -----------------------------------------------------

func _clear_ui() -> void:
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()


func _stack() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 8)
	_row.add_child(v)
	return v


## Your persistent deck, as a grid you pick one card from. Compact buttons rather
## than CardViews: a deck runs well past a dozen cards and full card faces don't
## fit the strip — the name and cost are what you're choosing on anyway.
func _deck_picker(deck: Array, on_pick: Callable) -> void:
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	_row.add_child(grid)
	for i in range(deck.size()):
		var card: Dictionary = deck[i]
		var idx := i
		var b := _button("%s   ✦%d" % [String(card.get("name", "?")),
			int(card.get("cost", 0))], func() -> void: on_pick.call(idx))
		b.custom_minimum_size = Vector2(196, 36)
		grid.add_child(b)


func _add_switch() -> void:
	if _is_solo():
		_controls.add_child(_button("▶ Switch to %s" % _hunter_name(1 - _active_slot),
			func() -> void:
				_active_slot = 1 - _active_slot
				_deck_pick = ""
				_shop_pick = -1
				_refresh()))
