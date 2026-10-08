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
#include "res://assets/3d/drawn_sprite_lut3d.gdshaderinc"

// tools/drawn_lut.py paints a ramp with this to measure the curve.
uniform bool calibrate = false;
// tools/drawn_lut3d.py: >= 0 paints LUT3_N^3 emission samples, four blue
// slices per shot (slices 4*cal_grid..+3), in a green frame with a red
// corner at UV 0,0; 99 paints every cell one grey (finds what covers the
// quad); cal_flip turns the cells 180 degrees so a covered cell is seen in
// the other shot.
uniform int cal_grid = -1;
uniform bool cal_flip = false;
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

// Emission for a texel the screen should show as `want` (sRGB 0..1):
// trilinear in the measured table, then the table's curve back to linear.
const float EMIT_CAP = 1.6;
vec3 emit3(vec3 want) {
	vec3 f = clamp(want, 0.0, 1.0) * float(LUT3_N - 1);
	ivec3 lo = ivec3(floor(f));
	ivec3 hi = min(lo + 1, ivec3(LUT3_N - 1));
	vec3 w = f - vec3(lo);
	int n = LUT3_N;
	vec3 c000 = LUT3[lo.r + n * (lo.g + n * lo.b)];
	vec3 c100 = LUT3[hi.r + n * (lo.g + n * lo.b)];
	vec3 c010 = LUT3[lo.r + n * (hi.g + n * lo.b)];
	vec3 c110 = LUT3[hi.r + n * (hi.g + n * lo.b)];
	vec3 c001 = LUT3[lo.r + n * (lo.g + n * hi.b)];
	vec3 c101 = LUT3[hi.r + n * (lo.g + n * hi.b)];
	vec3 c011 = LUT3[lo.r + n * (hi.g + n * hi.b)];
	vec3 c111 = LUT3[hi.r + n * (hi.g + n * hi.b)];
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

vec3 cal_cell(vec2 uv) {
	const float B = 0.04;
	if (uv.x < B && uv.y < B) return vec3(1.0, 0.0, 0.0);
	if (uv.x < B || uv.y < B || uv.x > 1.0 - B || uv.y > 1.0 - B) return vec3(0.0, 1.0, 0.0);
	vec2 q = (uv - B) / (1.0 - 2.0 * B);
	if (cal_flip) q = 1.0 - q;
	if (cal_grid == 99) return vec3(0.3);
	ivec2 blk = ivec2(floor(q * 2.0));
	int slice = cal_grid * 4 + blk.y * 2 + blk.x;
	ivec2 cell = ivec2(floor(fract(q * 2.0) * float(LUT3_N)));
	if (slice >= LUT3_N) return vec3(0.0);
	vec3 u = vec3(float(cell.x), float(cell.y), float(slice)) / float(LUT3_N - 1);
	return LUT3_E0 + (LUT3_EMAX - LUT3_E0) * pow(u, vec3(LUT3_GAMMA));
}

void fragment() {
	if (calibrate && cal_grid >= 0) {
		ALBEDO = cal_cell(UV);
		ALPHA = 1.0;
	} else if (calibrate) {
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
		ALBEDO = emit3(t.rgb);
		ALPHA = t.a;
	}
}
