//
//  MyInstancedRenderView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/2.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyInstancedRenderView.h"
#import "FQShaderHelper.h"

@implementation MyInstancedRenderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"instancedRender" fragmentFileName:@"instancedRender"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    float vertices[] = {
        -0.5f,  1.0f, 0.0f, 1.0f, 0.0f,   // 右上
        -0.5f,  0.5f, 0.0f, 1.0f, 1.0f,   // 右下
        -1.0f,  0.5f, 0.0f, 0.0f, 1.0f,  // 左下
        -1.0f,  1.0f, 0.0f, 0.0f, 0.0f,  // 左上
    };

    unsigned int indices[] = {
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLuint program = [FQShaderHelper linkShaderWithVertexFileName:vertexName fragmentFileName:fragmentName];
    if (program == 0) {
        return;
    }
    glUseProgram(program);
    
    int posLoc = glGetAttribLocation(program, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (void *)0);
    
    int texPos = glGetAttribLocation(program, "aTexCoord");
    glEnableVertexAttribArray(texPos);
    glVertexAttribPointer(texPos, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    // 设置偏移量
    float offsets[] = {
        0.1f, -0.3f, 0.0f,
        0.7f, -0.7f, 0.0f,
        1.3f, -1.3f, 0.0f,
    };

    GLuint offsetVBO;
    glGenBuffers(1, &offsetVBO);
    glBindBuffer(GL_ARRAY_BUFFER, offsetVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(offsets), offsets, GL_STATIC_DRAW);

    int offsetPos = glGetAttribLocation(program, "offset");
    glEnableVertexAttribArray(offsetPos);
    glVertexAttribPointer(offsetPos, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    
    [super genTexture3:program];
    
    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /*
     参数 index ： 对应着色器中的索引。
     参数 divisor ：表示顶点属性的更新频率，每隔多少个实例将重新设置实例的该属性，例如设置为1，那么每个实例的属性都不一样，设置为2则每两个实例相同，3则每三个实例改变属性。
     */
    glVertexAttribDivisorEXT(offsetPos, 1);
    // instanceCount 用于设置渲染实例个数
    glDrawElementsInstancedEXT(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0, 3);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
