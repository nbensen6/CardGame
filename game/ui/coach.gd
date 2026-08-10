## Contextual onboarding. Instead of a wall of text up front, each rule of the
## game announces itself at the exact moment it first matters, then never again.
##
## Pure read-only: it looks at the same snapshot the view already has and returns
## the highest-priority hint the player hasn't dismissed yet. No game state, no
## rules — the view decides what to do with the answer.
class_name Coach
extends RefCounted

## Ordered most-urgent first: the first matching, unseen hint is the one shown.
## Each entry is {id, text, when: Callable(ctx) -> bool}.
static func hint_for(shared: Dictionary, private: Dictionary, me: int) -> Dictionary:
	var phase := String(shared.get("phase", ""))
	var players: Array = shared.get("players", [])
	var mine: Dictionary = players[me] if me >= 0 and me < players.size() else {}
	var boss: Dictionary = shared.get("boss", {})
	var hand: Array = private.get("hand", [])

	var candidates: Array = []
	match phase:
		"map":
			candidates.append({"id": "map",
				"text": "Pick your route. Elites pay relics; campfires heal or sharpen your deck."})
		"event":
			candidates.append({"id": "event",
				"text": "Every choice says what it costs before you take it."})
		"shop":
			candidates.append({"id": "shop",
				"text": "One shared purse. Removing a card often beats buying one."})
		"campfire":
			candidates.append({"id": "campfire",
				"text": "Heal, or spend the hour on your deck — cutting a weak card sharpens every draw."})
		"reward":
			candidates.append({"id": "reward",
				"text": "You can Skip. A lean deck draws its best cards more often."})
		"combat":
			var height := int(boss.get("weak_point_height", 0))
			var fh := int(mine.get("foothold", 0))
			# most urgent first — a ticking grip timer beats every other lesson
			if not bool(mine.get("secure", true)):
				candidates.append({"id": "climbing",
					"text": "Your grip is draining. Reach the next ledge before it empties."})
			if bool(mine.get("reached", false)):
				candidates.append({"id": "at_sigil",
					"text": "Full damage here — but deal too much and it bucks you off."})
			if height > 0 and fh <= 0:
				candidates.append({"id": "armored",
					"text": "Armoured below the sigil. Climb to the glow to really hurt it."})
			if _hand_has(hand, "timed"):
				candidates.append({"id": "timed",
					"text": "Timed card: tap to swing, then tap again inside the green band."})
			var ally: Dictionary = players[1 - me] if players.size() == 2 and me in [0, 1] else {}
			if height > 0 and fh > 0 and int(ally.get("foothold", 0)) <= 0:
				candidates.append({"id": "ally_stuck",
					"text": "Your ally is stuck on the ground. Some cards lift them."})
			candidates.append({"id": "play_card",
				"text": "Tap a card to play it. ✦ is energy. End Turn when you're done."})

	for c in candidates:
		if not Progress.hint_seen(String(c["id"])):
			return c
	return {}


static func _hand_has(hand: Array, flag: String) -> bool:
	for c in hand:
		if bool((c as Dictionary).get(flag, false)):
			return true
	return false
