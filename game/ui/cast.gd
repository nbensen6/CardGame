## Which model plays a character.
##
## Your own art wins. If a file named after the character exists — cast/frog.glb
## for the Frog — the game uses it, everywhere, with no code change. Only when
## there isn't one does it fall back to the Kenney stand-in.
##
## That ordering is the point: making art should mean exporting a file, not
## exporting a file AND editing three view scripts to notice it (see
## design/guide/blender-pipeline.md).
##
## A rigged, toon-shaded rebuild (combat_3d.gd's HUNTER_AI_ART, the same
## "<id>_ai.glb beats <id>.glb" rule the fight itself uses) wins over even
## your own plain cast/<id>.glb, so this is the ONE place that decides which
## model a character wears — request #13, 2026-09-24: character select was
## still showing the old primitive Frog after the fight moved on to
## frog_ai.glb, because this function never looked for the "_ai" file at all.
class_name Cast
extends RefCounted

const DIR := "res://assets/3d/cast/"

## The Kenney model standing in for each hunter until you replace it.
const PLACEHOLDER := {
	"frog": "bunny", "vine_weaver": "koala", "mountain_climbers": "deer",
	"goblin_mech": "monkey", "lightbearer": "cat",
}


## Path to the model for a character id: an "_ai" rebuild first, then your
## plain cast/<id>.glb, else the stand-in.
static func model_path(character_id: String) -> String:
	if character_id == "":
		return DIR + String(PLACEHOLDER.get(character_id, "bunny")) + ".glb"
	var ai := DIR + character_id + "_ai.glb"
	if ResourceLoader.exists(ai):
		return ai
	var own := DIR + character_id + ".glb"
	if ResourceLoader.exists(own):
		return own
	return DIR + String(PLACEHOLDER.get(character_id, "bunny")) + ".glb"


## True when this character is wearing art you made rather than a placeholder —
## so tools can say which is which.
static func is_yours(character_id: String) -> bool:
	return character_id != "" and ResourceLoader.exists(DIR + character_id + ".glb")
