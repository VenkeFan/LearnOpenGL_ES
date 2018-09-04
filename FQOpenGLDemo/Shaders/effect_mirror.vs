#version 100

attribute vec2 aPos;
attribute vec2 aTexCoord;
attribute vec2 aOffset;
attribute vec2 aTexTransform;

varying vec2 vTexCoord;

void main()
{
    vec2 correctTexCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
    
    if (aTexTransform.x > 0.0) {
        correctTexCoord.x = aTexTransform.x - correctTexCoord.x;
    }
    
    if (aTexTransform.y > 0.0) {
        correctTexCoord.y = aTexTransform.y - correctTexCoord.y;
    }
    vTexCoord = correctTexCoord;
    
    gl_Position = vec4(aPos + aOffset, 0.0, 1.0);
}
