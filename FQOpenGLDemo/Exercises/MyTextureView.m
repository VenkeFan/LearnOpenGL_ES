//
//  MyTextureView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyTextureView.h"
#import "FQShaderHelper.h"
#import <GLKit/GLKit.h>
#include "JpegUtil.h"

@interface MyTextureView ()

@end

@implementation MyTextureView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"texture" fragmentFileName:@"texture"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    float vertices[] = {
        // ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
    };
    
    unsigned int indices[] = {
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    // 索引缓冲对象
    GLuint EBO;
    glGenBuffers(1, &EBO);
    
    // 复制索引数组到一个索引缓冲中
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 顶点缓冲对象
    GLuint VBO; // 缓冲ID
    glGenBuffers(1, &VBO); // 生成VBO对象
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO); // 将缓冲对象绑定到 GL_ARRAY_BUFFER 目标上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); // 把顶点数据从 CPU 内存复制到 GPU 的缓冲内存中
    
    // 着色器程序
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:vertexName fragmentFileName:fragmentName];
    if (shaderProgram == 0) {
        return;
    }
    
    glUseProgram(shaderProgram);
    
    GLuint positionLocation = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(positionLocation);
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (void*)0);
    
    GLuint colorLocation = glGetAttribLocation(shaderProgram, "aColor");
    glEnableVertexAttribArray(colorLocation);
    glVertexAttribPointer(colorLocation, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    GLuint texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLfloat *)NULL + 6);
    
    
    // 生成纹理
    [self genTexture:shaderProgram];
//    [self genTexture2:shaderProgram];
//    [self genTexture3:shaderProgram];
    
    // 设置背景色
    glClearColor(0.3, 0.0, 0.0, 1.0);
    // 清空渲染缓存的旧内容
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 绘制
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0); // 从索引缓冲渲染
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

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
