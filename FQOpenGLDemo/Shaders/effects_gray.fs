#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721); // GPUImage中使用的灰度变换因子
//const highp vec3 luminanceWeighting = vec3(0.299, 0.587, 0.114);
//const highp vec3 luminanceWeighting = vec3(1.0, 1.0, 1.0);

/*
 转换为灰度的方法：
 1.浮点算法：Gray=R*0.3+G*0.59+B*0.11
 2.整数方法：Gray=(R*30+G*59+B*11)/100
 3.移位方法：Gray =(R*76+G*151+B*28)>>8;
 4.平均值法：Gray=(R+G+B)/3;
 5.仅取绿色：Gray=G；
 */

void main()
{
    vec4 color = texture2D(image, vTexcoord);
    // 灰度
    float luminance = dot(color.rgb, luminanceWeighting);
    // 用灰度替换原来的RGB色值
    color = vec4(vec3(luminance), color.a);
    gl_FragColor = color;
}


//// GPUImageGrayscaleFilter
//precision highp float;
//
//varying vec2 textureCoordinate;
//
//uniform sampler2D inputImageTexture;
//
//const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
//
//void main()
//{
//    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
//    float luminance = dot(textureColor.rgb, W);
//    
//    gl_FragColor = vec4(vec3(luminance), textureColor.a);
//}
