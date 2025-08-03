shader_type sky;

uniform vec3 color_env : source_color;
uniform sampler2D noise_texture : repeat_enable;
uniform float noise_power;
uniform float speed;

void sky() {
	COLOR = color_env * ((1.0+EYEDIR.y)/2.0) + noise_power*texture(noise_texture, SKY_COORDS + vec2(TIME*speed, 0)).xyz;
}