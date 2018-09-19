//
//  MyLightingMapsView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/3.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyLightingMapsView.h"
#import "FQShaderHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"
#include "PngUtil.h"

@implementation MyLightingMapsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"lightingMaps" fragmentFileName:@"lightingMaps"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    float vertices[] = {
        // positions          // normals           // texture coords
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
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
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (void *)0);
    
    GLuint normalPos = glGetAttribLocation(objProgram, "aNormal");
    glEnableVertexAttribArray(normalPos);
    glVertexAttribPointer(normalPos, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    GLuint texPos = glGetAttribLocation(objProgram, "aTexCoord");
    glEnableVertexAttribArray(texPos);
    glVertexAttribPointer(texPos, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLfloat *)NULL + 6);
    
    // 光源
    GLuint lampProgram = [FQShaderHelper linkShaderWithVertexFileName:@"basicLighting_lamp"
                                                     fragmentFileName:@"basicLighting_lamp"];
    if (lampProgram == 0) {
        return;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    GLuint posLoc2 = glGetAttribLocation(lampProgram, "aPos");
    glEnableVertexAttribArray(posLoc2);
    glVertexAttribPointer(posLoc2, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (void *)0);
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 光源坐标
    glm::vec3 lightPos(0.2f, 1.0f, 2.0f);
    
    {
        glUseProgram(objProgram);
        
        // 摄像机坐标
        glUniform3f(glGetUniformLocation(objProgram, "viewPos"), 0.0f, 0.0f, 3.0f);
        
        // 材质
        {
            // 为什么光照这几章和文章里的效果不一致呢？？？
            GLuint texture0 = [self generateTexture:[[NSBundle mainBundle] pathForResource:@"container2" ofType:@"png"]];
            GLuint texture1 = [self generateTexture:[[NSBundle mainBundle] pathForResource:@"lighting_maps_specular_color" ofType:@"png"]];
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, texture0);
            glUniform1i(glGetUniformLocation(objProgram, "material.diffuse"), 0);
            
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, texture1);
            glUniform1i(glGetUniformLocation(objProgram, "material.specular"), 1);
        }
        
        glUniform1f(glGetUniformLocation(objProgram, "material.shininess"), 64.0f);
        
        // 光照属性
        glUniform3fv(glGetUniformLocation(objProgram, "light.position"), 1, glm::value_ptr(lightPos));
        glUniform3f(glGetUniformLocation(objProgram, "light.ambient"), 0.2f, 0.2f, 0.2f);
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

- (GLuint)generateTexture:(NSString *)path {
    pic_data data;
    
    // 加载纹理
    if (read_png_file(path.UTF8String, &data) < 0) {
        printf("%s\n", "decode fail");
    }
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    if (data.flag > 0) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)data.width, (GLsizei)data.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data.rgba);
    } else {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)data.width, (GLsizei)data.height, 0, GL_RGB, GL_UNSIGNED_BYTE, data.rgba);
    }
    
    if (data.rgba) {
        free(data.rgba);
        data.rgba = NULL;
    }
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}

@end
