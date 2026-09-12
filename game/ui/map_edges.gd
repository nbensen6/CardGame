## Draws the connecting paths between map nodes, behind the node buttons.
##
## Without these you can see an act's shape but not which node a choice leads to,
## so you can't plan a route — which is most of what a roguelike map is for.
## Edges hold direct references to the two node buttons and read their laid-out
## rects at draw time, so the lines stay correct at any window size.
class_name MapEdges
extends Control

const COLOR_OPEN := Color(0.92, 0.78, 0.42, 0.95)  # a step you may take right now
const COLOR_LINK := Color(0.62, 0.55, 0.44, 0.40)  # the rest of the route, for planning
const WIDTH_OPEN := 3.0
const WIDTH_LINK := 2.0

# [{from: Control (lower row), to: Control (upper row), open: bool}, ...]
var edges: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Node buttons move when the panel lays out or scrolls, and Controls get no
## layout-changed signal we can rely on here, so refresh while the map is up.
func _process(_delta: float) -> void:
	if visible and not edges.is_empty():
		queue_redraw()


func _draw() -> void:
	# open edges last so they sit on top of the dim ones where paths converge
	for pass_open in [false, true]:
		for e in edges:
			if bool(e.get("open", false)) != pass_open:
				continue
			var lower: Control = e.get("from")
			var upper: Control = e.get("to")
			if not is_instance_valid(lower) or not is_instance_valid(upper):
				continue
			var a := _edge_point(lower, true)   # top of the node you're leaving
			var b := _edge_point(upper, false)  # bottom of the node you're heading to
			draw_line(a, b, COLOR_OPEN if pass_open else COLOR_LINK,
				WIDTH_OPEN if pass_open else WIDTH_LINK, true)


## Centre of a node button's top (or bottom) edge, in this overlay's space.
## Controls have no to_local(), and UI here is unrotated, so subtracting our own
## global origin is the conversion.
func _edge_point(node: Control, top: bool) -> Vector2:
	return edge_point_of(node.get_global_rect(), top, global_position)


## The pure half of _edge_point() above, lifted out (backlog #86 duty 3) so the
## anchor math a route's whole legibility depends on -- "leaving from the top
## of one node, arriving at the bottom of the next" -- can be proven headless,
## with no Control, no tree, and no viewport, the same way overworld_3d's own
## screen-space geometry was already pulled out for testing.
static func edge_point_of(rect: Rect2, top: bool, origin: Vector2) -> Vector2:
	var p := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + (0.0 if top else rect.size.y))
	return p - origin
