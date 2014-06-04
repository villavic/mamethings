
#pragma optimize (on)
#pragma debug (off)

uniform sampler2D color_texture;
uniform vec4      vid_attributes;     // gamma, contrast, brightness

void main()
{
	vec4 gamma = vec4( 1.0 / vid_attributes.r, 1.0 / vid_attributes.r, 1.0 / vid_attributes.r, 0.0);

	// gamma, contrast, brightness equation from: rendutil.h / apply_brightness_contrast_gamma_fp
	vec4 color = pow( texture2D(color_texture, gl_TexCoord[0].st) , gamma);

	// contrast/brightness
	gl_FragColor =  (color * vid_attributes.g) + vid_attributes.b - 1.0;
}

