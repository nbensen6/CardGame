## Headless playtest of the Goblin Engineer — plays each of his cards through the
## REAL Combat engine using the actual data/cards.json definitions (via Content),
## so it catches data/wiring bugs the unit tests (which use hand-built stubs) miss.
##   Godot_v4.7.1-stable_win64_console.exe --headless --path game --script res://tools/goblin_playtest.gd
extends SceneTree

var _fails := 0

func _init() -> void:
	print("\n=== GOBLIN ENGINEER PLAYTEST (real cards via Content) ===\n")
	_jetpack()
	_grappling_arm()
	_build_mech()
	_burn_coal()
	_catapult()
	_meld()
	_satchel_at_base()
	_satchel_at_sigil()
	_grapple_built()
	print("\n%s" % ("ALL GOBLIN CARDS OK" if _fails == 0 else "%d ISSUE(S) FOUND" % _fails))
	quit(_fails)


## A started 2-player combat: goblin (slot 0, with his passive) + an ally, vs a
## tall climbable titan (weak point 6, ledges [2,4], threshold 22). Hand is forced.
func _mk(hand_ids: Array, ally_foot: int = 0) -> Combat:
	var combatants := [Combatant.new("Goblin", 42), Combatant.new("Ally", 42)]
	var boss := Content.build_boss("drowned_colossus")
	var passives := [Content.character_passive("goblin_mech"), {}]
	var c := Combat.new([[], []], combatants, boss, 42, 0, 0, 0, 0, passives)
	c.start()
	var hand: Array = []
	for id in hand_ids:
		hand.append(Content.make_card(String(id)))
	c.players[0].hand = hand
	c.players[0].energy = 6
	c.players[1].foothold = ally_foot
	return c


func _report(name: String, ok: bool, detail: String) -> void:
	print("%s  %-22s  %s" % ["PASS" if ok else "FAIL", name, detail])
	if not ok:
		_fails += 1


func _jetpack() -> void:
	var c := _mk(["goblin_jetpack", "slash"])
	c.play_card(0, 0)
	var primed: bool = String(c.players[0].prepared) == "jetpack"
	c.end_turn(0)
	c.end_turn(1)  # enemy turn, then next round -> jetpack fires
	var at_sigil: int = c.players[0].foothold
	_report("Goblin Jetpack", primed and at_sigil == c.boss.weak_point_height,
		"primed=%s, next-turn Height=%d (weak point %d)" % [primed, at_sigil, c.boss.weak_point_height])


func _grappling_arm() -> void:
	var c := _mk(["grappling_arm", "slash"], 2)
	c.players[0].foothold = 4
	c.play_card(0, 0)
	_report("Grappling Arm", c.players[1].foothold == 4,
		"ally 2 -> %d (goblin at 4)" % c.players[1].foothold)


func _build_mech() -> void:
	var c := _mk(["build_mech", "build_mech"])
	c.play_card(0, 0)
	var b1: int = c.players[0].combatant.block
	c.play_card(0, 0)
	_report("Build Mech (scaling)", b1 == 2 and c.players[0].combatant.block == 6,
		"1st=+%d, total after 2nd=%d (expect 2 then 6)" % [b1, c.players[0].combatant.block])


func _burn_coal() -> void:
	var c := _mk(["burn_coal", "cleave", "slash"])
	var before: int = c.effective_cost(0, c.players[0].hand[1])  # cleave
	c.play_card(0, 0, true, 2, 1)  # sacrifice slash(2), cheapen cleave(1)
	var exhausted: bool = c.players[0].exhaust_pile.size() == 1
	var cheaper: bool = c.effective_cost(0, c.players[0].hand[0]) == before - 1
	_report("Burn Coal", exhausted and cheaper,
		"exhausted=%d, Cleave cost %d -> %d" % [c.players[0].exhaust_pile.size(), before, c.effective_cost(0, c.players[0].hand[0])])


func _catapult() -> void:
	var c := _mk(["catapult", "slash"], 0)
	c.play_card(0, 0, true, 1, -1)  # sacrifice slash(1)
	_report("Catapult", c.players[1].foothold == 2 and c.players[0].exhaust_pile.size() == 1,
		"ally 0 -> %d, exhausted=%d" % [c.players[1].foothold, c.players[0].exhaust_pile.size()])


func _meld() -> void:
	var c := _mk(["meld", "cleave", "grapple"])
	c.play_card(0, 0, true, 1, 2)  # meld cleave + grapple
	var fused: Card = c.players[0].hand[0] if c.players[0].hand.size() == 1 else null
	var ok: bool = fused != null and fused.damage == 10 and fused.grip == 1 and fused.timed and fused.timed_grip == 2
	_report("Meld", ok, "hand=%d, fused=%s" % [c.players[0].hand.size(), fused.name if fused != null else "none"])


func _satchel_at_base() -> void:
	var c := _mk(["satchel_charge", "slash"])  # foothold 0, titan weak point 6 -> ARMORED
	var before: int = c.boss.hp
	c.play_card(0, 0, true)
	_report("Satchel @ base (armored)", before - c.boss.hp < 10,
		"dealt %d (chip — expected small; must climb for full)" % (before - c.boss.hp))


func _satchel_at_sigil() -> void:
	var c := _mk(["satchel_charge", "slash"])
	c.players[0].foothold = c.boss.weak_point_height  # at the weak point
	var before: int = c.boss.hp
	c.play_card(0, 0, true)  # 6 + 20 timed + 2 passive + 5 sigil = 33
	_report("Satchel @ weak point", before - c.boss.hp == 33,
		"dealt %d (expect 33: 6+20+2 passive+5 sigil)" % (before - c.boss.hp))


func _grapple_built() -> void:
	var c := _mk(["build_grapple", "slash"])
	c.play_card(0, 0)  # builds a Grappling Hook into hand
	var has_grapple := false
	for card in c.players[0].hand:
		if String(card.id) == "grapple":
			has_grapple = true
	_report("Build Grapple", has_grapple, "grapple in hand=%s" % has_grapple)
