## Per-player combat state (CLAUDE.md §2: each player has their own private hand,
## energy, and piles; the boss and board are shared). Pure /core data — no
## rendering/input/net. One of these per player in a Combat.
class_name PlayerState
extends RefCounted

var combatant: Combatant       # hp / block / name — the public bit shown on the board
var draw_pile: Array = []      # face-down; drawn from the back
var hand: Array = []           # PRIVATE — only this player (and the host) sees the cards
var discard_pile: Array = []
var energy: int = 0
var strength: int = 0          # added to this hunter's attack damage (buffs last the fight)
var foothold: int = 0          # how high THIS hunter has climbed (per-player — SotC)
var weak_point_damage: int = 0 # sigil damage dealt this visit; at the threshold the beast bucks you off
var ended_turn: bool = false   # this player has passed; others may still act this round
var prepared: String = ""      # a delayed effect armed this fight (e.g. "jetpack"), fires next turn
var play_counts: Dictionary = {}  # card id -> times played this fight (for scaling cards like Build Mech)
# Character signature passives (set from the chosen character; constant for the run)
var character: String = ""     # character id, for display
var climb_bonus: int = 0       # extra Height per climb card (Frog)
var char_attack_bonus: int = 0 # extra attack damage (Goblin Mech)
var ally_climb: int = 0        # when this hunter climbs, the ally also gains this Height (Mountain Climbers)
