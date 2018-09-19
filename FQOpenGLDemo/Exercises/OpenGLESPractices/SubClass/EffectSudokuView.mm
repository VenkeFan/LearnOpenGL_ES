//
//  EffectSudokuView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/13.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "EffectSudokuView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface EffectSudokuView () {
    EAGLContext *_context;
    CAEAGLLayer *_myEAGLLayer;
    
    GLuint _frameBuffer;
    GLuint _colorRenderBuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
    
    GLuint _VAO;
    GLuint _program;
    GLuint _texture;
    
    // animation
    NSTimeInterval _duration;
    NSTimeInterval _timeOffset;
    glm::vec3 _fromValue;
    glm::vec3 _toValue;
    CFTimeInterval _lastSetp;
}

@end

@implementation EffectSudokuView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
        [self initializeLayer];
        [self initializeFrameAndColorRenderBuffer];
//        [self renderWithInstance];
        [self renderWithCycle];
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
    _context= [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)initializeLayer {
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

- (void)renderWithInstance {
    GLuint program = [FQShaderHelper linkShaderWithVertexFileName:@"effect_sudoku"
                                                 fragmentFileName:@"effect_sudoku"];
    if (program == 0) {
        return;
    }
    
    float vertices[] = {
        -1.0, 1.0,              // 左上
        -1.0, 1.0 / 3.0,        // 左下
        -1.0 / 3.0,  1.0 / 3.0, // 右下
        -1.0 / 3.0,  1.0        // 右上
    };
    
    float texCoords[] = {
        0.0, 1.0,
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0
    };
    
    float vertexOffsets[] = { // 顶点坐标偏移
        0.0,        0.0,
        2.0 / 3.0,  0.0,
        4.0 / 3.0,  0.0,
        
        0.0,        -2.0 / 3.0,
        2.0 / 3.0,  -2.0 / 3.0,
        4.0 / 3.0,  -2.0 / 3.0,
        
        0.0,        -4.0 / 3.0,
        2.0 / 3.0,  -4.0 / 3.0,
        4.0 / 3.0,  -4.0 / 3.0,
    };
    
    unsigned int indices[] = {
        0, 1, 2,
        0, 2, 3
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
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(texCoords) + sizeof(vertexOffsets), NULL, GL_STATIC_DRAW);
    
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices), sizeof(texCoords), texCoords);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(texCoords), sizeof(vertexOffsets), vertexOffsets);
    
    int posLoc = glGetAttribLocation(program, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(program, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)sizeof(vertices));
    
    int offsetLoc = glGetAttribLocation(program, "aOffset");
    glEnableVertexAttribArray(offsetLoc);
    glVertexAttribPointer(offsetLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)(sizeof(vertices) + sizeof(texCoords)));
    glVertexAttribDivisorEXT(offsetLoc, 1);
    
    glBindVertexArrayOES(0);
    
    GLuint texture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    glUseProgram(program);
    
    {
        // 不做任何变换，只是为了适配顶点着色器
        glm::mat4 model = glm::mat4();
        glUniformMatrix4fv(glGetUniformLocation(program, "model"), 1, GL_FALSE, glm::value_ptr(model));
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    glUniform1f(glGetUniformLocation(program, "myTexture"), 0);
    
    glBindVertexArrayOES(VAO);
    glDrawElementsInstancedEXT(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0, 9);
    glBindVertexArrayOES(0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderWithCycle {
    _program = [FQShaderHelper linkShaderWithVertexFileName:@"effect_sudoku"
                                           fragmentFileName:@"effect_sudoku"];
    if (_program == 0) {
        return;
    }
    
    float vertices[] = {
        -1.0, 1.0,              // 左上
        -1.0, 1.0 / 3.0,        // 左下
        -1.0 / 3.0,  1.0 / 3.0, // 右下
        -1.0 / 3.0,  1.0        // 右上
    };
    
    float texCoords[] = {
        0.0, 1.0,
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0
    };
    
    unsigned int indices[] = {
        0, 1, 2,
        0, 2, 3
    };
    
    glGenVertexArraysOES(1, &_VAO);
    glBindVertexArrayOES(_VAO);
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(texCoords), NULL, GL_STATIC_DRAW);
    
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices), sizeof(texCoords), texCoords);
    
    int posLoc = glGetAttribLocation(_program, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(_program, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLfloat *)sizeof(vertices));
    
    glBindVertexArrayOES(0);
    
    _texture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    glUseProgram(_program);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    glUniform1f(glGetUniformLocation(_program, "myTexture"), 0);
    
    glBindVertexArrayOES(_VAO);
//    glm::mat4 model;
//    float offset = 2 / 3.0;
//    int numberInRow = 3, rows = 3, instanceCount = numberInRow * rows;
//    for (int i = 0; i < instanceCount; i++) {
//        float x = i % numberInRow * offset;
//        float y = i / numberInRow * (-offset);
//
//        model = glm::mat4();
//        model = glm::translate(model, glm::vec3(x, y, 0.0));
//        glUniformMatrix4fv(glGetUniformLocation(program, "model"), 1, GL_FALSE, glm::value_ptr(model));
//        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
//    }
    
    glm::mat4 model = glm::mat4();
    glUniformMatrix4fv(glGetUniformLocation(_program, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    glBindVertexArrayOES(0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _duration = 4.0;
    _timeOffset = 0.0;
    _fromValue = glm::vec3();
    _toValue = glm::vec3(4.0 / 3.0,  -4.0 / 3.0, 0.0);
    _lastSetp = CACurrentMediaTime();

    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerStep:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)timerStep:(CADisplayLink *)displayLink {
    CFTimeInterval currentStep = CACurrentMediaTime();
    
    CFTimeInterval stepDuration = currentStep - _lastSetp;
    _lastSetp = currentStep;
    
    _timeOffset = MIN(_timeOffset + stepDuration, _duration);
    
    float time = _timeOffset / _duration;
    
    {
        glClear(GL_COLOR_BUFFER_BIT);
        
        glBindVertexArrayOES(_VAO);
        glm::vec3 translate = [self calculateStepLocalityWithFromValue:_fromValue toValue:_toValue time:time];
        
        glm::mat4 model = glm::mat4();
        model = glm::translate(model, translate); // glm::vec3(4.0 / 3.0,  -4.0 / 3.0, 0.0)
        glUniformMatrix4fv(glGetUniformLocation(_program, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        glBindVertexArrayOES(0);
        
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    if (_timeOffset >= _duration) {
        [displayLink invalidate];
        displayLink = nil;
    }
}

- (glm::vec3)calculateStepLocalityWithFromValue:(glm::vec3)fromValue toValue:(glm::vec3)toValue time:(float)time {
    float x = (toValue.x - fromValue.x) * time + fromValue.x;
    float y = (toValue.y - fromValue.y) * time + fromValue.y;
    float z = (toValue.z - fromValue.z) * time + fromValue.z;
    
    return glm::vec3(x, y, z);
}

@end
