## Transport-agnostic messaging interface (CLAUDE.md §5, §8) — the seam between
## clients and the authoritative host. Game rules (/core), the host, and the
## views NEVER touch a socket: they speak in plain Dictionaries through this
## interface. A phone/web/cast client attaches later (build step 3+) by swapping
## the implementation, with NO changes above this layer.
##
## One bus, two directions:
##   client -> server:  send_command(peer_id, command)  =>  command_received
##   server -> clients:  broadcast(message)             =>  message_received
##
## Messages are JSON-friendly Dictionaries so any real transport can serialize
## them unchanged.
class_name Transport
extends RefCounted

## Server side: a client command arrived.
signal command_received(peer_id: int, command: Dictionary)
## Client side: a server message arrived.
signal message_received(message: Dictionary)

## Client -> server. Override in a real transport to send over the wire.
func send_command(_peer_id: int, _command: Dictionary) -> void:
	push_error("Transport.send_command not implemented")

## Server -> all clients. Override in a real transport to broadcast.
func broadcast(_message: Dictionary) -> void:
	push_error("Transport.broadcast not implemented")
