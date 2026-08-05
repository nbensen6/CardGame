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
				"text": "Choose your route. Elites and Titans pay relics; campfires heal you or sharpen your deck. Look ahead — the lines show where each path leads."})
		"event":
			candidates.append({"id": "event",
				"text": "Wayside choices have real stakes, and each button says exactly what it costs or gives."})
		"shop":
			candidates.append({"id": "shop",
				"text": "One purse between you — gold is shared. Removing a card is often worth more than buying one."})
		"campfire":
			candidates.append({"id": "campfire",
				"text": "Rest to heal — or spend the hour on your deck. Removing a weak card makes you draw your best ones more often."})
		"reward":
			candidates.append({"id": "reward",
				"text": "You can Skip a reward. A lean deck is often stronger than a big one."})
		"combat":
			var height := int(boss.get("weak_point_height", 0))
			var fh := int(mine.get("foothold", 0))
			# most urgent first — a ticking grip timer beats every other lesson
			if not bool(mine.get("secure", true)):
				candidates.append({"id": "climbing",
					"text": "You're between holds and your grip is draining. Play another climb card to reach the next ledge — or you'll fall."})
			if bool(mine.get("reached", false)):
				candidates.append({"id": "at_sigil",
					"text": "You're at the weak point. Strikes land in full here — but deal too much and the beast will buck you off."})
			if height > 0 and fh <= 0:
				candidates.append({"id": "armored",
					"text": "Below the weak point its hide is armoured — your hits barely chip it. Climb to the glowing sigil to do real damage."})
			if _hand_has(hand, "timed"):
				candidates.append({"id": "timed",
					"text": "Timed card: tap once to start the swing, then tap again inside the green band. Miss and the card is wasted."})
			var ally: Dictionary = players[1 - me] if players.size() == 2 and me in [0, 1] else {}
			if height > 0 and fh > 0 and int(ally.get("foothold", 0)) <= 0:
				candidates.append({"id": "ally_stuck",
					"text": "Your ally is still on the ground. Some cards lift them — nobody climbs this alone."})
			candidates.append({"id": "play_card",
				"text": "Tap a card to play it. Your energy is the ✦ number; End Turn when you're done."})

	for c in candidates:
		if not Progress.hint_seen(String(c["id"])):
			return c
	return {}


static func _hand_has(hand: Array, flag: String) -> bool:
	for c in hand:
		if bool((c as Dictionary).get(flag, false)):
			return true
	return false
