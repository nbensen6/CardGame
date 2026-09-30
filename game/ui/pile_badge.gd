extends Control
## A card pile as Slay the Spire draws it: a small stack of card backs with its
## count in a disc on the corner (queue, "One HUD style", Nick 2026-09-30).
## Presentation only; the count comes from the snapshot through set_count().

const BACK := Color(0.30, 0.22, 0.14)
const BACK_EDGE := Color(0.05, 0.03, 0.02, 0.95)
const COUNT_DISC := Color(0.08, 0.07, 0.07, 0.95)

var count := 0
var tint := Color(0.95, 0.78, 0.42)
var label := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


func set_count(n: int) -> void:
	if n != count:
		count = n
		queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var card := Vector2(size.x * 0.62, size.y * 0.72)
	var base := Vector2(size.x * 0.08, size.y * 0.06)
	# Three backs, each nudged, so it reads as a pile and not one card.
	for k in range(3):
		var r := Rect2(base + Vector2(k * 2.0, k * 2.5), card)
		draw_rect(r.grow(1.5), BACK_EDGE)
		draw_rect(r, BACK.lerp(tint, 0.18 * k))
		draw_rect(r.grow(-3.0), Color(tint, 0.55), false, 1.0)
	var c := Vector2(size.x * 0.74, size.y * 0.74)
	var rad := size.x * 0.26
	draw_circle(c, rad + 2.0, BACK_EDGE)
	draw_circle(c, rad, COUNT_DISC)
	var txt := str(count)
	var fs := 13
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, c + Vector2(-tw * 0.5, fs * 0.36), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.96, 0.9))
	if label != "":
		var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		draw_string(font, Vector2((size.x - lw) * 0.5, size.y + 10.0), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.76, 0.68))
