## The places between fights, staged in 3D.
##
## Step 6 of design/3d-pivot.md — the phases the 2D client still owned. Routing
## the run through 3D made those handovers jarring: you walk a region in 3D,
## climb a beast in 3D, and then a flat 2D panel appears.
##
## This is one scene for several phases, because they are all the same thing —
## your hunters standing somewhere, being offered a choice. What changes is the
## place (a felled beast, a campfire) and the choice on the HUD. Building them as
## one scene is what keeps the remaining phases cheap to add.
##
## Like every other client here, it owns no rules: it reads the same snapshot and
## sends the same commands the 2D screens do.
extends Node3D

const CAST := "res://assets/3d/cast/"
const HEX := "res://assets/3d/hex/"
const HEX_W := 1.0
const HEX_D := 1.154701
const ROW_STEP := HEX_D * 0.75
const TILE_TOP := 0.2
const HUNTER_HEIGHT := 0.62
## The felled beast is laid out behind the hunters, sized from the SAME input the
## fight used — how far you had to climb it — so the thing lying here is
## recognisably the thing you just beat.
##
## Not at combat's literal ratio. There a Titan stands ~17 hunters tall; 17x here
## would bury the reward cards this scene exists to frame, and you'd be reading
## three cards against a wall of flank. So it's compressed into a range the plot
## can hold, while a Titan still sprawls about three times a Crag Pup. Before
## this, EVERY beast lay at 1.7 — you felled a colossus and got a knee-high
## trophy, which quietly undercut the fight you'd just won.
const FELLED_MIN := 1.8
const FELLED_MAX := 5.0
## Weak-point Heights run 1..8 across the roster; that span maps onto the range.
const FELLED_MAX_WP := 8.0
## Where the body's centre lands — behind the hunters (who stand at z -0.15),
## still on the tiles.
const FELLED_Z := -1.25
## Hex neighbours around the centre tile — pointy-top, so odd rows step half a
## tile sideways. Same grid the overworld uses.
const _PLOT := [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(-1, -1),
	Vector2i(2, 0), Vector2i(-2, 0),
	Vector2i(1, 1), Vector2i(-2, 1), Vector2i(1, -1), Vector2i(-2, -1),
	Vector2i(0, 2), Vector2i(-1, 2), Vector2i(0, -2), Vector2i(-1, -2),
	Vector2i(1, 2), Vector2i(-2, 2), Vector2i(1, -2), Vector2i(-2, -2),
]
## Reuses the combat view's table, so a beast swapped there is swapped here too.
const BEAST_MODEL := preload("res://views/combat_3d.gd")

var _client: GameClient
var _built := ""        # the phase the scene was staged for
var _active_slot := 0
var _selected := -1     # reward choice tapped but not yet locked in
var _kw_popup: CanvasLayer = null  # the keyword explainer, when one is open
var _deck_pick := ""    # campfire: "remove" | "upgrade" while choosing a card
var _shop_pick := -1    # shop: the removal being resolved, -1 when idle
var _time := 0.0
var _hunters: Array = []
var _felled_span := 0.0   # size of the body on the plot; the shot backs off for it

@onready var _plot: Node3D = %Plot
@onready var _cam: Camera3D = %Camera
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _prompt: Label = %Prompt
@onready var _row: HBoxContainer = %Row
@onready var _controls: HBoxContainer = %Controls


func _ready() -> void:
	Screen.fit(self)   # a phone gets a physically larger interface
	# The console here too, so `deck`, `card` and `own` work at a campfire and a
	# trader - which is exactly where you are thinking about your deck.
	DevConsole.attach(self, _refresh)
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	if not _client.shared.is_empty():
		_refresh()


func _process(delta: float) -> void:
	_time += delta
	for i in range(_hunters.size()):
		var n: Node3D = _hunters[i]
		if is_instance_valid(n):
			n.position.y = TILE_TOP + sin(_time * 2.1 + i * 1.7) * 0.035


# --- solo helpers -----------------------------------------------------
#
# Delegates to combat_3d.gd's own solo_view_slot/solo_cmd_slot/
# solo_private_view (via BEAST_MODEL, already preloaded above) instead of
# keeping a second hand-typed copy of the same routing. The two copies used
# to drift only in wording, never behaviour, but "used to" is exactly how
# the two-copies-of-one-truth bug class starts. #86 duty 3.

func _is_solo() -> bool:
	return bool(_client.shared.get("solo", false))

func _me() -> int:
	return BEAST_MODEL.solo_view_slot(_is_solo(), _active_slot, _client.you)

func _cmd_slot() -> int:
	return BEAST_MODEL.solo_cmd_slot(_is_solo(), _active_slot)

func _my_private() -> Dictionary:
	return BEAST_MODEL.solo_private_view(_is_solo(), _active_slot, _client.private)


# --- staging --------------------------------------------------------------

func _refresh() -> void:
	# A snapshot can land while the router is swapping this view out — the signal
	# is still connected for that window. Staging a detached scene aims a camera
	# that isn't in the tree and measures props that aren't either; nothing good
	# comes of it, and the frame it would build is about to be thrown away.
	#
	# Audited 2026-08-22 (backlog #7): legitimate, not masking a bug. `game_3d.gd`
	# connects its own `state_updated` listener before any child view exists, so on
	# every emission the router's `_sync()` always runs first; when a phase change
	# lands it calls `remove_child(_view); _view.queue_free()` on the OLD view
	# *immediately* (deliberately — see game_3d.gd, so both views don't render for
	# a frame), then instantiates the new one. `queue_free()` only defers the
	# node's destruction to end-of-frame — it does not disconnect signals — so the
	# OLD view's own `state_updated` handler, connected later (in its `_ready`) and
	# hence later in Godot's per-signal call order, still fires this same emission
	# against a node that has already left the tree. `combat_3d.gd` and
	# `overworld_3d.gd` share the same router and the same ordering, but dodge the
	# race for a different reason: their `_refresh` bails out itself the moment
	# `phase` no longer names them, before touching anything tree-dependent. This
	# view can't use that trick — one scene renders SEVERAL phases (select, reward,
	# event, campfire, shop, won, lost) — so it needs its own guard. Added in
	# 0934ea9915b2 ("staging stops shouting"), which took staging errors from 11
	# per staging to 0; removing it reintroduces them.
	if not is_inside_tree():
		return
	var s := _client.shared
	var phase := String(s.get("phase", ""))
	if phase == "":
		return
	if phase != _built:
		_built = phase
		_selected = -1
		_deck_pick = ""
		_shop_pick = -1
		_stage(s, phase)
	match phase:
		"select": _render_select(s)
		"reward": _render_reward(s)
		"event": _render_event(s)
		"campfire": _render_campfire(s)
		"shop": _render_shop(s)
		"won", "lost": _render_over(s, phase)


## Build the place. A small hex plot the hunters stand on, plus whatever the
## phase is *about* — for a reward, the beast lying behind them.
func _stage(s: Dictionary, phase: String) -> void:
	for c in _plot.get_children():
		c.queue_free()
	_hunters.clear()
	_felled_span = 0.0   # only a reward has a body to make room for
	# backlog #86 duty 2: ui/sfx.gd's DEFS has authored a distinct "win" (860Hz,
	# cheerful) and "lose" (120Hz, mournful) tone since the sound palette was
	# baked, but nothing in game/** ever called Sfx.play("win") or
	# Sfx.play("lose") — grepping every literal Sfx.play("...") call site turns
	# up card/climb/end_turn/lock/reach_sigil/reward/shake and stops there. The
	# WON/LOST screen (_render_over, right below) sets its title/subtitle text
	# on every refresh but never once reached for Sfx, so a run's actual ending
	# — the one moment the whole run built toward — played in total silence.
	# Same shape as the already-fixed combat.ogg gap (an authored asset with no
	# reachable call site), and this is the right choke point for the same
	# reason music_for_phase() is called from _sync(): _stage() only runs the
	# instant `phase` first becomes "won"/"lost" (guarded by `_refresh()`'s own
	# `phase != _built` check above), not on every later broadcast — so the
	# jingle can't be re-triggered by an ally's turn, an autosave tick, or any
	# other unrelated snapshot that lands while this screen stays up.
	var stinger := sfx_for_over(phase)
	if stinger != "":
		Sfx.play(stinger)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(phase + String(s.get("felled", "")))
	# The inner ring stays PLAIN grass: forest tiles carry trees, and trees where
	# the hunters and the body stand simply swallow them. Scenery goes outside.
	_tile("grass", 0, 0, rng)
	for i in range(_PLOT.size()):
		var at: Vector2i = _PLOT[i]
		var tile := "grass"
		if i >= 6:
			tile = ["grass", "grass", "grass-forest", "grass-hill"][rng.randi() % 4]
		_tile(tile, at.x, at.y, rng)
	if phase == "select":
		pass  # the roster itself is the staging — see _show_roster
	elif phase == "reward":
		var felled_id := String(s.get("felled", ""))
		# Ground first, and enough of it: a felled Titan sprawls wider than this
		# little plot, and a carcass overhanging open water is the same "floating"
		# read this whole fix exists to kill. Sized off the body that's coming.
		_widen_plot(rng, _felled_height(felled_id) * 0.78)
		_lay_out_the_felled(felled_id)
	elif phase == "event":
		_landmark("building-wizard-tower", Vector3(-1.0, 0.0, -1.55))
	elif phase == "campfire":
		_landmark("building-cabin", Vector3(-1.0, 0.0, -1.55))
	elif phase == "shop":
		_landmark("building-market", Vector3(-1.0, 0.0, -1.55))
	if phase != "select":
		_place_hunters(s)
	# the card row owns the bottom of the screen here too, so the scene is
	# aimed and offset to sit clear of it — same trick as the combat view.
	# A felled Titan sprawls several times a Crag Pup, so the shot backs off to
	# hold it rather than cropping the body the reward is FOR.
	# Derived from the body's measured sprawl and the lens, not hand-tuned offsets:
	# a felled Crag Pup and a felled Titan differ by three times, and coefficients
	# that framed one cropped the other.
	var need := maxf(4.5, _felled_span * 1.9)
	var back := need / (2.0 * tan(deg_to_rad(_cam.fov) * 0.5))
	_cam.position = Vector3(0.0, back * 0.55, back * 1.05)
	_cam.look_at(Vector3(0.0, 0.4 + _felled_span * 0.22, -1.1), Vector3.UP)


static func _hex_x(hex_col: int, hex_row: int) -> float:
	return hex_col * HEX_W + (HEX_W * 0.5 if absi(hex_row) % 2 == 1 else 0.0)


func _tile(name: String, hex_col: int, hex_row: int, rng: RandomNumberGenerator) -> void:
	var path := Tiles.path(name)
	if not ResourceLoader.exists(path):
		return
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	inst.position = Vector3(_hex_x(hex_col, hex_row), 0.0, -hex_row * ROW_STEP)
	inst.rotation.y = float(rng.randi_range(0, 5)) * (PI / 3.0)
	_plot.add_child(inst)


## The beast you just brought down, on its side. It is the only reason the
## reward exists, and a flat panel never said so.
func _lay_out_the_felled(beast_id: String) -> void:
	# Same rule as the fight: your own cast/<beast_id>.glb beats the stand-in, so
	# the beast you felled is the beast lying here rather than the elephant it
	# used to be standing in for.
	var path := CAST + beast_id + ".glb"
	if beast_id == "" or not ResourceLoader.exists(path):
		var key: String = String((BEAST_MODEL.MODELS as Dictionary).get(beast_id, ""))
		path = CAST + key + ".glb"
		if key == "" or not ResourceLoader.exists(path):
			return
	var body: Node3D = (load(path) as PackedScene).instantiate()
	_plot.add_child(body)
	var tall := _felled_height(beast_id)
	_fit_height(body, tall)
	_felled_span = tall
	# Onto its BACK, feet toward the camera — a cube pet tipped onto its flank
	# still reads as sitting, but belly-up is unmistakable.
	body.rotation = Vector3(-PI * 0.5, 0.35, 0.0)
	body.position = Vector3.ZERO
	# Measure, then correct. A toppled body sprawls by its full standing height,
	# and where a model's origin sits inside that sprawl differs per beast — the
	# old fixed offset sent it off the BACK of the island to hang over the sea,
	# which is why the trophy looked like it was floating. Place it, look at where
	# it actually landed, and shift by the difference.
	var b := _bounds_in_parent(body)
	body.position += Vector3(-b.get_center().x,
		TILE_TOP - b.position.y,
		FELLED_Z - b.get_center().z)
	# What the shot has to hold: the body's real sprawl, not the height we asked
	# for. These models are near-cubic, so a beast scaled to 2.3 tall still lies
	# 2.8 across — frame off the target and the trophy gets its head cropped.
	_felled_span = maxf(b.size.x, maxf(b.size.y, b.size.z))


## Extra ground out to `radius`, filling in whatever _PLOT doesn't already cover.
## Circular rather than following _PLOT's hand-placed shape, so it stays right at
## any size — and the other phases, which need no extra room, never call it and
## keep the plot exactly as it was.
func _widen_plot(rng: RandomNumberGenerator, radius: float) -> void:
	if radius <= 2.2:   # _PLOT already reaches about this far
		return
	var have := {Vector2i(0, 0): true}
	for at in _PLOT:
		have[at] = true
	for row in range(-6, 7):
		for col in range(-6, 7):
			var key := Vector2i(col, row)
			if have.has(key):
				continue
			if Vector2(_hex_x(col, row), -row * ROW_STEP).length() > radius:
				continue
			_tile(["grass", "grass", "grass", "grass-forest"][rng.randi() % 4],
				col, row, rng)


## How big the body lying here should be, from the climb the beast demanded.
## Reads the beast's own data rather than anything the snapshot happens to carry,
## so it stays right if the reward payload ever changes shape.
##
## Static and untouched by anything on self, so run_tests.gd can prove the size
## curve headless — no scene tree, no model loaded. #86 duty 3.
static func _felled_height(beast_id: String) -> float:
	var boss: Boss = Content.build_boss(beast_id)
	if boss == null:
		return FELLED_MIN
	var t := clampf((float(boss.weak_point_height) - 1.0) / (FELLED_MAX_WP - 1.0), 0.0, 1.0)
	return lerpf(FELLED_MIN, FELLED_MAX, t)


## A hex landmark stood up as scenery — the same tile the overworld uses for
## that node type, so arriving somewhere looks like the place you walked to.
func _landmark(name: String, at: Vector3) -> void:
	var path := Tiles.path(name)
	if not ResourceLoader.exists(path):
		return
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	inst.position = at
	_plot.add_child(inst)


func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	for i in range(players.size()):
		var id := String((players[i] as Dictionary).get("character", ""))
		if id == "":
			id = String((players[i] as Dictionary).get("portrait", "")) \
				.get_file().get_basename()
		# Your art first — same rule as the fight (ui/cast.gd).
		var path := Cast.model_path(id)
		if not ResourceLoader.exists(path):
			continue
		var n: Node3D = (load(path) as PackedScene).instantiate()
		_plot.add_child(n)
		# Width capped a shade under the height, so the widest hunter still reads
		# as one of the row rather than as scenery.
		_fit_height(n, HUNTER_HEIGHT, HUNTER_HEIGHT * 0.9)
		n.position = Vector3(-0.78 + 1.56 * float(i), TILE_TOP, -0.15)
		# facing the camera, angled toward each other — models face +Z, so PI
		# here would show you nothing but their backs
		n.rotation.y = 0.4 if i == 0 else -0.4
		_hunters.append(n)


## Scale a model to a target world height, measured — see design/blender-pipeline.md.
func _fit_height(node: Node3D, want: float, max_wide := 0.0) -> void:
	var box := _bounds(node)
	node.scale = Vector3.ONE * fit_height_scale(box.size, want, max_wide)


## The scale-selection rule inside _fit_height, pure (#86 duty 3): given a
## model's own bounds size, the height it should reach, and an optional width
## cap, which multiplier actually gets used.
##
## HEIGHT ALONE IS THE WRONG MEASURE FOR A SQUAT BODY.
##
## Nick, 2026-09-08: the Frog is still enormous on the character select. It is
## fitted to the same HUNTER_HEIGHT as everyone else and obeys it exactly —
## but a frog is 1.72 wide and 1.15 tall where the Vine-Weaver is 0.80 wide
## and 1.85 tall, so making them equally TALL makes the frog nearly three
## times as WIDE on screen.
##
## Worse, shortening the frog's model (2026-09-08, frog.py height 1.85 -> 1.15)
## made this screen worse rather than better: less height to reach the target
## means a bigger multiplier, so the width grew again. The model change was
## right for the fight and wrong here, because here nothing was clamping width.
##
## So take whichever limit binds first. Anything with a normal body plan is
## unaffected — their height is what binds, exactly as before.
static func fit_height_scale(box_size: Vector3, want: float, max_wide: float) -> float:
	var k := want / maxf(box_size.y, 0.001)
	if max_wide > 0.0:
		var wide := maxf(box_size.x, box_size.z)
		k = minf(k, max_wide / maxf(wide, 0.001))
	return k


## Bounds of everything under `node`, in NODE'S OWN space.
##
## Deliberately not `global_transform`. That needs the node to be inside the
## scene tree, and staging measures a model the instant it is built — including
## on snapshots that land while this view is being swapped out, which threw about
## a dozen errors per staging and left the first drawn frame mis-framed. Walking
## the local chain needs no tree at all.
##
## Measuring in the node's own space is also the honest answer: a model's size
## should not change because something above it happens to be scaled.
##
## Static (#86 duty 3): touches nothing on self, only the node chain it's
## handed, so run_tests.gd can prove the felled-beast placement math (the
## "floating trophy" bug class this function exists to prevent — see
## _lay_out_the_felled's own comment) with a bare Node3D/MeshInstance3D/BoxMesh
## tree and no model loaded, the same lift already done for combat_3d's
## foothold_anchor/route_between_rungs.
static func _bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for m in _meshes(node):
		var mi: MeshInstance3D = m
		var b: AABB = _relative_xform(mi, node) * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


## The same bounds seen by the node's PARENT — so it includes the node's own
## rotation and scale. What you want after toppling something on its back: only
## then is its upright height lying sideways.
static func _bounds_in_parent(node: Node3D) -> AABB:
	return node.transform * _bounds(node)


## Transform of `from` expressed in `to`'s space, by walking the parent chain.
## Pure arithmetic on local transforms — works on a node that was built a moment
## ago and has never been in the tree.
static func _relative_xform(from: Node3D, to: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var n: Node = from
	while n != null and n != to:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t


static func _meshes(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		out += _meshes(c)
	return out


## Right-clicking a keyword on a card you are being offered explains it, the same
## as it does in a fight. Its own small overlay: this scene has no card inspector,
## and the question ("what is Poison") does not need one.
func _show_keyword(kw: Dictionary) -> void:
	if kw.is_empty() or _kw_popup != null and is_instance_valid(_kw_popup):
		if _kw_popup != null and is_instance_valid(_kw_popup):
			_kw_popup.queue_free()
			_kw_popup = null
		if kw.is_empty():
			return
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.03, 0.02, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			shade.queue_free()
			_kw_popup = null)
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	layer.add_child(shade)
	_kw_popup = layer

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 16.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)
	var title := RichTextLabel.new()
	title.bbcode_enabled = true
	title.text = "[u]%s[/u]" % String(kw.get("name", ""))
	title.fit_content = true
	title.scroll_active = false
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("normal_font_size", 18)
	title.add_theme_color_override("default_color", Color(1, 0.86, 0.5))
	col.add_child(title)
	var body := Label.new()
	body.text = String(kw.get("text", ""))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(328, 0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color(0.86, 0.82, 0.74))
	col.add_child(body)


# --- the reward ------------------------------------------------------------

## The REWARD phase is reached three ways — a felled beast, a felled Titan, or a
## treasure cache you simply walked up to — and only one of them involves
## felling a Titan. Lifted out of _render_reward so the headline/subtitle/
## prompt rules can be tested without a scene tree.
static func reward_header_text(node_type: String, encounter: int, total_encounters: int,
		is_relic: bool, picked: bool, has_selection: bool, solo: bool,
		active_hunter_name: String) -> Dictionary:
	var title: String
	match node_type:
		"boss":
			title = "Titan felled!   (%d / %d)" % [encounter, total_encounters]
		"elite":
			title = "The elite falls."
		"treasure":
			title = "A cache in the rocks"
		"event":
			title = "A find on the road"
		_:
			title = "The beast falls."
	var subtitle := ("Choose a RELIC — a lasting boon for the team."
		if is_relic else "Choose a card to strengthen your deck for the next Titan.")
	var noun := "relic" if is_relic else "card"
	var prompt: String
	if picked:
		prompt = "Locked in — waiting for your ally"
	elif has_selection:
		prompt = "Tap another to change, or Lock In your %s" % noun
	else:
		prompt = "%sTap a %s to select" % [
			("%s picks:   " % active_hunter_name) if solo else "", noun]
	return {"title": title, "subtitle": subtitle, "prompt": prompt}


func _render_reward(s: Dictionary) -> void:
	var reward: Dictionary = _my_private().get("reward", {})
	var is_relic := String(reward.get("kind", "card")) == "relic"
	var picked := bool(reward.get("picked", false))
	var solo := _is_solo()
	var header := reward_header_text(String(s.get("node_type", "boss")),
		int(s.get("encounter", 1)), int(s.get("total_encounters", 1)),
		is_relic, picked, _selected >= 0, solo, _hunter_name(_active_slot))
	_title.text = String(header["title"])
	_subtitle.text = String(header["subtitle"])
	_prompt.text = String(header["prompt"])

	for c in _row.get_children():
		c.queue_free()
	for choice in reward.get("choices", []):
		var idx := int(choice["index"])
		var cv := CardView.new()
		_row.add_child(cv)
		cv.setup(choice, not picked)
		cv.modulate = Color(1, 1, 1) if (_selected == idx or _selected < 0) \
			else Color(0.62, 0.6, 0.56)
		cv.keyword_requested.connect(_show_keyword)
		cv.tapped.connect(func() -> void:
			if picked:
				return
			Sfx.play("card")
			_selected = idx
			_render_reward(_client.shared))

	for c in _controls.get_children():
		c.queue_free()
	# selection is client-side; the host only ever hears the locked choice
	var lock := _button("Lock In Reward", func() -> void:
		Sfx.play("lock")
		_client.pick_card(_selected, _cmd_slot())
		_selected = -1)
	lock.disabled = picked or _selected < 0
	_controls.add_child(lock)
	if not picked:
		_controls.add_child(_button("Skip — keep the deck lean", func() -> void:
			Sfx.play("lock")
			_client.skip_reward(_cmd_slot())
			_selected = -1))
	if solo:
		_controls.add_child(_button("▶ Switch to %s" % _hunter_name(1 - _active_slot),
			func() -> void:
				_active_slot = 1 - _active_slot
				_selected = -1
				_render_reward(_client.shared)))


# --- wayside events --------------------------------------------------------

func _render_event(s: Dictionary) -> void:
	var ev: Dictionary = s.get("event", {})
	_title.text = String(ev.get("title", "On the way"))
	_subtitle.text = String(ev.get("text", ""))
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()
	# an event can offer more than two choices, so they stack in the card row
	# rather than crowding the single control strip
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_END
	stack.add_theme_constant_override("separation", 8)
	_row.add_child(stack)
	for i in range(ev.get("choices", []).size()):
		var ch: Dictionary = (ev["choices"] as Array)[i]
		var idx := i
		var b := _button("%s     %s" % [String(ch.get("label", "…")),
			_stakes(ch.get("effects", {}))], func() -> void:
				Sfx.play("card")
				_client.pick_event(idx))
		b.custom_minimum_size = Vector2(560, 44)
		stack.add_child(b)


## Spell the stakes out on the button — an event should never be a blind pick.
## Same rule the 2D screen follows, and the same wording.
##
## Static, and already pure (only ever reads `eff`) — this is the text a
## player reads before picking a wayside event choice, and until #86 duty 3
## it had zero coverage: a formatting slip here (say, the sign on a `max_hp`
## penalty) would silently misdescribe a real choice to a real player, with
## nothing in run_tests.gd able to catch it.
##
## backlog #86 duty 2: this hand-lists the effect keys it knows how to
## describe, and it had drifted from the real list — `Run._apply_effect_block`
## (and events.json's own `_comment`) also handle `potion`/`random_potion`/
## `take_potion`/`key`. Worst case was `the_sealed_hollow`'s "Force the seal"
## (`{"heal": -6, "key": true}`), which grants one of the three keys the real
## final Titan needs — the single most consequential effect any event can
## grant — and showed the player only "(-6 HP)", with the key invisible.
## `abandoned_apothecary`'s "Take the marked vial" (`{"potion": "..."}` alone)
## was worse still: no HP/gold/relic/reward to fall back on, so `bits` stayed
## empty and the button showed no stakes at all, indistinguishable from a
## true no-op choice.
##
## backlog #86 duty 2 (second pass): the note above used to excuse
## `remove_card`/`sharpen_card`/`curse_card` as "already spelled out in every
## event's hand-authored label text" — true of every events.json choice that
## uses them, but `_apply_effect_block` is shared with `pick_boon` (a boon IS
## an event choice, run.gd:639), and boons.json's `a_bold_trade`
## (`{"sharpen_card": true, "curse_card": "bruised_grip"}`) breaks the
## assumption: its label is just "Take the bold trade", naming neither
## effect. That left `_stakes` silently blank for a live data entry the day
## the BOON phase gets a screen (it has none yet — `game_3d.gd`'s phase
## router has no case for Phase.BOON), same "no stakes shown"
## failure `abandoned_apothecary` already demonstrates. Give these three the
## same explicit treatment as every other key here instead of trusting labels
## to cover for it.
static func _stakes(eff: Dictionary) -> String:
	var bits: Array[String] = []
	var h := int(eff.get("heal", 0))
	if h > 0:
		bits.append("+%d HP" % h)
	elif h < 0:
		bits.append("%d HP" % h)
	var mh := int(eff.get("max_hp", 0))
	if mh != 0:
		bits.append("%+d max HP" % mh)
	var g := int(eff.get("gold", 0))
	if g != 0:
		bits.append("%+d gold" % g)
	if bool(eff.get("relic", false)):
		bits.append("relic")
	if bool(eff.get("remove_card", false)):
		bits.append("-1 card")
	if bool(eff.get("sharpen_card", false)):
		bits.append("sharpen a card")
	var cc := String(eff.get("curse_card", ""))
	if cc != "":
		bits.append("+1 %s" % Content.make_card(cc).name)
	var rw := String(eff.get("reward", ""))
	if rw != "":
		bits.append("choose a " + rw)
	var pid := String(eff.get("potion", ""))
	if pid != "":
		bits.append(String(Content.make_potion(pid).get("name", pid)))
	if bool(eff.get("random_potion", false)):
		bits.append("a potion")
	if bool(eff.get("take_potion", false)):
		bits.append("-1 potion")
	if bool(eff.get("key", false)):
		bits.append("a key")
	return "(%s)" % "  ·  ".join(bits) if not bits.is_empty() else ""


# --- the run ending --------------------------------------------------------

## Which one-shot stinger (ui/sfx.gd's DEFS) plays the moment the run reaches
## its ending, keyed by phase. Lifted static, the same idiom
## `Game3D.music_for_phase()` uses, so run_tests.gd can prove the mapping
## headless with no scene tree and no audio device. #86 duty 2.
static func sfx_for_over(phase: String) -> String:
	match phase:
		"won": return "win"
		"lost": return "lose"
		_: return ""


func _render_over(s: Dictionary, phase: String) -> void:
	var won := phase == "won"
	_title.text = "The last Titan falls." if won else "The hunt ends here."
	# `result` is a bare token for the log, not something to show a player
	_subtitle.text = ("Every Titan in the range has been brought down. Ascension %d cleared."
		% int(s.get("ascension", 0))) if won else 		"The range keeps its Titans. Take what you learned and climb again."
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()
	_controls.add_child(_button("Hunt again", func() -> void: _client.restart()))
	_controls.add_child(_button("Return to menu", func() -> void:
		get_tree().change_scene_to_file("res://views/menu.tscn")))


## Pure form of the clamp math below: takes the viewport width and the
## handheld/desktop floor explicitly instead of reading get_viewport() and
## Screen.is_handheld(), so run_tests.gd can prove the curve headless -- no
## scene tree, no viewport. #86 duty 3.
static func _roster_card_width_for(wide: float, count: int, floor_w: float) -> float:
	var room: float = wide - 40.0 - 10.0 * float(maxi(count - 1, 0))
	return clampf(room / float(maxi(count, 1)), floor_w, 268.0)


## How wide one hunter card can be, given how many there are and how much room.
##
## Clamped BELOW as well as above: past a point a narrower card just wraps its
## description into a column of single words, which is worse than swiping.
func _roster_card_width(count: int) -> float:
	# This view is a Node3D, so there is no get_viewport_rect() on self — the
	# viewport's visible rect is already in the same scaled space Controls
	# lay out in, which is what the cards are measured against.
	var wide: float = get_viewport().get_visible_rect().size.x
	var floor_w := 168.0 if Screen.is_handheld() else 190.0
	return _roster_card_width_for(wide, count, floor_w)


func _button(text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(190, 40)
	b.pressed.connect(on_press)
	return b


func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	if slot < 0 or slot >= players.size():
		return "Hunter %d" % (slot + 1)
	return String((players[slot] as Dictionary).get("name", "Hunter %d" % (slot + 1)))


# --- choosing your hunter --------------------------------------------------

## The lobby, staged like everywhere else. Picking a hunter in 3D means you see
## the body you'll be climbing with, at the size it'll actually be — which a row
## of portrait cards never told you.
func _render_select(s: Dictionary) -> void:
	var roster: Array = _client.private.get("characters", [])
	var solo := bool(s.get("solo", false))
	var slot := int(s.get("current_slot", 0)) if solo else _client.you
	_title.text = "Choose your hunter" if not solo \
		else "Choose Hunter %d's climber" % (slot + 1)
	var joined := int(s.get("joined", 1))
	var required := int(s.get("required", 1))
	_subtitle.text = "Waiting for hunters — %d of %d here." % [joined, required] \
		if joined < required else "Nobody climbs this alone. Pick who you'll be."
	_clear_ui()
	_show_roster(roster)
	# The roster SCROLLS sideways rather than trusting it to fit.
	#
	# It used to be a plain row of 268px buttons. Four of those already
	# overflowed a 1280 desktop; when the cloud added a fifth hunter nothing
	# complained, and on a phone — where the interface runs at about 519 logical
	# pixels wide — two of the five were sliced off at the edges and could be
	# neither read nor reliably tapped. A row that MUST fit is a row that breaks
	# the next time someone adds a character.
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 104)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	scroll.add_child(row)
	_controls.add_child(scroll)
	for i in range(roster.size()):
		var c: Dictionary = roster[i]
		var id := String(c.get("id", ""))
		var b := _button("%s\n%s" % [String(c.get("name", id)), String(c.get("desc", ""))],
			func() -> void:
				Sfx.play("lock")
				_client.select_character(id, slot if solo else -1))
		# Fit the row to the space there IS, down to a floor where the text stops
		# being readable — below that it scrolls instead of shrinking further. So a
		# desktop shows all five and a phone shows three and a bit, and neither has
		# to know how many hunters exist.
		b.custom_minimum_size = Vector2(_roster_card_width(roster.size()), 96)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(b)


## Line the whole roster up on the plot, so the buttons below name bodies you
## can see rather than words on their own.
func _show_roster(roster: Array) -> void:
	for n in _hunters:
		if is_instance_valid(n):
			(n as Node3D).queue_free()
	_hunters.clear()
	var span := 1.05
	var left := -span * (float(roster.size()) - 1.0) * 0.5
	for i in range(roster.size()):
		# Ask Cast, which prefers your own art over the Kenney stand-in. This line
		# used to carry its own copy of the placeholder table and so kept showing a
		# bunny for the Frog long after frog.glb existed — the character select is
		# the ONE screen whose whole job is showing you who you are picking.
		var path := Cast.model_path(String((roster[i] as Dictionary).get("id", "")))
		if not ResourceLoader.exists(path):
			continue
		var n: Node3D = (load(path) as PackedScene).instantiate()
		_plot.add_child(n)
		# Width capped a shade under the height, so the widest hunter still reads
		# as one of the row rather than as scenery.
		_fit_height(n, HUNTER_HEIGHT, HUNTER_HEIGHT * 0.9)
		n.position = Vector3(left + span * float(i), TILE_TOP, -0.4)
		_hunters.append(n)


# --- the campfire ----------------------------------------------------------

func _render_campfire(s: Dictionary) -> void:
	var cf: Dictionary = s.get("campfire", {})
	var priv := _my_private()
	var deck: Array = priv.get("deck", [])
	var done := bool(priv.get("done", false))
	_title.text = "Campfire"
	_clear_ui()
	if done:
		_subtitle.text = "%s is done — waiting for your ally." % _hunter_name(_me())
		_add_switch()
		return
	if _deck_pick != "":
		var removing := _deck_pick == "remove"
		_subtitle.text = ("Choose a card to remove — it leaves the deck for good."
			if removing else "Choose a card to sharpen.")
		var action := _deck_pick
		# "remove" can target any card; "upgrade" cannot — filtered to the same
		# cards campfire_can_sharpen() would count, so the picker never offers a
		# card Run.campfire_action() is about to refuse (#86 duty 2).
		var pick_deck := deck if removing else campfire_sharpenable(deck)
		_deck_picker(pick_deck, func(i: int) -> void:
			Sfx.play("reward")
			_client.campfire(action, i, _cmd_slot())
			_deck_pick = "",
			_subtitle.text,
			"Remove this card for good" if removing else "Sharpen this card")
		_controls.add_child(_button("Back", func() -> void:
			_deck_pick = ""
			_refresh()))
		return
	_subtitle.text = "%s rests. A quiet hour before the climb — spend it how you like." \
		% _hunter_name(_me())
	var stack := _stack()
	stack.add_child(_button("Rest — recover %d HP" % campfire_heal_shown(cf),
		func() -> void:
			Sfx.play("reward")
			_client.campfire("rest", -1, _cmd_slot())))
	var can_thin: bool = campfire_can_thin(deck.size(), min_deck_shown(cf))
	var thin := _button("Thin the deck — remove a card" if can_thin
		else "Thin the deck — deck too small", func() -> void:
			_deck_pick = "remove"
			_refresh())
	thin.disabled = not can_thin
	stack.add_child(thin)
	var can_sharpen: bool = not campfire_sharpenable(deck).is_empty()
	var sharpen := _button("Sharpen — upgrade a card" if can_sharpen
		else "Sharpen — nothing left to sharpen", func() -> void:
			_deck_pick = "upgrade"
			_refresh())
	sharpen.disabled = not can_sharpen
	stack.add_child(sharpen)
	stack.add_child(_button("Look through your deck (%d)" % deck.size(), open_deck))
	_add_switch()


# --- the trader ------------------------------------------------------------

func _render_shop(s: Dictionary) -> void:
	var shop: Dictionary = s.get("shop", {})
	var stock: Array = shop.get("stock", [])
	var gold := int(s.get("gold", 0))
	_title.text = "A trader on the road"
	_clear_ui()
	if _shop_pick >= 0:
		_subtitle.text = "Choose a card to remove — it leaves the deck for good."
		var idx := _shop_pick
		_deck_picker(_my_private().get("deck", []), func(i: int) -> void:
			Sfx.play("reward")
			_client.buy(idx, i)
			_shop_pick = -1,
			_subtitle.text,
			"Remove this card for good")
		_controls.add_child(_button("Back", func() -> void:
			_shop_pick = -1
			_refresh()))
		return
	_subtitle.text = "Purse: %d gold. One purse between you — spend it well." % gold
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 6)
	# hug the bottom, so eight stock items don't bury the place you walked to
	grid.size_flags_vertical = Control.SIZE_SHRINK_END
	_row.add_child(grid)
	var min_deck := min_deck_shown(shop)
	var potion_slots := potion_slots_shown(shop)
	for i in range(stock.size()):
		grid.add_child(_stock_button(stock[i], i, gold, min_deck, potion_slots))
	_controls.add_child(_button("Your deck", open_deck))
	_controls.add_child(_button("Move on →", func() -> void:
		Sfx.play("end_turn")
		_client.leave_shop()))
	_add_switch()


## Mirrors Run.buy()'s own gate (run.gd:507-525) so the button a player sees
## never lies about what the server will actually accept — a sold slot stays
## disabled regardless of gold, and affording exactly the price is enough
## (the boundary is "<", not "<=", same as the server's check).
##
## `is_remove`/`deck_size`/`min_deck` mirror the OTHER half of that same gate:
## a "remove" ("Thin the deck") item is also refused once the target hunter's
## deck is already at MIN_DECK (run.gd:525, "deck.size() <= MIN_DECK"). Until
## #86 duty 2 this function only ever checked sold/gold/price, so a "remove"
## slot for a deck already at the floor rendered enabled — affordable and
## unsold — right up until the click, where Run.buy() silently refused it and
## the button came back looking exactly the same, with no explanation. The
## sibling gate for this same rule, campfire_can_thin() below, already got it
## right; this one just never carried it.
##
## `is_potion`/`held`/`potion_slots` are the SAME shape for the OTHER hidden
## refusal in Run.buy() — "potion": `potions[slot].size() >= POTION_SLOTS`
## (run.gd, the "potion" branch). The comment above this fix used to claim
## "Defaults keep every non-'remove' call (cards, relics, potions) behaving
## exactly as before" and stopped there: cards and relics really have no
## such cap, but a hunter who already holds POTION_SLOTS potions (won from
## felling beasts, before ever reaching this shop) saw an enabled, priced
## "buy" button for a fourth — affordable and unsold — that Run.buy()
## silently refused with no gold spent and no feedback, the exact bug the
## "remove" fix above was written to close, just for the one sibling kind it
## missed (#86 duty 2).
static func shop_slot_disabled(sold: bool, gold: int, price: int,
		is_remove: bool = false, deck_size: int = 0, min_deck: int = 0,
		is_potion: bool = false, held: int = 0, potion_slots: int = 0) -> bool:
	return sold or gold < price or (is_remove and deck_size <= min_deck) \
		or (is_potion and held >= potion_slots)


## Mirrors Run.campfire_action()'s own gate (run.gd:583) so the "Thin the
## deck" button never offers a trim the server will refuse — the boundary is
## "<=", not "<": a deck sitting exactly on the floor may not shrink further,
## the same rule campfire_action() enforces for "remove". #86 duty 3.
static func campfire_can_thin(deck_size: int, min_deck: int) -> bool:
	return deck_size > min_deck


## The HP the Rest button promises, from the campfire dict game_host.gd's
## `_build_shared()` sends. #86 duty 2: the `.get()` fallback here used to be
## a bare `12` — a second, independent guess at "what a rest heals" that
## nobody kept in sync with the real rule. It had already drifted from
## `Run.REST_HEAL` (9) itself, let alone `Run.rest_heal_amount()`'s
## ascension-adjusted real value — the exact "two copies of one truth" shape
## `_build_shared()`'s own `campfire.heal` fix (game_host.gd, right above
## this file's `"campfire"` read) closed at the snapshot layer, just one
## layer further out: every snapshot with `phase == CAMPFIRE` always carries
## a real "heal" (`_build_shared()`'s campfire branch sets it unconditionally
## and `_refresh()` only calls `_render_campfire()` off that same snapshot),
## so this fallback is never actually reached today. Pinned to the true
## unmodified constant anyway, so a fallback nobody hits yet stops being a
## live lie about the rule the moment anything changes that.
static func campfire_heal_shown(cf: Dictionary) -> int:
	return int(cf.get("heal", Run.REST_HEAL))


## The deck floor `_render_campfire()`'s "Thin the deck" gate and
## `_render_shop()`'s "remove" gate both read from a campfire/shop snapshot
## dict — mirroring `Run.MIN_DECK`. #86 duty 2: both call sites' `.get()`
## fallback here used to be a bare `5` — a second, independent guess at the
## deck floor that nobody kept in sync with `Run.MIN_DECK`, the exact "two
## copies of one truth" shape `campfire_heal_shown()`'s own `Run.REST_HEAL`
## fix closed right above. `game_host.gd`'s `_build_shared()` always sends a
## real `"min_deck"` for both `"campfire"` and `"shop"` today, so this
## fallback is never actually reached — pinned to the true constant anyway,
## same reasoning as `campfire_heal_shown()`.
static func min_deck_shown(d: Dictionary) -> int:
	return int(d.get("min_deck", Run.MIN_DECK))


## The potion cap `_render_shop()`'s "potion" gate reads from the shop
## snapshot dict — mirroring `Run.POTION_SLOTS`, the same "two copies" shape
## as `min_deck_shown()` right above, for the shop's other hardcoded-literal
## fallback (`3`). #86 duty 2.
static func potion_slots_shown(shop: Dictionary) -> int:
	return int(shop.get("potion_slots", Run.POTION_SLOTS))


## Filters to the cards the sharpen picker may offer, so it never hands the
## server one Run.campfire_action() is about to refuse.
##
## This used to re-derive Run.campfire_action()'s "upgrade" gate from just
## `upgraded`/`status` (run.gd's gate at the time: `if c.upgraded or c.status:
## return false`). That was a second copy of the gate, and it drifted the day
## the gate grew a third condition, `would_upgrade_change_anything()` (backlog
## #86 duty 2/3, run.gd) — a card that is fresh and curse-free but already has
## nothing left to bump, cheapen, or grant retain (cost already 0, already
## `retain`) kept passing this filter and reaching Run.campfire_action(),
## which silently refused it, burning the hunter's one campfire action for
## nothing.
##
## `would_upgrade_change_anything()` needs the real Card — rule_upgrade,
## enchants, history — which a client holding a display-only face dict does
## not have (same reason the "upgrade" preview is built server-side in
## game_host._deck_cards, not here). So instead of a second copy of the gate,
## this reads the one verdict the host already computed and sent:
## `face["sharpenable"]`, set in game_host._deck_cards from the real Card.
## There is now exactly one place that decides eligibility.
static func campfire_sharpenable(deck: Array) -> Array:
	return deck.filter(func(entry: Dictionary) -> bool:
		return bool(entry.get("sharpenable", false)))


func _stock_button(item: Dictionary, index: int, gold: int, min_deck: int, potion_slots: int = Run.POTION_SLOTS) -> Button:
	var price := int(item["price"])
	var sold := bool(item["sold"])
	var owner := int(item.get("slot", -1))
	var who := "" if owner < 0 else "  (%s)" % _hunter_name(owner)
	var is_remove := String(item.get("kind", "")) == "remove"
	var deck_size := int(item.get("deck_size", 0))
	var too_thin := is_remove and deck_size <= min_deck
	var is_potion := String(item.get("kind", "")) == "potion"
	var held := int(item.get("held", 0))
	var too_full := is_potion and held >= potion_slots
	var b := Button.new()
	b.custom_minimum_size = Vector2(258, 74)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.text = "%s\n%s%s\n%s" % [
		"SOLD" if sold else ("deck too small" if too_thin else ("potions full" if too_full else "%d gold" % price)),
		String(item.get("name", "?")), who, String(item.get("text", ""))]
	b.disabled = shop_slot_disabled(sold, gold, price, is_remove, deck_size, min_deck,
		is_potion, held, potion_slots)
	if not b.disabled:
		var idx := index
		b.pressed.connect(func() -> void:
			# a removal has to name a card too, so it opens the deck picker
			if String(item.get("kind", "")) == "remove":
				_shop_pick = idx
				_refresh()
			else:
				Sfx.play("reward")
				_client.buy(idx))
	return b


# --- shared UI helpers -----------------------------------------------------

func _clear_ui() -> void:
	_prompt.text = ""
	for c in _row.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()


func _stack() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 8)
	_row.add_child(v)
	return v


## Your persistent deck, as a grid you pick one card from. Compact buttons rather
## than CardViews: a deck runs well past a dozen cards and full card faces don't
## fit the strip — the name and cost are what you're choosing on anyway.
## Choose a card from your deck — the deck SCREEN, not a list of names.
##
## This was a grid of text buttons reading "Tongue Snap   1". Fine for
## "remove a card", thin for anything else, and actively wrong for SHARPEN: the
## only question being asked is what the card becomes, and the answer was not on
## screen anywhere. DeckView already draws a card beside its upgraded twin, so
## the campfire asking its question through that screen is less code here and a
## better answer there.
##
## `prompt` is the question, `action` the confirm button's words.
func _deck_picker(deck: Array, on_pick: Callable, prompt: String = "",
		action: String = "Choose this card") -> void:
	if get_node_or_null("DeckView") != null:
		return
	var v := DeckView.open(self, deck, prompt, action, on_pick)
	# backlog #86 duty 2 (two copies of one truth): "a picker is open" lived in
	# both _deck_pick/_shop_pick and this node's own existence. Cancelling out
	# of the picker (Escape, or its own Cancel button) used to free the node
	# and leave the flag set, so the next unrelated refresh (an ally acting,
	# a periodic sync) popped the picker back open unprompted. A successful
	# pick already clears its own flag from inside `on_pick`, so resetting it
	# again here is a harmless no-op on that path.
	v.closed.connect(func() -> void:
		_deck_pick = ""
		_shop_pick = -1
		_refresh())


## Browse the deck, changing nothing. Reachable from the campfire and the
## trader, and from the dev console's `deck`.
##
## Returns whether a DeckView is now actually showing (already open, or just
## built) — backlog #86 duty 2: this used to be void, so console.gd's
## `_cmd_deck()` had no way to tell "opened it" apart from "there was nothing
## to open" and reported "deck open" either way. `_my_private()` only carries
## a "deck" key in COMBAT/CAMPFIRE/SHOP (game_host.gd's `_slot_private()`
## returns {} for every other phase) — MAP, EVENT, REWARD, SELECT, WON and
## LOST all read back an empty deck here, so the dev console's `deck` command
## claimed success on six of the game's nine phases while building nothing at
## all.
func open_deck() -> bool:
	if get_node_or_null("DeckView") != null:
		return true  # already open
	var deck: Array = _my_private().get("deck", [])
	if deck.is_empty():
		return false
	DeckView.open(self, deck)
	return true


func _add_switch() -> void:
	if _is_solo():
		_controls.add_child(_button("▶ Switch to %s" % _hunter_name(1 - _active_slot),
			func() -> void:
				_active_slot = 1 - _active_slot
				_deck_pick = ""
				_shop_pick = -1
				_refresh()))
