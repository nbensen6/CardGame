## Playable combat view — presentation + pointer input only (CLAUDE.md §8:
## /views render state; they don't own it). All rules live in /core (Combat).
##
## Mobile-ready constraints honored (CLAUDE.md §5):
##  - Single-pointer only: every action is a click/tap on a Button. No hover,
##    right-click, or keyboard is REQUIRED.
##  - No hover-only info: each card shows its cost + rules text on its face;
##    the boss intent is always visible on screen.
##  - Anchor-based, scalable UI: containers only, no hard-coded pixel positions.
extends Control

var _combat: Combat

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
	_end_turn_btn.pressed.connect(_on_end_turn)
	_restart_btn.pressed.connect(func() -> void: get_tree().reload_current_scene())
	_start_new_combat()


func _start_new_combat() -> void:
	var deck := Content.build_starter_deck()
	var player := Combatant.new("You", 42)
	var boss := Content.build_boss("gatekeeper")
	_combat = Combat.new(deck, player, boss, 0)  # seed 0 = randomized real play
	_combat.start()
	_refresh()


func _on_end_turn() -> void:
	if _combat.is_over():
		return
	_combat.end_turn()
	_refresh()


func _on_card_pressed(index: int) -> void:
	if _combat.play_card(index):
		_refresh()


func _refresh() -> void:
	var boss := _combat.boss
	_boss_name.text = boss.name
	_boss_hp.text = "HP %d / %d%s" % [boss.hp, boss.max_hp, _block_suffix(boss.block)]
	_boss_hp_bar.max_value = boss.max_hp
	_boss_hp_bar.value = boss.hp
	_intent.text = "Intent:  %s" % _intent_text(boss.current_move())

	var p := _combat.player
	_player_stats.text = "You:  HP %d / %d%s      Energy %d / %d      Turn %d" % [
		p.hp, p.max_hp, _block_suffix(p.block),
		_combat.energy, Combat.BASE_ENERGY, _combat.turn,
	]

	# Last few log lines (kept short so it reads at a glance).
	var lines: Array = _combat.log.slice(maxi(_combat.log.size() - 6, 0))
	_log_label.text = "\n".join(lines)

	_rebuild_hand()
	_end_turn_btn.disabled = _combat.is_over()
	_update_overlay()


func _rebuild_hand() -> void:
	for child in _hand_row.get_children():
		child.queue_free()

	for i in range(_combat.hand.size()):
		var card: Card = _combat.hand[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 190)  # thumb-friendly target (§5)
		btn.clip_text = true
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "%s\n(%d energy)\n\n%s" % [card.name, card.cost, card.text]
		btn.disabled = not _combat.can_play(i)
		btn.pressed.connect(_on_card_pressed.bind(i))
		_hand_row.add_child(btn)


func _update_overlay() -> void:
	if not _combat.is_over():
		_overlay.visible = false
		return
	_overlay.visible = true
	match _combat.result():
		Combat.Result.WIN:
			_result_label.text = "Victory!\nThe Gatekeeper falls."
		Combat.Result.LOSE:
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
