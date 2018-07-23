//
//  MyCoordinateSystemsView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/21.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyCoordinateSystemsView.h"
#import "FQShaderHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@implementation MyCoordinateSystemsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"coordinate" fragmentFileName:@"coordinate"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    // cube
    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
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
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (void*)0);
    
    GLuint texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    // 生成纹理
    [self genTexture:shaderProgram];
    
    // 设置背景色
    glClearColor(0.3, 0.0, 0.0, 1.0);
    
    // 清空颜色缓存和深度缓存的旧内容
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    {
        // 更多的3D
//        glm::vec3 cubePositions[] = {
//            glm::vec3( 0.0f,  0.0f,  0.0f),
//            glm::vec3( 2.0f,  5.0f, -15.0f),
//            glm::vec3(-1.5f, -2.2f, -2.5f),
//            glm::vec3(-3.8f, -2.0f, -12.3f),
//            glm::vec3( 2.4f, -0.4f, -3.5f),
//            glm::vec3(-1.7f,  3.0f, -7.5f),
//            glm::vec3( 1.3f, -2.0f, -2.5f),
//            glm::vec3( 1.5f,  2.0f, -2.5f),
//            glm::vec3( 1.5f,  0.2f, -1.5f),
//            glm::vec3(-1.3f,  1.0f, -1.5f)
//        };
//
//        for (int i = 0; i < 10; i++) {
//            glm::mat4 model;
//            model = glm::scale(model, glm::vec3(0.5f, 0.5f, 0.5f));
//            model = glm::translate(model, cubePositions[i]);
//            float angle = 20.f * i;
//            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.f, 0.3f, 0.5f));
//
//            glm::mat4 view;
//            view = glm::translate(view, glm::vec3(0.f, 0.f, -5.f));
//
//            glm::mat4 projection;
//            projection = glm::perspective(glm::radians(45.f), self.renderWidth/(float)self.renderHeight, 0.1f, 100.f);
//
//            glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
//            glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
//            glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
//
//
//            glDrawArrays(GL_TRIANGLES, 0, 36);
//        }
    }
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)genTexture:(GLuint)shaderProgram {
    [super genTexture:shaderProgram];
    
    // 模型矩阵
    glm::mat4 model;
    model = glm::rotate(model, glm::radians(30.f), glm::vec3(1.f, 1.f, 0.f));
    
    // 观察矩阵 (使场景向Z轴负方向移动，模拟摄像机向Z轴正方向移动)
    glm::mat4 view;
    view = glm::translate(view, glm::vec3(0.f, 0.f, -3.f));

    // 投影矩阵（透视投影）
    glm::mat4 projection;
    projection = glm::perspective(glm::radians(90.f), self.renderWidth/(float)self.renderHeight, 0.1f, 100.f);

    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
}

@end
