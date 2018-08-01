#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    vec4 color = texture2D(image, vTexcoord);
    float luminance = dot(color.rgb, W);
    color = vec4(vec3(luminance), color.a);
    gl_FragColor = color;
}
