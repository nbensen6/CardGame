// The fist's fire, drawn over the fight in 2D, past the tonemapper.
//
// The drawn beast reaches the screen through the fight's Environment (ACES,
// contrast, saturation); drawn_sprite.gdshader inverts that with a 3D LUT,
// which holds everywhere but in the brightest saturated yellows: ACES mixes
// the channels there, so TARGET's lemon flame core (~255,200,40) came out
// ~15 green short and cream (builder 2026-10-09, queue "Fist fire", graders
// R1-R13). This draws the rig's own pixels for the flame's bright colours on
// a canvas layer under the HUD, so they reach the screen as the PNG.
// views/drawn_rig.gd sets `screen_to_uv` (a homography from screen UV to
// the billboard's UV) every frame, so it follows the camera and the pose.
shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D rig_tex : filter_linear, repeat_disable;
uniform mat3 screen_to_uv = mat3(1.0);
// The part of the rig canvas the overlay may draw in (uv x0, y0, x1, y1),
// and its soft edge: the fire and the swung fist's path, not the body.
uniform vec4 region = vec4(0.0, 0.0, 0.4, 0.62);
uniform float region_feather = 0.03;
// Which colours count as flame (unpremultiplied): bright, warm, low blue.
uniform vec2 red_ramp = vec2(0.72, 0.88);
uniform vec2 green_ramp = vec2(0.30, 0.45);
uniform vec2 blue_ramp = vec2(0.72, 0.58);   // the cream rim too: a partial overlay serrated it (grader run 15 R2)
uniform float strength = 1.0;
// Rig texels per screen pixel: the 3x3 box over each pixel's footprint
// (the billboard's own filter, drawn_sprite.gdshader `footprint`).
uniform bool footprint = true;

vec2 to_uv(vec2 s) {
	vec3 q = screen_to_uv * vec3(s, 1.0);
	return q.xy / q.z;
}

void fragment() {
	vec2 uv = to_uv(SCREEN_UV);
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		discard;
	}
	vec4 t;
	if (footprint) {
		vec2 dx = dFdx(uv);
		vec2 dy = dFdy(uv);
		t = vec4(0.0);
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				t += texture(rig_tex, uv + dx * (float(i) / 3.0) + dy * (float(j) / 3.0));
			}
		}
		t /= 9.0;
	} else {
		t = texture(rig_tex, uv);
	}
	if (t.a <= 0.001) {
		discard;
	}
	vec3 c = t.rgb / t.a;   // the rig's target holds premultiplied colour
	float flame = smoothstep(red_ramp.x, red_ramp.y, c.r)
		* smoothstep(green_ramp.x, green_ramp.y, c.g)
		* smoothstep(blue_ramp.x, blue_ramp.y, c.b);
	float inside = smoothstep(region.x - region_feather, region.x, uv.x)
		* smoothstep(region.z + region_feather, region.z, uv.x)
		* smoothstep(region.y - region_feather, region.y, uv.y)
		* smoothstep(region.w + region_feather, region.w, uv.y);
	float a = clamp(flame * inside * strength, 0.0, 1.0) * t.a;
	if (a <= 0.001) {
		discard;
	}
	COLOR = vec4(clamp(c, 0.0, 1.0), a);
}
