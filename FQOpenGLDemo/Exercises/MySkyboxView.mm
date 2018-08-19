//
//  MySkyboxView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/13.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MySkyboxView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#import "JpegUtil.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface MySkyboxView () {
    EAGLContext *_context;
    CAEAGLLayer *_myEAGLLayer;
    
    GLuint _frameBuffer;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
    
    GLuint _cubemapTexture;
    GLuint _texture;
    
    GLuint _skyboxVAO;
    GLuint _cubemapVAO;
}

@end

@implementation MySkyboxView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addGestures];
        
        [self initializeContext];
        [self initializeLayer];
        [self initializeFrameAndRenderBuffer];
        [self initializeDepthBuffer];
        
        [self render];
    }
    return self;
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
    
    {
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
        glViewport(0, 0, _renderWidth, _renderHeight);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)initializeDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

#pragma mark - render

- (void)render {
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    glm::mat4 model;
    glm::mat4 view;
    glm::mat4 projection;
    
    {
        // cube
        
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(1.f, 1.f, 0.f));
        view = glm::translate(view, glm::vec3(0.f, 0.f, -3.f));
        projection = glm::perspective(glm::radians(90.0f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
        
        GLuint cubeShader = [FQShaderHelper linkShaderWithVertexFileName:@"cubemap" fragmentFileName:@"cubemap"];
        [self loadTexture];
        
        {
            [self cubeVertex];
            
            glBindVertexArrayOES(_cubemapVAO);
            
            int posLoc = glGetAttribLocation(cubeShader, "aPos");
            glEnableVertexAttribArray(posLoc);
            glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (GLfloat *)NULL + 0);
            
            int texLoc = glGetAttribLocation(cubeShader, "aTexCoords");
            glEnableVertexAttribArray(texLoc);
            glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (GLfloat *)NULL + 3);
            
            glBindVertexArrayOES(0);
        }
        
        {
            glUseProgram(cubeShader);
            
            glUniformMatrix4fv(glGetUniformLocation(cubeShader, "model"), 1, GL_FALSE, glm::value_ptr(model));
            glUniformMatrix4fv(glGetUniformLocation(cubeShader, "view"), 1, GL_FALSE, glm::value_ptr(view));
            glUniformMatrix4fv(glGetUniformLocation(cubeShader, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
        }
        
        glBindVertexArrayOES(_cubemapVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glUniform1f(glGetUniformLocation(cubeShader, "myTexture"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindVertexArrayOES(0);
    }
    
    {
        // skybox
        
        glDepthFunc(GL_LEQUAL);
        
        view = glm::translate(view, glm::vec3(0.f, 0.f, -3.f));
        projection = glm::perspective(glm::radians(10.0f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
        
        GLuint skyboxShader = [FQShaderHelper linkShaderWithVertexFileName:@"skybox" fragmentFileName:@"skybox"];
        [self loadCubemap];
        
        {
            [self skyboxVertex];
            
            glBindVertexArrayOES(_skyboxVAO);
            
            int posLoc = glGetAttribLocation(skyboxShader, "aPos");
            glEnableVertexAttribArray(posLoc);
            glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (GLfloat *)NULL + 0);
            
            glBindVertexArrayOES(0);
        }
        
        {
            glUseProgram(skyboxShader);
            
            glUniformMatrix4fv(glGetUniformLocation(skyboxShader, "view"), 1, GL_FALSE, glm::value_ptr(view));
            glUniformMatrix4fv(glGetUniformLocation(skyboxShader, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
        }
        
        glBindVertexArrayOES(_skyboxVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, _cubemapTexture);
        glUniform1f(glGetUniformLocation(skyboxShader, "skybox"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        glBindVertexArrayOES(0);
        
        glDepthFunc(GL_LESS);
    }
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)cubeVertex {
    float cubeVertices[] = {
        // positions          // texture Coords
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
    
    GLuint VBO;
    [self generateVAO:&_cubemapVAO
                  vbo:&VBO
               target:GL_ARRAY_BUFFER
                usage:GL_STATIC_DRAW
             dataSize:sizeof(cubeVertices)
                 data:cubeVertices];
}

- (void)skyboxVertex {
    float skyboxVertices[] = {
        // positions
        -1.0f,  1.0f, -1.0f,
        -1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
        -1.0f,  1.0f, -1.0f,
        1.0f,  1.0f, -1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
        1.0f, -1.0f,  1.0f
    };
    
    GLuint VBO;
    [self generateVAO:&_skyboxVAO
                  vbo:&VBO
               target:GL_ARRAY_BUFFER
                usage:GL_STATIC_DRAW
             dataSize:sizeof(skyboxVertices)
                 data:skyboxVertices];
}


/**
 loads a cubemap texture from 6 individual texture faces
 order:
 +X (right)
 -X (left)
 +Y (top)
 -Y (bottom)
 +Z (front)
 -Z (back)
 */
- (void)loadCubemap {
    NSArray<NSString *> *faces = @[@"right.jpg",
                                   @"left.jpg",
                                   @"top.jpg",
                                   @"bottom.jpg",
                                   @"front.jpg",
                                   @"back.jpg"];
    
    glGenTextures(1, &_cubemapTexture);
    glBindTexture(GL_TEXTURE_2D, _cubemapTexture);
    
    unsigned char *data;
    int size;
    int width;
    int height;
    
    for (int i = 0; i < faces.count; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:faces[i] ofType:nil];
        
        if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
            printf("%s\n", "decode fail");
        }
        
        if (data) {
            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, (GLsizei)width, (GLsizei)height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        }
    }
    
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
}

- (void)loadTexture {
    _texture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"marble" ofType:@"jpg"]];
}

- (void)generateVAO:(GLuint *)vao
                vbo:(GLuint *)vbo
             target:(GLenum)target
              usage:(int)usage
           dataSize:(int)dataSize
               data:(void *)data {
    glGenVertexArraysOES(1, vao);
    glBindVertexArrayOES(*vao);
    
    glGenBuffers(1, vbo);
    glBindBuffer(target, *vbo);
    glBufferData(target, dataSize, data, usage);
    
    glBindVertexArrayOES(0);
}

#pragma mark - GestureRecognizer

- (void)addGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnPan:)];
    [self addGestureRecognizer:panGesture];
}

- (void)selfOnPan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint velocity = [gestureRecognizer velocityInView:self];
        CGPoint location = [gestureRecognizer locationInView:self];
        NSLog(@"translation: (%f, %f) / location: (%f, %f) \n", translation.x, translation.y, location.x, location.y);
        
        if (ABS(translation.x) < ABS(translation.y)) {
            if (translation.y > 0) {
                NSLog(@"bottom");
            } else {
                NSLog(@"top");
            }
            
        } else if (translation.x < 0) {
            NSLog(@"left");
        } else {
            NSLog(@"right");
        }
        
        
    }
}

@end
