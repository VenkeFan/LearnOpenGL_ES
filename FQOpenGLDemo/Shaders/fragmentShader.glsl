#version 100

precision mediump float;

//uniform vec4 ourColor;
varying vec4 fragColor;

void main()
{
//    gl_FragColor = vec4(0, 0, 1, 1);
//    gl_FragColor = ourColor;
    gl_FragColor = fragColor;
}
