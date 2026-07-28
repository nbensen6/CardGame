## Main menu / lobby (CLAUDE.md §7 build step 3B). Picks a networked transport —
## host a game or join one by IP — wires up Session, then hands off to the combat
## view. The view itself is transport-agnostic; only this screen knows about ENet.
##
## One machine, two players (how to test locally): launch the game twice — one
## window clicks Host, the other clicks Join with IP 127.0.0.1.
extends Control

const PORT := 9999

@onready var _ip: LineEdit = %IpEdit
@onready var _status: Label = %Status
@onready var _host_btn: Button = %HostBtn
@onready var _join_btn: Button = %JoinBtn


@onready var _solo_btn: Button = %SoloBtn


func _ready() -> void:
	Session.reset()
	Music.play("menu")
	_solo_btn.pressed.connect(_on_solo)
	_host_btn.pressed.connect(_on_host)
	_join_btn.pressed.connect(_on_join)


## Single-player: one player controls both hunters, all in-process (no networking).
func _on_solo() -> void:
	var transport := LocalTransport.new()
	Session.transport = transport
	Session.host = GameHost.new(transport, 0, 2, true)  # solo = true
	Session.client = GameClient.new(transport, 1)
	Session.client.join()  # enters the (solo) character-select lobby
	_goto_combat()


func _on_host() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, 1)  # 1 remote client + the host = 2 players
	if err != OK:
		_status.text = "Could not host on port %d (in use?). Error %d." % [PORT, err]
		return
	multiplayer.multiplayer_peer = peer
	var link := _make_link()
	var transport := EnetTransport.new(link, true)
	Session.transport = transport
	Session.host = GameHost.new(transport, 0, 2)
	Session.client = GameClient.new(transport, multiplayer.get_unique_id())  # = 1
	Session.client.join()  # host joins as Player 1; combat starts when Player 2 arrives
	_goto_combat()


func _on_join() -> void:
	var ip := _ip.text.strip_edges()
	if ip.is_empty():
		ip = "127.0.0.1"
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		_status.text = "Could not start client. Error %d." % err
		return
	multiplayer.multiplayer_peer = peer
	var link := _make_link()
	_set_busy("Connecting to %s:%d…" % [ip, PORT])
	multiplayer.connected_to_server.connect(func() -> void:
		var transport := EnetTransport.new(link, false)
		Session.transport = transport
		Session.host = null
		Session.client = GameClient.new(transport, multiplayer.get_unique_id())
		Session.client.join()
		_goto_combat()
	, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(func() -> void:
		link.queue_free()
		multiplayer.multiplayer_peer = null
		_set_busy("", false)
		_status.text = "Connection to %s failed." % ip
	, CONNECT_ONE_SHOT)


func _make_link() -> NetLink:
	# Same node path on every peer so RPCs route: /root/NetLink.
	var link := NetLink.new()
	link.name = "NetLink"
	get_tree().root.add_child(link)
	return link


func _goto_combat() -> void:
	get_tree().change_scene_to_file("res://views/combat_view.tscn")


func _set_busy(msg: String, busy: bool = true) -> void:
	_status.text = msg
	_host_btn.disabled = busy
	_join_btn.disabled = busy
