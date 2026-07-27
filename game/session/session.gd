## Process-wide handoff for the active networking session (CLAUDE.md §2). The
## menu sets these up — choosing a transport (in-process LocalTransport or a
## networked EnetTransport) and wiring host/client — then changes scene to the
## combat view, which reads Session.client. Static vars, so no autoload or tree
## wiring is needed and the same view works regardless of which transport it is.
class_name Session
extends RefCounted

static var transport: Transport
static var host: GameHost      # null on a pure client (joined a remote host)
static var client: GameClient

## Clear references (e.g. when returning to the menu). The NetLink node, if any,
## is owned by the scene tree and freed separately by the menu.
static func reset() -> void:
	transport = null
	host = null
	client = null
