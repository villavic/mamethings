uniform vec2 color_texture_sz;

void main() {
    float x = 1.0 / color_texture_sz.x;
    float y = 1.0 / color_texture_sz.y;

    //gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_Position = ftransform();

    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_TexCoord[1].xy = vec2(x, 0.0);
    gl_TexCoord[1].zw = vec2(0.0, y);
}