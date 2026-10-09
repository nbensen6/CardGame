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
uniform sampler2D tex : filter_linear_mipmap, repeat_disable;   // no wrap: halo and footprint taps past the top edge pulled the lava rows down from the bottom (a red line across the sky, 2026-10-09)
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
// Unsharp mask, in texture pixels. The rig's parts reach the screen through
// two linear resamples (part -> rig viewport, viewport -> billboard), which
// halve the edge contrast TARGET's own pixels carry: the cracks read thin
// and dim. This puts it back. 0 = off.
uniform float sharpen = 0.0;
// Box-filter each screen pixel's whole footprint in the texture (3x3 taps
// across dFdx/dFdy) instead of one bilinear tap. The rig renders above
// screen size so its parts are drawn sharp; this brings it down without
// skipping texels (thin cracks) or the blur of a mip chain. false = one tap.
uniform bool footprint = false;
// The footprint's kernel: false a box (one screen pixel), true Lanczos-2 over
// +-1.5 screen pixels in half-pixel taps, the resample TARGET is measured at
// (tools/vs_target.py brings TARGET to the square with Lanczos). The box left
// every line ~half a pixel softer than TARGET's: the cream outline's edges
// and the cracks' cores lower, a glow one pixel past the outline ("Scene
// lines soft", builder 2026-10-09 run 18).
uniform bool footprint_lanczos = false;
uniform float screen_sharpen = 0.0;
uniform float screen_sharpen_px = 1.0;
// TARGET's lava cracks read as wide channels with yellow-hot cores; through
// the resamples they thin to lines. crack_grow spreads each crack's colour
// over the plate pixels next to it (radius in texture pixels), crack_heat
// lifts the brightest crack pixels toward TARGET's yellow core. 0 = off.
uniform float crack_grow = 0.0;
uniform float crack_px = 2.6;
uniform float crack_heat = 0.0;
uniform float crack_orange = 0.0;
uniform float hot_glow = 0.0;
uniform float hot_glow_px = 3.5;
uniform vec3 crack_core = vec3(1.0, 0.82, 0.30);

float hotness(vec4 c) {
	if (c.a < 0.9) return 0.0;
	vec3 r = c.rgb / c.a;
	return smoothstep(0.78, 0.95, r.r) * smoothstep(0.38, 0.62, r.g) * smoothstep(0.30, 0.16, r.b);
}

float crackness(vec4 c) {
	if (c.a < 0.9) return 0.0;
	vec3 r = c.rgb / c.a;
	// Hot orange-red: red high, blue low, red well above green.
	return smoothstep(0.55, 0.8, r.r) * smoothstep(0.25, 0.1, r.b) * smoothstep(0.12, 0.3, r.r - r.g);
}
uniform float halo_px = 10.0;
uniform vec3 halo_color = vec3(1.0, 0.674, 0.259);
// Above 0, only texels at least this opaque cast the halo: a backdrop pocket
// drawn just under full alpha (beast_rig.py POCKET_ALPHA) casts none.
uniform float halo_from = 0.0;

float halo_a(float a) {
	return halo_from > 0.0 ? smoothstep(halo_from - 0.02, 1.0, a) : a;
}

float glow_at(vec2 uv) {
	vec2 t = halo_px / vec2(textureSize(tex, 0));
	float g = 0.0;
	for (int i = 0; i < 12; i++) {
		float a = float(i) * 0.5236;
		vec2 d = vec2(cos(a), sin(a));
		g += halo_a(texture(tex, uv + d * t * 0.45).a) * 0.6 + halo_a(texture(tex, uv + d * t).a) * 0.4;
	}
	return g / 12.0;
}

// Emission for a texel the screen should show as `want` (sRGB 0..1):
// trilinear in the measured table, then the table's curve back to linear.
const float EMIT_CAP = 2.2;
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
		vec4 t;
		if (footprint) {
			vec2 dx = dFdx(UV);
			vec2 dy = dFdy(UV);
			t = vec4(0.0);
			if (footprint_lanczos) {
				// Lanczos-2 at 0, +-0.5, +-1, +-1.5 screen px (the +-1 taps weigh 0).
				float lw[4] = float[](1.0, 0.5731, 0.0, -0.0637);
				float wsum = 0.0;
				for (int i = -3; i <= 3; i++) {
					for (int j = -3; j <= 3; j++) {
						float w = lw[abs(i)] * lw[abs(j)];
						if (w == 0.0) continue;
						t += w * textureLod(tex, UV + dx * (float(i) * 0.5) + dy * (float(j) * 0.5), 0.0);
						wsum += w;
					}
				}
				t = clamp(t / wsum, vec4(0.0), vec4(1.0));
				t.rgb = min(t.rgb, vec3(t.a));
			} else {
				for (int i = -1; i <= 1; i++) {
					for (int j = -1; j <= 1; j++) {
						t += textureLod(tex, UV + dx * (float(i) / 3.0) + dy * (float(j) / 3.0), 0.0);
					}
				}
				t /= 9.0;
			}
			if (screen_sharpen > 0.0) {
				// The box footprint is softer than the Lanczos resample TARGET
				// is measured at: a small unsharp mask at screen-pixel reach
				// puts the thin cracks' peaks back.
				vec4 w = (textureLod(tex, UV + dx * screen_sharpen_px, 0.0) + textureLod(tex, UV - dx * screen_sharpen_px, 0.0)
					+ textureLod(tex, UV + dy * screen_sharpen_px, 0.0) + textureLod(tex, UV - dy * screen_sharpen_px, 0.0)) * 0.25;
				vec4 sh = t + (t - w) * screen_sharpen;
				// Only inside solid rock: at the silhouette it would ring.
				float solid = step(0.999, min(t.a, w.a));
				t = mix(t, clamp(sh, vec4(0.0), vec4(1.0)), solid);
			}
		} else {
			t = texture(tex, UV);
		}
		if (sharpen > 0.0) {
			vec2 px = 1.0 / vec2(textureSize(tex, 0));
			vec4 n = (texture(tex, UV + vec2(px.x, 0.0)) + texture(tex, UV - vec2(px.x, 0.0))
				+ texture(tex, UV + vec2(0.0, px.y)) + texture(tex, UV - vec2(0.0, px.y))) * 0.25;
			t = clamp(t + (t - n) * sharpen, vec4(0.0), vec4(1.0));
			t.rgb = min(t.rgb, vec3(t.a));
		}
		if (crack_grow > 0.0 && t.a > 0.9) {
			vec2 px = crack_px / vec2(textureSize(tex, 0));
			vec4 best = vec4(0.0);
			float bm = 0.0;
			float bs = 0.0;
			float bh = 0.0;
			// A crack is a line between dark plates; the fist's fire is a broad
			// bright field. Only pixels with dark rock within reach are cracks.
			float plate = 0.0;
			for (int i = 0; i < 16; i++) {
				float ang = float(i) * 0.7854 + (i >= 8 ? 0.3927 : 0.0);
				// Two rings (half and full reach), so the grown fringe is solid
				// from the crack out, not a parallel line with a gap.
				vec4 c = texture(tex, UV + vec2(cos(ang), sin(ang)) * px * (i >= 8 ? 0.5 : 1.0));
				// The brightest crack pixel in reach (the orange core, not the
				// deep red edge), so the widened channel keeps the core's colour.
				float m = crackness(c);
				float score = m * (0.3 + dot(c.rgb, vec3(0.3, 0.59, 0.11)));
				if (score > bs) { bs = score; bm = m; best = c; }
				bh = max(bh, hotness(c));
				if (c.a > 0.9) plate = max(plate, smoothstep(0.32, 0.18, dot(c.rgb / c.a, vec3(0.3, 0.59, 0.11))));
			}
			float own = crackness(t);
			float ownh = hotness(t) * plate;
			bm *= plate;
			bh *= plate;
			// Never over a light pixel: the cream line and the eyes' cores stay.
			float light = smoothstep(0.45, 0.65, t.g / max(t.a, 1e-4));
			// Only onto the dark rock plates: the fire's dark red glow between
			// its tongues is brighter red than any plate and must stay a gap.
			float rock = smoothstep(0.55, 0.42, t.r / max(t.a, 1e-4));
			// Grow only where a neighbour is more crack than this pixel, by how
			// much more: the crack's own soft edge fills in instead of gapping.
			// A max filter: take the crack's colour wherever it is brighter than
			// this pixel, so the channel widens solid from its core outwards.
			float lt = dot(t.rgb, vec3(0.3, 0.59, 0.11));
			float lb = dot(best.rgb, vec3(0.3, 0.59, 0.11));
			float w = crack_grow * bm * smoothstep(0.0, 0.06, lb - lt) * (1.0 - light);
			// One solid stroke: the fringe takes the crack's own colour.
			t = mix(t, best, clamp(w, 0.0, 1.0));
			// TARGET's limb cracks are orange, not deep red: lift green in the
			// crack (its own and the grown fringe) toward orange.
			float cm = max(own, w);
			t.g = mix(t.g, max(t.g, t.r * 0.36), clamp(cm * crack_orange, 0.0, 1.0));
			// The yellow cores spread too (TARGET's sternum Y is a wide fan).
			// TARGET's channels read orange at their middle, red only at the
			// rim: the red-hot middle of each channel is lifted to orange.
			vec3 tu = t.rgb / max(t.a, 1e-4);
			float core = smoothstep(0.74, 0.92, tu.r) * smoothstep(0.16, 0.32, tu.g) * smoothstep(0.35, 0.2, tu.b) * plate;
			t.rgb = mix(t.rgb, vec3(1.0, 0.58, 0.16) * t.a, clamp(core * crack_heat * 0.55, 0.0, 1.0));
			float h = crack_heat * max(ownh, bh * 0.8 * (1.0 - light) * rock);
			t.rgb = mix(t.rgb, crack_core * t.a, clamp(h, 0.0, 1.0));
			// TARGET's hottest seams (the sternum Y) throw a soft gold glow over
			// the plates round them: the yellow cores, blurred wide, added.
			if (hot_glow > 0.0) {
				float gsum = 0.0;
				for (int i = 0; i < 12; i++) {
					float ang = float(i) * 0.5236 + 0.26;
					vec2 d = vec2(cos(ang), sin(ang)) * px / crack_px;
					gsum += hotness(texture(tex, UV + d * hot_glow_px * 0.4)) * 0.5
						+ hotness(texture(tex, UV + d * hot_glow_px)) * 0.5;
				}
				float gl = clamp(gsum / 12.0 * hot_glow, 0.0, 1.0) * (1.0 - light) * plate * rock;
				t.rgb = mix(t.rgb, crack_core * t.a, gl);
			}
		}
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
