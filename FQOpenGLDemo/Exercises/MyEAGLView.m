//
//  MyEAGLView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyEAGLView.h"
#import <GLKit/GLKit.h>
#include "JpegUtil.h"

@interface MyEAGLView ()

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;

@end

@implementation MyEAGLView {
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _depthRenderbuffer;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
    }
    return self;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_frameBuffer);
    glDeleteRenderbuffers(1, &_renderBuffer);
    glDeleteRenderbuffers(1, &_depthRenderbuffer);
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    
}

- (void)initializeContext {
    // 设置渲染上下文
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    // 设置渲染窗口（图层）
    self.myEAGLLayer.opaque = YES;
    self.myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(FALSE),
                                            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    // 渲染缓存有：颜色缓存、深度缓存、模版缓存
    // 设置颜色缓存
    glGenRenderbuffers(1, &_renderBuffer);
    // 当第一次来绑定某个渲染缓存的时候，它会分配这个对象的存储空间并初始化，此后再调用这个函数的时候会将指定的渲染缓存对象绑定为当前的激活状态
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    // 渲染上下文绑定渲染窗口（图层）
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    // 设置帧缓存
    glGenFramebuffers(1, &_frameBuffer);
    // 当第一次来绑定某个帧缓存的时候，它会分配这个对象的存储空间并初始化，此后再调用这个函数的时候会将指定的帧缓存对象绑定为当前的激活状态
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 帧缓存装载渲染缓存的内容
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    // 渲染窗口
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    // 设置深度缓冲区
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    // 为当前绑定的渲染缓存对象分配图像数据空间
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
    glEnable(GL_DEPTH_TEST);
    
    // 设置颜色缓存为当前的渲染缓存
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        printf("ERROR:FRAMEBUFFER:: 帧缓存不完整！");
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
}

#pragma mark - 纹理

- (void)genTexture:(GLuint)shaderProgram {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 纹理单元1
    GLuint texLocation = glGetUniformLocation(shaderProgram, "ourTexture");
    glUniform1i(texLocation, 0); // 将0传递给uniform ourTexture,如果激活的是GL_TEXTURE1就传递1，以此类推
    
    // 纹理单元2
    GLKTextureInfo *textureInfo2 = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"awesomeface" ofType:@"png"] options:options error:nil];
    GLuint texLocation2 = glGetUniformLocation(shaderProgram, "anthorTexture");
    glUniform1i(texLocation2, 1);
    
    // 激活并绑定
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureInfo2.name);
    
    [self setupTexture];
}

- (void)genTexture2:(GLuint)shaderProgram {
    UIImage *img = [UIImage imageNamed:@"1.jpg"];
    // 将图片数据以RGBA的格式导出到textureData中
    CGImageRef imageRef = [img CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // 生成纹理
    GLuint texture;
    glGenTextures(1, &texture);
    
    // 在绑定纹理之前先激活纹理单元，OpenGL ES中最多可以激活8个通道。通道0是默认激活的，所以本例中这一句也可以不写
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    glUniform1i(glGetUniformLocation(shaderProgram, "ourTexture"), 0);
    
    [self setupTexture];
}

- (void)genTexture3:(GLuint)shaderProgram {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    
    unsigned char *textureData;
    int size;
    int width;
    int height;
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &textureData, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    
    // 生成纹理
    GLuint texture;
    glGenTextures(1, &texture);
    
    // 在绑定纹理之前先激活纹理单元，OpenGL ES中最多可以激活8个通道。通道0是默认激活的，所以本例中这一句也可以不写
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    /*
     参数 target ：指定纹理单元的类型，二维纹理需要指定为GL_TEXTURE_2D
     参数 level：指定纹理单元的层次，非mipmap纹理level设置为0，mipmap纹理设置为纹理的层级
     参数 internalFormat：指定OpenGL ES是如何管理纹理单元中数据格式的
     参数 width：指定纹理单元的宽度
     参数 height：指定纹理单元的高度
     参数 border：指定纹理单元的边框，如果包含边框取值为1，不包含边框取值为0
     参数 format：指定data所指向的数据的格式
     参数 type：指定data所指向的数据的类型
     参数 data：实际指向的数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)width, (GLsizei)height, 0, GL_RGB, GL_UNSIGNED_BYTE, textureData);
    
    glUniform1i(glGetUniformLocation(shaderProgram, "ourTexture"), 0);
    
    if (textureData) {
        free(textureData);
        textureData = NULL;
    }
    
    [self setupTexture];
}

- (void)setupTexture {
    // 环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // 过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 多级渐远
    glGenerateMipmap(GL_TEXTURE_2D); // 为当前绑定的纹理自动生成所有需要的多级渐远纹理
    
    //    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); // 切换多级渐远纹理级别
}

@end
