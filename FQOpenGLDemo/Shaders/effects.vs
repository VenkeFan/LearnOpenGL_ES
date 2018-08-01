#version 100

attribute vec3 vPos;
attribute vec2 texcoord;

varying vec2 vTexcoord;

void main()
{
    gl_Position = vec4(vPos, 1.0);
    vTexcoord = texcoord;
}
