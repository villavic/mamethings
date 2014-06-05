// Cartoon shader I (class B)
// by guest(r)
// license: GNU-GPL
// conversion to SDLMAME by R. Belmont

#pragma optimize (on)
#pragma debug (off)

uniform sampler2D color_texture;
uniform sampler2D colortable_texture;
uniform vec2      colortable_sz; // ct size
uniform vec2      colortable_pow2_sz; // pow2 ct size
uniform vec2      color_texture_pow2_sz; // pow2 tex size

vec4 lutTex2D(in vec2 texcoord)
{
  vec2 lutindex;
  vec2 one = 1.0 / color_texture_pow2_sz;

  // normalized texture coordinates ..
  float incolor = texture2D(color_texture, texcoord).a;

  // GL_UNSIGNED_SHORT GL_ALPHA in ALPHA16 conversion:
  // general: f = c / ((2*N)-1), c color bitfield, N number of bits
  // ushort:  c = ((2**16)-1)*f;
  float index = floor(incolor * 65535) + 1e-6;
  /* Compute high byte (8 MSBs) of 2D texture lookup position: */
  lutindex.y = (floor(index / colortable_pow2_sz.x) + 0.5);
  /* Compute low byte (8 LSBs) of 2D texture lookup position: */
  lutindex.x = (floor(mod(index, colortable_pow2_sz.x)) + 0.5);
  /* Readout LUT texture at 2D location lutindex(x,y) to get final RGBA8 */
  /* output pixel and write it to framebuffer: */
  lutindex = lutindex * (1.0 + 1e-4);
  return texture2D(colortable_texture, lutindex / colortable_pow2_sz);
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
