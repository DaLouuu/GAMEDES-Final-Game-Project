shader_type canvas_item;

uniform float saturation: hint_range(0.0, 2.0) = 1.0; // 1.0 = original color

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    // Compute luminance
    float lum = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 gray = vec3(lum);

    // Mix original color with grayscale based on saturation
    // saturation = 1.0 -> original color
    // saturation = 0.0 -> fully grayscale
    col.rgb = mix(gray, col.rgb, saturation);

    COLOR = col;
}
