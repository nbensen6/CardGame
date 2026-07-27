## In-process loopback transport (CLAUDE.md §7, build step 2: "still testable on
## one machine"). Host and client(s) live in the same process; messages are
## delivered synchronously by emitting the interface signals. No sockets.
##
## In-process there is one bus, so send_to emits to every client and each keeps
## only the message stamped with its own `for_peer`. (A networked transport
## instead sends a real per-peer packet — see EnetTransport.) Either way a
## player's PRIVATE hand is only ever seen by that player.
class_name LocalTransport
extends Transport

func send_command(peer_id: int, command: Dictionary) -> void:
	command_received.emit(peer_id, command)

func send_to(_peer_id: int, message: Dictionary) -> void:
	message_received.emit(message)  # clients filter on message["for_peer"]
