## Combat view — a pure CLIENT of the authoritative host (CLAUDE.md §2, §8).
## It renders snapshot Dictionaries and sends intents through GameClient; it
## holds NO game rules and never touches /core types. The same view will render
## whether the host is in-process (now) or across a network (build step 3).
##
## Mobile-ready constraints honored (CLAUDE.md §5):
##  - Single-pointer only: every action is a click/tap on a Button.
##  - No hover-only info: each card shows cost + rules text on its face; the
##    boss intent is always visible.
##  - Anchor-based, scalable UI: containers only, no hard-coded pixel positions.
extends Control

var _transport: LocalTransport
var _host: GameHost
var _client: GameClient

@onready var _boss_name: Label = %BossName
@onready var _boss_hp: Label = %BossHP
@onready var _boss_hp_bar: ProgressBar = %BossHPBar
@onready var _intent: Label = %Intent
@onready var _log_label: Label = %Log
@onready var _player_stats: Label = %PlayerStats
@onready var _hand_row: HBoxContainer = %Hand
@onready var _end_turn_btn: Button = %EndTurn
@onready var _overlay: Control = %Overlay
@onready var _result_label: Label = %ResultLabel
@onready var _restart_btn: Button = %RestartButton


func _ready() -> void:
	_end_turn_btn.pressed.connect(func() -> void: _client.end_turn())
	_restart_btn.pressed.connect(func() -> void: _client.restart())

	# --- Bootstrap the client/server split over an in-process transport. ---
	# Build step 3 swaps LocalTransport for a networked transport with NO changes
	# to GameHost, GameClient, /core, or this view. (This local wiring is the
	# only bit that moves out then: the host runs on one machine, clients dial in.)
	_transport = LocalTransport.new()
	_host = GameHost.new(_transport)          # authoritative state lives here
	_client = GameClient.new(_transport, 1)   # this window is player/peer 1
	_client.state_updated.connect(_on_state)
	_client.join()


func _on_state(_shared: Dictionary, _private: Dictionary) -> void:
	_refresh()


func _on_card_pressed(index: int) -> void:
	_client.play_card(index)


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty():
		return
	var boss: Dictionary = s["boss"]
	_boss_name.text = String(boss["name"])
	_boss_hp.text = "HP %d / %d%s" % [boss["hp"], boss["max_hp"], _block_suffix(boss["block"])]
	_boss_hp_bar.max_value = boss["max_hp"]
	_boss_hp_bar.value = boss["hp"]
	_intent.text = "Intent:  %s" % _intent_text(boss["intent"])

	var p: Dictionary = s["player"]
	_player_stats.text = "You:  HP %d / %d%s      Energy %d / %d      Turn %d" % [
		p["hp"], p["max_hp"], _block_suffix(p["block"]),
		s["energy"], s["base_energy"], s["turn"],
	]

	_log_label.text = "\n".join(s["log"])

	_rebuild_hand(_client.private.get("hand", []))
	_end_turn_btn.disabled = bool(s["over"])
	_update_overlay(s)


func _rebuild_hand(cards: Array) -> void:
	for child in _hand_row.get_children():
		child.queue_free()

	for card in cards:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 190)  # thumb-friendly target (§5)
		btn.clip_text = true
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "%s\n(%d energy)\n\n%s" % [card["name"], card["cost"], card["text"]]
		btn.disabled = not bool(card["playable"])
		btn.pressed.connect(_on_card_pressed.bind(int(card["index"])))
		_hand_row.add_child(btn)


func _update_overlay(s: Dictionary) -> void:
	if not bool(s.get("over", false)):
		_overlay.visible = false
		return
	_overlay.visible = true
	match String(s.get("result", "")):
		"win":
			_result_label.text = "Victory!\nThe Gatekeeper falls."
		"lose":
			_result_label.text = "Defeat.\nYou have fallen."
		_:
			_result_label.text = "Combat over."


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
