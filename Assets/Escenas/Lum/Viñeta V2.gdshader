shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_offset = 10.0;

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    vec2 offset_uv = uv + vec2(shadow_offset, shadow_offset) / SCREEN_PIXEL_SIZE;
    vec4 shadow = texture(TEXTURE, offset_uv) * shadow_color;
    COLOR = mix(COLOR, shadow, shadow.a);
}
