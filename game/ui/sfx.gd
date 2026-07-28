## Sound-effect hook (build step 5). Placeholder: NO audio files yet — the game
## is silent, but every place a sound should play already calls Sfx.play(event),
## so adding audio later is a one-file change (load streams here, keyed by event).
## Keeping this stub avoids sprinkling audio wiring through the views later.
class_name Sfx
extends RefCounted

## Events currently emitted: "card", "attack", "block", "end_turn", "reward",
## "win", "lose". No-op until real AudioStreams are wired in.
static func play(_event: String) -> void:
	pass
