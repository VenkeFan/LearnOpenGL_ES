//
//  MyBasicLightingView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/23.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyBasicLightingView.h"
#import "FQShaderHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@implementation MyBasicLightingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"basicLighting" fragmentFileName:@"basicLighting"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    float vertices[] = {
        // -- 顶点坐标--        -- 法向量 --
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
    };
    
    GLuint VAO;
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 物体
    GLuint objProgram = [FQShaderHelper linkShaderWithVertexFileName:vertexName
                                                    fragmentFileName:fragmentName];
    if (objProgram == 0) {
        return;
    }
    
    GLuint posLoc = glGetAttribLocation(objProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (void *)0);
    
    // 光源
    GLuint lampProgram = [FQShaderHelper linkShaderWithVertexFileName:@"basicLighting_lamp"
                                                     fragmentFileName:@"basicLighting_lamp"];
    if (lampProgram == 0) {
        return;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    GLuint posLoc2 = glGetAttribLocation(lampProgram, "aPos");
    glEnableVertexAttribArray(posLoc2);
    glVertexAttribPointer(posLoc2, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (void *)0);
    
    glClearColor(0.3, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 光源坐标
    glm::vec3 lightPos(0.2f, 1.0f, 2.0f);
    
    {
        glUseProgram(objProgram);
        
        // 物体光照颜色
        glUniform3fv(glGetUniformLocation(objProgram, "lightPos"), 1, glm::value_ptr(lightPos));
        glUniform3f(glGetUniformLocation(objProgram, "lightColor"), 1.0f, 1.0f, 1.0f);
        glUniform3f(glGetUniformLocation(objProgram, "objectColor"), 1.0f, 0.5f, 0.31f);
        
        
        // 物体坐标
        glm::mat4 model, view, projection;
        
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
        model = glm::scale(model, glm::vec3(0.5f));
        view = glm::translate(view, glm::vec3(0.f, -0.5f, -3.f));
        projection = glm::perspective(glm::radians(45.f), self.renderWidth/(float)self.renderHeight, 0.1f, 100.f);
        
        glUniformMatrix4fv(glGetUniformLocation(objProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glUniformMatrix4fv(glGetUniformLocation(objProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
        glUniformMatrix4fv(glGetUniformLocation(objProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    {
        glUseProgram(lampProgram);
        
        // 光源坐标
        glm::mat4 model, view, projection;
        
        model = glm::translate(model, lightPos);
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
        model = glm::scale(model, glm::vec3(0.2f));
        
        view = glm::translate(view, glm::vec3(0.f, 0.f, -6.f));
        projection = glm::perspective(glm::radians(45.f), self.renderWidth/(float)self.renderHeight, 0.1f, 100.f);
        
        glUniformMatrix4fv(glGetUniformLocation(lampProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glUniformMatrix4fv(glGetUniformLocation(lampProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
        glUniformMatrix4fv(glGetUniformLocation(lampProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
