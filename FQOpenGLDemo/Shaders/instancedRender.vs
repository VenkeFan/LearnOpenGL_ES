#version 100

attribute vec3 aPos;
attribute vec2 aTexCoord;
attribute vec3 offset; //偏移量

varying vec2 vTexCoord;

void main()
{
    gl_Position = vec4(aPos + offset, 1.0);
    
    vTexCoord = aTexCoord;
}
