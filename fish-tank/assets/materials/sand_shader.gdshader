shader_type spatial;
render_mode cull_disabled;

uniform sampler2D vertex_noise : filter_nearest;
uniform sampler2D sand_noise : filter_nearest;

uniform float amplitude : hint_range(0.0, 1.0, 0.05);
uniform vec3 sand_color : source_color;

vec3 getTriangleNormal(vec3 a, vec3 b, vec3 c) {
    vec3 u = b - a;
    vec3 v = c - a;
    return normalize(cross(u, v));
}


void vertex() {
	vec3 v0 = VERTEX + vec3(-(1.0/16.0), texture(vertex_noise, UV - vec2(1.0/16.0)).r * amplitude, -(1.0/16.0));
	vec3 v1 = VERTEX + vec3(0, texture(vertex_noise, UV - vec2(0, 1.0/16.0)).r * amplitude, -(1.0/16.0));
	VERTEX = VERTEX + vec3(0, texture(vertex_noise, UV).r * amplitude, 0);
	NORMAL = getTriangleNormal(VERTEX, v1, v0);
}


void fragment() {
	ALBEDO = normalize((0.3) + texture(sand_noise, UV).rgb) * sand_color;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
