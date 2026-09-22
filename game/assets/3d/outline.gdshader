shader_type spatial;
render_mode cull_front, unshaded, shadows_disabled;

// Inverted-hull outline — the next_pass of toon.gdshader. Spike, 2026-09-22.
//
// Draws the model again, pushed out along its normals, back faces only, in one
// flat colour. Works on every renderer (no normal buffer needed). Width is in
// screen terms: scaled by view distance so a beast across the arena keeps the
// same line weight as one in your face.

uniform vec4 line_color : source_color = vec4(0.07, 0.05, 0.08, 1.0);
uniform float width : hint_range(0.0, 0.02) = 0.0045;

// Same idle motion as toon.gdshader, or the line peels off the moving tail.
// Keep these two blocks identical.
uniform float tail_amp = 0.0;
uniform float tail_rate = 0.9;
uniform vec2 tail_x = vec2(-1.0, -3.2);
uniform vec2 tail_z = vec2(-1.4, -2.2);
uniform float breath_amp = 0.0;
uniform float breath_rate = 1.3;
uniform float breath_min_y = 1.2;

vec3 idle(vec3 v, vec3 n) {
	// Negated so edge0 < edge1: smoothstep with them reversed is undefined in GLSL.
	float tail = smoothstep(-tail_x.x, -tail_x.y, -v.x) * smoothstep(-tail_z.x, -tail_z.y, -v.z);
	float lag = (-v.x) * 0.6;
	v.z += sin(TIME * tail_rate - lag) * tail_amp * tail * tail;
	float barrel = smoothstep(breath_min_y, breath_min_y + 0.5, v.y) * (1.0 - tail);
	v += n * sin(TIME * breath_rate) * breath_amp * barrel;
	return v;
}

void vertex() {
	vec3 v = idle(VERTEX, NORMAL);
	vec4 view_pos = MODELVIEW_MATRIX * vec4(v, 1.0);
	vec3 view_n = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	view_pos.xyz += view_n * width * -view_pos.z;
	POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
	ALBEDO = line_color.rgb;
}
