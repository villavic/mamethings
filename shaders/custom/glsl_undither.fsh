// 2x Undithering GLSL shader - coded by ShadX
//
// [A][B][C][D][E]
// [F][G][H][J][K]
// [L][M][N][O][P] matrix used
// [Q][R][S][T][U]
// [V][W][X][Y][Z]
//

#pragma optimize(on)
#pragma debug(off)

uniform sampler2D mpass_texture;
uniform vec2      screen_texture_sz;      // screen texture size
uniform vec2      screen_texture_pow2_sz; // screen texture pow2 size

varying vec2 TCoord;

void main()
{
float offsetx1 = 1.0 / screen_texture_pow2_sz.x;
float offsety1 = 1.0 / screen_texture_pow2_sz.y;
float offsetx2 = 2.0 / screen_texture_pow2_sz.x;
float offsety2 = 2.0 / screen_texture_pow2_sz.y;

vec3 fact;
fact.x = 0.30;
fact.y = 0.59;
fact.z = 0.11;

vec4 colA = texture2D(mpass_texture, TCoord + vec2(-offsetx2,-offsety2));
vec4 colB = texture2D(mpass_texture, TCoord + vec2(-offsetx1,-offsety2));
vec4 colC = texture2D(mpass_texture, TCoord + vec2( 0.0,-offsety2));
vec4 colD = texture2D(mpass_texture, TCoord + vec2( offsetx1,-offsety2));
vec4 colE = texture2D(mpass_texture, TCoord + vec2( offsetx2,-offsety2));
vec4 colF = texture2D(mpass_texture, TCoord + vec2(-offsetx2,-offsety1));
vec4 colG = texture2D(mpass_texture, TCoord + vec2(-offsetx1,-offsety1));
vec4 colH = texture2D(mpass_texture, TCoord + vec2( 0.0,-offsety1));
vec4 colJ = texture2D(mpass_texture, TCoord + vec2( offsetx1,-offsety1));
vec4 colK = texture2D(mpass_texture, TCoord + vec2( offsetx2,-offsety1));
vec4 colL = texture2D(mpass_texture, TCoord + vec2(-offsetx2, 0.0));
vec4 colM = texture2D(mpass_texture, TCoord + vec2(-offsetx1, 0.0));
vec4 colN = texture2D(mpass_texture, TCoord);
vec4 colO = texture2D(mpass_texture, TCoord + vec2( offsetx1, 0.0));
vec4 colP = texture2D(mpass_texture, TCoord + vec2( offsetx2, 0.0));
vec4 colQ = texture2D(mpass_texture, TCoord + vec2(-offsetx2, offsety1));
vec4 colR = texture2D(mpass_texture, TCoord + vec2(-offsetx1, offsety1));
vec4 colS = texture2D(mpass_texture, TCoord + vec2( 0.0, offsety1));
vec4 colT = texture2D(mpass_texture, TCoord + vec2( offsetx1, offsety1));
vec4 colU = texture2D(mpass_texture, TCoord + vec2( offsetx2, offsety1));
vec4 colV = texture2D(mpass_texture, TCoord + vec2(-offsetx2, offsety2));
vec4 colW = texture2D(mpass_texture, TCoord + vec2(-offsetx1, offsety2));
vec4 colX = texture2D(mpass_texture, TCoord + vec2( 0.0, offsety2));
vec4 colY = texture2D(mpass_texture, TCoord + vec2( offsetx1, offsety2));
vec4 colZ = texture2D(mpass_texture, TCoord + vec2( offsetx2, offsety2));

vec4 c = (colG + colH + colJ + colM + colO + colR + colS + colT) * 0.1 + 0.2 * colN;//center
vec4 nw = (colA + colB + colC + colF + colH + colL + colM + colN) * 0.1 + 0.2 * colG;//North-west
vec4 se = (colN + colO + colP + colS + colU + colX + colY + colZ) * 0.1 + 0.2 * colT;//South-East

vec4 luma = se - nw; //you can also use "nw - se"...
float temp = (luma.x * fact.x + luma.y * fact.y + luma.z * fact.z);
vec4 togray;
togray.x = temp;
togray.y = temp;
togray.z = temp;
togray.w = 0.0;

vec4 undith;
undith.x = c.x;
undith.y = c.y;
undith.z = c.z;
undith.w = colN.w;

gl_FragColor = undith + togray;
}