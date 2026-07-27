## Networked transport (CLAUDE.md §5, build step 3B) — the drop-in replacement
## for LocalTransport that the whole architecture was built to allow. Implements
## the SAME Transport interface over Godot ENet + RPC (via a NetLink node), so
## /core, GameHost, GameClient, and the views are UNCHANGED from local play.
##
## Listen-server model (§4.4, confirmed): one player hosts. That host also plays,
## so it runs a GameHost AND a local GameClient (peer id 1). Messages to the
## local client are delivered in-process; messages to remote clients go by RPC.
class_name EnetTransport
extends Transport

const SERVER_PEER := 1

var _link: NetLink
var _is_server: bool

func _init(link: NetLink, is_server: bool) -> void:
	_link = link
	_is_server = is_server
	_link.command_arrived.connect(_on_link_command)
	_link.message_arrived.connect(_on_link_message)

## Client -> server. On the host, the local client's command skips the wire.
func send_command(peer_id: int, command: Dictionary) -> void:
	if _is_server:
		command_received.emit(peer_id, command)  # host's own local client
	else:
		_link.to_server(command)

## Server -> one client. The host's own client (peer 1) is delivered locally;
## everyone else gets a real per-peer packet.
func send_to(peer_id: int, message: Dictionary) -> void:
	if peer_id == SERVER_PEER:
		message_received.emit(message)  # host's local client
	else:
		_link.to_peer(peer_id, message)

func _on_link_command(peer_id: int, command: Dictionary) -> void:
	command_received.emit(peer_id, command)  # a remote client's command (server side)

func _on_link_message(message: Dictionary) -> void:
	message_received.emit(message)  # the server's message (remote client side)
