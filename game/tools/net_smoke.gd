## Networked connectivity smoke test (build step 3B). Runs the REAL stack —
## ENet + NetLink + EnetTransport + GameHost + GameClient — as either a host or a
## client on 127.0.0.1, proving two processes actually connect and reach combat.
## Runs as a scene (normal main loop) so Godot auto-polls multiplayer.
##
##   godot --headless --path game res://tools/net_smoke.tscn -- host
##   godot --headless --path game res://tools/net_smoke.tscn -- client
## The client prints "NET OK" and exits 0 once it sees the shared combat board.
extends Node

var _link: NetLink
var _transport: EnetTransport
var _host: GameHost
var _client: GameClient
var _role := "host"
var _elapsed := 0.0
var _host_saw_combat := false


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_role = String(args[0])
	_link = NetLink.new()
	_link.name = "NetLink"
	# Defer: during _ready the root is still "busy setting up children", so a
	# direct add_child would fail and the node would never enter the tree (its
	# RPCs would then be unconfigured). Wait a couple of frames until it's in.
	get_tree().root.add_child.call_deferred(_link)
	await get_tree().process_frame
	await get_tree().process_frame
	if _role == "client":
		_start_client()
	else:
		_start_host()


func _start_host() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(9999, 1)
	if err != OK:
		_fail("create_server error %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	_transport = EnetTransport.new(_link, true)
	_host = GameHost.new(_transport, 777, 2)
	_client = GameClient.new(_transport, multiplayer.get_unique_id())
	_client.join()
	print("[net-smoke] HOST ready on :9999 — waiting for client")


func _start_client() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client("127.0.0.1", 9999)
	if err != OK:
		_fail("create_client error %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(func() -> void: _fail("connection_failed"))
	print("[net-smoke] CLIENT connecting to 127.0.0.1:9999")


func _on_connected() -> void:
	_transport = EnetTransport.new(_link, false)
	_client = GameClient.new(_transport, multiplayer.get_unique_id())
	_client.join()
	print("[net-smoke] CLIENT connected as peer %d — joining" % multiplayer.get_unique_id())


func _process(delta: float) -> void:
	_elapsed += delta
	var in_combat: bool = _client != null and not _client.shared.is_empty() \
		and not bool(_client.shared.get("waiting", true))

	if _role == "client":
		if in_combat:
			var players: Array = _client.shared.get("players", [])
			print("[net-smoke] CLIENT NET OK — you=%d players=%d boss=%s" % [
				_client.you, players.size(), _client.shared["boss"]["name"]])
			get_tree().quit(0)
		elif _elapsed > 12.0:
			_fail("client timed out before combat")
	else:
		if in_combat and not _host_saw_combat:
			_host_saw_combat = true
			print("[net-smoke] HOST NET OK — combat started with 2 players")
		if _elapsed > 12.0:
			if _host_saw_combat:
				get_tree().quit(0)
			else:
				_fail("host timed out; no client joined")


func _fail(msg: String) -> void:
	push_error("[net-smoke] " + msg)
	print("[net-smoke] FAIL: " + msg)
	get_tree().quit(1)
