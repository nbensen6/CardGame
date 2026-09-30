shader_type spatial;
render_mode cull_back, diffuse_toon, specular_toon;

// Black-glass arena floor — "Obsidian floor", 2026-09-30. Used by a biome that
// names `"floor": "obsidian"` in combat_3d.BIOME (quarry_ember only), on both
// the environment's own Floor mesh and the plain Ground disc under it.
//
// Three things, all in world space so it needs no UVs from the floor mesh:
//   - a near-black base with one hard lit/shadow step, like toon.gdshader;
//   - a sharp toon specular BAND: the reflected view ray's elevation, cut hard,
//     so the floor mirrors a strip of glow across the ground ahead.
//     A sun highlight alone never shows: the key light comes from behind the
//     camera, so its mirror spot falls outside the frame;
//   - faint orange emission along a Voronoi crack network.

uniform vec4 base_color : source_color = vec4(0.035, 0.03, 0.045, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.30, 0.30, 0.50, 1.0);

// The band: a hard-edged stripe of reflected glow. Reflected view rays whose
// VIEW-space elevation lies in [band_lo, band_hi] light up, so the stripe always
// lies across the floor between the hunter and what the camera faces; it fades
// out sideways past |x| = band_half so it ends like a sheen, not a painted line.
uniform vec4 band_color : source_color = vec4(1.0, 0.74, 0.62, 1.0);
uniform float band_strength : hint_range(0.0, 2.0) = 0.8;
uniform float band_lo : hint_range(0.0, 1.0) = 0.20;
uniform float band_hi : hint_range(0.0, 1.0) = 0.235;
uniform float band_half : hint_range(0.05, 1.0) = 0.9;

// Cracks: cell size in world units, line width as a fraction of a cell.
uniform vec4 crack_color : source_color = vec4(1.0, 0.46, 0.10, 1.0);
uniform float crack_gain : hint_range(0.0, 4.0) = 0.35;
uniform float crack_cell = 4.0;
uniform float crack_width : hint_range(0.0, 0.3) = 0.018;
uniform float crack_px : hint_range(0.5, 4.0) = 1.2;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

// Distance to the nearest Voronoi edge (F2 - F1 style, Inigo Quilez's exact
// border distance), in cell units.
float crack_edge(vec2 p) {
	vec2 n = floor(p);
	vec2 f = fract(p);
	vec2 mr = vec2(0.0);
	vec2 mg = vec2(0.0);
	float md = 8.0;
	for (int j = -1; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			vec2 g = vec2(float(i), float(j));
			vec2 r = g + hash2(n + g) - f;
			float d = dot(r, r);
			if (d < md) { md = d; mr = r; mg = g; }
		}
	}
	md = 8.0;
	for (int j = -2; j <= 2; j++) {
		for (int i = -2; i <= 2; i++) {
			vec2 g = mg + vec2(float(i), float(j));
			vec2 r = g + hash2(n + g) - f;
			if (dot(mr - r, mr - r) > 0.00001) {
				md = min(md, dot(0.5 * (mr + r), normalize(r - mr)));
			}
		}
	}
	return md;
}

void fragment() {
	vec2 cp = world_pos.xz / crack_cell;
	float e = crack_edge(cp);
	// Hairlines: the width is the smaller of a fraction of a cell and a couple
	// of screen pixels, so a crack at the hunter's feet stays as thin on screen
	// as one at the far wall instead of swelling into a bar.
	float px = fwidth(e) + 1e-5;
	float wdt = min(crack_width, px * crack_px);
	float crack = 1.0 - smoothstep(wdt - px * 0.5, wdt + px * 0.5, e);
	// A thin, dim halo so a crack glows rather than being a printed line.
	float halo = 1.0 - smoothstep(wdt, wdt * 3.0, e);

	ALBEDO = base_color.rgb * (1.0 - crack * 0.6);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;

	vec3 r = reflect(-VIEW, NORMAL);
	float w = fwidth(r.y) + 0.0005;
	float band = smoothstep(band_lo - w, band_lo + w, r.y)
		* (1.0 - smoothstep(band_hi - w, band_hi + w, r.y))
		* (1.0 - smoothstep(band_half * 0.4, band_half, abs(r.x)))
		* step(r.z, 0.0);
	// Glass: the cracks break the reflection, they do not carry it.
	band *= 1.0 - crack;

	EMISSION = band * band_strength * band_color.rgb
		+ crack_color.rgb * crack_gain * (crack + halo * 0.12);
}

void light() {
	float ndl = dot(NORMAL, LIGHT) * ATTENUATION;
	float lit = step(0.3, ndl);
	DIFFUSE_LIGHT += mix(shadow_color.rgb, vec3(1.0), lit) * LIGHT_COLOR / PI;
}
