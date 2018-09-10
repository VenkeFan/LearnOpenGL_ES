#version 100

attribute vec2 aPos;
attribute vec2 aTexCoord;
attribute vec2 aGhostTexCoord;
attribute float aScale;

varying vec2 vTexCoord;
varying vec2 vGhostTexCoord;

void main()
{
    vTexCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
    vGhostTexCoord = vec2(aGhostTexCoord.x, 1.0 - aGhostTexCoord.y);
    
    gl_Position = vec4(aPos, 0.0, 1.0);
}
