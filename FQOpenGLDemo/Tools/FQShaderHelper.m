//
//  FQShaderHelper.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQShaderHelper.h"

@implementation FQShaderHelper

/**
 链接着色器
 着色器程序对象(Shader Program Object)是多个着色器合并之后并最终链接完成的版本。
 如果要使用编译的着色器就必须把它们链接为一个着色器程序对象，然后在渲染对象的时候激活这个着色器程序
 
 @param vertexName 顶点着色器源码文件名
 @param fragmentName 片段着色器源码文件名
 @return 着色器程序
 */
+ (GLuint)linkShaderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    GLuint program;
    program = glCreateProgram(); // 创建着色器程序
    
    NSString* vertexFile = [[NSBundle mainBundle] pathForResource:vertexName ofType:@"vs"];
    NSString* fragmentFile = [[NSBundle mainBundle] pathForResource:fragmentName ofType:@"fs"];
    
    GLuint vertexShader = [self loadShaderWithFilePath:vertexFile type:GL_VERTEX_SHADER]; // 顶点着色器
    GLuint fragmentShader = [self loadShaderWithFilePath:fragmentFile type:GL_FRAGMENT_SHADER]; // 片段着色器
    
    if (vertexShader == 0 || fragmentShader == 0) {
        glDeleteProgram(program);
        return 0;
    }
    
    // 把编译的着色器附加到程序对象上（一个程序对象必须且只能有一个顶点着色器和一个片段着色器）
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 链接它们
    glLinkProgram(program);
    
    // 释放不再需要的shader
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    // 判断链接是否成功
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        GLint infoLength = 0;
        // 获取错误信息长度
        glGetShaderiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetProgramInfoLog(program, infoLength, NULL, infoLog);
            NSLog(@"Error linking program: %s", infoLog);
            free(infoLog);
        }
        glDeleteProgram(program);
        return 0;
    }
    
    return program;
}

/**
 *  编译着色器
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *
 *  @param filePath 着色器源码文件路径
 *  @param type 着色器类型
 */
+ (GLuint)loadShaderWithFilePath:(NSString *)filePath type:(GLenum)type {
    GLuint shader;
    shader = glCreateShader(type); // 创建着色器对象
    
    NSString *vertexString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *vertexShaderSource = (GLchar *)vertexString.UTF8String;
    glShaderSource(shader, 1, &vertexShaderSource, NULL); // 把着色器源码附加到着色器对象上
    glCompileShader(shader); // 编译
    
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success); // 判断编译是否成功
    if (success == GL_FALSE) {
        GLint infoLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength); // 获取错误信息长度
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog); // 获取错误信息
            NSLog(@"Error compiling shader %d: %s", type, infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

@end
