#version 100

attribute vec3 aPos;
attribute vec3 aNormal; // 法向量
attribute vec2 aTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying vec3 Normal;
varying vec3 FragPos;
varying vec2 TexCoord;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    
    Normal = aNormal;
    FragPos = vec3(model * vec4(aPos, 1.0));
    TexCoord = aTexCoord;
}
