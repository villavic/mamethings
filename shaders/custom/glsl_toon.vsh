// by guest(r) - guest.r@gmail.com
// license: GNU-GPL
// conversion to SDLMAME by R. Belmont

void main()

{
	float x = 0.001;	// adjust these for effect
	float y = 0.001;
	vec2 dg1 = vec2( x,y);
	vec2 dg2 = vec2(-x,y);
	vec2 dx  = vec2(x,0.0);
	vec2 dy  = vec2(0.0,y);
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_TexCoord[1].xy = gl_TexCoord[0].xy - dy;
	gl_TexCoord[2].xy = gl_TexCoord[0].xy + dy;
	gl_TexCoord[3].xy = gl_TexCoord[0].xy - dx;
	gl_TexCoord[4].xy = gl_TexCoord[0].xy + dx;
	gl_TexCoord[5].xy = gl_TexCoord[0].xy - dg1;
	gl_TexCoord[6].xy = gl_TexCoord[0].xy + dg1;
	gl_TexCoord[1].zw = gl_TexCoord[0].xy - dg2;
	gl_TexCoord[2].zw = gl_TexCoord[0].xy + dg2;
}
