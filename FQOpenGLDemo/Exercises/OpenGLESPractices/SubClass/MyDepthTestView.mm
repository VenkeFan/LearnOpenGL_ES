//
//  MyDepthTestView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/6.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyDepthTestView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "JpegUtil.h"
#import "PngUtil.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface MyDepthTestView () {
    GLuint _frameBuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;

    GLsizei _renderWidth;
    GLsizei _renderHeight;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyDepthTestView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
        [self initializeLayer];
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
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(FALSE),
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

- (void)initializeDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)initializeViewport {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    glViewport(0, 0, _renderWidth, _renderHeight);
}

#pragma mark - render

- (void)render {
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
    float floorVertices[] = {
        // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
        5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f,  5.0f,  0.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,

        5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
        5.0f, -0.5f, -5.0f,  2.0f, 2.0f
    };
    GLuint floorTexture = [self genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"wood"
                                                                                   ofType:@"png"]];
    GLuint cubeTexture = [self genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"marble"
                                                                                  ofType:@"jpg"]];
    
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:@"depthTest" fragmentFileName:@"depthTest"];
    if (shaderProgram == 0) {
        return;
    }
    glUseProgram(shaderProgram);
    
    // cube VBO
    GLuint cubeVAO;
    glGenVertexArraysOES(1, &cubeVAO);
    glBindVertexArrayOES(cubeVAO);
    
    GLuint cubeVBO;
    glGenBuffers(1, &cubeVBO);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);

    int posLoc = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL);

    int texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
    
    // floor VBO
    GLuint floorVAO;
    glGenVertexArraysOES(1, &floorVAO);
    glBindVertexArrayOES(floorVAO);
    
    GLuint floorVBO;
    glGenBuffers(1, &floorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, floorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(floorVertices), floorVertices, GL_STATIC_DRAW);

    int posLoc2 = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc2);
    glVertexAttribPointer(posLoc2, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL);

    int texLoc2 = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc2);
    glVertexAttribPointer(texLoc2, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
    
    // 全局配置
    glEnable(GL_DEPTH_TEST); // 启用深度测试，默认是禁用的
    /*
     GL_ALWAYS      永远通过深度测试
     GL_NEVER       永远不通过深度测试
     GL_LESS        在片段深度值小于缓冲的深度值时通过测试
     GL_EQUAL       在片段深度值等于缓冲区的深度值时通过测试
     GL_LEQUAL      在片段深度值小于等于缓冲区的深度值时通过测试
     GL_GREATER     在片段深度值大于缓冲区的深度值时通过测试
     GL_NOTEQUAL    在片段深度值不等于缓冲区的深度值时通过测试
     GL_GEQUAL      在片段深度值大于等于缓冲区的深度值时通过测试
     */
    glDepthFunc(GL_LESS);
//    glDepthMask(GL_FALSE); // 禁用深度缓冲的写入
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glm::mat4 model;
    model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
    glm::mat4 view;
    view = glm::translate(view, glm::vec3(0.f, 0.f, -4.f));
    glm::mat4 projection;
    projection = glm::perspective(glm::radians(90.f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    glBindVertexArrayOES(cubeVAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, cubeTexture);
    glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
    model = glm::translate(model, glm::vec3(-0.3f, 0.0f, -1.0f));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    model = glm::mat4();
    model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
    model = glm::translate(model, glm::vec3(0.3f, 0.0f, 1.0f));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
    
    glBindVertexArrayOES(floorVAO);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, floorTexture);
    glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(glm::mat4()));
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayOES(0);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    glDeleteVertexArraysOES(1, &cubeVAO);
    glDeleteVertexArraysOES(1, &floorVAO);
    glDeleteBuffers(1, &cubeVBO);
    glDeleteBuffers(1, &floorVBO);
}

#pragma mark - texture

- (GLuint)genTextureWithPath:(NSString *)path {
    BOOL isPng = [path.lastPathComponent.lowercaseString containsString:@"png"];
    BOOL hasAlpha = NO;
    
    unsigned char *data;
    int size, width, height;
    
    GLuint texture;
    glGenTextures(1, &texture);
    
    if (isPng) {
        pic_data picData;
        
        if (read_png_file(path.UTF8String, &picData) < 0) {
            return -1;
        }
        
        data = picData.rgba;
        width = picData.width;
        height = picData.height;
        hasAlpha = picData.flag > 0;
        
    } else {
        if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
            return -1;
        }
        
        hasAlpha = NO;
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    GLenum format = hasAlpha ? GL_RGBA : GL_RGB;
    glTexImage2D(GL_TEXTURE_2D, 0, format, (GLsizei)width, (GLsizei)height, 0, format, GL_UNSIGNED_BYTE, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}

@end
