## Per-player combat state (CLAUDE.md §2: each player has their own private hand,
## energy, and piles; the boss and board are shared). Pure /core data — no
## rendering/input/net. One of these per player in a Combat.
class_name PlayerState
extends RefCounted

var combatant: Combatant       # hp / block / name — the public bit shown on the board
var draw_pile: Array = []      # face-down; drawn from the back
var hand: Array = []           # PRIVATE — only this player (and the host) sees the cards
var discard_pile: Array = []
var exhaust_pile: Array = []   # cards burned/sacrificed this fight — never reshuffled back
var cost_reductions: Dictionary = {}  # card id -> permanent cost cut this fight (Burn Coal)
var energy: int = 0
var strength: int = 0          # added to this hunter's attack damage (buffs last the fight)
var foothold: int = 0          # how high THIS hunter has climbed (per-player — SotC)
var weak_point_damage: int = 0 # sigil damage dealt this visit; at the threshold the beast bucks you off
var ended_turn: bool = false   # this player has passed; others may still act this round
var prepared: String = ""      # a delayed effect armed this fight (e.g. "jetpack"), fires next turn
var rhythm: int = 0            # combo counter — +1 per timed card you LAND this turn (Frog); resets each turn
var play_counts: Dictionary = {}  # card id -> times played this fight (for scaling cards like Build Mech)
var sigil_rounds: int = 0      # consecutive enemy turns spent at/above the sigil (a "sigil_fatigue" limiter)
# Character signature passives (set from the chosen character; constant for the run)
var character: String = ""     # character id, for display
var climb_bonus: int = 0       # extra Height per climb card (Frog)
var char_attack_bonus: int = 0 # extra attack damage (Goblin Mech)
var ally_climb: int = 0        # when this hunter climbs, the ally also gains this Height (Mountain Climbers)
var poison_lift: int = 0       # when this hunter applies Wound, the ally climbs this much (Vine-Weaver)

## Everything a mid-fight save needs to put this hunter back exactly where they
## were: the piles (as Card dicts, same trick decks use), and every scalar
## above. Character passives round-trip too since they can differ from a fresh
## Content.character_passive() lookup once a run relic or ascension touches them.
func to_dict() -> Dictionary:
	return {
		"name": combatant.name, "max_hp": combatant.max_hp,
		"hp": combatant.hp, "block": combatant.block,
		"draw_pile": _cards_to_dicts(draw_pile), "hand": _cards_to_dicts(hand),
		"discard_pile": _cards_to_dicts(discard_pile),
		"exhaust_pile": _cards_to_dicts(exhaust_pile),
		"cost_reductions": cost_reductions, "energy": energy, "strength": strength,
		"foothold": foothold, "weak_point_damage": weak_point_damage,
		"ended_turn": ended_turn, "prepared": prepared, "rhythm": rhythm,
		"play_counts": play_counts, "sigil_rounds": sigil_rounds,
		"character": character, "climb_bonus": climb_bonus,
		"char_attack_bonus": char_attack_bonus, "ally_climb": ally_climb,
		"poison_lift": poison_lift,
		"frail": combatant.frail, "artifact": combatant.artifact, "thorns": combatant.thorns,
	}

static func from_dict(d: Dictionary) -> PlayerState:
	var ps := PlayerState.new()
	ps.combatant = Combatant.new(String(d.get("name", "")), int(d.get("max_hp", 1)))
	ps.combatant.hp = int(d.get("hp", ps.combatant.max_hp))
	ps.combatant.block = int(d.get("block", 0))
	ps.draw_pile = _cards_from_dicts(d.get("draw_pile", []))
	ps.hand = _cards_from_dicts(d.get("hand", []))
	ps.discard_pile = _cards_from_dicts(d.get("discard_pile", []))
	ps.exhaust_pile = _cards_from_dicts(d.get("exhaust_pile", []))
	ps.cost_reductions = (d.get("cost_reductions", {}) as Dictionary).duplicate()
	ps.energy = int(d.get("energy", 0))
	ps.strength = int(d.get("strength", 0))
	ps.foothold = int(d.get("foothold", 0))
	ps.weak_point_damage = int(d.get("weak_point_damage", 0))
	ps.ended_turn = bool(d.get("ended_turn", false))
	ps.prepared = String(d.get("prepared", ""))
	ps.rhythm = int(d.get("rhythm", 0))
	ps.play_counts = (d.get("play_counts", {}) as Dictionary).duplicate()
	ps.sigil_rounds = int(d.get("sigil_rounds", 0))
	ps.character = String(d.get("character", ""))
	ps.climb_bonus = int(d.get("climb_bonus", 0))
	ps.char_attack_bonus = int(d.get("char_attack_bonus", 0))
	ps.ally_climb = int(d.get("ally_climb", 0))
	ps.poison_lift = int(d.get("poison_lift", 0))
	ps.combatant.frail = int(d.get("frail", 0))
	ps.combatant.artifact = int(d.get("artifact", 0))
	ps.combatant.thorns = int(d.get("thorns", 0))
	return ps

static func _cards_to_dicts(pile: Array) -> Array:
	var out: Array = []
	for c in pile:
		out.append((c as Card).to_dict())
	return out

static func _cards_from_dicts(pile: Array) -> Array:
	var out: Array = []
	for cd in pile:
		out.append(Card.from_dict(cd))
	return out
