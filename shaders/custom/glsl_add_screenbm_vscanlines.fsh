
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D mpass_texture;
uniform vec2      screen_texture_sz;      // screen texture size
uniform vec2      screen_texture_pow2_sz; // screen texture pow2 size

uniform vec2	  color_texture_sz;       // mame-bmp tex size
uniform vec2	  color_texture_pow2_sz;  // mame-bmp pow2 tex size

void main()
{
	vec2 xy = gl_TexCoord[0].st;

	gl_FragColor = texture2D(mpass_texture, xy) -
	               step(1.0, mod(xy.x*screen_texture_pow2_sz.x,2.0))*0.5;
}

