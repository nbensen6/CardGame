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

void vertex() {
	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 view_n = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	view_pos.xyz += view_n * width * -view_pos.z;
	POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
	ALBEDO = line_color.rgb;
}
