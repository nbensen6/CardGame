## Which model plays a character.
##
## Your own art wins. If a file named after the character exists — cast/frog.glb
## for the Frog — the game uses it, everywhere, with no code change. Only when
## there isn't one does it fall back to the Kenney stand-in.
##
## That ordering is the point: making art should mean exporting a file, not
## exporting a file AND editing three view scripts to notice it (see
## design/blender-pipeline.md).
class_name Cast
extends RefCounted

const DIR := "res://assets/3d/cast/"

## The Kenney model standing in for each hunter until you replace it.
const PLACEHOLDER := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey", "lightbearer": "cat",
}


## Path to the model for a character id. Yours if it exists, else the stand-in.
static func model_path(character_id: String) -> String:
	var own := DIR + character_id + ".glb"
	if character_id != "" and ResourceLoader.exists(own):
		return own
	return DIR + String(PLACEHOLDER.get(character_id, "bunny")) + ".glb"


## True when this character is wearing art you made rather than a placeholder —
## so tools can say which is which.
static func is_yours(character_id: String) -> bool:
	return character_id != "" and ResourceLoader.exists(DIR + character_id + ".glb")
