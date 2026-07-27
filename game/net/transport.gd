## Transport-agnostic messaging interface (CLAUDE.md §5, §8) — the seam between
## clients and the authoritative host. Game rules (/core), the host, and the
## views NEVER touch a socket: they speak in plain Dictionaries through this
## interface. A phone/web/cast client attaches later (build step 3+) by swapping
## the implementation, with NO changes above this layer.
##
## One bus, two directions:
##   client -> server:  send_command(peer_id, command)  =>  command_received
##   server -> ONE client:  send_to(peer_id, message)   =>  message_received
##
## The host sends each player their own snapshot with send_to, so a private hand
## is delivered ONLY to its owner (over a real transport, an actual per-peer
## packet — not broadcast-and-filter). Messages are JSON-friendly Dictionaries
## so any real transport can serialize them unchanged.
class_name Transport
extends RefCounted

## Server side: a client command arrived.
signal command_received(peer_id: int, command: Dictionary)
## Client side: a server message arrived.
signal message_received(message: Dictionary)

## Client -> server. Override in a real transport to send over the wire.
func send_command(_peer_id: int, _command: Dictionary) -> void:
	push_error("Transport.send_command not implemented")

## Server -> one specific client. Override in a real transport.
func send_to(_peer_id: int, _message: Dictionary) -> void:
	push_error("Transport.send_to not implemented")
