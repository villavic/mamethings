/*  CRT Trinitron Shader
 *
 *  Copyright (C) 2012-2013 Douglas Lassance
 *  Port of the amazing CRT-OpenGL shader by cgwg for SDLMAME and SDLMESS.
 *  
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 */

uniform vec2 color_texture_sz;
uniform vec2 color_texture_pow2_sz;

varying vec2 texCoord;
varying vec2 one;
varying float mod_factor;

void main() {
   
    // Do the standard vertex processing.
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    // Precalculate a bunch of useful values we'll need in the fragment shader. Texture coords.
    texCoord = gl_MultiTexCoord0.xy;

    // The size of one texel, in texture-coordinates.
    one = 1.0 / color_texture_pow2_sz;

    // Resulting X pixel-coordinate of the pixel we're drawing.
    mod_factor = texCoord.x * color_texture_pow2_sz.x * color_texture_sz.x / color_texture_pow2_sz.x;
}