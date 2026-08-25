## An osu-style approach circle, drawn at the hold you are climbing to.
##
## Nick, 2026-08-22: "change the timing mechanic to mimicc osu so something pops
## up and you do a quick osu like timing thing". The sweep bar asks WHEN. This
## asks when AND where in one gesture, because it appears on the beast at the
## hold you are reaching for rather than in a strip under the card — so your eyes
## are on the climb instead of on the HUD while the most tense moment resolves.
##
## The rules half already exists (Combat.TIMING_PERFECT / GOOD / MISS, backlog
## #33), so this is purely a second FACE over the same grading. It emits the same
## `resolved(quality)` the card face does and nothing downstream can tell them
## apart. Both are kept and switchable, because which one feels better is a
## question only playing can answer (backlog #34).
class_name HitCircle
extends Control

## Same contract as CardView.timing_resolved.
signal resolved(quality: int)

## Fired as each note in a chain lands, so the view can react per hit rather
## than only at the end. `index` is 0-based, `quality` grades that note alone.
signal note_hit(index: int, quality: int)

## Seconds for the ring to close on the target.
##
## 1.15 was a countdown and read as waiting. 0.58 was a beat but left no room to
## aim, especially once a chain asks you to read the next note while hitting this
## one. 0.80 is the settle (Nick, 2026-08-25: "add a little bit more timing for
## it") — still a beat, with time to look ahead.
const APPROACH_SECONDS := 0.80
## How far past the target the ring may travel before the window closes, as a
## fraction of the approach. A late tap has to be possible or the whole thing is
## a coin flip on latency.
const OVERRUN := 0.30
## Bands, on the 0..1 approach scale: |offset| inside CORE is perfect, inside
## ZONE is good, outside is a miss. Wider fractions of a much shorter approach,
## which still tightens both in real time — perfect went 69ms -> 44ms and the
## whole window 184ms -> 116ms.
const CORE_BAND := 0.075
const ZONE_BAND := 0.200

const TARGET_RADIUS := 40.0
const START_SCALE := 2.9      # ring radius at the start, in target radii
## Seconds of fade-in as the note appears. osu never pops a circle in at full
## opacity; the fade is what tells you a new one has started.
const FADE_IN := 0.11
## How much of the NEXT note is already on screen while you are hitting this one.
## osu never shows you one circle at a time — the pattern is legible several
## notes ahead, and reading ahead is most of the skill. Without this a chain is
## just the same prompt three times (Nick, 2026-08-25: "it should be a fluid
## function mimicing how osu has multiple clicks for timing not just one").
const LOOKAHEAD_ALPHA := 0.34
## Seconds of head start the next note's approach ring gets, so it is already
## closing when the current one resolves. This is what makes a chain feel like
## one continuous motion instead of three separate reaction tests.
const CHAIN_OVERLAP := 0.22
## A slider: press on the beat, then HOLD while the follower runs the path.
## Seconds for it to travel the whole chain.
const SLIDE_SECONDS := 0.85
## Let go after this much of the path and it still counts, downgraded. Releasing
## a hair early is a slip; releasing at the start is not doing it at all.
const SLIDE_RESCUE := 0.72

## Slider ticks, as a fraction of the path. osu dots the body at regular
## intervals; passing one is a beat you can hear yourself keeping, and it turns a
## hold from "wait" into "travel".
const TICK_STEP := 0.2
## The follow circle: osu draws a ring around the ball WHILE you hold it, and
## drops it the instant you let go. It is the clearest "you still have this"
## signal in the game.
const FOLLOW_SCALE := 1.55

const GOLD := Color(1.0, 0.83, 0.36)
const RING := Color(0.98, 0.93, 0.72)
const CORE := Color(0.55, 0.95, 0.60)
const MISS := Color(0.92, 0.38, 0.32)

var zone_bonus := 0.0         # relic widening, same units the card face uses

var _live := false
var _t := 0.0                 # seconds since this window opened
var _hits_needed := 1
var _hits_done := 0
var _worst := Combat.TIMING_PERFECT
var _flash := 0.0
var _burst_grade := -1        # judgement being popped, osu's 300 / 100 / X
var _burst_note := 0          # which note it belongs to, so it follows the camera
var _combo := 0               # notes landed in a row, reset by a miss
var _slider := false          # this window is held, not tapped
var _holding := false         # the press has landed and the follower is running
var _slide := 0.0             # 0..1 along the path
var _press_quality := Combat.TIMING_PERFECT
var _cam: Camera3D
var _notes: PackedVector3Array = PackedVector3Array()   # one world point per hit
var _at := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Full-rect and STOP while live, so the tap lands here rather than on a card
	# behind it or the camera drag underneath. Ignored when idle so it never eats
	# an ordinary click.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(false)


## Open a chain of timing windows. `points` is one world position per hit — a
## climb card's three windows are three places up the beast, so the chain reads
## as the climb it is rather than as the same prompt three times.
## `slider` makes the whole window one held note travelling the path, instead of
## a tap at each point.
func begin(bonus: float, cam: Camera3D, points: PackedVector3Array,
		slider: bool = false) -> void:
	if _live or points.is_empty():
		return
	_live = true
	_slider = slider and points.size() > 1
	_holding = false
	_slide = 0.0
	_press_quality = Combat.TIMING_PERFECT
	_notes = points
	_hits_needed = 1 if _slider else points.size()
	_hits_done = 0
	_worst = Combat.TIMING_PERFECT
	_t = CHAIN_OVERLAP    # the first note starts part-closed too, so nothing stalls
	_flash = 0.0
	zone_bonus = bonus
	_cam = cam
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)
	queue_redraw()


func is_live() -> bool:
	return _live


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta * 4.0)
	if _live and _holding:
		_slide += delta / SLIDE_SECONDS
		if _slide >= 1.0:
			_finish(_press_quality)   # held it all the way
		queue_redraw()
		return
	if _live:
		_t += delta
		if _t > APPROACH_SECONDS * (1.0 + OVERRUN):
			_finish(Combat.TIMING_MISS)   # the window closed with no tap
			return
	elif _flash <= 0.0:
		visible = false
		set_process(false)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not _live or not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	if mb.pressed:
		_fire()
	elif _holding:
		# Let go. Near the end is a slip and still pays something; letting go at
		# the start means you did not hold it at all.
		_finish(Combat.TIMING_MISS if _slide < SLIDE_RESCUE
			else mini(_press_quality, Combat.TIMING_GOOD))


## Signed distance from the target, on the 0..1 approach scale. Negative before
## the ring lands, positive after — the sign is only for drawing; grading uses
## the magnitude, so early and late are punished identically.
func _offset() -> float:
	return (_t - APPROACH_SECONDS) / APPROACH_SECONDS


## One tap. Mirrors CardView._fire exactly, including that a chain's quality is
## its WORST window rather than its last: a shaky first hit still costs you.
func _fire() -> void:
	if _holding:
		return                       # already running the path
	var off := absf(_offset())
	if off > ZONE_BAND + zone_bonus:
		_finish(Combat.TIMING_MISS)
		return
	if off > CORE_BAND:
		_worst = mini(_worst, Combat.TIMING_GOOD)
	if _slider:
		# The press was on time. Now keep hold of it: the note is not done until
		# the follower reaches the end of the path.
		_press_quality = _worst
		_holding = true
		_slide = 0.0
		_combo += 1
		_burst_note = 0
		_burst_grade = _worst
		_flash = 1.0
		note_hit.emit(0, _worst)
		return
	_hits_done += 1
	_combo += 1
	_burst_note = _hits_done - 1
	_burst_grade = Combat.TIMING_PERFECT if off <= CORE_BAND else Combat.TIMING_GOOD
	_flash = 1.0
	note_hit.emit(_hits_done - 1, Combat.TIMING_PERFECT if off <= CORE_BAND else Combat.TIMING_GOOD)
	if _hits_done >= _hits_needed:
		_finish(_worst)
		return
	# The next note's ring is already partly closed, because it has been on
	# screen behind this one. Rewinding to zero is what made the old chain feel
	# like three separate prompts.
	_t = CHAIN_OVERLAP


func _finish(quality: int) -> void:
	_holding = false
	if _live and quality == Combat.TIMING_MISS:
		note_hit.emit(_hits_done, Combat.TIMING_MISS)
		_combo = 0
		_burst_note = mini(_hits_done, maxi(_notes.size() - 1, 0))
		_burst_grade = Combat.TIMING_MISS
		_flash = 1.0
	_live = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resolved.emit(quality)


## Screen position of note `i`, kept ON the screen.
##
## The path runs from the card up to the hold, and on a tall beast the far end
## of it can be above the top of the frame — so you would tap 1 and 2 and never
## find 3 (Nick, 2026-08-25). A note you cannot see is not a timing test, it is
## a guaranteed miss. Clamping here rather than where the path is built means it
## stays true while the camera moves under it, and every reader — notes, follow
## points, slider body, judgement bursts — gets the corrected position for free.
func _screen(i: int) -> Vector2:
	var at := _cam.unproject_position(_notes[i])
	var pad := TARGET_RADIUS * START_SCALE * 0.5 + 8.0   # room for the approach ring
	return Vector2(clampf(at.x, pad, maxf(size.x - pad, pad)),
		clampf(at.y, pad, maxf(size.y - pad, pad)))


func _visible_note(i: int) -> bool:
	return i >= 0 and i < _notes.size() and not _cam.is_position_behind(_notes[i])


## One osu note: filled disc, bright rim, number.
func _note(at: Vector2, n: int, alpha: float) -> void:
	draw_circle(at, TARGET_RADIUS, Color(0.10, 0.09, 0.13, 0.80 * alpha))
	draw_arc(at, TARGET_RADIUS, 0.0, TAU, 56, Color(GOLD.r, GOLD.g, GOLD.b, alpha), 4.0, true)
	var font := ThemeDB.fallback_font
	var label := str(n)
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
	draw_string(font, at + Vector2(-size.x * 0.5, 11.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 1, 1, alpha))


## osu's follow points: a dotted run between consecutive notes, so the chain
## reads as one path rather than as unrelated targets.
func _follow(a: Vector2, bb: Vector2, alpha: float) -> void:
	var span := bb - a
	var length := span.length()
	if length < TARGET_RADIUS * 2.2:
		return
	var dir := span / length
	var start := a + dir * (TARGET_RADIUS + 10.0)
	var run := length - (TARGET_RADIUS + 10.0) * 2.0
	var dots := int(run / 22.0)
	for i in range(maxi(dots, 0)):
		var p := start + dir * (22.0 * (i + 0.5))
		draw_circle(p, 2.6, Color(RING.r, RING.g, RING.b, 0.45 * alpha))


## Every note as a screen point, in order.
func _screen_path() -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(_notes.size()):
		if _cam.is_position_behind(_notes[i]):
			return PackedVector2Array()   # any point behind us and the path is a lie
		out.append(_screen(i))
	return out


## Where the follower is, walking the path by arc length so it moves at a
## constant speed rather than hurrying through the short legs.
func _path_point(path: PackedVector2Array, t: float) -> Vector2:
	if path.size() < 2:
		return path[0] if path.size() == 1 else Vector2.ZERO
	var legs: Array[float] = []
	var total := 0.0
	for i in range(path.size() - 1):
		var d := path[i].distance_to(path[i + 1])
		legs.append(d)
		total += d
	if total <= 0.0:
		return path[0]
	var want := clampf(t, 0.0, 1.0) * total
	for i in range(legs.size()):
		if want <= legs[i] or i == legs.size() - 1:
			return path[i].lerp(path[i + 1], clampf(want / maxf(legs[i], 0.001), 0.0, 1.0))
		want -= legs[i]
	return path[path.size() - 1]


## A slider: press on the beat, then hold while the follower runs the track.
## Drawn as a road rather than as separate targets, because that is what it asks
## of you — one sustained motion, not several decisions.
func _draw_slider(path: PackedVector2Array) -> void:
	var fade := clampf(_t / FADE_IN, 0.0, 1.0)
	draw_polyline(path, Color(0.10, 0.09, 0.13, 0.40 * fade), TARGET_RADIUS * 1.05, true)
	draw_polyline(path, Color(GOLD.r, GOLD.g, GOLD.b, 0.72 * fade), 2.5, true)
	var tail := path[path.size() - 1]
	draw_arc(tail, TARGET_RADIUS * 0.6, 0.0, TAU, 32,
		Color(CORE.r, CORE.g, CORE.b, 0.7 * fade), 3.0, true)

	# Slider ticks: osu dots the body at regular intervals, and passing one is a
	# beat you keep. They light as the ball goes over them, so the track fills in
	# behind you and the hold has a rhythm instead of being a wait.
	var tick := TICK_STEP
	while tick < 0.999:
		var lit: bool = _holding and _slide >= tick
		var tc := CORE if lit else RING
		draw_circle(_path_point(path, tick), 5.0 if lit else 3.8,
			Color(tc.r, tc.g, tc.b, (0.95 if lit else 0.6) * fade))
		tick += TICK_STEP

	if _holding:
		# The road behind you lights up, so "how much is left" is the thing you
		# are reading rather than a number.
		var done := PackedVector2Array()
		var steps := 14
		for i in range(steps + 1):
			done.append(_path_point(path, _slide * float(i) / float(steps)))
		if done.size() > 1:
			draw_polyline(done, Color(CORE.r, CORE.g, CORE.b, 0.75), 5.0, true)
		var ball := _path_point(path, _slide)
		draw_circle(ball, TARGET_RADIUS * 0.52, Color(0.10, 0.09, 0.13, 0.9))
		draw_arc(ball, TARGET_RADIUS * 0.52, 0.0, TAU, 40, CORE, 4.0, true)
		# The follow circle. osu draws it around the ball only while you are
		# holding and drops it the instant you let go, which makes it the
		# clearest "you still have this" signal on the screen.
		draw_arc(ball, TARGET_RADIUS * 0.52 * FOLLOW_SCALE, 0.0, TAU, 44,
			Color(GOLD.r, GOLD.g, GOLD.b, 0.75), 3.0, true)
		# The rescue mark: let go past this and it still pays, downgraded.
		var rescue := _path_point(path, SLIDE_RESCUE)
		draw_arc(rescue, 7.0, 0.0, TAU, 20, Color(GOLD.r, GOLD.g, GOLD.b, 0.6), 2.0, true)
		return

	_note(path[0], 1, fade)
	var core_r := TARGET_RADIUS * (1.0 + CORE_BAND * START_SCALE)
	draw_arc(path[0], core_r, 0.0, TAU, 48, Color(CORE.r, CORE.g, CORE.b, 0.5 * fade), 2.0, true)
	var span := 1.0 + OVERRUN
	var k := clampf(_t / (APPROACH_SECONDS * span), 0.0, 1.0)
	var near := 1.0 - clampf(absf(_offset()) / (ZONE_BAND + zone_bonus), 0.0, 1.0)
	var ring := RING.lerp(CORE, near)
	ring.a = (0.5 + 0.5 * near) * fade
	draw_arc(path[0], TARGET_RADIUS * lerpf(START_SCALE, 0.30, k), 0.0, TAU, 64, ring, 3.5, true)


## osu pops a judgement at the circle the moment you hit it — 300, 100, 50 or a
## miss — and the number IS the feedback. Ours are named rather than numbered
## because the words are what the rest of the game already calls them.
func _burst(at: Vector2, grade: int, t: float) -> void:
	var tint := MISS
	var label := "MISS"
	if grade >= Combat.TIMING_PERFECT:
		tint = CORE
		label = "PERFECT"
	elif grade >= Combat.TIMING_GOOD:
		tint = GOLD
		label = "GOOD"
	var ring := tint
	ring.a = t * 0.7
	draw_arc(at, TARGET_RADIUS * (1.0 + (1.0 - t) * 1.6), 0.0, TAU, 48, ring, 4.0, true)
	var font := ThemeDB.fallback_font
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
	var lift := (1.0 - t) * 22.0
	draw_string(font, at + Vector2(-size.x * 0.5, -TARGET_RADIUS - 12.0 - lift), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(tint.r, tint.g, tint.b, t))
	if _combo > 1 and grade > Combat.TIMING_MISS:
		var combo := "%dx" % _combo
		var cs := font.get_string_size(combo, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
		draw_string(font, at + Vector2(-cs.x * 0.5, TARGET_RADIUS + 24.0 + lift * 0.5), combo,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(GOLD.r, GOLD.g, GOLD.b, t * 0.9))


func _draw() -> void:
	if _cam == null or not is_instance_valid(_cam) or _notes.is_empty():
		return

	if _flash > 0.0 and _burst_grade >= 0:
		var fi := clampi(_burst_note, 0, _notes.size() - 1)
		if _visible_note(fi):
			_burst(_screen(fi), _burst_grade, _flash)
	if not _live:
		return

	if _slider:
		var path := _screen_path()
		if path.size() > 1:
			_draw_slider(path)
		return

	var fade := clampf(_t / FADE_IN, 0.0, 1.0)

	# The notes you have not hit yet, furthest first so the current one draws on
	# top. Each is dimmer than the last: the pattern is legible ahead of time,
	# but there is never any doubt which one is yours right now.
	for i in range(_notes.size() - 1, _hits_done, -1):
		if not _visible_note(i):
			continue
		var depth := i - _hits_done
		var alpha := LOOKAHEAD_ALPHA * pow(0.62, depth - 1)
		if _visible_note(i - 1):
			_follow(_screen(i - 1), _screen(i), alpha)
		_note(_screen(i), i + 1, alpha)

	if not _visible_note(_hits_done):
		return
	_at = _screen(_hits_done)
	_note(_at, _hits_done + 1, fade)

	# The perfect band, drawn where the approach ring will be when a tap scores
	# perfect. Aim for the moment it crosses this, not for the rim.
	var core_r := TARGET_RADIUS * (1.0 + CORE_BAND * START_SCALE)
	draw_arc(_at, core_r, 0.0, TAU, 48, Color(CORE.r, CORE.g, CORE.b, 0.5 * fade), 2.0, true)

	# The approach ring, shrinking onto the rim, carrying on past it through the
	# overrun so a late tap reads as late rather than as the window having gone.
	var span := 1.0 + OVERRUN
	var k := clampf(_t / (APPROACH_SECONDS * span), 0.0, 1.0)
	var radius := TARGET_RADIUS * lerpf(START_SCALE, 0.30, k)
	var near := 1.0 - clampf(absf(_offset()) / (ZONE_BAND + zone_bonus), 0.0, 1.0)
	var ring := RING.lerp(CORE, near)
	ring.a = (0.5 + 0.5 * near) * fade
	draw_arc(_at, radius, 0.0, TAU, 64, ring, 3.5, true)
