extends Control
## A creature's health bar, Slay the Spire style (queue, "One HUD style",
## Nick 2026-09-30: "reference how slay the spire ii displays information").
##
## The number lives INSIDE the bar, the bar lives UNDER the creature, and Block
## is a blue shield clipped onto the bar's left end with its own number, the
## bar itself turning blue while any Block stands. No panel, no frame around it:
## the thing it describes is the frame. Presentation only; values come from
## the snapshot through set_values().

const FILL := Color(0.80, 0.11, 0.10)
const FILL_BLOCKED := Color(0.22, 0.52, 0.86)
const TRACK := Color(0.16, 0.04, 0.04, 0.92)
const EDGE := Color(0.02, 0.01, 0.01, 0.95)
const SHIELD := Color(0.30, 0.62, 0.95)
const BAR_H := 11.0
## TARGET.png's bar under the Frog, sampled at the 720 square (builder
## 2026-10-09, "HP bar under the Frog"): a dark maroon rim, not black; a
## deeper red with a two-row pink lit band on top and a lighter last row; slim
## numerals with a thin maroon outline.
const RIM := Color(0.17, 0.02, 0.04, 0.95)
const BAR_FILL := Color(0.78, 0.13, 0.12)
const BAR_LIT := Color(0.85, 0.44, 0.41)
const BAR_LIT2 := Color(0.80, 0.29, 0.27)
const BAR_FOOT := Color(0.66, 0.20, 0.20)
const TEXT_OUTLINE := 3

var hp := 0
var max_hp := 1
var block := 0
var font_size := 10


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_values(hp_: int, max_hp_: int, block_: int = 0) -> void:
	if hp_ == hp and max_hp_ == max_hp and block_ == block:
		return
	hp = hp_
	max_hp = maxi(max_hp_, 1)
	block = block_
	queue_redraw()


## How much of the bar is full, 0..1. Pure so the test can hold it.
static func fill_frac(hp_: int, max_hp_: int) -> float:
	return clampf(float(hp_) / float(maxi(max_hp_, 1)), 0.0, 1.0)


## "42/42", Slay the Spire's own format: no "HP", no spaces.
static func hp_text(hp_: int, max_hp_: int) -> String:
	return "%d/%d" % [maxi(hp_, 0), max_hp_]


func _draw() -> void:
	var font := get_theme_default_font()
	var y0 := (size.y - BAR_H) * 0.5
	var bar := Rect2(0.0, y0, size.x, BAR_H)
	var rim := StyleBoxFlat.new()
	rim.bg_color = RIM
	rim.set_corner_radius_all(2)
	draw_style_box(rim, bar.grow(1.0))
	draw_rect(bar, TRACK)
	var f := fill_frac(hp, max_hp)
	if f > 0.0:
		var blocked := block > 0
		var fill_c := FILL_BLOCKED if blocked else BAR_FILL
		var w := bar.size.x * f
		draw_rect(Rect2(bar.position, Vector2(w, BAR_H)), fill_c)
		# The lit band along the top and the lighter last row: a tube.
		draw_rect(Rect2(bar.position, Vector2(w, 2.0)), FILL_BLOCKED.lightened(0.35) if blocked else BAR_LIT)
		draw_rect(Rect2(bar.position + Vector2(0, 2.0), Vector2(w, 1.0)), FILL_BLOCKED.lightened(0.2) if blocked else BAR_LIT2)
		draw_rect(Rect2(bar.position + Vector2(0, BAR_H - 1.0), Vector2(w, 1.0)), FILL_BLOCKED.lightened(0.15) if blocked else BAR_FOOT)
	var txt := hp_text(hp, max_hp)
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var base := Vector2((size.x - tw) * 0.5, y0 + BAR_H * 0.5 + font_size * 0.36)
	draw_string_outline(font, base, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_OUTLINE, RIM)
	draw_string(font, base, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 0.97, 0.92))
	if block > 0:
		_draw_shield(Vector2(0.0, size.y * 0.5), block, font)


## The Block badge: a heater shield straddling the bar's left end.
func _draw_shield(at: Vector2, n: int, font: Font) -> void:
	var r := 13.0
	var pts := PackedVector2Array([
		at + Vector2(-r, -r), at + Vector2(r, -r), at + Vector2(r, 0.1 * r),
		at + Vector2(0.0, r * 1.15), at + Vector2(-r, 0.1 * r)])
	var edge := PackedVector2Array()
	for p in pts:
		edge.append(at + (p - at) * 1.18)
	draw_colored_polygon(edge, EDGE)
	draw_colored_polygon(pts, SHIELD)
	var txt := str(n)
	var fs := font_size + 1
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := at + Vector2(-tw * 0.5, fs * 0.3)
	draw_string_outline(font, base, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, EDGE)
	draw_string(font, base, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
