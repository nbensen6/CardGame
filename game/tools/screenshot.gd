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


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out="):
			_out = a.substr(4)
		elif a.begins_with("state="):
			_state = a.substr(6)
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
	if _state in ["combat", "goblin", "juice", "climbing", "3d", "3dclimb"]:  # step off the map into a fight
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
	# state=3d renders the prototype 3D client instead of the 2D one
	change_scene_to_file("res://views/combat_3d.tscn" if _state.begins_with("3d")
		else "res://views/combat_view.tscn")
	_capture()


func _capture() -> void:
	for _i in 15:  # let the scene lay out and draw
		await process_frame
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
