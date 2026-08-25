shader_type canvas_item;

uniform vec4 dim_color : source_color = vec4(0.0, 0.0, 0.0, 0.75);
uniform vec2 highlight_center = vec2(0.5, 0.5);
uniform vec2 highlight_size = vec2(0.0, 0.0);
uniform float feather = 0.015;
uniform float highlight_enabled = 0.0;

void fragment() {
	vec2 d = abs(UV - highlight_center) - highlight_size * 0.5;
	float dist = max(d.x, d.y);
	float inside = 1.0 - smoothstep(0.0, feather, dist);

	float alpha = dim_color.a;
	if (highlight_enabled > 0.5) {
		alpha *= (1.0 - inside);
	}

	COLOR = vec4(dim_color.rgb, alpha);
}
