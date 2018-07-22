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
    [super genTexture:shaderProgram];
    
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
    
    // 三种创建应用矩阵的方式
    
    {
        // 1.
//        float scale[] = {
//            0.5, 0.0, 0.0, 0.0,
//            0.0, 0.5, 0.0, 0.0,
//            0.0, 0.0, 0.5, 0.0,
//            0.0, 0.0, 0.0, 1.0,
//        };
        
//        float rotation[] = { // 沿Z轴旋转90度
//            cosf(M_PI_2), -sinf(M_PI_2), 0.0, 0.0,
//            sinf(M_PI_2), cosf(M_PI_2), 0.0, 0.0,
//            0.0, 0.0, 1.0, 0.0,
//            0.0, 0.0, 0.0, 1.0,
//        };
//
//        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "aTransform"), 1, GL_FALSE, rotation);
    }
    
    {
        // 2.
        GLKMatrix4 scale = GLKMatrix4MakeScale(0.5f, 0.5f, 0.5f);
        GLKMatrix4 rotation = GLKMatrix4MakeRotation(M_PI_2, 0.f, 0.f, 1.f);
        
        GLKMatrix4 mat = GLKMatrix4Multiply(rotation, scale);
        
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "aTransform"), 1, GL_FALSE, mat.m);
    }
    
    {
        // 3.
//        glm::mat4 trans;
//        trans = glm::rotate(trans, glm::radians(90.0f), glm::vec3(0.0f, 0.0f, 1.0f)); // 沿Z轴旋转90度
//        trans = glm::scale(trans, glm::vec3(0.5f, 0.5f, 0.5f)); // 缩小0.5倍
//
//        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "aTransform"), 1, GL_FALSE, glm::value_ptr(trans));
    }
}

@end
