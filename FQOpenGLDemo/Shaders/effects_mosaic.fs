#version 100

precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

const vec2 texSize = vec2(640.0, 640.0);
const vec2 mosaicSize = vec2(18.0, 18.0);

vec4 mosaic1()
{
    // 取值范围换算到图像尺寸大小
    vec2 xy = vec2(vTexcoord.x * texSize.x, vTexcoord.y * texSize.y);
    // 计算某一个小mosaic的中心坐标
    vec2 xyMosaic = vec2(floor(xy.x / mosaicSize.x) * mosaicSize.x,
                         floor(xy.y / mosaicSize.y) * mosaicSize.y) + 0.5 * mosaicSize;
    // 计算距离中心的长度
    vec2 delXY = xyMosaic - xy;
    float delL = length(delXY);
    // 换算回纹理坐标系
    vec2 uvMosaic = vec2(xyMosaic.x / texSize.x, xyMosaic.y / texSize.y);
    
    vec4 finalColor;
    if(delL < 0.5 * mosaicSize.x)
    {
        finalColor = texture2D(image, uvMosaic);
    }
    else
    {
        //finalColor = texture2D(image, vTexcoord);
        finalColor = vec4(0., 0., 0., 1.);
    }
    
    return finalColor;
}

vec4 mosaic2()
{
    // 取值范围换算到图像尺寸大小
    vec2 xy = vec2(vTexcoord.x * texSize.x, vTexcoord.y * texSize.y);
    // 计算某一个小mosaic的中心坐标
    vec2 xyMosaic = vec2(floor(xy.x / mosaicSize.x) * mosaicSize.x,
                         floor(xy.y / mosaicSize.y) * mosaicSize.y);
    // 换算回纹理坐标系
    vec2 uvMosaic = vec2(xyMosaic.x / texSize.x, xyMosaic.y / texSize.y);
    vec4 finalColor = texture2D(image, uvMosaic);
    
    return finalColor;
}

void main()
{
    gl_FragColor = mosaic2();
}
