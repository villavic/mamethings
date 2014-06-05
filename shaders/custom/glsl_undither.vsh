varying vec2 TCoord;

void main()
{
    TCoord = gl_MultiTexCoord0.xy;

    gl_TexCoord[0]  = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_Position     = ftransform();
}

