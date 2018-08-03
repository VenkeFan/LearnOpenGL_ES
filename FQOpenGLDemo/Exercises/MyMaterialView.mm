//
//  MyMaterialView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/3.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyMaterialView.h"
#import "FQShaderHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@implementation MyMaterialView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"material" fragmentFileName:@"material"];
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
    
    GLuint normalPos = glGetAttribLocation(objProgram, "aNormal");
    glEnableVertexAttribArray(normalPos);
    glVertexAttribPointer(normalPos, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
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
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 光源坐标
    glm::vec3 lightPos(0.2f, 1.0f, 2.0f);
    
    {
        glUseProgram(objProgram);
        
        // 物体光照颜色
        glUniform3fv(glGetUniformLocation(objProgram, "lightPos"), 1, glm::value_ptr(lightPos));
        glUniform3f(glGetUniformLocation(objProgram, "lightColor"), 1.0f, 1.0f, 1.0f);
        glUniform3f(glGetUniformLocation(objProgram, "objectColor"), 1.0f, 0.5f, 0.31f);
        glUniform3f(glGetUniformLocation(objProgram, "viewPos"), 0.0f, 0.0f, 3.0f);
        
        // 材质
        glUniform3f(glGetUniformLocation(objProgram, "material.ambient"), 1.0f, 0.5f, 0.31f);
        glUniform3f(glGetUniformLocation(objProgram, "material.diffuse"), 1.0f, 0.5f, 0.31f);
        glUniform3f(glGetUniformLocation(objProgram, "material.specular"), 0.5f, 0.5f, 0.5f);
        glUniform1f(glGetUniformLocation(objProgram, "material.shininess"), 32.0f);
        
        // 光照属性
        glUniform3f(glGetUniformLocation(objProgram, "light.ambient"), 0.2, 0.2, 0.2);
        glUniform3f(glGetUniformLocation(objProgram, "light.diffuse"), 0.5f, 0.5f, 0.5f);
        glUniform3f(glGetUniformLocation(objProgram, "light.specular"), 1.0f, 1.0f, 1.0f);
        
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
