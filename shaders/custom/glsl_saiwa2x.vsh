
uniform vec2	color_texture_pow2_sz;		// pow2 tex size
varying vec2	color_texture_pow2_inv_sz;	// pow2 tex 1/size 
varying vec2	texCoord_0_pow2_sz;		// gl_TexCoord[0].xy*color_texture_pow2_sz

void main()
{
	gl_TexCoord[0]  = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	gl_Position     = ftransform();

	texCoord_0_pow2_sz     = gl_TexCoord[0].xy*color_texture_pow2_sz;
	color_texture_pow2_inv_sz = 1.0/color_texture_pow2_sz;
}

