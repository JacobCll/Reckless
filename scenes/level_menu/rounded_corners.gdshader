shader_type canvas_item;

// Fraction of the button's size used as the corner radius.
uniform float radius : hint_range(0.0, 0.5) = 0.12;
// Outline thickness in screen pixels (0 disables it).
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(0.788, 0.737, 0.6, 1.0); // #c9bc99

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Work in screen pixels so the outline and anti-aliasing stay crisp at any size.
	vec2 size = 1.0 / max(fwidth(UV), vec2(0.000001));
	vec2 p = (UV - 0.5) * size;
	float r = radius * min(size.x, size.y);
	vec2 d = abs(p) - (size * 0.5 - r);
	// Signed distance to the rounded rect edge (negative inside).
	float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;

	float shape = 1.0 - smoothstep(-0.5, 0.5, dist);
	float border = step(0.001, outline_width)
		* smoothstep(-outline_width - 0.5, -outline_width + 0.5, dist) * outline_color.a;

	COLOR.rgb = mix(tex_color.rgb, outline_color.rgb, border);
	COLOR.a = mix(tex_color.a, 1.0, border) * shape;
}
