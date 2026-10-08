shader_type spatial;
render_mode cull_back, diffuse_toon, specular_toon;

// Black-glass arena floor — "Obsidian floor", 2026-09-30. Used by a biome that
// names `"floor": "obsidian"` in combat_3d.BIOME (quarry_ember only), on both
// the environment's own Floor mesh and the plain Ground disc under it.
//
// Two things, all in world space so it needs no UVs from the floor mesh:
//   - a near-black base with one hard lit/shadow step, like toon.gdshader;
//   - faint orange emission along a Voronoi crack network.
// The reflected specular band it once had is gone (Nick, 2026-09-30:
// "remove the band").

uniform vec4 base_color : source_color = vec4(0.035, 0.03, 0.045, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.30, 0.30, 0.50, 1.0);
// Unlit slate tone the glass always shows, so the floor reads as ground and
// not a black hole (scene pass 1, picture A, 2026-10-04). Emission rather than
// a lighter albedo: the lava omni lights multiply albedo and turn any lift red.
uniform vec4 tone : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Cracks: cell size in world units, line width as a fraction of a cell.
uniform vec4 crack_color : source_color = vec4(1.0, 0.46, 0.10, 1.0);
uniform float crack_gain : hint_range(0.0, 4.0) = 0.35;
uniform float crack_cell = 4.0;
uniform float crack_width : hint_range(0.0, 0.3) = 0.018;
uniform float crack_px : hint_range(0.5, 4.0) = 1.2;
// Slabs (picture A, 2026-10-05): each Voronoi cell is one flat slab whose
// tone steps up or down by up to this much, so the floor reads as big cracked
// slabs, not one sheet with lines drawn on it. 0 = one tone everywhere.
uniform float slab_var : hint_range(0.0, 1.0) = 0.0;
// Hex tiles (TARGET.png, 2026-10-08): 1 lays the cracks on a hex grid, so the
// floor reads as TARGET's dark hexagonal flagstones with warm seams; 0 keeps
// the random Voronoi crack network.
uniform float hex_tiles : hint_range(0.0, 1.0) = 0.0;

// Rim heat — "Lava flows around the arena", 2026-09-30. Where lava rings the
// floor (combat_3d._add_lava sets these), the glass nearest it glows orange
// and its cracks run hotter, fading in over `rim_width` world units up to
// `rim_radius` from `rim_center`, and never near the lens (see below).
// rim_radius 0 = no lava, no heat. Emission,
// not a light: the glass is near-black, so no light that leaves the Frog
// green can make it read orange from the rest camera.
uniform vec2 rim_center = vec2(0.0);
uniform float rim_radius = 0.0;
uniform float rim_width = 1.0;
uniform vec4 rim_color : source_color = vec4(1.0, 0.36, 0.08, 1.0);
uniform float rim_gain : hint_range(0.0, 3.0) = 2.0;

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
float crack_edge(vec2 p, out vec2 cell) {
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
	cell = n + mg;
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

// Distance to the nearest edge of a pointy hex grid of unit flat-to-flat
// width, in cell units, and the cell's id.
float hex_edge(vec2 p, out vec2 cell) {
	vec2 r = vec2(1.0, 1.7320508);
	vec2 h = r * 0.5;
	vec2 a = mod(p, r) - h;
	vec2 b = mod(p - h, r) - h;
	vec2 gv = dot(a, a) < dot(b, b) ? a : b;
	cell = floor((p - gv) * 2.0 + 0.5);
	vec2 q = abs(gv);
	float hd = max(dot(q, vec2(0.5, 0.8660254)), q.x);
	return 0.5 - hd;
}

void fragment() {
	vec2 cp = world_pos.xz / crack_cell;
	vec2 cell;
	float e = hex_tiles > 0.5 ? hex_edge(cp, cell) : crack_edge(cp, cell);
	// Three flat steps per slab, never a gradient: picture A's floor is flat
	// planes like its cliffs.
	float slab = 1.0 + slab_var * (floor(hash2(cell * 1.7 + 3.1).x * 3.0) - 1.0);
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

	float heat = 0.0;
	if (rim_radius > 0.0) {
		float d = length(world_pos.xz - rim_center);
		heat = smoothstep(rim_radius - rim_width, rim_radius, d);
		heat = pow(heat, 1.2);
		// The rest camera stands near the rim on its own side, so the glass
		// under the lens would glow too and the dark ground in front of the
		// hunter would go red. Only the rim across the arena, the one you look
		// at, carries the heat.
		float seen = length(world_pos - CAMERA_POSITION_WORLD);
		heat *= smoothstep(0.5 * rim_radius, 1.2 * rim_radius, seen);
	}

	EMISSION = crack_color.rgb * crack_gain * (crack + halo * 0.12) * (1.0 + heat * 4.0)
		+ rim_color.rgb * rim_gain * heat
		+ tone.rgb * slab * (1.0 - crack);
}

void light() {
	float ndl = dot(NORMAL, LIGHT) * ATTENUATION;
	float lit = step(0.3, ndl);
	DIFFUSE_LIGHT += mix(shadow_color.rgb, vec3(1.0), lit) * LIGHT_COLOR / PI;
}
