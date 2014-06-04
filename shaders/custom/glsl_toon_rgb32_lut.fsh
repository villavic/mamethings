// Cartoon shader I (class B)
// by guest(r)
// license: GNU-GPL
// conversion to SDLMAME by R. Belmont

#pragma optimize (on)
#pragma debug (off)

uniform sampler2D     color_texture;
uniform sampler2D     colortable_texture;
uniform vec2          colortable_sz;      // orig size
uniform vec2          colortable_pow2_sz; // pow2 ct size
uniform vec2          color_texture_pow2_sz; // pow2 tex size

vec4 lutTex2D(in vec2 texcoord)
{
	vec4 color_tex;
	vec2 color_map_coord;
	vec4 color0;
	float colortable_scale = (colortable_sz.x/3.0) / colortable_pow2_sz.x;

	// normalized texture coordinates ..
	color_tex         = texture2D(color_texture, texcoord) * ((colortable_sz.x/3.0)-1.0)/colortable_pow2_sz.x;// lookup space 

	color_map_coord.x = color_tex.b;
	color0.b          = texture2D(colortable_texture, color_map_coord).b;

	color_map_coord.x = color_tex.g + colortable_scale;
	color0.g          = texture2D(colortable_texture, color_map_coord).g;

	color_map_coord.x = color_tex.r + 2.0 * colortable_scale;
	color0.r          = texture2D(colortable_texture, color_map_coord).r;

	return color0;
}

void main()
{
vec3 c00 = lutTex2D(gl_TexCoord[5].xy).xyz; 
vec3 c10 = lutTex2D(gl_TexCoord[1].xy).xyz; 
vec3 c20 = lutTex2D(gl_TexCoord[2].zw).xyz; 
vec3 c01 = lutTex2D(gl_TexCoord[3].xy).xyz; 
vec3 c11 = lutTex2D(gl_TexCoord[0].xy).xyz; 
vec3 c21 = lutTex2D(gl_TexCoord[4].xy).xyz; 
vec3 c02 = lutTex2D(gl_TexCoord[1].zw).xyz; 
vec3 c12 = lutTex2D(gl_TexCoord[2].xy).xyz; 
vec3 c22 = lutTex2D(gl_TexCoord[6].xy).xyz; 

vec3 dt = vec3(1.0,1.0,1.0); 

float d1=dot(abs(c00-c22),dt);
float d2=dot(abs(c20-c02),dt);
float hl=dot(abs(c01-c21),dt);
float vl=dot(abs(c10-c12),dt);

float d = 0.5*(d1+d2+hl+vl)/(dot(c11,dt)+0.15);

gl_FragColor.xyz = (1.1-pow(d,1.5))*c11;
}
