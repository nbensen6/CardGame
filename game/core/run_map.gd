## The run map — the roguelike's branching route (design/depth-plan.md item 1).
##
## A run is a sequence of ACTS. Each act is a few rows of branching nodes capped
## by a boss row (a Titan). You stand on a node and may step to any node its
## edges reach in the next row, so the route is a real choice you can plan
## several rows ahead — that's the decision density the run was missing.
##
## Pure /core: deterministic from a seeded RNG, no rendering/input/net. Rows are
## plain Dictionaries so the host can drop them straight into a snapshot.
##   node = {"type": String, "act": int, "next": Array[int]}   # next = cols in row+1
class_name RunMap
extends RefCounted

## Non-boss rows before each Titan. Was 3, which made an act four nodes long:
## you reached a trader holding one fight's worth of gold and could not afford
## anything in it, and an act was over before its route had a shape you could
## plan (Nick, 2026-08-16). Five rows puts a run at 24 nodes.
const ROWS_PER_ACT := 5
const MIN_WIDTH := 2
const MAX_WIDTH := 3

var rows: Array = []  # Array[Array[Dictionary]]


func _init(acts: int, rng: RandomNumberGenerator) -> void:
	for a in range(acts):
		var act_rows: Array = []
		for r in range(ROWS_PER_ACT):
			act_rows.append(_make_row(a, r, rng))
		_ensure_shop(act_rows, rng)
		for row in act_rows:
			rows.append(row)
		rows.append([{"type": "boss", "act": a, "next": []}])
	_link(rng)


## Columns reachable from a position. Before the run starts (row < 0) every node
## in the first row is a valid opening.
func available(row: int, col: int) -> Array:
	if rows.is_empty():
		return []
	if row < 0:
		var all: Array = []
		for i in range(rows[0].size()):
			all.append(i)
		return all
	if row >= rows.size() or col < 0 or col >= rows[row].size():
		return []
	return (rows[row][col] as Dictionary)["next"]


func node_at(row: int, col: int) -> Dictionary:
	if row < 0 or row >= rows.size() or col < 0 or col >= rows[row].size():
		return {}
	return rows[row][col]


func is_last_row(row: int) -> bool:
	return row >= rows.size() - 1


func total_rows() -> int:
	return rows.size()


# --- saving ---------------------------------------------------------------
#
# Rows are already plain Dictionaries of ints and Strings, so the map needs no
# translation to survive a save — only a way to be rebuilt WITHOUT regenerating,
# since a fresh generation would hand the player a different mountain.

func to_dict() -> Dictionary:
	return {"rows": rows.duplicate(true)}


static func from_dict(d: Dictionary) -> RunMap:
	var m := RunMap.new(0, RandomNumberGenerator.new())  # 0 acts: generates nothing
	m.rows = (d.get("rows", []) as Array).duplicate(true)
	return m


# --- generation -----------------------------------------------------------

## Every act offers a trader, in its back half.
##
## Left to the dice a shop turned up in about a third of acts, and when it did it
## could land on row 1 — before you had earned anything, which is the same as no
## shop at all. The back half guarantees a full act's fights are behind you, so
## the purse is worth spending when you get there.
func _ensure_shop(act_rows: Array, rng: RandomNumberGenerator) -> void:
	for row in act_rows:
		for n in row:
			if String((n as Dictionary)["type"]) == "shop":
				return
	var first: int = int(ceil(float(ROWS_PER_ACT) / 2.0))
	if first >= act_rows.size():
		return
	var r: int = rng.randi_range(first, act_rows.size() - 1)
	var row: Array = act_rows[r]
	# Convert a fight or an event rather than the rest that may be the only heal
	# before the Titan, falling back to any node if the row is all rests.
	var candidates: Array = []
	for i in range(row.size()):
		if String((row[i] as Dictionary)["type"]) in ["fight", "event", "treasure"]:
			candidates.append(i)
	if candidates.is_empty():
		for i in range(row.size()):
			candidates.append(i)
	(row[candidates[rng.randi_range(0, candidates.size() - 1)]] as Dictionary)["type"] = "shop"


func _make_row(act: int, row_in_act: int, rng: RandomNumberGenerator) -> Array:
	var width := rng.randi_range(MIN_WIDTH, MAX_WIDTH)
	var out: Array = []
	for _i in range(width):
		out.append({"type": _roll_type(row_in_act, rng), "act": act, "next": []})
	return out


## Each act eases in with a fight and tends to offer a breather before the boss;
## the middle is where the risk/reward spread lives.
func _roll_type(row_in_act: int, rng: RandomNumberGenerator) -> String:
	if row_in_act == 0:
		return "fight"
	var roll := rng.randi_range(0, 99)
	if row_in_act >= ROWS_PER_ACT - 1:  # the run-up to the Titan
		if roll < 36:
			return "rest"
		if roll < 62:
			return "treasure"
		if roll < 82:
			return "event"
		return "elite"
	if roll < 34:
		return "fight"
	if roll < 54:
		return "event"
	if roll < 70:
		return "elite"
	if roll < 82:
		return "shop"
	if roll < 92:
		return "treasure"
	return "rest"


## Wire each row to the next: every node gets 1–2 forward edges, and every node
## in the next row is guaranteed at least one way in (no unreachable dead ends).
func _link(rng: RandomNumberGenerator) -> void:
	for r in range(rows.size() - 1):
		var cur: Array = rows[r]
		var nxt: Array = rows[r + 1]
		var reached := {}
		for i in range(cur.size()):
			var j := _aligned(i, cur.size(), nxt.size())
			var edges: Array = [j]
			if nxt.size() > 1 and rng.randi_range(0, 1) == 1:
				var step := 1 if rng.randi_range(0, 1) == 1 else -1
				var k: int = clampi(j + step, 0, nxt.size() - 1)
				if k != j:
					edges.append(k)
			edges.sort()
			(cur[i] as Dictionary)["next"] = edges
			for e in edges:
				reached[e] = true
		for j in range(nxt.size()):
			if reached.has(j):
				continue
			var from := _aligned(j, nxt.size(), cur.size())
			var e2: Array = (cur[from] as Dictionary)["next"]
			if not e2.has(j):
				e2.append(j)
				e2.sort()


## Map an index in a row of `from_n` onto the proportionally matching index in a
## row of `to_n`, so paths run roughly straight instead of criss-crossing.
func _aligned(i: int, from_n: int, to_n: int) -> int:
	if from_n <= 1 or to_n <= 1:
		return 0
	return clampi(int(round(float(i) * float(to_n - 1) / float(from_n - 1))), 0, to_n - 1)
