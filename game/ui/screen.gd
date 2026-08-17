## Fits the UI to the screen it is actually running on.
##
## The HUD is authored against 1280x720. A phone is a very different shape and,
## more importantly, a very different SIZE: at 720 logical pixels of height the
## 12px rules text on a card works out to about a millimetre tall on a handset,
## which is unreadable no matter how correct the layout is.
##
## The lever is the logical viewport, not the font table. Asking for FEWER
## logical pixels makes every pixel physically bigger, so text, buttons, cards and
## touch targets all grow together and nothing has to be re-laid-out. One number
## moves the whole interface.
##
## Presentation only — /core never learns the screen exists (CLAUDE.md §2).
##
## A static class rather than an autoload, matching Music / Sfx / Session: the
## screenshot harness replaces the main loop, and a custom SceneTree never
## instantiates autoloads, so an autoload here would exist in the game and be
## missing from the one tool that verifies it.
class_name Screen
extends RefCounted

## Logical height the interface is designed against.
const DESKTOP_HEIGHT := 720.0
## Logical height on a handheld. Lower = a physically larger interface and fewer
## things on screen at once; this is the one knob to turn if the phone build
## reads too small or too cramped.
const HANDHELD_HEIGHT := 560.0

## Tools force this on to shoot the phone layout from a desktop.
static var force_handheld := false


## True on a real handheld, or when a tool has asked to pretend.
static func is_handheld() -> bool:
	return force_handheld or OS.has_feature("mobile")


## Called by every root scene as it opens. Idempotent, and cheap enough that
## re-applying on each scene change is simpler than tracking window resizes.
static func fit(node: Node) -> void:
	var w: Window = node.get_window()
	if w == null:
		return
	w.content_scale_factor = (DESKTOP_HEIGHT / HANDHELD_HEIGHT) if is_handheld() else 1.0
