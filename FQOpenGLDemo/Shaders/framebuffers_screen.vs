#version 100

attribute vec3 position;
attribute vec2 texcoord;

varying vec2 vTexcoord;

void main()
{
    vTexcoord = texcoord;
    
    gl_Position = vec4(position, 1.0);
}
