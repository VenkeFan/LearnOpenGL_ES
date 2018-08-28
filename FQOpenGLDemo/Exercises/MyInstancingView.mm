//
//  MyInstancingView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/27.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyInstancingView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface MyInstancingView () {
    EAGLContext *_context;
    CAEAGLLayer *_myEAGLLayer;
    
    GLuint _frameBuffer;
    GLuint _colorRenderBuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
}

@end

@implementation MyInstancingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
        [self initializeLayer];
        [self initializeFrameAndRenderBuffer];
        [self render];
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - initialize

- (void)initializeContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)initializeLayer {
    _myEAGLLayer = (CAEAGLLayer *)self.layer;
    _myEAGLLayer.opaque = YES;
    _myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    _myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}

- (void)initializeFrameAndRenderBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myEAGLLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    [self initializeViewport];
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)initializeViewport {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    glViewport(0, 0, _renderWidth, _renderHeight);
}

#pragma mark - render

- (void)render {
    GLuint program = [FQShaderHelper linkShaderWithVertexFileName:@"instance"
                                                 fragmentFileName:@"instance"];
    if (program == 0) {
        return;
    }
    
    float quadVertices[] = {
        // positions     // colors
        -0.05f,  0.05f,  1.0f, 0.0f, 0.0f,
        0.05f, -0.05f,  0.0f, 1.0f, 0.0f,
        -0.05f, -0.05f,  0.0f, 0.0f, 1.0f,
        
        -0.05f,  0.05f,  1.0f, 0.0f, 0.0f,
        0.05f, -0.05f,  0.0f, 1.0f, 0.0f,
        0.05f,  0.05f,  0.0f, 1.0f, 1.0f
    };
    
    GLuint VAO;
    {
        glGenVertexArraysOES(1, &VAO);
        glBindVertexArrayOES(VAO);
        
        {
            GLuint VBO;
            glGenBuffers(1, &VBO);
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
            glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
            
            int posLoc = glGetAttribLocation(program, "aPos");
            glEnableVertexAttribArray(posLoc);
            glVertexAttribPointer(posLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (GLfloat *)NULL + 0);
            
            int colorLoc = glGetAttribLocation(program, "aColor");
            glEnableVertexAttribArray(colorLoc);
            glVertexAttribPointer(colorLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (GLfloat *)NULL + 2);
            
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        }
        
        {
            glm::vec2 translations[100];
            int index = 0;
            float offset = 0.1f;
            for (int y = -10; y < 10; y += 2)
            {
                for (int x = -10; x < 10; x += 2)
                {
                    glm::vec2 translation;
                    translation.x = (float)x / 10.0f + offset;
                    translation.y = (float)y / 10.0f + offset;
                    translations[index++] = translation;
                }
            }
            
            GLuint instanceVBO;
            glGenBuffers(1, &instanceVBO);
            glBindBuffer(GL_ARRAY_BUFFER, instanceVBO);
            glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec2) * 100, &translations[0], GL_STATIC_DRAW);
            
            int offsetLoc = glGetAttribLocation(program, "aOffset");
            glEnableVertexAttribArray(offsetLoc);
            glVertexAttribPointer(offsetLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)NULL + 0);
            glVertexAttribDivisorEXT(offsetLoc, 1);
            
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        }
        
        glBindVertexArrayOES(0);
    }
    
    {
        // global config
        glViewport(0, 0, _renderWidth, _renderHeight);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
        
        glClearColor(0.3, 0.3, 0.3, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    {
        // draw
        glUseProgram(program);
        
        glBindVertexArrayOES(VAO);
        glDrawArraysInstancedEXT(GL_TRIANGLES, 0, 6, 100);
        glBindVertexArrayOES(0);
        
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

@end
