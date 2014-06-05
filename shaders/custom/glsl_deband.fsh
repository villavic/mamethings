#pragma optimize (on)
#pragma debug (off)

uniform sampler2D mpass_texture;

float random(vec2 n) {
    return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
void main()
{

    gl_FragColor = texture2D(mpass_texture, gl_TexCoord[0]) + vec4(random(0.1 * gl_TexCoord[0].xy) / 255.0);
}