## Sound effects (build step 5+). Generates simple placeholder tones in code, so
## the game has audio with NO asset files yet. To use real sounds later, drop an
## `.ogg`/`.wav` into res://audio/ named after the event (e.g. audio/card.ogg) —
## it's picked up automatically, overriding the synthesized tone.
##
## Static + lazy: the first play() spins up a small AudioStreamPlayer pool under
## the scene root, so callers just do `Sfx.play("card")` — no autoload needed.
class_name Sfx
extends RefCounted

const AUDIO_DIR := "res://audio/"
const SAMPLE_RATE := 22050

# event -> {f: base freq, d: seconds, w: "sine"|"square"}
const DEFS := {
	"card": {"f": 620.0, "d": 0.05, "w": "square"},
	"attack": {"f": 240.0, "d": 0.10, "w": "square"},
	"block": {"f": 160.0, "d": 0.12, "w": "sine"},
	"end_turn": {"f": 360.0, "d": 0.10, "w": "sine"},
	"reward": {"f": 720.0, "d": 0.16, "w": "sine"},
	"nail": {"f": 900.0, "d": 0.13, "w": "sine"},
	"slip": {"f": 190.0, "d": 0.14, "w": "square"},
	"win": {"f": 860.0, "d": 0.35, "w": "sine"},
	"lose": {"f": 120.0, "d": 0.45, "w": "sine"},
}

static var _players: Array = []
static var _sounds: Dictionary = {}
static var _idx := 0


static func play(event: String) -> void:
	_ensure()
	if _players.is_empty() or not _sounds.has(event):
		return
	var p: AudioStreamPlayer = _players[_idx]
	_idx = (_idx + 1) % _players.size()
	p.stream = _sounds[event]
	p.play()


static func _ensure() -> void:
	if not _players.is_empty():
		return
	var loop := Engine.get_main_loop()
	if not (loop is SceneTree):
		return
	var root: Window = (loop as SceneTree).root
	if root == null:
		return
	for ev in DEFS:
		_sounds[ev] = _load_or_synth(ev)
	for _i in range(4):  # a small pool so quick sounds can overlap
		var pl := AudioStreamPlayer.new()
		root.add_child(pl)
		_players.append(pl)


## Prefer a real file in res://audio/ if present; otherwise synthesize a tone.
static func _load_or_synth(event: String) -> AudioStream:
	for ext in [".ogg", ".wav"]:
		var path: String = AUDIO_DIR + event + String(ext)
		if ResourceLoader.exists(path):
			return load(path)
	var d: Dictionary = DEFS[event]
	return _synth(float(d["f"]), float(d["d"]), String(d["w"]))


static func _synth(freq: float, dur: float, wave: String) -> AudioStreamWAV:
	var n := int(SAMPLE_RATE * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t := float(i) / SAMPLE_RATE
		var env := pow(1.0 - float(i) / n, 1.5)  # quick decay
		var s := sin(TAU * freq * t)
		if wave == "square":
			s = 1.0 if s >= 0.0 else -1.0
		data.encode_s16(i * 2, int(clampf(s * env * 0.35, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SAMPLE_RATE
	w.stereo = false
	w.data = data
	return w
