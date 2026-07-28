## Sound-effect generator (an sfxr/Bfxr-style synthesizer, in code).
##
## Rather than hand-tune a web tool by ear (which I can't hear), this bakes the
## whole game palette to real .wav files in res://audio/ from explicit parameters
## chosen for the "small charming climbers vs. a huge weighty beast" identity.
## The game (ui/sfx.gd) auto-loads res://audio/<event>.wav, so these override the
## code fallback tones the moment they exist.
##
## To regenerate after tweaking a parameter:
##   Godot_v4.7.1-stable_win64_console.exe --headless --path "G:\Co Op Game\game" --script res://tools/gen_sfx.gd
##
## Then open the project once so Godot imports the new .wav files.
##
## Synth features: square/saw/sine/triangle/noise voices, ADSR + sustain punch,
## exponential pitch glide, vibrato, one-pole low/high-pass filters, and two
## composition helpers — `notes` (a sequence, for chimes/arpeggios) and `layers`
## (summed voices, for meaty impacts). All deterministic (seeded noise).
extends SceneTree

const SR := 44100
const OUT_DIR := "res://audio/"


func _init() -> void:
	if not DirAccess.dir_exists_absolute(OUT_DIR):
		DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var defs := _defs()
	for name in defs:
		var samples := _render(defs[name])
		var path := OUT_DIR + String(name) + ".wav"
		_write_wav(path, samples)
		print("  wrote %-18s %5d samples  %.3fs" % [String(name) + ".wav", samples.size(), float(samples.size()) / SR])
	print("\nDone — %d sounds written to %s" % [defs.size(), OUT_DIR])
	quit(0)


# --- The palette ----------------------------------------------------------
# Each event maps to synth parameters. Comments say what the sound "is".
func _defs() -> Dictionary:
	return {
		# A hunter plays a card — a light, papery tap. Quick and unobtrusive.
		"card": {
			"wave": "triangle", "freq": 660.0, "freq_end": 540.0,
			"attack": 0.004, "sustain": 0.010, "decay": 0.055,
			"punch": 0.3, "lp": 4200.0, "gain": 0.55,
		},
		# A hunter strikes the armored hide — a light "tk" that doesn't bite.
		"attack": {
			"wave": "noise", "attack": 0.001, "sustain": 0.010, "decay": 0.060,
			"punch": 0.5, "hp": 900.0, "lp": 3200.0, "gain": 0.60, "seed": 7,
		},
		# Brace / block — a low, woody thud. Reassuring, soft.
		"block": {
			"wave": "sine", "freq": 210.0, "freq_end": 120.0,
			"attack": 0.002, "sustain": 0.020, "decay": 0.110,
			"punch": 0.4, "lp": 1400.0, "gain": 0.75,
		},
		# End of turn — a gentle descending two-tone. Calm hand-off.
		"end_turn": {
			"wave": "sine", "freq": 520.0, "freq_end": 340.0,
			"attack": 0.006, "sustain": 0.030, "decay": 0.090,
			"lp": 3000.0, "gain": 0.6,
		},
		# Card reward — a pleasant rising two-note chime.
		"reward": {"gain": 0.7, "notes": [
			{"f": 659.0, "d": 0.09, "w": "sine"},
			{"f": 988.0, "d": 0.18, "w": "sine"},
		]},
		# Grapple timing SUCCESS — a bright metallic "ting" that jumps up.
		"nail": {"gain": 0.75, "notes": [
			{"f": 1047.0, "d": 0.05, "w": "triangle"},
			{"f": 1568.0, "d": 0.12, "w": "triangle"},
		]},
		# Grapple timing FUMBLE — a deflating downward "womp".
		"slip": {
			"wave": "saw", "freq": 320.0, "freq_end": 110.0,
			"attack": 0.002, "sustain": 0.020, "decay": 0.170,
			"lp": 1600.0, "gain": 0.7,
		},
		# Victory — a small triumphant major arpeggio (C E G C).
		"win": {"gain": 0.85, "notes": [
			{"f": 523.0, "d": 0.11, "w": "triangle"},
			{"f": 659.0, "d": 0.11, "w": "triangle"},
			{"f": 784.0, "d": 0.11, "w": "triangle"},
			{"f": 1047.0, "d": 0.26, "w": "triangle"},
		]},
		# Defeat — a slow descending minor fall.
		"lose": {"gain": 0.8, "notes": [
			{"f": 330.0, "d": 0.16, "w": "sine"},
			{"f": 262.0, "d": 0.18, "w": "sine"},
			{"f": 196.0, "d": 0.34, "w": "sine"},
		]},

		# --- climb loop (new) -------------------------------------------------
		# Gaining a foothold — a short, dry scrape/grip. Filtered noise.
		"climb": {
			"wave": "noise", "attack": 0.002, "sustain": 0.018, "decay": 0.060,
			"punch": 0.4, "hp": 700.0, "lp": 2600.0, "gain": 0.5, "seed": 3,
		},
		# Reaching the weak point — a bright three-note "you made it!" flourish.
		"reach_sigil": {"gain": 0.8, "notes": [
			{"f": 784.0, "d": 0.07, "w": "triangle"},
			{"f": 1047.0, "d": 0.07, "w": "triangle"},
			{"f": 1319.0, "d": 0.18, "w": "triangle"},
		]},
		# The beast bucks (Sweep / attack_all) — a heavy low buckling rumble.
		"shake": {"gain": 0.95, "layers": [
			{"wave": "square", "freq": 92.0, "freq_end": 52.0,
			 "attack": 0.002, "sustain": 0.050, "decay": 0.300, "punch": 0.6, "lp": 420.0},
			{"wave": "noise", "attack": 0.004, "sustain": 0.040, "decay": 0.280,
			 "punch": 0.4, "lp": 520.0, "seed": 11},
		]},
		# A real hit on the weak point — a meaty low thud + a sharp crack transient.
		"strike_weakpoint": {"gain": 1.0, "layers": [
			{"wave": "square", "freq": 180.0, "freq_end": 90.0,
			 "attack": 0.001, "sustain": 0.020, "decay": 0.200, "punch": 0.6, "lp": 900.0},
			{"wave": "noise", "attack": 0.0, "sustain": 0.005, "decay": 0.080,
			 "punch": 0.8, "hp": 1500.0, "seed": 5},
		]},
	}


# --- Synthesis ------------------------------------------------------------

## Dispatch: a note sequence, summed layers, or a single voice — then normalize.
func _render(p: Dictionary) -> PackedFloat32Array:
	var raw: PackedFloat32Array
	if p.has("notes"):
		raw = _render_notes(p["notes"])
	elif p.has("layers"):
		raw = _render_layers(p["layers"])
	else:
		raw = _voice(p)
	return _finish(raw, float(p.get("gain", 0.8)))


func _render_notes(notes: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for note_v in notes:
		var note: Dictionary = note_v
		out.append_array(_voice({
			"wave": String(note.get("w", "triangle")),
			"freq": float(note["f"]), "freq_end": float(note.get("f_end", note["f"])),
			"attack": 0.004, "sustain": float(note["d"]) * 0.35,
			"decay": float(note["d"]) * 0.65, "punch": 0.25,
		}))
	return out


func _render_layers(layers: Array) -> PackedFloat32Array:
	var voices: Array = []
	var n := 0
	for lp_v in layers:
		var v := _voice(lp_v)
		voices.append(v)
		n = maxi(n, v.size())
	var out := PackedFloat32Array()
	out.resize(n)
	out.fill(0.0)
	for v_any in voices:
		var v: PackedFloat32Array = v_any
		for i in range(v.size()):
			out[i] += v[i]
	return out


## One synth voice -> raw float samples (un-normalized).
func _voice(p: Dictionary) -> PackedFloat32Array:
	var wave := String(p.get("wave", "sine"))
	var f0 := float(p.get("freq", 440.0))
	var f1 := float(p.get("freq_end", f0))
	var atk := float(p.get("attack", 0.005))
	var sus := float(p.get("sustain", 0.05))
	var dec := float(p.get("decay", 0.10))
	var punch := float(p.get("punch", 0.0))
	var duty := float(p.get("duty", 0.5))
	var vib_d := float(p.get("vib_depth", 0.0))
	var vib_s := float(p.get("vib_speed", 0.0))
	var lp := float(p.get("lp", 0.0))
	var hp := float(p.get("hp", 0.0))

	var total := atk + sus + dec
	var n := int(SR * total)
	var out := PackedFloat32Array()
	out.resize(n)

	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.get("seed", 1))

	var phase := 0.0
	# one-pole low-pass / high-pass state
	var lp_y := 0.0
	var lp_a := _lp_alpha(lp)
	var hp_a := _hp_alpha(hp)
	var hp_prev_in := 0.0
	var hp_prev_out := 0.0

	for i in range(n):
		var t := float(i) / SR
		var frac := t / total if total > 0.0 else 0.0
		# exponential pitch glide (musical); linear if either end is non-positive
		var f := f0
		if f0 > 0.0 and f1 > 0.0:
			f = f0 * pow(f1 / f0, frac)
		else:
			f = lerpf(f0, f1, frac)
		if vib_d > 0.0:
			f += vib_d * sin(TAU * vib_s * t)
		phase += f / SR
		var ph: float = phase - floor(phase)

		var s := 0.0
		match wave:
			"sine": s = sin(TAU * ph)
			"square": s = 1.0 if ph < duty else -1.0
			"saw": s = 2.0 * ph - 1.0
			"triangle": s = 4.0 * absf(ph - 0.5) - 1.0
			"noise": s = rng.randf_range(-1.0, 1.0)

		# ADSR envelope with a sustain "punch" that decays across the sustain.
		var env := 0.0
		if t < atk:
			env = t / atk if atk > 0.0 else 1.0
		elif t < atk + sus:
			var sp := (t - atk) / sus if sus > 0.0 else 1.0
			env = 1.0 + punch * (1.0 - sp)
		else:
			var dp := (t - atk - sus) / dec if dec > 0.0 else 1.0
			env = 1.0 - dp
		env = clampf(env, 0.0, 2.0)

		var val := s * env

		if lp_a > 0.0:
			lp_y += lp_a * (val - lp_y)
			val = lp_y
		if hp_a > 0.0:
			var hy := hp_a * (hp_prev_out + val - hp_prev_in)
			hp_prev_in = val
			hp_prev_out = hy
			val = hy

		out[i] = val
	return out


func _lp_alpha(cutoff: float) -> float:
	if cutoff <= 0.0:
		return 0.0
	var dt := 1.0 / SR
	var rc := 1.0 / (TAU * cutoff)
	return dt / (rc + dt)


func _hp_alpha(cutoff: float) -> float:
	if cutoff <= 0.0:
		return 0.0
	var dt := 1.0 / SR
	var rc := 1.0 / (TAU * cutoff)
	return rc / (rc + dt)


## Peak-normalize, apply gain, and add a tiny fade-out to kill end clicks.
func _finish(raw: PackedFloat32Array, gain: float) -> PackedFloat32Array:
	var peak := 0.0
	for v in raw:
		peak = maxf(peak, absf(v))
	var scale := (0.95 * gain / peak) if peak > 0.0001 else 0.0
	var n := raw.size()
	var fade := mini(int(SR * 0.003), n)  # ~3ms
	for i in range(n):
		var g := scale
		var tail := n - i
		if tail < fade:
			g *= float(tail) / float(fade)
		raw[i] = clampf(raw[i] * g, -1.0, 1.0)
	return raw


# --- WAV writing (16-bit PCM mono, little-endian RIFF) --------------------

func _write_wav(path: String, samples: PackedFloat32Array) -> void:
	var n := samples.size()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("gen_sfx: cannot open %s" % path)
		return
	f.store_buffer("RIFF".to_ascii_buffer())
	f.store_32(36 + n * 2)          # file size - 8
	f.store_buffer("WAVE".to_ascii_buffer())
	f.store_buffer("fmt ".to_ascii_buffer())
	f.store_32(16)                  # PCM fmt chunk size
	f.store_16(1)                   # audio format = PCM
	f.store_16(1)                   # channels = mono
	f.store_32(SR)                  # sample rate
	f.store_32(SR * 2)              # byte rate (sr * channels * bytes)
	f.store_16(2)                   # block align
	f.store_16(16)                  # bits per sample
	f.store_buffer("data".to_ascii_buffer())
	f.store_32(n * 2)               # data chunk size
	for s in samples:
		var iv := int(round(clampf(s, -1.0, 1.0) * 32767.0))
		if iv < 0:
			iv += 65536             # 16-bit two's complement for store_16
		f.store_16(iv)
	f.close()
