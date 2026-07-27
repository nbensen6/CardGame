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
var ended_turn: bool = false   # this player has passed; others may still act this round
