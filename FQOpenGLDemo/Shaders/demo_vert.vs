attribute vec3 position;
attribute vec2 texcoord;

varying vec2 vTexcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
//    gl_Position = projection * view * model * vec4(position, 1.0);
    
    gl_Position = vec4(position, 1.0);
    vTexcoord = texcoord;
}
