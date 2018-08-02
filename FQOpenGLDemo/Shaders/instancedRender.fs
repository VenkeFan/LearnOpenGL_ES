#version 100

precision mediump float;

uniform sampler2D ourTexture;

varying vec2 vTexCoord;

void main()
{
    gl_FragColor = texture2D(ourTexture, vTexCoord);
}
