shader_type canvas_item;

// Fraction of the button's half-size used as the corner radius.
uniform float radius : hint_range(0.0, 0.5) = 0.12;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	vec2 d = abs(UV - 0.5) - (0.5 - radius);
	float dist = length(max(d, 0.0)) - radius;
	float alpha = 1.0 - smoothstep(0.0, max(fwidth(dist), 0.0001), dist);

	COLOR = tex_color;
	COLOR.a *= alpha;
}
