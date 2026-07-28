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
	change_scene_to_file("res://views/combat_view.tscn")
	_capture()


func _capture() -> void:
	for _i in 15:  # let the scene lay out and draw
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
