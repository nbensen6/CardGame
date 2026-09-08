shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// A stylized creature shader — prototype, 2026-09-08.
//
// The problem it answers: every beast in this game renders on ONE material, one
// flat palette swatch per part, roughness 1.0, no normal map, no AO, and no
// shader at all (kenney.py:204). That is a matte flat-coloured blob by
// construction, and it is why six beasts each gained three points of geometry
// polish and still read as an asset pack. The models were never the problem.
//
// Everything here is chosen to work on the `gl_compatibility` renderer, which
// the project targets for mobile readiness (CLAUDE.md) and which has no SSAO
// and no SDFGI. So the depth comes from vertex-baked AO (tools/blender/aobake.py)
// rather than from a screen-space pass, and the separation comes from a rim
// term rather than from post.
//
// It deliberately keeps ENGINE lighting rather than going unshaded: the fight
// already sets a sun, a fill and an ambient per biome (combat_3d.gd), and
// throwing that away to hand-roll a ramp would lose the per-biome mood the
// game already has.

uniform sampler2D atlas : source_color, filter_nearest;

// AO baked into COLOR_0 by tools/blender/aobake.py. Strength 0 reproduces the
// old flat look exactly, which is what makes an honest before/after possible.
// These are deliberately gentle. The first values tried (0.85 / 0.25) turned
// the jackal into a black mass in the fight: models here are built from
// OVERLAPPING primitives, so a lot of vertices sit inside another part and bake
// almost fully occluded. The floor is what keeps those from reading as holes.
uniform float ao_strength : hint_range(0.0, 1.0) = 0.45;
uniform float ao_floor : hint_range(0.0, 1.0) = 0.55;   // never crush to black

// A low-poly model has few normals, so a plain fresnel rim reads as a hard
// outline. Widening the falloff turns it into a light wrap instead.
uniform vec4 rim_color : source_color = vec4(0.72, 0.80, 1.00, 1.0);
uniform float rim_strength : hint_range(0.0, 2.0) = 0.55;
uniform float rim_width : hint_range(1.0, 8.0) = 3.0;

// Flat swatches give the eye nothing to catch. A little specular puts a moving
// highlight on the form as the camera orbits, which is most of what separates
// "a shape" from "a thing made of something".
// Toned down 2026-09-08 — Nick: "tone down the shine." The first values
// (0.62 / 0.35) put a plastic sheen on the crag pup and the clot toad. These
// keep the form-reading highlight and drop the wet look.
uniform float rough : hint_range(0.0, 1.0) = 0.86;
uniform float spec : hint_range(0.0, 1.0) = 0.10;

// Volume cue: the underside of a form reads cooler and darker than its top.
// Cheap, and it survives being 200px tall on screen where AO detail does not.
uniform vec4 ground_tint : source_color = vec4(0.42, 0.44, 0.58, 1.0);
uniform float ground_strength : hint_range(0.0, 1.0) = 0.22;

varying vec3 world_normal;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    vec3 base = texture(atlas, UV).rgb;

    // COLOR is COLOR_0 from the glTF. A model with no baked AO imports as
    // white, so this is a no-op on unbaked assets rather than a regression.
    float ao = mix(1.0, max(COLOR.r, ao_floor), ao_strength);

    // Downward-facing surfaces pick up the ground tint, upward ones do not.
    float down = clamp(-world_normal.y, 0.0, 1.0);
    vec3 tinted = mix(base, base * ground_tint.rgb, down * ground_strength);

    ALBEDO = tinted * ao;
    ROUGHNESS = rough;
    SPECULAR = spec;

    float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), rim_width);
    RIM = fres * rim_strength;
    RIM_TINT = 0.6;
    // Rim as emission too, so it still separates the beast from a dark ground
    // in a biome whose key light is behind it.
    EMISSION = rim_color.rgb * fres * rim_strength * 0.35 * ao;
}
