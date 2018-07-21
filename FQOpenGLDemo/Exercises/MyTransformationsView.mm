//
//  MyTransformationsView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyTransformationsView.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@implementation MyTransformationsView

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    [super renderWithVertexFileName:@"transformations" fragmentFileName:@"transformations"];
}

- (void)genTexture:(GLuint)shaderProgram {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"jpg"];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 纹理单元0
    GLuint texLocation = glGetUniformLocation(shaderProgram, "ourTexture");
    glUniform1i(texLocation, 0); // 将0传递给uniform ourTexture,如果激活的是GL_TEXTURE1就传递1，以此类推
    
    // 纹理单元1
    GLKTextureInfo *textureInfo2 = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"awesomeface" ofType:@"png"] options:options error:nil];
    GLuint texLocation2 = glGetUniformLocation(shaderProgram, "anthorTexture");
    glUniform1i(texLocation2, 1);
    
    // 激活并绑定
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureInfo2.name);
    
    /*
     旋转矩阵
     
     沿X轴：
     {
         1.0,   0.0,   0.0,    0.0,
         0.0,   cos(), -sin(), 0.0,
         0.0,   sin(), cos(),  0.0,
         0.0,   0.0,   0.0,    1.0,
     }
     
     沿Y轴：
     {
         cos(),  0.0,  sin(), 0.0,
         0.0,    1.0,  0.0,   0.0,
         -sin(), 0.0,  cos(), 0.0,
         0.0,    0.0,  0.0,   1.0,
     }
     
     沿Z轴：
     {
         cos(),  -sin(), 0.0, 0.0,
         sin(),  cos(),  0.0, 0.0,
         0.0,    0.0,    1.0, 0.0,
         0.0,    0.0,    0.0, 1.0,
     }
     */
    
//    float scale[] = {
//        0.5, 0.0, 0.0, 0.0,
//        0.0, 0.5, 0.0, 0.0,
//        0.0, 0.0, 0.5, 0.0,
//        0.0, 0.0, 0.0, 1.0,
//    };
//
//    float rotation[] = {
//        cosf(M_PI_2), -sinf(M_PI_2), 0.0, 0.0,
//        sinf(M_PI_2), cosf(M_PI_2), 0.0, 0.0,
//        0.0, 0.0, 1.0, 0.0,
//        0.0, 0.0, 0.0, 1.0,
//    };
    
    glm::mat4 trans;
    trans = glm::rotate(trans, glm::radians(90.0f), glm::vec3(0.0f, 0.0f, 1.0f)); // 沿Z轴旋转90度
    trans = glm::scale(trans, glm::vec3(0.5f, 0.5f, 0.5f)); // 缩小0.5倍
    
    GLuint transformLoc = glGetUniformLocation(shaderProgram, "aTransform");
    glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
    
    // 环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    // 过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 多级渐远
    glGenerateMipmap(GL_TEXTURE_2D);
}

@end
