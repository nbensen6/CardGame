shader_type spatial;
render_mode cull_back, diffuse_toon, specular_disabled;

// Dark basalt with an ember glow — "Lava rock under the hunters", 2026-09-30.
// Used on the climb stones by a biome that names `"stone": "lava_rock"` in
// combat_3d.BIOME (quarry_ember only). The stone's own body and cap take it.
//
// Two glows, both emission so they read in the jackal fight's dim light:
//   - underside: faces that point DOWN in world space glow, as if lit from the
//     heat under them;
//   - edge: a fresnel rim, so the silhouette of every stone carries an orange
//     line against the black floor even from the wide shot.

uniform vec4 base_color : source_color = vec4(0.11, 0.095, 0.10, 1.0);
uniform sampler2D detail : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 glow_color : source_color = vec4(1.0, 0.32, 0.06, 1.0);
uniform float under_gain : hint_range(0.0, 6.0) = 0.7;
uniform float edge_gain : hint_range(0.0, 6.0) = 1.2;
uniform float edge_power : hint_range(0.5, 12.0) = 7.0;

void fragment() {
	vec3 d = texture(detail, UV).rgb;
	ALBEDO = base_color.rgb * mix(0.7, 1.2, d.r);
	ROUGHNESS = 0.95;
	vec3 wn = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float under = smoothstep(-0.55, -0.95, wn.y);
	float edge = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), edge_power);
	EMISSION = glow_color.rgb * (under * under_gain + edge * edge_gain);
}
