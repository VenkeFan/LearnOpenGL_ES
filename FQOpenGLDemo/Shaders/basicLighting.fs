#version 100

precision mediump float;

uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 objectColor;

varying vec3 Normal;
varying vec3 FragPos;

void main()
{
    // 环境光照
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;
    
    // 漫反射光照
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    
    vec3 result = (ambient + diffuse) * objectColor;
    
    gl_FragColor = vec4(result, 1.0);
}
