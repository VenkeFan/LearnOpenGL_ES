#version 100

attribute vec3 aPos;
attribute vec3 aColor;
attribute vec2 aTexCoord;

varying vec3 ourColor;
varying vec2 TexCoord;

uniform mat4 aTransform;

void main()
{
    gl_Position = aTransform * vec4(aPos, 1.0);
    
    ourColor = aColor;
    TexCoord = aTexCoord;
}
