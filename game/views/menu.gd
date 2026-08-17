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
@onready var _continue_btn: Button = %ContinueBtn
@onready var _asc_label: Label = %AscLabel
@onready var _asc_text: Label = %AscText
@onready var _asc_down: Button = %AscDown
@onready var _asc_up: Button = %AscUp
@onready var _reset_hints: Button = %ResetHints
@onready var _tips_toggle: Button = %TipsToggle

## Chosen difficulty tier. You may pick anything up to what you've unlocked;
## clearing a tier unlocks the next (see core/progress.gd).
var _ascension := 0


func _ready() -> void:
	Screen.fit(self)   # a phone gets a physically larger interface
	_compact_for_handheld()
	Session.reset()
	Music.play("menu")
	_ascension = Progress.unlocked_ascension()  # default to your hardest cleared tier
	_asc_down.pressed.connect(func() -> void: _set_ascension(_ascension - 1))
	_asc_up.pressed.connect(func() -> void: _set_ascension(_ascension + 1))
	_refresh_ascension()
	_tips_toggle.pressed.connect(func() -> void:
		Progress.set_hints_enabled(not Progress.hints_enabled())
		_refresh_tips())
	_reset_hints.pressed.connect(func() -> void:
		Progress.reset_hints()
		Progress.set_hints_enabled(true)   # asking to replay them implies wanting them
		_refresh_tips()
		_reset_hints.text = "Tips will show again"
		_reset_hints.disabled = true)
	_refresh_tips()
	_refresh_continue()
	_continue_btn.pressed.connect(_on_continue)
	_solo_btn.pressed.connect(_on_solo)
	_host_btn.pressed.connect(_on_host)
	_join_btn.pressed.connect(_on_join)


## This column is taller than a handheld's logical viewport, and a CenterContainer
## that overflows clips BOTH ends — the title off the top and the buttons off the
## bottom, with no way to reach either. Rather than let it scroll (a menu you have
## to scroll to find "play" is a bad menu), it gives up the things a phone doesn't
## need: the tagline, the local-network hint that assumes two windows on one
## desktop, and some of the breathing room.
func _compact_for_handheld() -> void:
	if not Screen.is_handheld():
		return
	var box := get_node_or_null("Center/Box") as VBoxContainer
	if box == null:
		return
	box.add_theme_constant_override("separation", 7)
	var title := box.get_node_or_null("Title") as Label
	if title != null:
		title.add_theme_font_size_override("font_size", 30)
	for hide_me in ["Subtitle", "Hint"]:
		var n := box.get_node_or_null(hide_me) as Control
		if n != null:
			n.visible = false
	for b in [_continue_btn, _solo_btn, _host_btn]:
		b.custom_minimum_size = Vector2(300, 44)


## Continue only appears when there is something to continue, and it says WHICH
## run — "Act 2 · The Frog & The Goblin Engineer" — because the one thing you
## want to know before pressing it is whether it is the run you remember.
func _refresh_continue() -> void:
	var summary := RunSave.summary()
	_continue_btn.visible = summary != ""
	if summary != "":
		_continue_btn.text = "Continue  —  %s" % summary
		# Starting a new run would overwrite the save, so say so rather than
		# letting someone lose an hour to a misread button.
		_solo_btn.text = "New run  (overwrites your save)"


## Resume the saved run. Solo only, and the character-select lobby is skipped —
## those hunters were chosen an hour ago.
func _on_continue() -> void:
	var saved := RunSave.load_run()
	if saved == null:
		_status.text = "That save could not be read. Starting fresh instead."
		_refresh_continue()
		return
	var transport := LocalTransport.new()
	Session.transport = transport
	Session.host = GameHost.new(transport, 0, 2, true, saved.ascension)
	Session.client = GameClient.new(transport, 1)
	Session.client.join()
	Session.host.resume_run(saved)
	_goto_combat()


## Two separate controls, because they answer different questions. The toggle is
## "do I want to be taught at all"; Replay is "teach me the ones I've already
## dismissed". Replaying with tips switched off would do nothing visible, so it
## switches them back on.
func _refresh_tips() -> void:
	var on := Progress.hints_enabled()
	_tips_toggle.text = "Tips: On" if on else "Tips: Off"
	_reset_hints.visible = on


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
	get_tree().change_scene_to_file("res://views/game_3d.tscn")


func _set_busy(msg: String, busy: bool = true) -> void:
	_status.text = msg
	_host_btn.disabled = busy
	_join_btn.disabled = busy
