#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

void main()
{
    vec4 tex = texture2D(image, vTexcoord);
    gl_FragColor = vec4(1.0 - tex.rgb, tex.w);
}
