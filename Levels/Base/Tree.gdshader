shader_type canvas_item;

uniform float speed = 1.5;
uniform float sway_amount = 25.0;

uniform float pinned_from_y = 0.55;

uniform float top_power = 1.5;

void vertex() {
	float wave = sin(TIME * speed);

	float top_weight = clamp((pinned_from_y - UV.y) / pinned_from_y, 0.0, 1.0);
	top_weight = pow(top_weight, top_power);

	VERTEX.x += wave * sway_amount * top_weight;
}