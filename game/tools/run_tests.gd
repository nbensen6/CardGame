## Headless test runner for /core — proves game rules are testable with NO
## rendering, input, or networking (CLAUDE.md §11).
##
## Run from the repo's /game dir:
##   godot --headless --script res://tools/run_tests.gd
## Exit code 0 = all passed, 1 = failure.
extends SceneTree

func _init() -> void:
	var failures := 0

	if not _check("GameState.self_check", func() -> bool:
		return GameState.self_check()
	):
		failures += 1

	if not _check("boss defeat at 0 hp", func() -> bool:
		var gs := GameState.new()
		gs.damage_boss(gs.boss_hp)
		return gs.is_boss_defeated()
	):
		failures += 1

	if not _check("boss hp never negative", func() -> bool:
		var gs := GameState.new()
		gs.damage_boss(99999)
		return gs.boss_hp == 0
	):
		failures += 1

	print("")
	if failures == 0:
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("%d TEST(S) FAILED" % failures)
		quit(1)


func _check(name: String, fn: Callable) -> bool:
	var ok: bool = fn.call()
	print(("PASS  " if ok else "FAIL  ") + name)
	return ok
