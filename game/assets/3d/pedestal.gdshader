shader_type spatial;
render_mode cull_disabled, diffuse_toon, specular_disabled;

// The Frog's pedestal (TARGET.png, builder 2026-10-08): a dark hex pillar in
// flat tones, one per face, carried by the mesh's vertex colour -- a pale plum
// top, near-black navy sides, a thin ember rim along the back top edges.
// Mostly emission so the lava omni lights cannot turn it maroon (they multiply
// albedo); a little albedo so the hunter's shadow still lands on the top.

uniform float glow : hint_range(0.0, 3.0) = 1.7;
uniform float lit : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	ALBEDO = COLOR.rgb * lit;
	EMISSION = COLOR.rgb * glow;
	ROUGHNESS = 1.0;
}
