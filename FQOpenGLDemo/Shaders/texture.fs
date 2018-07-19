#version 100

precision mediump float;

varying vec3 ourColor;
varying vec2 TexCoord;

uniform sampler2D ourTexture;
uniform sampler2D anthorTexture;

void main()
{
//    gl_FragColor = texture2D(ourTexture, TexCoord);
//    gl_FragColor = texture2D(ourTexture, TexCoord) * vec4(ourColor, 1.0);
    gl_FragColor = mix(texture2D(ourTexture, TexCoord), texture2D(anthorTexture, TexCoord), 0.2);
}
