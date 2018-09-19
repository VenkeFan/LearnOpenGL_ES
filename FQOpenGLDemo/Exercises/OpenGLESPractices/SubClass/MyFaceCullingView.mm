//
//  MyFaceCullingView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/8.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyFaceCullingView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"
#include "geometric.h"

@interface MyFaceCullingView () {
    GLuint _frameBuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyFaceCullingView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeLayer];
        [self initializeContext];
        [self initializeFrameAndRenderBuffer];
        [self initializeDepthBuffer];
        
        [self render];
    }
    return self;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderbuffer);
    _colorRenderbuffer = 0;
    glDeleteRenderbuffers(1, &_depthRenderbuffer);
    _depthRenderbuffer = 0;
}

#pragma mark - initialize

- (void)initializeContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)initializeLayer {
    self.myEAGLLayer.opaque = YES;
    self.myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}

- (void)initializeFrameAndRenderBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    [self initializeViewport];
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)initializeViewport {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    glViewport(0, 0, _renderWidth, _renderHeight);
}

- (void)initializeDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

#pragma mark - render

- (void)render {
    float cubeVertices[] = {
        // Back face
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, // Bottom-left
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f, // bottom-right
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, // bottom-left
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
        // Front face
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f, // top-right
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f, // top-right
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f, // top-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
        // Left face
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-right
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-left
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-left
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-right
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-right
        // Right face
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-left
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-right
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-right
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-left
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
        // Bottom face
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // top-right
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f, // top-left
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-left
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-right
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // top-right
        // Top face
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f  // bottom-left
    };
    
    GLuint cubeTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"marble"
                                                                                             ofType:@"jpg"]];
    
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:@"depthTest"
                                                       fragmentFileName:@"depthTest"];
    if (shaderProgram == 0) {
        return;
    }
    
    GLuint VAO;
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    
    int posLoc = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
    
    glm::mat4 model, view, projection;
    model = glm::rotate(model, glm::radians(30.0f), glm::vec3(1.0f, 1.0f, 0.0f));
    view = glm::translate(view, glm::vec3(0.f, 0.f, -3.f));
    projection = glm::perspective(glm::radians(80.f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
    
    glUseProgram(shaderProgram);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    {
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        
        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    }
    
    {
        glEnable(GL_CULL_FACE);
        /*
         GL_BACK：           只剔除背向面。
         GL_FRONT：          只剔除正向面。
         GL_FRONT_AND_BACK： 剔除正向面和背向面。
         */
        glCullFace(GL_FRONT);
        /*
         默认值是GL_CCW，它代表的是逆时针的环绕顺序，另一个选项是GL_CW，它代表的是顺时针顺序
         */
        glFrontFace(GL_CCW);
    }
    
    glBindVertexArrayOES(VAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, cubeTexture);
    glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
