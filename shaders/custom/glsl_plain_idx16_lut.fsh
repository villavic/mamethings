
#pragma optimize (off)
#extension GL_ARB_texture_rectangle : enable
#pragma optionNV(fastmath on)
#pragma optionNV(fastprecision on)
#pragma optionNV(ifcvt none)
#pragma optionNV(inline all)
#pragma optionNV(strict on)
#pragma optionNV(unroll all)
#pragma debug (on)

uniform sampler2D colortable_texture;    // LUT texture
uniform sampler2D color_texture;	 	 // mame idx'ed texture
uniform vec2      colortable_sz;         // LUT size
uniform vec2      colortable_pow2_sz;    // LUT pow2 size
uniform vec2      color_texture_sz;      // textured size
uniform vec2      color_texture_pow2_sz; // textured pow2 size


void main()
{
	// http://climserv.ipsl.polytechnique.fr/documentation/idl_help/High_Precision_Images.html
	// http://psychtoolbox-3.googlecode.com/svn/trunk/Psychtoolbox/PsychOpenGL/PsychGLSLShaders/
	/*	 Image Data Type 	Floating Point Conversion
	 *		BYTE				c/(2**8-1)
	 *		UINT				c/(2**16-1)
	 *		INT					(2c+1)/(2**16-1)
	 *		FLOAT 				c
	 * f = c / (2**16-1)
	 * c = (2**16-1) * f
	 */
	vec2 lutindex;
    vec2 one = 1.0 / color_texture_pow2_sz;

    /* Retrieve HDR/High precision input luminance value from ALPHA channel:     */
    /* We expect these values to be in 0.0 - 1.0 range.                         */
	float incolor = texture2D(color_texture, gl_TexCoord[0].st).a;

    /* Remap 'incolor' from 0.0 - 1.0 range to range 0 - bitdepth (2**16). Turn */
    /* remapped value into integral value by floor()'ing to closest */
    /* smaller or equal integral value: 'index' will be our linear index into the LUT. */
	float index = floor(incolor * 65535) + 1e-6;
    /* Compute high byte (8 MSBs) of 2D texture lookup position: */
    lutindex.y = (floor(index / colortable_pow2_sz.x) + 0.5);
    /* Compute low byte (8 LSBs) of 2D texture lookup position: */
    lutindex.x = (floor(mod(index, colortable_pow2_sz.x)) + 0.5);
    /* Readout LUT texture at 2D location lutindex(x,y) to get final RGBA8 */
    /* output pixel and write it to framebuffer: */
    lutindex = lutindex * (1.0 + 1e-4);
    gl_FragColor = texture2D(colortable_texture, lutindex / colortable_pow2_sz);
}