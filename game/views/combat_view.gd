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
@onready var _intent: Label = %Intent
@onready var _players_row: VBoxContainer = %Players
@onready var _ladder: VBoxContainer = %Ladder
@onready var _boss_art: TextureRect = %BossArt
@onready var _log_label: Label = %Log
@onready var _log_toggle: Button = %LogToggle
@onready var _hand_label: Label = %HandLabel
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
var _climbing := false        # the active hunter is between holds, timer running
var _grip := 1.0              # remaining grip, 1..0
var _climb_target := 0        # the Height (ledge/sigil) we're racing to reach
var _me_secure := true        # active hunter is resting on a safe hold
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


## Real-time grip drain. Runs every frame; only does anything mid-climb. When the
## timer empties, tell the host our hunter fell — the snapshot that follows drops
## us to the base and ends the burst.
func _process(delta: float) -> void:
	if not _climbing:
		return
	_grip -= delta / GRIP_SECONDS
	if _grip <= 0.0:
		_grip = 0.0
		_climbing = false
		_update_grip_bar()
		Sfx.play("shake")
		_client.fall(_cmd_slot())
		return
	_update_grip_bar()


## Derive the burst from the active hunter's "secure" flag: leaving a hold starts
## the timer full; reaching one (or falling) ends it. Grip only resets to full on
## a genuine hold->climbing transition, so it drains continuously across the whole
## hop even as we play several climb cards.
func _update_climb_state(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var meidx := _me()
	if meidx < 0 or meidx >= players.size():
		_stop_climb()
		return
	var p: Dictionary = players[meidx]
	_me_secure = bool(p.get("secure", true))
	_climb_target = int(p.get("next_safe", int(p.get("foothold", 0))))
	if _me_secure:
		_climbing = false
	elif not _climbing:
		_climbing = true
		_grip = 1.0
	_update_grip_bar()


func _stop_climb() -> void:
	_climbing = false
	_selecting = {}  # any in-progress card pick is abandoned when we leave combat
	if _grip_bar != null:
		_grip_bar.visible = false


func _update_grip_bar() -> void:
	if _grip_bar == null:
		return
	_grip_bar.visible = _climbing
	if not _climbing:
		return
	_grip_meter.value = _grip
	_grip_meter.modulate = Color(0.9, 0.33, 0.28).lerp(Color(0.55, 0.85, 0.5), _grip)
	_grip_label.text = "⚠ HOLD ON — reach Height %d before your grip gives out!" % _climb_target


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
		"combat":
			_render_combat(s)
		"reward":
			_render_reward(s)
		_:  # "won" / "lost"
			_render_over(s)


# --- Combat phase ---------------------------------------------------------

func _render_combat(s: Dictionary) -> void:
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
	_intent.text = "%s%s" % [_intent_text(move, int(boss.get("strength", 0))), _target_suffix(mtype, targeted)]
	_intent.add_theme_color_override("font_color", _intent_color(mtype))

	_combat_audio(s)
	_update_climb_state(s)
	_log_toggle.visible = true
	_show_boss_art(String(boss.get("art", "")), int(boss.get("strength", 0)) > 0)
	_build_ladder(s)
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
		elif foots[i] > _prev_footholds[i]:
			climbed = true
		elif foots[i] < _prev_footholds[i]:
			shook = true
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
	var tag := ("   —   %s" % _hunter_name(_active_slot)) if solo else ""
	if selecting:
		_hand_label.text = _selection_prompt()
	else:
		_hand_label.text = "Your hand%s%s" % [tag, "   (turn ended)" if ended else ""]
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
	elif _climbing:  # committed to a hop — you can't rest here; reach a hold or fall
		_end_turn_btn.disabled = true
		_end_turn_btn.text = "⚠ Climbing — reach a hold!"
		_switch_btn.disabled = true


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


# --- Reward phase ---------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	_stop_climb()
	_lock_btn.text = "Lock In Reward"
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false
	_boss_art.visible = false
	_ladder.visible = false
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
	_stop_climb()
	_log_toggle.visible = false
	_overlay.visible = false
	_top_bar.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false
	_switch_btn.visible = false
	_boss_art.visible = false
	_ladder.visible = false

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


## The shared climb ladder, drawn IN the scene beside the beast: one rung per
## Height (top = the gold weak point, blue = rest ledges), with each hunter's
## portrait marker sitting at their current Height. This is the climb made
## visible — solid blocks below you, outlined blocks still to go.
func _build_ladder(s: Dictionary) -> void:
	_clear(_ladder)
	_ladder.visible = true
	var boss: Dictionary = s.get("boss", {})
	var height := int(boss.get("weak_point_height", 0))
	if height <= 0:
		_ladder.visible = false
		return
	var ledges: Array = boss.get("ledges", [])
	var players: Array = s.get("players", [])
	var max_fh := 0
	for p in players:
		max_fh = maxi(max_fh, int(p.get("foothold", 0)))
	for lvl in range(height, -1, -1):  # top (sigil) down to the base (0)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.alignment = BoxContainer.ALIGNMENT_END
		# hunters standing at this Height (clamped: overshooting the sigil still
		# shows you AT the sigil — markers must never vanish off the top)
		for p in players:
			if clampi(int(p.get("foothold", 0)), 0, height) == lvl:
				var m := TextureRect.new()
				m.custom_minimum_size = Vector2(30, 30)
				m.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				m.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				var pp := String(p.get("portrait", ""))
				if pp != "" and ResourceLoader.exists(pp):
					m.texture = load(pp)
				if not bool(p.get("secure", true)):
					m.modulate = Color(1.0, 0.75, 0.6)  # clinging — tinted warm
				row.add_child(m)
		var is_ledge := false
		for l in ledges:
			if int(l) == lvl:
				is_ledge = true
		var b := Panel.new()
		b.custom_minimum_size = Vector2(22, 22)  # uniform rungs (Nick)
		b.add_theme_stylebox_override("panel",
			_block_style(lvl <= max_fh and lvl > 0, lvl == height, is_ledge or lvl == 0))
		row.add_child(b)
		_ladder.add_child(row)


func _block_style(climbed: bool, is_sigil: bool, is_ledge: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(2)
	sb.set_border_width_all(1)
	if climbed:  # solid — you're past this rung
		sb.bg_color = Color(0.55, 0.80, 0.48) if is_sigil else Color(0.68, 0.50, 0.30)
		sb.border_color = sb.bg_color.lightened(0.25)
	else:  # outlined — still to climb
		sb.bg_color = Color(0.12, 0.11, 0.09)
		if is_sigil:
			sb.border_color = Color(0.90, 0.74, 0.38)  # gold — the weak point up top
		elif is_ledge:
			sb.border_color = Color(0.46, 0.62, 0.78)  # blue — a rest ledge
		else:
			sb.border_color = Color(0.36, 0.32, 0.26)
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
