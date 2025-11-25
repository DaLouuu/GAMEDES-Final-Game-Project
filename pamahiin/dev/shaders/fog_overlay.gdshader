shader_type canvas_item;

// Noise texture used to generate the fog pattern
uniform sampler2D noise_texture: repeat_enable, filter_nearest;
// Controls how thick the fog appears
uniform float density: hint_range(0.0, 1.0) = 0.25;
// Controls the direction and speed of the fog movement
uniform vec2 speed = vec2(0.02, 0.01);

void fragment() {
	// Make the fog move by offsetting the UVs over time
	vec2 uv = UV + speed * TIME;
	
	// Sample the noise texture at the moving coordinates
	float noise = texture(noise_texture, uv).r;
	
	// Convert noise from (0.0 to 1.0) range to (-1.0 to 1.0) and clamp it.
	// This increases contrast and creates empty spaces (transparency) in the fog.
	float fog = clamp(noise * 2.5 - 1.0, 0.0, 1.0);
	
	// Apply the fog effect to the alpha channel of the ColorRect
	COLOR.a *= fog * density;
}