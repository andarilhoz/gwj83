// Based on jess::codes https://www.youtube.com/watch?v=eYlBociPwdw and https://www.youtube.com/watch?v=QB2o5Dys6Tc

shader_type canvas_item;

uniform sampler2D overlay: repeat_enable, filter_nearest;
uniform vec4 fg_color : source_color;
uniform vec4 bg_color : source_color;
uniform float tolerance : hint_range(0, 1);
uniform sampler2D overlay2: repeat_enable, filter_nearest;
uniform vec4 fg_color2 : source_color;
uniform vec4 bg_color2 : source_color;
uniform float tolerance2 : hint_range(0, 1);

uniform float tile_size = 64.0;
uniform float tile_size2 = 64.0;
varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 curr_color = texture(TEXTURE, UV);

    float dist_bg = distance(curr_color.rgb, bg_color.rgb);
    if (dist_bg <= tolerance) {
        discard;
    }

    vec2 scaled_position = world_position / tile_size;
    vec4 overlay_color = texture(overlay, scaled_position);

    float dist_fg = distance(curr_color.rgb, fg_color.rgb);
    if (dist_fg <= tolerance) {
        COLOR = overlay_color;
    }
	    vec4 curr_color2 = texture(TEXTURE, UV);

    float dist_bg2 = distance(curr_color.rgb, bg_color2.rgb);
    if (dist_bg2 <= tolerance2) {
        discard;
    }

    vec2 scaled_position2 = world_position / tile_size2;
    vec4 overlay_color2 = texture(overlay2, scaled_position2);

    float dist_fg2= distance(curr_color2.rgb, fg_color2.rgb);
    if (dist_fg2 <= tolerance2) {
        COLOR = overlay_color2;
	}
	}
