shader_type canvas_item;

render_mode unshaded, skip_vertex_transform;

const float curvature = 4.0;
const float vignette_mul = 1.5; // Affects the black corners sizes least to great, direct proportional
const float blur_val = 0.1;
const float ratio_to_window_size_y = 180.0;
uniform sampler2D screen_texture: hint_screen_texture;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) *step(abs(warped_uv.y), 1.0));

	vec3 scanlines = vec3(sin(2.0 * warped_uv.y * ratio_to_window_size_y) * 0.02 + 0.75);

	vec3 vignette = vec3(length(pow(abs(centered_uv),vec2(4.0))/3.0));


	vec3 screen_color = textureLod(screen_texture, (warped_uv+1.0)/2.0, blur_val).rgb * cutoff * scanlines;

	screen_color -= vignette * vignette_mul;
	//COLOR = vec4(warped_uv, 0.0, 1.0);
	    // global darkening

	COLOR = vec4(screen_color, 1.0);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
