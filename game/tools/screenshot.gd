## Visual verification harness. Boots the game into a chosen state, waits for a
## real rendered frame, saves a PNG, and quits — so UI work can be CHECKED BY
## LOOKING AT IT instead of shipped blind (headless can't render; this runs
## windowed, flashing a window for ~2s).
##
##   Godot_v4.7.1-stable_win64_console.exe --path game --script res://tools/screenshot.gd -- out=C:/path/shot.png state=combat
##
## states: select (character pick) | combat (solo fight, frog+goblin)
extends SceneTree

var _out := "shot.png"
var _state := "combat"
var _hold := ""   # 3dloop: stop the lap at this phase instead of finishing it


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out="):
			_out = a.substr(4)
		elif a.begins_with("state="):
			_state = a.substr(6)
		elif a.begins_with("hold="):
			_hold = a.substr(5)
	_failsafe()  # never hang the machine
	Progress.reset_hints()  # shots should show onboarding as a new player sees it
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
	elif _state != "select":
		Session.client.select_character("frog", 0)
		Session.client.select_character("goblin_mech", 1)
	if _state in ["combat", "goblin", "juice", "climbing", "3d", "3dclimb",
			"3dstrike", "3dgame", "3dgrip"]:  # 3dloop deliberately starts ON the map  # step off the map into a fight
		var r: Run = Session.host._run
		var g := 0
		while r.phase == Run.Phase.MAP and g < 30:
			g += 1
			r.pick_node(int(r.available_nodes()[0]))
		Session.host._broadcast_state()
	if _state == "shop":  # stock a trader so the screen can be checked
		var rs: Run = Session.host._run
		rs.gold = 260
		rs.map_row = 0
		rs.node_type = "shop"
		rs._begin_shop()
		Session.host._broadcast_state()
	if _state == "campfire":  # open a campfire so deck transformation is checkable
		var rc: Run = Session.host._run
		rc.map_row = 0
		rc.node_type = "rest"
		rc._begin_campfire()
		Session.host._broadcast_state()
	if _state == "event":  # force an event node so the screen can be checked
		var re: Run = Session.host._run
		re.map_row = 0
		re.node_type = "event"
		re._begin_event()
		Session.host._broadcast_state()
	if _state == "3dmap":  # a couple of rows in, so the walked route is visible
		var rm: Run = Session.host._run
		rm.pick_node(int(rm.available_nodes()[0]))
		rm.combat.boss.hp = 0
		rm.combat.phase = Combat.Phase.OVER
		rm.sync()
		while rm.phase == Run.Phase.REWARD:
			for slot in range(rm.player_count()):
				rm.pick_reward(slot, 0)
		Session.host._broadcast_state()
	if _state == "route":  # one node in, so the map shows where we stand
		var rr: Run = Session.host._run
		rr.pick_node(int(rr.available_nodes()[0]))
		rr.combat.boss.hp = 0
		rr.combat.phase = Combat.Phase.OVER
		rr.sync()
		while rr.phase == Run.Phase.REWARD:
			for slot in range(rr.player_count()):
				rr.pick_reward(slot, 0)
		Session.host._broadcast_state()
	if _state == "3dstrike":  # mid-ascent AND mid-hit, to check the 3D juice
		var cs: Combat = Session.host._run.combat
		cs.players[0].foothold = cs.boss.weak_point_height
		cs.players[1].foothold = maxi(cs.boss.weak_point_height - 1, 1)
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
	if _state == "climbing":  # mid-ascent, so marker placement can be checked
		var c: Combat = Session.host._run.combat
		c.players[0].foothold = c.boss.weak_point_height      # at the sigil
		c.players[1].foothold = maxi(c.boss.weak_point_height - 1, 1)  # clinging below
		Session.host._broadcast_state()
	# 3D clients: the overworld for 3dmap, the combat scene for the rest
	var scene := "res://views/combat_view.tscn"
	if _state in ["3dgame", "3dloop"]:
		scene = "res://views/game_3d.tscn"
	elif _state == "3dmap":
		scene = "res://views/overworld_3d.tscn"
	elif _state.begins_with("3d"):
		scene = "res://views/combat_3d.tscn"
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


func _capture() -> void:
	for _i in 15:  # let the scene lay out and draw
		await process_frame
	if _state == "3dstrike":  # fire the 3D strike and catch the flash + dust
		var v3 := current_scene
		if v3 != null and v3.has_method("_strike"):
			v3.call("_strike", true)
		for _i in 3:
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
		_router_is(router, "reward", "CombatView")
		if _hold != "reward":  # otherwise stop here so the handover can be seen
			while run.phase == Run.Phase.REWARD:
				for slot in range(run.player_count()):
					run.pick_reward(slot, 0)
			Session.host._broadcast_state()
			await process_frame
			_router_is(router, "map", "Overworld3D")
		for _k in 8:
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
	if _state == "juice":  # fire the strike effect and catch it mid-tween
		var view := current_scene
		if view != null and view.has_method("_juice_strike"):
			view.call("_juice_strike")
			view.call("_juice_shake")
			view.call("_spawn_emote", 0, load("res://assets/fx/emote_star.png"))
			view.call("_spawn_emote", 1, load("res://assets/fx/emote_swirl.png"))
		for _i in 6:
			await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(_out)
	print("SHOT SAVED: %s (%dx%d)" % [_out, img.get_width(), img.get_height()])
	quit(0)


func _failsafe() -> void:
	await create_timer(10.0).timeout
	print("SHOT TIMEOUT")
	quit(1)
