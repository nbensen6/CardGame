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

@onready var _boss_panel: PanelContainer = %BossPanel
@onready var _boss_name: Label = %BossName
@onready var _boss_hp: Label = %BossHP
@onready var _boss_hp_bar: ProgressBar = %BossHPBar
@onready var _intent: Label = %Intent
@onready var _players_row: HBoxContainer = %Players
@onready var _log_label: Label = %Log
@onready var _hand_label: Label = %HandLabel
@onready var _hand_row: HBoxContainer = %Hand
@onready var _end_turn_btn: Button = %EndTurn
@onready var _lock_btn: Button = %LockButton
@onready var _overlay: Control = %Overlay
@onready var _result_label: Label = %ResultLabel
@onready var _restart_btn: Button = %RestartButton
@onready var _menu_btn: Button = %MenuButton

var _server_lost := false
var _selected_choice := -1   # reward highlighted but NOT yet locked
var _selected_char := ""     # character highlighted in the lobby but NOT yet locked
var _prev_phase := ""


func _ready() -> void:
	_end_turn_btn.pressed.connect(func() -> void:
		Sfx.play("end_turn")
		_client.end_turn())
	_lock_btn.pressed.connect(_on_lock)
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
	_overlay.visible = false
	_boss_panel.visible = true
	_boss_hp_bar.visible = true
	_intent.visible = true
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = true
	_lock_btn.visible = false

	var boss: Dictionary = s["boss"]
	var height := int(boss.get("weak_point_height", 0))
	_boss_name.text = "%s        Titan %d / %d" % [boss["name"], s["encounter"], s["total_encounters"]]
	if height > 0:
		_boss_hp.text = "Weak point at Height %d — a hunter must climb to it to strike.   sigil %d / %d%s" % [
			height, boss["hp"], boss["max_hp"], _titan_tags(boss)]
	else:
		_boss_hp.text = "HP %d / %d%s" % [boss["hp"], boss["max_hp"], _titan_tags(boss)]
	_boss_hp_bar.max_value = boss["max_hp"]
	_boss_hp_bar.value = boss["hp"]
	_boss_hp_bar.add_theme_stylebox_override("fill",
		_bar_fill(float(boss["hp"]) / maxf(1.0, float(boss["max_hp"]))))
	_boss_hp_bar.modulate = Color(1, 1, 1, 1)

	var move: Dictionary = boss["intent"]
	var mtype := String(move.get("type", ""))
	var targeted := _targeted_indices(mtype, int(boss.get("target", -1)), s["players"].size())
	_intent.text = "Intent:  %s%s" % [_intent_text(move, int(boss.get("strength", 0))), _target_suffix(mtype, targeted)]
	_intent.add_theme_color_override("font_color", _intent_color(mtype))

	_render_players(s, targeted)
	_log_label.text = _log_with_relics(s)
	_render_hand()


func _render_hand() -> void:
	_clear(_hand_row)
	var ended := bool(_client.private.get("ended", false))
	_hand_label.text = "Your hand" + ("   (turn ended — waiting for ally)" if ended else "")
	for card in _client.private.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(card, bool(card["playable"]))
		var idx := int(card["index"])
		cv.tapped.connect(_on_card_tapped.bind(idx, bool(card.get("timed", false)), cv))
		cv.timing_resolved.connect(_on_timing_resolved.bind(idx))
	_end_turn_btn.disabled = ended
	_end_turn_btn.text = "Waiting for ally…" if ended else "End Turn"


func _on_card_tapped(index: int, timed: bool, cv: CardView) -> void:
	if timed:
		cv.start_timing()  # the card runs its own timing sweep; the next tap fires it
		return
	Sfx.play("card")
	_client.play_card(index)


func _on_timing_resolved(hit: bool, index: int) -> void:
	Sfx.play("card")
	_client.play_card(index, hit)


# --- Reward phase ---------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	_lock_btn.text = "Lock In Reward"
	_overlay.visible = false
	_boss_panel.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false

	var reward: Dictionary = _client.private.get("reward", {})
	var is_relic := String(reward.get("kind", "card")) == "relic"
	var picked := bool(reward.get("picked", false))
	_boss_name.text = "Titan felled!  (%d / %d)" % [s["encounter"], s["total_encounters"]]
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
	if bool(_client.private.get("reward", {}).get("picked", false)):
		return
	Sfx.play("card")
	_selected_choice = choice
	_refresh()


func _on_lock() -> void:
	var s := _client.shared
	if bool(s.get("waiting", false)) and String(s.get("phase", "")) == "select":
		if _selected_char != "":
			Sfx.play("reward")
			_client.select_character(_selected_char)
		return
	if _selected_choice < 0:
		return
	Sfx.play("reward")
	_client.pick_card(_selected_choice)


func _on_character_selected(character_id: String) -> void:
	if String(_client.private.get("selected", "")) != "":
		return  # already locked
	Sfx.play("card")
	_selected_char = character_id
	_refresh()


# --- Character select (lobby) ---------------------------------------------

func _render_character_select(s: Dictionary) -> void:
	_overlay.visible = false
	_boss_panel.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = true
	_end_turn_btn.visible = false

	_boss_name.text = "Choose your climber"
	_boss_hp.text = "Pick a character, then Lock In. The run begins when both hunters are ready."

	# players row -> who has locked in
	_clear(_players_row)
	var me: int = _client.you
	var sels: Array = s.get("selections", [])
	for i in range(sels.size()):
		var sel: Dictionary = sels[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		panel.add_child(box)
		box.add_child(_mklabel("Hunter %d%s" % [i + 1, "   (you)" if i == me else ""]))
		box.add_child(_mklabel("✓ " + String(sel["name"]) if bool(sel.get("picked", false)) else "choosing…"))
		_players_row.add_child(panel)
	_log_label.text = ""

	var selected := String(_client.private.get("selected", ""))
	var locked := selected != ""
	_hand_label.text = "Characters" + ("   (locked — waiting for ally)" if locked else "")
	_clear(_hand_row)
	for ch in _client.private.get("characters", []):
		var cid := String(ch["id"])
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup({"name": ch["name"], "text": ch["desc"], "icon": "grip", "no_cost": true}, not locked)
		if not locked and cid == _selected_char:
			cv.set_selected(true)
		cv.tapped.connect(_on_character_selected.bind(cid))
	_lock_btn.text = "Lock In Character"
	_lock_btn.visible = not locked
	_lock_btn.disabled = locked or _selected_char == ""


# --- Run over -------------------------------------------------------------

func _render_over(s: Dictionary) -> void:
	_overlay.visible = true
	_restart_btn.visible = true
	_menu_btn.visible = true
	_result_label.add_theme_font_size_override("font_size", 30)
	var win := String(s.get("result", "")) == "win"
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
	_overlay.visible = true
	_restart_btn.visible = false
	_menu_btn.visible = true
	_result_label.text = "Waiting for hunters…\n%d / %d joined" % [
		int(s.get("joined", 1)), int(s.get("required", 2))]


# --- Shared: players row --------------------------------------------------

func _render_players(s: Dictionary, targeted: Array) -> void:
	_clear(_players_row)
	var me: int = _client.you
	var phase := String(s.get("phase", "combat"))
	var players: Array = s["players"]
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		panel.add_child(box)

		var who := String(p["name"]) + ("   (you)" if i == me else "")
		if i in targeted:
			who += "   ⚔ targeted"
			panel.add_theme_stylebox_override("panel", _danger_panel())
		var who_lbl := _mklabel(who)
		if i in targeted:
			who_lbl.add_theme_color_override("font_color", Color(0.9, 0.52, 0.45))
		box.add_child(who_lbl)
		box.add_child(_mklabel("HP %d / %d%s" % [p["hp"], p["max_hp"], _block_suffix(int(p.get("block", 0)))]))

		if phase == "combat":
			var h := int(p.get("weak_point_height", 0))
			if h > 0:
				if bool(p.get("reached", false)):
					var atwp := _mklabel("✦ at the weak point — strike!")
					atwp.add_theme_color_override("font_color", Color(0.62, 0.82, 0.5))
					box.add_child(atwp)
				else:
					box.add_child(_mklabel("⛰ climbing — Height %d / %d" % [int(p.get("foothold", 0)), h]))
			var status := "Energy %d / %d" % [p["energy"], s["base_energy"]]
			if int(p.get("strength", 0)) > 0:
				status += "   Str +%d" % int(p["strength"])
			if bool(p.get("ended", false)):
				status += "   • ended"
			box.add_child(_mklabel(status))
		elif phase == "reward":
			box.add_child(_mklabel("✓ card chosen" if bool(p.get("picked", false)) else "choosing…"))
		_players_row.add_child(panel)


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
		return "  →  %s%s" % [players[t]["name"], " (you)" if t == _client.you else ""]
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


func _log_with_relics(s: Dictionary) -> String:
	var body := "\n".join(s.get("log", []))
	var relics: Array = s.get("relics", [])
	if relics.is_empty():
		return body
	var header := "Relics:  " + ",  ".join(relics)
	return header + ("\n\n" + body if not body.is_empty() else "")


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
