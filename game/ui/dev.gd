## Dev switches for looking at things that are RARE ON PURPOSE.
##
## Nick, 2026-09-01: "how do i dev test to see these cards in game?"
##
## Fair question, and the answer was "you mostly can't". A borderless card rolls
## at 4-13%, a foil at 6-14%, and both are decided when a reward is TAKEN — so
## seeing one meant playing until the dice agreed, and seeing a borderless foil
## of a specific card meant playing for a very long time. The screenshot harness
## could force them, but a screenshot cannot be tilted, and tilt is half of what
## both effects are.
##
## So the same flags the harness has, on the real game:
##
##   Godot.exe --path game -- borderless foil hand=crescendo,leap
##
## or, more simply, tools\dev.cmd with the same words. Everything after `--` is
## a user arg; the flag names match tools/screenshot.gd deliberately, so a thing
## you photographed and a thing you played are addressed the same way.
##
## And F9 in a fight cycles the treatment live, which is the one thing a launch
## flag cannot do: put the framed and the borderless version of the same card
## side by side in your memory a second apart.
##
## A static class rather than an autoload, matching Screen / Session / Music: a
## custom SceneTree (which is what the screenshot harness is) never instantiates
## autoloads, so an autoload here would exist in the game and be missing from
## the one tool that verifies it.
##
## PRESENTATION ONLY, plus a hand. Nothing here changes a rule, a number or a
## seed — a run played with these on is the same run, wearing different clothes.
class_name Dev
extends RefCounted

## Card ids to deal instead of whatever the shuffle produced, or empty.
static var hand: PackedStringArray = []
## True when any flag was given at all. Views use it to decide whether to say
## so on screen — a build that silently forces every card foil is a build that
## will eventually be screenshotted as if it were the game.
static var on := false

static var _booted := false


## Read the command line, once. Safe to call from anywhere, as often as you
## like; the second call does nothing.
static func boot() -> void:
	if _booted:
		return
	_booted = true
	for a in OS.get_cmdline_user_args():
		if a == "borderless":
			CardView.force_borderless = true
			on = true
		elif a == "foil":
			CardView.force_foil = true
			on = true
		elif a.begins_with("turn="):
			CardView.force_turn = float(a.substr(5))
			on = true
		elif a.begins_with("hand="):
			hand = a.substr(5).split(",", false)
			on = true
	if on:
		print("DEV %s%s%s" % [
			"borderless " if CardView.force_borderless else "",
			"foil " if CardView.force_foil else "",
			("hand=" + ", ".join(hand)) if not hand.is_empty() else ""])


## The four treatments, in the order F9 walks them. Named so the on-screen
## label can say which one you are looking at rather than making you infer it.
const CYCLE := ["framed", "borderless", "borderless foil", "foil"]


## Advance the treatment and return its name. The caller re-renders the hand.
##
## Live rather than launch-only because the interesting question is never "does
## the borderless one look good" — it is "does it look better than the framed
## one", and that is a comparison you can only make by flipping between them
## quickly on the same card.
static func cycle() -> String:
	var at := CYCLE.find(_name_now())
	var next: String = CYCLE[(at + 1) % CYCLE.size()]
	CardView.force_borderless = next.begins_with("borderless")
	CardView.force_foil = next.ends_with("foil")
	on = true
	return next


static func _name_now() -> String:
	if CardView.force_borderless:
		return "borderless foil" if CardView.force_foil else "borderless"
	return "foil" if CardView.force_foil else "framed"
