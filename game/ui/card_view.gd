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
const LIVE_COLOR := "7fd45c"
## The half of a timed card you only get by landing it.
const NAILED_COLOR := "ffd35c"
## A rules term with a tooltip behind it. Never used decoratively.
const KEYWORD_COLOR := "f0b45a"

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

## Force every card foil, for looking at it. Set by tools/screenshot.gd's
## `foil` flag — a foil is a rare pull by design, so without this there is no
## reliable way to get one on screen to judge.
static var force_foil := false


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
	add_child(_foil)
	set_process(true)


## What stands in for turning the card in your hand.
##
## The tutorial drives its holographic material off Layer Weight -> Facing, the
## angle between the surface and the viewer. A 2D card has no such angle, so:
## the pointer on a desktop, the accelerometer on a phone, and a slow drift
## under both so a foil sitting untouched still breathes.
func _foil_tilt(t: float) -> Vector2:
	var drift := Vector2(sin(t * 0.6), cos(t * 0.43)) * 0.35
	var accel := Input.get_accelerometer()
	if accel.length() > 0.1:
		return drift + Vector2(accel.x, accel.z) * 0.22
	var here := get_global_rect()
	if here.size.x <= 0.0:
		return drift
	var rel := (get_global_mouse_position() - here.get_center()) / maxf(here.size.y, 1.0)
	return drift + rel.limit_length(1.5) * 0.5


func setup(data: Dictionary, playable: bool = true, compact: bool = false) -> void:
	# Character/relic cards (no cost pip) carry portraits + longer text — taller frame.
	_compact = compact
	_data = data
	if compact:
		custom_minimum_size = Vector2(0, RAIL_HEIGHT)
	else:
		# 148 wide, not 164: with the energy orb beside the hand, five cards at the
		# old width overflowed and put a scrollbar under the most-used control on
		# the screen.
		#
		# A handheld runs the interface at fewer logical pixels so everything is
		# physically bigger (see ui/screen.gd), which means the SAME card is a much
		# larger share of the screen — at 224 tall the hand ate 40% of a phone and
		# climbed over the beast. Smaller here keeps the same physical size it has
		# on a desktop while giving the fight back its room.
		var big := bool(data.get("no_cost", false))
		if Screen.is_handheld():
			custom_minimum_size = Vector2(148, 222) if big else Vector2(124, 186)
		else:
			custom_minimum_size = Vector2(176, 264) if big else Vector2(148, 224)
	disabled = not playable
	text = ""
	if not mouse_entered.is_connected(_on_hover):
		mouse_entered.connect(_on_hover)
		mouse_exited.connect(_on_unhover)
	_apply_frame()
	for child in get_children():
		child.queue_free()

	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := 6 if compact else 10
	for side in ["left", "top", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, margin)
	add_child(pad)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6 if not compact else 3)
	pad.add_child(box)

	if compact:
		box.add_child(_rail_row(data))
	else:
		box.add_child(_rarity_pips(data))
		box.add_child(_header(String(data.get("name", "")), int(data.get("cost", 0)), bool(data.get("no_cost", false))))
		box.add_child(_art(String(data.get("icon", "")), String(data.get("portrait", ""))))
		box.add_child(_rich_body(data, 12, 74))

	_strip = _build_timing_strip()  # hidden until start_timing()
	box.add_child(_strip)
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
	row.add_child(cost)

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
## The word a keyword actually WEARS in prose. Mostly the keyword's own name, but
## Height is written "climb" everywhere a card talks about it, so searching for
## "Height" would find nothing. Timed has no word at all any more — the clock
## badge says it — so it is deliberately absent.
const KEYWORD_WORDS := {
	"height": ["Climb", "climb", "climbs", "Height"],
	"player_block": ["Block"], "poison": ["Poison"], "expose": ["Expose"],
	"rhythm": ["Rhythm"], "strength": ["Strength"], "burn": ["Burn"],
	"taunt": ["Taunt"],
}


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

	var dmg := int(pv.get("damage", 0))
	if dmg > 0:
		var n := int(fx.get("hits", 1))
		var times := "" if n <= 1 else (" twice" if n == 2 else " %d times" % n)
		out.append("Deal %s damage%s." % [_num(int(miss.get("damage", 0)), dmg,
			int(base.get("damage", dmg)), rich), times])

	# Both-hunters effects merge into one line. "Gain 2 Block. Ally gains 2 Block."
	# is the same fact typed twice; "All players gain 2 Block" is the card.
	var blk := int(pv.get("block", 0))
	var ally_blk := int(pv.get("ally_block", 0))
	var blk_n := _num(int(miss.get("block", 0)), blk, int(base.get("block", blk)), rich)
	if blk > 0 and blk == ally_blk:
		out.append("All players gain %s %s." % [blk_n, _kw("Block", "player_block", kw, rich)])
	else:
		if blk > 0:
			out.append("Gain %s %s." % [blk_n, _kw("Block", "player_block", kw, rich)])
		if ally_blk > 0:
			out.append("Ally gains %s %s." % [_num(int(miss.get("ally_block", 0)), ally_blk,
				int(base.get("ally_block", ally_blk)), rich), _kw("Block", "player_block", kw, rich)])

	var climb := int(pv.get("grip", 0))
	var ally_climb := int(pv.get("ally_grip", 0))
	var climb_n := _num(int(miss.get("grip", 0)), climb, int(base.get("grip", climb)), rich)
	if climb > 0 and climb == ally_climb:
		out.append("All players %s %s." % [_kw("climb", "height", kw, rich), climb_n])
	else:
		if climb > 0:
			out.append("%s %s." % [_kw("Climb", "height", kw, rich), climb_n])
		if ally_climb > 0:
			out.append("Ally %ss %d." % [_kw("climb", "height", kw, rich), ally_climb])

	if int(fx.get("wound", 0)) > 0:
		out.append("%s %d." % [_kw("Poison", "poison", kw, rich), int(fx["wound"])])
	if int(fx.get("vulnerable", 0)) > 0:
		out.append("%s %d." % [_kw("Expose", "expose", kw, rich), int(fx["vulnerable"])])
	if int(fx.get("strength", 0)) > 0:
		out.append("%s %d." % [_kw("Strength", "strength", kw, rich), int(fx["strength"])])
	if int(fx.get("rhythm", 0)) > 0:
		out.append("%s %d." % [_kw("Rhythm", "rhythm", kw, rich), int(fx["rhythm"])])
	if int(fx.get("draw", 0)) > 0:
		out.append("Draw %d." % int(fx["draw"]))
	if bool(fx.get("taunt", false)):
		out.append("%s." % _kw("Taunt", "taunt", kw, rich))
	if int(fx.get("pull_ally", 0)) > 0:
		out.append("Pull your ally up to you.")
	if int(fx.get("sac_ally_grip", 0)) > 0:
		out.append("%s a card: ally climbs %d." % [_kw("Burn", "burn", kw, rich),
			int(fx["sac_ally_grip"])])
	elif bool(fx.get("exhaust_pick", false)):
		out.append("%s a card%s." % [_kw("Burn", "burn", kw, rich),
			"" if not bool(fx.get("cheapen_pick", false)) else " to cheapen another"])
	if String(fx.get("create", "")) != "":
		out.append("Build a tool into your hand.")
	if String(fx.get("prepare", "")) != "":
		out.append("Primed for next turn.")
	if bool(fx.get("meld", false)):
		out.append("Fuse two cards into one that costs 1 less.")

	if out.is_empty():
		return String(data.get("text", ""))
	# No "Time it!" prefix: the clock badge in the corner says the card is timed,
	# and it says it in the same place on every card instead of eating the first
	# three words of the description (Nick, 2026-08-16).
	return " ".join(out)


## The card's one description, as rich text so a single number or keyword can be
## coloured. A plain Label can only tint the whole line, which is why modified values
## and keyword terms were invisible before.
func _rich_body(data: Dictionary, size: int, height: int) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.text = face_text(data, true)
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
		for word in KEYWORD_WORDS.get(id, []):
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
			return "[url=kw:%s][u][color=#%s]%s[/color][/u][/url]" % [id, KEYWORD_COLOR, word]
	return word


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


func _art(icon: String, portrait: String = "") -> Control:
	var tex := TextureRect.new()
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Fixed, modest art size — the icon is an accent, not the card's focus (Nick).
	# Portraits (character select) keep a larger pane.
	tex.custom_minimum_size = Vector2(0, 76 if portrait != "" else 42)
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # a big PNG must not force the card taller
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if portrait != "" and ResourceLoader.exists(portrait):
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


const FRAME_NORMAL := preload("res://assets/ui/card_normal.png")
const FRAME_HOVER := preload("res://assets/ui/card_hover.png")
const FRAME_PRESSED := preload("res://assets/ui/card_pressed.png")
const FRAME_DISABLED := preload("res://assets/ui/card_disabled.png")
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
		gem.custom_minimum_size = Vector2(4, 4)
		gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gem.pivot_offset = Vector2(2, 2)
		gem.rotation = PI * 0.25          # a diamond reads as a gem; a square reads as a bug
		row.add_child(gem)
	return row


func _apply_frame() -> void:
	var tint: Color = _rarity_of(_data)["tint"]
	add_theme_stylebox_override("normal", _tex_frame(FRAME_NORMAL, tint))
	add_theme_stylebox_override("hover", _tex_frame(FRAME_HOVER, tint))
	add_theme_stylebox_override("pressed", _tex_frame(FRAME_PRESSED, tint))
	add_theme_stylebox_override("disabled", _tex_frame(FRAME_DISABLED))


## Ornate 9-slice card frame (baked from Kenney Fantasy UI Borders).
func _tex_frame(tex: Texture2D, tint: Color = Color.WHITE) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.modulate_color = tint
	sb.set_texture_margin_all(14)  # keep the corner ornaments un-stretched
	sb.set_content_margin_all(8)
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
		(zone as Control).anchor_left = maxf(0.0, ZONE_MIN - zone_bonus)
		(zone as Control).anchor_right = minf(1.0, ZONE_MAX + zone_bonus)
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


## One tap during timing. A miss ends the whole chain (fizzle); a hit either
## advances to the next window or, on the last one, resolves at whatever
## quality the chain earned — the CORE band (already drawn as the bullseye)
## is "perfect", the rest of the zone is "good"; a chain's quality is its
## WORST window, not its last one, so a shaky early hit still costs you.
func _fire() -> void:
	if _t < ZONE_MIN - zone_bonus or _t > ZONE_MAX + zone_bonus:
		_end_timing(Combat.TIMING_MISS)
		return
	if _t < CORE_MIN or _t > CORE_MAX:
		_worst_quality = mini(_worst_quality, Combat.TIMING_GOOD)
	_hits_done += 1
	if _hits_done >= _hits_needed:
		_end_timing(_worst_quality)
		return
	_t = 0.0  # reset the sweep for the next window
	_dir = 1.0
	_elapsed = 0.0  # a fresh clock per window
	_update_count()


func _end_timing(quality: int) -> void:
	_timing = false
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
	if _foil != null and is_instance_valid(_foil):
		var mat := _foil.material as ShaderMaterial
		if mat != null:
			mat.set_shader_parameter("tilt",
				_foil_tilt(float(Time.get_ticks_msec()) * 0.001))
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
	zone.anchor_left = maxf(0.0, ZONE_MIN - zone_bonus)
	zone.anchor_right = minf(1.0, ZONE_MAX + zone_bonus)
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
