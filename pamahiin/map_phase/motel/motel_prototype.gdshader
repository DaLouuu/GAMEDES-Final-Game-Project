shader_type canvas_item;

uniform vec2 light_position : hint_range(0, 1024);
uniform float light_radius : hint_range(0, 500) = 150.0;
uniform float darkness_strength : hint_range(0, 1) = 0.8;

void fragment() {
    float dist = distance(UV * SCREEN_PIXEL_SIZE.xy, light_position);
    float intensity = smoothstep(light_radius, 0.0, dist);
    COLOR = vec4(vec3(1.0 - intensity * darkness_strength), 1.0);
}
