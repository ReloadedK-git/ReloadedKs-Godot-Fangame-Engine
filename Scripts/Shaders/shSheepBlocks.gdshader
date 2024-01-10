shader_type canvas_item;

uniform vec4 new_color: source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform bool blinking = false;

void fragment() {
	vec4 cur_color = texture(TEXTURE, UV);
	if (cur_color.rga == vec3(0, 0, 1) && cur_color.b > 0.0){
		if (blinking == false){
			COLOR.rgb = new_color.rgb * cur_color.b;
		} else {
			COLOR.rgb = vec3(0.8) * cur_color.b;
		}
	}
}