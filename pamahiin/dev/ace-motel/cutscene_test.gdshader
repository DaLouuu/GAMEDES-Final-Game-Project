shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float radius : hint_range(0.0, 1.5) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    vec2 viewport_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv = FRAGCOORD.xy / viewport_size;
    float dist = distance(uv, center);

    float mask = 1.0 - smoothstep(radius, radius - 0.05, dist);

    COLOR = vec4(vec3(0.0), mask);
}
