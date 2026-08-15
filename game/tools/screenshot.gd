## Visual verification harness. Boots the game into a chosen state, waits for a
## real rendered frame, saves a PNG, and quits — so UI work can be CHECKED BY
## LOOKING AT IT instead of shipped blind (headless can't render; this runs
## windowed, flashing a window for ~2s).
##
##   Godot_v4.7.1-stable_win64_console.exe --path game --script res://tools/screenshot.gd -- out=C:/path/shot.png state=combat
##
## states: menu | goblin (fight with the wordiest deck as the active hunter) |
##   3dselect 3dmap 3d 3dclimb 3dstrike 3dgrip 3dsel 3dreward 3devent 3dcampfire
##   3dshop 3dwon | 3dgame 3dloop (the router itself, walking a whole lap)
## modifiers: hold= (stop a driven sequence at a phase) beast= act= orbit=
extends SceneTree

var _out := "shot.png"
var _state := "combat"
var _hold := ""   # 3dloop: stop the lap at this phase instead of finishing it
var _beast := ""  # force a specific beast, to check a model that RNG rarely picks
var _act := 0     # 3dmap: fast-forward to this act, so later regions get looked at
var _orbit := 999.0  # 3D combat: drive the orbit camera to this yaw, in degrees


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out="):
			_out = a.substr(4)
		elif a.begins_with("state="):
			_state = a.substr(6)
		elif a.begins_with("hold="):
			_hold = a.substr(5)
		elif a.begins_with("beast="):
			_beast = a.substr(6)
		elif a.begins_with("act="):
			_act = int(a.substr(4))
		elif a.begins_with("orbit="):
			_orbit = float(a.substr(6))
	_failsafe()  # never hang the machine
	# Shots should show onboarding as a NEW player sees it, whatever this machine's
	# config happens to say — otherwise turning tips off while playing silently
	# changes what every screenshot verifies.
	Progress.reset_hints()
	Progress.set_hints_enabled(true)
	if _state == "menu":  # just the main menu, no session
		change_scene_to_file("res://views/menu.tscn")
		_capture()
		return
	var transport := LocalTransport.new()
	Session.transport = transport
	Session.host = GameHost.new(transport, 42, 2, true)  # deterministic solo game
	Session.client = GameClient.new(transport, 1)
	Session.client.join()
	if _state == "goblin":  # goblin as the ACTIVE hunter (slot 0) — wordiest cards
		Session.client.select_character("goblin_mech", 0)
		Session.client.select_character("frog", 1)
	elif _state != "3dselect":
		Session.client.select_character("frog", 0)
		Session.client.select_character("goblin_mech", 1)
	if _state in ["goblin", "3d", "3dclimb", "3dinspect",
			"3dstrike", "3dgame", "3dgrip", "3dsel", "3dreward", "3dwon"]:  # 3dloop deliberately starts ON the map  # step off the map into a fight
		var r: Run = Session.host._run
		var g := 0
		while r.phase == Run.Phase.MAP and g < 30:
			g += 1
			r.pick_node(int(r.available_nodes()[0]))
		Session.host._broadcast_state()
	if _state == "3dshop":  # the same stocked trader, shown by the 3D client
		var s3: Run = Session.host._run
		s3.gold = 260
		s3.map_row = 0
		s3.node_type = "shop"
		s3._begin_shop()
		Session.host._broadcast_state()
	if _state == "3dcampfire":  # a campfire, shown by the 3D client
		var c4: Run = Session.host._run
		c4.map_row = 0
		c4.node_type = "rest"
		c4._begin_campfire()
		Session.host._broadcast_state()
	if _state == "3devent":  # the same forced event, shown by the 3D client
		var r3: Run = Session.host._run
		r3.map_row = 0
		r3.node_type = "event"
		r3._begin_event()
		Session.host._broadcast_state()
	if _state == "3dmap":  # a couple of rows in, so the walked route is visible
		var rm: Run = Session.host._run
		# one step for act 1; for later acts, walk the whole way there
		var steps: int = 1 if _act <= 0 else (_act * (RunMap.ROWS_PER_ACT + 1) + 1)
		for _s in range(steps):
			if rm.phase != Run.Phase.MAP or rm.available_nodes().is_empty():
				break
			rm.pick_node(int(rm.available_nodes()[0]))
			if rm.phase == Run.Phase.COMBAT:
				rm.combat.boss.hp = 0
				rm.combat.phase = Combat.Phase.OVER
				rm.sync()
			var spin := 0
			while rm.phase not in [Run.Phase.MAP, Run.Phase.WON, Run.Phase.LOST] and spin < 40:
				spin += 1
				match rm.phase:
					Run.Phase.REWARD:
						for slot in range(rm.player_count()):
							rm.pick_reward(slot, 0)
					Run.Phase.EVENT:
						rm.pick_event(0)
					Run.Phase.CAMPFIRE:
						for slot in range(rm.player_count()):
							rm.campfire_action(slot, "rest")
					Run.Phase.SHOP:
						rm.leave_shop()
					_:
						break
		print("MAP at row %d, phase %s" % [rm.map_row, rm.phase])
		Session.host._broadcast_state()
	if _state == "3dstrike":  # mid-ascent AND mid-hit, to check the 3D juice
		var cs: Combat = Session.host._run.combat
		cs.players[0].foothold = cs.boss.weak_point_height
		cs.players[1].foothold = maxi(cs.boss.weak_point_height - 1, 1)
		Session.host._broadcast_state()
	if _beast != "" and Session.host._run.combat != null:
		Session.host._run.combat.boss = Content.build_boss(_beast)
		Session.host._broadcast_state()
	if _state in ["3dreward", "3dwon"]:  # fell the beast so the phase after opens
		var rr2: Run = Session.host._run
		rr2.combat.boss.hp = 0
		rr2.combat.phase = Combat.Phase.OVER
		rr2.sync()
		if _state == "3dwon":  # drive it all the way to the end of the run
			var spin2 := 0
			while rr2.phase not in [Run.Phase.WON, Run.Phase.LOST] and spin2 < 400:
				spin2 += 1
				match rr2.phase:
					Run.Phase.REWARD:
						for sl in range(rr2.player_count()):
							rr2.pick_reward(sl, 0)
					Run.Phase.MAP:
						rr2.pick_node(int(rr2.available_nodes()[0]))
						if rr2.phase == Run.Phase.COMBAT:
							rr2.combat.boss.hp = 0
							rr2.combat.phase = Combat.Phase.OVER
							rr2.sync()
					Run.Phase.EVENT: rr2.pick_event(0)
					Run.Phase.CAMPFIRE:
						for sl2 in range(rr2.player_count()):
							rr2.campfire_action(sl2, "rest")
					Run.Phase.SHOP: rr2.leave_shop()
					_: break
			print("RUN ended in phase %s" % rr2.phase)
		Session.host._broadcast_state()
	if _state == "3dsel":  # a Meld in hand, so the pick flow can be exercised
		var cm: Combat = Session.host._run.combat
		cm.players[0].hand[0] = Content.make_card("meld")
		cm.players[0].energy = 5
		Session.host._broadcast_state()
	if _state == "3dgrip":  # BETWEEN holds: the grip timer should be live
		var cg: Combat = Session.host._run.combat
		# find a height that is neither the ground, a ledge, nor the sigil
		var unsafe := 1
		for h in range(1, cg.boss.weak_point_height):
			if not (h in cg.boss.ledges):
				unsafe = h
				break
		cg.players[0].foothold = unsafe
		cg.players[1].foothold = maxi(cg.boss.weak_point_height - 1, 1)
		Session.host._broadcast_state()
	if _state == "3dclimb":  # mid-ascent in 3D — hunters should be up ON the beast
		var c3: Combat = Session.host._run.combat
		c3.players[0].foothold = c3.boss.weak_point_height
		c3.players[1].foothold = maxi(c3.boss.weak_point_height - 1, 1)
		Session.host._broadcast_state()
	# the router for anything it stages, the overworld for 3dmap, else the fight
	var scene := "res://views/combat_3d.tscn"
	if _state in ["3dgame", "3dloop", "3dreward", "3dwon", "3devent",
			"3dcampfire", "3dshop", "3dselect"]:
		scene = "res://views/game_3d.tscn"
	elif _state == "3dmap":
		scene = "res://views/overworld_3d.tscn"
	change_scene_to_file(scene)
	_capture()


## The router's whole job is showing the right client for the phase, so check
## exactly that: what phase does the host report, and what is actually mounted.
func _router_is(router: Node, phase: String, want_scene: String) -> void:
	var actual := String(Session.client.shared.get("phase", "?"))
	var mounted := "(nothing)"
	if router.get_child_count() > 0:
		mounted = router.get_child(router.get_child_count() - 1).name
	var ok: bool = actual == phase and mounted == want_scene
	print("ROUTER %s: phase=%s (wanted %s) showing=%s (wanted %s)" % [
		"OK" if ok else "FAIL", actual, phase, mounted, want_scene])


## Wait for the combat camera to stop moving.
##
## It eases toward its target over real seconds (the opening pull-in, and the ride
## up the beast as you climb), and this harness runs frames far faster than real
## time — so a fixed frame count catches it mid-glide and every shot lies about
## where the camera settles. Wait on the state, not on a count.
func _await_camera(view: Node) -> void:
	if view == null or not view.has_method("snap_camera"):
		return
	view.call("snap_camera")
	for _i in 3:  # a few settled frames before the shot
		await process_frame


## Where the things the player MUST see actually landed, in pixels.
##
## Eyeballing a 1280x720 render can't settle whether a hunter is on screen or two
## pixels behind the coach panel — and "can I see my climbers and the sigil" is
## the whole readability question the big-beast framing risks. So project them and
## check against the region the HUD does not own.
##
## Safe region excludes the left rail (x<312), the top bar + grip strip (y<140,
## which is where the grip bar ends), and the bottom-right party + buttons block.
## The coach now lives along the bottom centre, inside the party block's row.
func _report_visibility(view: Node) -> void:
	if view == null or not view.has_method("_climb_frame"):
		return
	var cam: Camera3D = view.get("_cam")
	if cam == null:
		return
	var vp := Vector2(1280, 720)
	var box: AABB = view.get("_beast_box")
	print("CAM pos=%v pivot=%v dist=%.2f pitch=%.3f h=%.2f v=%.2f | box pos=%v size=%v" % [
		cam.position, view.get("_pivot"), view.get("_dist"), view.get("_pitch"),
		cam.h_offset, cam.v_offset, box.position, box.size])
	var marks: Array = []
	var hunters: Array = view.get("_hunters")
	for i in range(hunters.size()):
		marks.append(["hunter%d" % i, (hunters[i] as Dictionary)["home"]])
	# The sigil is only expected on screen once the hunter you're PLAYING is close
	# enough for the camera's look-ahead to reach it. Below that, a Titan's weak
	# point being over the horizon of the frame is the scale doing its job, not a
	# framing bug — so don't assert it and don't cry wolf about it.
	var sigil: Node3D = view.get("_sigil")
	if sigil != null and sigil.visible:
		var me := int(view.call("_me"))
		var mine: float = float((hunters[me] as Dictionary)["home"].y) if me < hunters.size() else 0.0
		if mine > 0.5 and sigil.position.y - mine <= 3.5:
			marks.append(["sigil", sigil.position])
		else:
			print("VIS n/a sigil: hunter is %.1f below it — out of frame by design" % (
				sigil.position.y - mine))
	for m in marks:
		var world: Vector3 = m[1]
		if cam.is_position_behind(world):
			print("VIS FAIL %s: behind the camera" % m[0])
			continue
		var p: Vector2 = cam.unproject_position(world)
		var on: bool = p.x > 312 and p.x < vp.x - 8 and p.y > 140 and p.y < vp.y - 8
		# the bottom-right block is party + turn buttons
		if p.x > vp.x - 320 and p.y > vp.y - 220:
			on = false
		print("VIS %s %s: (%d, %d)" % ["OK" if on else "FAIL", m[0], int(p.x), int(p.y)])


func _capture() -> void:
	for _i in 15:  # let the scene lay out and draw
		await process_frame
	await _await_camera(current_scene)
	if _state.begins_with("3d") and _state not in ["3dmap", "3dloop"]:
		_report_visibility(current_scene)
	if _state == "3dinspect":  # open the card inspector on the first card in hand
		var vi := current_scene
		# Solo (which this harness always runs) nests each hunter's hand under
		# slots[]; co-op sends a flat "hand". Handle both.
		var priv: Dictionary = Session.client.private
		var hand: Array = priv.get("hand", [])
		if hand.is_empty() and priv.has("slots"):
			var slots: Array = priv["slots"]
			if not slots.is_empty():
				hand = (slots[0] as Dictionary).get("hand", [])
		if vi != null and vi.has_method("_show_card_detail") and not hand.is_empty():
			vi.call("_show_card_detail", hand[0])
		for _i in 4:
			await process_frame
	if _state == "3dstrike":  # fire the 3D strike and catch the flash + dust
		var v3 := current_scene
		if v3 != null and v3.has_method("_strike"):
			v3.call("_strike", true)
		# The damage number rides the snapshot diff (hp dropped), which this state
		# fakes rather than actually dealing — so fire the popup directly too, or
		# the one state whose whole job is checking the juice would miss it.
		if v3 != null and v3.has_method("_damage_popup"):
			var sig: Node3D = v3.get("_sigil")
			var where: Vector3 = sig.position if sig != null else Vector3.ZERO
			v3.call("_damage_popup", 34, where, true, false)
			v3.call("_damage_popup", 11, where + Vector3(-1.6, -1.2, 0.0), false, true)
		for _i in 8:  # let the popup rise a little before the shutter
			await process_frame
	if _state == "3dloop":  # walk the router through a whole lap of the run
		var router := current_scene
		var run: Run = Session.host._run
		_router_is(router, "map", "Overworld3D")
		run.pick_node(int(run.available_nodes()[0]))
		Session.host._broadcast_state()
		await process_frame
		_router_is(router, "combat", "Combat3D")
		run.combat.boss.hp = 0
		run.combat.phase = Combat.Phase.OVER
		run.sync()
		Session.host._broadcast_state()
		await process_frame
		_router_is(router, "reward", "Location3D")
		if _hold != "reward":  # otherwise stop here so the handover can be seen
			while run.phase == Run.Phase.REWARD:
				for slot in range(run.player_count()):
					run.pick_reward(slot, 0)
			Session.host._broadcast_state()
			await process_frame
			_router_is(router, "map", "Overworld3D")
		for _k in 8:
			await process_frame
	# Swing the camera BEFORE the walk test, not after. Now that the player can
	# look around the region, "can you still click a landmark from over here" is
	# the actual risk — and applying the orbit afterwards tested the pick from the
	# default angle every time while appearing to sweep.
	if _orbit < 900.0:
		var vo0 := current_scene
		if vo0 != null and vo0.has_method("_apply_orbit"):
			vo0.set("_yaw", deg_to_rad(_orbit))
			vo0.set("_user_framed", true)   # don't let a refresh undo it
			vo0.call("_apply_orbit")
			for _j in 3:
				await process_frame
	if _state == "3dmap":  # prove the click -> walk -> pick_node round trip
		var w := current_scene
		var before := int(Session.host._run.map_row)
		var cols: Array = w.get("_nodes").keys()
		if cols.is_empty():
			print("WALK FAIL: no reachable node was built")
		else:
			# project a reachable landmark BACK to a screen point and click it,
			# so the raycast itself is under test, not just the travel tween
			var cam: Camera3D = w.get("_cam")
			var target: Vector3 = w.get("_nodes")[cols[0]]["pos"]
			var screen: Vector2 = cam.unproject_position(target)
			var hit := int(w.call("_node_under_mouse", screen))
			print("WALK raycast: clicked %s -> node %d (wanted %d)" % [screen, hit, int(cols[0])])
			if hit == int(cols[0]):
				w.call("_travel_to", hit)
				# this harness runs frames far faster than real time, so wait on
				# the walk itself rather than a frame count
				var guard := 0
				while bool(w.get("_walking")) and guard < 3000:
					guard += 1
					await process_frame
				for _j in 4:
					await process_frame
				var after := int(Session.host._run.map_row)
				print("WALK %s: row %d -> %d, phase=%s" % [
					"OK" if after == before + 1 else "FAIL", before, after,
					Session.host._run.phase])
			else:
				print("WALK FAIL: raycast missed the landmark")
	if _state == "3dsel":  # tap Meld, then pick two cards, and check it fired
		var vs := current_scene
		var cs2: Combat = Session.host._run.combat
		var hand_before := int(cs2.players[0].hand.size())
		var meld: Dictionary = (Session.client.private.get("slots", [])[0] as Dictionary)["hand"][0]
		vs.call("_on_card_tapped", meld, CardView.new())
		await process_frame
		var armed: bool = not (vs.get("_selecting") as Dictionary).is_empty()
		print("SELECT armed=%s prompt=%s" % [armed, vs.get("_status").text])
		if _hold == "armed":  # stop here so the pick prompt can be seen
			for _k in 4:
				await process_frame
		else:
			vs.call("_pick_for_selection", 1)
			vs.call("_pick_for_selection", 2)
			for _j in 6:
				await process_frame
			var hand_after := int(Session.host._run.combat.players[0].hand.size())
			# Meld eats itself and both picks, leaving one fused card: 3 out, 1 in
			print("SELECT %s: hand %d -> %d, still selecting=%s" % [
				"OK" if hand_after == hand_before - 2 else "FAIL", hand_before, hand_after,
				not (vs.get("_selecting") as Dictionary).is_empty()])
	if _state == "3dgrip":  # let the grip run out and prove the fall lands
		var vg := current_scene
		var cg: Combat = Session.host._run.combat
		var before := int(cg.players[0].foothold)
		var guard := 0
		while not (vg.get("_climb") as Dictionary).is_empty() and guard < 40000:
			guard += 1
			await process_frame
		var after := int(Session.host._run.combat.players[0].foothold)
		print("GRIP %s: foothold %d -> %d after the timer emptied" % [
			"OK" if after < before else "FAIL", before, after])
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(_out)
	print("SHOT SAVED: %s (%dx%d)" % [_out, img.get_width(), img.get_height()])
	quit(0)


func _failsafe() -> void:
	await create_timer(10.0).timeout
	print("SHOT TIMEOUT")
	quit(1)
