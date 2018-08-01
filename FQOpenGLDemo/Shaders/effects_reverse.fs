#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

void main()
{
    vec2 coord = vec2(vTexcoord.x, 1.0 - vTexcoord.y);
    gl_FragColor = texture2D(image, coord);
}
