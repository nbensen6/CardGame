## Main menu / lobby (CLAUDE.md §7 build step 3B). Picks a networked transport —
## host a game or join one by IP — wires up Session, then hands off to the combat
## view. The view itself is transport-agnostic; only this screen knows about ENet.
##
## One machine, two players (how to test locally): launch the game twice — one
## window clicks Host, the other clicks Join with IP 127.0.0.1.
extends Control

const PORT := 9999

## The Frog stands in the menu in three dimensions, not as a 64px portrait.
## She is the first thing in this game that is OURS rather than a Kenney
## placeholder, so she should be the first thing you see, and she should move —
## a still image of a model says nothing a painting could not.
## Sized to the screen rather than fixed. "Skip her on a handheld" was too blunt
## a rule: the game is landscape-locked, so a phone is a WIDE short window with
## plenty of clear space to the right of the menu column — it is vertical room it
## is short of, and that is a reason to shrink her, not to drop her.
const HERO_HEIGHT := 400.0       # logical px, on a desktop
const HERO_ASPECT := 0.75        # width / height
const HERO_ROOM := 500.0         # logical px of viewport width before she fits at all
const HERO_SPIN := 0.42          # radians/sec — a slow turntable, not a spinner

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
var _hero: Node3D = null   # the Frog turning on the menu, if there is room for her


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
	_add_hero()


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


## Put the Frog on the menu, lit and turning.
##
## Built in code rather than in menu.tscn because it is entirely conditional: it
## needs a model that may not exist yet (every other hunter is still a
## placeholder, and Cast.is_yours is how we tell), and it needs a screen wide
## enough to hold her beside the menu. A scene file cannot express "only if".
func _add_hero() -> void:
	if not Cast.is_yours("frog"):
		return                     # a placeholder bunny is not a mascot
	var scene := load(Cast.model_path("frog")) as PackedScene
	if scene == null:
		return
	var view := get_viewport_rect().size
	if view.x < HERO_ROOM:
		return                     # she would stand on top of the buttons
	# Short windows shrink her instead of losing her.
	var hero := Vector2(0.0, minf(HERO_HEIGHT, view.y * 0.80))
	hero.x = hero.y * HERO_ASPECT
	var margin := Vector2(-52.0, -6.0) if not Screen.is_handheld() else Vector2(-26.0, -4.0)

	var vp := SubViewport.new()
	vp.size = Vector2i(hero)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X

	# Its own lighting: a SubViewport is a separate world, so it inherits nothing
	# from the menu and would otherwise render pitch black.
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.62, 0.66, 0.78)
	e.ambient_light_energy = 1.15
	env.environment = e
	vp.add_child(env)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-36.0, 152.0, 0.0)
	key.light_energy = 1.7
	vp.add_child(key)

	_hero = scene.instantiate() as Node3D
	_hero.rotation.y = 0.35        # three-quarter on, so she reads as a shape
	vp.add_child(_hero)

	var cam := Camera3D.new()
	cam.fov = 33.0
	# look_at needs a node already in the tree; this one is not yet.
	cam.look_at_from_position(Vector3(0.0, 1.06, 5.1), Vector3(0.0, 0.93, 0.0), Vector3.UP)
	vp.add_child(cam)

	var holder := SubViewportContainer.new()
	holder.stretch = true
	holder.custom_minimum_size = hero
	holder.size = hero
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE   # never eat a menu click
	holder.add_child(vp)
	add_child(holder)
	# Index 3: after BG, BGTint and the painted Beast, before the menu column. At
	# index 2 the Beast drew on top of her and swallowed her head.
	move_child(holder, 3)
	# Bottom RIGHT, standing in front of the beast on the backdrop. She was on the
	# left first and fought the menu column for the same 170px; here she is clear
	# of every button and the composition states the pitch — little climber,
	# colossal beast — instead of the tagline having to.
	holder.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT,
		Control.PRESET_MODE_KEEP_SIZE)
	holder.position += margin


func _process(delta: float) -> void:
	if _hero != null:
		_hero.rotation.y += delta * HERO_SPIN
