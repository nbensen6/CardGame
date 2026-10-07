// A drawn beast shows its own pixels.
//
// The fight's Environment (ACES, exposure, contrast, saturation) is right for
// the lit 3D scene and wrong for a finished illustration: it drops everything
// under about 0.14 linear to black, so the jackal's red-brown plates reached
// the screen at a third of their tone and its facets merged (grader,
// 2026-10-07). tools/drawn_lut.py measures that curve off a real shot and
// writes its inverse; this looks every texel up in it, so what reaches the
// screen is the PNG. Fog is off for the same reason. The table tops out at
// the white the scene can show without blooming, so the drawing never glows.
shader_type spatial;
render_mode unshaded, fog_disabled, cull_back, depth_prepass_alpha;

// Raw sRGB: the LUT is indexed by the value the screen should show.
uniform sampler2D tex : filter_linear_mipmap;
#include "res://assets/3d/drawn_sprite_lut.gdshaderinc"

// tools/drawn_lut.py paints a ramp with this to measure the curve.
uniform bool calibrate = false;

float emit(float target) {
	float i = clamp(target, 0.0, 1.0) * 255.0;
	int lo = int(floor(i));
	int hi = min(lo + 1, 255);
	return mix(DRAWN_LUT[lo], DRAWN_LUT[hi], i - float(lo));
}

void fragment() {
	if (calibrate) {
		ALBEDO = UV.y < 0.4 ? vec3(UV.x) : (UV.y < 0.6 ? vec3(1.0) : vec3(UV.x * 0.25));
		ALPHA = 1.0;
	} else {
		vec4 t = texture(tex, UV);
		ALBEDO = vec3(emit(t.r), emit(t.g), emit(t.b));
		ALPHA = t.a;
	}
}
