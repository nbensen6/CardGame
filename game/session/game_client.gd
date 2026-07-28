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

func play_card(index: int, timing_hit: bool = true, slot: int = -1) -> void:
	_send({"type": "play_card", "index": index, "timing": timing_hit, "slot": slot})

func end_turn(slot: int = -1) -> void:
	_send({"type": "end_turn", "slot": slot})

## Pick reward card option `choice` (during the between-encounter REWARD phase).
func pick_card(choice: int, slot: int = -1) -> void:
	_send({"type": "pick_card", "choice": choice, "slot": slot})

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
