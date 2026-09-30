shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never, shadows_disabled;

// Heat shimmer over the lava ring — "Lava flows around the arena", 2026-09-30.
// A tall open band combat_3d._add_lava stands just inside the wall, beyond
// CAMERA_MAX_R, so the camera always looks at it from inside and it only ever
// wobbles the wall and sky behind the lava, never the hunters or the beast.

uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 0.02) = 0.004;
uniform float speed = 1.4;
// The lava's own glow hanging in the hot air over it, added over the wobble:
// from the low rest camera the pool itself is a few rows at the horizon, and
// this is what makes it read as lava from there.
uniform vec4 glow_color : source_color = vec4(1.0, 0.38, 0.08, 1.0);
uniform float glow_gain : hint_range(0.0, 2.0) = 0.9;
// The band's height in its own units; combat_3d sets it to the mesh's. Its
// origin is at its middle, like any CylinderMesh.
uniform float band_height = 1.0;

varying float low;

void vertex() {
	// 0 at the band's top, 1 at the lava. Measured off the vertex: a
	// CylinderMesh's side UVs do not span 0..1 once its caps are off.
	low = clamp(0.5 - VERTEX.y / band_height, 0.0, 1.0);
}

void fragment() {
	// Strongest low, gone high.
	float fade = smoothstep(0.0, 1.0, low);
	vec2 wob = vec2(sin(UV.x * 180.0 + low * 22.0 - TIME * speed * 3.0),
		cos(UV.x * 140.0 - low * 30.0 + TIME * speed * 2.3));
	float heat = pow(low, 1.6) * glow_gain;
	ALBEDO = texture(screen, SCREEN_UV + wob * strength * fade).rgb + glow_color.rgb * heat;
	ALPHA = fade;
}
