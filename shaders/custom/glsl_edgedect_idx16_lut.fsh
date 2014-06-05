
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D color_texture;
uniform vec2      color_texture_pow2_sz; // pow2 tex size

uniform sampler2D colortable_texture;
uniform vec2      colortable_sz;      // ct size
uniform vec2      colortable_pow2_sz; // pow2 ct size

#define  KVAL(v) vec4( v, v, v, 0.0 )

#if 0
#define KERNEL_SIZE 9


vec4 KernelValue[KERNEL_SIZE] = {
		KVAL( 0.0), KVAL(  1.0), KVAL( 0.0),
		KVAL( 1.0), KVAL( -4.0), KVAL( 1.0),
		KVAL( 0.0), KVAL(  1.0), KVAL( 0.0)
};

vec2 Offset[KERNEL_SIZE] = {
	vec2( -1.0, -1.0 ), vec2( +0.0, -1.0 ), vec2( +1.0, -1.0 ),
	vec2( -1.0, +0.0 ), vec2( +0.0, +0.0 ), vec2( +1.0, +0.0 ),
	vec2( -1.0, +1.0 ), vec2( +0.0, +1.0 ), vec2( +1.0, +1.0 )
};
#endif
				

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
	vec4 sum = vec4(0.0);

#if 0
	int i;

	// sum it up ..
	for(i=0; i<KERNEL_SIZE; i++)
	{
		sum += lutTex2D(gl_TexCoord[0].st + Offset[i]/color_texture_pow2_sz) * KernelValue[i];
	}
#else
	sum += lutTex2D(gl_TexCoord[0].st + vec2(-1.0, -1.0)/color_texture_pow2_sz) * KVAL( 0.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2( 0.0, -1.0)/color_texture_pow2_sz) * KVAL( 1.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2(+1.0, -1.0)/color_texture_pow2_sz) * KVAL( 0.0);

	sum += lutTex2D(gl_TexCoord[0].st + vec2(-1.0,  0.0)/color_texture_pow2_sz) * KVAL( 1.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2( 0.0,  0.0)/color_texture_pow2_sz) * KVAL(-4.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2(+1.0,  0.0)/color_texture_pow2_sz) * KVAL( 1.0);

	sum += lutTex2D(gl_TexCoord[0].st + vec2(-1.0, +1.0)/color_texture_pow2_sz) * KVAL( 0.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2( 0.0, +1.0)/color_texture_pow2_sz) * KVAL( 1.0);
	sum += lutTex2D(gl_TexCoord[0].st + vec2(+1.0, +1.0)/color_texture_pow2_sz) * KVAL( 0.0);
#endif
	
	gl_FragColor = sum;
}

