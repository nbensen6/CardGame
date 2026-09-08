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

// EMBERS — palette swatches that glow.
//
// Added 2026-09-08 after measuring the jackal against the Sea of Thieves
// megalodon Nick sent: only 2.5% of our beast sat above 80% luminance and
// nothing in the frame told the eye where to look, while that shark's whole
// design hangs off white-hot cracks and eyes against a near-black body.
//
// Keyed on the swatch's UV rather than on its colour, which is exact rather
// than a guess: kenney.swatch(px, py) == (px/512, 1 - (py+16)/512), colour
// lives in the UV, and every face points at exactly one cell. Colour-keying
// would have caught the jackal's RUST body along with its TANGERINE ridge.
uniform vec2 ember_uv[4];
uniform int ember_count = 0;
uniform float ember_gain : hint_range(0.0, 8.0) = 2.6;
// Smouldering, not burning: the glow breathes instead of sitting flat. This is
// the one place a pulse belongs — it is light, not geometry, so nothing changes
// size and nothing leaves the ground.
uniform float ember_pulse : hint_range(0.0, 1.0) = 0.22;
uniform float ember_rate : hint_range(0.1, 4.0) = 1.1;
// Hot things go WHITE at the core, and this is the difference between "an
// orange part" and "a glowing part". Measured: turning the ridge and eyes on at
// full saturation moved the beast's share of pixels above 80% luminance from
// 2.5% to 2.4% — visible, but not BRIGHT, because saturated orange
// (255,140,40) only reaches 62% luminance no matter how far the gain is pushed.
// The reference this is chasing — the Sea of Thieves megalodon — runs
// near-white at the centre of every crack and orange only at the edges. With no
// bloom available on gl_compatibility, ramping to white IS the effect.
uniform float ember_white : hint_range(0.0, 1.0) = 0.55;

// Value range — BUILDER-QUEUE.md item 1. Measured against the Sea of Thieves
// megalodon: their body runs near-black so the embers can scream, ours sits
// mid-range everywhere and only 2.4% of it clears 80% luminance.
//
// A swatch swap was tried first (builder/2026-09-08-widen-value-range) and
// could not move the top of the range at all — it can only pick a different
// point ALONG the palette's existing luminance band, and that band is not
// very dark to begin with. This is the actual lever: multiply the lit body
// down and the embers up in the same draw call, so the gap opens from both
// ends instead of sliding along one narrow band. Default 1.0 is a no-op, so
// every beast that has not opted in (set from combat_3d.VALUE_RANGE, beside
// EMBERS) renders exactly as before.
uniform float body_gain : hint_range(0.0, 1.0) = 1.0;

// Surface breakup — BUILDER-QUEUE.md item 2. Their skin carries scarring and
// tonal variation; ours is flat swatches, one colour per face, no variation
// anywhere. No textures and no per-asset work: a triplanar value noise, in
// OBJECT space so it stays glued to the surface through idle sway and
// breathing rather than swimming across it, modulating brightness only —
// never hue, so the palette-swatch read this game depends on survives.
// Default 0.0 is a no-op, same shape as body_gain: a beast only breaks up
// once it has an entry in combat_3d.SURFACE_BREAKUP.
uniform float breakup_strength : hint_range(0.0, 1.0) = 0.0;
uniform float breakup_scale : hint_range(0.1, 20.0) = 3.0;

// Volume cue: the underside of a form reads cooler and darker than its top.
// Cheap, and it survives being 200px tall on screen where AO detail does not.
uniform vec4 ground_tint : source_color = vec4(0.42, 0.44, 0.58, 1.0);
uniform float ground_strength : hint_range(0.0, 1.0) = 0.22;

varying vec3 world_normal;
varying vec3 object_pos;
varying vec3 object_normal;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    // Object space, not world: these models only ever translate/rotate as a
    // whole (no skinning), so noise keyed here rides along with the beast
    // instead of sliding across its skin as it breathes and sways.
    object_pos = VERTEX;
    object_normal = NORMAL;
}

// Cheap 2D value noise — no textures, so this has to be analytic. Smoothstep
// interpolation between hashed lattice corners; nothing fancier is needed to
// read as scarring at fight distance (~250px tall on screen). Triplanar only
// ever samples a 2D projection of object space, so the noise stays 2D too.
float _breakup_hash(vec2 p) {
    p = fract(p * vec2(0.1031, 0.1030));
    p += dot(p, p.yx + 33.33);
    return fract((p.x + p.y) * p.x);
}

float _breakup_noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(_breakup_hash(i + vec2(0.0, 0.0)), _breakup_hash(i + vec2(1.0, 0.0)), f.x),
               mix(_breakup_hash(i + vec2(0.0, 1.0)), _breakup_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// Triplanar: blend the three axis-aligned projections by how much the
// (object-space) normal faces each one, so a flat low-poly face never shows a
// single projection stretched across it.
float _breakup_triplanar(vec3 pos, vec3 nrm, float scale) {
    vec3 w = abs(normalize(nrm));
    w /= (w.x + w.y + w.z + 0.0001);
    float nx = _breakup_noise(pos.yz * scale);
    float ny = _breakup_noise(pos.xz * scale);
    float nz = _breakup_noise(pos.xy * scale);
    return nx * w.x + ny * w.y + nz * w.z;
}

void fragment() {
    vec3 base = texture(atlas, UV).rgb;

    // COLOR is COLOR_0 from the glTF. A model with no baked AO imports as
    // white, so this is a no-op on unbaked assets rather than a regression.
    float ao = mix(1.0, max(COLOR.r, ao_floor), ao_strength);

    // Downward-facing surfaces pick up the ground tint, upward ones do not.
    float down = clamp(-world_normal.y, 0.0, 1.0);
    // -1..1 around zero, so strength 0 multiplies by exactly 1.0 — a true
    // no-op, not just a small one — and the noise darkens as often as it
    // lightens rather than flattening the body's own gain.
    float breakup = (_breakup_triplanar(object_pos, object_normal, breakup_scale) - 0.5) * 2.0;
    vec3 tinted = mix(base, base * ground_tint.rgb, down * ground_strength)
                * body_gain * (1.0 + breakup * breakup_strength);

    // How much of this face is an ember swatch. A half-cell radius: swatch
    // centres are 32px apart on a 512 atlas, so 0.0625 apart in UV — keying
    // inside 0.012 cannot reach a neighbour.
    float ember = 0.0;
    for (int i = 0; i < ember_count; i++) {
        ember = max(ember, 1.0 - smoothstep(0.004, 0.012, distance(UV, ember_uv[i])));
    }
    float beat = 1.0 + sin(TIME * ember_rate) * ember_pulse;

    // An ember is its own light source, so neither the crevice shading nor the
    // ground bounce has any business darkening it.
    // The core runs hotter than the edge: strongest where the face sits dead on
    // the swatch, cooling to the swatch's own colour at the fringe.
    vec3 hot = mix(base, vec3(1.0), ember_white * ember);

    ALBEDO = mix(tinted * ao, hot, ember);
    ROUGHNESS = mix(rough, 1.0, ember);
    SPECULAR = spec * (1.0 - ember);

    float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), rim_width);
    RIM = fres * rim_strength * (1.0 - ember);
    RIM_TINT = 0.6;
    // Rim as emission too, so it still separates the beast from a dark ground
    // in a biome whose key light is behind it — plus the embers themselves,
    // which are the only thing here that is allowed to be the brightest object
    // in the frame.
    EMISSION = rim_color.rgb * fres * rim_strength * 0.35 * ao
             + hot * ember * ember_gain * beat;
}
