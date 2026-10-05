shader_type canvas_item;
render_mode blend_mix;

// One bevelled plate on a card frame mock: the title plate, the type bar, the
// text box, the cost socket. A raised plate is lit on its top-left edge; an
// inset one (inset = 1) on its bottom-right, because its wall faces the other
// way. That one flip is the difference between "a box drawn on the card" and
// "a panel set into it" (design/art/card-frame-research.md, point 2).

uniform vec2 rect_size = vec2(100.0, 20.0);
uniform float radius = 3.0;
uniform vec4 fill_top : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform vec4 fill_bottom : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 lit : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 dark : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 outline : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_w = 1.0;
uniform float bevel = 1.5;
uniform float inset = 0.0;
// A hairline rule this many px below the top, 0 for none (A's text box).
uniform float rule_y = 0.0;
uniform vec4 rule_col : source_color = vec4(1.0, 0.5, 0.2, 0.6);

const vec2 KEY_DIR = vec2(-0.61, -0.79);

float rbox(vec2 p, vec2 h, float r) {
	vec2 q = abs(p) - h + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 px = UV * rect_size;
	vec2 h = rect_size * 0.5;
	vec2 p = px - h;
	float r = min(radius, min(h.x, h.y));
	float d = rbox(p, h - 0.5, r);
	float e = -d;
	vec2 n = normalize(vec2(
		rbox(p + vec2(0.5, 0.0), h - 0.5, r) - rbox(p - vec2(0.5, 0.0), h - 0.5, r),
		rbox(p + vec2(0.0, 0.5), h - 0.5, r) - rbox(p - vec2(0.0, 0.5), h - 0.5, r)) + 1e-5);
	float facing = dot(n, KEY_DIR) * (inset > 0.5 ? -1.0 : 1.0);

	vec3 col = mix(fill_top.rgb, fill_bottom.rgb, UV.y);
	if (e < outline_w) {
		col = outline.rgb;
	} else if (e < outline_w + bevel) {
		col = mix(col, lit.rgb, clamp(facing, 0.0, 1.0));
		col = mix(col, dark.rgb, clamp(-facing, 0.0, 1.0));
	}
	if (rule_y > 0.0) {
		float k = 1.0 - smoothstep(0.0, 0.6, abs(px.y - rule_y));
		float span = smoothstep(0.08, 0.2, UV.x) * (1.0 - smoothstep(0.8, 0.92, UV.x));
		col = mix(col, rule_col.rgb, k * span * rule_col.a);
	}
	COLOR = vec4(col, 1.0 - smoothstep(-0.75, 0.75, d));
}
