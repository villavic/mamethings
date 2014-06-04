
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D	color_texture;
uniform vec2		color_texture_pow2_sz; // pow2 tex size
uniform vec4		vid_attributes;        // gamma, contrast, brightness

varying vec2		texCoord_0_pow2_sz; // gl_TexCoord[0].xy*color_texture_pow2_sz
varying vec2		color_texture_pow2_inv_sz;	// pow2 tex 1/size 

// #define DO_GAMMA  1 // 'pow' is very slow on old hardware, i.e. pre R600 and 'slow' in general

#define TEX2D(v) texture2D(color_texture,(v))

#define GET_RESULT(a,b,c,d) (sign(abs((a)-(c))+abs((a)-(d)))-sign(abs((b)-(c))+abs((b)-(d))))
//#define GET_RESULT(a,b,c,d) (float((a)!=(c) && (a)!=(d) && (b)==(c) && (b)==(d))-float((a)==(c) && (a)==(d)))

#define REDUCE(c) (dot((c),dt))

const vec4 dt = vec4(16777216.0,65536.0,256.0,1.0);

void main()
{
	vec4    color;
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
	if(fp.x>=.5 && fp.y>=.5) color = p11;
	else if(fp.x>=.5 || fp.y>=.5) color = p10;
	else color = C4;

	// gamma, contrast, brightness equation from: rendutil.h / apply_brightness_contrast_gamma_fp

#ifdef DO_GAMMA
	// gamma/contrast/brightness
	vec4 gamma = vec4(1.0 / vid_attributes.r, 1.0 / vid_attributes.r, 1.0 / vid_attributes.r, 0.0);
	gl_FragColor =  ( pow ( color, gamma ) * vid_attributes.g) + vid_attributes.b - 1.0;
#else
	// contrast/brightness
	gl_FragColor =  ( color                * vid_attributes.g) + vid_attributes.b - 1.0;
#endif

}


