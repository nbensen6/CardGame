## Ambient music. Same drop-in philosophy as Sfx: tracks live at
## res://assets/music/<name>.ogg (menu, combat) — swap the file to change the
## music, no code. Static + lazy: one looping AudioStreamPlayer under the root.
class_name Music
extends RefCounted

const DIR := "res://assets/music/"
const VOLUME_DB := -14.0  # ambient — under the SFX

static var _player: AudioStreamPlayer
static var _current := ""


static func play(track: String) -> void:
	if not Progress.music_enabled():
		_current = track   # remember the intent so unmuting can resume it
		if _player != null:
			_player.stop()
		return
	if track == _current and _player != null and _player.playing:
		return
	_ensure()
	if _player == null:
		return
	var path := DIR + track + ".ogg"
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	_player.stream = stream
	# Deferred: play() may be called from a _ready while the player's own deferred
	# add_child hasn't run yet (root is busy setting up children). FIFO order
	# guarantees the add lands first.
	_player.play.call_deferred()
	_current = track


static func stop() -> void:
	_current = ""
	if _player != null:
		_player.stop()


## Apply the current setting right now — the toggle has to be audible on the tap,
## not on the next scene change.
static func refresh() -> void:
	if not Progress.music_enabled():
		if _player != null:
			_player.stop()
		return
	var want := _current
	_current = ""      # force play() past its "already playing this" guard
	if want != "":
		play(want)


static func _ensure() -> void:
	if _player != null:
		return
	var loop := Engine.get_main_loop()
	if not (loop is SceneTree):
		return
	var root: Window = (loop as SceneTree).root
	if root == null:
		return
	_player = AudioStreamPlayer.new()
	_player.volume_db = VOLUME_DB
	root.add_child.call_deferred(_player)  # safe even when called from a _ready
