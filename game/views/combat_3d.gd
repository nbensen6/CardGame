## 3D combat view — the SAME authoritative snapshots, rendered in a 3D scene.
##
## This is CLAUDE.md §2's layering rule paying off: /core and /session don't know
## or care that the game became 3D. It began as a second client beside the 2D
## `combat_view.gd`, reading identical `shared`/`private` dicts; that one has
## since been retired, and this is the only fight screen.
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
	# every beast gets its OWN body — the map's variety is pointless if ten of
	# the fourteen fights look like the same elephant. Chosen to echo the 2D
	# portrait where a Cube Pet exists, and to never reuse a hunter's model.
	"stone_warden": "elephant", "gale_serpent": "caterpillar",
	"drowned_colossus": "polar", "sunken_warden": "lion",
	"crag_pup": "dog", "bramble_hog": "pig", "bounder": "fox",
	"root_lurker": "beaver", "sky_snapper": "parrot", "riftling": "cat",
	"mire_snapper": "crab", "frost_sentinel": "penguin",
	"grove_bear": "panda", "shifting_idol": "tiger",
}
## Models are sized to a TARGET WORLD HEIGHT, measured off each mesh, never by a
## fixed multiplier. Two reasons. The Cube Pets already vary 1.55-2.13 units
## tall, so one multiplier made the two hunters differ by ~24% for no reason.
## And it means a model built in Blender at any scale drops straight in — the
## art pipeline shouldn't require matching someone else's units.
##
## A beast's height comes from how far you climb it, so a Titan with its sigil at
## Height 8 physically towers over a Crag Pup you can hit from the ground.
const BEAST_BASE_HEIGHT := 2.6
const BEAST_HEIGHT_PER_CLIMB := 0.28
## Real-time grip (SotC), the same client-side skill layer the 2D view runs: the
## instant a hunter leaves a safe hold a timer starts full and drains live; reach
## the next ledge before it empties or this client reports a fall. The host is
## told the OUTCOME, never the ticking timer.
const GRIP_SECONDS := 5.0
const HUNTER_HEIGHT := 0.8
## Orbit camera (Nick's call, 2026-08-05). The beast is a PLACE, so you can walk
## the camera around it. Auto-framing still sets the opening shot off the model's
## own size; dragging only takes over from there, and never below the ground or
## over the top.
const ORBIT_PITCH_MIN := -0.12   # radians below level — never under the floor
const ORBIT_PITCH_MAX := 1.05    # nearly overhead, but never gimbal-locked
const ORBIT_SENSITIVITY := 0.006
const ZOOM_STEP := 0.12

var _client: GameClient
var _beast: Node3D
var _beast_id := ""
var _beast_box := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
var _beast_scale := 1.0
var _beast_height := 0.0
var _hunters: Array = []          # slot -> {node, home}
var _active_slot := 0

# --- feel state ---
var _shake := 0.0                 # camera shake energy, decays each frame
var _cam_home := Vector3.ZERO
# --- orbit state ---
var _yaw := 0.0
var _pitch := 0.26
var _dist := 12.0
var _pivot := Vector3(0, 2.0, 0)
var _dragging := false
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
# Card selection (Burn Coal / Catapult / Meld): tapping a selection card starts a
# local pick flow, and the chosen hand indices are bundled into ONE play_card.
# Empty = idle. Without this, those cards simply can't be played.
var _selecting: Dictionary = {}
var _coach_id := ""   # the onboarding hint currently on screen
var _log_expanded := false

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
@onready var _party: VBoxContainer = %Party
@onready var _run_label: Label = %RunLabel
@onready var _coach: PanelContainer = %Coach
@onready var _coach_text: Label = %CoachText
@onready var _coach_ok: Button = %CoachOk
@onready var _log_label: Label = %LogLabel
@onready var _log_toggle: Button = %LogToggle
@onready var _log_panel: PanelContainer = %LogPanel


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
	_log_toggle.pressed.connect(func() -> void:
		_log_expanded = not _log_expanded
		_refresh())
	_coach_ok.pressed.connect(func() -> void:
		if _coach_id != "":
			Progress.mark_hint_seen(_coach_id)   # taught once, never again
			_coach_id = ""
		_coach.visible = false)
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
		_beast.scale = Vector3.ONE * _beast_scale * breathe * recoil
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
		_cam.look_at(_pivot, Vector3.UP)
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
		_selecting = {}
		_coach.visible = false
		return
	_hud.visible = true
	var boss: Dictionary = s["boss"]
	_title.text = String(boss["name"])
	_hp.text = "%d / %d" % [int(boss["hp"]), int(boss["max_hp"])]
	_hp_bar.max_value = int(boss["max_hp"])
	_hp_bar.value = int(boss["hp"])
	_intent.text = _intent_text(boss)
	_show_beast(String(boss.get("id", "")), String(boss["name"]),
		int(boss.get("weak_point_height", 0)))
	_place_sigil(s)
	_place_hunters(s)
	_update_climb_state(s)
	_render_party(s, int(boss.get("target", -1)), String(boss.get("intent", {}).get("type", "")))
	_update_coach(s)
	_render_log(s)
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

func _show_beast(beast_id: String, beast_name: String, weak_point: int) -> void:
	var key := _model_key(beast_id, beast_name)
	var want := BEAST_BASE_HEIGHT + BEAST_HEIGHT_PER_CLIMB * float(weak_point)
	if key == _beast_id and is_instance_valid(_beast) 			and is_equal_approx(want, _beast_height):
		return
	_beast_id = key
	_beast_height = want
	if _beast != null:
		_beast.queue_free()
	var path := CAST + key + ".glb"
	if not ResourceLoader.exists(path):
		return
	_beast = (load(path) as PackedScene).instantiate()
	_rig.add_child(_beast)
	_beast_scale = _fit_height(_beast, want)
	_beast_box = _merged_aabb(_beast)
	_frame_beast()


## Scale a freshly added model so it stands `want` units tall, and report the
## factor used. Measured, so it holds for any mesh from any source.
func _fit_height(node: Node3D, want: float) -> float:
	var raw := _merged_aabb(node).size.y
	var factor: float = want / maxf(raw, 0.001)
	node.scale = Vector3.ONE * factor
	return factor


## Pull the camera back to fit whatever we're fighting. Beasts now range from a
## Crag Pup to a Titan nearly twice its height, so a fixed camera either crops
## the big ones or strands the small ones in empty sky.
func _frame_beast() -> void:
	var tall := maxf(_beast_box.size.y, 1.0)
	_dist = clampf(tall * 2.15 + 3.2, 9.5, 22.0)
	# aim at the body's middle: high enough that the beast clears the top HUD,
	# low enough that hunters standing on the GROUND stay above the card hand
	_pivot = Vector3(0.0, tall * 0.46, 0.0)
	_yaw = 0.0          # a new beast is always introduced from the front
	_pitch = 0.26
	_apply_orbit()


## Spherical position around the beast. Everything else (shake, the strike flash)
## composes on top of _cam_home, so the orbit is the only thing that decides
## where the camera fundamentally is.
func _apply_orbit() -> void:
	_pitch = clampf(_pitch, ORBIT_PITCH_MIN, ORBIT_PITCH_MAX)
	var flat := cos(_pitch) * _dist
	_cam_home = _pivot + Vector3(sin(_yaw) * flat, sin(_pitch) * _dist, cos(_yaw) * flat)
	_cam.position = _cam_home
	_cam.look_at(_pivot, Vector3.UP)


## Drag anywhere the HUD didn't already claim. Cards and buttons are Controls, so
## they consume their own clicks before this ever runs — the hand and the camera
## never fight over the same drag.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = mb.pressed
			MOUSE_BUTTON_WHEEL_UP:
				_dist = maxf(_dist * (1.0 - ZOOM_STEP), 4.0)
				_apply_orbit()
			MOUSE_BUTTON_WHEEL_DOWN:
				_dist = minf(_dist * (1.0 + ZOOM_STEP), 34.0)
				_apply_orbit()
	elif event is InputEventMouseMotion and _dragging:
		var mm: InputEventMouseMotion = event
		_yaw -= mm.relative.x * ORBIT_SENSITIVITY
		_pitch += mm.relative.y * ORBIT_SENSITIVITY
		_apply_orbit()


## The beast's data id picks its model. The old guess read the portrait PATH,
## which cannot work — several beasts share one portrait (two use crocodile.png),
## so half the roster resolved to the wrong body or fell back to the elephant.
## The name is kept only as a fallback for a beast added without a mapping.
func _model_key(beast_id: String, beast_name: String) -> String:
	if MODELS.has(beast_id):
		return String(MODELS[beast_id])
	var lower := beast_name.to_lower()
	for id in MODELS:
		if lower.contains(String(id).replace("_", " ")):
			return String(MODELS[id])
	push_warning("combat_3d: no model for beast '%s' — falling back" % beast_id)
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
		holder.add_child(m)
		_fit_height(m, HUNTER_HEIGHT)
	holder.add_child(_hunter_pip(slot))
	return {"node": holder, "home": Vector3.ZERO}


## Orbiting means a hunter can end up behind the beast's body. A pip that draws
## THROUGH the beast keeps both of them findable from any angle — otherwise the
## camera freedom costs you the one thing you always need to know.
func _hunter_pip(slot: int) -> Node3D:
	var pip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.12
	cone.height = 0.22
	cone.radial_segments = 8
	pip.mesh = cone
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.95, 0.5) if slot == 0 else Color(0.55, 0.82, 1.0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.render_priority = 2
	pip.material_override = mat
	pip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pip.rotation.z = PI  # point down at the hunter it marks
	pip.position = Vector3(0, 0.72, 0)
	return pip


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
	var selecting := not _selecting.is_empty()
	for card in priv.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		var idx := int(card["index"])
		# while picking, EVERY card is tappable — the pick is the point — except
		# the ones already spoken for
		var playable: bool = bool(card["playable"])
		if selecting:
			playable = idx != int(_selecting.get("sac", -1))
		cv.setup(card, playable)
		var c_card: Dictionary = card
		cv.tapped.connect(func() -> void: _on_card_tapped(c_card, cv))
		cv.timing_resolved.connect(func(hit: bool) -> void:
			Sfx.play("nail" if hit else "slip")
			_client.play_card(idx, hit, _cmd_slot()))
	var players: Array = _client.shared.get("players", [])
	var me: Dictionary = players[_me()] if _me() < players.size() else {}
	if selecting:
		_status.text = _selection_prompt()
		_switch_btn.visible = _is_solo()
		_end_btn.disabled = bool(priv.get("ended", false))
		return
	var climb := ""
	if bool(me.get("reached", false)):
		climb = "   ✦ at the weak point"
	elif not bool(me.get("secure", true)):
		climb = "   ⚠ climbing"
	_status.text = "%s   ✦%d   HP %d%s" % [String(me.get("name", "")),
		int(me.get("energy", 0)), int(me.get("hp", 0)), climb]
	_switch_btn.visible = _is_solo()
	_end_btn.disabled = bool(priv.get("ended", false))


# --- playing a card, including the multi-pick cards -----------------------

func _on_card_tapped(card: Dictionary, cv: CardView) -> void:
	var index := int(card["index"])
	if not _selecting.is_empty():  # this tap is a pick for the active card
		_pick_for_selection(index)
		return
	if bool(card.get("timed", false)):
		# a relic can widen the window, so pass the team's bonus through
		cv.zone_bonus = float(int(_client.shared.get("mods", {}).get("timing_zone", 0))) / 100.0
		cv.start_timing(int(card.get("timed_hits", 1)))
		return
	if bool(card.get("exhaust_pick", false)) or bool(card.get("cheapen_pick", false)) 			or bool(card.get("meld", false)):
		_start_selection(card)
		return
	Sfx.play("card")
	_client.play_card(index, true, _cmd_slot())


func _selection_prompt() -> String:
	var mode := String(_selecting.get("mode", "exhaust"))
	var step := int(_selecting.get("step", 0))
	var nm := String(_selecting.get("name", "card"))
	var cancel := "   (tap %s again to cancel)" % nm
	match mode:
		"meld":
			return "%s — tap the %s card to meld%s" % [nm, "FIRST" if step == 0 else "SECOND", cancel]
		"exhaust_cheapen":
			if step == 0:
				return "%s — tap a card to SACRIFICE%s" % [nm, cancel]
			return "%s — tap a card to make CHEAPER" % nm
		_:
			return "%s — tap a card to SACRIFICE%s" % [nm, cancel]


func _start_selection(card: Dictionary) -> void:
	var mode := "exhaust"
	var picks := 1
	if bool(card.get("meld", false)):
		mode = "meld"
		picks = 2
	elif bool(card.get("cheapen_pick", false)):
		mode = "exhaust_cheapen"
		picks = 2
	_selecting = {"play_index": int(card["index"]), "name": String(card.get("name", "card")),
		"mode": mode, "picks": picks, "step": 0, "sac": -1, "target": -1}
	Sfx.play("card")
	_render_hand()


func _pick_for_selection(idx: int) -> void:
	if idx == int(_selecting.get("play_index", -1)):
		_selecting = {}  # tapped the selection card again — cancel
		_render_hand()
		return
	if int(_selecting.get("step", 0)) == 0:
		_selecting["sac"] = idx
	elif idx == int(_selecting.get("sac", -1)):
		return  # the two picks must be different cards
	else:
		_selecting["target"] = idx
	_selecting["step"] = int(_selecting.get("step", 0)) + 1
	if int(_selecting["step"]) >= int(_selecting.get("picks", 1)):  # all picks in — fire
		var play_index := int(_selecting.get("play_index", -1))
		var sac := int(_selecting.get("sac", -1))
		var target := int(_selecting.get("target", -1))
		_selecting = {}
		Sfx.play("card")
		_client.play_card(play_index, true, _cmd_slot(), sac, target)
	else:
		_render_hand()


# --- the party and the run's standing ------------------------------------

## Co-op means your ally's state is not optional information: HP, block,
## Energy, how high they've climbed, whether they're hanging, and whether the
## beast is about to hit them. The 3D scene shows WHERE they are; this says how
## they're doing.
func _render_party(s: Dictionary, boss_target: int, move_type: String) -> void:
	for c in _party.get_children():
		c.queue_free()
	var players: Array = s.get("players", [])
	var sweeps: bool = move_type in ["attack_all", "swipe_high", "swipe_low"]
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var aimed: bool = sweeps or i == boss_target
		_party.add_child(_party_card(p, i, aimed))
	var bits: Array = ["Gold %d" % int(s.get("gold", 0))]
	var relics: Array = s.get("relics", [])
	if not relics.is_empty():
		bits.append(", ".join(relics))
	_run_label.text = "  •  ".join(bits)


func _party_card(p: Dictionary, slot: int, aimed: bool) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.1, 0.08, 0.8)
	style.set_border_width_all(2 if slot == _me() else 1)
	# the hunter in the beast's sights is outlined in red — the single most
	# time-critical fact on the screen
	style.border_color = Color(0.85, 0.32, 0.26) if aimed 		else (Color(0.85, 0.68, 0.4) if slot == _me() else Color(0.45, 0.33, 0.23))
	style.set_corner_radius_all(5)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	var who := Label.new()
	who.text = "%s%s" % [String(p.get("name", "")), "  (you)" if slot == _me() else ""]
	who.add_theme_font_size_override("font_size", 13)
	who.add_theme_color_override("font_color", Color(1, 0.93, 0.78))
	box.add_child(who)
	var bar := ProgressBar.new()
	bar.max_value = maxi(int(p.get("max_hp", 1)), 1)
	bar.value = int(p.get("hp", 0))
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 12)
	box.add_child(bar)
	var stats := Label.new()
	var parts: Array = ["HP %d/%d" % [int(p.get("hp", 0)), int(p.get("max_hp", 0))]]
	if int(p.get("block", 0)) > 0:
		parts.append("◈%d" % int(p.get("block", 0)))
	parts.append("✦%d" % int(p.get("energy", 0)))
	parts.append("↑%d" % int(p.get("foothold", 0)))
	if bool(p.get("reached", false)):
		parts.append("at the sigil")
	elif not bool(p.get("secure", true)):
		parts.append("hanging!")
	if bool(p.get("ended", false)):
		parts.append("done")
	stats.text = "   ".join(parts)
	stats.add_theme_font_size_override("font_size", 12)
	stats.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	box.add_child(stats)
	return panel


## Contextual onboarding, shared with the 2D client: the rule that matters right
## now announces itself once, then never again. The armoured-hide gate is the
## one that most needs saying — without it, hitting a beast from the ground
## reads as the cards being broken rather than as the climb being the point.
func _update_coach(s: Dictionary) -> void:
	var hint := Coach.hint_for(s, _my_private(), _me())
	if hint.is_empty():
		_coach_id = ""
		_coach.visible = false
		return
	_coach_id = String(hint["id"])
	_coach_text.text = String(hint["text"])
	_coach.visible = true


## What just happened, in words. The 3D scene shows the blow landing but not
## WHY it was small — the armoured-hide flag that explains a chipped hit only
## exists here, which is exactly the confusion the log was added to fix.
func _render_log(s: Dictionary) -> void:
	var entries: Array = s.get("log", [])
	var n := 16 if _log_expanded else 4
	_log_label.text = "
".join(entries.slice(maxi(entries.size() - n, 0)))
	_log_panel.visible = not entries.is_empty()  # no empty box before round 1
	_log_toggle.text = "Log ▾" if _log_expanded else "Log ▸"
