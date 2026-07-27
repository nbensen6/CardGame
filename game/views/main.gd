## Boot / smoke-test view. Presentation only (CLAUDE.md §8: /views renders state).
##
## Purpose right now: confirm the toolchain end-to-end — Godot opens the project,
## GDScript runs, and /core is reachable and testable WITHOUT rendering/input/net.
## Replace this with the real shared-board view during build step 1.
extends Control

@onready var _status: Label = $CenterContainer/VBox/Status
@onready var _detail: Label = $CenterContainer/VBox/Detail


func _ready() -> void:
	var core_ok := GameState.self_check()

	# Exercise /core the way a view eventually will: read state, never own it.
	var gs := GameState.new()
	gs.damage_boss(35)

	if core_ok:
		_status.text = "✅ Toolchain OK — Godot + GDScript + /core wired up"
	else:
		_status.text = "❌ /core self-check FAILED"

	_detail.text = "core self-check: %s   |   boss_hp after 35 dmg: %d / 100" % [
		"pass" if core_ok else "fail", gs.boss_hp,
	]

	print("[boot] core self-check: ", "pass" if core_ok else "FAIL")
	print("[boot] Co-Op Deckbuilder prototype window is up.")
