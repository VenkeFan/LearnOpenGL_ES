#version 100

precision mediump float;

varying vec2 vTexCoord;

uniform sampler2D myTexture;

void main()
{
    gl_FragColor = texture2D(myTexture, vTexCoord);
}
