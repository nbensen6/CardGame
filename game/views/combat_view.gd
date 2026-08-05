## Co-op run view — a pure CLIENT of the authoritative host (CLAUDE.md §2, §8).
## Renders snapshot Dictionaries and sends intents through GameClient; holds NO
## game rules and never touches /core types. Handles the run's phases:
##   waiting -> combat (fight a Titan) -> reward (pick a card) -> ... -> won/lost.
##
## Mobile-ready (CLAUDE.md §5): single-pointer taps only; each card shows cost +
## text on its face; the Titan's intent (and WHO it targets) is always visible;
## anchor-based, scalable layout.
extends Control

var _client: GameClient

@onready var _top_bar: PanelContainer = %TopBar
@onready var _boss_name: Label = %BossName
@onready var _boss_hp: Label = %BossHP
@onready var _boss_hp_bar: ProgressBar = %BossHPBar
@onready var _intent: HBoxContainer = %Intent
@onready var _players_row: VBoxContainer = %Players
@onready var _scene_row: HBoxContainer = %Scene
@onready var _map_panel: PanelContainer = %MapPanel
@onready var _map_rows: VBoxContainer = %MapRows
@onready var _hand_bar: HBoxContainer = %HandBar
@onready var _arena: Control = %Arena
@onready var _climb_layer: Control = %Climb
@onready var _boss_art: TextureRect = %BossArt
@onready var _log_label: Label = %Log
@onready var _log_toggle: Button = %LogToggle
@onready var _hand_label: Label = %HandLabel
@onready var _hand_icon: TextureRect = %HandIcon
@onready var _hand_row: HBoxContainer = %Hand
@onready var _grip_bar: PanelContainer = %GripBar
@onready var _grip_label: Label = %GripLabel
@onready var _grip_meter: ProgressBar = %GripMeter
@onready var _end_turn_btn: Button = %EndTurn
@onready var _lock_btn: Button = %LockButton
@onready var _switch_btn: Button = %SwitchButton
@onready var _overlay: Control = %Overlay
@onready var _result_label: Label = %ResultLabel
@onready var _restart_btn: Button = %RestartButton
@onready var _menu_btn: Button = %MenuButton

var _server_lost := false
var _selected_choice := -1   # reward highlighted but NOT yet locked
var _selected_char := ""     # character highlighted in the lobby but NOT yet locked
var _prev_phase := ""
var _active_slot := 0        # solo: which hunter the player is currently controlling
var _over_sound := false     # win/lose sting plays once
# Climb-loop audio: fired from snapshot-to-snapshot deltas (the view is a pure
# client, so it infers "climbed / reached / bucked off / struck the sigil" by
# comparing successive states rather than being told).
var _prev_encounter := -1
var _prev_boss_hp := -1
var _prev_footholds: Array = []
var _prev_reached: Array = []
# Real-time grip (SotC): the instant the active hunter leaves a safe hold, a grip
# timer starts full and drains live; reach the next ledge/sigil before it empties
# or the client reports a fall. Purely client-side skill — the host is told the
# outcome (a play_card that reaches safety, or a `fall`), never the ticking timer.
const GRIP_SECONDS := 5.0     # how long you can cling between holds (tune by feel)
# Per-hunter grip timers: slot -> {g: remaining 0..1, target: Height to reach}.
# In solo BOTH hunters can be mid-climb at once (Nick: switch while the timer
# runs — hunter A keeps draining while you act with hunter B). In co-op each
# client only ever tracks its own hunter.
var _climb: Dictionary = {}
# Card selection (Burn Coal / Catapult): tapping a selection card starts a local
# pick flow; the chosen hand indices are bundled into one play_card. Empty = idle.
var _selecting: Dictionary = {}
var _log_expanded := false   # log ticker: collapsed = last 4 lines, expanded = last 16


# --- Solo helpers (one player controls both hunters) ----------------------

func _is_solo() -> bool:
	return bool(_client.shared.get("solo", false))

## The hunter this view currently represents (solo: the active one; co-op: you).
func _me() -> int:
	return _active_slot if _is_solo() else _client.you

## The slot a command targets: solo names it, co-op lets the host use the peer's.
func _cmd_slot() -> int:
	return _active_slot if _is_solo() else -1

## The private data for the hunter being controlled.
func _my_private() -> Dictionary:
	if _is_solo():
		var slots: Array = _client.private.get("slots", [])
		return slots[_active_slot] if _active_slot < slots.size() else {}
	return _client.private

func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	return String(players[slot]["name"]) if slot < players.size() else "Hunter %d" % (slot + 1)


func _ready() -> void:
	_end_turn_btn.pressed.connect(func() -> void:
		Sfx.play("end_turn")
		_client.end_turn(_cmd_slot())
		if _is_solo():  # hand control to the other hunter
			_active_slot = 1 - _active_slot
			_refresh())
	_switch_btn.pressed.connect(func() -> void:
		_active_slot = 1 - _active_slot
		_selected_choice = -1
		_selected_char = ""
		_refresh())
	_lock_btn.pressed.connect(_on_lock)
	_log_toggle.pressed.connect(func() -> void:
		_log_expanded = not _log_expanded
		_log_toggle.text = "Log ▾" if _log_expanded else "Log ▸"
		_refresh())
	_restart_btn.pressed.connect(func() -> void: _client.restart())
	_menu_btn.pressed.connect(_return_to_menu)
	Music.play("combat")
	_client = Session.client
	_client.state_updated.connect(_on_state)
	# Disconnect handling: the host going away (client side) drops us to the menu.
	if Session.transport != null:
		Session.transport.server_lost.connect(_on_server_lost)
	if not _client.shared.is_empty():
		_refresh()


func _on_server_lost() -> void:
	_server_lost = true
	_overlay.visible = true
	_restart_btn.visible = false
	_menu_btn.visible = true
	_result_label.text = "Disconnected from host.\nThe run has ended."


func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://views/menu.tscn")


func _on_state(_shared: Dictionary, _private: Dictionary) -> void:
	_refresh()


## Real-time grip drain — every climbing hunter's timer ticks, whoever is active.
## When a timer empties, tell the host that hunter fell.
func _process(delta: float) -> void:
	if _climb.is_empty():
		return
	for slot in _climb.keys().duplicate():
		var st: Dictionary = _climb[slot]
		st["g"] = float(st["g"]) - delta / GRIP_SECONDS
		if float(st["g"]) <= 0.0:
			_climb.erase(slot)
			Sfx.play("shake")
			_client.fall(int(slot) if _is_solo() else -1)
	_update_grip_bar()


## Derive climb bursts from the "secure" flags: leaving a hold starts that
## hunter's timer full; reaching one (or falling) ends it. Grip only resets on a
## genuine hold->climbing transition, so it drains continuously across a hop.
## Solo tracks BOTH hunters; co-op only your own.
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


func _stop_climb() -> void:
	_climb.clear()
	_selecting = {}  # any in-progress card pick is abandoned when we leave combat
	if _grip_bar != null:
		_grip_bar.visible = false


## Show the ACTIVE hunter's grip if they're climbing; else any other climbing
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


func _refresh() -> void:
	if _server_lost:
		return  # keep the disconnect overlay
	var s := _client.shared
	if s.is_empty():
		return
	# Reset the (unlocked) reward selection when a fresh reward phase begins.
	var cur_phase := String(s.get("phase", "combat"))
	if cur_phase == "reward" and _prev_phase != "reward":
		_selected_choice = -1
	_prev_phase = cur_phase
	if bool(s.get("paused", false)):
		_show_paused(s)
		return
	if bool(s.get("waiting", false)):
		if String(s.get("phase", "")) == "select":
			_render_character_select(s)
		else:
			_show_waiting(s)
		return
	match String(s.get("phase", "combat")):
		"map":
			_render_map(s)
		"combat":
			_render_combat(s)
		"reward":
			_render_reward(s)
		_:  # "won" / "lost"
			_render_over(s)


# --- Combat phase ---------------------------------------------------------

func _render_combat(s: Dictionary) -> void:
	_show_map(false)
	_over_sound = false  # reset so the next win/lose plays its sting
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = true
	_intent.visible = true
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = true
	_lock_btn.visible = false

	var boss: Dictionary = s["boss"]
	_boss_name.text = "%s   ·   Titan %d / %d" % [boss["name"], s["encounter"], s["total_encounters"]]
	_boss_hp.text = "%d / %d%s" % [boss["hp"], boss["max_hp"], _titan_tags(boss)]
	_boss_hp_bar.max_value = boss["max_hp"]
	_boss_hp_bar.value = boss["hp"]
	_boss_hp_bar.add_theme_stylebox_override("fill",
		_bar_fill(float(boss["hp"]) / maxf(1.0, float(boss["max_hp"]))))
	_boss_hp_bar.modulate = Color(1, 1, 1, 1)

	var move: Dictionary = boss["intent"]
	var mtype := String(move.get("type", ""))
	var targeted := _targeted_indices(mtype, int(boss.get("target", -1)), s["players"].size())
	_render_intent(s, boss, move, mtype, targeted)

	_combat_audio(s)
	_update_climb_state(s)
	_log_toggle.visible = true
	_show_boss_art(String(boss.get("art", "")), int(boss.get("strength", 0)) > 0)
	_build_climb_arena(s)
	_render_players(s, targeted)
	_log_label.text = _log_tail(s)
	_render_hand()


## Emit climb-loop sounds by diffing this combat snapshot against the last one.
## A fresh fight (new Titan, or the very first snapshot) syncs silently so we
## never mistake an encounter reset for a climb or a buck-off.
func _combat_audio(s: Dictionary) -> void:
	var boss: Dictionary = s["boss"]
	var players: Array = s["players"]
	var enc := int(s.get("encounter", 0))
	var hp := int(boss.get("hp", 0))
	var foots: Array = []
	var reached: Array = []
	for p in players:
		foots.append(int(p.get("foothold", 0)))
		reached.append(bool(p.get("reached", false)))

	if enc != _prev_encounter or _prev_footholds.size() != foots.size():
		_sync_combat_audio(enc, hp, foots, reached)
		return

	# A real hit on the sigil: the beast lost health while a hunter was up there.
	if hp < _prev_boss_hp and (reached.has(true) or _prev_reached.has(true)):
		Sfx.play("strike_weakpoint")
		_juice_strike()

	var arrived := false
	var climbed := false
	var shook := false
	for i in range(foots.size()):
		if not _prev_reached[i] and reached[i]:
			arrived = true
			_spawn_emote(i, EMOTE_STAR)  # made it to the weak point!
		elif foots[i] > _prev_footholds[i]:
			climbed = true
		elif foots[i] < _prev_footholds[i]:
			shook = true
			_spawn_emote(i, EMOTE_SWIRL)  # knocked down — dizzy
	if arrived:
		Sfx.play("reach_sigil")
	elif climbed:
		Sfx.play("climb")
	if shook:
		Sfx.play("shake")
		_juice_shake()

	_sync_combat_audio(enc, hp, foots, reached)


func _sync_combat_audio(enc: int, hp: int, foots: Array, reached: Array) -> void:
	_prev_encounter = enc
	_prev_boss_hp = hp
	_prev_footholds = foots
	_prev_reached = reached


func _render_hand() -> void:
	_clear(_hand_row)
	var solo := _is_solo()
	var priv := _my_private()
	var ended := bool(priv.get("ended", false))
	var selecting := not _selecting.is_empty()
	# Your identity is a SYMBOL, not a sentence (Nick): the active hunter's
	# portrait sits above the hand; text only appears for real states.
	var players: Array = _client.shared.get("players", [])
	var meidx := _me()
	var pp := String(players[meidx].get("portrait", "")) if meidx < players.size() else ""
	_hand_icon.visible = pp != "" and ResourceLoader.exists(pp)
	if _hand_icon.visible:
		_hand_icon.texture = load(pp)
	if selecting:
		_hand_label.text = _selection_prompt()
	else:
		_hand_label.text = "(turn ended)" if ended else ""
	for card in priv.get("hand", []):
		var idx := int(card["index"])
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(card, true if selecting else bool(card["playable"]))  # any card is pickable
		if selecting and (idx == int(_selecting.get("play_index", -1)) or idx == int(_selecting.get("sac", -1))):
			cv.set_selected(true)
		cv.tapped.connect(_on_card_tapped.bind(card, cv))
		cv.timing_resolved.connect(_on_timing_resolved.bind(idx))
	_switch_btn.visible = solo
	if solo:
		_switch_btn.text = "▶ Switch to %s" % _hunter_name(1 - _active_slot)
		_end_turn_btn.text = "End %s's Turn" % _hunter_name(_active_slot)
	else:
		_end_turn_btn.text = "Waiting for ally…" if ended else "End Turn"
	_end_turn_btn.disabled = ended
	_switch_btn.disabled = false
	if selecting:  # mid-pick — lock the turn controls until it resolves or cancels
		_end_turn_btn.disabled = true
		_end_turn_btn.text = "Choosing a card…"
		_switch_btn.disabled = true
	elif _climb.has(_me()):  # committed to a hop — reach a hold or fall...
		_end_turn_btn.disabled = true
		_end_turn_btn.text = "⚠ Climbing — reach a hold!"
		# ...but you MAY switch and act with the other hunter while the timer runs
		# (their climb keeps draining — solo multitasking, per Nick).


func _on_card_tapped(card: Dictionary, cv: CardView) -> void:
	var index := int(card["index"])
	if not _selecting.is_empty():  # a pick for the active selection card
		_pick_for_selection(index)
		return
	if bool(card.get("timed", false)):
		cv.start_timing(int(card.get("timed_hits", 1)))  # runs its own sweep(s); next tap fires each
		return
	if bool(card.get("exhaust_pick", false)) or bool(card.get("cheapen_pick", false)) or bool(card.get("meld", false)):
		_start_selection(card)  # Burn Coal / Catapult / Meld — pick target cards, then it fires
		return
	Sfx.play("card")
	_client.play_card(index, true, _cmd_slot())


# --- Card selection flow (Burn Coal / Catapult) ---------------------------

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
	else:
		if idx == int(_selecting.get("sac", -1)):
			return  # the two picks must be different cards
		_selecting["target"] = idx
	_selecting["step"] = int(_selecting.get("step", 0)) + 1
	if int(_selecting["step"]) >= int(_selecting.get("picks", 1)):  # all picks made — fire it
		var play_index := int(_selecting.get("play_index", -1))
		var sac := int(_selecting.get("sac", -1))
		var target := int(_selecting.get("target", -1))
		_selecting = {}
		Sfx.play("card")
		_client.play_card(play_index, true, _cmd_slot(), sac, target)
	else:
		_render_hand()


func _on_timing_resolved(hit: bool, index: int) -> void:
	Sfx.play("nail" if hit else "slip")
	_client.play_card(index, hit, _cmd_slot())


# --- Map phase (the route) ------------------------------------------------

const NODE_ICONS := {
	"fight": preload("res://assets/icons/sword.png"),
	"elite": preload("res://assets/icons/skull.png"),
	"rest": preload("res://assets/icons/campfire.png"),
	"treasure": preload("res://assets/icons/award.png"),
}
const NODE_TINT := {
	"fight": Color(0.82, 0.44, 0.34),
	"elite": Color(0.72, 0.42, 0.72),
	"rest": Color(0.62, 0.80, 0.52),
	"treasure": Color(0.90, 0.78, 0.42),
	"boss": Color(0.95, 0.55, 0.42),
}
const NODE_LABEL := {
	"fight": "Beast", "elite": "Elite", "rest": "Rest",
	"treasure": "Relic", "boss": "TITAN",
}

## The route: rows of nodes drawn bottom-up (you climb the page). Nodes you can
## step to are lit and tappable; where you stand is ringed; what's behind you is
## dimmed. Either hunter may choose — the route is a shared decision.
func _render_map(s: Dictionary) -> void:
	_show_map(true)
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	var m: Dictionary = s.get("map", {})
	var rows: Array = m.get("rows", [])
	var cur_row := int(m.get("row", -1))
	var cur_col := int(m.get("col", 0))
	var avail: Array = m.get("available", [])
	var boss_art: Array = m.get("boss_art", [])
	# Only the act you're in — each act is a short route capped by its Titan, so
	# the whole choice fits on screen without scrolling.
	var act := 0
	if cur_row >= 0 and cur_row < rows.size():
		act = int((rows[cur_row] as Array)[cur_col].get("act", 0))
	elif not rows.is_empty():
		act = int((rows[0] as Array)[0].get("act", 0))
	_boss_name.text = "Choose your route"
	_boss_hp.text = "Act %d of %d" % [act + 1, int(s.get("total_encounters", 4))]
	_clear(_map_rows)
	for r in range(rows.size() - 1, -1, -1):  # the Titan on top — you climb the page
		var row: Array = rows[r]
		if int((row[0] as Dictionary).get("act", 0)) != act:
			continue
		var line := HBoxContainer.new()
		line.alignment = BoxContainer.ALIGNMENT_CENTER
		line.add_theme_constant_override("separation", 12)
		for c in range(row.size()):
			var node: Dictionary = row[c]
			var is_here: bool = (r == cur_row and c == cur_col)
			var is_open: bool = (r == cur_row + 1 and avail.has(c))
			line.add_child(_map_node_button(node, r < cur_row, is_here, is_open, c, boss_art))
		_map_rows.add_child(line)


func _map_node_button(node: Dictionary, passed: bool, here: bool, open: bool,
		col: int, boss_art: Array) -> Control:
	var type := String(node.get("type", "fight"))
	var b := Button.new()
	b.custom_minimum_size = Vector2(122, 60)
	b.disabled = not open
	b.add_theme_stylebox_override("normal", _node_style(here, open, passed))
	b.add_theme_stylebox_override("hover", _node_style(here, open, passed, true))
	b.add_theme_stylebox_override("disabled", _node_style(here, open, passed))
	var box := HBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(box)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if type == "boss":
		var act := int(node.get("act", 0))
		var art := String(boss_art[act]) if act < boss_art.size() else ""
		if art != "" and ResourceLoader.exists(art):
			icon.texture = load(art)
	elif NODE_ICONS.has(type):
		icon.texture = NODE_ICONS[type]
		icon.modulate = NODE_TINT.get(type, Color(1, 1, 1))
	box.add_child(icon)
	var l := Label.new()
	l.text = String(NODE_LABEL.get(type, type))
	l.add_theme_font_size_override("font_size", 13)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not open and not here:
		l.add_theme_color_override("font_color", Color(0.55, 0.51, 0.45))
	box.add_child(l)
	if open:
		b.pressed.connect(func() -> void:
			Sfx.play("card")
			_client.pick_node(col))
	return b


func _node_style(here: bool, open: bool, passed: bool, hover: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(6)
	sb.set_border_width_all(2)
	sb.set_content_margin_all(6)
	if here:
		sb.bg_color = Color(0.26, 0.21, 0.13)
		sb.border_color = Color(0.92, 0.78, 0.42)   # you are here
	elif open:
		sb.bg_color = Color(0.20, 0.18, 0.14) if not hover else Color(0.27, 0.24, 0.18)
		sb.border_color = Color(0.72, 0.62, 0.40)   # reachable
	else:
		sb.bg_color = Color(0.11, 0.10, 0.09, 0.75 if passed else 0.5)
		sb.border_color = Color(0.30, 0.27, 0.22)   # behind you / off-route
	return sb


## Swap between the route screen and the combat scene.
func _show_map(on: bool) -> void:
	_map_panel.visible = on
	_scene_row.visible = not on
	_hand_bar.visible = not on
	_hand_row.visible = not on
	_end_turn_btn.get_parent().visible = not on
	if on:
		_stop_climb()


# --- Reward phase ---------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	_show_map(false)
	_stop_climb()
	_hand_icon.visible = false  # instruction text leads here, not identity
	_lock_btn.text = "Lock In Reward"
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false
	_boss_art.visible = false
	_arena.visible = false
	var solo := _is_solo()
	_switch_btn.visible = solo
	_switch_btn.disabled = false  # never inherit combat's mid-climb lock into reward
	if solo:
		_switch_btn.text = "▶ Switch to %s" % _hunter_name(1 - _active_slot)

	var reward: Dictionary = _my_private().get("reward", {})
	var is_relic := String(reward.get("kind", "card")) == "relic"
	var picked := bool(reward.get("picked", false))
	_boss_name.text = "Titan felled!  (%d / %d)%s" % [s["encounter"], s["total_encounters"],
		("   —   %s picks" % _hunter_name(_active_slot)) if solo else ""]
	_boss_hp.text = ("Choose a RELIC — a lasting boon for the team." if is_relic
		else "Choose a card to strengthen your deck for the next Titan.")

	_render_players(s, [])
	_log_label.text = _log_with_relics(s)

	var noun := "relic" if is_relic else "card"
	if picked:
		_hand_label.text = "Locked in — waiting for ally"
	elif _selected_choice >= 0:
		_hand_label.text = "Tap another to change, or Lock In your %s" % noun
	else:
		_hand_label.text = "Tap a %s to select" % noun

	_clear(_hand_row)
	for choice in reward.get("choices", []):
		var idx := int(choice["index"])
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(choice, not picked)
		if not picked and idx == _selected_choice:
			cv.set_selected(true)
		cv.tapped.connect(_on_reward_selected.bind(idx))

	# The Lock In button confirms the highlighted choice (fixes accidental picks).
	_lock_btn.visible = not picked
	_lock_btn.disabled = picked or _selected_choice < 0


func _on_reward_selected(choice: int) -> void:
	# Select (highlight) only — nothing is committed until Lock In.
	if bool(_my_private().get("reward", {}).get("picked", false)):
		return
	Sfx.play("card")
	_selected_choice = choice
	_refresh()


func _on_lock() -> void:
	var s := _client.shared
	if bool(s.get("waiting", false)) and String(s.get("phase", "")) == "select":
		if _selected_char != "":
			Sfx.play("lock")  # a latch clunking shut — locking your climber in
			var slot := int(s.get("current_slot", -1)) if _is_solo() else -1
			_client.select_character(_selected_char, slot)
			_selected_char = ""
		return
	if _selected_choice < 0:
		return
	Sfx.play("reward")
	_client.pick_card(_selected_choice, _cmd_slot())
	_selected_choice = -1
	if _is_solo():  # go pick the other hunter's reward
		_active_slot = 1 - _active_slot


func _on_character_selected(character_id: String) -> void:
	if not _is_solo() and String(_client.private.get("selected", "")) != "":
		return  # already locked (co-op)
	Sfx.play("card")
	_selected_char = character_id
	_refresh()


# --- Character select (lobby) ---------------------------------------------

func _render_character_select(s: Dictionary) -> void:
	_show_map(false)
	_stop_climb()
	_hand_icon.visible = false
	_log_toggle.visible = false
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false
	_switch_btn.visible = false
	_boss_art.visible = false
	_arena.visible = false

	var solo := bool(s.get("solo", false))
	var current := int(s.get("current_slot", 0)) if solo else _client.you
	if solo:
		_boss_name.text = "Choose Hunter %d's climber" % (current + 1)
		_boss_hp.text = "Pick a character for each hunter, then Lock In. You'll play both."
	else:
		_boss_name.text = "Choose your climber"
		_boss_hp.text = "Pick a character, then Lock In. The run begins when both hunters are ready."

	# players row -> who has locked in
	_clear(_players_row)
	var sels: Array = s.get("selections", [])
	for i in range(sels.size()):
		var sel: Dictionary = sels[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		panel.add_child(box)
		var marker := "   ◀ choosing" if (solo and i == current) else ("   (you)" if (not solo and i == current) else "")
		box.add_child(_mklabel("Hunter %d%s" % [i + 1, marker]))
		box.add_child(_mklabel("✓ " + String(sel["name"]) if bool(sel.get("picked", false)) else "…"))
		_players_row.add_child(panel)
	_log_label.text = ""

	# In solo you always control the pick; in co-op you lock once.
	var locked := (not solo) and String(_client.private.get("selected", "")) != ""
	_hand_label.text = "Characters" + ("   (locked — waiting for ally)" if locked else "")
	_clear(_hand_row)
	for ch in _client.private.get("characters", []):
		var cid := String(ch["id"])
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup({"name": ch["name"], "text": ch["desc"], "icon": "climb",
			"portrait": String(ch.get("portrait", "")), "no_cost": true}, not locked)
		if not locked and cid == _selected_char:
			cv.set_selected(true)
		cv.tapped.connect(_on_character_selected.bind(cid))
	_lock_btn.text = "Lock In Character"
	_lock_btn.visible = not locked
	_lock_btn.disabled = locked or _selected_char == ""


# --- Run over -------------------------------------------------------------

func _render_over(s: Dictionary) -> void:
	_show_map(false)
	_stop_climb()
	_overlay.visible = true
	_restart_btn.visible = true
	_menu_btn.visible = true
	_result_label.add_theme_font_size_override("font_size", 30)
	var win := String(s.get("result", "")) == "win"
	if not _over_sound:
		Sfx.play("win" if win else "lose")
		_over_sound = true
	_result_label.add_theme_color_override("font_color",
		Color(0.62, 0.80, 0.52) if win else Color(0.86, 0.46, 0.42))
	match String(s.get("result", "")):
		"win":
			_result_label.text = "Run complete!\nAll Titans have fallen."
		"lose":
			_result_label.text = "Defeat.\nA hunter has fallen."
		_:
			_result_label.text = "Run over."


func _show_paused(s: Dictionary) -> void:
	_show_map(false)
	_stop_climb()
	_overlay.visible = true
	_restart_btn.visible = false
	_menu_btn.visible = true
	var slot := int(s.get("disconnected_slot", -1))
	var who := "A hunter"
	var players: Array = s.get("players", [])
	if slot >= 0 and slot < players.size():
		who = String(players[slot]["name"])
	_result_label.text = "%s disconnected.\nThe run is paused." % who


func _show_waiting(s: Dictionary) -> void:
	_show_map(false)
	_stop_climb()
	_overlay.visible = true
	_restart_btn.visible = false
	_menu_btn.visible = true
	_result_label.text = "Waiting for hunters…\n%d / %d joined" % [
		int(s.get("joined", 1)), int(s.get("required", 2))]


# --- Shared: players row --------------------------------------------------

## Compact hunter panel: [portrait] [name / HP bar / one status line].
func _render_players(s: Dictionary, targeted: Array) -> void:
	_clear(_players_row)
	var me: int = _me()
	var phase := String(s.get("phase", "combat"))
	var players: Array = s["players"]
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if i in targeted:
			panel.add_theme_stylebox_override("panel", _danger_panel())
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		panel.add_child(row)

		var port := TextureRect.new()
		port.custom_minimum_size = Vector2(46, 46)
		port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var ppath := String(p.get("portrait", ""))
		if ppath != "" and ResourceLoader.exists(ppath):
			port.texture = load(ppath)
		row.add_child(port)

		var box := VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 2)
		row.add_child(box)

		var who := String(p["name"]) + ("  (you)" if i == me else "")
		if i in targeted:
			who += "  ⚔"
		var who_lbl := Label.new()
		who_lbl.text = who
		who_lbl.add_theme_font_size_override("font_size", 15)
		if i in targeted:
			who_lbl.add_theme_color_override("font_color", Color(0.9, 0.52, 0.45))
		box.add_child(who_lbl)

		var hp_row := HBoxContainer.new()
		hp_row.add_theme_constant_override("separation", 6)
		var hp_bar := ProgressBar.new()
		hp_bar.custom_minimum_size = Vector2(120, 14)
		hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hp_bar.show_percentage = false
		hp_bar.max_value = int(p["max_hp"])
		hp_bar.value = int(p["hp"])
		hp_bar.add_theme_stylebox_override("fill",
			_bar_fill(float(p["hp"]) / maxf(1.0, float(p["max_hp"]))))
		hp_row.add_child(hp_bar)
		var hp_lbl := Label.new()
		hp_lbl.text = "%d%s" % [int(p["hp"]), _block_suffix(int(p.get("block", 0)))]
		hp_lbl.add_theme_font_size_override("font_size", 13)
		hp_row.add_child(hp_lbl)
		box.add_child(hp_row)

		var status_lbl := Label.new()
		status_lbl.add_theme_font_size_override("font_size", 13)
		status_lbl.add_theme_color_override("font_color", Color(0.8, 0.76, 0.66))
		if phase == "combat":
			status_lbl.text = _player_status_line(s, p)
			if not bool(p.get("secure", true)):
				status_lbl.add_theme_color_override("font_color", Color(0.92, 0.6, 0.42))
			elif bool(p.get("reached", false)):
				status_lbl.add_theme_color_override("font_color", Color(0.62, 0.82, 0.5))
		elif phase == "reward":
			status_lbl.text = "✓ chosen" if bool(p.get("picked", false)) else "choosing…"
		box.add_child(status_lbl)
		_players_row.add_child(panel)


## One compact line: energy + climb situation + buffs.
func _player_status_line(s: Dictionary, p: Dictionary) -> String:
	var bits: Array[String] = []
	bits.append("✦%d" % int(p.get("energy", 0)))
	var h := int(p.get("weak_point_height", 0))
	if h > 0:
		if bool(p.get("reached", false)):
			var thr := int(s.get("boss", {}).get("weak_point_threshold", 0))
			bits.append("at weak point!" if thr <= 0 else "weak point %d/%d" % [int(p.get("wp_damage", 0)), thr])
		elif not bool(p.get("secure", true)):
			bits.append("climbing…")
		elif int(p.get("foothold", 0)) > 0:
			bits.append("on ledge")
	if int(p.get("strength", 0)) > 0:
		bits.append("Str+%d" % int(p["strength"]))
	if int(p.get("rhythm", 0)) > 0:
		bits.append("♪%d" % int(p["rhythm"]))
	if bool(p.get("ended", false)):
		bits.append("ended")
	return "   ".join(bits)


# --- helpers --------------------------------------------------------------

func _titan_tags(boss: Dictionary) -> String:
	var out := _block_suffix(int(boss.get("block", 0)))
	var vuln := int(boss.get("vulnerable", 0))
	if vuln > 0:
		out += "   · exposed %d" % vuln
	var strength := int(boss.get("strength", 0))
	if strength > 0:
		out += "   · enraged +%d" % strength
	var wound := int(boss.get("wound", 0))
	if wound > 0:
		out += "   · bleeding %d" % wound
	return out


func _targeted_indices(mtype: String, target: int, count: int) -> Array:
	if mtype == "attack" and target >= 0:
		return [target]
	if mtype == "attack_all":
		return range(count)
	return []


func _target_suffix(mtype: String, targeted: Array) -> String:
	if mtype == "attack_all":
		return "  →  both hunters"
	if targeted.size() == 1:
		var players: Array = _client.shared["players"]
		var t: int = targeted[0]
		return "  →  %s%s" % [players[t]["name"], " (you)" if t == _me() else ""]
	return ""


# Intent as iconography (Nick): [beast] [move icon] [value] → [target portrait(s)].
const INTENT_ICONS := {
	"attack": preload("res://assets/icons/sword.png"),
	"attack_all": preload("res://assets/icons/sword.png"),
	"leech": preload("res://assets/icons/skull.png"),
	"enrage": preload("res://assets/icons/fire.png"),
	"block": preload("res://assets/icons/shield.png"),
	"regen": preload("res://assets/icons/flask_full.png"),
}

func _render_intent(s: Dictionary, boss: Dictionary, move: Dictionary, mtype: String, targeted: Array) -> void:
	_clear(_intent)
	var art := String(boss.get("art", ""))
	if art != "" and ResourceLoader.exists(art):
		_intent.add_child(_mini_icon(load(art)))
	if INTENT_ICONS.has(mtype):
		var icon := _mini_icon(INTENT_ICONS[mtype])
		icon.modulate = _intent_color(mtype)
		_intent.add_child(icon)
	var value := int(move.get("value", 0))
	if mtype in ["attack", "attack_all", "leech"]:
		value += int(boss.get("strength", 0))
	if value > 0:
		var v := Label.new()
		v.text = str(value)
		v.add_theme_font_size_override("font_size", 17)
		v.add_theme_color_override("font_color", _intent_color(mtype))
		_intent.add_child(v)
	# who it's aimed at — the targeted hunters' portraits
	if not targeted.is_empty():
		var arrow := Label.new()
		arrow.text = "→"
		arrow.add_theme_color_override("font_color", Color(0.8, 0.74, 0.62))
		_intent.add_child(arrow)
		var players: Array = s.get("players", [])
		for t in targeted:
			var pp := String(players[t].get("portrait", "")) if t < players.size() else ""
			if pp != "" and ResourceLoader.exists(pp):
				_intent.add_child(_mini_icon(load(pp)))


func _mini_icon(tex: Texture2D) -> TextureRect:
	var m := TextureRect.new()
	m.texture = tex
	m.custom_minimum_size = Vector2(26, 26)
	m.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	m.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return m


func _intent_text(move: Dictionary, strength: int) -> String:
	var value := int(move.get("value", 0))
	match String(move.get("type", "")):
		"attack":
			return "Attack for %d" % (value + strength)
		"attack_all":
			return "Sweep for %d" % (value + strength)
		"enrage":
			return "Enrage (+%d strength)" % value
		"block":
			return "Defend (+%d block)" % value
		_:
			return "Unknown"


# --- Juice (visual feedback on big combat beats) --------------------------

const FX_BURST := preload("res://assets/fx/burst.png")
const FX_DUST := preload("res://assets/fx/dust.png")
const EMOTE_STAR := preload("res://assets/fx/emote_star.png")
const EMOTE_SWIRL := preload("res://assets/fx/emote_swirl.png")


## A little reaction bubble over a hunter's panel — floats up and fades.
func _spawn_emote(slot: int, tex: Texture2D) -> void:
	if slot < 0 or slot >= _players_row.get_child_count():
		return
	var panel := _players_row.get_child(slot) as Control
	if panel == null:
		return
	var fx := TextureRect.new()
	fx.texture = tex
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fx.size = Vector2(40, 40)
	add_child(fx)
	fx.global_position = panel.global_position + Vector2(panel.size.x - 48, -8)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(fx, "position:y", fx.position.y - 26, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(fx, "modulate:a", 0.0, 0.8)
	tw.chain().tween_callback(fx.queue_free)

## A weak-point strike: burst flash over the beast + a white flinch.
func _juice_strike() -> void:
	_spawn_fx(FX_BURST, Color(1.0, 0.85, 0.4), 1.6)
	if _boss_art.visible:
		var tw := create_tween()
		_boss_art.modulate = Color(1.6, 1.6, 1.5)  # over-bright flash
		tw.tween_property(_boss_art, "modulate", Color(1, 1, 1), 0.25)

## The beast bucks: dust + the whole arena judders.
func _juice_shake() -> void:
	_spawn_fx(FX_DUST, Color(0.9, 0.82, 0.7, 0.9), 2.2)
	var arena := _boss_art.get_parent() as Control
	if arena == null:
		return
	var tw := create_tween()
	for off in [Vector2(10, -6), Vector2(-9, 5), Vector2(6, -3), Vector2.ZERO]:
		tw.tween_property(arena, "position", arena.position + off, 0.05)

## Spawn a one-shot particle sprite over the beast, tweened out then freed.
func _spawn_fx(tex: Texture2D, tint: Color, grow: float) -> void:
	if not _boss_art.visible:
		return
	var fx := TextureRect.new()
	fx.texture = tex
	fx.modulate = tint
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var size := Vector2(150, 150)
	fx.size = size
	fx.pivot_offset = size / 2.0
	add_child(fx)
	fx.global_position = _boss_art.global_position + _boss_art.size / 2.0 - size / 2.0
	fx.scale = Vector2(0.5, 0.5)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(fx, "scale", Vector2(grow, grow), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(fx, "modulate:a", 0.0, 0.35)
	tw.chain().tween_callback(fx.queue_free)


func _show_boss_art(path: String, enraged: bool) -> void:
	if path == "" or not ResourceLoader.exists(path):
		_boss_art.visible = false
		return
	_boss_art.texture = load(path)
	if path.ends_with(".svg"):
		# Silhouettes get the warm stone tone; a shade redder when enraged.
		_boss_art.modulate = Color(0.72, 0.42, 0.34) if enraged else Color(0.56, 0.49, 0.39)
	else:
		# Full-colour art stays true; flush red when the beast is enraged.
		_boss_art.modulate = Color(1.0, 0.62, 0.55) if enraged else Color(1, 1, 1)
	_boss_art.visible = true


func _log_with_relics(s: Dictionary) -> String:
	var body := "\n".join(s.get("log", []))
	var relics: Array = s.get("relics", [])
	if relics.is_empty():
		return body
	var header := "Relics:  " + ",  ".join(relics)
	return header + ("\n\n" + body if not body.is_empty() else "")


## Combat ticker: the last few log lines, dim, in the scene's left column.
## The Log ▸/▾ button toggles between a 4-line ticker and a 16-line history.
func _log_tail(s: Dictionary) -> String:
	var log: Array = s.get("log", [])
	var n := 16 if _log_expanded else 4
	return "\n".join(log.slice(maxi(log.size() - n, 0)))


## The beast IS the play space: hunters are markers placed ON its body, the weak
## point glows at a real spot on it, and ledges are ticks along the route. Height
## maps to a normalized y between the base (bottom) and the sigil (upper body), so
## it stays correct at any window size and works with whatever art we swap in.
const CLIMB_X := 0.5      # the route runs up the centre of the beast
const BASE_Y := 0.92      # ground level
const SIGIL_Y := 0.22     # where the weak point sits on the body

func _build_climb_arena(s: Dictionary) -> void:
	for c in _climb_layer.get_children():
		c.queue_free()
	_arena.visible = true
	var boss: Dictionary = s.get("boss", {})
	var height := int(boss.get("weak_point_height", 0))
	if height <= 0:
		return
	# the route itself — a faint line up the body from base to sigil
	var route := Panel.new()
	route.add_theme_stylebox_override("panel", _route_style())
	_place(route, CLIMB_X, (BASE_Y + SIGIL_Y) / 2.0, Vector2(6, 0))
	route.anchor_top = SIGIL_Y
	route.anchor_bottom = BASE_Y
	route.offset_top = 0.0
	route.offset_bottom = 0.0
	# ledge ticks along the route
	for l in boss.get("ledges", []):
		var tick := Panel.new()
		tick.add_theme_stylebox_override("panel", _ledge_style())
		_place(tick, CLIMB_X, _climb_y(int(l), height), Vector2(54, 5))
	# the weak point — a pulsing gold burst on the beast's body
	var wp := TextureRect.new()
	wp.texture = FX_BURST
	wp.modulate = Color(1.0, 0.82, 0.35, 0.95)
	wp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_place(wp, CLIMB_X, SIGIL_Y, Vector2(64, 64))
	wp.pivot_offset = Vector2(32, 32)
	var pulse := wp.create_tween().set_loops()
	pulse.tween_property(wp, "scale", Vector2(1.15, 1.15), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(wp, "scale", Vector2(0.9, 0.9), 0.7).set_trans(Tween.TRANS_SINE)
	# the hunters, on the beast at their Heights
	var players: Array = s.get("players", [])
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var fh := clampi(int(p.get("foothold", 0)), 0, height)
		var nx: float = CLIMB_X + (-0.07 if i == 0 else 0.07)
		_climb_layer.add_child(_hunter_marker(p, i == _me()))
		_place(_climb_layer.get_child(-1), nx, _climb_y(fh, height), Vector2(50, 50))


## Normalized y for a Height: 0 sits at the base, `height` at the sigil.
func _climb_y(lvl: int, height: int) -> float:
	var t := float(lvl) / float(maxi(height, 1))
	return lerpf(BASE_Y, SIGIL_Y, clampf(t, 0.0, 1.0))


## Anchor a node at a normalized point in the climb layer, so it scales with the
## arena instead of depending on pixel sizes we don't know until layout runs.
func _place(node: Control, nx: float, ny: float, size: Vector2) -> void:
	if node.get_parent() == null:
		_climb_layer.add_child(node)
	node.anchor_left = nx
	node.anchor_right = nx
	node.anchor_top = ny
	node.anchor_bottom = ny
	node.offset_left = -size.x / 2.0
	node.offset_right = size.x / 2.0
	node.offset_top = -size.y / 2.0
	node.offset_bottom = size.y / 2.0
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE


## A hunter clinging to the beast: portrait on a dark disc, ringed gold when it's
## the hunter you're currently controlling, tinted warm while mid-climb.
func _hunter_marker(p: Dictionary, is_me: bool) -> Control:
	var holder := PanelContainer.new()
	holder.add_theme_stylebox_override("panel", _marker_style(is_me, not bool(p.get("secure", true))))
	var port := TextureRect.new()
	port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	port.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pp := String(p.get("portrait", ""))
	if pp != "" and ResourceLoader.exists(pp):
		port.texture = load(pp)
	holder.add_child(port)
	return holder


func _marker_style(is_me: bool, climbing: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.09, 0.07, 0.85)
	sb.set_corner_radius_all(25)
	sb.set_border_width_all(3 if is_me else 2)
	if climbing:
		sb.border_color = Color(0.95, 0.62, 0.35)   # clinging — warm warning
	elif is_me:
		sb.border_color = Color(0.92, 0.78, 0.42)   # you
	else:
		sb.border_color = Color(0.55, 0.50, 0.42)   # ally
	sb.set_content_margin_all(4)
	return sb


func _route_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.11, 0.07, 0.45)  # a scuffed line up the hide
	sb.set_corner_radius_all(2)
	return sb


func _ledge_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.46, 0.62, 0.78, 0.55)
	sb.set_corner_radius_all(2)
	return sb
func _block_suffix(block: int) -> String:
	return "   [%d block]" % block if block > 0 else ""


func _bar_fill(frac: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if frac > 0.5:
		sb.bg_color = Color(0.66, 0.44, 0.28)  # bronze
	elif frac > 0.25:
		sb.bg_color = Color(0.80, 0.45, 0.22)  # orange
	else:
		sb.bg_color = Color(0.80, 0.28, 0.22)  # blood red
	sb.set_corner_radius_all(3)
	return sb


func _intent_color(mtype: String) -> Color:
	match mtype:
		"attack", "attack_all":
			return Color(0.88, 0.5, 0.44)  # threat red
		"enrage":
			return Color(0.9, 0.62, 0.35)  # ember
		"block":
			return Color(0.6, 0.72, 0.82)  # steel
		"regen":
			return Color(0.62, 0.8, 0.55)  # sickly green
		_:
			return Color(0.9, 0.86, 0.78)


func _danger_panel() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.12, 0.11)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.68, 0.34, 0.30)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(8)
	return sb


func _mklabel(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
