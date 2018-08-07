#version 100

precision mediump float;

varying vec3 ourColor;
varying vec2 TexCoord;

uniform sampler2D ourTexture;
uniform sampler2D anthorTexture;

void main()
{
//    gl_FragColor = texture2D(ourTexture, TexCoord);
//    gl_FragColor = texture2D(ourTexture, TexCoord) * vec4(ourColor, 1.0);
    gl_FragColor = mix(texture2D(ourTexture, TexCoord), texture2D(anthorTexture, TexCoord), 0.2);
    
    
    // 加法
//    vec4 color1 = texture2D(ourTexture, TexCoord);
//    vec4 color2 = texture2D(anthorTexture, TexCoord);
//    float alpha = 0.6;
//    gl_FragColor = vec4(vec3(color1*(1.0 - alpha) + color2*alpha), 1.0);
    
    // 减法
//    vec4 color1 = texture2D(ourTexture, TexCoord);
//    vec4 color2 = texture2D(anthorTexture, TexCoord);
//    gl_FragColor = vec4(vec3(color2 - color1), 1.0);
    
    // 乘法
//    vec4 color1 = texture2D(ourTexture, TexCoord);
//    vec4 color2 = texture2D(anthorTexture, TexCoord);
//    gl_FragColor = vec4(vec3(1.5 * color1 * color2), 1.0);
    
    // 除法
//    vec4 color1 = texture2D(ourTexture, TexCoord);
//    vec4 color2 = texture2D(anthorTexture, TexCoord);
//    gl_FragColor = vec4(vec3(color1/color2), 1.0);
    
    // 非运算
//    vec4 color1 = texture2D(ourTexture, TexCoord);
//    gl_FragColor = vec4(vec3(1.0) - vec3(color1), 1.0);
}
