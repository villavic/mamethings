
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D color_texture;
uniform sampler2D colortable_texture;
uniform vec2      colortable_sz; // ct size
uniform vec2      colortable_pow2_sz; // pow2 ct size
uniform vec2      color_texture_pow2_sz; // pow2 tex size

varying vec2      texCoord_0_pow2_sz; // gl_TexCoord[0].xy*color_texture_pow2_sz
varying vec2	  color_texture_pow2_inv_sz;	// pow2 tex 1/size 

#define TEX2D(v) lutTex2D((v))

#define GET_RESULT(a,b,c,d) (sign(abs((a)-(c))+abs((a)-(d)))-sign(abs((b)-(c))+abs((b)-(d))))
//#define GET_RESULT(a,b,c,d) (float((a)!=(c) && (a)!=(d) && (b)==(c) && (b)==(d))-float((a)==(c) && (a)==(d)))

#define REDUCE(c) (dot((c),dt))

const vec4 dt = vec4(16777216.0,65536.0,256.0,1.0);

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
	vec2	fp = fract(texCoord_0_pow2_sz), dx, dy,
		pC4 = floor(texCoord_0_pow2_sz)/color_texture_pow2_sz;

	if(fp.x<.5 || fp.y>=.5)
	{
		dx = vec2(color_texture_pow2_inv_sz.x,0.);
		dy = vec2(0.,color_texture_pow2_inv_sz.y);
	}
	else
	{
		dx = vec2(0.,color_texture_pow2_inv_sz.y);
		dy = vec2(color_texture_pow2_inv_sz.x,0.);
	}

	vec4	C0 = TEX2D(pC4-   dx-   dy),
		C1 = TEX2D(pC4      -   dy),
		C2 = TEX2D(pC4+   dx-   dy),
		C3 = TEX2D(pC4-   dx      ),
		C4 = TEX2D(pC4            ),
		C5 = TEX2D(pC4+   dx      ),
		C6 = TEX2D(pC4-   dx+   dy),
		C7 = TEX2D(pC4      +   dy),
		C8 = TEX2D(pC4+   dx+   dy),
		D0 = TEX2D(pC4-   dx+2.*dy),
		D1 = TEX2D(pC4      +2.*dy),
		D2 = TEX2D(pC4+   dx+2.*dy),
		D4 = TEX2D(pC4+2.*dx      ),
		D5 = TEX2D(pC4+2.*dx+   dy),
		p10,p11;
	float	c0 = REDUCE(C0),c1 = REDUCE(C1),c2 = REDUCE(C2),c3 = REDUCE(C3),
		c4 = REDUCE(C4),c5 = REDUCE(C5),c6 = REDUCE(C6),c7 = REDUCE(C7),
		c8 = REDUCE(C8),d0 = REDUCE(D0),d1 = REDUCE(D1),d2 = REDUCE(D2),
		d4 = REDUCE(D4),d5 = REDUCE(D5);
	if(c4==c8)
	{
		if(c5!=c7)
		{
			p10 = (c4==c3 && c7==d2 || c4==c5 && c4==c6 && c3!=c7 && c7==d0) ? C4 : .5*(C4+C7);
			p11 = C4;
		}
		else
		{
			if(c4==c5) 
			{
				p11 = (p10 = C4);
			}
			else
			{
				float r = GET_RESULT(c4,c5,c3,c1)+GET_RESULT(c4,c5,d5,d2)
					 -GET_RESULT(c5,c4,d4,c2)-GET_RESULT(c5,c4,c6,d1);
				p10 = .5*(C4+C7);
				if(r>0.) p11 = C4;
				else if(r<0.) p11 = C5;
				else p11 = .25*(C4+C5+C7+C8);
			}
		}
	}
	else if(c5==c7)
	{
		p10 = (c7==c6 && c4==c2 || c7==c3 && c7==c8 && c4!=c6 && c4==c0) ? C7 : .5*(C4+C7);
		p11 = C5;
	}
	else
	{
		p11 = .25*(C4+C5+C7+C8);
		if(c4==c5 && c4==c6 && c3!=c7 && c7==d0) p10 = C4;
		else if(c7==c3 && c7==c8 && c4!=c6 && c4==c0) p10 = C7;
		else p10 = .5*(C4+C7);
	}
	if(fp.x>=.5 && fp.y>=.5) gl_FragColor = p11;
	else if(fp.x>=.5 || fp.y>=.5) gl_FragColor = p10;
	else gl_FragColor = C4;

}
