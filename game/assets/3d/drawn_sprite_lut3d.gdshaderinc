// Written by tools/drawn_lut3d.py -- do not edit by hand. Measured 2026-10-08 on combat_3d.tscn's Environment.
// Screen sRGB (r + N*(g + N*b) on an N-grid) -> u; emit E0 + (EMAX - E0) * u^GAMMA.
// The table is drawn_sprite_lut3d.tres, a float texture (texel i % N^2, i / N^2) bound by
// the drawn_lut3d shader global: NVIDIA will not compile it as an N^3 constant array.
const int LUT3_N = 17;
const float LUT3_E0 = 0.120;
const float LUT3_EMAX = 2.400;
const float LUT3_GAMMA = 1.700;
global uniform sampler2D drawn_lut3d;
vec3 LUT3(int i) {
	return texelFetch(drawn_lut3d, ivec2(i % 289, i / 289), 0).rgb;
}
