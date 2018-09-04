#version 100

precision mediump float;

varying vec2 vTexCoord;

uniform sampler2D myTexture;

void main()
{
    // 正常
    gl_FragColor = texture2D(myTexture, vTexCoord);
    
    // 电击效果
//    vec4 tex = texture2D(myTexture, vTexCoord);
//    gl_FragColor = vec4(1.0 - tex.rgb, tex.w);
    
}
