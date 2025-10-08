shader_type spatial;
render_mode cull_disabled, unshaded;

uniform sampler2D tex;

instance uniform vec3 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = color;
	if (UV.y > 0.495) {
		ALPHA = 1.0;
	} else {
		ALPHA = clamp(texture(tex, vec2(UV.x, UV.y + TIME * 0.2)).r * (UV.y - 0.40) * 2.0, 0.0, 1.0);
	}
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
