
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D mpass_texture;
uniform sampler2D color_texture;
uniform vec2	  color_texture_pow2_sz;          // pow2 tex size

void main()
{
	vec2 xy = gl_TexCoord[0].st;

	gl_FragColor = texture2D(mpass_texture, xy) -
	               step(1.0, mod(xy.x*color_texture_pow2_sz.x,2.0))*0.5;
}

