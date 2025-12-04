shader_type canvas_item;

// 0.0 = Normal Player, 1.0 = Pure Black Silhouette
uniform float darkness_amount : hint_range(0.0, 1.0) = 1.0;

// The color to fade to (Default is Black, but you can make it dark purple/red)
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Optional: Adds a "static" noise overlay to the shadow so it looks alive
uniform bool use_static = true;
uniform float static_strength : hint_range(0.0, 1.0) = 0.2;

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	// 1. Calculate the shadow version (Pure color)
	vec3 shadow_rgb = shadow_color.rgb;
	
	// 2. Add Horror Static (Optional)
	// This makes the blackness "crawl" slightly
	if (use_static && darkness_amount > 0.0) {
		float noise = random(UV + vec2(TIME * 20.0, TIME * 5.0));
		shadow_rgb += (noise - 0.5) * static_strength;
	}
	
	// 3. Mix: Normal Color -> Black Shadow
	// We preserve the original Alpha (transparency) so the shape stays perfect
	original_color.rgb = mix(original_color.rgb, shadow_rgb, darkness_amount);
	
	COLOR = original_color;
}