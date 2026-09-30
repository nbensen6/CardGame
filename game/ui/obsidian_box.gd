@tool
extends StyleBox
## Carved obsidian: the HUD's one panel material (see Combat3D.obsidian_style).
##
## StyleBoxFlat has one border colour, so it can draw a rim but never a bevel.
## This wraps one and draws the rest on top: a faint glassy sheen over the top
## of the fill, a lit line just inside the top edge and a shaded line just
## inside the bottom lip. Light from above, like the scene's key light.

var flat: StyleBoxFlat


func _init(base: StyleBoxFlat = null) -> void:
	flat = base if base != null else StyleBoxFlat.new()
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		set_content_margin(side, flat.get_content_margin(side))


func _draw(ci: RID, rect: Rect2) -> void:
	flat.draw(ci, rect)
	if not flat.draw_center:
		return
	var b := float(flat.border_width_top)
	var r := float(flat.corner_radius_top_left)
	var inner := Rect2(rect.position + Vector2(b, b),
		rect.size - Vector2(b * 2.0, b + flat.border_width_bottom))
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return
	var sheen := StyleBoxFlat.new()
	sheen.bg_color = Color(1, 0.92, 0.85, 0.11)
	sheen.corner_radius_top_left = int(maxf(r - b, 0.0))
	sheen.corner_radius_top_right = sheen.corner_radius_top_left
	sheen.anti_aliasing = true
	sheen.draw(ci, Rect2(inner.position, Vector2(inner.size.x, inner.size.y * 0.46)))
	var span := maxf(inner.size.x - r * 2.0, 0.0)
	RenderingServer.canvas_item_add_rect(ci,
		Rect2(inner.position + Vector2(r, 0), Vector2(span, 1.0)), Color(1, 0.86, 0.7, 0.6))
	RenderingServer.canvas_item_add_rect(ci,
		Rect2(Vector2(inner.position.x + r, inner.end.y - 2.0), Vector2(span, 2.0)), Color(0, 0, 0, 0.6))
