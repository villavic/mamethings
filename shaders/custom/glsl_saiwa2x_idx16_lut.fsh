
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D	color_texture;
uniform sampler2D	colortable_texture;
uniform vec2		colortable_sz; // ct size
uniform vec2		colortable_pow2_sz; // pow2 ct size
uniform vec2		color_texture_pow2_sz; // pow2 tex size

varying vec2		color_texture_pow2_inv_sz;	// pow2 tex 1/size 
varying vec2		texCoord_0_pow2_sz;		// gl_TexCoord[0].xy*color_texture_pow2_sz

// #define DO_GAMMA  1 // 'pow' is very slow on old hardware, i.e. pre R600 and 'slow' in general

#define TEX2D(v) lutTex2D((v))

#define GET_RESULT(a,b,c,d) (sign(abs((a)-(c))+abs((a)-(d)))-sign(abs((b)-(c))+abs((b)-(d))))
//#define GET_RESULT(a,b,c,d) (float((a)!=(c) && (a)!=(d) && (b)==(c) && (b)==(d))-float((a)==(c) && (a)==(d)))

#define REDUCE(c) (dot((c),dt))

const vec4  dt = vec4(16777216.0,65536.0,256.0,1.0);
const float pi = 1.570796326794896619231321691640;

vec2 rx,ry;
vec2 dx,dy;

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

vec4 SaI2x(in vec2 fp, in vec2 pC4)
{
  vec4 rValue;
  if(fp.x < .5 && fp.y < .5) rValue = TEX2D(pC4);
  else
  {
    if(fp.x < .5 || fp.y >= .5){dx = rx; dy = ry;}else{dx = ry; dy = rx;}
    vec4 C4 = TEX2D(pC4            ),
         C5 = TEX2D(pC4+   dx      ),
         C7 = TEX2D(pC4      +   dy),
         C8 = TEX2D(pC4+   dx+   dy),
         p10,p11;
    float c4 = REDUCE(C4),c5 = REDUCE(C5),c7 = REDUCE(C7),c8 = REDUCE(C8);
    if(c4==c8)
    {
      if(c5!=c7)
      {
        vec4 C3 = TEX2D(pC4-   dx      ),
             C6 = TEX2D(pC4-   dx+   dy),
             D0 = TEX2D(pC4-   dx+2.*dy),
             D2 = TEX2D(pC4+   dx+2.*dy);
        float c3 = REDUCE(C3),c6 = REDUCE(C6),d0 = REDUCE(D0),d2 = REDUCE(D2);
        p10 = (c4==c3 && c7==d2 || c4==c5 && c4==c6 && c3!=c7 && c7==d0) ? C4 : .5*(C4+C7);
        p11 = C4;
      }
      else if(c4==c5) p11 = (p10 = C4);
      else
      {
        vec4 C1 = TEX2D(pC4      -   dy),
             C2 = TEX2D(pC4+   dx-   dy),
             C3 = TEX2D(pC4-   dx      ),
             C6 = TEX2D(pC4-   dx+   dy),
             D1 = TEX2D(pC4      +2.*dy),
             D2 = TEX2D(pC4+   dx+2.*dy),
             D4 = TEX2D(pC4+2.*dx      ),
             D5 = TEX2D(pC4+2.*dx+   dy);
        float c1 = REDUCE(C1),c2 = REDUCE(C2),c3 = REDUCE(C3),c6 = REDUCE(C6),
              d1 = REDUCE(D1),d2 = REDUCE(D2),d4 = REDUCE(D4),d5 = REDUCE(D5);
        float r = GET_RESULT(c4,c5,c3,c1)+GET_RESULT(c4,c5,d5,d2)
                 -GET_RESULT(c5,c4,d4,c2)-GET_RESULT(c5,c4,c6,d1);
        p10 = .5*(C4+C7);
        if(r>0.) p11 = C4;
        else if(r<0.) p11 = C5;
        else p11 = .25*(C4+C5+C7+C8);
      }
    }
    else if(c5==c7)
    {
      vec4 C0 = TEX2D(pC4-   dx-   dy),
           C2 = TEX2D(pC4+   dx-   dy),
           C3 = TEX2D(pC4-   dx      ),
           C6 = TEX2D(pC4-   dx+   dy);
      float c0 = REDUCE(C0),c2 = REDUCE(C2),c3 = REDUCE(C3),c6 = REDUCE(C6);
      p10 = (c7==c6 && c4==c2 || c7==c3 && c7==c8 && c4!=c6 && c4==c0) ? C7 : .5*(C4+C7);
      p11 = C5;
    }
    else
    {
      vec4 C0 = TEX2D(pC4-   dx-   dy),
           C3 = TEX2D(pC4-   dx      ),
           C6 = TEX2D(pC4-   dx+   dy),
           D0 = TEX2D(pC4-   dx+2.*dy);
      float c0 = REDUCE(C0),c3 = REDUCE(C3),c6 = REDUCE(C6),d0 = REDUCE(D0);
      p11 = .25*(C4+C5+C7+C8);
      if(c4==c5 && c4==c6 && c3!=c7 && c7==d0) p10 = C4;
      else if(c7==c3 && c7==c8 && c4!=c6 && c4==c0) p10 = C7;
      else p10 = .5*(C4+C7);
    }
    rValue = (fp.x>=.5 && fp.y>=.5) ? p11 : p10;
  }
  return rValue;
}


void main()
{
	vec2	fp = fract(texCoord_0_pow2_sz),
		s0 = vec2(1.-fp.x,1.-fp.y), s1 = vec2(1.-fp.x,fp.y),
		s2 = vec2(   fp.x,1.-fp.y), s3 = vec2(   fp.x,fp.y),
		_dx,_dy;
	     
	rx = vec2(color_texture_pow2_inv_sz.x,0.);
	ry = vec2(0.,color_texture_pow2_inv_sz.y);

	_dx = rx;
	_dy = ry;


	if(fp.x>=.5){fp.x = 1. - fp.x; _dx = -_dx;}
	if(fp.y>=.5){fp.y = 1. - fp.y; _dy = -_dy;}

	fp *= 2.;

	if(fp.x>=.5){fp.x = 1. - fp.x; _dx = vec2(0.);}
	if(fp.y>=.5){fp.y = 1. - fp.y; _dy = vec2(0.);}

	mat4 C =mat4(SaI2x(s0,gl_TexCoord[0].xy-_dx-_dy),SaI2x(s1,gl_TexCoord[0].xy-_dx),
		     SaI2x(s2,gl_TexCoord[0].xy   -_dy),SaI2x(s3,gl_TexCoord[0].xy   ));
	mat2 gp = mat2((fp+.5)*(fp+.5),(fp-.5)*(fp-.5));
	vec4 c = vec4(gp[0][0]+gp[0][1],gp[0][0]+gp[1][1],
		gp[1][0]+gp[0][1],gp[1][0]+gp[1][1]);
	c=-sqrt(c);if(c.x<-1.)c.x=-1.;if(c.y<-1.)c.y=-1.;if(c.z<-1.)c.z=-1.;c=cos(pi*c);
	gl_FragColor = (C[0]*c.x+C[1]*c.y+C[2]*c.z+C[3]*c.w)/(c.x+c.y+c.z+c.w);
}

