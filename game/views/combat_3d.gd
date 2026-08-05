## 3D combat view — the SAME authoritative snapshots, rendered in a 3D scene.
##
## This is CLAUDE.md §2's layering rule paying off: /core and /session don't know
## or care that the game became 3D. This is a second client alongside
## views/combat_view.gd, reading identical `shared`/`private` dicts.
##
## The climb stops being an abstraction here — Height IS vertical position on the
## beast's body, so a hunter at the weak point is literally up at the weak point.
##
## The models are static low-poly props, so everything that moves is procedural:
## breathing, idle sway, climb hops, recoil, flashes, camera shake. That reads far
## better than static toys and costs no animation budget.
extends Node3D

const CAST := "res://assets/3d/cast/"
## Which model plays each character / beast, until real art exists.
const MODELS := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey",
	"stone_warden": "elephant", "gale_serpent": "tiger",
	"drowned_colossus": "polar", "sunken_warden": "lion",
}
const BEAST_SCALE := 2.6
## Real-time grip (SotC), the same client-side skill layer the 2D view runs: the
## instant a hunter leaves a safe hold a timer starts full and drains live; reach
## the next ledge before it empties or this client reports a fall. The host is
## told the OUTCOME, never the ticking timer.
const GRIP_SECONDS := 5.0
const HUNTER_SCALE := 0.42

var _client: GameClient
var _beast: Node3D
var _beast_id := ""
var _beast_box := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
var _hunters: Array = []          # slot -> {node, home}
var _active_slot := 0

# --- feel state ---
var _shake := 0.0                 # camera shake energy, decays each frame
var _cam_home := Vector3.ZERO
var _beast_punch := 0.0           # recoil when the beast is struck
var _time := 0.0
# snapshot deltas drive the juice, exactly like the 2D view
var _prev_hp := -1
var _prev_foot: Array = []
var _prev_reached: Array = []
var _prev_encounter := -1
# slot -> {g: remaining 0..1, target: the Height that ends the climb}. Solo
# tracks BOTH hunters, since you can switch while a timer runs.
var _climb: Dictionary = {}

@onready var _rig: Node3D = %BeastRig
@onready var _cam: Camera3D = %Camera
@onready var _flash: OmniLight3D = %Flash
@onready var _dust: CPUParticles3D = %Dust
@onready var _sigil: Node3D = %Sigil
@onready var _hud: Control = %Root
@onready var _title: Label = %Title
@onready var _hp: Label = %HpLabel
@onready var _hp_bar: ProgressBar = %HpBar
@onready var _intent: Label = %Intent
@onready var _hand_row: HBoxContainer = %Hand
@onready var _status: Label = %StatusLabel
@onready var _end_btn: Button = %EndTurn
@onready var _switch_btn: Button = %SwitchBtn
@onready var _grip_bar: PanelContainer = %GripBar
@onready var _grip_label: Label = %GripLabel
@onready var _grip_meter: ProgressBar = %GripMeter


func _ready() -> void:
	_cam_home = _cam.position
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


# --- solo helpers ---------------------------------------------------------

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


# --- per-frame feel -------------------------------------------------------

## Everything alive in the scene is driven from here: the beast breathes, the
## hunters sway, and any shake or recoil decays back to rest.
func _process(delta: float) -> void:
	_time += delta
	if _beast != null:
		var breathe := 1.0 + sin(_time * 1.6) * 0.02
		var recoil := 1.0 - _beast_punch * 0.10
		_beast.scale = Vector3.ONE * BEAST_SCALE * breathe * recoil
		_beast.position.z = -_beast_punch * 0.35
	_beast_punch = maxf(0.0, _beast_punch - delta * 3.5)
	for i in range(_hunters.size()):
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		if is_instance_valid(node):
			# a gentle out-of-phase idle so the two hunters don't look cloned
			node.position.y = float((h["home"] as Vector3).y) + sin(_time * 2.3 + i * 1.7) * 0.045
	if _sigil != null and _sigil.visible:
		_sigil.scale = Vector3.ONE * (1.0 + sin(_time * 3.0) * 0.14)
	if _shake > 0.001:
		_shake = maxf(0.0, _shake - delta * 2.6)
		var amp := _shake * 0.42
		_cam.position = _cam_home + Vector3(
			randf_range(-amp, amp), randf_range(-amp, amp), randf_range(-amp, amp) * 0.4)
	elif _cam.position != _cam_home:
		_cam.position = _cam_home
	if _flash != null:
		_flash.light_energy = maxf(0.0, _flash.light_energy - delta * 9.0)
	_tick_grip(delta)


## How long the party can cling, including any grip relics.
func _grip_seconds() -> float:
	return GRIP_SECONDS + float(int(_client.shared.get("mods", {}).get("grip_seconds", 0)))


## Every climbing hunter's timer ticks, whoever is active. An empty timer is a
## fall — and in 3D that is worth SEEING, so a slipping hunter shakes harder the
## closer they are to letting go.
func _tick_grip(delta: float) -> void:
	if _climb.is_empty():
		return
	for slot in _climb.keys().duplicate():
		var st: Dictionary = _climb[slot]
		st["g"] = float(st["g"]) - delta / _grip_seconds()
		if float(st["g"]) <= 0.0:
			_climb.erase(slot)
			Sfx.play("shake")
			_client.fall(int(slot) if _is_solo() else -1)
			continue
		var i := int(slot)
		if i < _hunters.size():
			var node: Node3D = (_hunters[i] as Dictionary)["node"]
			if is_instance_valid(node):
				# steady at full grip, scrabbling as it runs out
				var slip: float = 1.0 - clampf(float(st["g"]), 0.0, 1.0)
				var amp: float = slip * slip * 0.075
				node.position.x = float(((_hunters[i] as Dictionary)["home"] as Vector3).x) 					+ sin(_time * 34.0 + i) * amp
	_update_grip_bar()


## Derive climb bursts from the "secure" flags: leaving a hold starts that
## hunter's timer full, reaching one (or falling) ends it. Grip only resets on a
## genuine hold -> climbing transition, so it drains continuously across a hop.
func _update_climb_state(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var slots: Array = [0, 1] if _is_solo() else [_client.you]
	for slot in slots:
		if slot < 0 or slot >= players.size():
			continue
		var p: Dictionary = players[slot]
		if bool(p.get("secure", true)):
			_climb.erase(slot)
		else:
			if not _climb.has(slot):
				_climb[slot] = {"g": 1.0}
			_climb[slot]["target"] = int(p.get("next_safe", int(p.get("foothold", 0))))
	_update_grip_bar()


## Show the ACTIVE hunter's grip if they're climbing, else any other climbing
## hunter's (named), so a ticking ally timer is never invisible after a switch.
func _update_grip_bar() -> void:
	if _grip_bar == null:
		return
	_grip_bar.visible = not _climb.is_empty()
	if _climb.is_empty():
		return
	var slot: int = _me() if _climb.has(_me()) else int(_climb.keys()[0])
	var st: Dictionary = _climb[slot]
	var g := clampf(float(st["g"]), 0.0, 1.0)
	_grip_meter.value = g
	_grip_meter.modulate = Color(0.9, 0.33, 0.28).lerp(Color(0.55, 0.85, 0.5), g)
	var who := "" if slot == _me() else "%s — " % _hunter_name(slot)
	var extra := "   (both hunters climbing!)" if _climb.size() > 1 else ""
	_grip_label.text = "⚠ %sHOLD ON — reach Height %d before your grip gives out!%s" % [
		who, int(st.get("target", 0)), extra]


func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	if slot < 0 or slot >= players.size():
		return "Hunter %d" % (slot + 1)
	return String((players[slot] as Dictionary).get("name", "Hunter %d" % (slot + 1)))


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty() or String(s.get("phase", "")) != "combat":
		_hud.visible = false
		_climb.clear()
		return
	_hud.visible = true
	var boss: Dictionary = s["boss"]
	_title.text = String(boss["name"])
	_hp.text = "%d / %d" % [int(boss["hp"]), int(boss["max_hp"])]
	_hp_bar.max_value = int(boss["max_hp"])
	_hp_bar.value = int(boss["hp"])
	_intent.text = _intent_text(boss)
	_show_beast(String(boss.get("art", "")), String(boss["name"]))
	_place_sigil(s)
	_place_hunters(s)
	_update_climb_state(s)
	_react(s)
	_render_hand()


func _intent_text(boss: Dictionary) -> String:
	var move: Dictionary = boss.get("intent", {})
	var v := int(move.get("value", 0)) + int(boss.get("strength", 0))
	match String(move.get("type", "")):
		"attack": return "⚔ Attack %d" % v
		"attack_all": return "⚔ Sweep %d" % v
		"swipe_high": return "⚔ Lash the flank %d" % v
		"swipe_low": return "⚔ Stamp %d" % v
		"rift": return "⚔ Wrench apart %d+" % v
		"leech": return "⚔ Drain %d" % v
		"block": return "◆ Defend"
		"enrage": return "▲ Enrage"
		"regen": return "✚ Recover"
		"shift_sigil": return "✦ Shift its sigil"
	return ""


# --- the beast ------------------------------------------------------------

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
	_beast_box = _merged_aabb(_beast)


## The 2D build identified beasts by portrait path; reuse that to pick a model.
func _model_key(art: String, beast_name: String) -> String:
	var stem := art.get_file().get_basename()
	for id in MODELS:
		if stem == String(MODELS[id]) or stem == id:
			return String(MODELS[id])
	var lower := beast_name.to_lower()
	for id2 in MODELS:
		if lower.contains(String(id2).replace("_", " ")):
			return String(MODELS[id2])
	return "elephant"


## World-space bounds of a model, so hunters can be placed ON it whatever its
## shape — no per-beast hand-tuning.
func _merged_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for node in _all_meshes(root):
		var vi := node as VisualInstance3D
		var box: AABB = vi.global_transform * vi.get_aabb()
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	if first:
		return AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	return out


func _all_meshes(node: Node) -> Array:
	var out: Array = []
	if node is VisualInstance3D:
		out.append(node)
	for c in node.get_children():
		out.append_array(_all_meshes(c))
	return out


# --- hunters --------------------------------------------------------------

## Height becomes literal: on the ground they stand in front of the beast; as
## they climb they move UP its flank, hugging the model's actual bounds.
func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var boss: Dictionary = s.get("boss", {})
	var height: int = maxi(int(boss.get("weak_point_height", 1)), 1)
	while _hunters.size() < players.size():
		_hunters.append(_spawn_hunter(_hunters.size(), players))
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var t: float = clampf(float(int(p.get("foothold", 0))) / float(height), 0.0, 1.0)
		var side: float = -1.0 if i == 0 else 1.0
		var pos: Vector3
		if t <= 0.01:
			# flanking it on the ground — out to the sides, not in front, so the
			# card hand can't swallow them at the bottom of the frame
			pos = Vector3(side * (_beast_box.size.x * 0.5 + 1.4), 0.0,
				_beast_box.end.z * 0.4)
		elif t >= 0.92:
			# at the weak point — stand ON the sigil, the thing the climb was for
			pos = _sigil.position + Vector3(side * 0.42, -0.12, 0.15)
		else:
			var y := _beast_box.position.y + _beast_box.size.y * lerpf(0.18, 0.80, t)
			var x := side * (_beast_box.size.x * 0.30)
			pos = Vector3(x, y, _beast_box.get_center().z + _beast_box.size.z * 0.38)
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		var moved: bool = (h["home"] as Vector3).distance_to(pos) > 0.05
		h["home"] = pos
		if moved:
			create_tween().tween_property(node, "position", pos, 0.28) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			node.position = pos
		# ground hunters stand three-quarter on, turned in toward the beast
		node.rotation.y = (PI + 0.7 * side) if t <= 0.01 else (PI * 0.5 * -side)


func _spawn_hunter(slot: int, players: Array) -> Dictionary:
	var key := "bunny"
	var stem := String((players[slot] as Dictionary).get("portrait", "")).get_file().get_basename()
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
	return {"node": holder, "home": Vector3.ZERO}


## The weak point sits atop the beast and pulses, so the target of the whole
## climb is a place you can see rather than a number.
func _place_sigil(s: Dictionary) -> void:
	var boss: Dictionary = s.get("boss", {})
	var on: bool = int(boss.get("weak_point_height", 0)) > 0
	_sigil.visible = on
	if not on:
		return
	_sigil.position = Vector3(_beast_box.get_center().x,
		_beast_box.position.y + _beast_box.size.y * 0.88,
		_beast_box.get_center().z + _beast_box.size.z * 0.25)


# --- reactions (the same snapshot deltas the 2D view uses) ----------------

func _react(s: Dictionary) -> void:
	var boss: Dictionary = s["boss"]
	var players: Array = s["players"]
	var enc := int(s.get("encounter", 0))
	var hp := int(boss.get("hp", 0))
	var foots: Array = []
	var reached: Array = []
	for p in players:
		foots.append(int(p.get("foothold", 0)))
		reached.append(bool(p.get("reached", false)))
	if enc != _prev_encounter or _prev_foot.size() != foots.size():
		_sync(enc, hp, foots, reached)
		return
	if hp < _prev_hp:
		_strike(reached.has(true) or _prev_reached.has(true))
	for i in range(foots.size()):
		if not _prev_reached[i] and reached[i]:
			Sfx.play("reach_sigil")
		elif foots[i] > _prev_foot[i]:
			Sfx.play("climb")
		elif foots[i] < _prev_foot[i]:
			_beast_shake()
	_sync(enc, hp, foots, reached)


func _sync(enc: int, hp: int, foots: Array, reached: Array) -> void:
	_prev_encounter = enc
	_prev_hp = hp
	_prev_foot = foots
	_prev_reached = reached


## A hit on the beast: recoil, a flash of light, a kick of camera shake — much
## bigger when it lands on the weak point.
func _strike(weak_point: bool) -> void:
	Sfx.play("strike_weakpoint" if weak_point else "attack")
	_beast_punch = 1.0 if weak_point else 0.45
	_shake = maxf(_shake, 0.85 if weak_point else 0.3)
	_flash.position = _sigil.position if weak_point else _beast_box.get_center()
	_flash.light_energy = 7.0 if weak_point else 2.5
	if weak_point:
		_dust.position = _sigil.position
		_dust.restart()


## The beast bucks: a heavy jolt and dust off its hide.
func _beast_shake() -> void:
	Sfx.play("shake")
	_shake = maxf(_shake, 1.0)
	_beast_punch = 0.6
	_dust.position = _beast_box.get_center()
	_dust.restart()


# --- hand -----------------------------------------------------------------

func _render_hand() -> void:
	for c in _hand_row.get_children():
		c.queue_free()
	var priv := _my_private()
	for card in priv.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(card, bool(card["playable"]))
		var idx := int(card["index"])
		var timed := bool(card.get("timed", false))
		var hits := int(card.get("timed_hits", 1))
		cv.tapped.connect(func() -> void:
			if timed:
				cv.start_timing(hits)
			else:
				Sfx.play("card")
				_client.play_card(idx, true, _cmd_slot()))
		cv.timing_resolved.connect(func(hit: bool) -> void:
			Sfx.play("nail" if hit else "slip")
			_client.play_card(idx, hit, _cmd_slot()))
	var players: Array = _client.shared.get("players", [])
	var me: Dictionary = players[_me()] if _me() < players.size() else {}
	var climb := ""
	if bool(me.get("reached", false)):
		climb = "   ✦ at the weak point"
	elif not bool(me.get("secure", true)):
		climb = "   ⚠ climbing"
	_status.text = "%s   ✦%d   HP %d%s" % [String(me.get("name", "")),
		int(me.get("energy", 0)), int(me.get("hp", 0)), climb]
	_switch_btn.visible = _is_solo()
	_end_btn.disabled = bool(priv.get("ended", false))
