#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

const float PI = 3.14159265;
const float uD = 80.0; // 旋转角度
const float uR = 0.5; // 旋转半径

void main()
{
    ivec2 ires = ivec2(640, 640); // 分辨率（这里使用任意大于0的向量都行，比如单位向量 ivec2(1, 1)）
    float Res = float(ires.s); // 这里取s、t 都能得到同样的结果
    
    vec2 st = vTexcoord; // 纹理坐标
    float Radius = uR * Res; // 旋转半径
    
    vec2 xy = Res * st; // 转为分辨率
    
    // 计算该坐标点距中心点的距离
    vec2 dxy = xy - vec2(Res/2., Res/2.);
    float r = length(dxy);
    
    // (1.0-(r/Radius)*(r/Radius)) 抛物线递减因子
    float beta = atan(dxy.y, dxy.x) + radians(uD) * 2.0 * (1.0-(r/Radius)*(r/Radius));//(1.0 - r/Radius);
    
    vec2 xy1 = xy;
    if(r <= Radius)
    {
        xy1 = Res/2. + r*vec2(cos(beta), sin(beta));
    }
    
    st = xy1/Res; // 转为纹理坐标
    
    vec3 irgb = texture2D(image, st).rgb;
    
    gl_FragColor = vec4( irgb, 1.0 );
}
