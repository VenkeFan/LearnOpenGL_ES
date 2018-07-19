#version 100

attribute vec4 v_Position;
attribute vec4 v_Color;

varying vec4 fragColor;

void main()
{
    fragColor = v_Color;
    gl_Position = v_Position;
}
