// Cartoon shader I (class B)
// by guest(r)
// license: GNU-GPL
// conversion to SDLMAME by R. Belmont

#pragma optimize (on)
#pragma debug (off)

uniform sampler2D     color_texture;
uniform vec2          color_texture_pow2_sz; // pow2 tex size
uniform vec4          vid_attributes;        // gamma, contrast, brightness

void main()
{
vec3 c00 = texture2D(color_texture, gl_TexCoord[5].xy).xyz; 
vec3 c10 = texture2D(color_texture, gl_TexCoord[1].xy).xyz; 
vec3 c20 = texture2D(color_texture, gl_TexCoord[2].zw).xyz; 
vec3 c01 = texture2D(color_texture, gl_TexCoord[3].xy).xyz; 
vec3 c11 = texture2D(color_texture, gl_TexCoord[0].xy).xyz; 
vec3 c21 = texture2D(color_texture, gl_TexCoord[4].xy).xyz; 
vec3 c02 = texture2D(color_texture, gl_TexCoord[1].zw).xyz; 
vec3 c12 = texture2D(color_texture, gl_TexCoord[2].xy).xyz; 
vec3 c22 = texture2D(color_texture, gl_TexCoord[6].xy).xyz; 

vec3 dt = vec3(1.0,1.0,1.0); 

float d1=dot(abs(c00-c22),dt);
float d2=dot(abs(c20-c02),dt);
float hl=dot(abs(c01-c21),dt);
float vl=dot(abs(c10-c12),dt);

float d = 0.5*(d1+d2+hl+vl)/(dot(c11,dt)+0.15);

gl_FragColor.xyz = (1.1-pow(d,1.5))*c11;
}
