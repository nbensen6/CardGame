## In-process loopback transport (CLAUDE.md §7, build step 2: "still testable on
## one machine"). Host and client(s) live in the same process; messages are
## delivered synchronously by emitting the interface signals. No sockets.
##
## Targeting: broadcast reaches every client on the bus; the host stamps each
## snapshot with `for_peer`, and clients drop messages not addressed to them —
## so a player's PRIVATE view (their hand) is only ever rendered by that player.
## That filtering is what makes real per-peer networking a drop-in swap later.
class_name LocalTransport
extends Transport

func send_command(peer_id: int, command: Dictionary) -> void:
	command_received.emit(peer_id, command)

func broadcast(message: Dictionary) -> void:
	message_received.emit(message)
