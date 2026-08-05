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
## The felled beast is laid out behind the hunters — big enough to read as what
## you just brought down, not so big it competes with the cards.
const FELLED_HEIGHT := 1.7
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
var _time := 0.0
var _hunters: Array = []

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
	var s := _client.shared
	var phase := String(s.get("phase", ""))
	if phase == "":
		return
	if phase != _built:
		_built = phase
		_selected = -1
		_stage(s, phase)
	match phase:
		"reward": _render_reward(s)
		"won", "lost": _render_over(s, phase)


## Build the place. A small hex plot the hunters stand on, plus whatever the
## phase is *about* — for a reward, the beast lying behind them.
func _stage(s: Dictionary, phase: String) -> void:
	for c in _plot.get_children():
		c.queue_free()
	_hunters.clear()
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
	if phase == "reward":
		_lay_out_the_felled(String(s.get("felled", "")))
	_place_hunters(s)
	# the card row owns the bottom of the screen here too, so the scene is
	# aimed and offset to sit clear of it — same trick as the combat view
	_cam.position = Vector3(0.0, 3.5, 6.0)
	_cam.look_at(Vector3(0.0, 0.5, -1.4), Vector3.UP)


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
	_fit_height(body, FELLED_HEIGHT)
	# onto its BACK, not its flank — a cube pet tipped sideways still reads as
	# sitting, but feet-up is unmistakable
	body.rotation = Vector3(-PI * 0.5, 0.35, 0.0)
	body.position = Vector3(0.45, 0.0, -1.55)
	# it was scaled upright, so only AFTER toppling do we know how tall it lies
	body.position.y = TILE_TOP - _bounds(body).position.y


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
		n.rotation.y = PI + (0.35 if i == 0 else -0.35)  # turned a little inward
		_hunters.append(n)


## Scale a model to a target world height, measured — see design/blender-pipeline.md.
func _fit_height(node: Node3D, want: float) -> void:
	node.scale = Vector3.ONE * (want / maxf(_bounds(node).size.y, 0.001))


## World-space bounds of everything under a node.
func _bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for m in _meshes(node):
		var mi: MeshInstance3D = m
		var b: AABB = mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


func _meshes(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		out += _meshes(c)
	return out


# --- the reward ------------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	var reward: Dictionary = _my_private().get("reward", {})
	var is_relic := String(reward.get("kind", "card")) == "relic"
	var picked := bool(reward.get("picked", false))
	var noun := "relic" if is_relic else "card"
	var solo := _is_solo()
	_title.text = "Titan felled!   (%d / %d)" % [
		int(s.get("encounter", 1)), int(s.get("total_encounters", 1))]
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
