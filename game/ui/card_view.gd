## Reusable card widget (CLAUDE.md §5, §8: presentation, single-pointer, scalable).
## The whole card is one tappable Button; its contents are built from a card
## snapshot dict (name/cost/text/target/icon) — no /core types. A silhouette icon
## gives each card an at-a-glance identity (the minimalist Titan-slayer look, and
## a cheap placeholder that can later swap for real art).
class_name CardView
extends Button

## A normal tap (not during timing).
signal tapped
## A timed card's throw resolved: Combat.TIMING_MISS/GOOD/PERFECT (backlog #33
## — outside the green zone is a miss; inside it but off the bullseye core is a
## "good" landing; inside the core is "perfect". A multi-hit chain reports its
## WORST window, so a shaky chain can't average up to perfect.
signal timing_resolved(quality: int)
## The player asked what this card actually does. A dedicated button rather than a
## hover or a long-press: CLAUDE.md §5 forbids hover-only information (no hover on
## touch), and a hold would fight the timing tap.
signal inspect_requested(data: Dictionary)
## The player right-clicked one KEYWORD and wants just that term explained.
signal keyword_requested(keyword: Dictionary)

## Rail cards size themselves to the column's width; only the height is fixed, and
## it's set by the live-effect line plus two clipped lines of prose and the timing
## strip. The prose is deliberately allowed to run out of room — the numbers are on
## the effect line and the full rules are one tap away in the inspector.
const RAIL_HEIGHT := 88
const RAIL_TEXT_LINES := 2

## A value a buff or scaling changed from what the card prints — Slay the Spire
## greens these, and it's the only way a player sees a passive is doing something.
const LIVE_COLOR := "95c37a"   # TARGET's muted green (builder 2026-10-10 run 3; was 7fd45c)
## The half of a timed card you only get by landing it.
const NAILED_COLOR := "ffd35c"
## A rules term with a tooltip behind it. Never used decoratively.
const KEYWORD_COLOR := "dcc596"   # TARGET's pale tan: glyph cores ~(205,182,138) (builder 2026-10-10 run 6; was e4a955, f0b45a)
## TARGET's keyword underline: a dull dark tan, not the ink (run 6).
const KEYWORD_LINE := "7d6a46"
## TARGET's keyword strokes are heavier than its rules: the hand card's [b]
## is the rules face emboldened by this much more (run 6).
const A1_KEYWORD_EMBOLDEN := 0.3

## A full card's own box, big (no_cost) vs normal, desktop vs handheld — named
## so setup() (which picks the box) and _rich_body() (which has to size the
## font that fits inside it) read the same numbers instead of each keeping
## its own copy. They used to: setup() knew the handheld box was ~16%
## narrower and _rich_body()'s length-based shrink table didn't, tuned against
## the desktop width alone, so the longest reward card's text clipped mid-
## sentence on the phone layout with nowhere left to shrink to (found by the
## fixer lane, design/progress/bugs.md 2026-09-09 Pass A).
const BOX_DESKTOP_BIG := Vector2(191, 268)
## 264 tall, not 228 (builder 2026-10-09): TARGET's hand cards run off the
## bottom of the frame. The A1 face keeps its 228-tall layout (A1_ASPECT) and
## the extra height is body under the rules, hidden by the fan's tuck.
const BOX_DESKTOP_NORMAL := Vector2(162, 264)
const BOX_HANDHELD_BIG := Vector2(161, 226)
const BOX_HANDHELD_NORMAL := Vector2(135, 190)

const ZONE_MIN := 0.40
const ZONE_MAX := 0.60
## The bullseye core within the zone — already drawn brighter in
## _build_timing_strip() as an aim point; backlog #33 makes it mean something:
## land inside THIS band (not just the wider zone) for the full timed bonus.
const CORE_MIN := 0.47
const CORE_MAX := 0.53
const SWEEP_SPEED := 1.9    # sweeps per second — quick; timing should demand focus (Nick)
const WINDOW_SECONDS := 2.5 # max time per timing window; expire = the card fizzles (Nick)

var _timing := false
var _t := 0.0
var _dir := 1.0
var _elapsed := 0.0  # time spent in the current window
## Relic bonus widening the success zone on each side (0.06 = +6% each way).
var zone_bonus := 0.0
var _strip: Control
var _data := {}      # the snapshot this card was built from, for right-click inspect
var _hover_meta := ""  # "kw:<id>" while the pointer is over a keyword
var _clock: Control  # the timed badge, if this card has one
var _marker: ColorRect
var _count_lbl: Label
var _hits_needed := 1  # sequential timing windows to nail (Satchel Charge = 3)
var _hits_done := 0
var _worst_quality := Combat.TIMING_PERFECT  # the weakest window in a multi-hit chain wins
var _compact := false  # built in the rail form (see setup)

# Kenney "Board Game Icons" (white-fill SVGs → tint via modulate). Keys are the
# effect roles the host maps cards to (see game_host._card_icon).
## Ours, built by tools/blender/icons.py from the same palette as everything
## else. They were 28 Kenney glyphs recoloured by a tint table until 2026-08-26 —
## grey shapes drawn for a board-game asset pack, doing duty as the art on all
## 164 cards. The tint table existed to tell them apart; these carry their own
## colour, so it is gone.
##
## The comment beside each one is the BRIEF: what a card wearing it does. An icon
## that shows flavour instead of mechanic is worse than none, because a hand is
## read by shape, fast.
const ICONS := {
	"sword":   preload("res://assets/icons/sword.png"),                        # a plain attack
	"shield":  preload("res://assets/icons/shield.png"),                      # block
	"bow":     preload("res://assets/icons/bow.png"),                            # a ranged strike
	"fire":    preload("res://assets/icons/fire.png"),                          # burning damage
	"skull":   preload("res://assets/icons/skull.png"),                        # poison, wound, death
	"flask":   preload("res://assets/icons/flask.png"),                        # a potion
	"climb":   preload("res://assets/icons/climb.png"),                        # gain Height
	"bomb":    preload("res://assets/icons/bomb.png"),                          # a big one-off blast
	"gadget":  preload("res://assets/icons/gadget.png"),                      # the Engineer builds
	"draw":    preload("res://assets/icons/draw.png"),                          # draw a card
	"expose":  preload("res://assets/icons/expose.png"),                      # mark a weak point
	"taunt":   preload("res://assets/icons/taunt.png"),                        # pull its attention
	"support": preload("res://assets/icons/support.png"),                    # help the ally
	"relic":   preload("res://assets/icons/relic.png"),                        # a lasting boon
	"rally":   preload("res://assets/icons/rally.png"),                        # lift the whole party
	"volley":  preload("res://assets/icons/volley.png"),                      # several hits at once
	"guard":   preload("res://assets/icons/guard.png"),                        # block, but timed
	"wall":    preload("res://assets/icons/wall.png"),                          # block that scales
	"ascend":  preload("res://assets/icons/ascend.png"),                      # a big climb
	"rope":    preload("res://assets/icons/rope.png"),                          # both hunters climb
	"lift":    preload("res://assets/icons/lift.png"),                          # haul the ally to you
	"target":  preload("res://assets/icons/target.png"),                      # scales off Exposed
	"rhythm":  preload("res://assets/icons/rhythm.png"),                      # the Frog's combo counter
	"timer":   preload("res://assets/icons/timer.png"),                        # timed, nothing else
	"cog":     preload("res://assets/icons/cog.png"),                            # meld / fuse
	"burn":    preload("res://assets/icons/burn.png"),                          # exhaust a card
	"stack":   preload("res://assets/icons/stack.png"),                        # draw / hand size
	"peak":    preload("res://assets/icons/peak.png"),                          # a strike that scales with Height
	"intangible": preload("res://assets/icons/intangible.png"),      # a hit past Block is capped at 1
	"buffer":  preload("res://assets/icons/buffer.png"),                      # the next hit is cancelled outright
	"plated_armour": preload("res://assets/icons/plated_armour.png"),  # Block that survives the round
	"thorns":  preload("res://assets/icons/thorns.png"),                      # a landed attack reflects damage back
	"light":   preload("res://assets/icons/light.png"),                      # generate Light, the Lightbearer's resource
	"frail":   preload("res://assets/icons/frail.png"),                      # Block gained is reduced while stacked
	"strength": preload("res://assets/icons/strength.png"),                # gain Strength, adds to every attack
	"dexterity": preload("res://assets/icons/dexterity.png"),              # gain Dexterity, adds to Block gained
}
const ENERGY_ICON := preload("res://ui/icons/energy.svg")


## Build the card from a snapshot dict. `playable` greys it out when false.
##
## `compact` builds the RAIL form: a short, wide row instead of a portrait card.
## The fight stacks these down the left edge so the 3D scene keeps the screen
## (Nick, 2026-08-06) — a row of portrait cards ate the bottom third, which is
## exactly where the beast you're climbing stands. Everywhere the cards ARE the
## screen (rewards, shop, campfire, character select) keeps the portrait form.
const FOIL_SHADER := preload("res://ui/foil.gdshader")

var _foil: ColorRect = null
## Nick, 2026-09-30 10:59: "remove cost"; then 11:44: "no we still need cost
## gems". The gem is back; the switch stays so the next change is one line.
const SHOW_COST := true


## Whether a card face draws its cost. Static so a test can pin it.
static func shows_cost(data: Dictionary) -> bool:
	return SHOW_COST and not bool(data.get("no_cost", false))
## The moulding, drawn as a layer OVER the art rather than as the Button's
## stylebox - a stylebox draws behind every child and the art would hide it.
var _frame_rect: Control = null
## The border (Nick, 2026-09-30: "a redesign of the card borders is needed"):
## carved obsidian with a brass fillet and a thin line of the hunter's colour,
## drawn by card_border.gdshader. FRAMES and frames.py still dress the rail
## form and the deck list.
const BORDER_SHADER := preload("res://ui/card_border.gdshader")
## Width of the dark face, px. The art starts band + 4.5 in.
const BORDER_BAND := 13.0
const BORDER_RADIUS := 12.0
## The name ribbon, darkened onto the border's obsidian.
const BANNER_TINT := Color(0.34, 0.31, 0.33)
## hunter -> [line colour, its lit side]. frames.py's CHARACTERS, so a hunter
## keeps the colour it has always had.
const BORDER_HUES := {
	"frog": [Color("3F7A55"), Color("7FB894")],
	"vine_weaver": [Color("6B58A6"), Color("A794D6")],
	"mountain_climbers": [Color("5F82B5"), Color("9CB8DC")],
	"goblin_mech": [Color("C07E4F"), Color("E0AE85")],
	"lightbearer": [Color("D9A94E"), Color("F2D492")],
	"common": [Color("5D6171"), Color("9AA0B2")],
}


## The warm halo round a playable card, px, and its colour.
const PLAYABLE_GLOW_SIZE := 16
## The playable rim on the A1 frame, px.
const SEAT_RIM_SIZE := 4
const PLAYABLE_GLOW := Color(1.0, 0.70, 0.22, 0.85)


## The halo a card wears: gold when it can be played, none when it cannot.
## Static so a test can pin it.
static func playable_glow(playable: bool) -> Color:
	return PLAYABLE_GLOW if playable else Color(0, 0, 0, 0)


## The owner's line colour and its lit side. Static so a test can pin it.
static func border_hues(character: String) -> Array:
	return BORDER_HUES.get(character, BORDER_HUES["common"])
## The rules text, the type pill and the panel they sit on. Held so the hand can
## hide them until a card is highlighted.
var _rules: RichTextLabel = null
var _pill: Control = null
var _panel: ColorRect = null

## Force every card foil, for looking at it. Set by tools/screenshot.gd's
## `foil` flag — a foil is a rare pull by design, so without this there is no
## reliable way to get one on screen to judge.
static var force_foil := false
## Same, for the borderless treatment. Also rare by design.
static var force_borderless := false
## Pin every 3D window to one view, -1 (left) to +1 (right). Anything outside
## that range means "off", which is the default. A screenshot cannot move a
## mouse, so without this the parallax can only ever be photographed at
## whatever angle the drift happened to be at - and two shots that differ by an
## unknown amount prove nothing about whether the effect works.
static var force_turn := 2.0

## Where a borderless card's layers go — the rounded clip box (see
## _build_borderless). null on a framed card, where they go on the Button
## itself. _layer() reads this, so nothing else has to know which kind of card
## it is building.
var _face_host: Control = null
## The full-bleed painting, when this card has one; a frame mock re-cuts it to
## its own art window. null on an icon card.
var _art_full: TextureRect = null

## The 3D window, when this card has one (backlog #84). See _window_art().
var _win: AtlasTexture = null
var _win_frames := 0
var _win_cols := 1
var _win_cell := Vector2i.ZERO
var _win_at := -1
## THIS card's own turn, -1 (left) to +1 (right). Outside that range means
## "off", which is the default and the normal case.
##
## Beats both the pointer and CardView.force_turn, because the deck inspector
## drags ONE card and everything else on screen should carry on as it was. A
## static could not express that.
var turn_override := 2.0
## While something else is driving this card's viewing angle, this replaces the
## pointer-relative tilt the foil normally reads.
##
## A dragged card sits UNDER the pointer, so the pointer's offset from the
## card's centre is roughly zero however far across the screen you have taken
## it - which means the foil would sit dead still exactly while the card is
## being waved about. What should drive it there is where the CARD is, not where
## the pointer is inside it, and only the hand knows that.
var tilt_override := Vector2.ZERO
var tilt_overridden := false


## The foil sheen, when this copy pulled one.
##
## An overlay rather than a material on the card itself: a CanvasItem's material
## applies only to its own drawing, so shading the button would leave the name,
## the cost and the rules text unshaded and the foil would stop at the frame.
## A rect on top catches the whole face, which is what a real foil does.
func _build_foil(data: Dictionary) -> void:
	_foil = ColorRect.new()
	_foil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_foil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_foil.color = Color(1, 1, 1, 1)
	var mat := ShaderMaterial.new()
	mat.shader = FOIL_SHADER
	# Every foil in a hand shimmers on its own phase. Sharing one makes two
	# cards move in lockstep, which reads as a filter over the screen rather
	# than as two separate objects catching the light.
	mat.set_shader_parameter("seed", float(String(data.get("id", "")).hash() % 997))
	_foil.material = mat
	# Inside the clip box on a borderless card. Added to the Button, the sheen
	# is a square and lights up the four corners the rounded art does not reach —
	# which is the same class of bug as the black corner tabs, arriving from the
	# other direction.
	if _face_host != null:
		_face_host.add_child(_foil)
	else:
		add_child(_foil)
	set_process(true)


## What stands in for turning the card in your hand.
##
## The tutorial drives its holographic material off Layer Weight -> Facing, the
## angle between the surface and the viewer. A 2D card has no such angle, so:
## the pointer on a desktop, the accelerometer on a phone, and a slow drift
## under both so a foil sitting untouched still breathes.
func _foil_tilt(t: float) -> Vector2:
	if tilt_overridden:
		return tilt_override
	var accel := Input.get_accelerometer()
	var here := get_global_rect()
	var has_rect := here.size.x > 0.0
	var rel := Vector2.ZERO
	if has_rect:
		rel = (get_global_mouse_position() - here.get_center()) / maxf(here.size.y, 1.0)
	return foil_tilt_for(t, accel, has_rect, rel)


## The math half of _foil_tilt(), lifted out so it can be hit from headless
## with plain scalars instead of a live Control in a Viewport (get_global_rect()
## and get_global_mouse_position() both need one). `has_rect` and `rel` are
## exactly what _foil_tilt() would have computed from a real on-screen card;
## the caller does that translation, this just picks and combines.
##
## Accelerometer wins over the pointer whenever the device reports one moving
## -- a phone in your hand is the case this branch exists for, and it should
## not fight a stray mouse position the OS still reports on touch input.
static func foil_tilt_for(t: float, accel: Vector3, has_rect: bool, rel: Vector2) -> Vector2:
	var drift := Vector2(sin(t * 0.6), cos(t * 0.43)) * 0.35
	if accel.length() > 0.1:
		return drift + Vector2(accel.x, accel.z) * 0.22
	if not has_rect:
		return drift
	return drift + rel.limit_length(1.5) * 0.5


## The card face is a LAYER STACK, not a column.
##
## Nick, on the Bash and Break references: "it looks like they started with a
## full art card then put the border around it." That is what those cards are,
## and it is a different construction from what we had. Ours was a padded
## MarginContainer holding a VBox, and a flow layout FILLS its parent - so
## every attempt to slide a full-bleed painting underneath it ended with the
## column covering the painting. Mixing flow layout and absolute layers is what
## broke the first attempt at this.
##
## So on a full card nothing flows. Every element is anchored and offset over
## the art. Child index IS draw order:
##
##   0  ground   dark fill, for a card whose art does not exist yet
##   1  art      the painting, full bleed
##   2  scrim    darkens the lower third so cream text survives a bright sky
##   3  frame    the moulding, transparent in the middle
##   4  pill     the type, straddling the scrim's top edge
##   5  rules    the text, on the scrim
##   6  pips     rarity, top right
##   7  banner   the name, straddling the top edge
##   8  orb      the cost, hung off the corner
##   9+ timing strip, clock badge, foil sheen
##
## ART_LAYER is deliberately a named index. Backlog #84 wants the Slay the Spire
## style 3D window on rare cards, and that effect arrives as a 120-frame sprite
## sequence - it replaces exactly one node, at exactly this index, and every
## layer above it keeps working untouched. See design/art/rare-card-3d-effect.md.
const ART_LAYER := 1


## Anchor a node over the card by FRACTIONS of the card, plus pixel nudges.
## Fractions rather than pixels because the same face is laid out at 135, 162
## and 191 wide and a hard-coded offset only ever looks right at one of them.
func _layer(node: Control, l: float, t: float, r: float, b: float,
		dl: float = 0.0, dt: float = 0.0, dr: float = 0.0, db: float = 0.0) -> Control:
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.anchor_left = l
	node.anchor_top = t
	node.anchor_right = r
	node.anchor_bottom = b
	node.offset_left = dl
	node.offset_top = dt
	node.offset_right = dr
	node.offset_bottom = db
	if node.get_parent() != null:
		pass   # placed where its caller already put it (the A1 window and body)
	elif _face_host != null:
		_face_host.add_child(node)
	else:
		add_child(node)
	return node


## Where this card sat before it was raised, in global coordinates, while it is
## raised; empty otherwise. A hovered card jumps up out of the fan and grows,
## which moves it out from under a mouse parked on its lower half — so it lost
## hover, dropped back under the mouse, gained hover, and rose again, every
## frame (Nick, 2026-09-22: "rapidly goes from your hand to selected"). The
## playtester measured 30 flips in 30 frames on the bottom half of every card.
## Counting the resting spot as part of the raised card makes the pointer stay
## inside it; clicks there play it, too.
## Stored as the resting TRANSFORM, not a rect: the outer cards of the fan sit
## tilted, and an upright rect missed their corners (still 5 flicker spots).
var hover_hold: Variant = null   # Transform2D (global, at rest) or null


func _has_point(point: Vector2) -> bool:
	if Rect2(Vector2.ZERO, size).has_point(point):
		return true
	if hover_hold == null:
		return false
	var at_rest: Vector2 = (hover_hold as Transform2D).affine_inverse() * (get_global_transform() * point)
	return Rect2(Vector2.ZERO, size).has_point(at_rest)


func setup(data: Dictionary, playable: bool = true, compact: bool = false) -> void:
	_compact = compact
	_data = data
	if compact:
		custom_minimum_size = Vector2(0, RAIL_HEIGHT)
	else:
		# 62:87 - Slay the Spire 2's own full-card ratio (their modding docs give
		# 310x435). Measured, not eyeballed: ours was 0.614, a good deal narrower
		# than theirs, which is why the face felt cramped however it was arranged.
		var big := bool(data.get("no_cost", false))
		if Screen.is_handheld():
			custom_minimum_size = BOX_HANDHELD_BIG if big else BOX_HANDHELD_NORMAL
		else:
			custom_minimum_size = BOX_DESKTOP_BIG if big else BOX_DESKTOP_NORMAL
	disabled = not playable
	text = ""
	if not mouse_entered.is_connected(_on_hover):
		mouse_entered.connect(_on_hover)
		mouse_exited.connect(_on_unhover)
	_apply_frame()
	for child in get_children():
		child.queue_free()
	_face_host = null   # _build_borderless sets it; _layer() and _build_foil read it
	_art_full = null
	_win = null         # _window_art() sets it if this card has a 3D window

	if compact:
		var pad := MarginContainer.new()
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for side in ["left", "top", "right", "bottom"]:
			pad.add_theme_constant_override("margin_" + side, 6)
		add_child(pad)
		pad.add_child(_rail_row(data))
	else:
		_build_face(data)

	_strip = _build_timing_strip()  # hidden until start_timing()
	add_child(_strip)
	_strip.anchor_left = 0.10
	_strip.anchor_right = 0.90
	_strip.anchor_top = 0.86
	_strip.anchor_bottom = 0.86
	_strip.offset_bottom = 10.0
	_clock = null
	if bool(data.get("timed", false)):
		_clock = _clock_badge(compact, int(data.get("timed_hits", 1)))
		add_child(_clock)
	_foil = null
	if bool(data.get("foil", false)) or force_foil:
		_build_foil(data)
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)
	if not gui_input.is_connected(_on_card_input):
		gui_input.connect(_on_card_input)


## Every layer of a full card, bottom to top. See the note on ART_LAYER.
func _build_face(data: Dictionary) -> void:
	var id := String(data.get("id", ""))

	# The borderless pull, before anything else is built — it is a different
	# card, not a framed card with pieces removed.
	#
	# Gated on the painting EXISTING. A borderless card is defined by the art
	# reaching the edge; run it on one of the 186 cards still wearing a shared
	# icon and you get a black rectangle with a glyph floating in it, which is
	# strictly worse than the framed version. /core rolls the flag blind because
	# it may not touch res:// (CLAUDE.md §11), so the check belongs here, and a
	# card that rolled borderless with no art simply draws normal.
	var art_path := CARD_ART + id + ".png"
	var painted := id != "" and ResourceLoader.exists(art_path) or _has_window(id)
	if painted and (bool(data.get("borderless", false)) or force_borderless):
		_build_borderless(data, load(art_path))
		return

	# 0 - ground, with ROUNDED corners matching the frame's. Nick: "the edges of
	# the borders of the card are just black squares" - the frame's corners are
	# rounded and transparent outside the curve, and a square dark rect behind
	# them showed through as four black tabs at every corner.
	var ground := Panel.new()
	var gsb := StyleBoxFlat.new()
	gsb.bg_color = Color(0.055, 0.052, 0.062)
	# Radius 13 and inset 1px: the frame's outer curve is about 11px, and a
	# ground rounded TIGHTER than the frame leaves a dark wedge poking past the
	# curve at every corner - the zoom of Tongue Snap's top-right showed it
	# plainly. The ground must always be the smaller shape.
	gsb.set_corner_radius_all(13)
	# Picture B's glowing edge on a card that can be played (Nick, 2026-10-04).
	var glow := playable_glow(not disabled)
	if SHIP_A1:
		glow = seat_glow(not disabled, String(data.get("character", "")))
	gsb.shadow_color = glow
	gsb.shadow_size = PLAYABLE_GLOW_SIZE if glow.a > 0.0 else 0
	if SHIP_A1:
		# No glow at all (queue, "HUD and cards: TARGET's look, no glow",
		# 2026-10-08): TARGET's cards sit on a plain dark edge.
		gsb.shadow_size = 0
	ground.add_theme_stylebox_override("panel", gsb)
	_layer(ground, 0, 0, 1, 1, 1.0, 1.0, -1.0, -1.0)

	# 1 - ART_LAYER. Full bleed, cropped to fill rather than letterboxed: the
	# card is a window onto a painting, not a painting pasted onto a card.
	var art := TextureRect.new()
	var own := CARD_ART + id + ".png"
	var win := _window_art(id)
	if win != null:
		art.texture = win
	elif id != "" and ResourceLoader.exists(own):
		# Mipmapped: a 620 px painting drawn ~90 px wide skipped texels and
		# read paler and grainier than TARGET's own art (2026-10-09).
		art.texture = _sharp_mip(load(own))
		art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	elif ICONS.has(String(data.get("icon", ""))):
		# No painting yet: the shared icon, small and centred, so the card is
		# still legible while 187 of these are waiting to be drawn.
		art.texture = ICONS[String(data.get("icon", ""))]
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		if SHIP_A1:
			# inside the A1 art window, clear of the title plate
			# TARGET draws the glyph big: ~0.7 of the card's width (2026-10-09).
			_layer(art, 0.11, 0.11, 0.83, 0.465)   # clear of the pill (run 14); TARGET's glyph ~6% bigger and ~3 px left (run 16)
		else:
			_layer(art, 0.18, 0.12, 0.82, 0.52)
		_build_upper(data)
		return
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.clip_contents = true
	# Inset to the frame's inner face, top and bottom included. Full-rect, the
	# painting ran OVER the border - above the banner at the top, past the rail
	# at the bottom (Nick's screenshot of Leap shows both). The border frames
	# the art; the art does not wear the border.
	_layer(art, 0, 0, 1, 1, 8.0, 8.0, -8.0, -10.0)
	_art_full = art
	_build_upper(data)


## Layers 2 and up: everything that sits ON the art.
func _build_upper(data: Dictionary) -> void:
	if FRAME_MOCKS.has(frame_mock):
		_build_mock_frame(frame_mock_spec(frame_mock, _data))
		return
	if SHIP_A1:
		_build_a1()
		return
	# 2 - scrim. Cream rules text over a bright sky is unreadable, and the
	# reference darkens the foot of the art for exactly this reason.
	# SOLID, not a scrim. Nick: "make sure the black space at the bottom of the
	# border where the text is solid. I could sort of see the art behind it."
	# Look at Finisher: the lower half of a Slay the Spire card is an opaque
	# olive panel, not a darkened piece of the painting. Art showing through is
	# what makes rules text hard to read at hand size.
	# The seam sits at 56% of the card, not 70%. Measure Finisher: the art is
	# the band from the banner to just past half way, and the text panel is
	# nearly HALF the card. That allocation is why their rules text can be big
	# and centred with air around it, and moving our seam down to give the art
	# more room was exactly backwards - the art already reads at half size, the
	# text did not.
	var scrim := ColorRect.new()
	_panel = scrim
	scrim.color = Color(0.152, 0.163, 0.134, 1.0)
	_layer(scrim, 0.055, 0.56, 0.945, 0.95)

	# 3 - the moulding. A Button draws its StyleBox BEHIND every child, so the
	# frame cannot be a stylebox any more or the art would cover it.
	var fr := ColorRect.new()
	var mat := ShaderMaterial.new()
	mat.shader = BORDER_SHADER
	var hues := border_hues(String(_data.get("character", "")))
	mat.set_shader_parameter("hue", hues[0])
	mat.set_shader_parameter("hue_lit", hues[1])
	mat.set_shader_parameter("band", BORDER_BAND)
	mat.set_shader_parameter("radius", BORDER_RADIUS)
	fr.material = mat
	fr.resized.connect(func() -> void:
		mat.set_shader_parameter("rect_size", fr.size))
	_frame_rect = fr
	_layer(fr, 0, 0, 1, 1)
	mat.set_shader_parameter("rect_size", custom_minimum_size)

	# 4 - the type, straddling the scrim's top edge as a caption on the art.
	var kind := String(_data.get("type", ""))
	if kind != "":
		_pill = _plate(PILL, PILL_SLICE, kind.capitalize(), 9, 15)
		_layer(_pill, 0.30, 0.56, 0.70, 0.56, 0.0, -8.0, 0.0, 7.0)

	# 5 - the rules, on the scrim.
	# Bigger and centred. Nick: "the text is much clearer" - and it is, because
	# theirs is large, white and centred on a solid panel while ours was 10px,
	# left-aligned and fighting a painting.
	_rules = _rich_body(_data, 14, 40)
	var body := _rules
	# [center], not horizontal_alignment - a RichTextLabel has no such property
	# and it would have thrown the first time a card was drawn.
	body.text = "[center]" + body.text + "[/center]"
	_layer(body, 0.085, 0.615, 0.915, 0.945)
	# _layer() defaults every node it places to MOUSE_FILTER_IGNORE -- right for
	# the seven decorative layers around it, wrong for this one: _rich_body()
	# just set PASS a few lines up so the label can see the pointer and answer
	# "which keyword is this" (its own comment explains why), and _layer() was
	# stomping that back to IGNORE unconditionally, since it has no idea this
	# particular node already asked for something else. With IGNORE, the label
	# never receives a hover or a click at all, so meta_hover_started/_ended
	# never fire, _hover_meta stays "" forever, and _on_card_input's own
	# `_hover_meta.begins_with("kw:")` branch can never be true on a real full
	# card -- right-clicking (or, once it's tappable, tapping) directly on a
	# keyword word can never answer that keyword, only ever fall through to the
	# generic inspector. The compact rail form (_rail_row) never hit this: it
	# adds the label straight to its row instead of through _layer().
	body.mouse_filter = Control.MOUSE_FILTER_PASS

	# 6 - rarity pips, tucked into the panel's bottom-right corner. They used
	# to float over the art's top edge, where they read as stray debris rather
	# than information - two unexplained blue squares beside the banner.
	_layer(_rarity_pips(_data), 0.60, 0.955, 0.92, 0.955, 0.0, -12.0, 0.0, -2.0)

	# 7 - the name, straddling the top edge and clear of the orb.
	# Taller ribbon, bigger name. The name is the one thing readable on every
	# card in the reference hand - it is their largest type after the cost.
	var ban := _plate(BANNER, BANNER_SLICE, String(_data.get("name", "")), 14, 26)
	# Obsidian, to match the border (Nick, 2026-09-30): the steel ribbon is
	# darkened with self_modulate, which leaves the name label alone, and the
	# name turns cream on it.
	ban.self_modulate = BANNER_TINT
	var ban_lbl: Label = ban.get_child(0)
	ban_lbl.add_theme_color_override("font_color", Color(1.0, 0.93, 0.78))
	ban_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_layer(ban, 0.0, 0.0, 1.0, 0.0, 28.0, 2.0, -3.0, 30.0)

	# 8 - the cost, over the ribbon's left end, as in the reference.
	if shows_cost(_data):
		add_child(_cost_orb(int(_data.get("cost", 0)),
			String(_data.get("character", ""))))



# --- The A1 frame, tinted per seat (Nick, 2026-10-05) -----------------------
#
# "A1, but i need the orange color to be editable to match the color of
# different characters. also make sure that things match up within the card."
#
# tools/cardframe_a1.py split the generation into two files: neutral stone and
# a white glow. They are stacked here and ONLY the glow is coloured, by the
# seat's tint, so a blue hand has no warm cast left anywhere on it.

## The switch, like SHOW_COST: false draws the carved-obsidian border again.
const SHIP_A1 := true
# TARGET's own card (tools/cardframe_target.py, builder 2026-10-09): a thin
# cream line and green chain band, a dark name band, the art edge to edge
# under it, olive rules box. The carved A1 stone is card_frame_a1_*.png.
const A1_BASE := preload("res://assets/ui/card_frame_t_base.png")
## The same frame with a solid gold inner rule on the left: TARGET's upright
## middle card shows no beads on that rail, its tilted cards do (run 9).
const A1_BASE_FLAT := preload("res://assets/ui/card_frame_t_flat.png")
const A1_GLOW := preload("res://assets/ui/card_frame_t_glow.png")
## The source pair's size, px. The nine-patch is drawn at this size and scaled
## down to the card, so the corners (and the socket in the top-left one) keep
## their shape and only the straight runs between them stretch.
const A1_SRC := Vector2(690, 984)
## Nine-patch margins in source px: left/top hold the socket, the others the
## carved corner.
const A1_PATCH := [130, 130, 80, 80]   # left, top, right, bottom
## The clear margin cardframe_target.py's PAD puts round the frame texture,
## source px: the Compatibility renderer has no 2D MSAA, so the frame's
## filtered alpha is what smooths a fanned card's edge (Matched check
## 2026-10-10 run 4). A1_SRC and A1_PATCH are the frame inside it.
const A1_PAD := 10.0
## Boxes measured off the generation by tools/cardframe_a1.py, normalised
## against the card. The socket is centre + radius (radius as a fraction of
## the WIDTH), because the cost is centred in it, not boxed.
const A1_SOCKET := Vector3(0.126, 0.0874, 0.0478)
const A1_TITLE := Rect2(0.205, 0.045, 0.94 - 0.205, 0.130 - 0.045)
const A1_TITLE_LIFT := 0.007   # 0.0045 and 0.0055 snap to the same frame: summed name error 155 -> 129; 0.007 -> 124
const A1_ART := Rect2(0.039, 0.132, 0.928 - 0.039, 0.588 - 0.132)   # TARGET's art starts inside the gold line, past the dark band (2026-10-09 run 14)
const A1_TYPE := Rect2(0.090, 0.558, 0.878 - 0.090, 0.618 - 0.558)   # TARGET's pill sits ~5 px higher at hand size (run 14); ~3 px left of ours (run 16)
const A1_TEXT := Rect2(0.047, 0.623, 0.92 - 0.047, 0.95 - 0.623)   # run 16: runs left with the frame (A1_LEFT_OUT); TARGET centres the rules ~2 px left of ours

## TARGET's card edge: a thin dull-gold line, the same on every seat.
const A1_RIM := Color(0.62, 0.50, 0.26, 0.6)
## How dark the A1 stone is drawn: TARGET's card frame is near-black.
const A1_STONE_SHADE := Color(1, 1, 1)
## TARGET's cost disc: green, a darker rim, a lighter cap.
const COST_DISC_FILL := Color(0.19, 0.65, 0.34)   # TARGET's gem face, sampled (48,165,86)
const COST_DISC_EDGE := Color(0.15, 0.30, 0.18)   # its darker lip at the edge (38,69,43)
const COST_DISC_CAP := Color(0.17, 0.57, 0.29)   # the lower half a shade darker (45,148,75)
const COST_DISC_RIM := Color(0.46, 0.94, 0.62)  # the lit rim round the upper half (92,215,136)
## The disc's diameter as a fraction of the card's width, and its centre as
## fractions of the card: TARGET's disc is about a third of the card across
## and its centre sits on the frame's top-left corner.
const COST_DISC_D := 0.31   # TARGET's disc, registered by area on all five cards in the 720 square (run 14)
const COST_DISC_C := Vector2(0.08, 0.077)   # TARGET's gem centre ~12 px under the card top in the 720 square (2026-10-09; 1 px higher, Matched check 2026-10-10 run 4)


## TARGET's art window behind an icon: near-black (cardframe_target.py ART_BG).
const A1_WINDOW := Color(10.0 / 255.0, 11.0 / 255.0, 9.0 / 255.0)
## TARGET's rules box: dark olive (cardframe_target.py BODY).
const A1_BODY := Color(36.0 / 255.0, 39.0 / 255.0, 31.0 / 255.0)
## How far the art runs past the window under the frame, px of the card.
const A1_ART_BLEED := 2.0
const AA_RECT := preload("res://ui/aa_rect.gdshader")


## TARGET's type pill: pale grey, a darker edge.
const TYPE_PILL_FILL := Color(0.64, 0.65, 0.71)   # TARGET's pill averages (150,152,166), a cool steel grey (run 16)
const TYPE_PILL_EDGE := Color(0.43, 0.44, 0.49)
const TYPE_PILL_TEX := preload("res://assets/ui/type_pill_t.png")
## TARGET's pill ink, ~(41,42,51), for the words cut off its pills.
const A1_PILL_WORD_INK := Color(0.16, 0.165, 0.2)


## The type pill's rect inside the type bar `ty`: centred, 44% of its width.
## The theme's face is a semibold; TARGET's rules are a regular weight.
const A1_RULES_EMBOLDEN := -0.3
const A1_PILL_EMBOLDEN := 0.05
const A1_PILL_SHADE := 0.95
## TARGET's rules ink: glyph cores ~(232,231,209). The hand draws ~0.9 of
## the ink it is given, so this is that over 0.9.
const A1_RULES_INK := Color(1.0, 1.0, 0.91)


## The theme face unhinted: hinting snaps stems to whole pixels, which is
## what makes small card lettering read typeset next to TARGET's painted
## letters (run 5, 2026-10-10). Built once.
static var _painted_base: Font = null


static func a1_painted_base(base: Font) -> Font:
	if _painted_base != null:
		return _painted_base
	_painted_base = base
	if base is FontFile:
		var f := (base as FontFile).duplicate() as FontFile
		f.hinting = TextServer.HINTING_NONE
		f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_ONE_QUARTER
		_painted_base = f
	return _painted_base


static func a1_type_pill(ty: Rect2) -> Rect2:
	# TARGET's pill: ~46x11 px on a 92 px card in the 720 square (builder
	# 2026-10-09), half the card's width and a fat bevelled lozenge.
	# Run 16, registered on the --hand pair: TARGET's is ~4% narrower, ~13%
	# taller and ~1 px lower than the run-14 pill.
	# Run 5 (2026-10-10), with the glossy capsule: TARGET's is 63x12 px at
	# 1024 against the run-16 rect's 65x15, so ~3% narrower and ~20% thinner.
	var pw := ty.size.x * 0.525
	var ph := maxf(ty.size.y * 1.05, 8.0)
	var cy := ty.get_center().y + ty.size.y * 0.20
	return Rect2(ty.get_center().x - pw * 0.5, cy - ph * 0.5, pw, ph)


## TARGET's cost gem, painted once: a green face, the lower half a shade
## darker, a lit rim round the upper half at 0.8-0.9 of the radius, a dark lip
## and a soft shadow at the edge (sampled radially off TARGET's Leap disc,
## run 14). Flat panels drew a dashed ring at hand size.
static var _disc_tex: Texture2D = null


## TARGET's own gem, cut digit-free from its five hand gems by
## tools/costdisc_target.py (Matched check 2026-10-10 run 4: the painted gem
## below lacked TARGET's raised rim and lit lower-right crescent).
const COST_DISC_T := preload("res://assets/ui/cost_disc_t.png")


static func a1_disc_texture() -> Texture2D:
	if _disc_tex != null:
		return _disc_tex
	var cut: Image = COST_DISC_T.get_image() if COST_DISC_T != null else null
	if cut != null:
		cut = cut.duplicate()
		if cut.is_compressed():
			cut.decompress()
		cut.convert(Image.FORMAT_RGBA8)
		cut.generate_mipmaps()
		_disc_tex = ImageTexture.create_from_image(cut)
		return _disc_tex
	var n := 128
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c := (n - 1) * 0.5
	var r := n * 0.45
	for y in range(n):
		for x in range(n):
			var dx := (x - c) / r
			var dy := (y - c) / r
			var d := sqrt(dx * dx + dy * dy)
			var up := clampf(-dy / maxf(d, 0.001), -1.0, 1.0)   # 1 at the top
			var col := COST_DISC_FILL
			# lower half a shade darker
			col = col.lerp(COST_DISC_CAP, clampf(-up, 0.0, 1.0) * 0.55)
			# the lit rim, upper side
			var ring := clampf(1.0 - absf(d - 0.85) / 0.09, 0.0, 1.0)
			col = col.lerp(COST_DISC_RIM, ring * clampf(up * 0.6 + 0.45, 0.0, 1.0))
			# dark lip at the very edge
			col = col.lerp(COST_DISC_EDGE, clampf((d - 0.93) / 0.07, 0.0, 1.0))
			var a := clampf((1.0 - d) * r * 0.5 + 0.5, 0.0, 1.0)
			# soft shadow just outside
			if d > 1.0:
				var sh := clampf(1.0 - (d - 1.0) / 0.10, 0.0, 1.0) * 0.45
				col = Color(0.02, 0.06, 0.03)
				a = maxf(a, sh)
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	img.generate_mipmaps()
	_disc_tex = ImageTexture.create_from_image(img)
	return _disc_tex


## The cost disc's rect in px of a card w x h. Static so a test can pin it.
static func a1_cost_disc(w: float, h: float) -> Rect2:
	var d := COST_DISC_D * w
	h = a1_h(w, h)
	return Rect2(COST_DISC_C.x * w - d * 0.5, COST_DISC_C.y * h - d * 0.5, d, d)


## One colour per character: the glow on their cards and the halo round a
## playable one. The Frog and the Climbers are combat_3d.gd's SLOT_TINT, which
## now reads from here, so the cards match the markers on the floor.
const SEAT_TINT := {
	"frog": Color(0.45, 0.95, 0.5),
	"mountain_climbers": Color(0.55, 0.82, 1.0),
	"vine_weaver": Color(0.73, 0.49, 0.93),
	"lightbearer": Color(0.97, 0.84, 0.47),
	"goblin_mech": Color(0.93, 0.47, 0.16),
	"common": Color(0.93, 0.47, 0.16),
}


## The seat colour a character's cards wear. Static so a test can pin it.
static func seat_tint(character: String) -> Color:
	return SEAT_TINT.get(character, SEAT_TINT["common"])


## The halo a card wears on the A1 frame: its seat colour when it can be
## played, none when it cannot.
static func seat_glow(playable: bool, character: String) -> Color:
	if not playable:
		return Color(0, 0, 0, 0)
	var c := seat_tint(character)
	c.a = PLAYABLE_GLOW.a
	return c


## A normalised box in px of a card w x h.
## The A1 face's own height for its width: every piece is laid out on this,
## so a taller card only grows its body at the bottom.
const A1_ASPECT := 228.0 / 162.0


static func a1_h(w: float, h: float) -> float:
	return minf(h, w * A1_ASPECT)


static func a1_box(r: Rect2, w: float, h: float) -> Rect2:
	h = a1_h(w, h)
	return Rect2(r.position.x * w, r.position.y * h, r.size.x * w, r.size.y * h)


## The socket's centre and radius in px of a card w x h.
static func a1_socket(w: float, h: float) -> Vector3:
	return Vector3(A1_SOCKET.x * w, A1_SOCKET.y * a1_h(w, h), A1_SOCKET.z * w)


## The cost's font size: the number shrinks to the disc, never the disc to the
## number. A digit is about 0.6 em wide and 0.75 em tall, so 1.5 x the radius
## keeps a two-digit cost inside the circle too.
static func a1_cost_font_size(radius: float) -> int:
	return maxi(6, int(floor(radius * 1.5)))


## The stone or glow layer, as a nine-patch drawn at source size and scaled.
## The frame patches with mipmaps, built once: drawn at ~0.15 of their source
## size, the thin edge lines skipped texels and read as dashes (grader,
## 2026-10-09). *.import is not in git, so this is built here.
static var _a1_mipped := {}


static func _a1_mip(tex: Texture2D) -> Texture2D:
	if tex == null or tex.has_mipmaps():
		return tex
	if _a1_mipped.has(tex):
		return _a1_mipped[tex]
	var img := tex.get_image()
	if img == null:
		return tex
	if img.is_compressed():
		img.decompress()
	img.generate_mipmaps()
	var out := ImageTexture.create_from_image(img)
	_a1_mipped[tex] = out
	return out


## A painting's mip chain built with Lanczos, not the default box filter: the
## hand draws the art at about its mip 1, and the box-filtered level read as
## a soft haze beside TARGET's crisp window - a grader called TARGET's own
## Leap pixels "blue sky" and ours, measured the same colour, "pale haze"
## (run 16).
static var _sharp_mipped := {}


static func _sharp_mip(tex: Texture2D) -> Texture2D:
	if tex == null:
		return tex
	if _sharp_mipped.has(tex):
		return _sharp_mipped[tex]
	var src := tex.get_image()
	if src == null:
		return tex
	src = src.duplicate()
	if src.is_compressed():
		src.decompress()
	if src.has_mipmaps():
		src.clear_mipmaps()
	src.convert(Image.FORMAT_RGBA8)
	var w := src.get_width()
	var h := src.get_height()
	var data := PackedByteArray()
	var lw := w
	var lh := h
	while true:
		var lvl := src.duplicate()
		if lw != w or lh != h:
			lvl.resize(lw, lh, Image.INTERPOLATE_LANCZOS)
		data.append_array(lvl.get_data())
		if lw == 1 and lh == 1:
			break
		lw = maxi(1, lw >> 1)
		lh = maxi(1, lh >> 1)
	var img := Image.create_from_data(w, h, true, Image.FORMAT_RGBA8, data)
	var out: Texture2D = ImageTexture.create_from_image(img)
	_sharp_mipped[tex] = out
	return out


## Swap the frame for its solid-rail variant (the hand's upright middle card).
func set_frame_flat(on: bool) -> void:
	var np := _frame_rect as NinePatchRect
	if np == null or not np.has_meta("a1_src"):
		return
	var src: Texture2D = np.get_meta("a1_src")
	if src != A1_BASE and src != A1_BASE_FLAT:
		return
	var want: Texture2D = A1_BASE_FLAT if on else A1_BASE
	if src == want:
		return
	np.texture = _a1_mip(want)
	np.set_meta("a1_src", want)


func _a1_patch(tex: Texture2D) -> NinePatchRect:
	var np := NinePatchRect.new()
	np.texture = _a1_mip(tex)
	np.set_meta("a1_src", tex)   # which patch this is, under its mipmapped copy
	np.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	np.patch_margin_left = A1_PATCH[0] + int(A1_PAD)
	np.patch_margin_top = A1_PATCH[1] + int(A1_PAD)
	np.patch_margin_right = A1_PATCH[2] + int(A1_PAD)
	np.patch_margin_bottom = A1_PATCH[3] + int(A1_PAD)
	np.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(np)
	return np


## Fit a source-size nine-patch over a card of this size.
static func a1_patch_fit(card: Vector2) -> Array:
	var k := card.x / A1_SRC.x
	return [Vector2(k, k), card / k]


func _a1_fit(np: NinePatchRect) -> void:
	var card := size if size.x > 0.0 else custom_minimum_size
	var fit := a1_patch_fit(card)
	np.position = Vector2(-(A1_SIDE_OUT + A1_LEFT_OUT + A1_PAD) * fit[0].x, -A1_PAD * fit[0].y)
	np.scale = fit[0]
	np.size = fit[1] + Vector2(2.0 * A1_SIDE_OUT + A1_LEFT_OUT, 0.0) + Vector2.ONE * 2.0 * A1_PAD


## Source px the frame runs out past the card's sides. TARGET's cards are wider
## than their art and rules by a wider dark band: on the --hand pair its cream
## and gold side lines sit 28 px apart against our 20, the gold lines in the
## same place (builder 2026-10-09 run 16). The frame's band is drawn that much
## wider (cardframe_target.py) and the patch runs out by it, so everything
## inside the gold line keeps its place.
const A1_SIDE_OUT := 12.0
## And the left side runs out further still, the art window with it: TARGET's
## left-hand lines sit ~15 px left of ours on every card of the --hand pair
## while the discs and the right edge match (run 16).
const A1_LEFT_OUT := 23.0


## TARGET's gold line sits a few px INSIDE a dark border, not on the card's
## outer edge (builder 2026-10-09): pull the rim patch in by A1_RIM_INSET.
const A1_RIM_INSET := 4.0


func _a1_inset(np: Control) -> void:
	var k := np.scale.x if np.scale.x > 0.0 else 1.0
	np.position = Vector2(A1_RIM_INSET, A1_RIM_INSET)
	np.size = np.size - Vector2(A1_RIM_INSET, A1_RIM_INSET) * 2.0 / k


func _build_a1() -> void:
	var w := custom_minimum_size.x
	var h := custom_minimum_size.y
	var who := String(_data.get("character", ""))
	var tint := seat_tint(who)

	# 1 - the stone, UNDER the art: the base is opaque, the art sits in its
	# window. Straight after the ground.
	var base := _a1_patch(A1_BASE)
	# TARGET's frame is near-black, not grey stone.
	base.self_modulate = A1_STONE_SHADE
	_a1_fit(base)
	_frame_rect = base
	_panel = null
	_pill = null

	# 2 - the art window. The frame's window is see-through and the art is
	# drawn UNDER the frame, a little larger than the window, so the frame's
	# filtered edge trims it: on a tilted card the window edge is smooth, as
	# in TARGET, not the art rect's aliased staircase (run 14). An icon's
	# clear ground shows TARGET's near-black window.
	var ar := a1_box(A1_ART, w, h)
	# The card's body under the see-through window: on the taller hand card
	# the nine-patch stretches the frame's window below the art box, and the
	# scene showed through that strip as a near-black band over the rules
	# (TARGET: olive straight under the art; run 16).
	var body := ColorRect.new()
	body.color = A1_BODY
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	move_child(body, 1)
	_place(body, Rect2(ar.position.x, ar.end.y - 1.0, ar.size.x, h * 0.5))
	var win := ColorRect.new()
	win.color = A1_WINDOW
	win.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(win)
	move_child(win, 1)
	_place(win, ar.grow(1.0))
	if _art_full != null:
		var g := A1_ART_BLEED
		_art_full.offset_left = ar.position.x - g
		_art_full.offset_top = ar.position.y - g
		_art_full.offset_right = ar.end.x + g - w
		_art_full.offset_bottom = ar.end.y + g - h
		# On a tilted hand card the art's bottom edge, where it meets the
		# olive body, drew as a hard staircase; TARGET's is a clean line
		# (run 6, 2026-10-10).
		var aa := ShaderMaterial.new()
		aa.shader = AA_RECT
		_art_full.material = aa
		_art_full.clip_contents = false
		var art_ref := _art_full
		var sync := func() -> void:
			aa.set_shader_parameter("rect_size", art_ref.size)
		sync.call()
		_art_full.resized.connect(sync)
		move_child(base, _art_full.get_index() + 1)
	else:
		move_child(base, 2)

	# 3 - the glow, the ONLY coloured thing on the frame.
	var glow := _a1_patch(A1_GLOW)
	_a1_fit(glow)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	# TARGET's frame edge is a thin dull-gold line, not a seat-coloured glow.
	glow.self_modulate = A1_RIM
	_a1_inset(glow)
	resized.connect(func() -> void:
		_a1_fit(base)
		_a1_fit(glow)
		_a1_inset(glow))

	# 4 - the name, starting clear of the socket.
	var tr := a1_box(A1_TITLE, w, h)
	# TARGET's names sit ~0.9 px higher in their band at hand size (0.5-1.25
	# px on all five cards, coins unmoved; builder 2026-10-10 run 12).
	tr.position.y -= h * A1_TITLE_LIFT
	var nm := _label(String(_data.get("name", "")), 15 if w < 170 else 17)
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# TARGET centres the name in its band.
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.clip_text = true
	# TARGET's name ink: glyph cores ~(237,230,210), over the hand's ~0.9
	# (run 5, 2026-10-10; warm cream since run 14).
	nm.add_theme_color_override("font_color", Color(1.0, 0.98, 0.90))
	nm.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	# TARGET's name has no hard dark ring and a lighter stroke than the
	# theme's semibold (run 5).
	nm.add_theme_constant_override("outline_size", 1)
	var nf := FontVariation.new()
	nf.base_font = a1_painted_base(nm.get_theme_font("font"))
	nf.variation_embolden = -0.15
	nm.add_theme_font_override("font", nf)
	# ...and a faint cream bloom round it, as TARGET's painted names carry.
	nm.add_theme_color_override("font_shadow_color", Color(1.0, 0.9, 0.7, 0.18))
	nm.add_theme_constant_override("shadow_offset_x", 0)
	nm.add_theme_constant_override("shadow_offset_y", 0)
	nm.add_theme_constant_override("shadow_outline_size", 3)
	# TARGET's name sits ~3 px higher in its band at hand size (run 14).
	_place(nm, tr.grow_individual(-2.0, 0.0, -3.0, 0.0).grow_individual(0.0, 4.0, 0.0, -4.0))

	# 5 - the type bar, with rarity at its right end.
	var ty := a1_box(A1_TYPE, w, h)
	var kind := String(_data.get("type", ""))
	if kind != "":
		# TARGET's type: a small centred grey pill, title case, dark ink.
		var pr := a1_type_pill(ty)
		# TARGET's lozenge is a glossy steel capsule lit from the top left,
		# painted once off its own pixels (tools/builder/type_pill.py).
		var pill := TextureRect.new()
		pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pill.texture = TYPE_PILL_TEX
		pill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pill.stretch_mode = TextureRect.STRETCH_SCALE
		pill.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		# The capsule drew 6-9 levels brighter than TARGET's face at its ends
		# and top band (middle card at 1024, run 6 2026-10-10).
		pill.self_modulate = Color(A1_PILL_SHADE, A1_PILL_SHADE, A1_PILL_SHADE)
		_place(pill, pr)
		# TARGET's own painted word for this card, cut off its pill
		# (tools/pill_word_cut.py): soft and card by card, as TARGET draws it
		# (Matched check 2026-10-10 run 9). Other cards print the word.
		var word_path := "res://assets/ui/pill_word_%s.png" % String(_data.get("id", ""))
		if ResourceLoader.exists(word_path):
			var word := TextureRect.new()
			word.mouse_filter = Control.MOUSE_FILTER_IGNORE
			word.texture = _a1_mip(load(word_path))
			word.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			word.stretch_mode = TextureRect.STRETCH_SCALE
			word.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			word.self_modulate = A1_PILL_WORD_INK
			_place(word, pr)
		else:
			var tl := _label(kind.capitalize(), 10)
			tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			# TARGET's pill ink: a dark blue-grey (~41,42,51), a regular weight.
			tl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.19))
			var pf := FontVariation.new()
			pf.base_font = a1_painted_base(tl.get_theme_font("font"))
			# Run 6: TARGET's word carries twice the dark ink of run 5's light,
			# 0.9-alpha word (50 vs 24 px under 100 on the middle pill at 1024).
			pf.variation_embolden = A1_PILL_EMBOLDEN
			tl.add_theme_font_override("font", pf)
			tl.add_theme_constant_override("outline_size", 0)
			_place(tl, pr)
	# No rarity pips: TARGET's cards carry none (builder 2026-10-09).

	# 6 - the rules, wrapped inside the text box.
	var xr := a1_box(A1_TEXT, w, h)
	# 15, not 14: TARGET's rules run ~6% wider (2026-10-09).
	# 15, stretched 1.08 tall: TARGET's rules are ~8% taller at the same line
	# width, and a touch heavier (builder 2026-10-10 run 3).
	_rules = _rich_body(_data, 15, int(xr.size.y) - 6)
	_rules.text = "[center]" + _rules.text + "[/center]"
	var tall := FontVariation.new()
	# unhinted: hinting snapped each glyph to the pixel grid, and on a tilted
	# card "Climb" stepped up letter by letter (run 6, 2026-10-10)
	tall.base_font = a1_painted_base(_rules.get_theme_font("normal_font"))
	tall.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(0.0, 1.08), Vector2.ZERO)
	# A regular weight, not heavier: TARGET's rules carry ~15% less ink than
	# the semibold face at +0.15 drew (Matched check 2026-10-10 run 5).
	tall.variation_embolden = A1_RULES_EMBOLDEN
	_rules.add_theme_font_override("normal_font", tall)
	var kw_bold := FontVariation.new()
	kw_bold.base_font = tall.base_font
	kw_bold.variation_transform = tall.variation_transform
	kw_bold.variation_embolden = A1_RULES_EMBOLDEN + A1_KEYWORD_EMBOLDEN
	_rules.add_theme_font_override("bold_font", kw_bold)
	_rules.add_theme_font_size_override("bold_font_size", _rules.get_theme_font_size("normal_font_size"))
	# TARGET's rules ink is a brighter cream than the shared body colour.
	_rules.add_theme_color_override("default_color", A1_RULES_INK)
	_place(_rules, xr.grow_individual(-4.0, -7.0, -4.0, 0.0))   # TARGET's lines sit ~2 px lower (run 3)
	_rules.mouse_filter = Control.MOUSE_FILTER_PASS

	# 7 - the cost: TARGET's big green disc, hung over the top-left corner.
	if shows_cost(_data):
		var dr := a1_cost_disc(w, h)
		var so := Vector3(dr.get_center().x, dr.get_center().y, dr.size.x * 0.5)
		var d := so.z * 2.0
		var disc := TextureRect.new()
		disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		disc.texture = a1_disc_texture()
		disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		disc.stretch_mode = TextureRect.STRETCH_SCALE
		disc.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		# the painted face is 0.9 of the texture; the rest is its shadow
		_place(disc, dr.grow(dr.size.x / 0.9 * 0.05))
		# TARGET's digit is about a third of the disc tall, white, a thin
		# dark-green outline (run 14).
		# TARGET's digit is ~0.4 of the gem tall, a touch taller than run 14's
		# (Matched check 2026-10-10 run 4, measured on its five hand gems).
		var cl := _label(str(int(_data.get("cost", 0))), a1_cost_font_size(so.z * 0.54))
		cl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cl.add_theme_color_override("font_color", Color(0.89, 0.93, 0.89))   # TARGET: a greyed white, pressed in
		cl.add_theme_color_override("font_outline_color", Color(0.02, 0.13, 0.06, 1.0))
		cl.add_theme_constant_override("outline_size", 3)
		# Heavy, so a 10px digit still reads at hand size (the grader, on the
		# first pass: "barely readable").
		var heavy := FontVariation.new()
		heavy.base_font = cl.get_theme_font("font")
		heavy.variation_embolden = 0.12   # TARGET's stroke is thin; the outline carries it
		cl.add_theme_font_override("font", heavy)
		_place(cl, Rect2(so.x - so.z, so.y - so.z + 0.5, d, d))


# --- Card-frame mocks (Nick, 2026-10-05) ------------------------------------
#
# "the card template for the outer layer of the cards looks low quality.
# reference real tcgs like pokemon and mtg and prepare a redesign."
# design/art/card-frame-research.md takes our frame apart and specs three
# directions; these are those three, on the real card, so Nick picks at the
# size he plays at. Off unless asked for: the harness's `cardframe=A|B|C`.
#
# All three fix the same five things the research found, whichever wins:
# the cost is inside the card, the art has a keyline and a window, the name
# plate stays inside the edge, the edge is anti-aliased in the shader, and
# rarity sits in one fixed place.
#
#   A  carved obsidian  the fight's own stone, an ember keyline (Hearthstone's
#                       socketed cost, Runeterra's restraint)
#   B  printed card     Magic's M15 logic: hard black border, frame tinted by
#                       type, cost right-aligned in the title, parchment rules
#   C  sculpted relic   Hearthstone's: a thick gold frame with bosses, an
#                       arched art window, the cost as a gem, a type ribbon

## "" = the shipping frame. Set by tools/screenshot.gd's `cardframe=`.
static var frame_mock := ""

const FRAME_MOCK_SHADER := preload("res://ui/card_frame_mock.gdshader")
const PLATE_SHADER := preload("res://ui/card_plate.gdshader")

## Each direction's numbers. Pixels are of the card's own rect, so 135, 162
## and 191 wide all get the same strokes; the art/text split is a fraction.
const FRAME_MOCKS := {
	"A": {
		"name": "Carved obsidian", "radius": 10.0, "band": 7.0, "outer_w": 1.5,
		"title_h": 24.0, "type_h": 14.0, "footer_h": 11.0, "art_split": 0.55,
		"art_arch": 0.0, "ornament": 0.0, "grain": 0.35,
		"plate_top": Color("2a2629"), "plate_bottom": Color("141215"),
		"lit": Color("6a6268"), "outer": Color("050405"),
		"title_top": Color("332e31"), "title_bottom": Color("1e1b1d"),
		"text_top": Color("0d0c0e"), "text_bottom": Color("151316"),
		"ink": Color(1.0, 0.93, 0.80), "name_align": "center",
		"cost": "socket", "cost_d": 30.0, "type": "bar",
		# Rarity is the keyline (research, direction A).
		"keylines": {"common": Color("e8752a"), "uncommon": Color("7cc4ff"), "rare": Color("ffd25e")},
	},
	"B": {
		"name": "Printed card", "radius": 8.0, "band": 9.0, "outer_w": 4.5,
		"title_h": 21.0, "type_h": 14.0, "footer_h": 0.0, "art_split": 0.53,
		"art_arch": 0.0, "ornament": 0.0, "grain": 0.0,
		"outer": Color("060606"), "lit": Color(1, 1, 1, 0.55),
		# The frame is tinted by what the card IS, Magic's colour identity.
		"tints": {
			"attack": [Color("b0563a"), Color("6e2c1c")],
			"skill": [Color("4f7fae"), Color("274563")],
			"power": [Color("5c9a5a"), Color("2c5a2c")],
		},
		"title_top": Color("f3ead6"), "title_bottom": Color("ddd0b2"),
		"text_top": Color("f2ead8"), "text_bottom": Color("e3d7bb"),
		"ink": Color(0.10, 0.08, 0.06), "name_align": "left",
		"cost": "in_title", "cost_d": 19.0, "type": "line",
		"keylines": {"common": Color("060606"), "uncommon": Color("060606"), "rare": Color("060606")},
	},
	"C": {
		"name": "Sculpted relic", "radius": 12.0, "band": 11.0, "outer_w": 1.5,
		"title_h": 21.0, "type_h": 0.0, "footer_h": 10.0, "art_split": 0.57,
		"art_arch": 20.0, "ornament": 1.0, "grain": 0.0,
		"plate_top": Color("e2ad55"), "plate_bottom": Color("8a5a22"),
		"lit": Color("fff0c0"), "outer": Color("1c1206"),
		"title_top": Color("4a3020"), "title_bottom": Color("2a1a10"),
		"text_top": Color("2a1c12"), "text_bottom": Color("1a110a"),
		"ink": Color(1.0, 0.93, 0.78), "name_align": "center",
		"cost": "gem", "cost_d": 32.0, "type": "ribbon",
		"keylines": {"common": Color("1c1206"), "uncommon": Color("1c1206"), "rare": Color("1c1206")},
	},
}


## One direction's spec, with this card's own colours resolved in: the
## keyline by rarity, B's plate by type. Static so a test can pin it.
static func frame_mock_spec(style: String, data: Dictionary) -> Dictionary:
	var spec: Dictionary = FRAME_MOCKS.get(style, {}).duplicate()
	if spec.is_empty():
		return spec
	var rarity := String(data.get("rarity", "common"))
	if not RARITY.has(rarity):
		rarity = "common"
	spec["rarity"] = rarity
	spec["keyline"] = spec["keylines"][rarity]
	if spec.has("tints"):
		var t: Array = spec["tints"].get(String(data.get("type", "")), spec["tints"]["skill"])
		spec["plate_top"] = t[0]
		spec["plate_bottom"] = t[1]
	return spec


## Where each piece of a mock frame goes, in px of a card w x h. Static so a
## test can hold the five fixes: everything inside the card, the art in a
## window, nothing overlapping the next piece down.
static func frame_mock_layout(spec: Dictionary, w: float, h: float) -> Dictionary:
	var b: float = spec["band"]
	var title := Rect2(b, b, w - 2.0 * b, spec["title_h"])
	var art_top := title.end.y + 2.0
	var art_bot := roundf(h * float(spec["art_split"]))
	var art := Rect2(b + 1.0, art_top, w - 2.0 * b - 2.0, art_bot - art_top)
	var type_rect := Rect2()
	var text_top := art_bot + 3.0
	match String(spec["type"]):
		"bar", "line":
			type_rect = Rect2(b, art_bot + 2.0, w - 2.0 * b, spec["type_h"])
			text_top = type_rect.end.y + 2.0
		"ribbon":
			type_rect = Rect2(w * 0.27, art_bot - 8.0, w * 0.46, 15.0)
			text_top = art_bot + 8.0
	var foot: float = spec["footer_h"]
	var text := Rect2(b + 1.0, text_top, w - 2.0 * b - 2.0, h - b - foot - text_top)
	var d: float = spec["cost_d"]
	var cost := Rect2()
	match String(spec["cost"]):
		"socket":
			cost = Rect2(title.position.x + 1.0, title.position.y + (title.size.y - d) * 0.5, d, d)
		"in_title":
			cost = Rect2(title.end.x - d - 3.0, title.position.y + (title.size.y - d) * 0.5, d, d)
		"gem":
			cost = Rect2(3.0, 3.0, d, d)
	var rarity_at := Vector2(w * 0.5, h - b - foot * 0.5) if foot > 0.0 \
		else Vector2(type_rect.end.x - 9.0, type_rect.get_center().y)
	return {"title": title, "art": art, "type": type_rect, "text": text,
		"cost": cost, "rarity": rarity_at}


func _place(node: Control, r: Rect2) -> Control:
	return _layer(node, 0, 0, 0, 0, r.position.x, r.position.y, r.end.x, r.end.y)


func _mock_plate(r: Rect2, top: Color, bottom: Color, lit: Color, outline: Color,
		inset: bool, radius: float = 3.0, rule: Color = Color(0, 0, 0, 0)) -> ColorRect:
	var cr := ColorRect.new()
	var m := ShaderMaterial.new()
	m.shader = PLATE_SHADER
	m.set_shader_parameter("rect_size", r.size)
	m.set_shader_parameter("radius", radius)
	m.set_shader_parameter("fill_top", top)
	m.set_shader_parameter("fill_bottom", bottom)
	m.set_shader_parameter("lit", lit)
	m.set_shader_parameter("dark", Color(0, 0, 0, 1))
	m.set_shader_parameter("outline", outline)
	m.set_shader_parameter("inset", 1.0 if inset else 0.0)
	if rule.a > 0.0:
		m.set_shader_parameter("rule_y", 3.0)
		m.set_shader_parameter("rule_col", rule)
	cr.material = m
	_place(cr, r)
	return cr


func _build_mock_frame(spec: Dictionary) -> void:
	var w := custom_minimum_size.x
	var h := custom_minimum_size.y
	var at := frame_mock_layout(spec, w, h)
	var ink: Color = spec["ink"]
	var key: Color = spec["keyline"]
	var who := String(_data.get("character", ""))
	var hues := border_hues(who)

	# The painting, re-cut to the window so it is centred in it.
	if _art_full != null:
		var ar: Rect2 = at["art"]
		_art_full.offset_left = ar.position.x
		_art_full.offset_top = ar.position.y
		_art_full.offset_right = ar.end.x - w
		_art_full.offset_bottom = ar.end.y - h

	# The text box goes UNDER the plate's hole edge but is its own panel.
	var tr: Rect2 = at["text"]
	var rule := key if String(spec["type"]) == "bar" else Color(0, 0, 0, 0)
	if rule.a > 0.0:
		rule.a = 0.7
	var box := _mock_plate(tr, spec["text_top"], spec["text_bottom"],
		Color(1, 1, 1, 1).lerp(spec["text_top"], 0.6), Color(0, 0, 0, 0.9), true, 3.0, rule)
	_panel = null

	# The plate itself, art window cut out of it.
	var fr := ColorRect.new()
	var mat := ShaderMaterial.new()
	mat.shader = FRAME_MOCK_SHADER
	var art_r: Rect2 = at["art"]
	mat.set_shader_parameter("rect_size", Vector2(w, h))
	mat.set_shader_parameter("radius", spec["radius"])
	mat.set_shader_parameter("art_rect", Vector4(art_r.position.x, art_r.position.y, art_r.end.x, art_r.end.y))
	mat.set_shader_parameter("art_arch", spec["art_arch"])
	mat.set_shader_parameter("outer_col", spec["outer"])
	mat.set_shader_parameter("outer_w", spec["outer_w"])
	mat.set_shader_parameter("plate_top", spec["plate_top"])
	mat.set_shader_parameter("plate_bottom", spec["plate_bottom"])
	mat.set_shader_parameter("lit", spec["lit"])
	mat.set_shader_parameter("keyline", key)
	mat.set_shader_parameter("ornament", spec["ornament"])
	mat.set_shader_parameter("grain", spec["grain"])
	fr.material = mat
	_frame_rect = fr
	_layer(fr, 0, 0, 1, 1)
	# The text box sits in front of the plate: move the plate under it.
	move_child(fr, box.get_index())

	# The title plate, inside the edge, never overhanging it.
	var ti: Rect2 = at["title"]
	_mock_plate(ti, spec["title_top"], spec["title_bottom"],
		Color(1, 1, 1).lerp(spec["title_top"], 0.45), Color(0, 0, 0, 0.9), false)
	var name_r := ti.grow_individual(-6.0, 0.0, -6.0, 0.0)
	var cr: Rect2 = at["cost"]
	if shows_cost(_data):
		match String(spec["cost"]):
			"socket", "gem":
				name_r.position.x = maxf(name_r.position.x, cr.end.x + 2.0)
				name_r.size.x = ti.end.x - 6.0 - name_r.position.x
			"in_title":
				name_r.size.x = cr.position.x - 3.0 - name_r.position.x
	var nm := _label(String(_data.get("name", "")), 13 if w < 170 else 15)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if String(spec["name_align"]) == "left" \
		else HORIZONTAL_ALIGNMENT_CENTER
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.add_theme_color_override("font_color", ink)
	if ink.get_luminance() > 0.5:
		nm.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		nm.add_theme_constant_override("outline_size", 3)
	_place(nm, name_r)

	# The type: a stone bar (A), a printed type line (B), a ribbon over the
	# foot of the art (C).
	var ty: Rect2 = at["type"]
	var kind := String(_data.get("type", "")).capitalize()
	if ty.size.x > 0.0 and kind != "":
		var ribbon := String(spec["type"]) == "ribbon"
		var tt: Color = spec["title_top"]
		var tb: Color = spec["title_bottom"]
		if ribbon:
			tt = spec["plate_top"]
			tb = spec["plate_bottom"]
		_mock_plate(ty, tt, tb, Color(1, 1, 1).lerp(tt, 0.45), Color(0, 0, 0, 0.9),
			false, 6.0 if ribbon else 2.0)
		var tl := _label(kind if String(spec["type"]) != "bar" else kind.to_upper(), 10)
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if String(spec["type"]) == "line" \
			else HORIZONTAL_ALIGNMENT_CENTER
		tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var tink := ink
		if ribbon:
			tink = Color(0.16, 0.09, 0.03)
		elif String(spec["type"]) == "bar":
			tink = ink.lerp(key, 0.2)
		tl.add_theme_color_override("font_color", tink)
		_place(tl, ty.grow_individual(-6.0, 0.0, -6.0, 0.0))
	_pill = null

	# The rules.
	_rules = _rich_body(_data, 13, 30)
	var t := "[center]" + _rules.text + "[/center]"
	if ink.get_luminance() < 0.5:
		# Printed on parchment: the live/nailed/keyword colours are tuned for a
		# dark panel and vanish on a light one.
		t = t.replace(LIVE_COLOR, "2e6f1c").replace(NAILED_COLOR, "8a5a00") \
			.replace(KEYWORD_COLOR, "8a3f0c").replace(KEYWORD_LINE, "8a3f0c")
	_rules.text = t
	_rules.add_theme_color_override("default_color", ink)
	_place(_rules, tr.grow_individual(-4.0, -5.0, -4.0, -2.0))
	_rules.mouse_filter = Control.MOUSE_FILTER_PASS

	# Rarity, one token in one place: a diamond in the footer (A, C) or at the
	# right end of the type line (B), set in the frame.
	var rc: Color = _rarity_of(_data)["pip"]
	var gem := ColorRect.new()
	gem.color = rc
	var gs := 7.0
	gem.pivot_offset = Vector2(gs, gs) * 0.5
	gem.rotation = PI * 0.25
	var gp: Vector2 = at["rarity"]
	var ring := ColorRect.new()
	ring.color = Color(0, 0, 0, 0.9)
	ring.pivot_offset = Vector2(gs + 2.0, gs + 2.0) * 0.5
	ring.rotation = PI * 0.25
	_place(ring, Rect2(gp - Vector2(gs + 2.0, gs + 2.0) * 0.5, Vector2(gs + 2.0, gs + 2.0)))
	_place(gem, Rect2(gp - Vector2(gs, gs) * 0.5, Vector2(gs, gs)))

	# The cost, inside the silhouette.
	if shows_cost(_data):
		var style := String(spec["cost"])
		var fill_t: Color = hues[1]
		var fill_b: Color = hues[0].darkened(0.35)
		var socket := _mock_plate(cr, Color("0a090a"), Color("0a090a"), Color("4a4448"),
			Color(0, 0, 0, 1), true, cr.size.x * 0.5)
		if style == "gem":
			socket.material.set_shader_parameter("fill_top", Color("fff0c0"))
			socket.material.set_shader_parameter("fill_bottom", Color("8a5a22"))
			socket.material.set_shader_parameter("inset", 0.0)
		var inner := cr.grow(-2.5 if style != "in_title" else -1.0)
		var disc := _mock_plate(inner, fill_t, fill_b, Color(1, 1, 1).lerp(fill_t, 0.3),
			key if style == "socket" else Color(0, 0, 0, 1), false, inner.size.x * 0.5)
		if style == "socket":
			disc.material.set_shader_parameter("outline_w", 1.5)
		var cl := _label(str(int(_data.get("cost", 0))), int(round(cr.size.x * 0.6)))
		cl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cl.add_theme_color_override("font_color", Color(1, 0.98, 0.92))
		cl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		cl.add_theme_constant_override("outline_size", 4)
		_place(cl, cr)


# --- The 3D window, for rares (backlog #84) --------------------------------
#
# Nick sent valdosh's Blender tutorial: a card with a hole cut through it and a
# scene sitting behind the hole, so turning the card gives the contents real
# parallax against the frame. tools/blender/rare3d.py renders that — 24 views of
# one card's window, packed into a single sprite sheet.
#
# It is played back as an ANGLE LOOKUP, not as an animation. The frame is picked
# from the same `tilt` the foil shader uses: the pointer on a desktop, the
# accelerometer on a phone. A card that loops on a timer reads as a GIF stuck to
# the face; one that tracks the player's hand reads as an object being turned,
# which is the entire point of the effect.
#
# It replaces exactly one node — the ART_LAYER TextureRect — on either
# treatment, framed or borderless, and every layer above it is untouched. That
# is what the named constant was reserved for.
#
# WHO GETS ONE. Nick, 2026-09-01: "All rares will have the window effect."
# So it is NOT a pull — unlike foil and borderless, which roll per copy, this is
# a fixed property of the card, and every rare wears it. That is what makes the
# three read as a hierarchy instead of three unrelated shinies: the window says
# what the CARD is, the foil and the border say what this COPY is, and a
# borderless foil rare has all three at once because they are answering
# different questions.
#
# The policy lives in tools/blender/rare3d.py, which refuses a non-rare without
# --force and has an --all that builds the whole set from cards.json. This side
# stays dumb on purpose — a sheet exists, so it is used — because the same
# rule enforced in two places is a rule that will eventually disagree with
# itself. 29 rares; one has art so far.
const CARD_ART_3D := "res://assets/cardart3d/"


func _has_window(id: String) -> bool:
	return id != "" and ResourceLoader.exists(CARD_ART_3D + id + ".png")


## The sheet as an AtlasTexture, with the grid read from its sidecar .json.
## Returns null when this card has no window, which is all but a handful.
func _window_art(id: String) -> AtlasTexture:
	if not _has_window(id):
		return null
	var grid := _window_grid(CARD_ART_3D + id + ".json")
	if grid.is_empty():
		return null
	_win_frames = int(grid.get("frames", 0))
	_win_cols = maxi(int(grid.get("cols", 1)), 1)
	_win_cell = Vector2i(int(grid.get("cell_w", 0)), int(grid.get("cell_h", 0)))
	if _win_frames <= 0 or _win_cell.x <= 0 or _win_cell.y <= 0:
		return null
	_win = AtlasTexture.new()
	_win.atlas = load(CARD_ART_3D + id + ".png")
	_win_at = -1
	_turn_window(0.0)          # a still card shows the head-on view
	set_process(true)          # the window needs a tick even with no foil
	return _win


## The sheet's grid, from its sidecar .json. {} when it cannot be read.
##
## Two ways in, because a .json is an awkward thing to ship: Godot's importer
## turns it into a JSON resource, but a plain-file loader can also pick it up,
## and which one applies depends on whether the project has been imported since
## the file appeared. Trying both costs four lines and removes a class of bug
## where the window silently does not appear on one machine.
func _window_grid(path: String) -> Dictionary:
	var d: Variant = null
	if ResourceLoader.exists(path):
		var res := load(path)
		if res is JSON:
			d = (res as JSON).data
	if typeof(d) != TYPE_DICTIONARY and FileAccess.file_exists(path):
		d = JSON.parse_string(FileAccess.get_file_as_string(path))
	return d if typeof(d) == TYPE_DICTIONARY else {}


## Point the window at the view for `t` in -1..+1, left to right.
func _turn_window(t: float) -> void:
	if _win == null:
		return
	var i := clampi(int(round((clampf(t, -1.0, 1.0) * 0.5 + 0.5)
		* float(_win_frames - 1))), 0, _win_frames - 1)
	if i == _win_at:
		return   # 24 views over a full turn, so most ticks land on the same one
	_win_at = i
	var col: int = i % _win_cols
	var row: int = i / _win_cols
	_win.region = Rect2(col * _win_cell.x, row * _win_cell.y,
		_win_cell.x, _win_cell.y)


# --- The borderless pull ---------------------------------------------------
#
# A second TREATMENT of the same card, in the sense Magic and Slay the Spire's
# beta art use the word: identical rules, identical size, no moulding. The
# painting runs to all four rounded corners and the type is printed straight
# onto it.
#
# It is not "the framed card with the frame switched off". Take the border away
# and three things that were doing quiet work stop:
#
#   the moulding      gave the card a defined EDGE against a dark table
#   the steel banner  gave the name a light plate to be dark ink on
#   the olive panel   gave the rules a flat opaque field to sit on
#
# So each is replaced by something that does the same job without geometry: a
# hairline stroke in the hunter's colour, an outlined cream name, and a
# gradient that fades the painting into black under the text. That last one is
# the difference between borderless and unreadable — a hard-edged dark panel on
# a card with no frame just looks like the frame came back.

## The corner radius the whole card is cut to. Bigger than the framed card's 13:
## with no moulding to read the curve off, a tight radius looks like a
## rectangle someone forgot to round.
const BORDERLESS_RADIUS := 16
## The hairline edge, per hunter — the LIP colours from tools/blender/frames.py,
## which are the highlight on each character's moulding. Using the lip rather
## than the body colour is deliberate: the stroke is standing in for the bright
## edge the moulding used to catch, so it should be that colour.
const EDGE := {
	"frog": Color("7FB894"),
	"vine_weaver": Color("A794D6"),
	"mountain_climbers": Color("9CB8DC"),
	"goblin_mech": Color("E0AE85"),
	"lightbearer": Color("F2D492"),
	"common": Color("9AA0B2"),
}


func _build_borderless(data: Dictionary, tex: Texture2D) -> void:
	# The clip box. Everything on this card lives inside it, because the whole
	# claim of a borderless card is that the ART reaches the corner — and a
	# TextureRect has no corner radius. A Panel that draws a rounded box and
	# clips its children to that shape does, and it costs one node.
	var host := Panel.new()
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color(0.045, 0.043, 0.050)   # only ever seen behind the art
	hsb.set_corner_radius_all(BORDERLESS_RADIUS)
	host.add_theme_stylebox_override("panel", hsb)
	host.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(host)
	_face_host = host   # from here _layer() and _build_foil() target the box

	# 1 - ART_LAYER, and on this card it is the whole card. Same index as the
	# framed face on purpose: backlog #84's 3D window replaces exactly this node
	# whichever treatment it lands on.
	var art := TextureRect.new()
	var win := _window_art(String(_data.get("id", "")))
	art.texture = win if win != null else tex
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.clip_contents = true
	_layer(art, 0, 0, 1, 1)

	# 2 - the fade. Where the framed card has an opaque olive panel, this has
	# the painting continuing down into black. Three stops rather than two: a
	# straight linear ramp has a visible start line partway up the art, and the
	# soft shoulder is what makes it read as the picture going dark rather than
	# as a translucent rectangle laid over it.
	_layer(_fade(false, Color(0.02, 0.02, 0.03), 0.97), 0, 0.40, 1, 1)
	# And a shorter one at the top, for the name. Nothing else needs it.
	_layer(_fade(true, Color(0.02, 0.02, 0.03), 0.80), 0, 0, 1, 0.19)

	# 4 - the type, small, printed on the art. No steel pill: a plate is
	# furniture, and this card's argument is that there is none.
	var kind := String(_data.get("type", ""))
	if kind != "":
		var t := _label(kind.to_upper(), 9)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.add_theme_color_override("font_color", _rarity_of(_data)["pip"])
		t.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		t.add_theme_constant_override("outline_size", 4)
		_layer(t, 0.0, 0.555, 1.0, 0.555, 0.0, 0.0, 0.0, 14.0)

	# 5 - the rules, on the fade. Same size and centring as the framed card, so
	# a borderless copy of a card you own reads at exactly the same speed.
	_rules = _rich_body(_data, 14, 40)
	_rules.text = "[center]" + _rules.text + "[/center]"
	# A shadow, because there is no flat panel underneath any more and cream
	# text on a dark PAINTING still has to survive whatever the painting does.
	_rules.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_rules.add_theme_constant_override("shadow_offset_x", 1)
	_rules.add_theme_constant_override("shadow_offset_y", 1)
	_rules.add_theme_constant_override("shadow_outline_size", 3)
	_layer(_rules, 0.085, 0.635, 0.915, 0.95)
	# Same _layer()-stomps-PASS-back-to-IGNORE gap as the framed face's own
	# rules body (_build_upper, a few functions up) -- a borderless pull goes
	# through this builder instead, so it needs the identical restore.
	_rules.mouse_filter = Control.MOUSE_FILTER_PASS

	# 6 - rarity pips, bottom right, same place as the framed card.
	_layer(_rarity_pips(_data), 0.60, 0.955, 0.92, 0.955, 0.0, -12.0, 0.0, -2.0)

	# 7 - the name, printed rather than plated. Cream with a heavy outline is
	# how every full-art card in every game does this, for the same reason:
	# it is the only treatment that works over a sky AND over a shadow.
	var nm := _label(String(_data.get("name", "")), 15)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nm.add_theme_color_override("font_color", Color(0.98, 0.95, 0.87))
	nm.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	nm.add_theme_constant_override("outline_size", 6)
	# Left edge clears the cost orb, exactly as the banner does on a framed card.
	_layer(nm, 0.0, 0.0, 1.0, 0.0, 40.0, 6.0, -8.0, 32.0)

	# 8 - the stroke. This is the border's real job, kept: a card with no edge
	# at all dissolves into a dark background, and a hand of them looks like one
	# smeared painting. One hairline in the hunter's colour and it is an object
	# again. Drawn last so it sits over the art at every corner.
	var edge := Panel.new()
	var esb := StyleBoxFlat.new()
	esb.bg_color = Color(0, 0, 0, 0)
	esb.set_corner_radius_all(BORDERLESS_RADIUS)
	esb.set_border_width_all(2)
	esb.border_color = Color(EDGE.get(String(_data.get("character", "")),
		EDGE["common"]), 0.70)
	edge.add_theme_stylebox_override("panel", esb)
	_layer(edge, 0, 0, 1, 1)

	# 9 - the cost. The one plate that survives: it is the number read first and
	# most often, and printing it flat onto the art costs a real read for a
	# cosmetic. INSET rather than overhanging the corner, because the clip box
	# would cut an overhang off.
	if shows_cost(_data):
		var orb := _cost_orb(int(_data.get("cost", 0)),
			String(_data.get("character", "")))
		orb.position = Vector2(4, 4)
		host.add_child(orb)


## A one-directional fade to `to`, as a texture rather than a shader.
##
## `from_top` true fades from transparent at the top to opaque at the bottom of
## its own rect; false is the same ramp upside down. `peak` is how opaque it
## ever gets — never 1.0 at the very edge on the bottom fade, so the painting
## is still faintly present behind the last line of text instead of the card
## ending in a flat black bar.
func _fade(from_top: bool, to: Color, peak: float) -> TextureRect:
	var g := Gradient.new()
	# FOUR stops, not a straight ramp. A linear fade puts alpha at about 0.5
	# exactly where the rules text lands, and the first shot of this showed the
	# result: "Climb 4." printed over lit foliage, legible only because of its
	# shadow. This one stays soft for the first third — which is what hides the
	# transition — and then commits hard, so the text gets a real bed under it.
	g.offsets = PackedFloat32Array([0.0, 0.30, 0.60, 1.0])
	var ramp := [0.0, 0.40, 0.88, 1.0]
	var cols: PackedColorArray = []
	for i in range(4):
		var f: float = ramp[i] if not from_top else ramp[3 - i]
		cols.append(Color(to, f * peak))
	g.colors = cols
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 4
	gt.height = 256
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var r := TextureRect.new()
	r.texture = gt
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	return r


## Show or hide a card's RULES, leaving its name, cost and art alone.
##
## Nick, on the Slay the Spire hand: "you cannot even see the information of the
## card until you highlight it." Correct, and it is what makes their hand read as
## a row of paintings rather than a wall of small print. The name, the cost and
## the picture are always there; the panel, the type and the rules arrive when
## the card comes up.
##
## Always on for a handheld: there is no hover on a touch screen, and a card
## whose text only appears on something a phone cannot do is a card with no text.
## Nick, seeing the fan at rest: "it shows them as full art instead of the
## bordered." Right - Slay the Spire never HIDES the panel. It is always part
## of the card, and at rest it sits below the screen edge because the card is
## tucked, which is a completely different thing from toggling it off: a card
## dragged, mid-animation, or on a short screen still looks like a card. The
## deep tuck does the concealing; this now does nothing, kept only so old
## callers do not crash.
func set_details_visible(_on: bool) -> void:
	pass


## The rail form: [cost] [icon] [name / rules text], one row. Everything a
## portrait card says, laid out sideways — nothing is dropped, because a card you
## can't read is a card you won't play.
func _rail_row(data: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Cost reads as a pip, not a word — it's the number you scan first.
	var cost := _label(str(int(data.get("cost", 0))), 20)
	cost.custom_minimum_size = Vector2(22, 0)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost.add_theme_color_override("font_color", Color(0.95, 0.82, 0.5))
	if shows_cost(data):
		row.add_child(cost)
	else:
		cost.free()

	var icon := String(data.get("icon", ""))
	if ICONS.has(icon):
		var tex := TextureRect.new()
		tex.texture = ICONS[icon]
		tex.custom_minimum_size = Vector2(30, 30)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tex)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 1)

	var name_lbl := _label(String(data.get("name", "")), 14)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	col.add_child(name_lbl)

	col.add_child(_rich_body(data, 12, RAIL_HEIGHT - 34))

	row.add_child(col)
	row.add_child(_inspect_button(data))
	return row


## The clock in the bottom-right corner: this card has a timing window, and
## landing the middle of it pays a bonus.
##
## It replaces the "Time it!" that used to open the description. A badge in a
## fixed corner is learned once and then read at a glance across a whole hand,
## where a text prefix has to be re-read on every card and costs the room the
## actual numbers need (Nick, 2026-08-16).
##
## Bottom-right, not top-right: the name is right-aligned in the header, and a
## badge up there cost "Tongue Snap" its last three letters on every timed card.
## It shares the bottom band with the timing strip, so start_timing() hides it —
## once the strip is sweeping, the promise has been redeemed and the badge is
## just clutter over the thing the player is actually watching.
## `hits` > 1 puts a count beside the clock ("3x"). Descriptions say nothing about
## timing at all now, so a card that needs THREE windows in a row rather than one
## — Satchel Charge is the whole point of the mechanic — would otherwise read
## exactly like a card that needs none. The count is an icon, not prose.
func _clock_badge(compact: bool, hits: int) -> Control:
	var size := 14.0 if compact else 18.0
	var inset := 3.0 if compact else 5.0
	var gold := Color(1.0, 0.83, 0.36)  # the timing colour, so badge and strip agree

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 1)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE  # never steals the tap that plays the card
	var width := size
	if hits > 1:
		var count := _label("%dx" % hits, 11 if compact else 12)
		count.add_theme_color_override("font_color", gold)
		count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(count)
		width += 14.0

	var tex := TextureRect.new()
	tex.texture = ICONS["timer"]
	tex.modulate = gold
	tex.custom_minimum_size = Vector2(size, size)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(tex)

	row.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	row.offset_left = -(width + inset)
	row.offset_top = -(size + inset)
	row.offset_right = -inset
	row.offset_bottom = -inset
	return row


## A thumb-sized "?" that opens the full rules. The card face carries the numbers;
## this carries the explanation, so neither has to be crammed onto the other.
func _inspect_button(data: Dictionary) -> Control:
	var b := Button.new()
	b.text = "?"
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(26, 26)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.tooltip_text = "What does this do?"
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(0.72, 0.66, 0.56))
	b.add_theme_color_override("font_hover_color", Color(1, 0.88, 0.55))
	b.pressed.connect(func() -> void: inspect_requested.emit(data))
	return b


## The card's ONE description line, written from what it will actually do.
##
## Slay the Spire never prints a formula and a result side by side: a card says
## "Deal 6 damage", and when Strength makes that 9 the NUMBER changes, in place.
## The first pass at this added a live readout ABOVE the authored text, so Brace
## read "5 blk" and then "Gain 5 Block." — the same fact twice, once abbreviated.
## This replaces both: full words, live numbers, one sentence.
##
## The authored `text` still exists and still explains the card's SHAPE ("+3 per
## Rhythm") — it lives in the inspector, where there is room for it.
## `rich` emits BBCode for a RichTextLabel: numbers a buff or scaling CHANGED from
## the card's printed value turn green (StS's cue that your Strength is working),
## and every keyword turns gold so the player can see a rules term exists at all.
## Keywords whose prose form differs from keywords.json's own `name`, or that
## are deliberately never marked up. Height is written "climb" everywhere a
## card talks about it, so searching for "Height" alone would find nothing.
## Timed has no word at all any more — the clock badge says it — so it opts
## out with an empty list rather than being left for the default below.
const KEYWORD_WORD_OVERRIDES := {
	"height": ["Climb", "climb", "climbs", "Height"],
	"timed": [],
}


## The word(s) a keyword actually WEARS in prose, for _markup() to search for.
##
## Used to be a hand-copied list of every keyword's own name, and it only ever
## held the 8 keywords that existed when it was written — every keyword added
## since (Frail, Thorns, Dexterity, Retain, Innate, Ethereal, Scry, Intangible,
## Buffer, Plated Armour, Light, Discard, ...) silently had no entry, so its
## word was never findable and never underlined wherever a card's authored
## `text` was rendered with no live `preview` (every reward-screen offer).
## Defaults to the keyword's own printed name (keywords.json) so a new keyword
## is markup-able the moment it ships; only KEYWORD_WORD_OVERRIDES above needs
## to spell one differently or opt one out.
static func _keyword_words(id: String) -> Array:
	if KEYWORD_WORD_OVERRIDES.has(id):
		return KEYWORD_WORD_OVERRIDES[id]
	var kw_name := String(Content.keyword(id).get("name", ""))
	return [kw_name] if kw_name != "" else []


static func face_text(data: Dictionary, rich: bool = false) -> String:
	var pv: Dictionary = data.get("preview", {})
	if pv.is_empty():
		# No live preview — a card you are being OFFERED rather than holding. Its
		# authored text still names keywords, so mark them up here or the same
		# term would be underlined in your hand and plain on the reward screen.
		return _markup(String(data.get("text", "")), data.get("keywords", []), rich)
	var miss: Dictionary = data.get("preview_miss", pv)
	var fx: Dictionary = data.get("fx", {})
	var base: Dictionary = data.get("base", {})
	var kw: Array = data.get("keywords", [])
	var out: PackedStringArray = []

	# backlog #86 duty 2 — the same "GameHost's fx dict never carried this
	# field" gap as light_gain/ally_heal/dexterity/etc. above, this time for
	# light_cost (#47's bank-and-spend cost, Combat.can_play()/play_card()):
	# Guiding Light ("Spend 3 Light. Heal an ally 8.") and Flare ("Spend 5
	# Light. Deal 14 damage.") both have another effect that fires first and
	# fills `out`, so their live face silently dropped the Light cost entirely
	# — a player saw a card that looked free beyond its energy cost, then
	# found it unplayable once their banked Light ran low with nothing on the
	# card ever having said why. Printed first, matching the authored text's
	# own "Spend N Light." lead clause.
	if int(fx.get("light_cost", 0)) > 0:
		out.append("Spend %d %s." % [int(fx["light_cost"]), _kw("Light", "light", kw, rich)])

	# backlog #86 duty 2: read "damage_after_mods" (the Titan's own armored-hide/
	# Exposed/sigil math already folded in, matching what _damage_boss() will
	# actually do to boss.hp) rather than the raw "damage", which is what
	# play_card() still feeds _damage_boss()/_damage_add() and no longer what the
	# player should be told to expect — same fix, same reasoning, as
	# block_after_mods above, just for the other half of a hit. A live preview
	# lacking the new key falls back to the raw number, same as block's own
	# fallback.
	var dmg := int(pv.get("damage_after_mods", pv.get("damage", 0)))
	if dmg > 0:
		var n := int(fx.get("hits", 1))
		var times := "" if n <= 1 else (" twice" if n == 2 else " %d times" % n)
		# backlog #86 duty 2 — Cleave (#63, hits_all_enemies) reached this dict's
		# sibling `_keywords_of()` tag long ago but never this line: Sweeping
		# Strike's live face read "Deal 8 damage." with no hint it also hits
		# every add, same "reads as a smaller, wrong card" failure every other
		# fx gap this function has caught produces.
		var cleave := " to the Titan and every add it has" if bool(fx.get("hits_all_enemies", false)) else ""
		out.append("Deal %s damage%s%s." % [_num(int(miss.get("damage_after_mods", miss.get("damage", 0))), dmg,
			int(base.get("damage", dmg)), rich), times, cleave])

	# Both-hunters effects merge into one line. "Gain 2 Block. Ally gains 2 Block."
	# is the same fact typed twice; "All players gain 2 Block" is the card.
	# backlog #86 duty 2: read "*_after_mods" (Dexterity/Frail already folded
	# in, matching what Combatant.gain_block() will actually produce) rather
	# than the raw "block"/"ally_block", which is what play_card() still feeds
	# gain_block() and no longer what the player should be told to expect. A
	# live preview lacking the new key (the printed-only fallback outside
	# combat, `_printed()`) has no combatant to modify against anyway, so
	# falling back to the raw number there is exactly right, not a compromise.
	var blk := int(pv.get("block_after_mods", pv.get("block", 0)))
	var ally_blk := int(pv.get("ally_block_after_mods", pv.get("ally_block", 0)))
	var blk_n := _num(int(miss.get("block_after_mods", miss.get("block", 0))), blk, int(base.get("block", blk)), rich)
	if blk > 0 and blk == ally_blk:
		out.append("All players gain %s %s." % [blk_n, _kw("Block", "player_block", kw, rich)])
	else:
		if blk > 0:
			out.append("Gain %s %s." % [blk_n, _kw("Block", "player_block", kw, rich)])
		if ally_blk > 0:
			out.append("Ally gains %s %s." % [_num(int(miss.get("ally_block_after_mods", miss.get("ally_block", 0))), ally_blk,
				int(base.get("ally_block", ally_blk)), rich), _kw("Block", "player_block", kw, rich)])

	var climb := int(pv.get("grip", 0))
	var ally_climb := int(pv.get("ally_grip", 0))
	var climb_n := _num(int(miss.get("grip", 0)), climb, int(base.get("grip", climb)), rich)
	# backlog #86 duty 2: ally_climb used to be hand-interpolated with a raw
	# %d instead of routed through _num() like every sibling stat (damage,
	# block, ally_block, this card's own climb_n) -- so ally_grip_per_rhythm
	# scaling (Hopscotch, Ripple Leap) or an upgrade's +1 ally_grip could never
	# turn the ally-climb number gold, even when it landed well above the
	# printed card.
	var ally_climb_n := _num(int(miss.get("ally_grip", 0)), ally_climb, int(base.get("ally_grip", ally_climb)), rich)
	if climb > 0 and climb == ally_climb:
		out.append("All players %s %s." % [_kw("climb", "height", kw, rich), climb_n])
	else:
		if climb > 0:
			out.append("%s %s." % [_kw("Climb", "height", kw, rich), climb_n])
		if ally_climb > 0:
			out.append("Ally %ss %s." % [_kw("climb", "height", kw, rich), ally_climb_n])
	# backlog #86 duty 2 — targets_hold (#24, Route Finder) never grew a branch
	# here: Combat.preview() never folds a hold-climb into `grip` (that's
	# resolved separately in play_card()), so face_text() had no live number to
	# read for it at all. Standalone Route Finder only read right by accident
	# (no other fx field set, so `out` stayed empty and the authored text won);
	# melding it with a real attack or Block card silently dropped the climb.
	if bool(fx.get("targets_hold", false)):
		out.append("%s straight to the next hold." % _kw("Climb", "height", kw, rich))

	# backlog #86 duty 2 — same shape as Dexterity/Frail/Thorns below: GameHost's
	# "fx" dict never carried "ally_heal" (card.gd's name for the Lightbearer's
	# Mend), so a card combining it with an already-handled effect showed only
	# the other line and silently dropped the heal — a lone Warm Glow ("Heal an
	# ally 4. Gain 1 Light.") hit this the moment its light_gain line fired
	# first, and a melded Guiding Light + Harpoon (ally_heal 8, real damage from
	# Harpoon) hides its entire heal behind "Deal 8 damage." _meld_cards() itself
	# already carries ally_heal correctly (run_tests.gd's
	# _test_meld_carries_light_and_deck_effects) — only the FACE never grew a
	# branch for it.
	if int(fx.get("ally_heal", 0)) > 0:
		out.append("%s an ally %d." % [_kw("Heal", "mend", kw, rich), int(fx["ally_heal"])])
	if int(fx.get("wound", 0)) > 0:
		out.append("%s %d." % [_kw("Poison", "poison", kw, rich), int(fx["wound"])])
	# backlog #86 duty 2 — Expose is the one debuff on this list that does NOT
	# fan out to adds on a hits_all_enemies card (combat.gd:1167-1172 keeps
	# Vulnerable boss-only on purpose, since an add never spends the sigil's
	# bonus it would carry). Poison/Frail above and below genuinely do fan
	# out, so their lines needed no scope note — but this line used to sit
	# directly under the damage line's own "to the Titan and every add it
	# has" (the `cleave` var above), so a melded Cleave+Expose card read as
	# "Deal 8 damage to the Titan and every add it has. Expose 2." with
	# nothing telling the player the second sentence doesn't mean what the
	# first one just said. _test_backlog86_expose_scope_note_on_a_cleave_card
	# (run_tests.gd) pins the fixed wording.
	if int(fx.get("vulnerable", 0)) > 0:
		var boss_only := " (the Titan only)" if bool(fx.get("hits_all_enemies", false)) else ""
		out.append("%s %d%s." % [_kw("Expose", "expose", kw, rich), int(fx["vulnerable"]), boss_only])
	# backlog #86 duty 2 — same shape as Dexterity/power_effect below: GameHost's
	# "fx" dict never carried "frail", so a card combining damage with Frail
	# (Crippling Blow: "Deal 5 damage. Frail 2.") showed only "Deal 5 damage."
	# once the damage line made `out` non-empty and skipped the authored-text
	# fallback. Frail is applied to the Titan, like Poison/Expose above.
	if int(fx.get("frail", 0)) > 0:
		out.append("%s %d." % [_kw("Frail", "frail", kw, rich), int(fx["frail"])])
	if int(fx.get("strength", 0)) > 0:
		out.append("%s %d." % [_kw("Strength", "strength", kw, rich), int(fx["strength"])])
	# backlog #86 duty 2 — Dexterity (Strength's own "defensive counterpart",
	# card.gd's words) never got this line when Strength did: the fx dict this
	# reads (GameHost) never carried "dexterity" at all, so a card combining
	# Block+Dexterity (Steady Grip) showed "Gain 4 Block." on its live face and
	# silently dropped the Dexterity — while its Block+Strength sibling (Chalk
	# Up) correctly shows both. Same two-line fix game_host.gd's "fx" dicts got.
	if int(fx.get("dexterity", 0)) > 0:
		out.append("%s %d." % [_kw("Dexterity", "dexterity", kw, rich), int(fx["dexterity"])])
	# backlog #86 duty 2 — same gap, this time Thorns (a self-buff, like
	# Strength/Dexterity above, not a Titan debuff): Spinebrace ("Gain 5 Block.
	# Thorns 2.") showed only "Gain 5 Block." once the Block line made `out`
	# non-empty.
	if int(fx.get("thorns", 0)) > 0:
		out.append("%s %d." % [_kw("Thorns", "thorns", kw, rich), int(fx["thorns"])])
	# backlog #86 duty 2 — same gap once more, this time Intangible/Buffer/
	# Plated Armour (#60/#61): game_host.gd's "fx" dict never carried any of the
	# three, so a card combining one with damage/Block (or a meld fusing e.g.
	# Ghost Step's Intangible into a real attack — Combat._meld_cards() already
	# sums all three correctly) showed only the other line and silently dropped
	# the defensive stack.
	if int(fx.get("intangible", 0)) > 0:
		out.append("%s %d." % [_kw("Intangible", "intangible", kw, rich), int(fx["intangible"])])
	if int(fx.get("buffer", 0)) > 0:
		out.append("%s %d." % [_kw("Buffer", "buffer", kw, rich), int(fx["buffer"])])
	if int(fx.get("plated_armour", 0)) > 0:
		out.append("%s %d." % [_kw("Plated Armour", "plated_armour", kw, rich), int(fx["plated_armour"])])
	# backlog #86 duty 2 — game_host.gd's "fx" dict has carried power_effect/
	# power_value since backlog #57 (the recurring-power cards themselves), and
	# a melded power card (79821cd) carries them too once fused — but this
	# function never grew a matching branch, so any melded card that ALSO deals
	# damage or grants Block/Height (out.is_empty() then false, skipping the
	# "fall back to authored text" case below) shows only that one line: melding
	# Iron Husk (a real recurring +3 Block card) into Cleave mechanically still
	# pays Block every turn end, but its live face reads just "Deal 10 damage." —
	# the whole recurring payoff is invisible on the card that has it. Same
	# "GameHost grew the field, face_text() didn't" shape as Dexterity above.
	var power_val := int(fx.get("power_value", 0))
	if String(fx.get("power_effect", "")) != "" and power_val > 0:
		var peff := String(fx["power_effect"])
		# backlog #86 duty 2 — combat.gd's _handle_power_effects() and card.gd's
		# archetype_tags() both resolve "heal" as a real power_effect
		# (game_host.gd's _keywords_of() appends the "heal" id for it too, so
		# keywords.json's own "heal" entry is reachable) — but this dict never
		# grew a matching entry, so a power_effect:"heal" card fell to the
		# peff.capitalize()/"power" default: the word still read "Heal" by
		# capitalize() luck, but tapping it linked to the unrelated "power"
		# keyword instead of "heal". No shipped card uses power_effect "heal"
		# yet, but neither did block/strength/wound/thorns before the cards
		# that needed them shipped.
		var pword: String = {"block": "Block", "strength": "Strength", "wound": "Poison",
			"vulnerable": "Expose", "frail": "Frail", "thorns": "Thorns",
			"heal": "Heal"}.get(peff, peff.capitalize())
		var pkw: String = {"block": "player_block", "strength": "strength", "wound": "poison",
			"vulnerable": "expose", "frail": "frail", "thorns": "thorns",
			"heal": "heal"}.get(peff, "power")
		out.append("%s: %s %d each turn end." % [_kw("Power", "power", kw, rich),
			_kw(pword, pkw, kw, rich), power_val])
	if int(fx.get("rhythm", 0)) > 0:
		out.append("%s %d." % [_kw("Rhythm", "rhythm", kw, rich), int(fx["rhythm"])])
	if int(fx.get("draw", 0)) > 0:
		out.append("Draw %d." % int(fx["draw"]))
	if bool(fx.get("taunt", false)):
		out.append("%s." % _kw("Taunt", "taunt", kw, rich))
	# backlog #86 duty 2 — retain/innate/ethereal (game_host.gd's "fx" dict never
	# carried any of the three until the fix beside this one) are real card
	# behaviour, not flavour: Bunker Down ("Gain 4 Block. Retain."), Steady Flame
	# ("Gain 5 Block. Gain 2 Light. Retain."), First Strike ("Deal 5 damage.
	# Innate."), and Reckless Swing/Guarded Instant/Fading Insight (all
	# "... Ethereal.") each pair one of these with a live-tracked effect that
	# already fills `out` above — so the live face fell straight past the
	# `out.is_empty()` authored-text fallback and silently dropped the clause
	# that makes the card do what its own printed text says it does, for six
	# real, shipped cards.
	if bool(fx.get("retain", false)):
		out.append("%s." % _kw("Retain", "retain", kw, rich))
	if bool(fx.get("innate", false)):
		out.append("%s." % _kw("Innate", "innate", kw, rich))
	if bool(fx.get("ethereal", false)):
		out.append("%s." % _kw("Ethereal", "ethereal", kw, rich))
	# backlog #86 duty 2 — same gap again: Light (Beacon "Gain 4 Block. Gain 3
	# Light."; Kindled Strike "Deal 3 damage. Gain 2 Light.") had no branch, so
	# both showed only their Block/damage line once that line made `out`
	# non-empty.
	if int(fx.get("light_gain", 0)) > 0:
		out.append("Gain %d %s." % [int(fx["light_gain"]), _kw("Light", "light", kw, rich)])
	if int(fx.get("pull_ally", 0)) > 0:
		out.append("Pull your ally up to you.")
	# backlog #86 duty 2 — Ally Energy is its own field (distinct from
	# ally_block/ally_grip above, which read pv/base, not fx), so cards that
	# pair it with a live-tracked effect (Alpine Focus: "Strength 2. Ally gains
	# 1 Energy."; Summit Call: "Ally climbs 1. Ally gains 1 Energy.") dropped
	# the Energy line entirely. Rally alone was never affected — with no other
	# fx field set, `out` stayed empty and it fell back to authored text.
	if int(fx.get("ally_energy", 0)) > 0:
		out.append("Ally gains %d %s." % [int(fx["ally_energy"]), _kw("Energy", "energy", kw, rich)])
	if int(fx.get("sac_ally_grip", 0)) > 0 and bool(fx.get("cheapen_pick", false)):
		# backlog #86 duty 2 — _meld_cards() sums sac_ally_grip and ORs
		# cheapen_pick independently, so fusing Catapult (sac_ally_grip) with
		# Burn Coal (cheapen_pick) produces one card whose exhaust_pick block
		# genuinely does both (combat.gd:1021-1029 runs the cheapen branch and
		# the sac_ally_grip branch unconditionally, one after the other). This
		# was an if/elif that only ever showed the ally-climb line, so the
		# fused card's cheapen half — the one the player is actively prompted
		# to pick a second card for — was invisible on its own face.
		out.append("%s a card: ally climbs %d, cheapen another by %d." % [_kw("Burn", "burn", kw, rich),
			int(fx["sac_ally_grip"]), int(fx.get("cheapen_amount", 1))])
	elif int(fx.get("sac_ally_grip", 0)) > 0:
		out.append("%s a card: ally climbs %d." % [_kw("Burn", "burn", kw, rich),
			int(fx["sac_ally_grip"])])
	elif bool(fx.get("exhaust_pick", false)):
		# backlog #86 duty 2 — cheapen_amount (game/core/card.gd:51) is the
		# number upgraded_copy() actually bumps (1 -> 2), but this branch never
		# read it, only the cheapen_pick bool: a campfire-sharpened Burn Coal
		# really did cut a target's cost by 2, and the live face still printed
		# the exact same "to cheapen another" as the un-upgraded card, with the
		# upgrade's whole effect invisible to the player who paid for it.
		out.append("%s a card%s." % [_kw("Burn", "burn", kw, rich),
			"" if not bool(fx.get("cheapen_pick", false))
				else " to cheapen another by %d" % int(fx.get("cheapen_amount", 1))])
	# backlog #86 duty 2 — Discard is an action, not a stat (like Burn above),
	# so it needs its own line rather than falling out of the numeric branches:
	# Quick Purge ("Discard 2 cards. Draw 1.") showed only "Draw 1." once Draw
	# made `out` non-empty, and Cull the Deck / Landfill likewise dropped
	# "Discard a card." alongside their damage/Block line.
	if int(fx.get("discard", 0)) > 0:
		var discard_n := int(fx["discard"])
		out.append("%s %s." % [_kw("Discard", "discard", kw, rich),
			"a card" if discard_n == 1 else "%d cards" % discard_n])
	# backlog #86 duty 2 — same "fx never grew a branch" gap as ally_heal above,
	# this time Scry: a lone Peer Ahead/Read The Climb never surfaces it (no
	# other fx field is set, so `out` stays empty and the authored text wins),
	# but a melded Spark + Peer Ahead (light_gain 2, scry 2) shows only "Gain 2
	# Light." and drops the reveal entirely, even though the meld itself already
	# carries scry correctly.
	if int(fx.get("scry", 0)) > 0:
		out.append("%s %d." % [_kw("Scry", "scry", kw, rich), int(fx["scry"])])
	if String(fx.get("create", "")) != "":
		out.append("Build a tool into your hand.")
	if String(fx.get("prepare", "")) != "":
		out.append("Primed for next turn.")
	# backlog #86 duty 2 — Reach (#68: topdeck/shuffle_in/tutor) had the same
	# "fx never grew a branch" gap as create/prepare just above: Depot ("Gain 3
	# Block. Shuffle a Grip into your draw pile.") showed only "Gain 3 Block."
	# once the Block line made `out` non-empty, and Recon/Waymark (no other fx
	# field set) fell back to their authored text ONLY by accident — a melded
	# copy pairing either with a live-tracked effect would have silently
	# dropped the draw-pile touch entirely, the same way ally_heal/scry did.
	# Generic wording, not the specific card named: face_text() only ever gets
	# an id here, and create/prepare already made the same call above.
	if String(fx.get("topdeck", "")) != "":
		out.append("Put a card on top of your draw pile.")
	if String(fx.get("shuffle_in", "")) != "":
		out.append("Shuffle a card into your draw pile.")
	if String(fx.get("tutor", "")) != "":
		out.append("Search your draw pile for a card and pull it into your hand.")
	if bool(fx.get("meld", false)):
		out.append("Fuse two cards into one that costs 1 less.")

	# backlog #67's condition/condition_bonus (backlog #86 duty 2) — same "fx
	# never grew a branch" gap as ally_heal/scry above. Combat.preview()
	# (combat.gd:618-625) already folds condition_bonus into the damage/block/
	# ally_block/grip numbers written above when the condition holds, so the
	# NUMBER on a live card is always right — but nothing ever told the player
	# the bonus exists, since every one of dagger/brace/harpoon/sunlight_blade/
	# draw_aggro/safety_line also has a non-zero base effect that already fills
	# `out`, skipping the `out.is_empty()` fallback below that is the only
	# place the authored clause used to survive.
	var cond: Dictionary = fx.get("condition", {})
	var cond_bonus: Dictionary = fx.get("condition_bonus", {})
	if not cond.is_empty() and not cond_bonus.is_empty():
		var lead := ""
		match String(cond.get("type", "")):
			"above_sigil":
				lead = "Above the sigil"
			"ally_hanging":
				lead = "If your ally is hanging"
			"nth_card":
				lead = "On your %s card this turn or later" % _ordinal(int(cond.get("value", 1)))
		if lead != "":
			var bits: PackedStringArray = []
			if int(cond_bonus.get("damage", 0)) > 0:
				bits.append("deal %d more" % int(cond_bonus["damage"]))
			if int(cond_bonus.get("block", 0)) > 0:
				bits.append("gain %d more %s" % [int(cond_bonus["block"]), _kw("Block", "player_block", kw, rich)])
			if int(cond_bonus.get("ally_block", 0)) > 0:
				bits.append("ally gains %d more %s" % [int(cond_bonus["ally_block"]), _kw("Block", "player_block", kw, rich)])
			if int(cond_bonus.get("grip", 0)) > 0:
				bits.append("%s %d more" % [_kw("climb", "height", kw, rich), int(cond_bonus["grip"])])
			if not bits.is_empty():
				out.append("%s, %s." % [lead, ", ".join(bits)])

	if out.is_empty():
		return String(data.get("text", ""))
	# No "Time it!" prefix: the clock badge in the corner says the card is timed,
	# and it says it in the same place on every card instead of eating the first
	# three words of the description (Nick, 2026-08-16).
	return " ".join(out)


## The card's one description, as rich text so a single number or keyword can be
## coloured. A plain Label can only tint the whole line, which is why modified values
## and keyword terms were invisible before.
## The length-based shrink below was tuned against the DESKTOP box only
## (BOX_DESKTOP_*) — the handheld box is ~16% narrower (BOX_HANDHELD_* vs
## BOX_DESKTOP_*, set in setup()) and a fixed font size read off desktop-tuned
## thresholds had nowhere left to shrink to on the narrower box, so the
## longest reward card's text clipped mid-sentence on the phone layout with no
## ellipsis or scroll indicator (found by the fixer lane,
## design/progress/bugs.md 2026-09-09 Pass A). Lifted out as a pure function,
## `handheld`/`big` passed in explicitly rather than read from Screen/data here,
## so it can be hit directly from run_tests.gd the way route_between_rungs and
## fire_quality already are.
static func body_font_size(data: Dictionary, base_size: int, handheld: bool) -> int:
	var size := base_size
	# Measured off the PLAIN text, not the bbcode, or the keyword markup counts
	# toward the length and short cards shrink for no reason.
	var chars := face_text(data, false).length()
	if chars > 80:
		size -= 3
	elif chars > 54:
		size -= 2
	elif chars > 36:
		size -= 1
	if handheld:
		var big := bool(data.get("no_cost", false))
		var desktop_w: float = (BOX_DESKTOP_BIG if big else BOX_DESKTOP_NORMAL).x
		var handheld_w: float = (BOX_HANDHELD_BIG if big else BOX_HANDHELD_NORMAL).x
		size = int(round(size * (handheld_w / desktop_w)))
	return maxi(size, 8)


func _rich_body(data: Dictionary, size: int, height: int) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.text = face_text(data, true)
	# Shrink the type to fit rather than clip.
	#
	# Nick: "some words are going off the cards." This label clips instead of
	# growing - which keeps the card the right shape and loses the end of the
	# sentence silently, which is worse than either. Cull the Deck reads "Discard
	# a card. Deal 3 damage and an additional 1 per card in your discard pile":
	# 88 characters into a strip sized for about 50.
	size = body_font_size(data, size, Screen.is_handheld())
	r.fit_content = false
	r.scroll_active = false      # clip a long line rather than grow the card
	r.clip_contents = true
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# PASS, not IGNORE: the label has to SEE the pointer to know which keyword is
	# under it. Anything it doesn't accept still reaches the card Button beneath.
	r.mouse_filter = Control.MOUSE_FILTER_PASS
	r.meta_underlined = false           # the [u] in _kw does it, on the word only
	r.meta_hover_started.connect(func(meta: Variant) -> void: _hover_meta = String(meta))
	r.meta_hover_ended.connect(func(_meta: Variant) -> void: _hover_meta = "")
	# A left click on a keyword is consumed by the RichTextLabel before the Button
	# ever sees it, so forward it by hand — clicking the word "Poison" on a card
	# must still play that card.
	r.meta_clicked.connect(func(_meta: Variant) -> void: _on_self_pressed())
	r.gui_input.connect(_on_card_input)  # right-click over a keyword asks about it
	r.custom_minimum_size = Vector2(0, height)
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.add_theme_font_size_override("normal_font_size", size)
	# Keywords print [b]: the same face, heavier, not the theme's bold font.
	var kb := FontVariation.new()
	kb.base_font = r.get_theme_font("normal_font")
	kb.variation_embolden = A1_KEYWORD_EMBOLDEN
	r.add_theme_font_override("bold_font", kb)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_color_override("default_color", Color(0.9, 0.86, 0.76))
	return r


## The authored text minus everything the live line already said.
##
## Both strings are now written from the same vocabulary, so the inspector showed
## "Deal 2 damage. Climb 2." and then, one line under it, "Deal 2 damage. Climb 1.
## 3 more damage per Rhythm..." — the same words twice. Comparing with the digits
## stripped also catches "Climb 2" against the printed "Climb 1": the same
## statement at a different value, which is exactly what the live line is for.
##
## What survives is the part a live number cannot show — the scaling clauses and
## the timing bonus. A card with nothing left to add (Leap is just "Climb 3")
## returns "", and the inspector drops the line entirely.
static func shape_text(data: Dictionary) -> String:
	var authored := String(data.get("text", ""))
	if authored == "" or (data.get("preview", {}) as Dictionary).is_empty():
		return authored
	var said := {}
	for s in _sentences(face_text(data, false)):
		said[_shape_of(s)] = true
	var keep: PackedStringArray = []
	for s in _sentences(authored):
		if not said.has(_shape_of(s)):
			keep.append(s)
	return " ".join(keep)


static func _sentences(s: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for part in s.split(". ", false):
		var t := part.strip_edges()
		if t != "":
			out.append(t if t.ends_with(".") else t + ".")
	return out


## A sentence with its numbers removed, so two statements that differ only in
## value compare equal.
static func _shape_of(s: String) -> String:
	var out := ""
	for c in s:
		if not (c >= "0" and c <= "9"):
			out += c
	return out.strip_edges()


## A number, coloured only when it isn't what the card printed.
##
## A timed card prints what it is GUARANTEED to do — `low`, the miss outcome —
## because the clock badge already promises a bonus for landing the middle, and a
## bonus reads as "on top of the printed number". The old "2→5" put an arrow and
## two numbers on every timed card, which is most of the Frog's hand.
## The exception is a card whose whole effect is conditional (Tempo Trap climbs
## only on a nail): printing "Climb 0" would describe nothing, so it prints the
## landed value.
static func _num(low: int, high: int, base: int, rich: bool) -> String:
	var shown := low if low > 0 else high
	if rich and shown != base:  # a buff or a scaling field moved it
		return "[color=#%s]%d[/color]" % [LIVE_COLOR, shown]
	return str(shown)


## English ordinal suffix ("1st", "2nd", "3rd", "4th", "11th"–"13th" exceptions).
## Only `nth_card`'s printed value feeds this today (always 3), but the
## condition's own `value` is data, not a hardcoded "3rd", so a beast-tier
## card authored with a different threshold reads correctly without a
## matching code change.
static func _ordinal(n: int) -> String:
	var suffix := "th"
	if n % 100 < 11 or n % 100 > 13:
		match n % 10:
			1: suffix = "st"
			2: suffix = "nd"
			3: suffix = "rd"
	return "%d%s" % [n, suffix]


## Wrap every keyword term in a block of prose, once each.
##
## Only the FIRST occurrence: marking up every "Block" in a sentence turns the
## card into a ransom note, and one underline is enough to say the term is
## explainable. Matches on word boundaries so "Blocking" is never half-wrapped.
static func _markup(text_str: String, kws: Array, rich: bool) -> String:
	if not rich or text_str == "" or kws.is_empty():
		return text_str
	var out := text_str
	for k in kws:
		var id := String((k as Dictionary).get("id", ""))
		for word in _keyword_words(id):
			var at := _word_index(out, String(word))
			if at < 0:
				continue
			out = out.substr(0, at) + _kw(String(word), id, kws, true) 				+ out.substr(at + String(word).length())
			break  # this keyword is marked; move to the next one
	return out


## Index of `word` in `text_str` as a whole word, or -1. Skips anything already
## inside a BBCode tag, so a second keyword can't be spliced into the first's markup.
static func _word_index(text_str: String, word: String) -> int:
	var from := 0
	while true:
		var at := text_str.find(word, from)
		if at < 0:
			return -1
		var before := "" if at == 0 else text_str[at - 1]
		var after_i := at + word.length()
		var after := "" if after_i >= text_str.length() else text_str[after_i]
		var boundary := not _is_word_char(before) and not _is_word_char(after)
		if boundary and text_str.rfind("[", at) <= text_str.rfind("]", at):
			return at
		from = at + 1
	return -1


static func _is_word_char(c: String) -> bool:
	return c != "" and (c.to_lower() != c.to_upper() or c == "_")


## Gold AND underlined, only when the word really is a keyword this card touches.
##
## The colour alone said "this is special"; the underline says "you can ask about
## this" — which is the part that has to be visible, now that right-clicking a
## keyword explains it (Nick, 2026-08-16: "the keyword should be underlined. All
## keywords should be underlined."). The [url] carries the id so a click knows
## WHICH keyword it landed on.
static func _kw(word: String, id: String, kws: Array, rich: bool) -> String:
	if not rich:
		return word
	for k in kws:
		if String((k as Dictionary).get("id", "")) == id:
			return kw_markup(id, word)
	return word


## One keyword word as the card prints it: a tappable link, TARGET's pale tan
## ink in a heavier stroke, and a duller tan underline (run 6).
static func kw_markup(id: String, word: String) -> String:
	return "[url=kw:%s][u color=#%s][b][color=#%s]%s[/color][/b][/u][/url]" % [id, KEYWORD_LINE, KEYWORD_COLOR, word]


const BANNER := preload("res://assets/ui/banner.png")
const PILL := preload("res://assets/ui/pill.png")
## Horizontal nine-slice margins — the shaped ends are fixed, the middle
## stretches. Must match the shapes plates.py renders.
const BANNER_SLICE := 26
const PILL_SLICE := 13
const ORBS := {
	"frog": preload("res://assets/ui/orb_frog.png"),
	"vine_weaver": preload("res://assets/ui/orb_vine_weaver.png"),
	"mountain_climbers": preload("res://assets/ui/orb_mountain_climbers.png"),
	"goblin_mech": preload("res://assets/ui/orb_goblin_mech.png"),
	"lightbearer": preload("res://assets/ui/orb_lightbearer.png"),
	"common": preload("res://assets/ui/orb_common.png"),
}


## A shaped plate with a label centred on it.
##
## NinePatchRect rather than TextureRect: "Bash" and "Reckless Charge" are very
## different widths, and the ribbon's notched ends have to stay notched at both.
func _plate(tex: Texture2D, slice: int, txt: String, size: int,
		height: int) -> Control:
	var np := NinePatchRect.new()
	np.texture = tex
	np.patch_margin_left = slice
	np.patch_margin_right = slice
	np.custom_minimum_size = Vector2(0, height)
	np.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl := _label(txt, size)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Inset by the slice, so the text sits on the FLAT of the plate and not out
	# over the notched ends. Centred across the whole rect, "Cull the Deck" ran
	# past the left notch and looked like it had escaped the card.
	# 0.34, not 0.62. The ribbon is already inset from the card to clear the cost
	# orb, so insetting the label by most of a slice on top of that cost about
	# 42px of a 140px card and truncated "Tongue Snap" to "Tongue Sn...".
	lbl.offset_left = float(slice) * 0.34
	lbl.offset_right = -float(slice) * 0.34
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Dark ink: the plate is steel and deliberately light, because it has to
	# carry a name on all six border colours.
	lbl.add_theme_color_override("font_color", Color(0.13, 0.14, 0.17))
	lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.35))
	lbl.add_theme_constant_override("outline_size", 2)
	np.add_child(lbl)
	return np


## The cost gem, hung off the top-left corner.
##
## Added to the CARD rather than to the layout column, because in the reference
## it overhangs the frame — and anything inside the column is clipped to the
## content margin, which is exactly the overhang.
func _cost_orb(cost: int, who: String) -> Control:
	var tex: Texture2D = ORBS.get(who, ORBS["common"])
	var orb := TextureRect.new()
	orb.texture = tex
	orb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# 40, up from 34. The gem is the largest single glyph on a Slay the Spire
	# card - cost is the first thing you check in hand, and theirs says so.
	var d := 40.0 if not _compact else 24.0
	orb.custom_minimum_size = Vector2(d, d)
	orb.size = Vector2(d, d)
	orb.position = Vector2(-5, -6)
	orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl := _label(str(cost), 18 if not _compact else 12)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(1, 0.97, 0.9))
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	lbl.add_theme_constant_override("outline_size", 4)
	orb.add_child(lbl)
	return orb


func _header(card_name: String, cost: int, no_cost: bool = false) -> Control:
	if no_cost:  # relics have no energy cost — just a centered name
		var name_only := _label(card_name, 14)
		name_only.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_only.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_only.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		return name_only

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)

	var e := TextureRect.new()
	e.texture = ENERGY_ICON
	e.custom_minimum_size = Vector2(16, 16)
	e.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	e.modulate = Color(0.86, 0.72, 0.4)
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(e)

	var cost_lbl := _label(str(cost), 16)
	row.add_child(cost_lbl)

	var name_lbl := _label(card_name, 12)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS  # long names never overflow
	row.add_child(name_lbl)
	return row


## Where a card's own painted art goes: assets/cardart/<card id>.png.
##
## Same idiom as the rest of this project — cast/<id>.glb beats the Kenney
## stand-in, env/<beast>.glb beats the blank disc. Drop a file in and it wins;
## no code edit, no manifest, no registration. Delete it and the shared icon
## comes back.
##
## 187 cards currently share 33 icons — eighteen of them wear the same "lift"
## glyph — so this is the slot that turns a spreadsheet into a card game.
const CARD_ART := "res://assets/cardart/"
## What to export from Canva: 620 x 870 PNG, PORTRAIT.
##
## This changed when the card did. Slay the Spire has two art specs and we now
## use the second one:
##
##   windowed card   25:19 landscape (1000x760) - art inside a frame
##   FULL-IMAGE card 62:87 portrait  (310x435)  - art fills the whole card
##
## Ours is full-bleed now, so the painting has to be the shape of the CARD. A
## landscape 1000x760 dropped into a 62:87 card is scaled to fill and loses most
## of its width - Nick's forest came out as a vertical slice of treetops, which
## is correct behaviour and the wrong source.
##
## 620x870 is 2x their 310x435, for the same reason the frame renders at card
## size: enough for the card detail view without being wasteful.
##
## 4:3 because the art window below is 4:3, so a card fills edge to edge with no
## letterboxing and nothing has to be cropped by eye. 1024 because the card
## DETAIL view blows a card up far past its size in hand — 512 is enough for the
## hand and visibly soft the moment someone inspects it. It is one export either
## way, so it may as well be the one that survives being looked at closely.
const CARD_ART_SIZE := Vector2i(620, 870)
## The art window's height as a fraction of its width. Matches CARD_ART_SIZE.
##
## 19/25 = 0.76, which is Slay the Spire's own card-art ratio - their atlas
## images are 250x190 and the recommended export is 1000x760. Ours was 4:3, a
## 1.3% difference nobody could see, but there is no reason to be near a
## measured number when you can be on it.
const CARD_ART_ASPECT := 0.76


## The art WINDOW: a recessed box the picture sits inside.
##
## Nick: "the art doesn't have its own box." In Slay the Spire the illustration
## is inset behind a frame with its own lip and shadow, which is most of why
## those cards read as printed objects. Ours floated an icon on the card body
## with no boundary at all, so the card had a name, a gap, and some text.
func _art_box(inner: Control) -> Control:
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The window's height is COMPUTED from the card's width and the 25:19 art
	# ratio, and set as a real minimum. Two other ways were tried and both
	# failed for the same underlying reason - nothing was telling the column how
	# tall this thing wanted to be:
	#
	#   EXPAND_FILL       swallowed all the leftover height, so a landscape
	#                     painting sat in a tall narrow hole and was cropped to
	#                     a vertical strip.
	#   AspectRatioContainer
	#                     reports no minimum size of its own, so the column
	#                     allocated it almost nothing and it drew its child
	#                     over the type pill and the rules text.
	#
	# A number the container can actually see fixes both.
	var inner_w: float = maxf(custom_minimum_size.x, 118.0) - 34.0
	box.custom_minimum_size = Vector2(0, inner_w * CARD_ART_ASPECT)
	var sb := StyleBoxFlat.new()
	# Darker than the card body, so it reads as a hole rather than a panel laid
	# on top - a window is something you look INTO.
	sb.bg_color = Color(0.055, 0.055, 0.065)
	sb.set_corner_radius_all(3)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.62, 0.64, 0.70, 0.55)
	# A brighter top edge and a dark bottom: the same lit-from-above bevel the
	# frame and the plates use, so the window belongs to the same object.
	sb.border_width_top = 2
	sb.set_content_margin_all(3)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 3
	box.add_theme_stylebox_override("panel", sb)
	box.add_child(inner)
	return box


func _art(icon: String, portrait: String = "", card_id: String = "") -> Control:
	var tex := TextureRect.new()
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The window's SHAPE decides its height now (see _art_box), so the picture
	# just fills whatever the window is.
	tex.size_flags_vertical = Control.SIZE_FILL
	# Fixed, modest art size — the icon is an accent, not the card's focus (Nick).
	# Portraits (character select) keep a larger pane.
	# 86, not 58. The window is the biggest element on a Slay the Spire card
	# whether or not there is art in it, and sizing it to the ICON made ours
	# a name over a gap over a paragraph.
	tex.custom_minimum_size = Vector2(0, 76 if portrait != "" else 0)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # a big PNG must not force the card taller
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var own := CARD_ART + card_id + ".png"
	if card_id != "" and ResourceLoader.exists(own):
		# This card has art of its own. Give it a 4:3 window matching what the
		# artist exported, so it fills the frame instead of sitting letterboxed
		# inside the icon's slot. Width comes from the card; height follows.
		# The art is the card. In the reference it runs from under the name
		# plate to the type pill - well over half the face - and everything else
		# is a strip. Ours was 42px on a 224px card.
		# NO minimum height. size_flags_vertical is already EXPAND_FILL, so the
		# window takes whatever the card has spare - and a minimum on top of that
		# does not make the art bigger, it makes the CARD bigger.
		#
		# That is the bug: a card with real art demanded 100px for its window on
		# top of the name, pill and rules, blew past its own custom_minimum_size,
		# and came out visibly taller than its neighbours. Leap was a head above
		# the rest of the hand, and the fan lays cards out assuming they match.
		tex.custom_minimum_size = Vector2.ZERO
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.clip_contents = true
		tex.texture = load(own)
	elif portrait != "" and ResourceLoader.exists(portrait):
		tex.texture = load(portrait)  # character portrait, full colour
	elif ICONS.has(icon):
		tex.texture = ICONS[icon]
	return tex


func _body(text_str: String) -> Control:
	var l := _label(text_str, 12)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL  # balance the space below the art
	return l


func _tag(text_str: String) -> Control:
	var l := _label(text_str, 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.modulate = Color(0.72, 0.67, 0.55)
	return l


func _label(text_str: String, size: int) -> Label:
	var l := Label.new()
	l.text = text_str
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	return l


## One frame per CHARACTER, rendered by tools/blender/frames.py — a real
## moulding lit from the top left, which is where the "almost 3D" in Nick's
## reference cards comes from.
##
## By character rather than by rarity because that is what he asked for and it
## is the stronger signal: a hand is one hunter's cards, so the border tells you
## whose turn you are looking at before you read a word. Rarity is still on the
## face, as the gem pips.
##
## "common" is the fallback for a card with no owner — a reward on offer, a
## neutral card — not a rarity.
const FRAMES := {
	"frog": preload("res://assets/ui/frame_frog.png"),
	"vine_weaver": preload("res://assets/ui/frame_vine_weaver.png"),
	"mountain_climbers": preload("res://assets/ui/frame_mountain_climbers.png"),
	"goblin_mech": preload("res://assets/ui/frame_goblin_mech.png"),
	"lightbearer": preload("res://assets/ui/frame_lightbearer.png"),
	"common": preload("res://assets/ui/frame_common.png"),
}
## Must match frames.py's MARGIN. The moulding lives in this band and a 9-slice
## stretches everything outside it — get this wrong and the corners smear.
const FRAME_MARGIN := 13
const FRAME_GOLD := preload("res://assets/ui/card_gold.png")


## Rarity, made visible.
##
## The data has carried a rarity per card since the beginning (core/card.gd) and
## the card face has never once shown it. Marvel Snap and Pokémon TCG Pocket both
## make rarity a VISUAL fact — borders, effects, a treatment that changes as a
## card improves — and that is most of where card games earn their reputation for
## polish. On a phone the card is the object in your hand; it is the surface
## worth spending on.
##
## Deliberately restrained: a tint on the frame and a pip under the cost. Three
## rarities need to be told apart at a glance on a 124px card, not admired.
const RARITY := {
	"common":   {"tint": Color(1.00, 1.00, 1.00), "pip": Color(0.62, 0.66, 0.70), "pips": 1},
	"uncommon": {"tint": Color(0.86, 0.94, 1.06), "pip": Color(0.55, 0.78, 1.00), "pips": 2},
	"rare":     {"tint": Color(1.10, 1.00, 0.80), "pip": Color(1.00, 0.82, 0.35), "pips": 3},
}


func _rarity_of(data: Dictionary) -> Dictionary:
	return RARITY.get(String(data.get("rarity", "common")), RARITY["common"])


## Three little gems in the top corner: one common, two uncommon, three rare.
##
## Count rather than colour alone, because colour alone fails for the ~8% of
## players with a red-green deficiency and fails again on a dim phone outdoors.
func _rarity_pips(data: Dictionary) -> Control:
	var r := _rarity_of(data)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 2)
	row.alignment = BoxContainer.ALIGNMENT_END
	for i in range(int(r["pips"])):
		var gem := ColorRect.new()
		gem.color = r["pip"]
		gem.custom_minimum_size = Vector2(6, 6)
		gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# SHRINK_CENTER, or the HBox stretches each gem to the row's full height
		# and the 45 degrees below turns a 6x10 bar into a slightly skewed 6x10
		# bar. Zoomed, the pair read as a pause button in the corner of the card,
		# which is the second time this element has been mistaken for a control.
		gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		gem.pivot_offset = Vector2(3, 3)
		gem.rotation = PI * 0.25          # a diamond reads as a gem; a square reads as a bug
		row.add_child(gem)
	return row


func _apply_frame() -> void:
	var tex: Texture2D = FRAMES.get(String(_data.get("character", "")),
		FRAMES["common"])
	# Hover lifts, pressed sinks, disabled drains. All off ONE rendered frame:
	# the bevel already carries the form, so the states only have to change how
	# much light it is catching.
	# Empty on a full card: _build_upper draws the frame as a layer above the
	# art. The rail form still wants a real stylebox behind its row.
	if not _compact:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())
		return
	add_theme_stylebox_override("normal", _tex_frame(tex, Color(1, 1, 1)))
	add_theme_stylebox_override("hover", _tex_frame(tex, Color(1.18, 1.16, 1.12)))
	add_theme_stylebox_override("pressed", _tex_frame(tex, Color(0.82, 0.82, 0.84)))
	add_theme_stylebox_override("disabled", _tex_frame(tex, Color(0.55, 0.56, 0.60)))


## Ornate 9-slice card frame (baked from Kenney Fantasy UI Borders).
func _tex_frame(tex: Texture2D, tint: Color = Color.WHITE) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.modulate_color = tint
	sb.set_texture_margin_all(FRAME_MARGIN)  # the bevel lives here; never stretch it
	# Wider side margins than top/bottom. Nick: "wording still leans off the side
	# of the card." A uniform margin looks even and reads badly, because the
	# rules text is the only thing that runs the full width and it was ending
	# flush against the moulding.
	# Clear of the border, or the rules text sits on the bevel and the card reads
	# as cramped. The frame's border is about 13% of its width.
	sb.set_content_margin_all(13)
	sb.content_margin_left = 17.0
	sb.content_margin_right = 17.0
	return sb


## Mark this card as the current (not yet locked) reward selection.
func set_selected(on: bool) -> void:
	if not on:
		return
	var gold := _tex_frame(FRAME_GOLD)
	add_theme_stylebox_override("normal", gold)
	add_theme_stylebox_override("hover", gold)
	add_theme_stylebox_override("pressed", gold)


# --- Timing minigame (on the card) ----------------------------------------

## Whether this card is currently mid-sweep on the timing minigame. Public
## because the hand row (combat_3d._render_hand) needs to know, from outside,
## whether THIS card is the one a player's thumb is still on — see the
## should_rebuild_hand gate.
func is_timing() -> bool:
	return _timing


## Begin the timing sweep. `hits` sequential windows must all land (Satchel = 3);
## the next tap fires each one. The green zone is anchored (see _build_timing_strip)
## so it sizes itself once the strip is laid out.
func start_timing(hits: int = 1) -> void:
	if _timing:
		return
	_timing = true
	_hits_needed = maxi(1, hits)
	_hits_done = 0
	_worst_quality = Combat.TIMING_PERFECT
	_t = 0.0
	_dir = 1.0
	_elapsed = 0.0
	_update_count()
	var zone := _strip.get_node_or_null("Zone")
	if zone != null:  # relics may have widened the window since setup()
		var bonus_t := zone_bonus_t(zone_bonus)
		(zone as Control).anchor_left = maxf(0.0, ZONE_MIN - bonus_t)
		(zone as Control).anchor_right = minf(1.0, ZONE_MAX + bonus_t)
	_strip.modulate = Color(1, 1, 1)
	_strip.visible = true
	if is_instance_valid(_clock):
		_clock.visible = false  # the strip is the clock now
	set_process(true)


## Right-click asks what a card's words MEAN, without playing it.
##
## Nick, 2026-08-16: "I would like the ability to right click on things like
## keywords... For example, poison. What does poison do?" The inspector already
## answers exactly that — every keyword the card touches, with its definition —
## it was just behind a small "?" that is easy not to notice.
##
## The "?" button stays: CLAUDE.md §5 keeps a tap path for everything, because a
## phone has no right mouse button. This is the accelerator, not the only way in.
func _on_card_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_RIGHT or not mb.pressed:
		return
	accept_event()  # never let a right-click fall through and play the card
	# On a keyword, answer that keyword. Anywhere else on the card, open the
	# inspector — which answers all of them, plus the card itself.
	if _hover_meta.begins_with("kw:"):
		var want := _hover_meta.substr(3)
		for k in _data.get("keywords", []):
			if String((k as Dictionary).get("id", "")) == want:
				keyword_requested.emit(k)
				return
	inspect_requested.emit(_data)


func _on_self_pressed() -> void:
	if _timing:
		_fire()
	else:
		tapped.emit()


## Converts a raw `timing_zone` fraction (HitCircle.zone_bonus's own units —
## 0.12 for a 12% relic) into the sweep bar's t-space (0..1 across the strip).
## HitCircle turns the same fraction into `zone_bonus * 0.35` EXTRA SECONDS of
## forgiveness on each side of the beat; t here advances at SWEEP_SPEED units
## per second (see _process), so the same seconds of forgiveness is
## `zone_bonus * 0.35 * SWEEP_SPEED` in t.
##
## Before this, fire_quality() and _build_timing_strip()/start_timing() added
## the raw fraction straight onto the bar's 0..1 zone bounds with no
## conversion at all, so the exact same relic widened HitCircle's window by a
## few percent but blew the bar's zone open by several times as much — and at
## the combined bonus two shipped relics plus a Wide-enchanted card already
## reach today (Steady Hands 6% + Metronome Shell 12% + Wide 30% = 48%), the
## bar's zone bounds clamped past both ends of the strip and MISS became
## impossible on that face while the circle still carried real risk for the
## identical cards (backlog #86 duty 2 — two faces of one rule silently
## disagreeing on what the rule was).
static func zone_bonus_t(zone_bonus: float) -> float:
	return zone_bonus * 0.35 * SWEEP_SPEED


## Pure grading for one tap of the sweep-bar timing minigame, lifted out of
## _fire() below so a headless test can prove it without building the strip's
## UI. Mirrors HitCircle's own worst-window rule (see the tests beside
## _test_backlog86_hit_circle_chain_quality_is_its_worst_window_not_its_last):
## a tap outside the zone MISSES outright, discarding whatever `worst_quality`
## the chain already earned — a miss ends the chain, it doesn't average into
## it. A tap inside the zone but off the CORE band caps the running worst at
## GOOD; landing in CORE leaves it unchanged. The chain resolves once
## `hits_done` reaches `hits_needed`.
static func fire_quality(t: float, zone_bonus: float, hits_done: int,
		hits_needed: int, worst_quality: int) -> Dictionary:
	var bonus_t := zone_bonus_t(zone_bonus)
	if t < ZONE_MIN - bonus_t or t > ZONE_MAX + bonus_t:
		return {"quality": Combat.TIMING_MISS, "hits_done": hits_done, "resolved": true}
	var worst := worst_quality
	if t < CORE_MIN or t > CORE_MAX:
		worst = mini(worst, Combat.TIMING_GOOD)
	var done := hits_done + 1
	return {"quality": worst, "hits_done": done, "resolved": done >= hits_needed}


## One tap during timing. A miss ends the whole chain (fizzle); a hit either
## advances to the next window or, on the last one, resolves at whatever
## quality the chain earned — the CORE band (already drawn as the bullseye)
## is "perfect", the rest of the zone is "good"; a chain's quality is its
## WORST window, not its last one, so a shaky early hit still costs you.
func _fire() -> void:
	var result := fire_quality(_t, zone_bonus, _hits_done, _hits_needed, _worst_quality)
	_worst_quality = int(result["quality"])
	_hits_done = int(result["hits_done"])
	if result["resolved"]:
		_end_timing(_worst_quality)
		return
	_t = 0.0  # reset the sweep for the next window
	_dir = 1.0
	_elapsed = 0.0  # a fresh clock per window
	_update_count()


func _end_timing(quality: int) -> void:
	_timing = false
	# Only stop ticking if nothing else needs the tick. A foil card that had
	# been timed used to freeze its sheen the moment the window resolved,
	# because this turned _process off wholesale; a 3D window would have frozen
	# the same way.
	if _foil == null and _win == null:
		set_process(false)
	_strip.visible = false
	if is_instance_valid(_clock):
		_clock.visible = true
	timing_resolved.emit(quality)


func _update_count() -> void:
	if _count_lbl == null:
		return
	if _hits_needed > 1:
		_count_lbl.visible = true
		_count_lbl.text = "%d/%d" % [_hits_done, _hits_needed]
	else:
		_count_lbl.visible = false


func _process(delta: float) -> void:
	if _foil != null or _win != null:
		var tilt := _foil_tilt(float(Time.get_ticks_msec()) * 0.001)
		if _foil != null and is_instance_valid(_foil):
			var mat := _foil.material as ShaderMaterial
			if mat != null:
				mat.set_shader_parameter("tilt", tilt)
		# The same tilt drives the window, so on a card that is both foil and
		# 3D the sheen and the parallax move together — two effects out of step
		# read as two effects, not as one card being turned.
		# This card, then the global pin, then the pointer.
		var t := tilt.x
		if absf(force_turn) <= 1.0:
			t = force_turn
		if absf(turn_override) <= 1.0:
			t = turn_override
		_turn_window(t)
	if not _timing:
		return
	_elapsed += delta
	if _elapsed >= WINDOW_SECONDS:  # hesitated too long — the moment is gone
		_end_timing(Combat.TIMING_MISS)
		return
	_t += _dir * SWEEP_SPEED * delta
	if _t >= 1.0:
		_t = 1.0
		_dir = -1.0
	elif _t <= 0.0:
		_t = 0.0
		_dir = 1.0
	_marker.position.x = _t * (_strip.size.x - _marker.size.x)
	# The strip reddens as the window runs out — see the timeout coming.
	var urgency := _elapsed / WINDOW_SECONDS
	_strip.modulate = Color(1.0, 1.0 - 0.45 * urgency, 1.0 - 0.45 * urgency)


func _build_timing_strip() -> Control:
	var strip := Control.new()
	strip.custom_minimum_size = Vector2(0, 20)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.045)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(bg)
	# Success zone: anchored to ZONE_MIN..ZONE_MAX of the strip so it always spans
	# the target band, whatever the strip's laid-out width is. A brighter "perfect"
	# core in the centre makes the aim point obvious.
	var zone := ColorRect.new()
	zone.name = "Zone"
	zone.color = Color(0.33, 0.72, 0.36)
	var bonus_t := zone_bonus_t(zone_bonus)
	zone.anchor_left = maxf(0.0, ZONE_MIN - bonus_t)
	zone.anchor_right = minf(1.0, ZONE_MAX + bonus_t)
	zone.anchor_top = 0.0
	zone.anchor_bottom = 1.0
	zone.offset_left = 0.0
	zone.offset_right = 0.0
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(zone)
	var core := ColorRect.new()  # the bullseye — centre of the green band
	core.color = Color(0.55, 0.95, 0.55)
	core.anchor_left = CORE_MIN
	core.anchor_right = CORE_MAX
	core.anchor_top = 0.0
	core.anchor_bottom = 1.0
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(core)
	_marker = ColorRect.new()
	_marker.color = Color(1.0, 0.96, 0.82)
	_marker.size = Vector2(5, 20)
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(_marker)
	# Chain counter (only shown for multi-window cards like Satchel), pinned left.
	_count_lbl = Label.new()
	_count_lbl.add_theme_font_size_override("font_size", 12)
	_count_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	_count_lbl.anchor_top = 0.0
	_count_lbl.anchor_bottom = 1.0
	_count_lbl.offset_left = 4.0
	_count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_lbl.visible = false
	strip.add_child(_count_lbl)
	return strip


func _on_hover() -> void:
	# Optional accelerator only — cards remain fully usable by tap (§5).
	# A rail card slides out of the column instead of scaling: it's already as
	# wide as the rail, so growing it would just clip on the screen edge.
	if _compact:
		position.x = 8.0
		return
	pivot_offset = size / 2.0
	scale = Vector2(1.06, 1.06)


func _on_unhover() -> void:
	if _compact:
		position.x = 0.0
		return
	scale = Vector2.ONE


func _frame(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(1)
	sb.border_color = border
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(2)
	return sb
