shader_type canvas_item;

uniform float speed = 2.0;

uniform float horizontal_amount = 1.0;
uniform float vertical_amount = 1.0;

uniform float pinned_from_y = 0.65;
uniform float head_power = 1.0;

uniform float stretch_strength = 0.5;
uniform float squish_strength = 1.8;

void vertex() {
	float wave = sin(TIME * speed);

	if (wave > 0.0) {
		wave *= stretch_strength;
	} else {
		wave *= squish_strength;
	}

	float upper_weight = clamp((pinned_from_y - UV.y) / pinned_from_y, 0.0, 1.0);
	upper_weight = pow(upper_weight, head_power);

	VERTEX.x += (UV.x - 0.5) * wave * horizontal_amount * upper_weight;
	VERTEX.y -= wave * vertical_amount * upper_weight;
}