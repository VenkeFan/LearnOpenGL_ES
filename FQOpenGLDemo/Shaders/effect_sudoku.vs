#version 100

attribute vec2 aPos;
attribute vec2 aTexCoord;
attribute vec2 aOffset;

uniform mat4 model;

varying vec2 vTexCoord;

void main ()
{
    vTexCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
    gl_Position = model * vec4(aPos + aOffset, 0.0, 1.0);
}
