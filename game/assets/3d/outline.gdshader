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
// True when the mesh carries welded normals in TANGENT (Combat3D.hull_mesh):
// the hull then pushes out along those, one direction per corner, and stays
// closed over hard facet edges instead of splitting into a stair-step.
uniform bool welded = false;
// Above 1.0 the line passes the scene's glow threshold and blooms (the
// jackal's warm line in picture A). 1.0 is a plain flat line.
uniform float energy = 1.0;
// The hull also steps back from the camera by this many line widths, so where
// it pokes through a concave crease (the jackal's cracks) the body still hides
// it and the line shows only past the silhouette.
uniform float depth_push = 3.0;

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
	vec3 push = welded ? TANGENT : NORMAL;
	vec3 view_n = normalize((MODELVIEW_MATRIX * vec4(push, 0.0)).xyz);
	float reach = width * -view_pos.z;
	view_pos.xyz += view_n * reach;
	view_pos.z -= reach * depth_push;
	POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
	ALBEDO = line_color.rgb * energy;
}
