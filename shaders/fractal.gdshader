shader_type spatial;
uniform bool tex_fractal = false;
uniform sampler2D tex_albedo : source_color;
uniform vec2 tex_scale = vec2(10.0f);

vec2 hash2D(vec2 s) {
    return fract(sin(mod(vec2(dot(s, vec2(127.1, 311.7)), dot(s, vec2(269.5, 183.3))), 3.14159))*43758.5453);
}

vec4 texFractal(sampler2D tex, vec2 uv) {
    vec3 BW_vx[4];
    vec2 skewUV = mat2(vec2(1.0, 0.0), vec2(-0.57735027, 1.15470054))*(uv*3.464);
    vec2 vxID = floor(skewUV);
    vec3 barry = vec3(fract(skewUV), 0.0);
    barry.z = 1.0 - barry.x - barry.y;
    if (barry.z > 0.0) {
        BW_vx[0] = vec3(vxID, 0.0);
        BW_vx[1] = vec3(vxID + vec2(0.0, 1.0), 0.0);
        BW_vx[2] = vec3(vxID + vec2(1.0, 0.0), 0.0);
        BW_vx[3] = vec3(barry.z, barry.y, barry.x); // z,y,x order
    }
	else {
        BW_vx[0] = vec3(vxID + vec2(1.0, 1.0), 0.0);
        BW_vx[1] = vec3(vxID + vec2(1.0, 0.0), 0.0);
        BW_vx[2] = vec3(vxID + vec2(0.0, 1.0), 0.0);
        BW_vx[3] = vec3(-barry.z, 1.0 - barry.y, 1.0 - barry.x);
    }
    vec2 dx = dFdx(uv);
    vec2 dy = dFdy(uv);
    float w0 = BW_vx[3].x;
    float w1 = BW_vx[3].y;
    float w2 = BW_vx[3].z;
    vec4 result = (
		textureGrad(tex, uv + hash2D(BW_vx[0].xy), dx, dy)*w0 +
		textureGrad(tex, uv + hash2D(BW_vx[1].xy), dx, dy)*w1 +
		textureGrad(tex, uv + hash2D(BW_vx[2].xy), dx, dy)*w2
	);
    return result;
}

void fragment() {
	vec4 texel = tex_fractal ? texFractal(tex_albedo, UV*tex_scale) : texture(tex_albedo, UV*tex_scale);
    ALBEDO = texel.rgb;
    ALPHA = texel.a;
	METALLIC = 0.0;
	CLEARCOAT = 0.0;
    SPECULAR = 0.0;
	FOG = vec4(0.0);
	RIM = 0.0;
}