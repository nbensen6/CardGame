## The run in 3D — one router that keeps the right client on screen.
##
## The two 3D scenes were each proven on their own; this is what makes them a
## loop. It watches the authoritative `phase` and swaps the client that owns it:
##
##   map    -> views/overworld_3d.tscn   (walk the region to choose your route)
##   combat -> views/combat_3d.tscn      (climb the beast, play cards)
##   reward -> views/location_3d.tscn    (standing over what you just felled)
##   select, event, campfire, shop, won, lost -> the same scene
##
## The table is the whole contract: every phase /core can report has a 3D screen,
## so there is no 2D fallback any more. A phase this table doesn't know is a bug
## in one of the two, not a case to paper over — it holds the current screen and
## shouts, rather than swapping to something arbitrary mid-run.
##
## Every child scene already builds itself from the snapshot on `_ready`, so a
## swap needs no handover — the router owns nothing but which scene is current.
extends Node

const SCENES := {
	"select": "res://views/location_3d.tscn",
	"map": "res://views/overworld_3d.tscn",
	"combat": "res://views/combat_3d.tscn",
	"reward": "res://views/location_3d.tscn",
	"event": "res://views/location_3d.tscn",
	"campfire": "res://views/location_3d.tscn",
	"shop": "res://views/location_3d.tscn",
	"won": "res://views/location_3d.tscn",
	"lost": "res://views/location_3d.tscn",
}

var _client: GameClient
var _current := ""   # the scene path on screen, so identical phases don't churn
var _view: Node


func _ready() -> void:
	Screen.fit(self)   # a phone gets a physically larger interface
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _sync())
	_sync()


func _sync() -> void:
	var phase := String(_client.shared.get("phase", ""))
	if phase.is_empty():
		return
	if not SCENES.has(phase):
		push_error("game_3d: no 3D client for phase '%s' — staying on %s" % [phase, _current])
		return
	var want: String = String(SCENES[phase])
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
