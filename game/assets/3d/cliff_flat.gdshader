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
uniform vec4 lit_color : source_color = vec4(0.31, 0.32, 0.37, 1.0);
uniform vec4 side_color : source_color = vec4(0.20, 0.205, 0.235, 1.0);
uniform vec4 shade_color : source_color = vec4(0.11, 0.11, 0.125, 1.0);
// The direction the cliffs' light comes from, in world space (towards the
// light). Upper-left from the rest camera, like the picture.
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.35);
// Where a facet stops being lit / starts being in shade, on dot(n, key).
uniform float lit_at : hint_range(-1.0, 1.0) = 0.42;
uniform float shade_at : hint_range(-1.0, 1.0) = -0.05;
// The warm band at the foot of the wall, in world units above the floor.
uniform vec4 heat_color : source_color = vec4(1.0, 0.36, 0.08, 1.0);
uniform float heat_height = 2.0;
uniform float heat_gain : hint_range(0.0, 2.0) = 0.55;

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
	ALBEDO = c + heat_color.rgb * heat_gain * heat * heat;
}
