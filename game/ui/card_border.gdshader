shader_type canvas_item;
render_mode blend_mix;

// The card border, drawn rather than baked (Nick, 2026-09-30: "a redesign of
// the card borders is needed").
//
// The old border was a 9-slice of one lofted moulding in the hunter's colour:
// a thick green slab that read as plastic next to the obsidian HUD. This one
// is carved obsidian, the fight's own material, with the hunter kept as a thin
// line of colour where the border meets the art:
//
//   e (px in from the edge)   what it is
//   0 .. 1.3                  an outer brass hairline
//   1.3 .. 3                  outer bevel, lit from the top left
//   2 .. band-2               the flat dark face, with an engraved groove
//   band-2 .. band            inner bevel, lit the other way (a wall facing in)
//   band .. +2                a brass fillet, the warm line on the card
//   +2 .. +4.5                the hunter's colour, so ownership still reads
//   beyond                    the art, under a soft inner shadow
//
// Plus a brass stud at each corner and one at the foot. Everything is in
// pixels of the card's own rect, so the band is the same width on every card
// size and the corners never smear the way a stretched 9-slice can.

uniform vec2 rect_size = vec2(162.0, 228.0);
uniform vec4 hue : source_color = vec4(0.25, 0.48, 0.33, 1.0);
uniform vec4 hue_lit : source_color = vec4(0.50, 0.72, 0.58, 1.0);
uniform float radius = 12.0;
uniform float band = 8.0;

const vec3 OBSIDIAN = vec3(0.070, 0.066, 0.080);
const vec3 BRASS = vec3(0.86, 0.64, 0.32);
const vec3 BRASS_LIT = vec3(1.00, 0.88, 0.62);
const vec2 KEY_DIR = vec2(-0.61, -0.79);   // top left, y down

float rbox(vec2 p, vec2 h, float r) {
	vec2 q = abs(p) - h + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// A diamond stud: returns (coverage, shade) for a stud of half-size s at c.
vec2 stud(vec2 p, vec2 c, float s) {
	vec2 q = p - c;
	float m = abs(q.x) + abs(q.y);
	float cover = 1.0 - smoothstep(s - 0.7, s + 0.7, m);
	// Lit facet top-left, dark facet bottom-right.
	float shade = 0.5 + 0.5 * clamp(dot(normalize(q + 1e-4), -KEY_DIR) * -1.0, -1.0, 1.0);
	return vec2(cover, shade);
}

void fragment() {
	vec2 h = rect_size * 0.5;
	vec2 p = UV * rect_size - h;
	float d = rbox(p, h - 0.5, radius);
	float e = -d;
	vec2 n = normalize(vec2(
		rbox(p + vec2(0.5, 0.0), h - 0.5, radius) - rbox(p - vec2(0.5, 0.0), h - 0.5, radius),
		rbox(p + vec2(0.0, 0.5), h - 0.5, radius) - rbox(p - vec2(0.0, 0.5), h - 0.5, radius)) + 1e-5);
	float facing = dot(n, KEY_DIR);          // +1 on an edge that faces the light

	vec3 face = mix(OBSIDIAN, hue.rgb * 0.45, 0.35);
	// A little light falling down the card, so the face is not a dead flat.
	face *= mix(1.25, 0.85, UV.y);
	vec3 col = face;
	float a = 1.0;

	if (e < 1.3) {
		// An outer brass hairline, so the card's silhouette separates from a
		// dark floor.
		col = mix(BRASS * 0.55, BRASS_LIT, clamp(facing * 0.5 + 0.5, 0.0, 1.0));
	} else if (e < 3.0) {
		col = mix(face * 0.6, mix(face, hue_lit.rgb, 0.55), clamp(facing, 0.0, 1.0));
		col = mix(col, vec3(0.0), clamp(-facing, 0.0, 1.0) * 0.5);
	} else if (e < band - 2.0) {
		// The engraved groove: a dark cut with a lit lip below it.
		float g = e - band * 0.5;
		col = mix(col, col * 0.45, 1.0 - smoothstep(0.0, 0.8, abs(g + 0.3)));
		col = mix(col, col * 1.6, (1.0 - smoothstep(0.0, 0.7, abs(g - 0.9))) * 0.6);
	} else if (e < band) {
		col = mix(face * 0.5, face * 1.5, clamp(-facing * 0.5 + 0.5, 0.0, 1.0));
	} else if (e < band + 2.0) {
		col = mix(BRASS, BRASS_LIT, clamp(-facing * 0.5 + 0.5, 0.0, 1.0));
	} else if (e < band + 4.5) {
		col = mix(hue_lit.rgb, hue.rgb, clamp(facing * 0.5 + 0.5, 0.0, 1.0));
	} else {
		col = vec3(0.0);
		a = 0.45 * (1.0 - smoothstep(0.0, 5.0, e - band - 4.5));
	}

	// Brass studs: the four corners on the face, and one at the foot.
	float mid = band * 0.5;
	vec2 cc = h - radius;
	float to_band = radius - mid;
	vec2 k = vec2(0.7071);
	vec2 s1 = stud(p, vec2(-cc.x, -cc.y) - k * to_band, 4.4);
	vec2 s2 = stud(p, vec2( cc.x, -cc.y) + vec2(k.x, -k.y) * to_band, 4.4);
	vec2 s3 = stud(p, vec2(-cc.x,  cc.y) + vec2(-k.x, k.y) * to_band, 4.4);
	vec2 s4 = stud(p, vec2( cc.x,  cc.y) + k * to_band, 4.4);
	vec2 s5 = stud(p, vec2(0.0, h.y - mid), 5.0);
	vec2 s = s1;
	if (s2.x > s.x) s = s2;
	if (s3.x > s.x) s = s3;
	if (s4.x > s.x) s = s4;
	if (s5.x > s.x) s = s5;
	col = mix(col, mix(BRASS * 0.55, BRASS_LIT, s.y), s.x);
	a = max(a, s.x);

	// Anti-aliased outer edge.
	a *= 1.0 - smoothstep(-0.75, 0.75, d);
	COLOR = vec4(col, a);
}
