shader_type canvas_item;
uniform float saturation: hint_range(0.0, 2.0) = 1.3;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float lum = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	col.rgb = mix(vec3(lum), col.rgb, saturation);
	COLOR = col * COLOR;
}