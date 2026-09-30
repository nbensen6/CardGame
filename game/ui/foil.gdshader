shader_type canvas_item;
render_mode blend_mix;

// Holographic foil, translated from Tami Coker's Blender tutorial
// "How to Create Rare Trading Cards in Blender" (youtube galbsQKb_XU), which
// Nick sent as the reference for how foils should feel.
//
// Her node graph, and what each part became here:
//
//   Layer Weight -> Facing     the effect must depend on VIEW ANGLE, or it is a
//                              sticker rather than a foil. There is no view
//                              angle on a 2D card, so `tilt` stands in for it:
//                              the pointer on a desktop, the accelerometer on a
//                              phone. Same job — the sheen has to move when the
//                              player moves.
//   Noise texture, distorted   `sparkle` below. Scale up, distortion up, as she
//                              does, so it breaks into flecks rather than a
//                              smooth wash.
//   Mix -> LINEAR LIGHT        `linear_light()`. She changes the blend mode from
//                              Mix to Linear Light specifically and says it
//                              "gives us a better effect" — it does, because it
//                              both brightens and darkens around 0.5, so the
//                              foil bites into the dark parts of the card
//                              instead of only glowing on the light ones.
//   Colour ramp                `SHEEN_*` — her silvery base, black lifted a
//                              little, white pulled toward the grey.
//   Second rainbow gradient,   `rainbow()` swept along the card by `tilt`. She
//   rotated on Y               rotates hers on Y so it travels across the face.
//
// Everything is procedural: no texture to author, no import, and it costs one
// pass over the card's own rectangle.

uniform vec2 tilt = vec2(0.0);
uniform float strength : hint_range(0.0, 2.0) = 1.0;
uniform float sparkle_scale : hint_range(1.0, 40.0) = 13.0;
uniform float distortion : hint_range(0.0, 2.0) = 0.55;
// A per-card offset so two foils in the same hand do not shimmer in lockstep,
// which instantly reads as a screen effect rather than as two objects.
uniform float seed = 0.0;
// RIM MODE. 0 is the foil above. Above 0 the same rect draws only a glowing
// edge instead of a face sheen: the lifted card in the hand (Cards fan and
// glow, 2026-09-30). `rim` is how bright, `rim_px` the rect's size in pixels
// and `rim_pad` how far the rect reaches past the card, so the glow can sit on
// the card's edge and bleed outward rather than being cut at the frame.
uniform float rim = 0.0;
uniform vec2 rim_px = vec2(1.0);
uniform float rim_pad = 0.0;
uniform float time_s = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// Her colour ramp: red, orange, yellow, green, blue, purple, evenly distributed.
vec3 rainbow(float t) {
	return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

// base + 2*blend - 1, clamped. The blend mode she switches to on purpose.
vec3 linear_light(vec3 base, vec3 blend) {
	return clamp(base + 2.0 * blend - 1.0, vec3(0.0), vec3(1.0));
}

// The card's edge, glowing ember-gold with the foil's rainbow band travelling
// round it. A gaussian on the distance to the card's true edge: bright on the
// frame line, gone a few pixels in (the name and cost stay clean) and a soft
// halo outward.
vec4 rim_glow(vec2 uv) {
	vec2 p = uv * rim_px;
	float d = min(min(p.x, rim_px.x - p.x), min(p.y, rim_px.y - p.y)) - rim_pad;
	float g = exp(-d * d / 26.0) + 0.45 * exp(-max(-d, 0.0) / 6.0) * step(d, 0.0);
	float sweep = (uv.x * 0.85 + uv.y * 0.55) + time_s * 0.35;
	vec3 ember = vec3(1.0, 0.72, 0.32);
	vec3 col = mix(ember, rainbow(sweep * 2.0), 0.18);
	return vec4(col, clamp(g, 0.0, 1.0) * rim);
}

void fragment() {
	vec2 uv = UV;
	if (rim > 0.0) {
		COLOR = rim_glow(uv);
	} else {

	// The "facing" stand-in: one diagonal sweep across the card, phase driven by
	// tilt. Deliberately NOT wrapped with fract() — a repeating band tiles the
	// face with blobs, which reads as a texture rather than as light on it.
	float sweep = (uv.x * 0.85 + uv.y * 0.55) * 1.15 + tilt.x * 0.35 - tilt.y * 0.2;

	// Distorted noise — flecks, not a wash.
	vec2 warp = vec2(noise(uv * sparkle_scale * 0.5 + tilt * 0.4),
			noise(uv * sparkle_scale * 0.5 - tilt * 0.4));
	float sparkle = noise(uv * sparkle_scale + warp * distortion * 2.0);

	// Silvery base, black lifted off zero and white pulled toward the grey.
	vec3 sheen = mix(vec3(0.30, 0.32, 0.38), vec3(0.88, 0.90, 0.96),
			smoothstep(0.25, 0.85, sparkle));

	// Two full hue cycles across the face, so you see a SPECTRUM travelling
	// rather than one colour sitting there. At one cycle the card picked up a
	// single hue, mixed with the brown frame, and read as a stain.
	vec3 bow = rainbow(sweep * 2.0 + sparkle * 0.12);

	// ONE narrow highlight travelling across the face, not the whole thing
	// glowing at once. A gaussian rather than a smoothstep pair: it falls off
	// on both sides, so the band has an edge and reads as a moving reflection.
	float d = sweep - 0.55;
	float band = exp(-d * d * 7.0);

	// Colour lives IN the band and nowhere else. Away from it the card gets a
	// faint colourless sheen, which is what an unlit part of a real foil does —
	// spreading the rainbow over the whole face is what made it a stain.
	vec3 col = linear_light(sheen, mix(vec3(0.5), bow, band) * 0.5);

	// Low. A foil is mostly still the card. The first version ran 0.16 to 0.60
	// and buried the rules text under a rainbow; every word has to stay legible
	// while the sheen crosses it.
	float a = (0.035 + 0.26 * band) * strength;

	COLOR = vec4(col, a * texture(TEXTURE, UV).a);
	}
}
