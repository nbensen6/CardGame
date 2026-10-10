// A TextureRect's own edges, antialiased: alpha fades over the last screen
// pixel inside the rect. Godot's compatibility renderer draws a rotated
// quad's edge as a hard staircase; TARGET's tilted cards show a clean line
// where the art window meets the card body (builder 2026-10-10 run 6).
shader_type canvas_item;

uniform vec2 rect_size = vec2(100.0, 100.0);
varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec2 d = max(fwidth(local_pos), vec2(1e-4));
	vec2 inside = min(local_pos, rect_size - local_pos) / d;
	COLOR.a *= clamp(min(inside.x, inside.y) + 0.5, 0.0, 1.0);
}
