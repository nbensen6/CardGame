shader_type spatial;
render_mode cull_back, diffuse_toon, specular_toon;

// Toon shader for TEXTURED models — spike, 2026-09-22.
//
// creature.gdshader is built around the palette atlas: one flat swatch per
// face, embers keyed on swatch UVs. A model that arrives with its own painted
// texture (AI image-to-3D, an asset pack) breaks both assumptions, so it gets
// this instead.
//
// The look is the one the research kept landing on for Sea of Thieves /
// Astroneer-style stylisation: light in a few hard bands rather than a smooth
// falloff, and shadow that goes COOL instead of going black. Works on
// gl_compatibility — it is all in light(), no screen-space pass.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);

// Three bands: lit, half, shadow. Soft edges a few % wide so the band boundary
// does not crawl as the beast breathes.
uniform float band_hi : hint_range(0.0, 1.0) = 0.55;
uniform float band_lo : hint_range(0.0, 1.0) = 0.12;
uniform float band_soft : hint_range(0.001, 0.2) = 0.03;
uniform float half_level : hint_range(0.0, 1.0) = 0.62;
// Shadow is a colour, not an absence of light.
uniform vec4 shadow_color : source_color = vec4(0.38, 0.40, 0.62, 1.0);

uniform vec4 rim_color : source_color = vec4(1.0, 0.86, 0.70, 1.0);
uniform float rim_strength : hint_range(0.0, 2.0) = 0.45;
uniform float rim_cut : hint_range(0.0, 1.0) = 0.72;

uniform float spec_strength : hint_range(0.0, 1.0) = 0.12;
uniform float spec_cut : hint_range(0.5, 1.0) = 0.94;

// Hot parts of the painted texture glow: anything this saturated and this
// orange lifts into emission. Stands in for the palette ember channel, which
// cannot key on UVs of a painted texture.
uniform float glow_gain : hint_range(0.0, 4.0) = 1.2;
uniform float glow_hue : hint_range(0.0, 1.0) = 0.07;   // orange

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}

void fragment() {
	vec3 base = texture(albedo_tex, UV).rgb * tint.rgb;
	ALBEDO = base;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;

	vec3 hsv = rgb2hsv(base);
	float hue_d = min(abs(hsv.x - glow_hue), 1.0 - abs(hsv.x - glow_hue));
	float hot = (1.0 - smoothstep(0.03, 0.08, hue_d)) * smoothstep(0.55, 0.8, hsv.y) * smoothstep(0.55, 0.85, hsv.z);
	EMISSION = base * hot * glow_gain;
}

void light() {
	float ndl = dot(NORMAL, LIGHT) * ATTENUATION;
	float lit = smoothstep(band_hi - band_soft, band_hi + band_soft, ndl);
	float mid = smoothstep(band_lo - band_soft, band_lo + band_soft, ndl);
	float level = mix(0.0, half_level, mid);
	level = mix(level, 1.0, lit);
	// Blend toward the shadow colour, rather than scaling toward black.
	vec3 shade = mix(shadow_color.rgb, vec3(1.0), level);
	DIFFUSE_LIGHT += shade * LIGHT_COLOR / PI;

	vec3 h = normalize(LIGHT + VIEW);
	float s = step(spec_cut, dot(NORMAL, h)) * lit;
	SPECULAR_LIGHT += s * spec_strength * LIGHT_COLOR / PI;

	float rim = 1.0 - dot(NORMAL, VIEW);
	rim = smoothstep(rim_cut - 0.02, rim_cut + 0.02, rim) * max(ndl, 0.0);
	DIFFUSE_LIGHT += rim * rim_strength * rim_color.rgb * LIGHT_COLOR / PI;
}
