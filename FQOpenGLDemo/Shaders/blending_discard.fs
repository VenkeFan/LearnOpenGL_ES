#version 100

precision mediump float;

varying vec2 TexCoord;

uniform sampler2D myTexture;

void main()
{
    vec4 color = texture2D(myTexture, TexCoord);
    if (color.a <= 0.1) {
        discard;
    }
    
    gl_FragColor = color;
}
