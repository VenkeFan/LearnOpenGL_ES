//
//  EffectGhostView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/4.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "EffectGhostView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface EffectGhostView () {
    EAGLContext *_context;
    CAEAGLLayer *_myEAGLLayer;
    
    GLuint _frameBuffer;
    GLuint _colorRenderBuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
}

@end

@implementation EffectGhostView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
        [self initializeLyayer];
        [self initializeFrameAndColorRenderBuffer];
        [self render];
    }
    return self;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    if ([EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
        _context = nil;
    }
}

#pragma mark - initialize

- (void)initializeContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)initializeLyayer {
    _myEAGLLayer = (CAEAGLLayer *)self.layer;
    _myEAGLLayer.opaque = YES;
    _myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    _myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}

- (void)initializeFrameAndColorRenderBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myEAGLLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

#pragma mark - render

- (void)render {
    GLuint program = [FQShaderHelper linkShaderWithVertexFileName:@"effect_ghost"
                                                 fragmentFileName:@"effect_ghost"];
    if (program == 0) {
        return;
    }
    
    float vertices[] = {
        0.8f,  0.6f,      // 右上
        0.8f, -0.6f,      // 右下
        -0.8f, -0.6f,     // 左下
        -0.8f,  0.6f,     // 左上
    };
    
    float texCoords[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f
    };
    
    float ghostTexCoords[] = {
        0.85f, 0.85f,
        0.85f, 0.15f,
        0.15f, 0.15f,
        0.15f, 0.85f
    };
    
    unsigned int indices[] = {
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    GLuint VAO;
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(texCoords) + sizeof(ghostTexCoords), NULL, GL_STATIC_DRAW);
    
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices), sizeof(texCoords), texCoords);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(texCoords), sizeof(ghostTexCoords), ghostTexCoords);
    
    int posLoc = glGetAttribLocation(program, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (GLfloat *)NULL + 0);
    
    int texLoc = glGetAttribLocation(program, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (GLfloat *)sizeof(vertices));
    
    int ghostTexLoc = glGetAttribLocation(program, "aGhostTexCoord");
    glEnableVertexAttribArray(ghostTexLoc);
    glVertexAttribPointer(ghostTexLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (GLfloat *)(sizeof(vertices) + sizeof(texCoords)));
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
    
    GLuint texture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
    
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    glUseProgram(program);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1f(glGetUniformLocation(program, "myTexture"), 0);
    {
        // 很奇怪 1.jpg 这张图片纹理设置必须是以下值，否则纹理显示不出来
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1f(glGetUniformLocation(program, "ghostTexture"), 1);
    {
        // 很奇怪 1.jpg 这张图片纹理设置必须是以下值，否则纹理显示不出来
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    
    glBindVertexArrayOES(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glBindVertexArrayOES(0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
