## Autonomous playtester — plays the real game through real input and checks
## what a player would notice, every step, over time.
##
## screenshot.gd checks one frozen moment; run_tests.gd checks one rule in
## isolation. Nick's bugs live in neither: the hand drifting right only AFTER an
## End Turn, a card flickering only while the mouse sits still on it. This plays
## a fight the way he does — mouse moves, clicks, waits — and after every action
## runs the INVARIANTS below against the live screen and the live model.
##
##   tools\playtest.cmd mode=play beast=cinder_jackal steps=40 out=C:\pt
##   tools\playtest.cmd mode=hover beast=cinder_jackal out=C:\pt
##
## Always through tools\playtest.cmd (second monitor, no focus steal).
##
## modes:
##   play   pick a playable card, move to it, click it (timed cards: the bot
##          plays the hit circle / sweep for real), else End Turn. Repeat.
##   hands  deal every hand size 1..10 and check the layout of each
##   hover  park the mouse still at points across every resting card and count
##          how often the raised card changes. A still mouse must never flicker.
##
## Output (in out=): report.md (every FAIL with the step it happened on),
## step_NNN.png per action, and a FAIL line on stdout per violation.
## Exit code = number of distinct failing checks.
extends SceneTree

## Below this, two hunter "home" points read as the same standing spot rather
## than two hunters side by side. See check 7 in _check() for where this is
## used and why this number.
const MIN_HUNTER_GAP := 0.35

var _mode := "play"
var _beast := ""
var _steps := 40
var _out := "user://playtest"
var _size := Vector2i(1280, 720)
var _timeout := 0.0   # timeout=SECONDS — 0 means scale it from the step count

var _fails: Dictionary = {}       # check name -> count
var _log: PackedStringArray = []
var _step := 0
var _errors: Array = []           # script errors caught by _ErrLog


class _ErrLog extends Logger:
	var sink: Array
	func _init(s: Array) -> void:
		sink = s
	func _log_error(function: String, file: String, line: int, code: String,
			rationale: String, _editor_notify: bool, error_type: int,
			bt: Array) -> void:
		# error_type 1 = warning; everything else is an error worth failing on
		if error_type != 1:
			var where: PackedStringArray = []
			for b in bt:
				if b != null:
					for i in mini(b.get_frame_count(), 4):
						where.append("%s:%d %s" % [b.get_frame_file(i).get_file(), b.get_frame_line(i), b.get_frame_function(i)])
			sink.append("%s:%d %s %s  <- %s" % [file.get_file(), line, code, rationale, " < ".join(where)])
	func _log_message(_message: String, _error: bool) -> void:
		pass


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		match kv[0]:
			"mode": _mode = kv[1]
			"beast": _beast = kv[1]
			"steps": _steps = int(kv[1])
			"timeout": _timeout = float(kv[1])
			"out": _out = kv[1]
			"size":
				var wh := kv[1].split("x")
				_size = Vector2i(int(wh[0]), int(wh[1]))
	OS.add_logger(_ErrLog.new(_errors))
	DirAccess.make_dir_recursive_absolute(_out)
	DisplayServer.window_set_size(_size)
	root.set_flag(Window.FLAG_NO_FOCUS, true)
	_watchdog()
	# Silence. These run while Nick is playing something else, and a harness
	# that sings over his game is a harness he turns off (2026-09-23).
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	RunSave.use_scratch_slot("run_playtest")
	RunSave.clear()
	Progress.use_scratch_slot("progress_playtest")
	Progress.reset_hints()
	Progress.set_hints_enabled(false)
	Progress.set_timing_style(Progress.TIMING_CIRCLE)
	var transport := LocalTransport.new()
	Session.transport = transport
	Session.host = GameHost.new(transport, 42, 2, true)
	Session.client = GameClient.new(transport, 1)
	Session.client.join()
	Session.client.select_character("frog", 0)
	Session.client.select_character("goblin_mech", 1)
	var r: Run = Session.host._run
	var g := 0
	while r.phase == Run.Phase.MAP and g < 30:
		g += 1
		r.pick_node(int(r.available_nodes()[0]))
	if _beast != "" and r.combat != null:
		r.combat.boss = Content.build_boss(_beast)
	Session.host._broadcast_state()
	change_scene_to_file("res://views/game_3d.tscn")
	_run.call_deferred()


## Wall-clock guard. Software rendering (the CI runner: Xvfb + llvmpipe, no
## GPU) takes many times longer per frame than this PC, and a fixed 600s cut a
## healthy 80-step run off at step 76 — reported as "stuck" when nothing was.
## Scale it with the work asked for, and let a caller override.
func _watchdog() -> void:
	await create_timer(maxf(_timeout, 90.0 + _steps * 25.0)).timeout
	_fail("watchdog", "playtest did not finish in 600s — something is stuck")
	_finish()


# --------------------------------------------------------------- helpers

func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _view() -> Node:
	var router := current_scene
	if router == null:
		return null
	var v: Node = router.get("_view")
	return v if v != null else router


func _combat() -> Combat:
	var r: Run = Session.host._run
	return r.combat if r != null else null


func _fail(check: String, detail: String) -> void:
	_fails[check] = int(_fails.get(check, 0)) + 1
	var line := "FAIL [step %d] %s: %s" % [_step, check, detail]
	print(line)
	_log.append("- " + line)


func _note(s: String) -> void:
	print(s)
	_log.append("- " + s)


func _move(at: Vector2) -> void:
	var mm := InputEventMouseMotion.new()
	mm.position = at
	mm.global_position = at
	Input.warp_mouse(at)
	root.push_input(mm)


func _click(at: Vector2, release := true) -> void:
	_move(at)
	await process_frame
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = at
	down.global_position = at
	root.push_input(down)
	if release:
		await process_frame
		var up := down.duplicate() as InputEventMouseButton
		up.pressed = false
		root.push_input(up)


func _hand(v: Node) -> Array:
	var row: Control = v.get("_hand_row")
	if row == null:
		return []
	return row.get_children().filter(func(c: Node) -> bool: return not c.is_queued_for_deletion())


func _shot() -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png("%s/step_%03d.png" % [_out, _step])


# --------------------------------------------------------------- invariants

## Every check a player would notice without being told to look.
func _check(v: Node, when: String) -> void:
	if v == null or not v.has_method("_layout_hand"):
		return
	var screen := Vector2(root.get_visible_rect().size)
	var cards := _hand(v)
	var hover: Variant = v.get("_hand_hover")
	var timing: Variant = v.get("_timing_card")

	# 1. The resting fan is centred on its strip.
	if hover == null and timing == null and not cards.is_empty():
		var lo := INF
		var hi := -INF
		for c in cards:
			var r := (c as Control).get_global_rect()
			lo = minf(lo, r.position.x)
			hi = maxf(hi, r.end.x)
		var strip := ((v.get("_hand_row") as Control).get_parent() as Control).get_global_rect()
		var off := (lo + hi) * 0.5 - strip.get_center().x
		if absf(off) > 12.0:
			_fail("hand-centred", "%s: fan centre is %+.0fpx off its strip" % [when, off])

	# 2. The model and the screen agree on the hand.
	var c := _combat()
	var me := int(v.call("_me")) if v.has_method("_me") else 0
	if c != null and me < c.players.size():
		var n_model: int = c.players[me].hand.size()
		if cards.size() != n_model:
			_fail("hand-count", "%s: %d cards on screen, %d in the hand" % [when, cards.size(), n_model])
		# 3. Energy shown is energy held.
		var el: Label = v.get("_energy_label")
		if el != null and el.is_visible_in_tree() and el.text.is_valid_int() \
				and int(el.text) != int(c.players[me].energy):
			_fail("energy-label", "%s: shows %s, model has %d" % [when, el.text, c.players[me].energy])

	# 4. Nothing on the HUD hangs off the screen or is cut short.
	for n in _all_controls(v):
		var ctl := n as Control
		if not ctl.is_visible_in_tree() or ctl in cards or _inside_hand(ctl, v):
			continue
		var r := ctl.get_global_rect()
		if r.size.x < 2 or r.size.y < 2 or r.size.x >= screen.x - 1:
			continue
		if r.position.x < -4 or r.position.y < -4 or r.end.x > screen.x + 4 or r.end.y > screen.y + 4:
			_fail("offscreen", "%s: %s %s leaves the screen" % [when, ctl.name, r])
		if ctl is Label:
			var lb := ctl as Label
			if lb.text != "" and lb.autowrap_mode == TextServer.AUTOWRAP_OFF \
					and lb.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING \
					and lb.get_minimum_size().x > r.size.x + 2 and lb.clip_text:
				_fail("text-cut", "%s: '%s' is clipped (%.0f > %.0f)" % [when, lb.text.left(30),
					lb.get_minimum_size().x, r.size.x])

	# 5. The resting hand never covers End Turn / Switch.
	for bname in ["_end_btn", "_switch_btn"]:
		var b: Control = v.get(bname)
		if b == null or not b.is_visible_in_tree():
			continue
		var br := b.get_global_rect()
		for card in cards:
			if card == hover or card == timing:
				continue
			if (card as Control).get_global_rect().grow(-6).intersects(br):
				_fail("hand-over-button", "%s: a resting card covers %s" % [when, b.name])
				break

	# 6. No script errors, ever.
	while not _errors.is_empty():
		_fail("script-error", String(_errors.pop_front()))

	# 7. No two hunters stand inside each other on the beast (request
	# 2026-09-22-1700-session-to-fixer-hunters-overlap-at-sigil: both "at the
	# sigil" drew on the exact same point). MIN_HUNTER_GAP is well under the
	# smallest real side-step (_stand_on_model: beast_width*0.055+0.30 to
	# EACH side, so >= ~0.6 apart whenever the offset is actually applied)
	# and well over the ~0.05 slack _place_hunters already tolerates as "not
	# moved", so it only fires on a genuine overlap, not layout noise.
	var hunters: Variant = v.get("_hunters")
	if hunters is Array and hunters.size() > 1:
		for a in range((hunters as Array).size()):
			for b in range(a + 1, (hunters as Array).size()):
				var pa: Vector3 = ((hunters[a] as Dictionary).get("home", Vector3.ZERO))
				var pb: Vector3 = ((hunters[b] as Dictionary).get("home", Vector3.ZERO))
				var d := pa.distance_to(pb)
				if d < MIN_HUNTER_GAP:
					_fail("hunters-overlap", "%s: hunters %d/%d are %.2fm apart (< %.2f) at %v / %v" \
						% [when, a, b, d, MIN_HUNTER_GAP, pa, pb])

	# 8. A hunter mid-climb stands ON the model's own climb marker
	# (combat_3d._stand_on_model), not floating off beside the body or fallen
	# back to the bounding-box guess that runs when a beast ships with no
	# climb_N anchors (checklist item 2; this is the "hunters land within
	# reach of a climb marker after a climb" check the baseline request asked
	# for). _place_hunters only takes the ground (t<=0.01) and sigil (t>=0.92)
	# branches around the ends -- skip those, they intentionally don't use
	# _climb_points. Height matches _stand_on_model exactly (h.y = anchor.y,
	# untouched by the side/clearance offsets), so any drift there means the
	# wrong branch ran. x tolerance is exactly _stand_on_model's own side
	# offset (stand_offset_x), so a hunter genuinely on the model's near/far
	# side still passes and only a real miss (wrong anchor, stale
	# climb_points, a fallback position) fails.
	var climb_points: Variant = v.get("_climb_points")
	var beast_box: Variant = v.get("_beast_box")
	if c != null and hunters is Array and c.boss != null and climb_points is Dictionary \
			and not (climb_points as Dictionary).is_empty() and beast_box is AABB:
		var height: int = maxi(int(c.boss.weak_point_height), 1)
		var width: float = (beast_box as AABB).size.x
		var tol: float = width * 0.055 + 0.30 + 0.05
		for h in (hunters as Array):
			var foot := int((h as Dictionary).get("foot", 0))
			var t := clampf(float(foot) / float(height), 0.0, 1.0)
			if t <= 0.01 or t >= 0.92:
				continue
			var home: Vector3 = (h as Dictionary).get("home", Vector3.ZERO)
			var anchor: Vector3 = v.call("foothold_anchor", climb_points, foot)
			if absf(home.y - anchor.y) > 0.05 or absf(home.x - anchor.x) > tol:
				_fail("hunter-off-marker", "%s: hunter at foothold %d is %.2fm from its climb marker (home %v, anchor %v, x-tol %.2f)" \
					% [when, foot, home.distance_to(anchor), home, anchor, tol])

	# 9. The camera keeps the ACTIVE hunter (the one you are playing) on screen
	# once things have settled -- checklist item 4, "the beast is framed, the
	# hunter is visible", and this playtester's own brief names exactly this
	# check as a gap ("camera keeps the active hunter inside the frame").
	# Checked only here, at the settled `when` _check() always runs at (after
	# a hop's own mid-flight transient has had a few frames to ease back) --
	# NOT sampled during the hop itself, which is a separate, already-
	# documented gap (the wide establishing shot leaving a climbing hunter
	# briefly tiny/off-frame; see the playtester status note) and not what
	# this check is asking. `is_position_behind` catches a camera looking
	# somewhere else entirely (a real break, never expected); the screen
	# bounds below are the FULL viewport with no HUD-safe-region trim (unlike
	# screenshot.gd's tighter `_report_visibility`, tuned for single frozen
	# states) precisely so this doesn't re-flag the already-known near-edge
	# framing gap as a new failure -- only a hunter that is not on screen AT
	# ALL once settled counts here.
	var cam: Camera3D = v.get("_cam")
	if cam != null and hunters is Array and me < (hunters as Array).size():
		var mine: Vector3 = ((hunters as Array)[me] as Dictionary).get("home", Vector3.ZERO)
		if cam.is_position_behind(mine):
			_fail("hunter-behind-camera", "%s: the active hunter is behind the camera -- cannot be on screen at all" % when)
		else:
			var p := cam.unproject_position(mine)
			if p.x < -2.0 or p.y < -2.0 or p.x > screen.x + 2.0 or p.y > screen.y + 2.0:
				_fail("hunter-offscreen", "%s: the active hunter projects to %v, off the %v screen entirely" % [when, p.round(), screen])


func _all_controls(n: Node) -> Array:
	var out: Array = []
	for c in n.get_children():
		if c is Control:
			out.append(c)
		out.append_array(_all_controls(c))
	return out


func _inside_hand(ctl: Control, v: Node) -> bool:
	var row: Control = v.get("_hand_row")
	return row != null and (row == ctl or row.is_ancestor_of(ctl))


# --------------------------------------------------------------- modes

func _run() -> void:
	await _frames(60)
	var v := _view()
	_note("playtest mode=%s beast=%s view=%s" % [_mode, _beast, v.name if v else "none"])
	_check(v, "start")
	if _mode == "hover":
		await _hover_sweep()
	elif _mode == "hands":
		await _hand_sizes()
	else:
		await _play()
	_finish()


## Every hand size a run can produce, 1..10, laid out and checked — a six-card
## hand only turns up when the draw allows, so do not wait for one.
func _hand_sizes() -> void:
	var c := _combat()
	var ids := ["tongue_snap", "leap", "scramble", "hop", "pounce", "brace",
		"leapfrog", "flick", "take_aim", "tongue_snap"]
	for n in range(1, 11):
		_step = n
		c.players[0].hand.clear()
		for i in n:
			c.players[0].hand.append(Content.make_card(ids[i]))
		Session.host._broadcast_state()
		await _frames(20)
		_check(_view(), "hand of %d" % n)
		await _shot()


## A still mouse must never make the raised card change. Parks the pointer at a
## grid of points across each card's resting (visible) face, holds it still for
## half a second, and counts how often `_hand_hover` flips while it waits.
func _hover_sweep() -> void:
	var v := _view()
	var screen := Vector2(root.get_visible_rect().size)
	var cards := _hand(v)
	var worst := 0
	for i in cards.size():
		# Resting geometry first, with nothing hovered.
		_move(Vector2(screen.x * 0.5, screen.y * 0.3))
		await _frames(8)
		var r := (cards[i] as Control).get_global_rect()
		var top := r.position.y
		var bottom := minf(r.end.y, screen.y - 2)
		for fy in [0.08, 0.3, 0.55, 0.8, 0.97]:
			for fx in [0.25, 0.5, 0.75]:
				var at := Vector2(r.position.x + r.size.x * fx, top + (bottom - top) * fy)
				_move(Vector2(screen.x * 0.5, screen.y * 0.3))
				await _frames(4)
				_move(at)
				var flips := 0
				var last: Variant = v.get("_hand_hover")
				for _f in 30:
					await process_frame
					# re-send the same position: a real mouse keeps reporting it
					_move(at)
					var h: Variant = v.get("_hand_hover")
					if h != last:
						flips += 1
						last = h
				worst = maxi(worst, flips)
				if flips > 1:
					_fail("hover-flicker", "card %d, mouse still at %s: raised card changed %d times in 30 frames"
						% [i, at.round(), flips])
					if flips == worst:
						await _shot()
		_step += 1
	_note("hover sweep: worst %d flips for a still mouse (0-1 is correct)" % worst)


## Plays the fight through real clicks.
func _play() -> void:
	var screen := Vector2(root.get_visible_rect().size)
	var idle := 0
	for s in _steps:
		_step = s
		var v := _view()
		var c := _combat()
		if c == null or c.phase == Combat.Phase.OVER or v == null or not v.has_method("_layout_hand"):
			_note("fight over at step %d" % s)
			break
		var me := int(v.call("_me"))
		var before := _snap(c, me)
		# The hunter's pre-climb world position, read now — before this step's
		# click can change it — so a real climb this step can be watched against
		# where it actually started (checklist item 3: the jump animation).
		var hunters_before: Variant = v.get("_hunters")
		var climb_from := Vector3.ZERO
		var have_climb_from := false
		if hunters_before is Array and me < (hunters_before as Array).size():
			climb_from = ((hunters_before as Array)[me] as Dictionary).get("home", Vector3.ZERO)
			have_climb_from = true
		var action := ""
		var cards := _hand(v)
		var target: CardView = null
		for cv in cards:
			if cv is CardView and not (cv as CardView).disabled:
				target = cv
				break
		if target != null:
			# hover first, the way a hand does, then click where it now IS
			_move((target as Control).get_global_rect().get_center())
			await _frames(6)
			var at := (target as Control).get_global_rect().get_center()
			action = "play '%s'%s (hunter %d) at %s" % [String((target as CardView).get("_data").get("name", "?")) if (target as CardView).get("_data") is Dictionary else "?",
				" [timed]" if (target as CardView).get("_data") is Dictionary and bool((target as CardView).get("_data").get("timed", false)) else "",
				me, at.round()]
			await _click(at)
			await _frames(4)
			await _drive_timing(v)
			# a pick (meld / burn / cheapen) asks for one or two more cards; pick
			# different cards each time, from the right end, never the card itself
			var guard := 0
			while is_instance_valid(v) and v.has_method("_pick_for_selection") and not (v.get("_selecting") as Dictionary).is_empty() and guard < 4:
				guard += 1
				var sel: Dictionary = v.get("_selecting")
				var play_i := int(sel.get("play_index", -1))
				var sac_i := int(sel.get("sac", -1))
				var pick: Control = null
				for x in _hand(v):
					var d: Dictionary = (x as CardView).get("_data")
					var ix := int(d.get("index", -1))
					if ix != play_i and ix != sac_i:
						pick = x
				if pick == null:
					break
				_move(pick.get_global_rect().get_center())
				await _frames(4)
				await _click(pick.get_global_rect().get_center())
				await _frames(6)
		else:
			var eb: Button = v.get("_end_btn")
			action = "End Turn"
			await _click(eb.get_global_rect().get_center())
		# A foothold change is a climb (Combat3D.hunter_move_kind: "was != foot",
		# nothing else) -- watch the hop itself (frame-strip + in-flight
		# checks) instead of the blanket wait, so checklist item 3
		# (anticipation squash, a clear arc, landing squash, no pop) is judged
		# on every real climb in the run, not left for a hand-picked repro.
		var watched := false
		if have_climb_from:
			await _frames(2)
			var cm := _combat()
			if cm != null and me < cm.players.size() and int(cm.players[me].foothold) != int(before.get("foot", -999)):
				await _watch_hop(_view(), me, climb_from)
				watched = true
		await _frames(43 if watched else 45)
		v = _view()
		if v == null or not v.has_method("_layout_hand"):
			_note("step %d: %s -> the fight ended (screen is now %s)" % [s, action, v.name if v else "none"])
			break
		c = _combat()
		var after := _snap(c, me) if c != null else {}
		if after == before and c != null and c.phase != Combat.Phase.OVER:
			idle += 1
			_fail("dead-click", "%s changed nothing (energy/hand/hp/foothold/turn all the same)" % action)
			if idle >= 3:
				_fail("stuck", "three actions in a row did nothing")
				break
		else:
			idle = 0
		_note("step %d: %s -> %s" % [s, action, _delta(before, after)])
		_check(v, action)
		await _shot()
	_move(Vector2(screen.x * 0.5, screen.y * 0.3))


## Plays whatever timing face opened, on the beat.
func _drive_timing(v: Node) -> void:
	if not is_instance_valid(v):
		return
	var circle: Control = v.get("_circle")
	var guard := 0
	while is_instance_valid(v) and is_instance_valid(circle) and circle.visible and bool(circle.call("is_live")) and guard < 600:
		guard += 1
		var off: float = circle.call("_offset")
		var hit := int(circle.get("_hits_done"))
		if absf(off) < 0.02 and hit < (circle.get("_notes") as Array).size():
			await _click(circle.call("_screen", hit))
		await process_frame
	if not is_instance_valid(v):
		return   # the fight ended on that hit and its screen is gone
	var tc: Variant = v.get("_timing_card")
	guard = 0
	while tc != null and is_instance_valid(tc) and bool(tc.call("is_timing")) and guard < 600:
		guard += 1
		await _click((tc as Control).get_global_rect().get_center())
		await _frames(3)


## Slow the WHOLE ENGINE to this fraction of real speed while a hop is being
## sampled. `_hop`'s Tween (combat_3d.gd) advances by Engine.time_scale-scaled
## delta every frame, same as everything else in Godot 4 unless a tween opts
## out with set_ignore_time_scale -- combat_3d.gd's climb tweens never do. This
## sandbox's software renderer draws a real frame every ~0.1-0.3s, which used
## to leave a single-leg hop (one 0.34s tween) only 0-3 samples before it
## finished: not this bot missing frames, but the hop itself using up its
## real-time budget faster than a frame could be drawn. Running the SAME
## renderer at 1/6 game speed makes the tween take 6x longer in wall-clock
## seconds without changing one frame of the animation itself (the eased
## curves, the apex, the squash amounts: all still `hop_arc`/`_hop`'s own
## numbers -- only how much wall-clock time separates the frames this bot can
## actually catch). Restored to 1.0 the instant the hop is judged, on every
## exit path, so it never leaks into the rest of the run.
const HOP_TIME_SCALE := 1.0 / 6.0

## Watches one hunter's climb hop (combat_3d._hop) live: samples the animated
## node's own position/scale every frame while its climb tween runs (not the
## bookkeeping dict, which combat_3d.gd sets to the destination the instant
## the climb is decided, before the tween even starts -- sampling the dict
## would never catch the hunter failing to actually GET there), saves a frame
## every sampled tick as a strip, and checks the shape of the hop once it
## lands. Checklist item 3.
func _watch_hop(v: Node, me: int, climb_from: Vector3) -> void:
	if not is_instance_valid(v):
		return
	var hunters: Variant = v.get("_hunters")
	var climb_tw: Variant = v.get("_climb_tw")
	if not (hunters is Array) or me >= (hunters as Array).size() or not (climb_tw is Dictionary):
		return
	var h: Dictionary = (hunters as Array)[me]
	var node: Node3D = h.get("node") as Node3D
	var body: Node3D = h.get("body") as Node3D
	var tw: Tween = (climb_tw as Dictionary).get(me) as Tween
	if node == null or tw == null or not tw.is_valid():
		return
	# `flight` (the numeric record _check_hop reads) is sampled every real frame
	# for as long as the tween genuinely runs -- capped only by `guard`, sized
	# generously for HOP_TIME_SCALE's slow-mo (a multi-leg sigil climb that took
	# 12 real frames at 1x needs ~6x that before it actually finishes at 1/6
	# speed). `shots` -- the PNGs actually written to disk -- is throttled far
	# lower: nobody needs 150 frames of one hop to read a strip, and at 1/6
	# speed that many renders would cost real minutes for no benefit.
	# Un-syncing the two caps matters: an earlier version capped the SAMPLING
	# loop at the same low number as the image throttle, so under slow-mo a
	# long climb got cut off mid-flight -- still rising, still squashed -- and
	# the code below then misread that mid-air moment as "landed," a real
	# false positive (a squash that "never recovered" because the hunter
	# hadn't actually landed yet). Never judge a hop the loop didn't see land.
	var flight: Array = []   # {pos: Vector3, scale: Vector3}
	var shots := 0
	var guard := 0
	Engine.time_scale = HOP_TIME_SCALE
	while is_instance_valid(node) and tw.is_valid() and tw.is_running() and guard < 300:
		guard += 1
		flight.append({"pos": node.position, "scale": body.scale if is_instance_valid(body) else Vector3.ONE})
		await RenderingServer.frame_post_draw
		if is_instance_valid(node) and shots < 24:
			var img := root.get_viewport().get_texture().get_image()
			img.save_png("%s/hop_%03d_%02d.png" % [_out, _step, shots])
			shots += 1
	if not is_instance_valid(node):
		Engine.time_scale = 1.0
		return   # the fight ended mid-hop
	if tw.is_valid() and tw.is_running():
		# The guard cap fired before the tween finished on its own -- we do not
		# know the shape of the rest of the hop, so say so and judge nothing,
		# rather than guessing from a truncated flight.
		Engine.time_scale = 1.0
		_note("step %d: hop still mid-flight after %d samples (guard cap) -- gave up watching, not judged" % [_step, flight.size()])
		return
	Engine.time_scale = 1.0
	await _frames(8)   # back at real speed: let the landing recoil (0.06s + 0.16s) settle
	var landed := node.position
	var landed_scale: Vector3 = body.scale if is_instance_valid(body) else Vector3.ONE
	_check_hop(flight, climb_from, landed, landed_scale)


## The checks checklist item 3 asks for, read off `_watch_hop`'s samples: a
## real arc (rises above a straight line between the endpoints, not a slide)
## and a squash that actually shows (anticipation/impact) -- gated on
## `covered_from_start` below -- plus no pop left behind at the end (the
## squash actually recovers once the hunter lands), which isn't gated: it
## reads the settled state after `is_running()` is conclusively false, not a
## race.
##
## `covered_from_start`: this sandbox's software renderer is slow enough
## (~0.1-0.3s/frame) relative to one hop leg (0.34s) that the first sample
## this bot manages to catch sometimes already lands well past the apex --
## caught live the first time this check ran: a 3-sample capture of a
## descending hop whose peak sat BELOW its start height, purely because
## sampling began after the rise was already over, not because the rise
## never happened. Asserting hop-flat/hop-no-squash on a capture like that
## would blame the game for this bot's own late start. So: only trust those
## two when the first sample lands within 40% of the whole hop's distance
## from where it started (a real rise/squash happens early, well inside
## that window); past that, note the partial capture and judge nothing.
func _check_hop(flight: Array, from_pos: Vector3, to_pos: Vector3, landed_scale: Vector3) -> void:
	if flight.size() < 2:
		_note("step %d: hop finished before it could be sampled (too fast for this frame rate) -- not checked" % _step)
		return
	var peak_y := -INF
	var max_scale_dev := 0.0
	for f in flight:
		peak_y = maxf(peak_y, (f["pos"] as Vector3).y)
		max_scale_dev = maxf(max_scale_dev, _scale_dev(f["scale"]))
	var total_dist := from_pos.distance_to(to_pos)
	var first_dist := (flight[0]["pos"] as Vector3).distance_to(from_pos)
	var covered_from_start := total_dist < 0.05 or first_dist < total_dist * 0.4
	var straight_top := maxf(from_pos.y, to_pos.y)
	if covered_from_start:
		if peak_y < straight_top - 0.03:
			_fail("hop-flat", "step %d: hop peak y=%.2f never rose above its endpoints (%.2f -> %.2f) -- reads as a slide, not a jump"
				% [_step, peak_y, from_pos.y, to_pos.y])
		if max_scale_dev < 0.03:
			_fail("hop-no-squash", "step %d: hunter body scale never left Vector3.ONE (max deviation %.3f) during the hop -- no anticipation/impact squash"
				% [_step, max_scale_dev])
	var end_dev: float = _scale_dev(landed_scale)
	if end_dev > 0.03:
		_fail("hop-leftover-squash", "step %d: landed with body scale %v, %.3f off Vector3.ONE -- squash never recovered (a pop at the end)"
			% [_step, landed_scale, end_dev])
	_note("step %d: hop watched -- %d in-flight samples (%s), peak y %.2f (endpoints %.2f -> %.2f), max squash dev %.3f"
		% [_step, flight.size(), "from the start" if covered_from_start else "partial capture, arc/squash not judged",
			peak_y, from_pos.y, to_pos.y, max_scale_dev])


func _scale_dev(s: Vector3) -> float:
	var d := (s - Vector3.ONE).abs()
	return maxf(d.x, maxf(d.y, d.z))


func _snap(c: Combat, me: int) -> Dictionary:
	var p = c.players[me]
	return {"energy": p.energy, "hand": p.hand.size(), "boss": c.boss.hp,
		"foot": p.foothold, "hp": p.combatant.hp,
		"turn": c.round_num, "played": c.cards_played_total}


func _delta(a: Dictionary, b: Dictionary) -> String:
	var parts: PackedStringArray = []
	for k in a:
		if b.get(k) != a[k]:
			parts.append("%s %s→%s" % [k, a[k], b.get(k)])
	return ", ".join(parts) if parts else "no change"


func _finish() -> void:
	# A GDScript error inside the bot's own coroutine just returns from it, so
	# anything still in the sink is the reason the run ended early.
	while not _errors.is_empty():
		_fail("script-error", String(_errors.pop_front()))
	var lines: PackedStringArray = ["# Playtest report", "",
		"mode `%s`, beast `%s`, %d steps" % [_mode, _beast, _step + 1], "",
		"## Result", ""]
	if _fails.is_empty():
		lines.append("**All checks passed.**")
	else:
		for k in _fails:
			lines.append("- **%s**: %d" % [k, _fails[k]])
	lines.append_array(["", "## Log", ""])
	lines.append_array(_log)
	var f := FileAccess.open(_out + "/report.md", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	print("PLAYTEST %s: %d failing check(s) %s" % ["OK" if _fails.is_empty() else "FAIL",
		_fails.size(), _fails])
	quit(_fails.size())
