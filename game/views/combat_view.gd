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
@onready var _overlay: Control = %Overlay
@onready var _result_label: Label = %ResultLabel
@onready var _restart_btn: Button = %RestartButton


func _ready() -> void:
	_end_turn_btn.pressed.connect(func() -> void: _client.end_turn())
	_restart_btn.pressed.connect(func() -> void: _client.restart())
	_client = Session.client
	_client.state_updated.connect(_on_state)
	if not _client.shared.is_empty():
		_refresh()


func _on_state(_shared: Dictionary, _private: Dictionary) -> void:
	_refresh()


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty():
		return
	if bool(s.get("waiting", false)):
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

	var boss: Dictionary = s["boss"]
	_boss_name.text = "%s        Titan %d / %d" % [boss["name"], s["encounter"], s["total_encounters"]]
	_boss_hp.text = "HP %d / %d%s" % [boss["hp"], boss["max_hp"], _titan_tags(boss)]
	_boss_hp_bar.max_value = boss["max_hp"]
	_boss_hp_bar.value = boss["hp"]

	var move: Dictionary = boss["intent"]
	var mtype := String(move.get("type", ""))
	var targeted := _targeted_indices(mtype, int(boss.get("target", -1)), s["players"].size())
	_intent.text = "Intent:  %s%s" % [_intent_text(move, int(boss.get("strength", 0))), _target_suffix(mtype, targeted)]

	_render_players(s, targeted)
	_log_label.text = "\n".join(s["log"])
	_render_hand()


func _render_hand() -> void:
	_clear(_hand_row)
	var ended := bool(_client.private.get("ended", false))
	_hand_label.text = "Your hand" + ("   (turn ended — waiting for ally)" if ended else "")
	for card in _client.private.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(card, bool(card["playable"]))
		cv.pressed.connect(_on_card_pressed.bind(int(card["index"])))
	_end_turn_btn.disabled = ended
	_end_turn_btn.text = "Waiting for ally…" if ended else "End Turn"


func _on_card_pressed(index: int) -> void:
	_client.play_card(index)


# --- Reward phase ---------------------------------------------------------

func _render_reward(s: Dictionary) -> void:
	_overlay.visible = false
	_boss_panel.visible = true
	_boss_hp_bar.visible = false
	_intent.visible = false
	_end_turn_btn.get_parent().visible = false

	_boss_name.text = "Titan felled!  (%d / %d)" % [s["encounter"], s["total_encounters"]]
	_boss_hp.text = "Choose a card to strengthen your deck for the next Titan."

	_render_players(s, [])
	_log_label.text = ""

	var reward: Dictionary = _client.private.get("reward", {})
	var picked := bool(reward.get("picked", false))
	_hand_label.text = "Pick a reward card" + ("   (chosen — waiting for ally)" if picked else "")
	_clear(_hand_row)
	for choice in reward.get("choices", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		cv.setup(choice, not picked)
		cv.pressed.connect(_on_reward_pressed.bind(int(choice["index"])))


func _on_reward_pressed(choice: int) -> void:
	_client.pick_card(choice)


# --- Run over -------------------------------------------------------------

func _render_over(s: Dictionary) -> void:
	_overlay.visible = true
	_restart_btn.visible = true
	match String(s.get("result", "")):
		"win":
			_result_label.text = "Run complete!\nAll Titans have fallen."
		"lose":
			_result_label.text = "Defeat.\nA hunter has fallen."
		_:
			_result_label.text = "Run over."


func _show_waiting(s: Dictionary) -> void:
	_overlay.visible = true
	_restart_btn.visible = false
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
		box.add_child(_mklabel(who))
		box.add_child(_mklabel("HP %d / %d%s" % [p["hp"], p["max_hp"], _block_suffix(int(p.get("block", 0)))]))

		if phase == "combat":
			var status := "Energy %d / %d" % [p["energy"], s["base_energy"]]
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
	var height := int(boss.get("weak_point_height", 0))
	if height > 0:
		var foothold := int(boss.get("foothold", 0))
		if bool(boss.get("sigil_reached", false)):
			out += "   · sigil exposed ✓ (Foothold %d)" % foothold
		else:
			out += "   · Foothold %d / %d  (climb to %d)" % [foothold, int(boss.get("foothold_max", 6)), height]
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


func _block_suffix(block: int) -> String:
	return "   [%d block]" % block if block > 0 else ""


func _mklabel(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
