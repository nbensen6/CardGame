## The run in 3D — one router that keeps the right client on screen.
##
## The two 3D scenes were each proven on their own; this is what makes them a
## loop. It watches the authoritative `phase` and swaps the client that owns it:
##
##   map    -> views/overworld_3d.tscn   (walk the region to choose your route)
##   combat -> views/combat_3d.tscn      (climb the beast, play cards)
##   reward -> views/location_3d.tscn    (standing over what you just felled)
##   won/lost -> the same scene
##   else   -> views/combat_view.tscn    (the 2D client still owns event,
##                                        campfire and shop)
##
## The fallback is deliberate and temporary: those phases have no 3D staging yet,
## and a 2D screen for them is far better than blocking the loop on art that
## doesn't exist. `design/3d-pivot.md` retires the 2D client only at parity.
##
## Every child scene already builds itself from the snapshot on `_ready`, so a
## swap needs no handover — the router owns nothing but which scene is current.
extends Node

const SCENES := {
	"map": "res://views/overworld_3d.tscn",
	"combat": "res://views/combat_3d.tscn",
	"reward": "res://views/location_3d.tscn",
	"won": "res://views/location_3d.tscn",
	"lost": "res://views/location_3d.tscn",
}
const FALLBACK_2D := "res://views/combat_view.tscn"

var _client: GameClient
var _current := ""   # the scene path on screen, so identical phases don't churn
var _view: Node


func _ready() -> void:
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _sync())
	_sync()


func _sync() -> void:
	var phase := String(_client.shared.get("phase", ""))
	if phase.is_empty():
		return
	var want: String = String(SCENES.get(phase, FALLBACK_2D))
	if want == _current:
		return
	_current = want
	if _view != null:
		# drop it out of the tree NOW, not at the end of the frame — otherwise
		# both clients render, and both react to the same snapshot, for a frame
		remove_child(_view)
		_view.queue_free()
	var scene: PackedScene = load(want)
	if scene == null:
		push_error("game_3d: could not load %s" % want)
		return
	_view = scene.instantiate()
	add_child(_view)
