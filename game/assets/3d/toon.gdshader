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

// White when unset, so an untextured part (the jackal's basalt footholds) is
// just its `tint`.
uniform sampler2D albedo_tex : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
// The darkest the lit body may paint, applied AFTER the glow mask is read, so
// a near-black painted body reads as rock without any of it turning "hot"
// (scene pass 1, picture A, 2026-10-04). Zero is a no-op.
uniform vec3 body_floor = vec3(0.0);
// Mip bias on the painted texture. A generated texture carries per-pixel
// noise that reads as grit, not rock; sampling a blurrier mip turns it into
// flat colour planes like picture A (Nick, 2026-10-04). Zero is a no-op.
uniform float tex_soften = 0.0;
// 1.0 lights each triangle with its own face normal (screen derivatives), so
// the rock reads as cut flat planes, each one lit or in shadow whole. Zero
// keeps the mesh's own normals.
uniform float facet = 0.0;
// How much each flat face is shaded by which way it faces (a fixed key from
// upper front-left, in view space), so neighbouring planes differ in value
// even in shadow, like a cut stone. Zero is a no-op.
uniform float facet_shade = 0.0;
// Eyes: two points in the model's own space whose hot pixels glow eye_gain
// times harder, so the eyes read as two lit points and bloom at fight
// distance instead of losing to the bigger hot patches (the inner ears).
// eye_gain 0 is a no-op.
uniform vec3 eye_l = vec3(0.0);
uniform vec3 eye_r = vec3(0.0);
uniform float eye_radius = 0.05;
uniform float eye_gain = 0.0;
varying vec3 v_model;

// One hard band: lit or shadow, no midtone step. Style C, Nick 2026-09-24
// (Risk of Rain 2 / Hopoo Games — low-poly, flat-shaded, no gradient). Was
// three bands (lit/half/shadow) with a soft ~3%-wide edge; band_lo now sits
// on band_hi so the midtone plateau collapses to nothing, and the edge itself
// is razor-thin instead of soft, so the boundary reads as a hard cel line
// rather than a shaded falloff. half_level stays wired (mix() still runs) so
// a future style can reopen the midtone without touching the light() logic.
uniform float band_hi : hint_range(0.0, 1.0) = 0.55;
uniform float band_lo : hint_range(0.0, 1.0) = 0.55;
uniform float band_soft : hint_range(0.001, 0.2) = 0.008;
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

// IDLE LIFE — no rig, so the motion lives here. Masks are in the model's own
// space (glTF: +Z toward the head, the hunters). All zero by default: a model
// that does not ask for motion does not move. Mirrored in outline.gdshader so
// the ink line rides the same surface.
uniform float tail_amp = 0.0;          // tip travel, model units
uniform float tail_rate = 0.9;
uniform vec2 tail_x = vec2(-1.0, -3.2); // mask ramps in over this model-X span
uniform vec2 tail_z = vec2(-1.4, -2.2); // ... and over this model-Z span
uniform float breath_amp = 0.0;        // along the normal, model units
uniform float breath_rate = 1.3;
uniform float breath_min_y = 1.2;      // only the barrel breathes, not the legs
uniform float glow_pulse = 0.0;
// The colour the hot cracks glow, mixed over the painted one by its alpha
// (0, the default, is a no-op). The body's cool `tint` also cools the cracks
// to red; this lets them burn A's orange while the plates stay basalt.
uniform vec4 glow_color = vec4(1.0, 0.6, 0.15, 0.0);

vec3 idle(vec3 v, vec3 n) {
	// Negated so edge0 < edge1: smoothstep with them reversed is undefined in GLSL.
	float tail = smoothstep(-tail_x.x, -tail_x.y, -v.x) * smoothstep(-tail_z.x, -tail_z.y, -v.z);
	// Sweep: the further out along the tail, the further it travels, lagging
	// behind the root so it reads as a whip rather than a stiff paddle.
	float lag = (-v.x) * 0.6;
	v.z += sin(TIME * tail_rate - lag) * tail_amp * tail * tail;
	float barrel = smoothstep(breath_min_y, breath_min_y + 0.5, v.y) * (1.0 - tail);
	v += n * sin(TIME * breath_rate) * breath_amp * barrel;
	return v;
}

void vertex() {
	VERTEX = idle(VERTEX, NORMAL);
	v_model = VERTEX;
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}

void fragment() {
	// COLOR is the mesh's own per-vertex colour, white (1,1,1,1) when a model
	// carries none, so this is a no-op for every already-shipped textured
	// model. A model baked to flat per-face vertex colour (request #13 — the
	// hunters, whose auto-generated texture was noise, not detail, at their
	// real ~40px on-screen size) supplies a plain white 1x1 albedo_tex so its
	// true colour comes entirely from COLOR.
	// The glow mask reads the sharp texture so the cracks stay crisp lines;
	// only the body colour takes the softened mip.
	vec3 base = texture(albedo_tex, UV).rgb * tint.rgb * COLOR.rgb;
	vec3 body = texture(albedo_tex, UV, tex_soften).rgb * tint.rgb * COLOR.rgb;
	if (facet > 0.0) {
		vec3 fn = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
		NORMAL = normalize(mix(NORMAL, fn, facet));
	}
	float face = 1.0;
	if (facet_shade > 0.0) {
		vec3 fn = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
		face = mix(1.0, 0.45 + 0.9 * clamp(dot(fn, normalize(vec3(-0.35, 0.55, 0.75))), 0.0, 1.0), facet_shade);
	}
	ALBEDO = base;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;

	// With glow_color set, the mask reads the paint a quarter of the way back
	// from the tint, so a cooled body keeps its cracks inside the orange
	// window. Half way or more lit the whole jackal (pass 14).
	vec3 paint = texture(albedo_tex, UV).rgb * COLOR.rgb;
	vec3 hsv = rgb2hsv(glow_color.a > 0.0 ? mix(base, paint, 0.25) : base);
	float hue_d = min(abs(hsv.x - glow_hue), 1.0 - abs(hsv.x - glow_hue));
	float hot = (1.0 - smoothstep(0.03, 0.08, hue_d)) * smoothstep(0.55, 0.8, hsv.y) * smoothstep(0.55, 0.85, hsv.z);
	vec3 heat = mix(base, glow_color.rgb, glow_color.a);
	EMISSION = heat * hot * glow_gain * (1.0 + sin(TIME * 1.1) * glow_pulse);
	if (eye_gain > 0.0) {
		float d = min(distance(v_model, eye_l), distance(v_model, eye_r));
		float eye = 1.0 - smoothstep(eye_radius * 0.6, eye_radius, d);
		EMISSION += heat * hot * eye * eye_gain;
	}
	// The face shade goes on after the floor, so a floored body still shows
	// its planes; the hot cracks keep their own colour.
	ALBEDO = mix(max(body, body_floor) * face, heat, hot);
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
