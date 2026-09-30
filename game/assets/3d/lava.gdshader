shader_type spatial;
render_mode unshaded, cull_disabled;

// Molten lava for the ring round the arena — "Lava flows around the arena",
// 2026-09-30. Used by a biome that names `"lava"` in combat_3d.BIOME
// (quarry_ember only), on the flat annulus combat_3d._add_lava builds in the
// trench between the floor's edge and the wall.
//
// Unshaded: lava is its own light. Two layers of value noise, both measured
// in the ring's own polar coordinates (angle x radius) so the whole pool
// FLOWS round the arena instead of sliding across it:
//   - a hot body, orange into yellow where the noise peaks;
//   - a dark crust drifting slower on top, broken by the body's hot seams.

uniform vec4 crust_color : source_color = vec4(0.16, 0.025, 0.01, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.36, 0.04, 1.0);
uniform vec4 white_color : source_color = vec4(1.0, 0.82, 0.38, 1.0);
uniform float gain : hint_range(0.5, 4.0) = 1.25;
// Radians per second the lava travels round the ring. Slow: a pool, not a river.
uniform float flow = 0.018;
// Noise cells per world unit along the flow and across it.
uniform float scale = 0.08;
uniform float crust = 0.50;

varying vec2 polar;

void vertex() {
	float a = atan(VERTEX.z, VERTEX.x);
	polar = vec2(a, length(VERTEX.xz));
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float w = 0.5;
	for (int k = 0; k < 3; k++) {
		v += w * vnoise(p);
		p = p * 2.03 + vec2(17.0, 5.0);
		w *= 0.5;
	}
	return v;
}

void fragment() {
	// Arc length, so a cell is the same size at the inner and the outer edge.
	// The seam at a = +-PI is one line on the far side of a ring that is
	// always partly behind the beast; the noise is continuous across it at
	// the ring's mean radius to within a cell, which is all a still can see.
	float r = polar.y;
	float s = polar.x * r;
	float t = TIME;
	vec2 q = vec2(s * scale, r * scale * 1.6);
	vec2 warp = vec2(fbm(q + vec2(t * 0.05, 0.0)), fbm(q + vec2(3.1, t * 0.04)));
	// The body moves at `flow`, the crust at half of it: the skin lags the melt.
	vec2 along = vec2(t * flow * r * scale, 0.0);
	float body = fbm((q - along) * 1.3 + warp * 1.4);
	float skin = fbm((q - along * 0.5) * 0.9 + vec2(0.0, 9.0));
	vec3 c = mix(hot_color.rgb, white_color.rgb, smoothstep(0.55, 0.8, body));
	float crusted = smoothstep(crust - 0.06, crust + 0.10, skin) * (1.0 - smoothstep(0.62, 0.78, body));
	c = mix(c, crust_color.rgb, crusted * 0.9);
	ALBEDO = c * gain;
}
