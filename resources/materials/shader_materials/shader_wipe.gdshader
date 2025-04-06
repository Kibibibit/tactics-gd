shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0);
uniform float progress = 0.0;
uniform float width = 0.0;
uniform int pixel_size = 8;
uniform mat4 matrix = mat4(
	vec4(0.0,    0.5,    0.125,  0.625 ),
	vec4(0.75,   0.25,   0.875,  0.375 ),
	vec4(0.1875, 0.6875, 0.0625, 0.5625),
	vec4(0.9375, 0.4375, 0.8125, 0.3125)
);

void fragment() {
	
	float ps_x = SCREEN_PIXEL_SIZE.x * float(pixel_size);
	float ps_y = SCREEN_PIXEL_SIZE.y * float(pixel_size);
	vec2 stepped_uv = vec2(0.0);
	stepped_uv.x = floor(UV.x/ps_x) * ps_x;
	stepped_uv.y = floor(UV.y/ps_y) * ps_y;
	
	
	float alpha = stepped_uv.x;
	if (abs(stepped_uv.x-progress) >= width) {
		alpha = 0.0;
	} else {
		 alpha = smoothstep(0.0, 1.0, 1.0 - abs(stepped_uv.x-progress)/width);
		
		int p_x = int(floor(stepped_uv.x/SCREEN_PIXEL_SIZE.x/float(pixel_size)));
		int p_y = int(floor(stepped_uv.y/SCREEN_PIXEL_SIZE.y/float(pixel_size)));
		
		float threshold = matrix[p_y % 4][p_x % 4];
		if (alpha >= threshold) {
			alpha = 1.0;
		} else {
			alpha = 0.0;
		}
		
	}
	
	COLOR.a = alpha * color.a;
	COLOR.rgb = color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
