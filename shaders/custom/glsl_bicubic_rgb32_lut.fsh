#pragma optimize (on)
#pragma debug (off)

uniform sampler2D colortable_texture;    // LUT texture
uniform sampler2D color_texture;         // mame idx'ed texture
uniform vec2      colortable_sz;         // LUT size
uniform vec2      colortable_pow2_sz;    // LUT pow2 size
uniform vec2      color_texture_sz;      // textured size
uniform vec2      color_texture_pow2_sz; // textured pow2 size

varying vec2        color_texture_pow2_inv_sz;  // pow2 tex 1/size 
varying vec2        texCoord_0_pow2_sz;     // gl_TexCoord[0].xy*color_texture_pow2_sz

/* Change this define to one of:
 *  Triangular, BellFunc, BSpline, CatMullRom
 */

#define BICUBICFUNC CatMullRom

vec4 lutTex2D(in vec2 texcoord)
{
    vec4 color_tex;
    vec2 color_map_coord;
    vec4 color0;
    float colortable_scale = (colortable_sz.x/3.0) / colortable_pow2_sz.x;

    // normalized texture coordinates ..
    color_tex         = texture2D(color_texture, texcoord) * ((colortable_sz.x/3.0)-1.0)/colortable_pow2_sz.x;// lookup space 

    color_map_coord.x = color_tex.b;
    color0.b          = texture2D(colortable_texture, color_map_coord).b;

    color_map_coord.x = color_tex.g + colortable_scale;
    color0.g          = texture2D(colortable_texture, color_map_coord).g;

    color_map_coord.x = color_tex.r + 2.0 * colortable_scale;
    color0.r          = texture2D(colortable_texture, color_map_coord).r;

    return color0;
}

/* The basic Triangular function, completely blurred edges */
float Triangular( float f )
{
    f = f / 2.0;
    if( f < 0.0 )
    {
        return ( f + 1.0 );
    }
    else
    {
        return ( 1.0 - f );
    }
    return 0.0;
}

/* The Bell function, more edge detail */
float BellFunc( float x )
{
    float f = ( x / 2.0 ) * 1.5; // Converting -2 to +2 to -1.5 to +1.5
    if( f > -1.5 && f < -0.5 )
    {
        return( 0.5 * pow(f + 1.5, 2.0));
    }
    else if( f > -0.5 && f < 0.5 )
    {
        return 3.0 / 4.0 - ( f * f );
    }
    else if( ( f > 0.5 && f < 1.5 ) )
    {
        return( 0.5 * pow(f - 1.5, 2.0));
    }
    return 0.0;
}

/* B-Spline, more edge detail, but more ringing */
float BSpline( float x )
{
    float f = x;
    if( f < 0.0 )
    {
        f = -f;
    }

    if( f >= 0.0 && f <= 1.0 )
    {
        return ( 2.0 / 3.0 ) + ( 0.5 ) * ( f* f * f ) - (f*f);
    }
    else if( f > 1.0 && f <= 2.0 )
    {
        return 1.0 / 6.0 * pow( ( 2.0 - f  ), 3.0 );
    }
    return 1.0;
}  

/* CatMull-Rom preserved all edges but might create noise off dithering */
float CatMullRom( float x )
{
    const float B = 0.0;
    const float C = 0.5;
    float f = x;
    if( f < 0.0 )
    {
        f = -f;
    }
    if( f < 1.0 )
    {
        return ( ( 12 - 9 * B - 6 * C ) * ( f * f * f ) +
            ( -18 + 12 * B + 6 *C ) * ( f * f ) +
            ( 6 - 2 * B ) ) / 6.0;
    }
    else if( f >= 1.0 && f < 2.0 )
    {
        return ( ( -B - 6 * C ) * ( f * f * f )
            + ( 6 * B + 30 * C ) * ( f *f ) +
            ( - ( 12 * B ) - 48 * C  ) * f +
            8 * B + 24 * C)/ 6.0;
    }
    else
    {
        return 0.0;
    }
}

void main()
{
    vec2 TexCoord = gl_TexCoord[0].st;
    float texelSizeX = color_texture_pow2_inv_sz.x; //size of one texel 
    float texelSizeY = color_texture_pow2_inv_sz.y; //size of one texel 
    vec4 nSum = vec4( 0.0, 0.0, 0.0, 0.0 );
    vec4 nDenom = vec4( 0.0, 0.0, 0.0, 0.0 );
    float a = fract( TexCoord.x / color_texture_pow2_inv_sz.x ); // get the decimal part
    float b = fract( TexCoord.y / color_texture_pow2_inv_sz.y ); // get the decimal part
    for( int m = -1; m <=2; m++ )
    {
        for( int n =-1; n<= 2; n++)
        {
            vec4 vecData = lutTex2D(TexCoord + vec2(texelSizeX * float( m ), 
                    texelSizeY * float( n )));
            float f  = BICUBICFUNC( float( m ) - a );
            vec4 vecCooef1 = vec4( f,f,f,f );
            float f1 = BICUBICFUNC( -( float( n ) - b ) );
            vec4 vecCoeef2 = vec4( f1, f1, f1, f1 );
            nSum = nSum + ( vecData * vecCoeef2 * vecCooef1  );
            nDenom = nDenom + (( vecCoeef2 * vecCooef1 ));
        }
    }
    gl_FragColor = nSum / nDenom;
}