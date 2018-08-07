//
//  MyTextureView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyTextureView.h"
#import "FQShaderHelper.h"

#define kUseEBO     1

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
#if kUseEBO
        // ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
#else
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下

        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f,    // 左上
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
#endif
    };
    
#if kUseEBO
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
#endif
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
    [super genTexture:shaderProgram];
//    [super genTexture2:shaderProgram];
//    [super genTexture3:shaderProgram];
    
    // 设置背景色
    glClearColor(0.3, 0.0, 0.0, 1.0);
    // 清空渲染缓存的旧内容
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 绘制
    /*
     参数 mode ：指定绘制图元的类型。例如：GL_POINTS、GL_LINES。
     参数 count ：为绘制图元的数量乘上一个图元的顶点数。
     参数 type ：为索引值的类型，只能是下列值之一：GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT。
     参数 indices ：指向索引存贮位置的指针。
     */
#if kUseEBO
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0); // 从索引缓冲渲染
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
