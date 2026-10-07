shader_type spatial;
render_mode cull_back, unshaded;

// Flat-toned cliffs -- "Cliffs and floor in picture A's flat style",
// 2026-10-05. Used by a biome that names `"wall": "flat"` in combat_3d.BIOME
// (quarry_ember only), on the environment's Wall mesh in place of its painted
// rock texture.
//
// Picture A's cliffs are dark angular slate in two or three flat tones, not
// lit photographic rock. So: every triangle takes its own face normal (from
// screen derivatives, so the mesh's smoothed normals cannot blend facets back
// together) and that normal picks ONE of three tones, lit / side / shade, by
// how it faces a fixed key direction. Unshaded on purpose: the lava's and the
// seams' orange lights multiplied the old texture into brown-orange rock. The
// lava's heat comes back as one warm band low on the wall instead, which is
// what the picture shows where the cliffs meet the molten line. Fog still
// applies.

// Overnight pass 10 (picture A): its walls are near-black charcoal with
// cool grey lit faces (~18,24,36 up to ~49,49,63); the old blue-slate tones
// came out of the grade as navy (~32,35,61) over most of the upper frame.
// Overnight pass 13: those rendered near-black (~26,27,40) with facets that
// barely separated; A's walls are mid slate with clearly lit planes (~74,79,96
// lit, ~42,44,56 shadow). Lifted, cool, three tones apart.
// Overnight pass 16: those rendered lit slate blue (~106,110,136) over ~70% of
// the upper frame and hid A's open sky; A's walls are near-black silhouettes
// (~21,21,28 to ~42,42,53). Darker and less blue, with the lit tone kept
// well above the shade so the facets still separate.
// Checker iter 18 (2026-10-07), measured on the TARGET pair: TARGET's lit
// cliff facets reach ~(47,48,63) on screen, ours topped out at ~(21,19,30),
// so the planes did not separate. Only the lit tone is lifted, cooler.
uniform vec4 lit_color : source_color = vec4(0.265, 0.265, 0.31, 1.0);
uniform vec4 side_color : source_color = vec4(0.12, 0.118, 0.135, 1.0);
uniform vec4 shade_color : source_color = vec4(0.055, 0.054, 0.062, 1.0);
// The direction the cliffs' light comes from, in world space (towards the
// light). Upper-left from the rest camera, like the picture.
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.35);
// Where a facet stops being lit / starts being in shade, on dot(n, key).
// Checker iter 20: lit at 0.42 lit whole cliff faces, so the walls read as
// flat light-slate cut-outs; TARGET's are near-black masses whose lit
// planes are narrow cool edges. Only the most key-facing planes light now.
uniform float lit_at : hint_range(-1.0, 1.0) = 0.6;
uniform float shade_at : hint_range(-1.0, 1.0) = -0.05;
// The warm band at the foot of the wall, in world units above the floor.
uniform vec4 heat_color : source_color = vec4(1.0, 0.36, 0.08, 1.0);
uniform float heat_height = 2.0;
uniform float heat_gain : hint_range(0.0, 2.0) = 0.55;
// Checker iter 20: TARGET's cliffs are softly shaded inside each plane, not
// one flat tone: every facet darkens toward the ground by shade_floor over
// shade_span world units, and keeps its full tone above that.
uniform float shade_floor : hint_range(0.0, 1.0) = 0.6;
uniform float shade_span = 9.0;

// Checker iter 24: behind the jackal, the far side of the wall ring stood
// as a row of jagged dark teeth across the whole mid-ground; TARGET shows
// open sky there between two big formations. Wall that lies further than
// far_from arena radii past the arena centre, along the camera's view, fades
// toward the sky's own tone by far_mix at far_to. Only near the camera's
// centre line: wall more than lat_from radii to either side keeps its dark
// tones, so the two big formations at the frame edges stay as TARGET's.
uniform vec3 arena_centre = vec3(0.0);
uniform float arena_r = 12.0;
uniform float far_from = 0.2;
uniform float far_to = 0.9;
uniform vec4 far_color : source_color = vec4(0.341, 0.18, 0.325, 1.0);
uniform float far_mix : hint_range(0.0, 1.0) = 0.7;
uniform float lat_from = 0.6;
uniform float lat_to = 0.95;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 n = normalize(cross(dFdx(world_pos), dFdy(world_pos)));
	// The cross product's sign follows the screen's winding; face the camera.
	vec3 to_cam = CAMERA_POSITION_WORLD - world_pos;
	if (dot(n, to_cam) < 0.0) {
		n = -n;
	}
	float k = dot(n, normalize(key_dir));
	vec3 c = side_color.rgb;
	if (k > lit_at) {
		c = lit_color.rgb;
	} else if (k < shade_at) {
		c = shade_color.rgb;
	}
	float heat = 1.0 - smoothstep(0.0, max(heat_height, 1e-3), world_pos.y);
	c *= mix(shade_floor, 1.0, smoothstep(0.0, max(shade_span, 1e-3), world_pos.y));
	vec3 col = c + heat_color.rgb * heat_gain * heat * heat;
	vec3 fwd = -INV_VIEW_MATRIX[2].xyz;
	fwd = normalize(vec3(fwd.x, 0.0, fwd.z));
	float along = dot(world_pos - arena_centre, fwd) / max(arena_r, 1e-3);
	float lat = abs(dot(world_pos - arena_centre, vec3(-fwd.z, 0.0, fwd.x))) / max(arena_r, 1e-3);
	float far = smoothstep(far_from, far_to, along) * (1.0 - smoothstep(lat_from, lat_to, lat)) * far_mix;
	ALBEDO = mix(col, far_color.rgb, far);
}
