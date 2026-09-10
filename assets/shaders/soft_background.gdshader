// Calm animated background: warm vertical gradient with slowly drifting soft light blobs.
// Uses only TIME/UV math, safe for the Mobile renderer.
shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.972, 0.953, 0.914, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.925, 0.898, 0.850, 1.0);
uniform vec4 blob_color : source_color = vec4(1.0, 1.0, 1.0, 0.45);
uniform float speed : hint_range(0.0, 1.0) = 0.07;
uniform float blob_size : hint_range(0.1, 1.5) = 0.55;

void fragment() {
	vec2 uv = UV;
	vec4 base = mix(color_top, color_bottom, uv.y);
	float t = TIME * speed;
	float glow = 0.0;
	for (int i = 0; i < 4; i++) {
		float fi = float(i);
		vec2 center = vec2(
			0.5 + 0.40 * sin(t * (0.7 + 0.13 * fi) + fi * 1.9),
			0.5 + 0.36 * cos(t * (0.5 + 0.11 * fi) + fi * 2.7));
		vec2 stretched = (uv - center) * vec2(1.6, 1.0);
		float d = length(stretched);
		glow += smoothstep(blob_size, 0.0, d) * 0.45;
	}
	vec4 result = mix(base, blob_color, clamp(glow, 0.0, 1.0) * blob_color.a);
	COLOR = vec4(result.rgb, 1.0);
}
