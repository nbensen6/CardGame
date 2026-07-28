## RPC endpoint node for networked play (CLAUDE.md §5, build step 3B). Godot's
## high-level multiplayer routes RPCs by node path, so this must be a Node in the
## tree at the SAME path on every peer. The menu (and the net smoke test) add it
## as "/root/NetLink" on both host and client, then hand it to an EnetTransport.
##
## It only marshals dictionaries on/off the wire and re-emits them as signals;
## all game logic stays above, behind the Transport interface.
class_name NetLink
extends Node

## A client's command reached the server (peer_id = the sender).
signal command_arrived(peer_id: int, command: Dictionary)
## The server's message reached this client.
signal message_arrived(message: Dictionary)
## A remote peer dropped (server side).
signal peer_dropped(peer_id: int)
## The host went away (client side).
signal host_dropped()

func _ready() -> void:
	# multiplayer_peer is set before this node is added, so these are safe here.
	multiplayer.peer_disconnected.connect(func(id: int) -> void: peer_dropped.emit(id))
	multiplayer.server_disconnected.connect(func() -> void: host_dropped.emit())

## Client -> server.
func to_server(command: Dictionary) -> void:
	_recv_command.rpc_id(1, command)

## Server -> one specific client.
func to_peer(peer_id: int, message: Dictionary) -> void:
	_recv_message.rpc_id(peer_id, message)

@rpc("any_peer", "call_remote", "reliable")
func _recv_command(command: Dictionary) -> void:
	command_arrived.emit(multiplayer.get_remote_sender_id(), command)

@rpc("authority", "call_remote", "reliable")
func _recv_message(message: Dictionary) -> void:
	message_arrived.emit(message)
