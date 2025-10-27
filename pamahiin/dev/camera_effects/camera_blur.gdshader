shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.

}

void fragment() {
    vec4 sum = vec4(0.0);
    vec2 size = blur_amount * vec2(0.002);

    sum += texture(TEXTURE, UV - size);
    sum += texture(TEXTURE, UV + size);
    sum += texture(TEXTURE, UV - vec2(size.x, -size.y));
    sum += texture(TEXTURE, UV + vec2(size.x, -size.y));
    sum += texture(TEXTURE, UV);

    COLOR = sum / 5.0;
	
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
