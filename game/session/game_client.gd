## Client-side proxy to the authoritative host (CLAUDE.md §2). A view talks ONLY
## to this: it sends intents (play card, end turn) and renders the last snapshot
## it received. It holds no game rules and cannot change state directly — so the
## SAME view works whether the host is in-process (now) or across a network
## (build step 3). It drops snapshots addressed to other peers, so it only ever
## sees its own private hand.
class_name GameClient
extends RefCounted

signal state_updated(shared: Dictionary, private: Dictionary)

var shared: Dictionary = {}
var private: Dictionary = {}
var you: int = -1  # this client's player slot, as assigned by the host

var _transport: Transport
var _peer_id: int

func _init(transport: Transport, peer_id: int) -> void:
	_transport = transport
	_peer_id = peer_id
	_transport.message_received.connect(_on_message)

# --- Intents (client -> host) ---------------------------------------------

func join() -> void:
	_send({"type": "join"})

## Choose a character in the lobby. `slot` is used in solo (this player picks both
## hunters); co-op ignores it.
func select_character(character_id: String, slot: int = -1) -> void:
	_send({"type": "select_character", "character": character_id, "slot": slot})

## `sac`/`target` are hand indices for selection cards (Burn Coal / Catapult),
## chosen on the client; -1 when the card needs no selection. `quality` is the
## graded timing result (Combat.TIMING_MISS/GOOD/PERFECT, backlog #33) —
## defaults to PERFECT so an untimed play (or any caller that predates
## grading) needs no change to keep paying a timed bonus in full.
func play_card(index: int, timing_hit: bool = true, slot: int = -1, sac: int = -1, target: int = -1,
		quality: int = Combat.TIMING_PERFECT) -> void:
	_send({"type": "play_card", "index": index, "timing": timing_hit, "slot": slot,
		"sac": sac, "target": target, "quality": quality})

func end_turn(slot: int = -1) -> void:
	_send({"type": "end_turn", "slot": slot})

## Report that a hunter lost their grip mid-climb (the client's real-time grip
## timer emptied before they reached a safe hold). The host drops them to the base.
func fall(slot: int = -1) -> void:
	_send({"type": "fall", "slot": slot})

## Drink a held potion (index into this hunter's own inventory) — combat only,
## same gate Run.use_potion() enforces host-side.
func use_potion(index: int, slot: int = -1) -> void:
	_send({"type": "use_potion", "index": index, "slot": slot})

## Throw a held potion away unused — legal any phase you're carrying one.
func discard_potion(index: int, slot: int = -1) -> void:
	_send({"type": "discard_potion", "index": index, "slot": slot})

## Answer a Scry reveal (backlog #59): `bin` names which revealed cards
## (indices into scry_pending) go to the discard pile. Everything else
## returns to the top of the draw pile in the same order it was revealed.
func resolve_scry(bin: Array, slot: int = -1) -> void:
	_send({"type": "resolve_scry", "bin": bin, "slot": slot})

## Pick reward card option `choice` (during the between-encounter REWARD phase).
func pick_card(choice: int, slot: int = -1) -> void:
	_send({"type": "pick_card", "choice": choice, "slot": slot})

## Step onto a map node (column in the next row). The route is a shared
## decision, so either hunter may send this.
func pick_node(col: int) -> void:
	_send({"type": "pick_node", "col": col})


## Answer a map event. Shared decision — either hunter may choose.
func pick_event(choice: int) -> void:
	_send({"type": "pick_event", "choice": choice})


## Campfire: "rest" | "remove" | "upgrade" (the latter two name a card in your
## own deck). Each hunter takes their own action.
func campfire(action: String, index: int = -1, slot: int = -1) -> void:
	_send({"type": "campfire", "action": action, "index": index, "slot": slot})


## Decline a reward — keeping the deck lean is a real strategy.
func skip_reward(slot: int = -1) -> void:
	_send({"type": "skip_reward", "slot": slot})


## Buy shop stock item `index`. A removal also names a card in that deck.
## The purse is shared, so either hunter may spend it.
func buy(index: int, card_index: int = -1) -> void:
	_send({"type": "buy", "index": index, "card_index": card_index})


func leave_shop() -> void:
	_send({"type": "leave_shop"})


func restart() -> void:
	_send({"type": "restart"})

func _send(command: Dictionary) -> void:
	_transport.send_command(_peer_id, command)

# --- Snapshots (host -> client) -------------------------------------------

func _on_message(message: Dictionary) -> void:
	if String(message.get("type", "")) != "snapshot":
		return
	if int(message.get("for_peer", -1)) != _peer_id:
		return  # addressed to another player — not our private view
	you = int(message.get("you", -1))
	shared = message.get("shared", {})
	private = message.get("private", {})
	state_updated.emit(shared, private)
