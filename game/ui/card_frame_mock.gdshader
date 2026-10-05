shader_type canvas_item;
render_mode blend_mix;

// The three card-frame directions (Nick, 2026-10-05: "the card template for
// the outer layer of the cards looks low quality ... prepare a redesign").
// design/art/card-frame-research.md is the spec. One shader, three looks:
// CardView.FRAME_MOCKS holds the numbers, this holds the drawing.
//
// It is a PLATE with a hole cut in it for the art, not a ring round the edge:
// every real frame works that way, and it is what makes the art read as
// sitting behind the frame instead of being pasted onto a card.
//
//   outer stroke (hard, dark)      what separates the card from the scene
//   outer bevel, lit top-left      the plate has thickness
//   plate face                     the frame's own material
//   wall round the art window      lit the other way: a cut facing in
//   keyline                        the art never touches the plate
//   inner shadow on the art        the art sits behind
//
// Everything is in pixels of the card's own rect, so 135, 162 and 191 wide
// all get the same stroke widths.

uniform vec2 rect_size = vec2(162.0, 228.0);
uniform float radius = 10.0;
// x0, y0, x1, y1 in px: the art window.
uniform vec4 art_rect = vec4(9.0, 33.0, 153.0, 126.0);
uniform float art_radius = 3.0;
// 0 = straight-topped window, >0 = that radius on the TOP corners only (C).
uniform float art_arch = 0.0;
uniform vec4 outer_col : source_color = vec4(0.02, 0.02, 0.03, 1.0);
uniform float outer_w = 1.5;
uniform vec4 plate_top : source_color = vec4(0.16, 0.15, 0.17, 1.0);
uniform vec4 plate_bottom : source_color = vec4(0.08, 0.07, 0.09, 1.0);
uniform vec4 lit : source_color = vec4(0.42, 0.40, 0.44, 1.0);
uniform vec4 keyline : source_color = vec4(0.95, 0.47, 0.16, 1.0);
uniform float keyline_w = 1.5;
// Ornament strength: corner studs and a groove round the plate (C only).
uniform float ornament = 0.0;
// Speckle on the plate face, so stone reads as stone (A only).
uniform float grain = 0.0;

const vec2 KEY_DIR = vec2(-0.61, -0.79);   // top left, y down

float rbox(vec2 p, vec2 h, float r) {
	vec2 q = abs(p) - h + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// The art window. With an arch, the top corners round off at art_arch and the
// bottom ones stay at art_radius.
float window(vec2 px) {
	vec2 c = (art_rect.xy + art_rect.zw) * 0.5;
	vec2 h = (art_rect.zw - art_rect.xy) * 0.5;
	float r = (art_arch > 0.0 && px.y < c.y) ? art_arch : art_radius;
	return rbox(px - c, h, r);
}

float hash(vec2 p) {
	return fract(sin(dot(floor(p), vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 px = UV * rect_size;
	vec2 h = rect_size * 0.5;
	vec2 p = px - h;
	float d = rbox(p, h - 0.5, radius);
	float e = -d;
	vec2 n = normalize(vec2(
		rbox(p + vec2(0.5, 0.0), h - 0.5, radius) - rbox(p - vec2(0.5, 0.0), h - 0.5, radius),
		rbox(p + vec2(0.0, 0.5), h - 0.5, radius) - rbox(p - vec2(0.0, 0.5), h - 0.5, radius)) + 1e-5);
	float facing = dot(n, KEY_DIR);

	float w = window(px);
	vec2 wn = normalize(vec2(window(px + vec2(0.5, 0.0)) - window(px - vec2(0.5, 0.0)),
		window(px + vec2(0.0, 0.5)) - window(px - vec2(0.0, 0.5))) + 1e-5);
	float w_facing = dot(wn, KEY_DIR);

	vec3 face = mix(plate_top.rgb, plate_bottom.rgb, UV.y);
	if (grain > 0.0) {
		face *= 1.0 + (hash(px * 0.7) - 0.5) * grain;
	}
	vec3 col = face;
	float a = 1.0;

	if (w < -keyline_w) {
		// Inside the window: transparent, with a soft shadow cast by the plate.
		col = vec3(0.0);
		a = 0.55 * (1.0 - smoothstep(0.0, 5.0, -w - keyline_w));
	} else if (w < 0.0) {
		col = keyline.rgb;
	} else if (w < 2.0) {
		// The wall of the cut, lit the opposite way to the outer bevel.
		col = mix(face * 0.45, lit.rgb, clamp(-w_facing, 0.0, 1.0));
	} else if (e < outer_w) {
		col = outer_col.rgb;
	} else if (e < outer_w + 1.6) {
		col = mix(face * 0.55, lit.rgb, clamp(facing, 0.0, 1.0));
		col = mix(col, face * 0.35, clamp(-facing, 0.0, 1.0));
	}

	if (ornament > 0.0 && w >= 2.0 && e >= outer_w + 1.6) {
		// An engraved groove half way across the plate, dark cut with a lit lip.
		float g = e - (outer_w + 5.0);
		col = mix(col, col * 0.4, (1.0 - smoothstep(0.0, 0.8, abs(g))) * ornament);
		col = mix(col, lit.rgb, (1.0 - smoothstep(0.0, 0.7, abs(g - 1.0))) * 0.5 * ornament);
		// A round boss at each corner, domed: lit top-left, dark bottom-right.
		vec2 cc = h - vec2(radius + 1.0);
		vec2 q = abs(p) - cc;
		vec2 sgn = sign(p);
		float rr = length(q);
		float boss = 1.0 - smoothstep(4.0, 5.2, rr);
		float dome = dot(normalize(q * sgn + 1e-4), KEY_DIR);
		vec3 bc = mix(face * 0.5, lit.rgb * 1.15, 0.5 + 0.5 * dome);
		bc = mix(bc, keyline.rgb, 1.0 - smoothstep(1.2, 2.2, rr));
		col = mix(col, bc, boss * ornament);
	}

	// Anti-aliased outer edge.
	a *= 1.0 - smoothstep(-0.75, 0.75, d);
	COLOR = vec4(col, a);
}
