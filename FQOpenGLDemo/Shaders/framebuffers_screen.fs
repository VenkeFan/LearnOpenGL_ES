#version 100

precision mediump float;

varying vec2 vTexcoord;

uniform sampler2D image;

void main()
{
    gl_FragColor = texture2D(image, vTexcoord);
//    gl_FragColor = vec4(vec3(1.0 - texture2D(myTexture, TexCoord)), 1.0);
}
