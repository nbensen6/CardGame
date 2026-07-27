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

func play_card(index: int) -> void:
	_send({"type": "play_card", "index": index})

func end_turn() -> void:
	_send({"type": "end_turn"})

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
