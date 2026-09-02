shader_type canvas_item;

// Recolors the ProgressBar's fill StyleBoxFlat into a red-to-green gradient.
// The background StyleBoxFlat is left untouched (its color won't match fill_color).
uniform vec4 fill_color : source_color = vec4(0.93, 0.65, 0.13, 1.0);
uniform vec4 gradient_start_color : source_color = vec4(0.85, 0.16, 0.16, 1.0);
uniform vec4 gradient_end_color : source_color = vec4(0.22, 0.78, 0.32, 1.0);
uniform float progress_ratio : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base_color = COLOR;

	if (distance(base_color.rgb, fill_color.rgb) < 0.05) {
		// UV spans 0..1 across the fill rect itself, so scaling by progress_ratio
		// maps each pixel back to its true position along the full bar width.
		float x_ratio = clamp(UV.x * progress_ratio, 0.0, 1.0);
		COLOR = vec4(mix(gradient_start_color.rgb, gradient_end_color.rgb, x_ratio), base_color.a);
	} else {
		COLOR = base_color;
	}
}
