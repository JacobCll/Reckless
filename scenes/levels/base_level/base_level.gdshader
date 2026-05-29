shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);

    color.rgb *= (1.0 - darkness);

    COLOR = color;
}	