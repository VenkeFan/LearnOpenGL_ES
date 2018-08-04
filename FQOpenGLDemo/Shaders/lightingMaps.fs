#version 100

precision mediump float;

// 材质属性
struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

// 光照属性
struct Light {
    vec3 position;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform Material material;
uniform Light light;
uniform vec3 viewPos; // 摄像机坐标

varying vec3 Normal;
varying vec3 FragPos;
varying vec2 TexCoord;

void main()
{
    // 环境光照
    vec3 ambient = light.ambient * texture2D(material.diffuse, TexCoord).rgb;
    
    // 漫反射光照
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * light.diffuse * texture2D(material.diffuse, TexCoord).rgb;
    
    // 镜面光照
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = spec * light.specular * texture2D(material.specular, TexCoord).rgb;
    
    vec3 result = ambient + diffuse + specular;
    
    gl_FragColor = vec4(result, 1.0);
}

