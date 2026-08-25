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
## 0.58, down from 1.15 (Nick, 2026-08-24: "needs to be faster and closer to osu
## style"). osu's approach circles are a beat, not a countdown — the read is
## instant and the commitment is reflex. A slow approach turns it into waiting,
## which is the opposite feeling.
const APPROACH_SECONDS := 0.58
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
var _flash_good := false
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
func begin(bonus: float, cam: Camera3D, points: PackedVector3Array) -> void:
	if _live or points.is_empty():
		return
	_live = true
	_notes = points
	_hits_needed = points.size()
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
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_fire()


## Signed distance from the target, on the 0..1 approach scale. Negative before
## the ring lands, positive after — the sign is only for drawing; grading uses
## the magnitude, so early and late are punished identically.
func _offset() -> float:
	return (_t - APPROACH_SECONDS) / APPROACH_SECONDS


## One tap. Mirrors CardView._fire exactly, including that a chain's quality is
## its WORST window rather than its last: a shaky first hit still costs you.
func _fire() -> void:
	var off := absf(_offset())
	if off > ZONE_BAND + zone_bonus:
		_finish(Combat.TIMING_MISS)
		return
	if off > CORE_BAND:
		_worst = mini(_worst, Combat.TIMING_GOOD)
	_hits_done += 1
	_flash = 1.0
	_flash_good = true
	note_hit.emit(_hits_done - 1, Combat.TIMING_PERFECT if off <= CORE_BAND else Combat.TIMING_GOOD)
	if _hits_done >= _hits_needed:
		_finish(_worst)
		return
	# The next note's ring is already partly closed, because it has been on
	# screen behind this one. Rewinding to zero is what made the old chain feel
	# like three separate prompts.
	_t = CHAIN_OVERLAP


func _finish(quality: int) -> void:
	if _live and quality == Combat.TIMING_MISS:
		note_hit.emit(_hits_done, Combat.TIMING_MISS)
	_live = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash = 1.0
	_flash_good = quality > Combat.TIMING_MISS
	resolved.emit(quality)


## Screen position of note `i`, or null-ish if it is behind the camera.
func _screen(i: int) -> Vector2:
	return _cam.unproject_position(_notes[i])


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


func _draw() -> void:
	if _cam == null or not is_instance_valid(_cam) or _notes.is_empty():
		return

	if _flash > 0.0:
		var fi := clampi(_hits_done - 1 if _flash_good else _hits_done, 0, _notes.size() - 1)
		if _visible_note(fi):
			var burst := TARGET_RADIUS * (1.0 + (1.0 - _flash) * 1.6)
			var tint := (CORE if _flash_good else MISS)
			tint.a = _flash * 0.7
			draw_arc(_screen(fi), burst, 0.0, TAU, 48, tint, 4.0, true)
	if not _live:
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
