## 3D combat view — the SAME authoritative snapshots, rendered in a 3D scene.
##
## This is the whole point of CLAUDE.md §2's layering rule paying off: /core and
## /session don't know or care that the game became 3D. This is a second client
## alongside views/combat_view.gd, reading identical `shared`/`private` dicts.
##
## The climb stops being an abstraction here — Height IS vertical position on the
## beast's body, so a hunter at the weak point is literally up at the weak point.
extends Node3D

const CAST := "res://assets/3d/cast/"
## Which model plays each character / beast, until real art exists.
const MODELS := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey",
	"stone_warden": "elephant", "gale_serpent": "tiger",
	"drowned_colossus": "polar", "sunken_warden": "lion",
	"crag_pup": "dog", "bramble_hog": "hog", "bounder": "bunny",
}
const BEAST_SCALE := 2.3     # the beast towers; hunters are small things on it
const HUNTER_SCALE := 0.5
const CLIMB_TOP := 3.4       # world height of the weak point
const CLIMB_BASE := 0.35     # world height of the ground

var _client: GameClient
var _beast: Node3D
var _beast_id := ""
var _hunters: Array = []     # slot -> Node3D

@onready var _rig: Node3D = %BeastRig
@onready var _cam: Camera3D = %Camera
@onready var _hud: Control = %Root
@onready var _title: Label = %Title
@onready var _hp: Label = %HpLabel
@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hand_row: HBoxContainer = %Hand
@onready var _status: Label = %StatusLabel
@onready var _end_btn: Button = %EndTurn
@onready var _switch_btn: Button = %SwitchBtn

var _active_slot := 0


func _ready() -> void:
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	_end_btn.pressed.connect(func() -> void:
		Sfx.play("end_turn")
		_client.end_turn(_cmd_slot())
		if _is_solo():
			_active_slot = 1 - _active_slot
		_refresh())
	_switch_btn.pressed.connect(func() -> void:
		_active_slot = 1 - _active_slot
		_refresh())
	if not _client.shared.is_empty():
		_refresh()


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


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty() or String(s.get("phase", "")) != "combat":
		_hud.visible = false
		return
	_hud.visible = true
	var boss: Dictionary = s["boss"]
	_title.text = String(boss["name"])
	_hp.text = "%d / %d" % [int(boss["hp"]), int(boss["max_hp"])]
	_hp_bar.max_value = int(boss["max_hp"])
	_hp_bar.value = int(boss["hp"])
	_show_beast(String(boss.get("art", "")), String(boss["name"]))
	_place_hunters(s)
	_render_hand()


## Swap in the beast model when the encounter changes, scaled to loom.
func _show_beast(art: String, beast_name: String) -> void:
	var key := _model_key(art, beast_name)
	if key == _beast_id:
		return
	_beast_id = key
	if _beast != null:
		_beast.queue_free()
	var path := CAST + key + ".glb"
	if not ResourceLoader.exists(path):
		return
	_beast = (load(path) as PackedScene).instantiate()
	_beast.scale = Vector3.ONE * BEAST_SCALE
	_rig.add_child(_beast)


## The 2D build identified beasts by portrait path; reuse that to pick a model.
func _model_key(art: String, beast_name: String) -> String:
	var stem := art.get_file().get_basename()
	for id in MODELS:
		if stem == String(MODELS[id]) or stem == id:
			return String(MODELS[id])
	# fall back on the name so a new beast still renders something
	for id2 in MODELS:
		if beast_name.to_lower().contains(String(id2).replace("_", " ")):
			return String(MODELS[id2])
	return "elephant"


## Height becomes literal: a hunter's world Y is interpolated between the ground
## and the weak point, so climbing is something you SEE rather than read.
func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var boss: Dictionary = s.get("boss", {})
	var height: int = maxi(int(boss.get("weak_point_height", 1)), 1)
	while _hunters.size() < players.size():
		var h := _spawn_hunter(_hunters.size(), players)
		_hunters.append(h)
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var t: float = clampf(float(int(p.get("foothold", 0))) / float(height), 0.0, 1.0)
		var y: float = lerpf(CLIMB_BASE, CLIMB_TOP, t)
		var side: float = -1.5 if i == 0 else 1.5
		# on the ground they stand in front of the beast; climbing, they're ON it
		var z: float = lerpf(3.6, 1.2, t)
		var node: Node3D = _hunters[i]
		node.position = Vector3(side, y, z)
		node.rotation.y = PI if t < 0.05 else 0.0


func _spawn_hunter(slot: int, players: Array) -> Node3D:
	var key := "bunny"
	var art := String((players[slot] as Dictionary).get("portrait", ""))
	var stem := art.get_file().get_basename()
	var by_portrait := {"frog": "bunny", "sloth": "koala", "goat": "deer", "monkey": "monkey"}
	if by_portrait.has(stem):
		key = String(by_portrait[stem])
	var holder := Node3D.new()
	_rig.add_child(holder)
	var path := CAST + key + ".glb"
	if ResourceLoader.exists(path):
		var m := (load(path) as PackedScene).instantiate()
		m.scale = Vector3.ONE * HUNTER_SCALE
		holder.add_child(m)
	return holder


func _render_hand() -> void:
	for c in _hand_row.get_children():
		c.queue_free()
	var priv := _my_private()
	for card in priv.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(card, bool(card["playable"]))
		var idx := int(card["index"])
		cv.tapped.connect(func() -> void:
			if bool(card.get("timed", false)):
				cv.start_timing(int(card.get("timed_hits", 1)))
			else:
				Sfx.play("card")
				_client.play_card(idx, true, _cmd_slot()))
		cv.timing_resolved.connect(func(hit: bool) -> void:
			Sfx.play("nail" if hit else "slip")
			_client.play_card(idx, hit, _cmd_slot()))
	var players: Array = _client.shared.get("players", [])
	var me: Dictionary = players[_me()] if _me() < players.size() else {}
	_status.text = "%s   ✦%d   Height %d" % [String(me.get("name", "")),
		int(me.get("energy", 0)), int(me.get("foothold", 0))]
	_switch_btn.visible = _is_solo()
	_end_btn.disabled = bool(priv.get("ended", false))
