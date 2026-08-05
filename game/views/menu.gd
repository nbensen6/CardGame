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
@onready var _asc_label: Label = %AscLabel
@onready var _asc_text: Label = %AscText
@onready var _asc_down: Button = %AscDown
@onready var _asc_up: Button = %AscUp

## Chosen difficulty tier. You may pick anything up to what you've unlocked;
## clearing a tier unlocks the next (see core/progress.gd).
var _ascension := 0


func _ready() -> void:
	Session.reset()
	Music.play("menu")
	_ascension = Progress.unlocked_ascension()  # default to your hardest cleared tier
	_asc_down.pressed.connect(func() -> void: _set_ascension(_ascension - 1))
	_asc_up.pressed.connect(func() -> void: _set_ascension(_ascension + 1))
	_refresh_ascension()
	_solo_btn.pressed.connect(_on_solo)
	_host_btn.pressed.connect(_on_host)
	_join_btn.pressed.connect(_on_join)


## Single-player: one player controls both hunters, all in-process (no networking).
func _on_solo() -> void:
	var transport := LocalTransport.new()
	Session.transport = transport
	Session.host = GameHost.new(transport, 0, 2, true, _ascension)  # solo = true
	Session.client = GameClient.new(transport, 1)
	Session.client.join()  # enters the (solo) character-select lobby
	_goto_combat()


func _set_ascension(v: int) -> void:
	_ascension = clampi(v, 0, Progress.unlocked_ascension())
	_refresh_ascension()


func _refresh_ascension() -> void:
	var unlocked := Progress.unlocked_ascension()
	_asc_label.text = "Ascension %d" % _ascension
	_asc_down.disabled = _ascension <= 0
	_asc_up.disabled = _ascension >= unlocked
	if _ascension <= 0:
		_asc_text.text = "The base climb." if unlocked == 0 else "The base climb.  (unlocked: %d)" % unlocked
		return
	# list what's stacked up at this tier
	var lines: Array[String] = []
	for t in Content.ascension_tiers():
		var tier: Dictionary = t
		if int(tier.get("level", 99)) <= _ascension:
			lines.append("%s — %s" % [String(tier.get("name", "")), String(tier.get("text", ""))])
	_asc_text.text = "\n".join(lines)


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
	Session.host = GameHost.new(transport, 0, 2, false, _ascension)
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
