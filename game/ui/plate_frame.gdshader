shader_type canvas_item;
render_mode blend_mix;

// A framed HUD piece, drawn over a Control as a ring with a clear centre
// (Nick, 2026-10-04: "the card and ui from b"). Picture B frames its energy
// counter and End Turn in bevelled gold and sets the beast's name and health
// on a carved stone plate. One shader does both: `metal` and `metal_lit` are
// the material's dark and lit sides, `grain` roughens it into stone.
//
//   e (px in from the edge)   what it is
//   0 .. 1.2                  a dark outer hairline, so it lifts off the scene
//   1.2 .. band*0.45          outer bevel, lit from the top left
//   .. band*0.55              an engraved groove
//   .. band                   inner bevel, lit the other way
//   band .. band+1.2          a dark inner hairline
//   beyond                    clear: the Control's own fill shows through
//
// Plus a stud at each corner. Pixels of the Control's own rect, so the band
// is the same width on every size.

uniform vec2 rect_size = vec2(120.0, 46.0);
uniform vec4 metal : source_color = vec4(0.55, 0.36, 0.12, 1.0);
uniform vec4 metal_lit : source_color = vec4(1.0, 0.86, 0.50, 1.0);
uniform float radius = 10.0;
uniform float band = 6.0;
uniform float grain = 0.0;
uniform float studs = 1.0;
// 1 fills the middle with the material too: a slab, drawn behind its host.
uniform float slab = 0.0;

const vec2 KEY_DIR = vec2(-0.61, -0.79);   // top left, y down

float rbox(vec2 p, vec2 h, float r) {
	vec2 q = abs(p) - h + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}

void fragment() {
	vec2 h = rect_size * 0.5;
	vec2 p = UV * rect_size - h;
	float r = min(radius, min(h.x, h.y));
	float d = rbox(p, h - 0.5, r);
	float e = -d;
	vec2 n = normalize(vec2(
		rbox(p + vec2(0.5, 0.0), h - 0.5, r) - rbox(p - vec2(0.5, 0.0), h - 0.5, r),
		rbox(p + vec2(0.0, 0.5), h - 0.5, r) - rbox(p - vec2(0.0, 0.5), h - 0.5, r)) + 1e-5);
	float facing = dot(n, KEY_DIR);

	vec3 col = vec3(0.0);
	float a = 0.0;
	float lit = clamp(facing * 0.5 + 0.5, 0.0, 1.0);
	if (e < 1.2) {
		col = vec3(0.06, 0.04, 0.02);
		a = 1.0;
	} else if (e < band * 0.45) {
		col = mix(metal.rgb, metal_lit.rgb, lit);
		a = 1.0;
	} else if (e < band * 0.55) {
		col = metal.rgb * 0.45;
		a = 1.0;
	} else if (e < band) {
		col = mix(metal.rgb, metal_lit.rgb, 1.0 - lit) * 0.92;
		a = 1.0;
	} else if (e < band + 1.2) {
		col = vec3(0.05, 0.035, 0.02);
		a = 0.9;
	} else {
		// A soft inner shadow under the frame, then clear.
		col = vec3(0.0);
		a = 0.35 * (1.0 - smoothstep(0.0, 4.0, e - band - 1.2));
		if (slab > 0.5) {
			// The slab's face: the dark side of the stone, chiselled by noise
			// and darkened under the frame's lip.
			col = metal.rgb * 0.62 * (1.0 - a);
			a = 0.95;
		}
	}
	// A sheen running down the metal, so it is not a dead flat.
	if (a > 0.5 && (e < band || slab > 0.5)) {
		col *= mix(1.15, 0.85, UV.y);
		float g = noise(UV * rect_size / 3.0) * 0.6 + noise(UV * rect_size / 9.0) * 0.4;
		col *= mix(1.0, 0.7 + 0.6 * g, grain);
	}

	// Corner studs, set into the band.
	if (studs > 0.5) {
		float mid = band * 0.5;
		vec2 c = h - vec2(mid + 1.0);
		vec2 q = abs(p) - c;
		float m = abs(q.x) + abs(q.y);
		float s = band * 0.62;
		float cover = 1.0 - smoothstep(s - 0.7, s + 0.7, m);
		float shade = clamp(0.5 - 0.5 * dot(normalize(sign(p) * q + 1e-4), KEY_DIR) * -1.0, 0.0, 1.0);
		vec3 stud = mix(metal.rgb * 0.7, metal_lit.rgb * 1.08, shade);
		col = mix(col, stud, cover);
		a = max(a, cover);
	}

	a *= 1.0 - smoothstep(-0.75, 0.75, d);
	COLOR = vec4(col, a);
}
