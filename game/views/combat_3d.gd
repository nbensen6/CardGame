## 3D combat view — the SAME authoritative snapshots, rendered in a 3D scene.
##
## This is CLAUDE.md §2's layering rule paying off: /core and /session don't know
## or care that the game became 3D. It began as a second client beside the 2D
## `combat_view.gd`, reading identical `shared`/`private` dicts; that one has
## since been retired, and this is the only fight screen.
##
## The climb stops being an abstraction here — Height IS vertical position on the
## beast's body, so a hunter at the weak point is literally up at the weak point.
##
## The models are static low-poly props, so everything that moves is procedural:
## breathing, idle sway, climb hops, recoil, flashes, camera shake. That reads far
## better than static toys and costs no animation budget.
extends Node3D

const CAST := "res://assets/3d/cast/"
const ENV := "res://assets/3d/env/"
## Every environment is built to this floor radius — see tools/blender/env.py.
const ENV_RADIUS := 6.0
## Which model plays each BEAST, until real art exists. Hunters are not in here:
## they come from ui/cast.gd, which prefers your own art, and keeping a second
## copy of that mapping is what kept the Frog looking like a bunny on the
## character select long after frog.glb existed.
const MODELS := {
	# every beast gets its OWN body — the map's variety is pointless if ten of
	# the fourteen fights look like the same elephant. Chosen to echo the 2D
	# portrait where a Cube Pet exists, and to never reuse a hunter's model.
	"stone_warden": "elephant", "gale_serpent": "caterpillar",
	"drowned_colossus": "polar", "sunken_warden": "lion",
	"crag_pup": "dog", "bramble_hog": "pig", "bounder": "fox",
	"root_lurker": "beaver", "sky_snapper": "parrot", "riftling": "cat",
	"mire_snapper": "crab", "frost_sentinel": "penguin",
	"grove_bear": "panda", "shifting_idol": "tiger",
}
## Models are sized to a TARGET WORLD HEIGHT, measured off each mesh, never by a
## fixed multiplier. Two reasons. The Cube Pets already vary 1.55-2.13 units
## tall, so one multiplier made the two hunters differ by ~24% for no reason.
## And it means a model built in Blender at any scale drops straight in — the
## art pipeline shouldn't require matching someone else's units.
##
## A beast's height comes from how far you climb it, so a Titan with its sigil at
## Height 8 physically towers over a Crag Pup you can hit from the ground.
##
## Far bigger than they were (Nick, 2026-08-06: "much bigger, to feel like you are
## climbing something massive"). A Titan is ~17 hunters tall now instead of ~6 —
## the difference between a large animal and a colossus.
##
## Scale ALONE would have changed nothing, which is the part worth remembering:
## the camera used to fit the whole body in frame, so doubling a beast's size just
## pushed the camera twice as far back and looked identical. A shot that always
## contains the whole creature is a shot that says "toy on a table". See
## VIEW_WINDOW_* — the camera now shows a fixed slice of world, and a big beast
## simply overflows it.
## Beasts should read as COLOSSAL, not merely big (Nick, 2026-08-15). Raised from
## 4.0 / 1.2 — a final Titan now stands ~16 units rather than ~11, and the camera
## framing below follows the beast's measured height so it pulls back to suit.
## Retuned 2026-08-16 alongside the deeper climbs. Sigils moved from 1-8 to 4-13,
## and at the old 2.8-per-Height a Titan would have stood 46 units — half again
## the size Nick signed off on. Raising the base and flattening the slope keeps
## the biggest beast at the ~33 units that already read as colossal, while every
## lesser beast grows: the shallowest is now 18 units rather than 13, so nothing
## in the game reads as small any more.
const BEAST_BASE_HEIGHT := 12.0
const BEAST_HEIGHT_PER_CLIMB := 1.6
## How much vertical world the camera frames, in units — the constant that makes
## size legible. A beast shorter than this fits with air around it; a Titan runs
## off the top of the screen and you only ever see the stretch you're climbing.
## The vertical slice of world the camera tries to hold. Widened (Nick,
## 2026-08-15: "camera should start zoomed out more") — and it has to grow anyway
## now the beasts are half again as tall.
const VIEW_WINDOW_MIN := 9.0
const VIEW_WINDOW_MAX := 28.0
## How far the camera slides toward the hunter you are HOLDING, as a fraction of
## their offset from the beast's axis (Nick, 2026-08-23: the shot is too centred,
## and switching hunter should show you who you now control).
##
## Now 1.0 — a real lock rather than a lean (Nick, 2026-08-24: "make sure the
## camera locks on to a character when you select it"). The earlier 0.55 hedged
## against shoving the beast out of frame, but the hunters sit only a fifth of the
## body's width off its spine, so a full lock slides the shot about 8% of a frame:
## plainly "this one is mine", nowhere near enough to lose the body.
##
## The lock is also what makes free look survivable. The camera orbits AROUND the
## hunter you hold, so dragging changes your angle ON them instead of wandering
## off them.
const CAMERA_LOCK := 1.0

## The bottom strip the hand now occupies. The camera frames into what is LEFT of
## the screen and lifts its aim to match, so the beast stands in clear air instead
## of behind the cards. Without this, moving the hand to the bottom simply hid the
## lower third of every beast.
const HUD_BOTTOM_FRACTION := 0.34
## Real-time grip (SotC), the same client-side skill layer the 2D view runs: the
## instant a hunter leaves a safe hold a timer starts full and drains live; reach
## the next ledge before it empties or this client reports a fall. The host is
## told the OUTCOME, never the ticking timer.
const GRIP_SECONDS := 5.0
## Hunters are the scale reference — a beast only looks colossal NEXT TO something.
## Dropped from 0.8 (Nick, 2026-08-15: "beasts much bigger than the hunters"), which
## widens the ratio from both ends at once: a lesser beast is now ~22x a hunter and a
## Titan ~38x, where before it was 14x and 24x. Lowering this is cheaper than raising
## the beasts alone, because it costs no extra camera pull-back.
const HUNTER_HEIGHT := 0.7
## Orbit camera (Nick's call, 2026-08-05). The beast is a PLACE, so you can walk
## the camera around it. Auto-framing still sets the opening shot off the model's
## own size; dragging only takes over from there, and never below the ground or
## over the top.
const ORBIT_PITCH_MIN := -0.12   # radians below level — never under the floor
const ORBIT_PITCH_MAX := 1.32    # nearly overhead, but never gimbal-locked
const ORBIT_SENSITIVITY := 0.006
const PAN_SENSITIVITY := 0.0018   # world units per pixel, per unit of distance
## WASD fly speed, in world units per second per unit of camera distance. Scaled
## by distance because a step that reads as a step next to a Crag Pup is a
## twitch next to a Titan, and the camera is 40 units out there.
const FLY_SPEED := 0.34
## World-units of height the camera holds around a hunter you have picked.
##
## An ABSOLUTE window, not a fraction of the working shot, and this is the whole
## fix: a fraction of a Titan's framing is still a Titan's distance away, so on a
## big beast "52% closer" left the hunter a speck (Nick, 2026-08-24: "still
## doesnt centar closely"). Four units is about six hunter-heights, so a hunter
## reads at roughly a fifth of the frame whatever they are standing on.
##
## Sliding the frame across was not enough, and measuring it proved why rather
## than disproving it: the lock does put the hunter dead centre, but on the
## ground a hunter is about 4% of the frame's height beside a beast that fills
## it, so a lateral slide of a sixth of a frame is a change nobody can see
## (Nick, 2026-08-24: "it still doesnt feel like ... it centers the camera on
## them"). So the camera CUTS to an absolute window around the hunter and holds
## there — a cut is the one move the eye cannot miss, and holding is what makes
## it a lock rather than a flourish.
##
## 6.5 units, about nine hunter-heights. A first pass at 4 was close enough to
## lose the fight around them (Nick: "zoom the camera out a bit"); at 6.5 the
## hunter still plainly owns the frame and you can see what they are standing on.
const FOCUS_WINDOW := 6.5
const ZOOM_STEP := 0.12
## Sideways truck, in world units per unit of camera distance, that pushes the
## beast right so it centres in the space left of the HUD rather than on the
## screen. The rail claims ~300 of 1280px, so the free middle is ~11% right of
## centre; at fov 48 on 16:9 a frame width is ~1.58 * distance, so 0.11 of a frame
## costs ~0.17 per unit of distance.
##
## Now 0. This compensated for a hand RAIL down the left edge, and the cards moved
## to the bottom on 2026-08-15 — so for a week the camera has been trucking
## sideways to dodge a UI element that no longer exists, which is most of why the
## shot read as subtly off (Nick, 2026-08-23). The left is now the party panel and
## the right is the climb gauge, which balance each other, so the scene's centre
## and the screen's centre are the same place again.
##
## Kept as a constant rather than deleted: if a future layout claims one edge
## again, this is the knob, and the derivation above is the reason it is 0.09-ish
## rather than arbitrary.
const SCENE_SHIFT := 0.0
## Downward lens shift per unit of distance while a hunter is on the ground, which
## lifts the whole shot so tiny hunters at a Titan's feet aren't pressed into the
## bottom edge. See _apply_orbit for why this can't be done by moving the pivot.
const GROUND_LIFT := 0.07
## Lowest the camera may sit, in world units. Below this it is under the ground
## plane and the shot looks up through the floor.
const CAMERA_FLOOR := 0.8
## How long a coach hint stays up before dismissing itself. Long enough to read
## twice, short enough that it never becomes a thing you have to click away
## (Nick, 2026-08-06: the tips are annoying). Acting also dismisses it — if you
## already know what to do, the lesson has served its purpose.
const COACH_SECONDS := 7.0
## The two hunters are told apart by COLOUR, everywhere it matters: the pip
## floating over their model in the scene, the frame around the portrait in the
## rail, their party card. One source so those can never drift apart — the whole
## point is that the green frame and the green pip are obviously the same hunter.
const SLOT_TINT := [Color(0.45, 0.95, 0.5), Color(0.55, 0.82, 1.0)]

var _client: GameClient
var _beast: Node3D
var _env: Node3D
var _beast_id := ""
var _beast_box := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
## Height -> where a hunter at that Height actually stands, in rig space.
##
## Read out of the model. tools/blender/beast.py drops an empty called
## `climb_<Height>` on every ledge and on the sigil, glTF carries empties
## through as plain nodes, so the route ships WITH the art: move a shoulder in
## Blender and the hunter standing on it moves too.
##
## Empty means an older model with no anchors, and the bounding-box fallback
## below takes over — which is what every beast used to do, and why hunters
## hovered in FRONT of a body instead of standing on the shelves it already had.
var _climb_points: Dictionary = {}
## How big the pulsing marker is. It used to be a fixed 1.0, which was tuned
## when it hung above the body at 88% of the bounding box and was mostly seen
## edge-on. Now it sits ON the mark the model wears, at eye level, where a fixed
## size swallowed a small beast's whole head — so it scales with the body.
var _sigil_scale := 1.0
var _beast_scale := 1.0
var _beast_height := 0.0
var _hunters: Array = []          # slot -> {node, home}
var _active_slot := 0

# --- feel state ---
var _shake := 0.0                 # camera shake energy, decays each frame
var _cam_home := Vector3.ZERO
# --- orbit state ---
var _yaw := 0.0
var _pitch := 0.26
var _dist := 12.0
var _pivot := Vector3(0, 2.0, 0)
var _dragging := false
var _pivot_target := Vector3(0, 2.0, 0)  # where the camera is drifting its aim to
var _user_framed := false   # the player has dragged/zoomed — stop auto-pitching
var _lock_slot := 0         # the hunter the camera is locked onto (CAMERA_LOCK)
var _circle: HitCircle      # the osu-style timing face, when that setting is on
var _circle_index := -1     # the hand index whose window the circle is holding open
var _focused := false       # the camera is held close on the hunter you picked
## Free offset from whatever the camera is locked to. Orbiting alone can only
## ever look AT the subject from a new angle; panning is what lets you go and
## look at something else, which is the difference between an orbit and a free
## camera. Cleared whenever you select a hunter, so picking one is also how you
## get back — no "reset camera" button to find.
var _pan := Vector3.ZERO
var _panning := false
var _establishing := false  # easing from the opening wide shot into the working one
var _working_dist := 12.0   # the shot the establishing pull-in settles at
## 0 while everyone is on the ground, ->1 as the hunter you're playing ascends.
## Derived from the HUNTERS, never from the camera's own height: the two come
## apart whenever the shot aims high at a small beast, and reading it off the
## pivot silently switched the ground lens shift off in exactly that case.
var _climb_t := 0.0
var _beast_punch := 0.0           # recoil when the beast is struck
var _time := 0.0
# snapshot deltas drive the juice, exactly like the 2D view
var _prev_hp := -1
var _prev_foot: Array = []
var _prev_reached: Array = []
var _prev_php: Array = []   # per-hunter hp last frame, so a hit on YOU pops a number too
var _detail: ColorRect = null   # the card inspector overlay, when one is open
## The climb gauge on the right edge, and the snapshot it draws from.
var _gauge: Control = null
var _gauge_data := {}
## The move type currently telegraphed, so right-clicking the tag can explain it.
var _intent_kind := ""
## The keybind action waiting for a key press, or "" when nothing is rebinding.
var _rebinding := ""
var _rebind_btns := {}          # action id → the button showing its key
var _prev_encounter := -1
# slot -> {g: remaining 0..1, target: the Height that ends the climb}. Solo
# tracks BOTH hunters, since you can switch while a timer runs.
var _climb: Dictionary = {}
# Card selection (Burn Coal / Catapult / Meld): tapping a selection card starts a
# local pick flow, and the chosen hand indices are bundled into ONE play_card.
# Empty = idle. Without this, those cards simply can't be played.
var _selecting: Dictionary = {}
var _coach_id := ""   # the onboarding hint currently on screen
var _coach_left := 0.0  # seconds before it dismisses itself
var _log_expanded := false

@onready var _rig: Node3D = %BeastRig
@onready var _cam: Camera3D = %Camera
@onready var _flash: OmniLight3D = %Flash
@onready var _dust: CPUParticles3D = %Dust
@onready var _sigil: Node3D = %Sigil
@onready var _hud: Control = %Root
@onready var _title: Label = %Title
@onready var _hp: Label = %HpLabel
@onready var _hp_bar: ProgressBar = %HpBar
## RichTextLabel, not Label: the move's NAME is a keyword, and a keyword has to
## be able to wear an underline and carry the id a right-click looks up.
@onready var _intent: RichTextLabel = %Intent
@onready var _intent_tag: PanelContainer = %IntentTag
@onready var _hand_row: HBoxContainer = %Hand
@onready var _status: Label = %StatusLabel
@onready var _energy_orb: PanelContainer = %EnergyOrb
@onready var _energy_label: Label = %EnergyLabel
@onready var _piles: Label = %Piles
@onready var _end_btn: Button = %EndTurn
@onready var _switch_btn: Button = %SwitchBtn
@onready var _grip_bar: PanelContainer = %GripBar
@onready var _grip_label: Label = %GripLabel
@onready var _grip_meter: ProgressBar = %GripMeter
@onready var _party: VBoxContainer = %Party
@onready var _run_label: Label = %RunLabel
@onready var _coach: PanelContainer = %Coach
@onready var _coach_text: Label = %CoachText
@onready var _coach_ok: Button = %CoachOk
@onready var _coach_off: Button = %CoachOff
@onready var _menu_btn: Button = %MenuBtn
@onready var _log_label: Label = %LogLabel
@onready var _log_toggle: Button = %LogToggle
@onready var _log_panel: PanelContainer = %LogPanel


## Let a camera drag pass through a whole subtree.
##
## Setting mouse_filter on a container does nothing for its children, and a
## child that is a plain Control still defaults to STOP — which is why marking
## the top bar IGNORE in the scene left it a dead strip anyway. Walking the
## subtree also means a label added there later cannot quietly reintroduce one.
static func _let_drags_through(root: Node) -> void:
	if root == null:
		return
	if root is Control:
		(root as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in root.get_children():
		_let_drags_through(child)


func _ready() -> void:
	Screen.fit(self)   # a phone gets a physically larger interface
	# The top bar is the beast's name and health: a readout with nothing to
	# click, so the camera gets every pixel of it.
	_let_drags_through(get_node_or_null("Hud/Root/TopBar"))
	_circle = HitCircle.new()
	_circle.name = "HitCircle"
	var hud := get_node_or_null("Hud/Root") as Control
	if hud != null:
		hud.add_child(_circle)
		# Connected once, not per card: there is one circle and it is told which
		# card it is holding a window open for.
		_circle.resolved.connect(_on_circle_resolved)
	if Screen.is_handheld():
		# The hand's band is sized for a 224-tall card. Handheld cards are 186, so
		# hand the difference back to the beast rather than leaving a dead strip.
		var scroll := _hand_row.get_parent() as Control
		if scroll != null:
			scroll.offset_top = -206.0
	_cam_home = _cam.position
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	_end_btn.pressed.connect(_end_turn)
	_switch_btn.pressed.connect(func() -> void: _switch_to(1 - _active_slot))
	_log_toggle.pressed.connect(func() -> void:
		_log_expanded = not _log_expanded
		_refresh())
	_menu_btn.pressed.connect(_open_settings)
	_coach_ok.pressed.connect(_dismiss_coach)
	# The off switch lives ON the tip, because that is the exact moment you want
	# it. Burying it in a menu means being annoyed now and fixing it later, which
	# in practice means never.
	_coach_off.pressed.connect(func() -> void:
		Progress.set_hints_enabled(false)
		_coach_id = ""
		_coach_left = 0.0
		_coach.visible = false)
	_build_gauge()
	# Right-click the telegraph to ask what the move does — the tag itself names
	# it and prints the number, and nothing more.
	_intent_tag.mouse_filter = Control.MOUSE_FILTER_STOP
	_intent_tag.gui_input.connect(func(e: InputEvent) -> void:
		if not (e is InputEventMouseButton):
			return
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and _intent_kind != "":
			_intent_tag.accept_event()
			_show_keyword(Content.keyword(_intent_kind)))
	if not _client.shared.is_empty():
		_refresh()


# --- the climb gauge -------------------------------------------------------
#
# "It's not very intuitive on how far you still need to climb" (Nick,
# 2026-08-16). It never was: the party panel printed a bare Height and nothing
# said what Height you were aiming AT, so the number had no scale. With sigils
# now sitting at 4-13 instead of 1-3 that gap stops being cosmetic — a climb is
# several turns of planning and you have to be able to see where you are in it.
#
# A ladder, drawn to scale, on the right edge: the sigil at the top, ledges as
# rungs, and each hunter as a dot in their own colour. Position, distance and the
# next safe hold are all one glance, and the shape of the climb is visible before
# you commit to it.

const GAUGE_W := 62.0
const GAUGE_H := 330.0
const GAUGE_MARGIN := 14.0
const GAUGE_PAD_TOP := 30.0     # room for the sigil mark above the rail
const GAUGE_PAD_BOTTOM := 34.0  # room for the "N to go" line below it


func _build_gauge() -> void:
	# A panel, not a bare line on the background: at 3 pixels wide against a sky
	# the first version read as a scratch on the screen rather than as a reading.
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	panel.offset_left = -(GAUGE_W + GAUGE_MARGIN)
	panel.offset_right = -GAUGE_MARGIN
	panel.offset_top = -GAUGE_H * 0.5
	panel.offset_bottom = GAUGE_H * 0.5
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.09, 0.075, 0.06, 0.66)
	st.set_border_width_all(1)
	st.border_color = Color(0.42, 0.35, 0.26, 0.8)
	st.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", st)

	_gauge = Control.new()
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	panel.add_child(_gauge)
	panel.visible = false
	_hud.add_child(panel)


## Feed the gauge from a snapshot. Hidden entirely for a beast with no weak point
## to climb to, because an empty ladder is worse than no ladder.
func _update_gauge(s: Dictionary) -> void:
	if _gauge == null or not is_instance_valid(_gauge):
		return
	var boss: Dictionary = s.get("boss", {})
	var top := int(boss.get("weak_point_height", 0))
	var panel: Control = _gauge.get_parent() as Control
	if top <= 0:
		panel.visible = false
		return
	var heights: Array = []
	for p in s.get("players", []):
		heights.append(int((p as Dictionary).get("foothold", 0)))
	_gauge_data = {"top": top, "ledges": boss.get("ledges", []), "heights": heights}
	panel.visible = true
	_gauge.queue_redraw()


func _draw_gauge() -> void:
	if _gauge_data.is_empty():
		return
	var top: int = int(_gauge_data["top"])
	var ledges: Array = _gauge_data["ledges"]
	var heights: Array = _gauge_data["heights"]
	var size := _gauge.size
	var x := size.x * 0.5
	var y_top := GAUGE_PAD_TOP
	var y_bot := size.y - GAUGE_PAD_BOTTOM
	var font := ThemeDB.fallback_font
	var rail := Color(0.55, 0.47, 0.36, 0.95)
	var gold := Color(1.0, 0.84, 0.42)

	# `h` in Height units -> a y on the rail. Height 0 is the ground, at the bottom.
	var y_of := func(h: float) -> float:
		return y_bot - (y_bot - y_top) * clampf(h / float(top), 0.0, 1.0)

	_gauge.draw_line(Vector2(x, y_top), Vector2(x, y_bot), rail, 3.0)

	# Rungs. Every Height gets a small one so the ladder has a SCALE — without
	# them a climb of 2 up a sigil of 13 looks the same as one up a sigil of 4.
	for h in range(1, top):
		var y: float = y_of.call(float(h))
		var is_ledge: bool = ledges.has(h)
		var w: float = 13.0 if is_ledge else 6.0
		_gauge.draw_line(Vector2(x - w, y), Vector2(x + w, y),
			Color(0.78, 0.68, 0.5, 0.95) if is_ledge else rail, 3.0 if is_ledge else 1.5)

	# The sigil, its Height, and the ground you fall back to.
	_gauge.draw_line(Vector2(x - 15, y_top), Vector2(x + 15, y_top), gold, 3.0)
	_gauge.draw_string(font, Vector2(0, y_top - 10), "✦ %d" % top,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, gold)
	_gauge.draw_line(Vector2(x - 11, y_bot), Vector2(x + 11, y_bot), rail, 3.0)

	# Each hunter, and — for the one you are holding — how much climb is left.
	for i in range(heights.size()):
		var h: int = heights[i]
		var y: float = y_of.call(float(h))
		var tint: Color = _slot_color(i)
		# Two hunters on the same hold would draw on top of each other.
		var dx: float = -8.0 if i == 0 else 8.0
		if heights.size() > 1 and int(heights[0]) != int(heights[1]):
			dx = 0.0
		_gauge.draw_circle(Vector2(x + dx, y), 6.0, tint)
		_gauge.draw_arc(Vector2(x + dx, y), 6.0, 0.0, TAU, 16, Color(0.1, 0.09, 0.07), 2.0)

	var mine: int = int(heights[_me()]) if _me() < heights.size() else 0
	var left: int = top - mine
	var label := "at sigil" if left <= 0 else "%d up" % left
	_gauge.draw_string(font, Vector2(0, y_bot + 22), label,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 13,
		gold if left <= 0 else Color(0.92, 0.88, 0.78))


## The circle landed (or ran out). Identical to the card face's path — same
## grading, same command — which is the point: nothing downstream knows or cares
## which face the player used.
func _on_circle_resolved(quality: int) -> void:
	if _circle_index < 0:
		return
	Sfx.play("nail" if quality > Combat.TIMING_MISS else "slip")
	_client.play_card(_circle_index, quality > Combat.TIMING_MISS, _cmd_slot(), -1, -1, quality)
	_circle_index = -1


## How much Climb makes a card a HOLD rather than a tap. A long haul up the body
## should feel sustained; a short hop should not.
## Fewest notes a timed card ever asks for.
##
## This is the whole reason the osu face did not feel like osu: `timed_hits` is 1
## for 28 of the 41 timed cards, so almost every card showed ONE circle and one
## circle is not a rhythm (Nick, 2026-08-25: "the osu circles still only have 1
## circle"). In osu you are always hitting a sequence — the pattern IS the
## instrument. A card that wants more windows still gets them; this is a floor,
## not an override, so Satchel Charge keeps its three.
const NOTE_MIN := 3


## Climb 2 and up. At 3 only two cards in the whole game would ever have been a
## slider, so the feature would have shipped effectively dead; at 2 it is five,
## and the rule still reads honestly — a real haul is a hold, a hop is a tap.
const SLIDER_CLIMB := 2


## How far this card climbs, as PRINTED on it.
##
## Under `base`, not at the top level: the snapshot puts a card's printed values
## in their own dict so the face can compare live numbers against them. Reading
## `card.grip` returns 0 for every card in the game, silently, which is exactly
## how the slider path came out flat until the harness could not find a climb
## card either.
func _card_climb(card: Dictionary) -> int:
	return int((card.get("base", {}) as Dictionary).get("grip", 0))


## Screen-space spacing between consecutive notes, in pixels.
##
## About a circle and a half apart — an osu stream, where the next note is close
## enough that you flick to it rather than travel to it. The first version ran
## the chain from the card all the way up to the hold, which was a journey across
## the frame and put notes off the edge of it (Nick, 2026-08-25: "dont make them
## acros the screen. they should be in quick succesion").
const NOTE_STEP := 92.0
## How far the zigzag swings either side of the line.
const NOTE_SWAY := 42.0


## The pattern this card asks you to tap: a short stream rising from the card you
## tapped, in screen space so the spacing is the same whatever the camera is
## doing and whatever you are fighting.
##
## Built as screen offsets and projected into the world, because HitCircle draws
## from world points — project_position is the exact inverse of the unproject it
## uses, so a note lands where the arithmetic says it will.
func _hold_points(card: Dictionary, hits: int, from_screen: Vector2) -> PackedVector3Array:
	var out := PackedVector3Array()
	if _cam == null:
		return out
	var count := maxi(hits, NOTE_MIN)
	if _card_climb(card) >= SLIDER_CLIMB:
		count = maxi(count, 3)      # a slider needs a path to travel along
	# One depth for the whole pattern, so the spacing stays in pixels rather than
	# stretching with perspective.
	var depth := maxf(_dist * 0.55, 3.0)
	# Keep the stream inside the frame even when the card that started it sits in
	# a corner: shove the whole pattern, rather than bending it out of shape.
	# A different shape every time. The same three positions on every card turned
	# a rhythm test into muscle memory you only had to learn once (Nick,
	# 2026-08-25: "the circles are in the same position everytime"). The stream
	# still rises — you are climbing — but it leans, curves and steps differently
	# on each play.
	var rng := RandomNumberGenerator.new()
	var lean := rng.randf_range(-0.55, 0.55)          # radians off vertical
	var curve := rng.randf_range(-0.9, 0.9)           # how much the line bends
	var flip := 1.0 if rng.randf() < 0.5 else -1.0    # which side the zigzag starts
	var pattern := PackedVector2Array()
	var lo := Vector2(1e9, 1e9)
	var hi := Vector2(-1e9, -1e9)
	for i in range(count):
		var step := float(i)
		var along := Vector2(sin(lean), -cos(lean)) * (NOTE_STEP * step)
		var side := Vector2(cos(lean), sin(lean))
		var wobble := flip * (1.0 if i % 2 == 0 else -1.0) * NOTE_SWAY
		var bend := curve * NOTE_SWAY * sin(step / maxf(float(count - 1), 1.0) * PI)
		var at := from_screen + along + side * (wobble + bend)
		pattern.append(at)
		lo = Vector2(minf(lo.x, at.x), minf(lo.y, at.y))
		hi = Vector2(maxf(hi.x, at.x), maxf(hi.y, at.y))

	# Shove the whole pattern back on screen rather than bending it out of shape.
	var pad := 96.0
	var view := get_viewport().get_visible_rect().size
	var shove := Vector2(
		maxf(0.0, pad - lo.x) - maxf(0.0, hi.x - (view.x - pad)),
		maxf(0.0, pad - lo.y) - maxf(0.0, hi.y - (view.y - pad)))
	for at in pattern:
		out.append(_cam.project_position(at + shove, depth))
	return out


## The one place a turn ends, so the button and the key can never drift apart.
func _end_turn() -> void:
	if _end_btn.disabled:
		return                                   # already ended; waiting on your ally
	Sfx.play("end_turn")
	_dismiss_coach()
	_client.end_turn(_cmd_slot())
	if _is_solo():
		_active_slot = 1 - _active_slot
		_lock_slot = _active_slot   # the camera follows the hand you now hold
		_focus_camera()
	_refresh()


## Keyboard accelerators, all remappable from the settings menu (Progress.KEYBINDS).
##
## Space ends the turn — it is the action you take every single turn, and the
## button for it sits in the far bottom corner (Nick, 2026-08-16). Swapping is
## time-critical for the same reason: both grip timers drain at once in solo, so
## reaching for a corner button while a bar empties is the wrong input for it.
## TAB toggles; 1 and 2 jump straight to a hunter, which beats toggling when you
## know who you want.
##
## An accelerator, never the only path: CLAUDE.md §5 keeps every action reachable
## by tap, because there is no keyboard on the mobile target. Every button stays
## exactly as it was.
##
## _input rather than _unhandled_input: TAB is ui_focus_next and Space activates
## the focused button, and the viewport's GUI layer consumes both before unhandled
## input ever runs — which, on a HUD you drive by clicking, is always.
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	var code: int = (event as InputEventKey).keycode

	# Rebinding runs first and swallows everything: while the settings menu is
	# waiting for a key, that key must land in the binding rather than firing the
	# action it is currently bound to.
	if _rebinding != "":
		_apply_rebind(code)
		get_viewport().set_input_as_handled()
		return

	# Beast check: [ and ] swap the Titan you are standing in front of, without
	# leaving the fight or playing a run to reach it.
	#
	# Nick asked for a way to "go directly to each boss to check on this" — there
	# are fourteen beasts and fourteen grounds now, and the only way to see the
	# fourth Titan's was to win three fights first. This swaps the boss the same
	# way tools/screenshot.gd does, so it exercises the real model, the real
	# ground and the real climb points rather than a preview of them.
	#
	# Host-only, because only the host owns the run — on a joined client the keys
	# do nothing rather than desyncing the two of you.
	if code == KEY_BRACKETLEFT or code == KEY_BRACKETRIGHT:
		_cycle_beast(1 if code == KEY_BRACKETRIGHT else -1)
		get_viewport().set_input_as_handled()
		return
	if _detail != null and is_instance_valid(_detail):
		return                                   # an overlay owns the keyboard

	# The keypad digits are aliases, not bindings — nobody expects to have to map
	# both, and nothing else wants them.
	if code == KEY_KP_1:
		code = KEY_1
	elif code == KEY_KP_2:
		code = KEY_2

	match Progress.action_for_key(code):
		"end_turn":
			_end_turn()
		"swap":
			_switch_to(1 - _active_slot)         # solo-only, guarded in _switch_to
		"hunter_1":
			_switch_to(0)
		"hunter_2":
			_switch_to(1)
		_:
			return
	get_viewport().set_input_as_handled()


## The one place the active hunter changes, so the button and the keys can never
## drift apart. A swap mid-pick would strand the half-finished selection on the
## other hunter's hand, so it cancels first.
func _switch_to(slot: int) -> void:
	if not _is_solo() or slot < 0 or slot > 1:
		return
	# Asking for the hunter you are already holding is not a no-op: it means
	# "show me them", which is the whole point of a lock-on and the natural thing
	# to do after flying the camera somewhere else.
	if slot == _active_slot:
		_focus_camera()
		return
	if not _selecting.is_empty():
		_selecting = {}
	_active_slot = slot
	_lock_slot = slot          # selecting a hunter IS aiming the camera at them
	_focus_camera()
	Sfx.play("card")
	_refresh()


## Put the camera on the hunter you just picked, hard enough to notice.
##
## The pivot CUTS rather than glides, and the shot STAYS close. It used to push
## in and ease back out to the beast framing, which Nick reported as the camera
## "moving away after selecting" — and he is right that it is wrong: a lock-on
## you have to keep re-triggering is not a lock-on. Now the close shot holds, and
## follows the hunter up the beast as they climb.
##
## Zoom or drag whenever you want the fight back; picking a hunter is how you
## return, and a new beast opens wide again.
##
## Also the one way back from free look, which is why it clears the pan and the
## manual framing rather than only re-aiming.
func _focus_camera() -> void:
	_pan = Vector3.ZERO
	_establishing = false
	if _hunters.is_empty() or _cam == null:
		return
	_focused = true
	# Hold the shot: _aim_camera only eases distance back to the beast framing
	# while it still owns framing, so taking it away is what stops the drift.
	_user_framed = true
	var lock := _lock_point()
	_pivot.x = lock.x
	_pivot.z = lock.y
	# Aim at the HUNTER's own height, not the beast-framing height _climb_frame
	# hands back. Pushing in while still aimed at the beast's middle just filled
	# the screen with beast and left the hunter under the cards, which answers the
	# wrong question — the whole point is showing you WHO you are holding.
	var slot: int = _lock_slot if _lock_slot >= 0 and _lock_slot < _hunters.size() else _me()
	if slot >= 0 and slot < _hunters.size():
		_pivot.y = float((_hunters[slot]["home"] as Vector3).y) + HUNTER_HEIGHT * 1.4
	_dist = maxf(_dist_for_window(FOCUS_WINDOW), 2.6)
	_apply_orbit()


# --- solo helpers ---------------------------------------------------------

func _is_solo() -> bool:
	return bool(_client.shared.get("solo", false))

func _me() -> int:
	return _active_slot if _is_solo() else _client.you

func _cmd_slot() -> int:
	return _active_slot if _is_solo() else -1

func _my_private() -> Dictionary:
	if _is_solo():
		var slots: Array = _client.private.get("slots", [])
		return slots[_active_slot] if _active_slot < slots.size() else {}
	return _client.private


# --- per-frame feel -------------------------------------------------------

## Everything alive in the scene is driven from here: the beast breathes, the
## hunters sway, and any shake or recoil decays back to rest.
func _process(delta: float) -> void:
	_time += delta
	if _beast != null:
		var breathe := 1.0 + sin(_time * 1.6) * 0.02
		var recoil := 1.0 - _beast_punch * 0.10
		_beast.scale = Vector3.ONE * _beast_scale * breathe * recoil
		_beast.position.z = -_beast_punch * 0.35
	_beast_punch = maxf(0.0, _beast_punch - delta * 3.5)
	for i in range(_hunters.size()):
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		if is_instance_valid(node):
			# a gentle out-of-phase idle so the two hunters don't look cloned
			node.position.y = float((h["home"] as Vector3).y) + sin(_time * 2.3 + i * 1.7) * 0.045
	if _sigil != null and _sigil.visible:
		_sigil.scale = Vector3.ONE * _sigil_scale * (1.0 + sin(_time * 3.0) * 0.14)
	_fly(delta)
	_track_climb(delta)
	# After the camera work above: the tag is pinned to a world point, so it has to
	# be reprojected once the shake, recoil and orbit for this frame have settled.
	_position_intent_tag()
	if _coach_left > 0.0:
		_coach_left -= delta
		# fade the last second, so it leaves rather than blinking out
		_coach.modulate.a = clampf(_coach_left, 0.0, 1.0)
		if _coach_left <= 0.0:
			_dismiss_coach()
			_coach.modulate.a = 1.0
	if _shake > 0.001:
		_shake = maxf(0.0, _shake - delta * 2.6)
		var amp := _shake * 0.42
		_cam.position = _cam_home + Vector3(
			randf_range(-amp, amp), randf_range(-amp, amp), randf_range(-amp, amp) * 0.4)
	elif _cam.position != _cam_home:
		_cam.position = _cam_home
		_cam.look_at(_pivot, Vector3.UP)
	if _flash != null:
		_flash.light_energy = maxf(0.0, _flash.light_energy - delta * 9.0)
	_tick_grip(delta)


## How long the party can cling, including any grip relics.
func _grip_seconds() -> float:
	return GRIP_SECONDS + float(int(_client.shared.get("mods", {}).get("grip_seconds", 0)))


## Every climbing hunter's timer ticks, whoever is active. An empty timer is a
## fall — and in 3D that is worth SEEING, so a slipping hunter shakes harder the
## closer they are to letting go.
func _tick_grip(delta: float) -> void:
	if _climb.is_empty():
		return
	for slot in _climb.keys().duplicate():
		var st: Dictionary = _climb[slot]
		st["g"] = float(st["g"]) - delta / _grip_seconds()
		if float(st["g"]) <= 0.0:
			_climb.erase(slot)
			Sfx.play("shake")
			_client.fall(int(slot) if _is_solo() else -1)
			continue
		var i := int(slot)
		if i < _hunters.size():
			var node: Node3D = (_hunters[i] as Dictionary)["node"]
			if is_instance_valid(node):
				# steady at full grip, scrabbling as it runs out
				var slip: float = 1.0 - clampf(float(st["g"]), 0.0, 1.0)
				var amp: float = slip * slip * 0.075
				node.position.x = float(((_hunters[i] as Dictionary)["home"] as Vector3).x) 					+ sin(_time * 34.0 + i) * amp
	_update_grip_bar()


## Derive climb bursts from the "secure" flags: leaving a hold starts that
## hunter's timer full, reaching one (or falling) ends it. Grip only resets on a
## genuine hold -> climbing transition, so it drains continuously across a hop.
func _update_climb_state(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var slots: Array = [0, 1] if _is_solo() else [_client.you]
	for slot in slots:
		if slot < 0 or slot >= players.size():
			continue
		var p: Dictionary = players[slot]
		if bool(p.get("secure", true)):
			_climb.erase(slot)
		else:
			if not _climb.has(slot):
				_climb[slot] = {"g": 1.0}
			_climb[slot]["target"] = int(p.get("next_safe", int(p.get("foothold", 0))))
	_update_grip_bar()


## Show the ACTIVE hunter's grip if they're climbing, else any other climbing
## hunter's (named), so a ticking ally timer is never invisible after a switch.
func _update_grip_bar() -> void:
	if _grip_bar == null:
		return
	_grip_bar.visible = not _climb.is_empty()
	if _climb.is_empty():
		return
	var slot: int = _me() if _climb.has(_me()) else int(_climb.keys()[0])
	var st: Dictionary = _climb[slot]
	var g := clampf(float(st["g"]), 0.0, 1.0)
	_grip_meter.value = g
	_grip_meter.modulate = Color(0.9, 0.33, 0.28).lerp(Color(0.55, 0.85, 0.5), g)
	var who := "" if slot == _me() else "%s — " % _hunter_name(slot)
	var extra := "   (both hunters climbing!)" if _climb.size() > 1 else ""
	_grip_label.text = "⚠ %sHOLD ON — reach Height %d before your grip gives out!%s" % [
		who, int(st.get("target", 0)), extra]


func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	if slot < 0 or slot >= players.size():
		return "Hunter %d" % (slot + 1)
	return String((players[slot] as Dictionary).get("name", "Hunter %d" % (slot + 1)))


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty() or String(s.get("phase", "")) != "combat":
		_hud.visible = false
		_climb.clear()
		_selecting = {}
		_coach.visible = false
		return
	_hud.visible = true
	var boss: Dictionary = s["boss"]
	_title.text = String(boss["name"])
	_hp.text = "%d / %d" % [int(boss["hp"]), int(boss["max_hp"])]
	_hp_bar.max_value = int(boss["max_hp"])
	_hp_bar.value = int(boss["hp"])
	_set_intent(boss, s)
	_show_beast(String(boss.get("id", "")), String(boss["name"]),
		int(boss.get("weak_point_height", 0)))
	_place_sigil(s)
	_place_hunters(s)
	_update_climb_state(s)
	_update_gauge(s)
	_render_party(s, int(boss.get("target", -1)), String(boss.get("intent", {}).get("type", "")))
	_update_coach(s)
	_render_log(s)
	_react(s)
	_render_hand()


## The telegraph belongs ABOVE THE BEAST, not in a bar at the top of the screen
## (Nick, 2026-08-15). Slay the Spire puts intent on the enemy for a reason: it is
## the one thing you must read before choosing a card, and you are already looking
## at the thing that's about to hit you. In the top bar it sat beside the HP
## readout, competing with the name, the numbers and the Menu button.
##
## Aggressive moves wear the alarm colour; defensive and utility ones don't, so a
## turn where the beast isn't swinging reads as safe at a glance.
func _set_intent(boss: Dictionary, s: Dictionary) -> void:
	var txt := _intent_text(boss, s)
	_intent.text = "[center]%s[/center]" % txt
	_intent_tag.visible = txt != ""
	if txt == "":
		return
	var kind := String(boss.get("intent", {}).get("type", ""))
	_intent_kind = kind
	var hostile: bool = kind in ["attack", "attack_all", "swipe_high", "swipe_low", "leech", "rift"]
	_intent.add_theme_color_override("default_color",
		Color(0.98, 0.55, 0.44) if hostile else Color(0.72, 0.84, 0.62))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.07, 0.06, 0.88) if hostile else Color(0.09, 0.14, 0.09, 0.85)
	style.set_border_width_all(2)
	style.border_color = Color(0.86, 0.36, 0.28) if hostile else Color(0.46, 0.62, 0.42)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	_intent_tag.add_theme_stylebox_override("panel", style)


## Follow the beast's crown in screen space, clamped so it is always readable.
##
## The clamp matters more than the tracking: a Titan's head is off the top of the
## frame by design, so an untethered tag would sit off-screen for exactly the
## fights where knowing what's coming matters most.
func _position_intent_tag() -> void:
	if _intent_tag == null or not _intent_tag.visible or _cam == null:
		return
	if _beast_box.size.y <= 0.0:
		return
	var c := _beast_box.get_center()
	var crown := Vector3(c.x, _beast_box.end.y + _beast_box.size.y * 0.05, c.z)
	if _cam.is_position_behind(crown):
		return
	var p := _cam.unproject_position(crown)
	var sz := _intent_tag.size
	# Node3D has no get_viewport_rect(); that lives on Control.
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var lo_y := 70.0                                   # clear of the boss HP bar
	var hi_y: float = maxf(lo_y, vp.y - sz.y - 250.0)  # clear of the hand
	_intent_tag.position = Vector2(
		clampf(p.x - sz.x * 0.5, 12.0, maxf(12.0, vp.x - sz.x - 12.0)),
		clampf(p.y - sz.y - 10.0, lo_y, hi_y))


## What the beast is about to do, in numbers the player does not have to derive.
##
## "It currently says wrench apart five. I'm not sure what that means" (Nick,
## 2026-08-16). It meant 5 plus 2 for every Height between the hunters, and the
## "+" was the whole explanation. A telegraph that hides its own arithmetic is
## not a telegraph — so every move now prints the real figure and, where the
## number depends on where you are standing, says what to do about it.
func _intent_text(boss: Dictionary, s: Dictionary) -> String:
	var move: Dictionary = boss.get("intent", {})
	var v := int(move.get("value", 0)) + int(boss.get("strength", 0))
	var kind := String(move.get("type", ""))
	var kw: Dictionary = Content.keyword(kind)
	if kw.is_empty():
		return ""
	var name := String(kw.get("name", kind))
	# The number, and nothing else. The move's NAME is the keyword; what it means
	# is a right-click away, the same deal the cards make (Nick, 2026-08-16: "it's
	# still giving a description for what the boss is gonna do").
	# Underlined, like every other keyword in the game, so it reads as something
	# you can ask about rather than as a label.
	var term := "[u]%s[/u]" % name
	match kind:
		"attack", "attack_all", "swipe_high", "swipe_low", "leech":
			return "⚔ %s %d" % [term, v]
		"rift":
			# The real total, gap included, the same way a card face shows what it
			# will actually do rather than the formula behind it.
			return "⚔ %s %d" % [term, v + _height_gap(s) * Combat.RIFT_PER_GAP]
		"block": return "◆ %s %d" % [term, int(move.get("value", 0))]
		"enrage": return "▲ %s %d" % [term, int(move.get("value", 0))]
		"regen": return "✚ %s %d" % [term, int(move.get("value", 0))]
		"shift_sigil": return "✦ %s — Height %d" % [term, int(move.get("value", 0))]
	return ""


## Height between the two hunters — what a rift is priced on.
func _height_gap(s: Dictionary) -> int:
	var players: Array = s.get("players", [])
	if players.size() < 2:
		return 0
	var lo := 9999
	var hi := 0
	for p in players:
		var f := int((p as Dictionary).get("foothold", 0))
		lo = mini(lo, f)
		hi = maxi(hi, f)
	return maxi(0, hi - lo)


# --- the beast ------------------------------------------------------------

func _show_beast(beast_id: String, beast_name: String, weak_point: int) -> void:
	var key := _model_key(beast_id, beast_name)
	var want := BEAST_BASE_HEIGHT + BEAST_HEIGHT_PER_CLIMB * float(weak_point)
	if key == _beast_id and is_instance_valid(_beast) 			and is_equal_approx(want, _beast_height):
		return
	_beast_id = key
	_beast_height = want
	if _beast != null:
		_beast.queue_free()
	var path := CAST + key + ".glb"
	if not ResourceLoader.exists(path):
		return
	_beast = (load(path) as PackedScene).instantiate()
	_rig.add_child(_beast)
	_beast_scale = _fit_height(_beast, want)
	_beast_box = _merged_aabb(_beast)
	_read_climb_points()
	# Grow the arena with its occupant. A 9-unit disc was generous under a bear and
	# is a dinner plate under a Titan — it ran out mid-frame and left the bottom of
	# the shot as void, which reads as a hole rather than as ground.
	# How big the world is, from how TALL the beast is — not from how far it
	# sprawls. A Mire Snapper is mostly jaw and tail, so sizing the ground off its
	# footprint gave it a floor sixty units across and an apron the camera stood
	# inside; you could not see the beast for its own scenery. Height is the
	# measure that means something, with a floor under it so a long beast still
	# has ground beneath every part of itself.
	var want_r := maxf(_beast_height * 0.85,
		maxf(_beast_box.size.x, _beast_box.size.z) * 0.62)
	var ground := get_node_or_null("Ground") as CSGCylinder3D
	if ground != null:
		ground.radius = maxf(9.0, want_r)
	_show_env(beast_id, want_r, ground)
	_frame_beast()


## The ground this particular beast is fought on.
##
## Every Titan used to stand on the same blank grey disc, which is why the
## fights all looked like the same fight in a different costume — a beast reads
## as colossal only next to something, and "something" was one hunter and a
## circle.
##
## Same rule as the cast: `env/<beast_id>.glb` if you made one, nothing if you
## have not, and the plain disc stays underneath either way so a beast with no
## ground yet still has a floor. Making one is exporting a file.
func _show_env(beast_id: String, want_r: float, ground: CSGCylinder3D) -> void:
	if _env != null:
		_env.queue_free()
		_env = null
	var path := ENV + beast_id + ".glb"
	if beast_id == "" or not ResourceLoader.exists(path):
		if ground != null:
			ground.visible = true
		return
	_env = (load(path) as PackedScene).instantiate()
	_rig.add_child(_env)
	# tools/blender/env.py builds every floor to ENV_RADIUS. Scaling by a
	# CONSTANT rather than by measured bounds is deliberate: an environment's
	# apron and props deliberately overhang its floor, so its bounds say nothing
	# useful about how big the floor is.
	_env.scale = Vector3.ONE * (want_r / ENV_RADIUS)
	_rig.move_child(_env, 0)
	if ground != null:
		# The disc would z-fight with the floor sitting on top of it.
		ground.visible = false


## Scale a freshly added model so it stands `want` units tall, and report the
## factor used. Measured, so it holds for any mesh from any source.
func _fit_height(node: Node3D, want: float) -> float:
	var raw := _merged_aabb(node).size.y
	var factor: float = want / maxf(raw, 0.001)
	node.scale = Vector3.ONE * factor
	return factor


## Frame a SLICE of the world, not the whole animal.
##
## The old version fitted the entire body, which is why the beasts never felt big:
## fitting is normalising, and a normalised colossus is a bear. Now the camera
## shows a roughly constant window of world, so how much of a beast is visible IS
## how big it is. A Crag Pup fits inside the window; the Sunken Warden runs off
## the top of the screen and you meet it a stretch at a time.
func _frame_beast() -> void:
	var tall := maxf(_beast_box.size.y, 1.0)
	var window := _window_for(tall * 1.18)
	_working_dist = _dist_for_window(window)
	_yaw = 0.0          # a new beast is always introduced from the front
	_user_framed = false
	_lock_slot = _me()
	_pan = Vector3.ZERO
	_focused = false          # a new beast is met wide, then you pick someone
	# Open on the whole creature, however far back that has to be, then fall in to
	# the working shot. You get to see what you've picked a fight with once —
	# after that, the climb is the subject and the rest of it is off-screen.
	_dist = _dist_for_window(_window_for(tall * 1.35))
	_establishing = _dist > _working_dist + 0.1
	_pivot = Vector3(0.0, _ground_pivot(window), 0.0)
	_pivot_target = _pivot
	_pitch = 0.24
	_apply_orbit()


## Walk the camera, on the keys, wherever you want it.
##
## The orbit could always TURN, and right-drag could slide it, but it stayed tied
## to a point — you could look at the fight from any angle and never go anywhere
## (Nick, 2026-08-24: "currently its locked to a fix point"). WASD moves it, E/Q
## lift and drop it.
##
## Movement is on the ground plane rather than along the lens, so holding W walks
## toward what you are facing instead of burrowing into the floor when you happen
## to be looking down. Picking a hunter puts it back.
func _fly(delta: float) -> void:
	if _rebinding != "" or (_detail != null and is_instance_valid(_detail)):
		return                       # a menu owns the keyboard
	if _cam == null:
		return
	var step := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		step.z += 1.0
	if Input.is_key_pressed(KEY_S):
		step.z -= 1.0
	if Input.is_key_pressed(KEY_D):
		step.x += 1.0
	if Input.is_key_pressed(KEY_A):
		step.x -= 1.0
	if Input.is_key_pressed(KEY_E):
		step.y += 1.0
	if Input.is_key_pressed(KEY_Q):
		step.y -= 1.0
	if step == Vector3.ZERO:
		return
	_take_manual_control()
	var b := _cam.global_transform.basis
	var fwd := Vector3(-b.z.x, 0.0, -b.z.z)
	fwd = fwd.normalized() if fwd.length() > 0.001 else Vector3.FORWARD
	var right := Vector3(b.x.x, 0.0, b.x.z)
	right = right.normalized() if right.length() > 0.001 else Vector3.RIGHT
	var speed := FLY_SPEED * maxf(_dist, 4.0) * delta
	_pan += (fwd * step.z + right * step.x + Vector3.UP * step.y) * speed


## Ride the camera up the beast as the hunter climbs. Smoothed rather than
## snapped, because the drift IS the feedback — a cut would just teleport you and
## you'd learn nothing about how far up you are.
##
## Only the AIM is automatic. Distance and angle stay the player's once they've
## touched them, so following the action can never wrestle the orbit away.
func _track_climb(delta: float) -> void:
	_aim_camera(delta, false)


## Settle the camera instantly, wherever it was easing to.
##
## For the screenshot harness: it drives frames far faster than real time, so a
## time-based ease can never finish there and every shot would show a camera
## caught mid-glide. Called twice because the ground framing reads the current
## distance, so one pass leaves it one step behind.
func snap_camera() -> void:
	_aim_camera(0.0, true)
	_aim_camera(0.0, true)


## Where the camera is locked, on the ground plane: (x, z) of the hunter you are
## holding. The frame answers "who am I?" without a label — and answers it by
## MOVING, which is the part a static badge cannot do.
##
## It does NOT yield to _user_framed any more, and that was the bug. The moment
## you looked around, selecting a hunter stopped moving the camera at all — so the
## one gesture that should always answer "who am I?" went dead at exactly the
## moment the shot was least familiar. Free look owns the ANGLE and the DISTANCE;
## the lock owns what you are angled at.
##
## Both x and z, not just x: under a rotated yaw a hunter's screen position is no
## longer a function of world x alone, so an x-only lock silently stops centring
## anyone the moment you orbit.
func _lock_point() -> Vector2:
	if _hunters.is_empty():
		return Vector2.ZERO
	var slot := _lock_slot
	if slot < 0 or slot >= _hunters.size():
		slot = _me()
	if slot < 0 or slot >= _hunters.size():
		return Vector2.ZERO
	var home := _hunters[slot]["home"] as Vector3
	return Vector2(home.x, home.z) * CAMERA_LOCK


func _aim_camera(delta: float, snap: bool) -> void:
	if _client == null or _beast == null:
		return
	var want := _climb_frame()
	var lock := _lock_point()
	_pivot_target.y = want.x + _pan.y
	if _focused:
		# Aim at the hunter and keep aiming at them, so the close shot rides up
		# the body as they climb instead of sliding back to the beast's framing.
		var fs: int = _lock_slot if _lock_slot >= 0 and _lock_slot < _hunters.size() else _me()
		if fs >= 0 and fs < _hunters.size():
			_pivot_target.y = float((_hunters[fs]["home"] as Vector3).y) 				+ HUNTER_HEIGHT * 1.2 + _pan.y
	_pivot_target.x = lock.x + _pan.x
	_pivot_target.z = lock.y + _pan.z
	if not _user_framed:
		_working_dist = _dist_for_window(want.y)
	if snap:
		_pivot = _pivot_target
		if not _user_framed:
			_dist = _working_dist
		_establishing = false
	else:
		if _establishing or (not _user_framed and absf(_dist - _working_dist) > 0.02):
			_dist = lerpf(_dist, _working_dist, 1.0 - exp(-delta * 1.6))
			if _establishing and absf(_dist - _working_dist) < 0.05:
				_establishing = false
		if _pivot.distance_to(_pivot_target) > 0.005 or _establishing:
			# frame-rate independent ease: the same feel at 30fps and 144
			_pivot = _pivot.lerp(_pivot_target, 1.0 - exp(-delta * 3.2))
	if not _user_framed:
		# Tilted up at the base, flattening out as you gain height — and only ever
		# flattening. A camera that tips DOWN at the top looks at a Titan's scalp,
		# which reads as a floor; near-level keeps the silhouette against the sky,
		# and a silhouette is what makes something look big.
		_pitch = lerpf(ORBIT_PITCH_MIN, 0.10, _climb_t)
	_apply_orbit()


## Camera distance that makes `window` world-units of height fill the frame.
## Derived from the lens rather than hand-tuned, so changing fov can't silently
## break the framing.
## Camera distance that makes `window` world-units of height fill the frame.
##
## Measured from the beast's FRONT, not its centre. The orbit is anchored at the
## body's axis, but the hunters cling to its near face — on a Titan that's 5 units
## nearer the camera, so standing off by the window alone put the lens practically
## against them and threw both hunters off opposite edges of the screen.
## The window the camera must hold for `want` world-units to stay visible ABOVE the
## card strip, clamped to the framing range.
func _window_for(want: float) -> float:
	return clampf(want / (1.0 - HUD_BOTTOM_FRACTION), VIEW_WINDOW_MIN, VIEW_WINDOW_MAX)


## How far to lift the aim so the subject sits in the clear band rather than centred
## on a screen whose bottom third is cards.
## Aim so the GROUND lands on the top edge of the card strip.
##
## Both ground shots want this and neither used to have it. Aiming lower left a
## Titan's feet floating a third of the way up the screen with a dead lane of desert
## under them; aiming higher pushed a lesser beast's whole body behind the hand. One
## rule fixes both: the beast stands ON the cards, so every pixel of clear screen is
## beast, and anything too tall to fit runs off the top — which is the whole point.
##
## Derivation: for world y=0 to sit at screen fraction (1 - HUD_BOTTOM_FRACTION),
## the pivot must be (0.5 - HUD_BOTTOM_FRACTION) * window. The small margin keeps
## the feet just clear of the card edge rather than tangent to it.
func _ground_pivot(window: float) -> float:
	return window * (0.5 - HUD_BOTTOM_FRACTION + 0.04)


func _dist_for_window(window: float) -> float:
	var lens := maxf(window, 1.0) / (2.0 * tan(deg_to_rad(_cam.fov) * 0.5))
	# Stand off from the beast's FRONT rather than its centre — but only by the
	# part the pivot has not already covered. Locking onto a hunter puts the pivot
	# out on that front face, and charging the whole standoff on top of it would
	# back the camera off by the beast's depth twice over.
	return lens + maxf(_beast_box.end.z * 0.85 - _pivot_target.z, 0.0)


## What the camera should be looking at, and how much world to fit around it:
## returns (focus height, window height).
##
## Two different shots, because the fight has two different subjects.
##
## On the ground the subject is the BEAST: aim low, near your hunters' own eye
## level, and let the body rear up out of the top of the frame. (Aiming at its
## middle instead is what made it look like a pet.)
##
## Once anyone is climbing, the subject is the HUNTERS: frame the pair, biased
## toward the one you're playing but never dropping the other. Aiming at the
## active hunter alone put a Titan's blank scalp on screen and lost the ally off
## the edge — and "where is my partner" is the question this game is about.
func _climb_frame() -> Vector2:
	var tall := maxf(_beast_box.size.y, 1.0)
	var eye := HUNTER_HEIGHT * 0.6
	var ys: Array[float] = []
	for h in _hunters:
		ys.append(float((h["home"] as Vector3).y) + eye)
	if ys.is_empty():
		var w0 := _window_for(tall * 1.18)
		return Vector2(_ground_pivot(w0), w0)
	var lo: float = ys.min()
	var hi: float = ys.max()
	if hi < eye + 0.05:  # nobody has left the ground
		_climb_t = 0.0
		var window := _window_for(tall * 1.18)
		# A beast small enough to fit the window is met face to face — cropping a
		# Crag Pup's head isn't imposing, it just looks like a mistake. Only the
		# ones too big to hold get the looming shot, which makes towering a thing
		# the act Titans do rather than something every fight does.
		return Vector2(_ground_pivot(window), window)
	var active: float = ys[_me()] if _me() < ys.size() else hi
	_climb_t = clampf(active / maxf(tall * 0.55, 1.0), 0.0, 1.0)
	# Look a little way up the road — from where YOU are, not from wherever the
	# party's highest climber got to. Framing purely on hunters put the sigil just
	# off the top of the screen for the whole ascent, so you climb toward a target
	# you can't see. Headroom is capped, so from partway up a Titan the weak point
	# is still over the horizon of the frame (honest, and part of why it feels
	# tall), but it slides into view as you close on it.
	#
	# Strictly after the ground test: applied before it, a hunter standing at the
	# feet already "sees" 3 units of headroom, the ground branch never fires, and
	# the looming shot this whole change exists for is silently lost.
	if _sigil != null and _sigil.visible:
		hi = maxf(hi, minf(_sigil.position.y, active + 3.0))
	# Enough air around the pair to read the body they're clinging to, then aim so
	# the HIGHER hunter lands around 42% down the frame rather than centred. The
	# top ~200px belong to the grip bar and the coach, and the higher hunter is
	# usually the one at the sigil — centre the pair and the payoff of the whole
	# climb sits behind a HUD panel. Framing off the top hunter also means the
	# lower one is always below them, so both stay on screen by construction.
	# The offset is bigger than "half the frame" arithmetic suggests, and measured
	# rather than derived: hunters cling to the FRONT of the body, much nearer the
	# camera than the pivot plane, so parallax throws them further from centre than
	# their world height alone predicts. tools/screenshot.gd prints where they
	# actually land — tune this against that, not against algebra.
	var window := _window_for((hi - lo) * 1.5 + 4.0)
	# When a carry is going well the pair can be most of a Titan apart — further
	# than any window that still feels big. Something has to fall off the edge, and
	# it is never the hunter whose cards you are holding. This clamp pins the
	# active hunter inside the middle 60% of frame; the ally can drift off, which
	# is itself the read that they are a very long way below you. The party panel
	# still has their HP and Height.
	# Climbing: the subject is the hunters, so bias the pair into the clear band
	# above the hand rather than the middle of the whole screen.
	return Vector2(clampf(hi - window * (0.19 + HUD_BOTTOM_FRACTION * 0.5),
		active - window * 0.30, active + window * 0.30), window)


## Spherical position around the beast. Everything else (shake, the strike flash)
## composes on top of _cam_home, so the orbit is the only thing that decides
## where the camera fundamentally is.
func _apply_orbit() -> void:
	_pitch = clampf(_pitch, ORBIT_PITCH_MIN, ORBIT_PITCH_MAX)
	var flat := cos(_pitch) * _dist
	_cam_home = _pivot + Vector3(sin(_yaw) * flat, sin(_pitch) * _dist, cos(_yaw) * flat)
	var lift := _dist * lerpf(GROUND_LIFT, 0.0, _climb_t)
	# Never dip under the floor. Aiming low at the foot of something 13 units tall
	# drives the camera below y=0, and then you're looking up THROUGH the ground.
	# The lens shift is added in because Godot applies it after this, moving the
	# camera down by exactly that much.
	_cam_home.y = maxf(_cam_home.y, CAMERA_FLOOR + lift)
	_cam.position = _cam_home
	_cam.look_at(_pivot, Vector3.UP)
	# The hand rail owns the left edge, so the screen's centre is not the SCENE's
	# centre any more. h_offset trucks the camera sideways without re-aiming it, so
	# the beast sits in the middle of the space it actually has. It scales with
	# distance because that's what a fixed fraction of the frame costs in world
	# units — zoom in and the shift shrinks with it.
	# It earns its keep in the wide ground shot, where the beast is broad and the
	# rail would crowd it. Up on the body it mostly pushes the right-hand climber
	# toward the party panel, so it eases off as you climb.
	_cam.h_offset = -lerpf(SCENE_SHIFT, SCENE_SHIFT * 0.3, _climb_t) * _dist
	# Lens shift DOWN while you're at the beast's feet, which lifts everything in
	# frame — the hunters stop hugging the bottom edge without the camera having to
	# tilt down and lose the looming angle. Moving the pivot can't do this: it
	# carries the camera with it, so the ground stays exactly where it was. Fades
	# out as you climb, where the hunter should simply be centred.
	_cam.v_offset = -lift


## Drag anywhere the HUD didn't already claim. Cards and buttons are Controls, so
## they consume their own clicks before this ever runs — the hand and the camera
## never fight over the same drag.
## Swap to the next (or previous) beast in bosses.json, in place.
func _cycle_beast(step: int) -> void:
	if Session.host == null or Session.host._run == null 			or Session.host._run.combat == null:
		_dev_note("[ ] only work while the HOST is in a fight")
		return
	var ids: Array = Content.boss_ids()
	if ids.is_empty():
		return
	var here: int = ids.find(String(Session.host._run.combat.boss.id))
	var next: int = posmod(here + step, ids.size())
	var id := String(ids[next])
	Session.host._run.combat.boss = Content.build_boss(id)
	Session.host._broadcast_state()
	_dev_note("%d/%d  %s   —  [ and ] to change" % [next + 1, ids.size(),
		Content.build_boss(id).name])


## A line of text at the top of the screen that goes away on its own. Deliberately
## built here rather than added to the scene: it is a tool, and a tool that only
## exists when you press its key cannot be left switched on by accident.
func _dev_note(text: String) -> void:
	var old := get_node_or_null("DevNote")
	if old != null:
		old.queue_free()
	var l := Label.new()
	l.name = "DevNote"
	l.text = text
	l.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 6)
	l.set_anchors_preset(Control.PRESET_CENTER_TOP)
	l.position.y = 96.0
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var tw := create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(l.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = mb.pressed
			MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT:
				# Right-drag pans. Right-CLICK on a card opens its keyword, but a
				# card is a Control and eats its own clicks before this runs, so
				# the two never meet.
				_panning = mb.pressed
			MOUSE_BUTTON_WHEEL_UP:
				_take_manual_control()
				_dist = maxf(_dist * (1.0 - ZOOM_STEP), 4.0)
				_apply_orbit()
			MOUSE_BUTTON_WHEEL_DOWN:
				_take_manual_control()
				_dist = minf(_dist * (1.0 + ZOOM_STEP), 60.0)
				_apply_orbit()
	elif event is InputEventMouseMotion and (_dragging or _panning):
		var mm: InputEventMouseMotion = event
		_take_manual_control()
		if _panning:
			# In the camera's own axes, so a drag moves the world the way the
			# hand moves, whatever angle you are viewing from. Scaled by distance
			# so panning feels the same close in and far out.
			var basis := _cam.global_transform.basis
			var k := _dist * PAN_SENSITIVITY
			_pan -= basis.x * mm.relative.x * k
			_pan += basis.y * mm.relative.y * k
		else:
			_yaw -= mm.relative.x * ORBIT_SENSITIVITY
			_pitch += mm.relative.y * ORBIT_SENSITIVITY
		_apply_orbit()


## The moment the player touches the camera it stops second-guessing them: no more
## auto-pitch, and the opening pull-in gives up rather than dragging them back.
## Following the climb keeps working — that's help, not interference.
func _take_manual_control() -> void:
	_user_framed = true
	_establishing = false


## The beast's data id picks its model. The old guess read the portrait PATH,
## which cannot work — several beasts share one portrait (two use crocodile.png),
## so half the roster resolved to the wrong body or fell back to the elephant.
## The name is kept only as a fallback for a beast added without a mapping.
func _model_key(beast_id: String, beast_name: String) -> String:
	# Your own art wins, exactly as it does for hunters (ui/cast.gd): a file named
	# cast/<beast_id>.glb replaces the Kenney stand-in with no code change, so
	# making a beast is exporting a file and nothing else.
	if beast_id != "" and ResourceLoader.exists(CAST + beast_id + ".glb"):
		return beast_id
	if MODELS.has(beast_id):
		return String(MODELS[beast_id])
	var lower := beast_name.to_lower()
	for id in MODELS:
		if lower.contains(String(id).replace("_", " ")):
			return String(MODELS[id])
	push_warning("combat_3d: no model for beast '%s' — falling back" % beast_id)
	return "elephant"


## World-space bounds of a model, so hunters can be placed ON it whatever its
## shape — no per-beast hand-tuning.
func _merged_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for node in _all_meshes(root):
		var vi := node as VisualInstance3D
		var box: AABB = vi.global_transform * vi.get_aabb()
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	if first:
		return AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	return out


func _all_meshes(node: Node) -> Array:
	var out: Array = []
	if node is VisualInstance3D:
		out.append(node)
	for c in node.get_children():
		out.append_array(_all_meshes(c))
	return out


# --- hunters --------------------------------------------------------------

## Pull the climb route out of the model that just spawned.
func _read_climb_points() -> void:
	_climb_points.clear()
	if _beast == null:
		return
	_gather_climb(_beast, Transform3D.IDENTITY)


## Walks the transform down rather than reading global_position, which is only
## meaningful once the node is in the tree and settled.
func _gather_climb(n: Node, xf: Transform3D) -> void:
	for c in n.get_children():
		var next := xf
		if c is Node3D:
			next = xf * (c as Node3D).transform
			var nm := String(c.name)
			if nm.begins_with("climb_"):
				var tail := nm.substr(6)
				if tail.is_valid_int():
					_climb_points[tail.to_int()] = next.origin * _beast_scale
		_gather_climb(c, next)


## The Heights this beast has anchors for, in order.
func _climb_rungs() -> Array:
	var keys: Array = _climb_points.keys()
	keys.sort()
	return keys


## Where a hunter at `foot` stands, from the model's own anchors.
##
## Exactly on a rung when the Height matches one, and between the two that
## bracket it otherwise — so a hunter part-way up a long haul is on the line
## between the ledge below and the ledge above rather than on a number.
func _stand_on_model(foot: int, side: float) -> Vector3:
	var rungs := _climb_rungs()
	var lo: int = int(rungs[0])
	var hi: int = int(rungs[rungs.size() - 1])
	for k in rungs:
		if int(k) <= foot:
			lo = int(k)
		if int(k) >= foot:
			hi = int(k)
			break
	var a: Vector3 = _climb_points[lo]
	var b: Vector3 = _climb_points[hi]
	var p: Vector3 = a
	if hi != lo:
		p = a.lerp(b, clampf(float(foot - lo) / float(hi - lo), 0.0, 1.0))
	# Two hunters on one ledge stand apart rather than inside each other, and a
	# little forward of the anchor so neither is buried in the body.
	return p + Vector3(side * (_beast_box.size.x * 0.055 + 0.30), 0.0,
		_beast_box.size.z * 0.025)


## Every anchor strictly between two footholds, so a hunter climbing from the
## ankle to the shoulder goes VIA the platform instead of through the chest.
func _route_between(from_foot: int, to_foot: int) -> Array:
	var out: Array = []
	var rungs := _climb_rungs()
	if to_foot > from_foot:
		for k in rungs:
			if int(k) > from_foot and int(k) < to_foot:
				out.append(int(k))
	else:
		for i in range(rungs.size() - 1, -1, -1):
			var k := int(rungs[i])
			if k < from_foot and k > to_foot:
				out.append(k)
	return out


## Height becomes literal: on the ground they stand in front of the beast; as
## they climb they move UP its flank, hugging the model's actual bounds.
func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var boss: Dictionary = s.get("boss", {})
	var height: int = maxi(int(boss.get("weak_point_height", 1)), 1)
	while _hunters.size() < players.size():
		_hunters.append(_spawn_hunter(_hunters.size(), players))
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var foot: int = int(p.get("foothold", 0))
		var t: float = clampf(float(foot) / float(height), 0.0, 1.0)
		var side: float = -1.0 if i == 0 else 1.0
		var pos: Vector3
		if t <= 0.01:
			# At the feet, close in. Flanking scales with the body, and the bodies
			# are colossal now — a hunter parked half a Titan's width out lands
			# under the hand rail on one side or the party panel on the other.
			# Standing right at the foot also reads better: you're about to climb
			# this thing, not square up to it.
			pos = Vector3(side * (_beast_box.size.x * 0.22 + 0.6), 0.0,
				_beast_box.end.z * 0.9)
		elif not _climb_points.is_empty():
			# The model says where its ledges are, so stand on one.
			pos = _stand_on_model(foot, side)
		elif t >= 0.92:
			# at the weak point — stand ON the sigil, the thing the climb was for.
			# Scaled off the body: a fixed nudge that cleared a 2-unit-deep bear
			# leaves a hunter buried inside a 12-unit-deep Titan.
			pos = _sigil.position + Vector3(side * (_beast_box.size.x * 0.10 + 0.3),
				-0.12, _beast_box.size.z * 0.06)
		else:
			var y := _beast_box.position.y + _beast_box.size.y * lerpf(0.18, 0.80, t)
			# closer to the spine than they used to be — a third of a Titan's width
			# out puts the right-hand climber behind the party panel, and hugging
			# the body reads more like climbing than like hanging off the edges
			var x := side * (_beast_box.size.x * 0.20)
			# out on the FRONT of the body, not a quarter of the way into it —
			# otherwise the hunter is behind the mesh and simply isn't there
			pos = Vector3(x, y, _beast_box.end.z * 0.82)
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		var moved: bool = (h["home"] as Vector3).distance_to(pos) > 0.05
		var was: int = int(h.get("foot", foot))
		h["home"] = pos
		h["foot"] = foot
		if moved:
			# Climb VIA the ledges in between, not through the body. Going from
			# the ankle to the shoulder means stopping on the platform on the way,
			# which is the whole reason the anchors exist — a straight tween
			# between two heights walks a hunter through the beast's chest.
			var way: Array = []
			if not _climb_points.is_empty() and was != foot:
				way = _route_between(was, foot)
			var tw := create_tween()
			tw.set_trans(Tween.TRANS_QUAD)
			var step: float = maxf(0.16, 0.30 / float(way.size() + 1))
			for wp in way:
				tw.tween_property(node, "position", _stand_on_model(int(wp), side),
					step).set_ease(Tween.EASE_IN_OUT)
			tw.tween_property(node, "position", pos, step).set_ease(Tween.EASE_OUT)
		else:
			node.position = pos
		# ground hunters stand three-quarter on, turned in toward the beast
		node.rotation.y = (PI + 0.7 * side) if t <= 0.01 else (PI * 0.5 * -side)


## Hunters come from ui/cast.gd, the one place that knows which body plays which
## character — and that prefers cast/<id>.glb, your own art, over the stand-in.
## Exporting a model is the whole job; no code edit makes it show up.
func _spawn_hunter(slot: int, players: Array) -> Dictionary:
	var p: Dictionary = players[slot]
	var cid := String(p.get("character", ""))
	var holder := Node3D.new()
	_rig.add_child(holder)
	# Your own cast/<character>.glb wins over the Kenney stand-in (see ui/cast.gd),
	# so exporting a model is the whole job — no code edit to make it show up.
	var path := Cast.model_path(cid)
	if ResourceLoader.exists(path):
		var m := (load(path) as PackedScene).instantiate()
		holder.add_child(m)
		_fit_height(m, HUNTER_HEIGHT)
	holder.add_child(_hunter_pip(slot))
	return {"node": holder, "home": Vector3.ZERO}


## Orbiting means a hunter can end up behind the beast's body. A pip that draws
## THROUGH the beast keeps both of them findable from any angle — otherwise the
## camera freedom costs you the one thing you always need to know.
func _hunter_pip(slot: int) -> Node3D:
	var pip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.12
	cone.height = 0.22
	cone.radial_segments = 8
	pip.mesh = cone
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _slot_color(slot)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.render_priority = 2
	pip.material_override = mat
	pip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pip.rotation.z = PI  # point down at the hunter it marks
	pip.position = Vector3(0, 0.72, 0)
	return pip


## The weak point sits atop the beast and pulses, so the target of the whole
## climb is a place you can see rather than a number.
func _place_sigil(s: Dictionary) -> void:
	var boss: Dictionary = s.get("boss", {})
	var on: bool = int(boss.get("weak_point_height", 0)) > 0
	_sigil.visible = on
	if not on:
		return
	# The model carries its own gold mark now, at the Height its data says. Put
	# the marker THERE rather than at 88% of the bounding box, or the beast wears
	# two sigils in different places and the floating one wins the eye.
	var wp := int(boss.get("weak_point_height", 0))
	_sigil_scale = clampf(_beast_box.size.y * 0.016, 0.28, 0.85)
	if _climb_points.has(wp):
		# Just in FRONT of the mark the model already wears, so the pulsing glow
		# reads as a highlight ON the weak point rather than as a second sigil
		# floating near it.
		_sigil.position = (_climb_points[wp] as Vector3) + Vector3(0.0, 0.0,
			_beast_box.size.z * 0.05)
		return
	# On the FRONT of the body. A quarter-depth offset put it inside the mesh —
	# survivable when a beast was 2 units deep, invisible now one is 12.
	_sigil.position = Vector3(_beast_box.get_center().x,
		_beast_box.position.y + _beast_box.size.y * 0.88,
		_beast_box.end.z * 0.86)


# --- reactions (the same snapshot deltas the 2D view uses) ----------------

func _react(s: Dictionary) -> void:
	var boss: Dictionary = s["boss"]
	var players: Array = s["players"]
	var enc := int(s.get("encounter", 0))
	var hp := int(boss.get("hp", 0))
	var foots: Array = []
	var reached: Array = []
	for p in players:
		foots.append(int(p.get("foothold", 0)))
		reached.append(bool(p.get("reached", false)))
	if enc != _prev_encounter or _prev_foot.size() != foots.size():
		_sync(enc, hp, foots, reached)
		return
	var php: Array = []
	for p in players:
		php.append(int(p.get("hp", 0)))
	if _prev_php.size() != php.size():
		_sync(enc, hp, foots, reached, php)
		return
	if hp < _prev_hp:
		var weak := reached.has(true) or _prev_reached.has(true)
		_strike(weak)
		_damage_popup(_prev_hp - hp, _sigil.position if weak else _beast_box.get_center(), weak)
	for i in range(foots.size()):
		if php[i] < _prev_php[i] and i < _hunters.size() \
				and is_instance_valid((_hunters[i] as Dictionary)["node"]):
			# Hunters bleed too, and how hard you were hit is the thing you most
			# need to know before deciding next turn.
			var hnode: Node3D = (_hunters[i] as Dictionary)["node"]
			_damage_popup(_prev_php[i] - php[i],
				hnode.position + Vector3(0.0, HUNTER_HEIGHT * 1.4, 0.0), false, true)
		if not _prev_reached[i] and reached[i]:
			Sfx.play("reach_sigil")
		elif foots[i] > _prev_foot[i]:
			Sfx.play("climb")
		elif foots[i] < _prev_foot[i]:
			_beast_shake()
	_sync(enc, hp, foots, reached, php)


func _sync(enc: int, hp: int, foots: Array, reached: Array, php: Array = []) -> void:
	_prev_encounter = enc
	_prev_hp = hp
	_prev_foot = foots
	_prev_reached = reached
	_prev_php = php


## Everything that isn't playing a card, behind one button. Settings live here
## rather than as their own HUD controls precisely because the screen was already
## too busy — the cure for clutter is not more buttons.
## One row of the keybind list: what it does on the left, the key on the right.
func _keybind_row(spec: Dictionary) -> Control:
	var id := String(spec["id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_lbl := _detail_label(String(spec["name"]), 13, Color(0.9, 0.86, 0.78))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(104, 34)
	# FOCUS_NONE matters here: a focused Button eats Space and Enter as "press me",
	# so binding Space would re-open the very button you just clicked.
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = _key_name(Progress.keybind(id))
	btn.pressed.connect(func() -> void:
		# Cancel any other row already listening, so only one key is ever captured.
		if _rebinding != "" and _rebind_btns.has(_rebinding):
			(_rebind_btns[_rebinding] as Button).text = _key_name(Progress.keybind(_rebinding))
		_rebinding = id
		btn.text = "press a key")
	_rebind_btns[id] = btn
	row.add_child(btn)
	return row


## Finish a rebind with the key the player just pressed. Escape cancels — it is
## the one key nobody should be able to bind, because it is how you back out.
func _apply_rebind(code: int) -> void:
	var id := _rebinding
	_rebinding = ""
	if code != KEY_ESCAPE:
		Progress.set_keybind(id, code)
	# Every row, not just this one: binding a key steals it from whoever held it.
	for other: String in _rebind_btns:
		var b: Button = _rebind_btns[other]
		if is_instance_valid(b):
			b.text = _key_name(Progress.keybind(other))


static func _key_name(code: int) -> String:
	if code == KEY_NONE:
		return "unbound"
	if code == KEY_SPACE:
		return "Space"          # OS_get_keycode_string gives "Space" already, but be sure
	return OS.get_keycode_string(code)


## One keyword, on its own. Right-clicking the word "Poison" should answer
## "what does Poison do" and nothing else — the full card inspector is the answer
## to a different question, and burying one term in it makes you hunt.
func _show_keyword(kw: Dictionary) -> void:
	if kw.is_empty():
		return
	_close_overlay()
	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.55)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			_close_overlay())

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

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
	col.add_child(_underlined(String(kw.get("name", "")), 18, Color(1, 0.86, 0.5)))
	var body := _detail_label(String(kw.get("text", "")), 13, Color(0.86, 0.82, 0.74), true)
	body.custom_minimum_size = Vector2(328, 0)
	col.add_child(body)
	col.add_child(_detail_label("tap anywhere to close", 11, Color(0.6, 0.56, 0.5)))


func _open_settings() -> void:
	_close_overlay()
	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.72)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			_close_overlay())

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 18.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	col.add_child(_detail_label("Settings", 20, Color(1, 0.94, 0.8)))
	col.add_child(_detail_rule())

	var music := Button.new()
	music.custom_minimum_size = Vector2(0, 42)
	music.text = "Music:  %s" % ("On" if Progress.music_enabled() else "Off")
	music.pressed.connect(func() -> void:
		Progress.set_music_enabled(not Progress.music_enabled())
		Music.refresh()   # audible on the tap, not at the next scene change
		music.text = "Music:  %s" % ("On" if Progress.music_enabled() else "Off"))
	col.add_child(music)

	var tips := Button.new()
	tips.custom_minimum_size = Vector2(0, 42)
	tips.text = "Tips:  %s" % ("On" if Progress.hints_enabled() else "Off")
	tips.pressed.connect(func() -> void:
		Progress.set_hints_enabled(not Progress.hints_enabled())
		tips.text = "Tips:  %s" % ("On" if Progress.hints_enabled() else "Off")
		if not Progress.hints_enabled():
			_coach_id = ""
			_coach.visible = false)
	col.add_child(tips)

	# The camera has four gestures and, until now, nothing anywhere said so. A
	# control nobody is told about is a control nobody has, which is indistinguishable
	# from one that does not work.
	var timing := Button.new()
	timing.custom_minimum_size = Vector2(0, 34)
	timing.focus_mode = Control.FOCUS_NONE
	timing.text = "Timing:  %s" % ("Hit circle" if Progress.timing_style() == Progress.TIMING_CIRCLE
		else "Sweep bar")
	timing.tooltip_text = "Where a timed card asks you to hit: an osu-style circle out on the beast, or the bar under the card."
	timing.pressed.connect(func() -> void:
		var next := Progress.TIMING_BAR if Progress.timing_style() == Progress.TIMING_CIRCLE 			else Progress.TIMING_CIRCLE
		Progress.set_timing_style(next)
		timing.text = "Timing:  %s" % ("Hit circle" if next == Progress.TIMING_CIRCLE else "Sweep bar"))
	col.add_child(timing)

	col.add_child(_detail_rule())
	col.add_child(_detail_label("Camera", 14, Color(1, 0.86, 0.5)))
	var cam_help := _detail_label(
		"W A S D  move the camera.  E / Q raise and lower it.
"
		+ "Drag to look around.  Right-drag to slide.  Wheel to zoom.
"
		+ "Picking a hunter puts the camera back on them.",
		11, Color(0.72, 0.68, 0.6), true)
	cam_help.custom_minimum_size = Vector2(284, 0)
	col.add_child(cam_help)

	col.add_child(_detail_rule())
	col.add_child(_detail_label("Keys", 14, Color(1, 0.86, 0.5)))
	var hint := _detail_label(
		"Tap a key, then press the one you want. Escape cancels. Every action still has a button.",
		11, Color(0.72, 0.68, 0.6), true)
	hint.custom_minimum_size = Vector2(284, 0)  # this panel is 320 wide, not the inspector's 430
	col.add_child(hint)
	_rebind_btns = {}
	for k in Progress.KEYBINDS:
		col.add_child(_keybind_row(k as Dictionary))

	var reset := Button.new()
	reset.custom_minimum_size = Vector2(0, 32)
	reset.focus_mode = Control.FOCUS_NONE
	reset.text = "Reset keys"
	reset.add_theme_font_size_override("font_size", 12)
	reset.add_theme_color_override("font_color", Color(0.72, 0.68, 0.6))
	reset.pressed.connect(func() -> void:
		_rebinding = ""
		Progress.reset_keybinds()
		for id: String in _rebind_btns:
			(_rebind_btns[id] as Button).text = _key_name(Progress.keybind(id)))
	col.add_child(reset)

	col.add_child(_detail_rule())
	var quit := Button.new()
	quit.custom_minimum_size = Vector2(0, 42)
	quit.text = "Abandon the hunt"
	quit.add_theme_color_override("font_color", Color(0.95, 0.55, 0.45))
	quit.pressed.connect(_confirm_quit)
	col.add_child(quit)

	var back := Button.new()
	back.custom_minimum_size = Vector2(0, 38)
	back.text = "Back"
	back.flat = true
	back.pressed.connect(_close_overlay)
	col.add_child(back)


func _close_overlay() -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()
	_detail = null
	# Closing mid-rebind must not leave the capture armed — it would swallow the
	# next key press and bind it to whatever row happened to be listening.
	_rebinding = ""
	_rebind_btns = {}


## Overlays must live in their OWN CanvasLayer, above the HUD's.
##
## Parenting them to this Node3D put them on the root canvas (layer 0) while the
## Hud CanvasLayer sits above it — so the settings panel rendered behind the hand
## and its Back button was unclickable under a card.
func _overlay_root() -> CanvasLayer:
	var found := get_node_or_null("OverlayLayer")
	if found is CanvasLayer:
		return found
	var layer := CanvasLayer.new()
	layer.name = "OverlayLayer"
	layer.layer = 20
	add_child(layer)
	return layer


## Asks first: a run is long, and a mis-tap that binned it silently would be worse
## than having no way out at all.
func _confirm_quit() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Leave the hunt?"
	d.dialog_text = "This run ends here. Progress in it is lost."
	d.ok_button_text = "Leave"
	d.cancel_button_text = "Keep hunting"
	add_child(d)
	d.confirmed.connect(func() -> void:
		get_tree().change_scene_to_file("res://views/menu.tscn"))
	d.canceled.connect(d.queue_free)
	d.popup_centered()


## The full rules for one card, on demand — the home that lets the card FACE stop
## being a rulebook.
##
## Shows what it does right now (live, from Combat.preview), the authored text, and
## every keyword it touches with the mechanic explained. Before this, each card
## re-taught its own mechanics on the face forever, which is why card text kept
## growing. See design/feel-and-readability.md.
func _show_card_detail(data: Dictionary) -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()

	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.72)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	# Tap anywhere to dismiss — one gesture, no close button to aim at on a phone.
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			if _detail != null and is_instance_valid(_detail):
				_detail.queue_free()
				_detail = null)

	# A CenterContainer, not a CENTER anchor preset: the panel's height depends on how
	# many keywords the card touches, and an anchored panel grows off the bottom of
	# the screen instead of staying centred.
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(430, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 18.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)

	col.add_child(_detail_label("%s   ✦%d" % [String(data.get("name", "")),
		int(data.get("cost", 0))], 21, Color(1, 0.94, 0.8)))

	var rarity := String(data.get("rarity", ""))
	if rarity != "":
		var rc := Color(0.72, 0.68, 0.6)
		if rarity == "uncommon":
			rc = Color(0.55, 0.78, 0.92)
		elif rarity == "rare":
			rc = Color(1, 0.84, 0.42)
		col.add_child(_detail_label(rarity.to_upper(), 11, rc))

	col.add_child(_detail_rule())
	# What it does right now — the same one sentence the card face shows, from the
	# same formatter, so the two can never disagree.
	var live := RichTextLabel.new()
	live.bbcode_enabled = true
	live.text = CardView.face_text(data, true)  # same colouring as the card face
	live.fit_content = true
	live.scroll_active = false
	live.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	live.mouse_filter = Control.MOUSE_FILTER_IGNORE
	live.custom_minimum_size = Vector2(394, 0)
	live.add_theme_font_size_override("normal_font_size", 15)
	live.add_theme_color_override("default_color", Color(0.94, 0.9, 0.82))
	col.add_child(live)

	# The authored line explains the card's SHAPE ("3 more damage per Rhythm") —
	# the part a single live number can't convey. It belongs here, where there is
	# room, not crammed onto the face beside the numbers it produces. shape_text
	# drops the clauses the live line above already stated.
	var authored := CardView.shape_text(data)
	if authored != "":
		col.add_child(_detail_label(authored, 12, Color(0.76, 0.72, 0.64), true))

	var kws: Array = data.get("keywords", [])
	if not kws.is_empty():
		col.add_child(_detail_rule())
		for k in kws:
			var kd: Dictionary = k
			# Underlined here too. A keyword wears the same face wherever it
			# appears, or the underline stops meaning "this is a keyword".
			col.add_child(_underlined(String(kd.get("name", "")), 14, Color(1, 0.86, 0.5)))
			col.add_child(_detail_label(String(kd.get("text", "")), 12,
				Color(0.8, 0.76, 0.68), true))

	col.add_child(_detail_rule())
	col.add_child(_detail_label("tap anywhere to close", 11, Color(0.6, 0.56, 0.5)))


## A keyword heading. A plain Label cannot underline, so the one place in the UI
## that needs the mark takes a RichTextLabel to get it.
func _underlined(txt: String, size: int, tint: Color) -> Control:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.text = "[u]%s[/u]" % txt
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_color_override("default_color", tint)
	return r


func _detail_label(txt: String, size: int, tint: Color, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = txt
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", tint)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(394, 0)
	return l


func _detail_rule() -> Control:
	var r := ColorRect.new()
	r.color = Color(0.4, 0.33, 0.22, 0.7)
	r.custom_minimum_size = Vector2(0, 1)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## A damage number at the point of impact.
##
## Until now the only place a hit's SIZE appeared was a line of text in the log,
## four lines down in the corner — so the loop was: play a card, see a flash, then
## READ to find out what happened. See design/feel-and-readability.md.
##
## Sized against the beast's own height so it stays legible whether you're fighting
## a pup or a Titan (the camera pulls back with the beast, so a fixed size shrinks).
func _damage_popup(amount: int, at: Vector3, weak_point: bool, on_hunter: bool = false) -> void:
	if amount <= 0:
		return
	var lbl := Label3D.new()
	lbl.text = str(amount)
	lbl.font_size = 128
	lbl.outline_size = 30
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true          # never lost inside the beast's mesh
	lbl.fixed_size = false
	var reach: float = maxf(_beast_box.size.y, 2.0)
	lbl.pixel_size = (0.0010 if not weak_point else 0.0014) * reach
	if on_hunter:
		lbl.pixel_size = 0.0009 * reach
		lbl.modulate = Color(1.0, 0.45, 0.38)      # your blood, not the beast's
	elif weak_point:
		lbl.modulate = Color(1.0, 0.86, 0.36)      # the sigil hit — the big one
	else:
		lbl.modulate = Color(0.95, 0.93, 0.88)
	lbl.outline_modulate = Color(0.08, 0.05, 0.04, 0.95)
	lbl.position = at
	_rig.add_child(lbl)

	var rise := reach * 0.22
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position", at + Vector3(0.0, rise, 0.0), 0.85) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.45).set_delay(0.4)
	tw.chain().tween_callback(lbl.queue_free)


## A hit on the beast: recoil, a flash of light, a kick of camera shake — much
## bigger when it lands on the weak point.
func _strike(weak_point: bool) -> void:
	Sfx.play("strike_weakpoint" if weak_point else "attack")
	_beast_punch = 1.0 if weak_point else 0.45
	_shake = maxf(_shake, 0.85 if weak_point else 0.3)
	_flash.position = _sigil.position if weak_point else _beast_box.get_center()
	_flash.light_energy = 7.0 if weak_point else 2.5
	if weak_point:
		_dust.position = _sigil.position
		_dust.restart()


## The beast bucks: a heavy jolt and dust off its hide.
func _beast_shake() -> void:
	Sfx.play("shake")
	_shake = maxf(_shake, 1.0)
	_beast_punch = 0.6
	_dust.position = _beast_box.get_center()
	_dust.restart()


# --- hand -----------------------------------------------------------------

func _render_hand() -> void:
	for c in _hand_row.get_children():
		c.queue_free()
	var priv := _my_private()
	var selecting := not _selecting.is_empty()
	for card in priv.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		var idx := int(card["index"])
		# while picking, EVERY card is tappable — the pick is the point — except
		# the ones already spoken for
		var playable: bool = bool(card["playable"])
		if selecting:
			playable = idx != int(_selecting.get("sac", -1))
		# Portrait form along the bottom (Nick, 2026-08-15). The left rail was
		# chosen in Aug to keep the 3D scene clear; with the camera pulled back and
		# the beasts scaled up, the bottom strip is affordable again and the cards
		# read far better at portrait size.
		cv.setup(card, playable, false)
		var c_card: Dictionary = card
		cv.tapped.connect(func() -> void: _on_card_tapped(c_card, cv))
		cv.inspect_requested.connect(_show_card_detail)
		cv.keyword_requested.connect(_show_keyword)
		cv.timing_resolved.connect(func(quality: int) -> void:
			# The clip is still binary (nailed it / missed it) — a "good" vs.
			# "perfect" distinction is the display half (backlog #34), not this one.
			Sfx.play("nail" if quality > Combat.TIMING_MISS else "slip")
			_client.play_card(idx, quality > Combat.TIMING_MISS, _cmd_slot(), -1, -1, quality))
	var players: Array = _client.shared.get("players", [])
	var me: Dictionary = players[_me()] if _me() < players.size() else {}
	if selecting:
		_status.text = _selection_prompt()
		_status.visible = true   # a transient instruction, not an identity
		_render_energy(me)
		_show_switch_target(players)
		_end_btn.disabled = bool(priv.get("ended", false))
		return
	_status.visible = false
	_render_energy(me)
	_show_switch_target(players)
	_end_btn.disabled = bool(priv.get("ended", false))


# --- playing a card, including the multi-pick cards -----------------------

func _on_card_tapped(card: Dictionary, cv: CardView) -> void:
	_dismiss_coach()   # you're playing; you don't need to be told to play
	var index := int(card["index"])
	if not _selecting.is_empty():  # this tap is a pick for the active card
		_pick_for_selection(index)
		return
	if bool(card.get("timed", false)):
		# a relic can widen the window, so pass the team's bonus through
		var bonus := float(int(_client.shared.get("mods", {}).get("timing_zone", 0))) / 100.0
		var hits := int(card.get("timed_hits", 1))
		if Progress.timing_style() == Progress.TIMING_CIRCLE and _circle != null:
			# Same grading, a different face: the circle opens ON the beast at the
			# hold this card is reaching for, so the tensest moment of the turn
			# happens where you are looking instead of in a strip under the cards.
			_circle_index = index
			var anchor := cv.get_global_rect().get_center() - Vector2(0.0, cv.size.y * 0.62)
			var climb := _card_climb(card)
			_circle.begin(bonus, _cam, _hold_points(card, hits, anchor),
				climb >= SLIDER_CLIMB)
			return
		cv.zone_bonus = bonus
		cv.start_timing(hits)
		return
	if bool(card.get("exhaust_pick", false)) or bool(card.get("cheapen_pick", false)) 			or bool(card.get("meld", false)):
		_start_selection(card)
		return
	Sfx.play("card")
	_client.play_card(index, true, _cmd_slot())


func _selection_prompt() -> String:
	var mode := String(_selecting.get("mode", "exhaust"))
	var step := int(_selecting.get("step", 0))
	var nm := String(_selecting.get("name", "card"))
	var cancel := "   (tap %s again to cancel)" % nm
	match mode:
		"meld":
			return "%s — tap the %s card to meld%s" % [nm, "FIRST" if step == 0 else "SECOND", cancel]
		"exhaust_cheapen":
			if step == 0:
				return "%s — tap a card to SACRIFICE%s" % [nm, cancel]
			return "%s — tap a card to make CHEAPER" % nm
		_:
			return "%s — tap a card to SACRIFICE%s" % [nm, cancel]


func _start_selection(card: Dictionary) -> void:
	var mode := "exhaust"
	var picks := 1
	if bool(card.get("meld", false)):
		mode = "meld"
		picks = 2
	elif bool(card.get("cheapen_pick", false)):
		mode = "exhaust_cheapen"
		picks = 2
	_selecting = {"play_index": int(card["index"]), "name": String(card.get("name", "card")),
		"mode": mode, "picks": picks, "step": 0, "sac": -1, "target": -1}
	Sfx.play("card")
	_render_hand()


func _pick_for_selection(idx: int) -> void:
	if idx == int(_selecting.get("play_index", -1)):
		_selecting = {}  # tapped the selection card again — cancel
		_render_hand()
		return
	if int(_selecting.get("step", 0)) == 0:
		_selecting["sac"] = idx
	elif idx == int(_selecting.get("sac", -1)):
		return  # the two picks must be different cards
	else:
		_selecting["target"] = idx
	_selecting["step"] = int(_selecting.get("step", 0)) + 1
	if int(_selecting["step"]) >= int(_selecting.get("picks", 1)):  # all picks in — fire
		var play_index := int(_selecting.get("play_index", -1))
		var sac := int(_selecting.get("sac", -1))
		var target := int(_selecting.get("target", -1))
		_selecting = {}
		Sfx.play("card")
		_client.play_card(play_index, true, _cmd_slot(), sac, target)
	else:
		_render_hand()


# --- the party and the run's standing ------------------------------------

## Co-op means your ally's state is not optional information: HP, block,
## Energy, how high they've climbed, whether they're hanging, and whether the
## beast is about to hit them. The 3D scene shows WHERE they are; this says how
## they're doing.
func _render_party(s: Dictionary, boss_target: int, move_type: String) -> void:
	for c in _party.get_children():
		c.queue_free()
	var players: Array = s.get("players", [])
	var sweeps: bool = move_type in ["attack_all", "swipe_high", "swipe_low"]
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var aimed: bool = sweeps or i == boss_target
		_party.add_child(_party_card(p, i, aimed))
	var bits: Array = ["Gold %d" % int(s.get("gold", 0))]
	var relics: Array = s.get("relics", [])
	if not relics.is_empty():
		bits.append(", ".join(relics))
	_run_label.text = "  •  ".join(bits)


## Solo only: the Switch button wears the face of the hunter you'd switch TO, so
## the swap is a picture rather than a word. Knowing who you're holding and who
## you'd get should both be glanceable.
func _show_switch_target(players: Array) -> void:
	_switch_btn.visible = _is_solo()
	if not _is_solo():
		return
	var other := 1 - _me()
	if other >= players.size():
		return
	var path := String((players[other] as Dictionary).get("portrait", ""))
	if path != "" and ResourceLoader.exists(path):
		_switch_btn.icon = load(path)
		_switch_btn.expand_icon = true
	# Name the shortcut on the control it accelerates — a keybind nobody is told
	# about is a keybind nobody uses.
	_switch_btn.text = "Switch  ⇥"
	_switch_btn.tooltip_text = "Swap hunter.  Tab, or 1 / 2 to pick one directly."
	_switch_btn.add_theme_color_override("font_color", _slot_color(other))


func _slot_color(slot: int) -> Color:
	return SLOT_TINT[slot % SLOT_TINT.size()]


## Energy, big, beside the hand — Slay the Spire's one un-shrunken HUD number.
##
## This replaced a panel in the top-left that restated the active hunter's entire
## row: portrait, HP, energy, Height, incoming, piles. All of it was already in the
## party panel, so the screen said everything twice (Nick, 2026-08-15: "still have
## some clutter"). The party panel now owns hunter state, and the only thing lifted
## out is the number you consult before every single card.
func _render_energy(p: Dictionary) -> void:
	var out := int(p.get("energy", 0))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.12, 0.07, 0.92) if out > 0 else Color(0.11, 0.1, 0.1, 0.85)
	style.set_border_width_all(3)
	style.border_color = Color(0.82, 0.66, 0.34) if out > 0 else Color(0.34, 0.32, 0.30)
	# A rounded SQUARE, not a disc. It was a disc — "it should read as an orb" —
	# right up until the osu face started drawing dark circles with a gold rim and
	# a big number in them, at which point the most permanent thing on the HUD and
	# the most urgent thing on the screen were speaking the same language (Nick,
	# 2026-08-25: "the number in the corner is confusing a bit. its the same
	# design as the osu numbers"). Two things cannot share one shape, and the one
	# you have to react to in half a second wins it.
	style.set_corner_radius_all(14)
	_energy_orb.add_theme_stylebox_override("panel", style)
	_energy_label.text = str(out)
	_energy_label.add_theme_color_override("font_color",
		Color(1, 0.87, 0.5) if out > 0 else Color(0.55, 0.52, 0.5))

	# Pile counts tucked under the orb. Small on purpose: they matter to the Goblin,
	# whose kit scales off the burn pile, and to nobody else most turns.
	var priv := _my_private()
	_piles.visible = priv.has("draw")
	if priv.has("draw"):
		_piles.text = "draw %d\ndisc %d · burn %d" % [int(priv.get("draw", 0)),
			int(priv.get("discard", 0)), int(priv.get("exhaust", 0))]




## A character's face at a fixed size, tinted frame optional. Portraits are baked
## large, so the texture is always told to ignore its own size.
func _portrait_of(p: Dictionary, px: int, ring: Color = Color(0, 0, 0, 0)) -> Control:
	var path := String(p.get("portrait", ""))
	if path == "" or not ResourceLoader.exists(path):
		var dot := ColorRect.new()   # never leave the slot unidentified
		dot.color = ring if ring.a > 0.0 else Color(0.5, 0.45, 0.4)
		dot.custom_minimum_size = Vector2(px, px)
		return dot
	var tex := TextureRect.new()
	tex.texture = load(path)
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return tex


func _party_card(p: Dictionary, slot: int, aimed: bool) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.1, 0.08, 0.8)
	style.set_border_width_all(2 if slot == _me() else 1)
	# the hunter in the beast's sights is outlined in red — the single most
	# time-critical fact on the screen
	# red when the beast is aiming at them, else their own identity colour so the
	# card, the portrait in the rail and the pip in the scene all agree
	style.border_color = Color(0.85, 0.32, 0.26) if aimed else _slot_color(slot)
	style.set_corner_radius_all(5)
	style.content_margin_left = 8.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)
	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)
	outer.add_child(_portrait_of(p, 34))
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	outer.add_child(box)
	var who := Label.new()
	who.text = "%s%s" % [String(p.get("name", "")), "  (you)" if slot == _me() else ""]
	who.add_theme_font_size_override("font_size", 13)
	who.add_theme_color_override("font_color", Color(1, 0.93, 0.78))
	box.add_child(who)
	var bar := ProgressBar.new()
	bar.max_value = maxi(int(p.get("max_hp", 1)), 1)
	bar.value = int(p.get("hp", 0))
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 12)
	box.add_child(bar)
	var stats := Label.new()
	var parts: Array = ["HP %d/%d" % [int(p.get("hp", 0)), int(p.get("max_hp", 0))]]
	if int(p.get("block", 0)) > 0:
		parts.append("◈%d" % int(p.get("block", 0)))
	# Energy only for the ALLY — yours is the orb beside your hand, and printing it
	# in both places is exactly the doubling this pass exists to remove.
	if slot != _me():
		parts.append("✦%d" % int(p.get("energy", 0)))
	# "↑2 / 6", never a bare "↑2" — a Height with nothing to measure it against
	# tells you where you are and not how far is left (Nick, 2026-08-16).
	var wp := int(p.get("weak_point_height", 0))
	parts.append("↑%d / %d" % [int(p.get("foothold", 0)), wp] if wp > 0
		else "↑%d" % int(p.get("foothold", 0)))
	# What the telegraphed move costs THIS hunter, after their Block. The red border
	# already says "aimed at"; this says whether they survive it.
	var inc: Dictionary = p.get("incoming", {})
	var through := int(inc.get("through", 0))
	if int(inc.get("raw", 0)) > 0:
		parts.append("⚔%d" % through if through > 0 else "⛨ blocked")
	if bool(p.get("reached", false)):
		parts.append("at the sigil")
	elif not bool(p.get("secure", true)):
		parts.append("hanging!")
	if bool(p.get("ended", false)):
		parts.append("done")
	stats.text = "   ".join(parts)
	stats.add_theme_font_size_override("font_size", 12)
	stats.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	box.add_child(stats)
	# Tapping a hunter's card holds that hunter, and the camera locks onto them.
	# The card already shows who they are and what is about to hit them, so it is
	# the thing you are looking at when you decide to swap — asking you to look
	# away to a separate button was the long way round (Nick: "make things more
	# clickable"). Solo only: in multiplayer you cannot hold your ally's hand.
	if _is_solo():
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.tooltip_text = "Hold this hunter — the camera locks on."
		panel.gui_input.connect(func(e: InputEvent) -> void:
			if not (e is InputEventMouseButton):
				return
			var mb := e as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
				_switch_to(slot))
	return panel


## Contextual onboarding, shared with the 2D client: the rule that matters right
## now announces itself once, then never again. The armoured-hide gate is the
## one that most needs saying — without it, hitting a beast from the ground
## reads as the cards being broken rather than as the climb being the point.
func _update_coach(s: Dictionary) -> void:
	# Gated here rather than inside Coach so Coach stays a pure function of the
	# snapshot — its tests must not depend on whatever this machine's config says.
	if not Progress.hints_enabled():
		_coach_id = ""
		_coach.visible = false
		return
	var hint := Coach.hint_for(s, _my_private(), _me())
	if hint.is_empty():
		_coach_id = ""
		_coach.visible = false
		return
	if String(hint["id"]) == _coach_id:
		return           # already up — don't restart its clock on every snapshot
	_coach_id = String(hint["id"])
	_coach_text.text = String(hint["text"])
	_coach.visible = true
	_coach_left = COACH_SECONDS


## Hints teach once and then get out of the way — they should never be a chore.
## Anything that dismisses one also marks it seen, exactly as the button does:
## running out the clock and pressing "Got it" mean the same thing.
func _dismiss_coach() -> void:
	if _coach_id == "":
		return
	Progress.mark_hint_seen(_coach_id)
	_coach_id = ""
	_coach_left = 0.0
	_coach.visible = false


## What just happened, in words. The 3D scene shows the blow landing but not
## WHY it was small — the armoured-hide flag that explains a chipped hit only
## exists here, which is exactly the confusion the log was added to fix.
func _render_log(s: Dictionary) -> void:
	var entries: Array = s.get("log", [])
	var n := 16 if _log_expanded else 4
	_log_label.text = "
".join(entries.slice(maxi(entries.size() - n, 0)))
	# Collapsed by default: Slay the Spire shows no combat log at all, and a panel
	# reading "— Round 1 —" beside the beast is pure noise. The toggle stays, so the
	# history is one tap away when something surprising happens.
	_log_panel.visible = _log_expanded and not entries.is_empty()
	_log_toggle.text = "Log ▾" if _log_expanded else "Log ▸"
