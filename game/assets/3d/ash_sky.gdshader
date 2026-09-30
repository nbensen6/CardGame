shader_type sky;

// Ash over the Cinder Jackal's arena — "A sky with ash", 2026-09-30. Used by a
// biome that names `"ash_sky"` in combat_3d.BIOME (quarry_ember only); it
// replaces the plain ProceduralSkyMaterial gradient for that fight alone.
//
// Three things, bottom to top:
//   - the biome's own gradient, horizon into top, but spread over the lower
//     half of the sky instead of ProceduralSkyMaterial's curve-0 hard step;
//   - a layer of dark ash cloud, value-noise fbm projected on a flat ceiling
//     and drifting slowly, lit red from below: the nearer the horizon and the
//     thinner the cloud, the redder;
//   - now and then a distant glow pulse that warms the clouds' undersides on
//     one side of the sky.
// The environment's fog still lands on top of all of it (fog_sky_affect), so
// the haze behind the wall stays as it was.

uniform vec4 top_color : source_color = vec4(0.20, 0.23, 0.41, 1.0);
uniform vec4 horizon_color : source_color = vec4(0.80, 0.36, 0.38, 1.0);
uniform vec4 ground_color : source_color = vec4(0.10, 0.08, 0.10, 1.0);
uniform vec4 ash_color : source_color = vec4(0.05, 0.04, 0.05, 1.0);
uniform vec4 under_color : source_color = vec4(1.0, 0.30, 0.08, 1.0);
// Cloud cells across the ceiling, and how much of the sky they cover (0..1).
uniform float scale = 5.0;
uniform float cover = 0.48;
// Noise cells per second the ash drifts; combat_3d.ash_wind() sets it.
uniform vec2 wind = vec2(0.3, 0.1);
// Seconds between glow pulses, and how bright one peaks.
uniform float pulse_period = 9.0;
uniform float pulse_gain = 0.9;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void sky() {
	vec3 d = EYEDIR;
	// 0 at the horizon, 1 straight up.
	float el = 1.0 - acos(clamp(d.y, -1.0, 1.0)) / (PI * 0.5);
	vec3 base = mix(horizon_color.rgb, top_color.rgb, smoothstep(0.0, 0.55, el));
	if (d.y < 0.0) {
		COLOR = mix(horizon_color.rgb, ground_color.rgb, smoothstep(0.0, 0.3, -el));
	} else if (AT_CUBEMAP_PASS) {
		// Reflections and radiance get the gradient alone: cheap, and still.
		COLOR = base;
	} else {
		// A flat ceiling: clouds shrink and bunch toward the horizon.
		vec2 uv = d.xz / max(d.y, 0.06) * scale + TIME * wind;
		float n = fbm(uv);
		float n2 = fbm(uv * 0.5 + vec2(4.1, 2.3) - TIME * wind * 0.6);
		float dens = smoothstep(1.0 - cover, 1.0 - cover + 0.12, n * 0.65 + n2 * 0.35);
		// Thin out right at the horizon so the band there stays the glow.
		dens *= smoothstep(0.0, 0.08, el);
		// Red from below: strongest low in the sky and on thin cloud edges.
		// The arena's wall hides everything under ~0.18 and the fight camera
		// sees up to ~0.4 (measured, 2026-09-30), so "low" is measured over
		// that band: fully lit just above the wall, dark ash at the top.
		float low = 1.0 - smoothstep(0.18, 0.4, el);
		// The underside: cloud here with none just below it (toward the
		// horizon). That lower edge is the rim the fire lights.
		vec2 dn = d.xz / max(d.y - 0.03, 0.06) * scale + TIME * wind;
		float below = smoothstep(1.0 - cover, 1.0 - cover + 0.12,
			fbm(dn) * 0.65 + fbm(dn * 0.5 + vec2(4.1, 2.3) - TIME * wind * 0.6) * 0.35);
		float rim = clamp(dens - below, 0.0, 1.0);
		// The odd distant glow: a sharp swell once a period, on one side.
		float phase = fract(TIME / pulse_period);
		float swell = pow(sin(PI * clamp(phase / 0.25, 0.0, 1.0)), 2.0) * step(phase, 0.25);
		vec2 side = normalize(vec2(0.6, -0.8));
		float toward = smoothstep(0.2, 1.0, dot(normalize(d.xz + 1e-4), side));
		float glow = swell * toward * pulse_gain;
		float red = clamp(rim * (0.5 + low) + low * 0.2 + glow * (1.0 - el), 0.0, 1.0);
		vec3 cloud = mix(ash_color.rgb, under_color.rgb * 1.8, red);
		COLOR = mix(base, cloud, dens * 0.96) + under_color.rgb * glow * low * 0.25;
	}
}
