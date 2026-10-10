shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, shadows_disabled;

// TARGET's floor on the fight's ground (builder 2026-10-09, Floor item).
// tools/floor_cut.py cuts TARGET.png's hex slabs below the lava line into
// `tex`; each ground point is mapped through the REST camera (handed in by
// combat_3d._place_backdrop) into TARGET's centred square, so from the rest
// view the floor is TARGET's own pixels, and when the lens climbs the slabs
// stay where they lie on the ground. Colour through the same table as the
// drawn jackal, so the screen shows TARGET's values.

uniform sampler2D tex : filter_linear, repeat_disable;   // no mips: at the rest view the map is screen-aligned, and the ground's grazing angle picked a blurred mip
#include "res://assets/3d/drawn_sprite_lut3d.gdshaderinc"

uniform mat4 rest_view;
uniform mat4 rest_proj;
uniform vec2 vp_size = vec2(1280.0, 720.0);
uniform float sq_x0 = 280.0;
uniform float sq_side = 720.0;
uniform float tex_top = 540.0;   // TARGET row the texture starts at
uniform float tex_pad = 420.0;   // TARGET px mirrored on past each side of the square
uniform bool ready = false;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

const float EMIT_CAP = 2.2;
vec3 emit3(vec3 want) {
	vec3 f = clamp(want, 0.0, 1.0) * float(LUT3_N - 1);
	ivec3 lo = ivec3(floor(f));
	ivec3 hi = min(lo + 1, ivec3(LUT3_N - 1));
	vec3 w = f - vec3(lo);
	int n = LUT3_N;
	vec3 c000 = LUT3(lo.r + n * (lo.g + n * lo.b));
	vec3 c100 = LUT3(hi.r + n * (lo.g + n * lo.b));
	vec3 c010 = LUT3(lo.r + n * (hi.g + n * lo.b));
	vec3 c110 = LUT3(hi.r + n * (hi.g + n * lo.b));
	vec3 c001 = LUT3(lo.r + n * (lo.g + n * hi.b));
	vec3 c101 = LUT3(hi.r + n * (lo.g + n * hi.b));
	vec3 c011 = LUT3(lo.r + n * (hi.g + n * hi.b));
	vec3 c111 = LUT3(hi.r + n * (hi.g + n * hi.b));
	vec3 u = mix(mix(mix(c000, c100, w.r), mix(c010, c110, w.r), w.g),
		mix(mix(c001, c101, w.r), mix(c011, c111, w.r), w.g), w.b);
	vec3 e = LUT3_E0 + (LUT3_EMAX - LUT3_E0) * pow(max(u, vec3(0.0)), vec3(LUT3_GAMMA));
	// The table was measured with the scene's bloom off, so it reaches for
	// emission past what the eye needs where only bloom could add the rest
	// (the cream outline, near-white). Capped, the line glows a little, as
	// TARGET's does, instead of fogging the whole figure. The whole colour
	// scales, not one channel: clipping red alone turned the yellow-hot
	// cores cream.
	float top = max(e.r, max(e.g, e.b));
	return e * min(1.0, EMIT_CAP / max(top, 1e-4));
}


void fragment() {
	if (!ready) discard;
	vec4 c = rest_proj * rest_view * vec4(world_pos, 1.0);
	if (c.w <= 0.0) discard;
	vec2 ndc = c.xy / c.w;
	vec2 px = vec2((ndc.x * 0.5 + 0.5) * vp_size.x, (0.5 - ndc.y * 0.5) * vp_size.y);
	float u = ((px.x - sq_x0) / sq_side * 1024.0 + tex_pad) / (1024.0 + 2.0 * tex_pad);
	float row = px.y / sq_side * 1024.0;
	float v = (row - tex_top) / (1024.0 - tex_top);
	if (u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) discard;
	vec4 t = texture(tex, vec2(u, v));
	if (t.a < 0.004) discard;
	ALBEDO = emit3(t.rgb);
	ALPHA = t.a;
}
