#version 100

precision mediump float;

varying vec2 vTexCoord;
varying vec2 vGhostTexCoord;

uniform sampler2D myTexture;
uniform sampler2D ghostTexture;

void main()
{
//    gl_FragColor = texture2D(myTexture, vTexCoord);
    
//    vec2 ghostTex = vec2(abs(vTexCoord.x - 0.25), abs(vTexCoord.y - 0.25));
    
    gl_FragColor = mix(texture2D(ghostTexture, vTexCoord), texture2D(myTexture, vGhostTexCoord), 0.2);
}
