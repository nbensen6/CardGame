## The boss — a Combatant with a telegraphed, repeating move pattern.
##
## Intent is always visible to the player (no hover — CLAUDE.md §5): the view
## reads current_move() and shows what the boss will do next. The pattern loops.
##
## A move is a Dictionary: { "type": "attack"|"block", "value": int }.
class_name Boss
extends Combatant

var id: String = ""            # the data key — the view needs a STABLE identity,
                               # since art paths are shared between beasts
var moves: Array = []
var art: String = ""           # path to the beast's silhouette (shown in the combat view)
var vulnerable: int = 0        # "exposed" stacks — each consumed hit deals bonus damage
var strength: int = 0          # added to every attack (grows via "enrage" moves)
var wound: int = 0             # bleed — the Titan takes this much at the start of each of its turns
var weak_point_height: int = 0 # 0 = low sigil (always reachable); >0 needs Foothold to strike (SotC climb)
var ledges: Array = []         # safe rest Heights between the base and the sigil (SotC holds) —
                               # each element is either a bare int (legacy: an unrestricted safe
                               # hold) or a named-hold Dictionary, see hold_height()/hold_safe()
                               # below (design/BACKLOG.md #24).
var weak_point_threshold: int = 0  # sigil damage a hunter can deal per visit before it bucks them off (0 = no limit)
var limiter: Dictionary = {}   # {"type": ..., "value": ...} — a rule this Titan bends against a
                                # specific strategy, applied generically by Combat._apply_limiter()
                                # (design/sts2-comparison.md §3.4). {} = none.
var hurt_pct: float = 0.0      # backlog #44: below this fraction of max_hp, `hurt_moves` replaces
                                # `moves` entirely. 0 (default) = no second pattern, unchanged beast.
var hurt_moves: Array = []     # the second pattern; same shape as `moves` ("when"/"fallback" both
                                # still work inside it). Ignored unless hurt_pct > 0.
var _move_index: int = 0

## A move in `moves` can carry an optional "when" condition (backlog #40):
## {"type": "min_height"|"max_height"|"at_sigil"|"undefended", "value": int}.
## When present, the move only fires if the condition holds against the
## board `context` passed to current_move() — {"footholds": [...], "blocks":
## [...]}, one entry per hunter, built by Combat.boss_context(). If it does
## not hold, the move's own "fallback" Dictionary is used instead (or a bare
## attack for 0 if a move sets "when" without a "fallback"). A move with no
## "when" always fires, exactly as before this existed.
const COND_MIN_HEIGHT := "min_height"
const COND_MAX_HEIGHT := "max_height"
const COND_AT_SIGIL := "at_sigil"
const COND_UNDEFENDED := "undefended"

## The move the boss will perform on its next enemy turn (telegraphed now).
## `context` is only consulted for moves that set "when" — omit it (or pass
## {}) to read the pattern's plain, unconditional shape.
func current_move(context: Dictionary = {}) -> Dictionary:
	var active := _active_moves()
	if active.is_empty():
		return {"type": "attack", "value": 0}
	var move: Dictionary = active[_move_index % active.size()]
	if move.has("when") and not _condition_met(move["when"], context):
		return move.get("fallback", {"type": "attack", "value": 0})
	return move

## backlog #44: below `hurt_pct` of max HP, the Titan switches its whole
## pattern rather than its whole fight looking the same at 5 HP as at full.
## Same `_move_index` drives both lists (no separate counter, no reset on
## crossing the line) so the switch lands wherever the pattern already was —
## a beast hurt mid-pattern doesn't restart its rotation, it just changes it.
func _active_moves() -> Array:
	if hurt_pct > 0.0 and not hurt_moves.is_empty() and hp <= max_hp * hurt_pct:
		return hurt_moves
	return moves

## Evaluate one "when" condition against the board context. Any hunter
## meeting it is enough — these are reactions to the CLIMB, not to a specific
## hunter, so either one clinging to the sigil (say) is enough to provoke it.
func _condition_met(cond: Dictionary, context: Dictionary) -> bool:
	var footholds: Array = context.get("footholds", [])
	var blocks: Array = context.get("blocks", [])
	match String(cond.get("type", "")):
		COND_MIN_HEIGHT:
			for h in footholds:
				if int(h) >= int(cond.get("value", 0)):
					return true
			return false
		COND_MAX_HEIGHT:
			for h in footholds:
				if int(h) <= int(cond.get("value", 0)):
					return true
			return false
		COND_AT_SIGIL:
			if weak_point_height <= 0:
				return false
			for h in footholds:
				if int(h) == weak_point_height:
					return true
			return false
		COND_UNDEFENDED:
			for b in blocks:
				if int(b) <= int(cond.get("value", 0)):
					return true
			return false
		_:
			return false

## Advance the pattern after the boss acts.
func advance_move() -> void:
	_move_index += 1

## A hold in `ledges` is either a bare number (legacy: an unrestricted safe
## rest Height — JSON-loaded ledges arrive as float, not int, so this checks
## `is Dictionary` rather than `is int`) or a Dictionary { "height": int,
## "safe": bool (default true), "exposed_to": Array[String] (default []) }.
## These three helpers let every reader treat both shapes the same way.
static func hold_height(h) -> int:
	return int((h as Dictionary).get("height", 0)) if h is Dictionary else int(h)

static func hold_safe(h) -> bool:
	return bool((h as Dictionary).get("safe", true)) if h is Dictionary else true

static func hold_exposed_to(h) -> Array:
	return (h as Dictionary).get("exposed_to", []) if h is Dictionary else []

## Plain heights, for legacy consumers (the climb gauge, screenshot.gd) that
## only need "which Heights are marked" and don't care about the richer shape.
func ledge_heights() -> Array:
	var out: Array = []
	for l in ledges:
		out.append(hold_height(l))
	return out

## Only the DYNAMIC per-fight state (what a fight can actually change) — the
## static data (moves, ledges, limiter, art, max_hp) is rebuilt from `id` via
## Content.boss_from_dict(), the same split Run/PlayerState use for cards.
func to_dict() -> Dictionary:
	return {
		"id": id, "hp": hp, "block": block, "vulnerable": vulnerable,
		"strength": strength, "wound": wound,
		# frail/artifact (backlog #36) are dynamic too — frail only ever
		# starts at 0 and grows from a card, same as vulnerable/wound; artifact
		# starts from beast data (build_boss) but is SPENT during the fight,
		# same shape weak_point_height already uses for a data-seeded value
		# that a fight can then change.
		"frail": frail, "artifact": artifact,
		"weak_point_height": weak_point_height,  # shift_sigil can move it mid-fight
		"move_index": _move_index,
	}

## Restore the dynamic state saved above onto a freshly rebuilt Boss.
func apply_dict(d: Dictionary) -> void:
	hp = int(d.get("hp", hp))
	block = int(d.get("block", 0))
	vulnerable = int(d.get("vulnerable", 0))
	strength = int(d.get("strength", 0))
	wound = int(d.get("wound", 0))
	frail = int(d.get("frail", 0))
	artifact = int(d.get("artifact", artifact))  # fall back to build_boss's data-seeded value
	weak_point_height = int(d.get("weak_point_height", weak_point_height))
	_move_index = int(d.get("move_index", 0))
