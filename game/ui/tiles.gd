## Which model draws a map tile.
##
## Same rule as ui/cast.gd, and for the same reason: your own art wins. If
## `hexown/<name>.glb` exists the map uses it, and only when it doesn't does it
## fall back to the Kenney tile of that name.
##
## That ordering is what lets the overworld be replaced one tile at a time
## instead of in one commit that either works or leaves the map full of holes —
## and it keeps the Kenney set around as a reference rather than deleting it.
class_name Tiles
extends RefCounted

const OWN := "res://assets/3d/hexown/"
const KENNEY := "res://assets/3d/hex/"


## Path to the model for a tile or landmark name. Ours if we made one.
static func path(name: String) -> String:
	var own := OWN + name + ".glb"
	return own if ResourceLoader.exists(own) else KENNEY + name + ".glb"


## True when this tile is wearing art we made, so tools can say which is which.
static func is_ours(name: String) -> bool:
	return ResourceLoader.exists(OWN + name + ".glb")
