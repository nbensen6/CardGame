## Co-op combat view — a pure CLIENT of the authoritative host (CLAUDE.md §2, §8).
## Renders snapshot Dictionaries and sends intents through GameClient; holds NO
## game rules and never touches /core types. The SAME view renders whether the
## host is in-process or across a network — the transport is chosen elsewhere
## (menu for online play), then handed to this view via the Session autoload.
##
## Mobile-ready (CLAUDE.md §5): single-pointer taps only; each card shows cost +
## text on its face; the boss intent (and WHO it targets) is always visible;
## anchor-based, scalable layout.
extends Control

var _client: GameClient

@onready var _boss_name: Label = %BossName
@onready var _boss_hp: Label = %BossHP
@onready var _boss_hp_bar: ProgressBar = %BossHPBar
@onready var _intent: Label = %Intent
@onready var _players_row: HBoxContainer = %Players
@onready var _log_label: Label = %Log
@onready var _hand_label: Label = %HandLabel
@onready var _hand_row: HBoxContainer = %Hand
@onready var _end_turn_btn: Button = %EndTurn
@onready var _overlay: Control = %Overlay
@onready var _result_label: Label = %ResultLabel
@onready var _restart_btn: Button = %RestartButton


func _ready() -> void:
	_end_turn_btn.pressed.connect(func() -> void: _client.end_turn())
	_restart_btn.pressed.connect(func() -> void: _client.restart())

	# The Session autoload holds the transport/client the menu (or a test harness)
	# set up. This view is transport-agnostic: local or networked, same code.
	_client = Session.client
	_client.state_updated.connect(_on_state)
	if not _client.shared.is_empty():
		_refresh()  # a snapshot may already have arrived before we connected


func _on_state(_shared: Dictionary, _private: Dictionary) -> void:
	_refresh()


func _on_card_pressed(index: int) -> void:
	_client.play_card(index)


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty():
		return

	if bool(s.get("waiting", false)):
		_show_waiting(s)
		return
	_overlay.visible = _is_over(s)

	var boss: Dictionary = s["boss"]
	_boss_name.text = String(boss["name"])
	_boss_hp.text = "HP %d / %d%s" % [boss["hp"], boss["max_hp"], _block_suffix(boss["block"])]
	_boss_hp_bar.max_value = boss["max_hp"]
	_boss_hp_bar.value = boss["hp"]
	var target_name := _target_name(s)
	_intent.text = "Intent:  %s  →  %s" % [_intent_text(boss["intent"]), target_name]

	_rebuild_players(s)
	_log_label.text = "\n".join(s["log"])
	_rebuild_hand()
	_update_controls(s)
	_update_overlay(s)


func _rebuild_players(s: Dictionary) -> void:
	for child in _players_row.get_children():
		child.queue_free()

	var me: int = _client.you
	var target: int = int(s["boss"].get("target", -1))
	var players: Array = s["players"]
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		panel.add_child(box)

		var who := "%s%s" % [String(p["name"]), "  (you)" if i == me else ""]
		if i == target:
			who += "   ⚔ targeted"
		box.add_child(_mklabel(who))
		box.add_child(_mklabel("HP %d / %d%s" % [p["hp"], p["max_hp"], _block_suffix(p["block"])]))
		var status := "Energy %d / %d" % [p["energy"], s["base_energy"]]
		if bool(p["ended"]):
			status += "   • ended"
		box.add_child(_mklabel(status))
		_players_row.add_child(panel)


func _rebuild_hand() -> void:
	for child in _hand_row.get_children():
		child.queue_free()

	var ended := bool(_client.private.get("ended", false))
	_hand_label.text = "Your hand" + ("   (turn ended — waiting for ally)" if ended else "")

	for card in _client.private.get("hand", []):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 190)  # thumb-friendly target (§5)
		btn.clip_text = true
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var tag := "  ↪ ally" if String(card.get("target", "self")) == "ally" else ""
		btn.text = "%s%s\n(%d energy)\n\n%s" % [card["name"], tag, card["cost"], card["text"]]
		btn.disabled = not bool(card["playable"])
		btn.pressed.connect(_on_card_pressed.bind(int(card["index"])))
		_hand_row.add_child(btn)


func _update_controls(s: Dictionary) -> void:
	var ended := bool(_client.private.get("ended", false))
	_end_turn_btn.disabled = ended or _is_over(s)
	_end_turn_btn.text = "Waiting for ally…" if ended and not _is_over(s) else "End Turn"


func _update_overlay(s: Dictionary) -> void:
	if not _is_over(s):
		_overlay.visible = false
		return
	_overlay.visible = true
	_restart_btn.visible = true
	match String(s.get("result", "")):
		"win":
			_result_label.text = "Victory!\nThe Gatekeeper falls."
		"lose":
			_result_label.text = "Defeat.\nA hero has fallen."
		_:
			_result_label.text = "Combat over."


func _show_waiting(s: Dictionary) -> void:
	_overlay.visible = true
	_result_label.text = "Waiting for players…\n%d / %d joined" % [
		int(s.get("joined", 1)), int(s.get("required", 2)),
	]
	_restart_btn.visible = false


# --- helpers --------------------------------------------------------------

func _is_over(s: Dictionary) -> bool:
	return bool(s.get("over", false))


func _target_name(s: Dictionary) -> String:
	var t: int = int(s["boss"].get("target", -1))
	var players: Array = s["players"]
	if t < 0 or t >= players.size():
		return "?"
	var name := String(players[t]["name"])
	return name + (" (you)" if t == _client.you else "")


func _intent_text(move: Dictionary) -> String:
	match String(move.get("type", "")):
		"attack":
			return "Attack for %d" % int(move.get("value", 0))
		"block":
			return "Defend (+%d block)" % int(move.get("value", 0))
		_:
			return "Unknown"


func _block_suffix(block: int) -> String:
	return "   [%d block]" % block if block > 0 else ""


func _mklabel(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l
