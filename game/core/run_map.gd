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

const ROWS_PER_ACT := 3  # non-boss rows before each Titan
const MIN_WIDTH := 2
const MAX_WIDTH := 3

var rows: Array = []  # Array[Array[Dictionary]]


func _init(acts: int, rng: RandomNumberGenerator) -> void:
	for a in range(acts):
		for r in range(ROWS_PER_ACT):
			rows.append(_make_row(a, r, rng))
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


# --- generation -----------------------------------------------------------

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
		if roll < 40:
			return "rest"
		if roll < 70:
			return "treasure"
		return "elite"
	if roll < 42:
		return "fight"
	if roll < 64:
		return "elite"
	if roll < 84:
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
