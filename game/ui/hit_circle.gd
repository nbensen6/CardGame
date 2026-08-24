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
var _world := Vector3.ZERO
var _at := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Full-rect and STOP while live, so the tap lands here rather than on a card
	# behind it or the camera drag underneath. Ignored when idle so it never eats
	# an ordinary click.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(false)


## Open a timing window at `world` (a point on the beast), seen through `cam`.
func begin(hits: int, bonus: float, cam: Camera3D, world: Vector3) -> void:
	if _live:
		return
	_live = true
	_hits_needed = maxi(1, hits)
	_hits_done = 0
	_worst = Combat.TIMING_PERFECT
	_t = 0.0
	_flash = 0.0
	zone_bonus = bonus
	_cam = cam
	_world = world
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
	if _hits_done >= _hits_needed:
		_finish(_worst)
		return
	_t = 0.0                  # next window, same hold


func _finish(quality: int) -> void:
	_live = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash = 1.0
	_flash_good = quality > Combat.TIMING_MISS
	resolved.emit(quality)


func _draw() -> void:
	if _cam == null or not is_instance_valid(_cam):
		return
	if _cam.is_position_behind(_world):
		return
	_at = _cam.unproject_position(_world)

	if _flash > 0.0:
		var burst := TARGET_RADIUS * (1.0 + (1.0 - _flash) * 1.6)
		var tint := (CORE if _flash_good else MISS)
		tint.a = _flash * 0.7
		draw_arc(_at, burst, 0.0, TAU, 48, tint, 4.0, true)
	if not _live:
		return

	# An osu note: a filled disc with a bright rim and a number in it, fading in
	# as it appears. The number matters for the multi-window cards (Satchel Charge
	# is three) — it is the same "hit these in order" read osu uses.
	var fade := clampf(_t / FADE_IN, 0.0, 1.0)
	var body := Color(0.10, 0.09, 0.13, 0.80 * fade)
	draw_circle(_at, TARGET_RADIUS, body)
	var rim := GOLD
	rim.a = fade
	draw_arc(_at, TARGET_RADIUS, 0.0, TAU, 56, rim, 4.0, true)
	# The perfect band, drawn where it actually is: the radius the approach ring
	# has when a tap would score perfect. Aim for the moment it crosses this.
	var core_r := TARGET_RADIUS * (1.0 + CORE_BAND * START_SCALE)
	draw_arc(_at, core_r, 0.0, TAU, 48, Color(CORE.r, CORE.g, CORE.b, 0.5 * fade), 2.0, true)

	var font := ThemeDB.fallback_font
	var label := str(_hits_done + 1)
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
	draw_string(font, _at + Vector2(-size.x * 0.5, 11.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 1, 1, fade))

	# The approach ring, shrinking onto the rim. It keeps going past it during the
	# overrun so a late tap reads as late rather than as the window having gone.
	var span := 1.0 + OVERRUN
	var k := clampf(_t / (APPROACH_SECONDS * span), 0.0, 1.0)
	var radius := TARGET_RADIUS * lerpf(START_SCALE, 0.30, k)
	var near := 1.0 - clampf(absf(_offset()) / (ZONE_BAND + zone_bonus), 0.0, 1.0)
	var ring := RING.lerp(CORE, near)
	ring.a = (0.5 + 0.5 * near) * fade
	draw_arc(_at, radius, 0.0, TAU, 64, ring, 3.5, true)
