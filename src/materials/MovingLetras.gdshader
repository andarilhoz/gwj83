shader_type canvas_item;

uniform float amplitude = 1.0;
uniform float frequency = 10.0;
uniform float speed = 5.0;


void fragment() {
    float wave = sin(UV.x * frequency + TIME * speed);
    vec2 offset = vec2(0.0, -wave * amplitude * TEXTURE_PIXEL_SIZE.y);
    vec2 shifted_uv = clamp(UV + offset, vec2(0.0), vec2(1.0));
    COLOR = texture(TEXTURE, shifted_uv) * COLOR;
}
