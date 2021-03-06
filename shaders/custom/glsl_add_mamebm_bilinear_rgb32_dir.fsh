
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D     mpass_texture;
uniform sampler2D     color_texture;
uniform vec2          color_texture_pow2_sz; // pow2 tex size
uniform vec4          vid_attributes;        // gamma, contrast, brightness

#define TEX2D(c) texture2D(mpass_texture,(c))

void main()
{
	vec2 xy = gl_TexCoord[0].st;

	// mix(x,y,a): x*(1-a) + y*a
	//
	// bilinear filtering includes 2 mix:
	//
	//   pix1 = tex[x0][y0] * ( 1 - u_ratio ) + tex[x1][y0] * u_ratio
	//   pix2 = tex[x0][y1] * ( 1 - u_ratio ) + tex[x1][y1] * u_ratio
	//   fin  =    pix1     * ( 1 - v_ratio ) +     pix2    * v_ratio
	//
	// so we can use the build in mix function for these 2 computations ;-)
	//
	vec2 uv_ratio     = fract(xy*color_texture_pow2_sz); // xy*color_texture_pow2_sz - floor(xy*color_texture_pow2_sz);
	vec2 one          = 1.0/color_texture_pow2_sz;

	vec4 col, col2;

	col  = mix( TEX2D(xy                   ), TEX2D(xy + vec2(one.x, 0.0)), uv_ratio.x);
	col2 = mix( TEX2D(xy + vec2(0.0, one.y)), TEX2D(xy + one             ), uv_ratio.x);
	gl_FragColor  = mix ( col, col2, uv_ratio.y );
}

