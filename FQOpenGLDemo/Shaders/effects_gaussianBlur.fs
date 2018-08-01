#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

const float PI = 3.14159265;

float gaussianWeight(float x, float y, float sigma)
{
    float res1 = 1.0 / (2.0 * PI * sigma * sigma);
    float res2 = exp(-(x * x + y * y) / (2.0 * sigma * sigma));
    return res1 * res2;
}

void main()
{
    /*
     参考链接：http://www.ruanyifeng.com/blog/2012/11/gaussian_blur.html
     
     高斯模糊权重矩阵（模糊半径为1，sigma=1.5）
     mat3 weight = mat3(vec3(0.0947416, 0.118318, 0.0947416),
                        vec3(0.118318, 0.147761, 0.118318),
                        vec3(0.0947416, 0.118318, 0.0947416));
     */
    
    float factor[9];
    factor[0] = 0.0947416; factor[1] = 0.118318; factor[2] = 0.0947416;
    factor[3] = 0.118318; factor[4] = 0.147761; factor[5] = 0.118318;
    factor[6] = 0.0947416; factor[7] = 0.118318; factor[8] = 0.0947416;
    
//    vec2 texSize = vec2(700.0, 1333.0);
//    float horizontal = 1.0 / texSize.s;
//    float vertical = 1.0 / texSize.t;
    
    float horizontal = 1.0 / 150.0;
    float vertical = 1.0 / 150.0;
    vec4 finalColor = vec4(0.0);
    
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            // 当前点的周围的点
            float x = max(0.0, vTexcoord.x + horizontal * float(i));
            float y = max(0.0, vTexcoord.y + vertical * float(j));

            // 每个点乘以自己的权重值
            finalColor += (texture2D(image, vec2(x, y)) * factor[(i + 1) * 3 + (j + 1)]);
            
            
            {
//                /*
//                 使用高斯函数获取的权重后，图片会变暗
//                 https://blog.csdn.net/lovelyloulou/article/details/5485538
//                 */
//                float x = max(0.0, vTexcoord.x + horizontal * float(i));
//                float y = max(0.0, vTexcoord.y + vertical * float(j));
//                float weight = gaussianWeight(x, y, 1.5);
//                finalColor += (texture2D(image, vec2(x, y)) * weight);
            }
        }
    }
    
    // 最后除以因子的总和，这里是1.0
    finalColor /= 1.0;
    
    gl_FragColor = finalColor;
}
