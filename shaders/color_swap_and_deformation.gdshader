shader_type canvas_item;

uniform vec4 original_0: source_color;
uniform vec4 original_1: source_color;
uniform vec4 original_2: source_color;
uniform vec4 original_3: source_color;
uniform vec4 original_4: source_color;
uniform vec4 replace_0: source_color;
uniform vec4 replace_1: source_color;
uniform vec4 replace_2: source_color;
uniform vec4 replace_3: source_color;
uniform vec4 replace_4: source_color;

uniform vec2 deformation = vec2(0, 0);
uniform float sideWaysDeformationFactor = 5.0;
uniform float knockbackFactor = 0.4;
uniform bool white = false;
uniform float alpha = 1.0;
uniform float darken = 0.0;

const float precision = 0.5;


vec4 swap_color(vec4 color){
	float my_alpha = color.a;
	color.a = 1.0;
	vec4 original_colors[5] = vec4[5] (original_0, original_1, original_2, original_3, original_4);
	vec4 replace_colors[5] = vec4[5] (replace_0, replace_1, replace_2, replace_3, replace_4);
	for (int i = 0; i < 5; i ++) {
		if (distance(color, original_colors[i]) <= precision){
			color = replace_colors[i];
			break;
		}
	}
	color.a = my_alpha;
	return color;
}

void vertex() {
	vec2 deformationStrength = abs(deformation);
	float sideWaysDeformation = min(deformationStrength.x, deformationStrength.y);
	float spriteWidth = abs(VERTEX.x);
	if (sign(VERTEX.y) != sign(deformation.y)) {
		VERTEX.x += sideWaysDeformation * sideWaysDeformationFactor * spriteWidth * sign(deformation.x);
	}
	vec2 scale = 1.0 - deformationStrength;

	VERTEX.x *= scale.x / scale.y;
	VERTEX.y *= scale.y / scale.x;
	VERTEX.xy += deformation * spriteWidth * knockbackFactor;

	if(white) {
		COLOR.r = 255.0;
		COLOR.g = 255.0;
		COLOR.b = 255.0;
	}

	COLOR.a = COLOR.a * alpha;

	COLOR.r = COLOR.r * (1.0 - darken);
	COLOR.g = COLOR.g * (1.0 - darken);
	COLOR.b = COLOR.b * (1.0 - darken);
}

void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}