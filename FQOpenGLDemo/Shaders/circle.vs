#version 100

attribute vec3 v_Position;
attribute vec3 v_Color;

varying vec3 fragColor;

void main()
{
    fragColor = v_Color;
    gl_Position = vec4(v_Position, 1.0);
}
