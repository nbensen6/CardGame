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
// A rigged drawing (views/drawn_rig.gd) reaches here through a SubViewport,
// whose transparent target holds colour premultiplied by alpha.
uniform bool premul = false;
// TARGET's warm glow outside the line, grown from the figure's alpha so it
// follows the parts as they move. 0 = none (a PNG that carries its own).
uniform float halo = 0.0;
uniform float halo_px = 10.0;
uniform vec3 halo_color = vec3(1.0, 0.674, 0.259);

float glow_at(vec2 uv) {
	vec2 t = halo_px / vec2(textureSize(tex, 0));
	float g = 0.0;
	for (int i = 0; i < 12; i++) {
		float a = float(i) * 0.5236;
		vec2 d = vec2(cos(a), sin(a));
		g += texture(tex, uv + d * t * 0.45).a * 0.6 + texture(tex, uv + d * t).a * 0.4;
	}
	return g / 12.0;
}

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
		if (premul && t.a > 0.0) {
			t.rgb /= t.a;
		}
		if (halo > 0.0 && t.a < 1.0) {
			float g = glow_at(UV) * halo * (1.0 - t.a);
			float a = t.a + g;
			t.rgb = (t.rgb * t.a + halo_color * g) / max(a, 0.0001);
			t.a = a;
		}
		ALBEDO = vec3(emit(t.r), emit(t.g), emit(t.b));
		ALPHA = t.a;
	}
}
