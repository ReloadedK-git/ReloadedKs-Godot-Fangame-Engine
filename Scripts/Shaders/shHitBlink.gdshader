shader_type canvas_item;

uniform float hit_opacity = 0;
uniform vec3 hit_color : source_color = vec3(1., 0., 0.);

void fragment(){
	//interpolates between the original sprite's color and the color white depending on the value of hit_opacity
	COLOR.rgb = texture(TEXTURE, UV).rgb * (1.0 - hit_opacity) + vec3(hit_color) * hit_opacity;
	
	//copies the original sprite's alpha values
	COLOR.a = texture(TEXTURE, UV).a ;
}