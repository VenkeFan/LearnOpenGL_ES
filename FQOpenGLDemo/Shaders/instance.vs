#version 100

attribute vec2 aPos;
attribute vec3 aColor;
attribute vec2 aOffset;

varying vec3 vColor;

void main()
{
    vColor = aColor;
    
    gl_Position = vec4(aPos + aOffset, 0.0, 1.0);
}
