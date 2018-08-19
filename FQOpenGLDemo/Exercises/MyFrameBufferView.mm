//
//  MyFrameBufferView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/3.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyFrameBufferView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#import "JpegUtil.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

@interface MyFrameBufferView () {
    GLuint _frameBuffer;
    GLuint _tmpFrameBuffer;

    GLuint _texture;

    GLuint _colorRenderBuffer;
    GLuint _textureColorBuffer;
    GLuint _textureDepthBuffer;
    GLuint _depthRenderBuffer;

    GLuint _program;
    GLuint _program1;

    GLsizei _renderWidth;
    GLsizei _renderHeight;
    
    GLuint _cubeVAO;
    GLuint _screenVAO;
    GLuint _cubeVBO;
    GLuint _screenVBO;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyFrameBufferView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _renderWidth = CGRectGetWidth(frame) * self.contentScaleFactor;
        _renderHeight = CGRectGetHeight(frame) * self.contentScaleFactor;

        [self initializeLayer];
        [self initializeContext];
        [self initializeFrameAndRenderBuffer];
        [self initializeTextureBuffer];

        [self render];
    }
    return self;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteFramebuffers(1, &_tmpFrameBuffer);
    _tmpFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    glDeleteRenderbuffers(1, &_textureColorBuffer);
    _textureColorBuffer = 0;
    glDeleteRenderbuffers(1, &_depthRenderBuffer);
    _depthRenderBuffer = 0;
}

#pragma mark - initialize

- (void)initializeContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }

    // 将当前上下文设置为我们创建的上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)initializeLayer {
    self.myEAGLLayer.opaque = YES;
    // 这个case中这里这样设置的话，纹理显示不全
//    self.myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}

- (void)initializeFrameAndRenderBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        printf("ERROR:FRAMEBUFFER:: _frameBuffer 帧缓存不完整！");
    }
}

- (void)initializeTextureBuffer {
    GLuint *textures = (GLuint *)malloc(sizeof(GLuint) * 1);
    glGenTextures(1, textures);

    _textureColorBuffer = textures[0];

    glBindTexture(GL_TEXTURE_2D, _textureColorBuffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _renderWidth, _renderHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glBindTexture(GL_TEXTURE_2D, 0);

    glGenFramebuffers(1, &_tmpFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _tmpFrameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureColorBuffer, 0);

//    glBindTexture(GL_TEXTURE_2D, _textureDepthBuffer);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _renderWidth, _renderHeight, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, NULL);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _textureDepthBuffer, 0);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        printf("ERROR:FRAMEBUFFER:: _tmpFrameBuffer 帧缓存不完整！");
    }
}

- (void)initializeViewport {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    glViewport(0, 0, _renderWidth, _renderHeight);
}

- (void)setupGLProgram {
    //    _program = [FQShaderHelper linkShaderWithVertexFileName:@"demo_vert"
    //                                           fragmentFileName:@"demo_mosaic"];
    
    _program = [FQShaderHelper linkShaderWithVertexFileName:@"framebuffers_screen"
                                           fragmentFileName:@"framebuffers_screen"];
}

- (void)setupGLProgram1 {
    //    _program1 = [FQShaderHelper linkShaderWithVertexFileName:@"demo_vert"
    //                                            fragmentFileName:@"demo_frag"];
    
    _program1 =  [FQShaderHelper linkShaderWithVertexFileName:@"framebuffers"
                                             fragmentFileName:@"framebuffers"];
}

#pragma mark - render

- (void)render {
    /*================================渲染到纹理================================*/
    {
        [self setupGLProgram1];
        glUseProgram(_program1);
        
        // bind to framebuffer and draw scene as we normally would to color texture
        glBindFramebuffer(GL_FRAMEBUFFER, _tmpFrameBuffer);

        glClearColor(1.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glViewport(0, 0, _renderWidth, _renderHeight);

        // cube VBO
        [self generateCubeVAO];
        [self setupTexure];
        
        glBindVertexArrayOES(_cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glUniform1i(glGetUniformLocation(_program1, "image"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArrayOES(0);
    }

    /*================================渲染到窗口================================*/
    {
        [self setupGLProgram];
        glUseProgram(_program);
        
        // now bind back to default framebuffer and draw a quad plane with the attached framebuffer color texture
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);

        glClearColor(1.0f, 1.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glViewport(0, 0, _renderWidth, _renderHeight);

        // screen VBO
        [self generateScreenVAO];
        
        glBindVertexArrayOES(_screenVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _textureColorBuffer);
        glUniform1i(glGetUniformLocation(_program, "image"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArrayOES(0);
    }

    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    glDeleteVertexArraysOES(1, &_cubeVAO);
    glDeleteBuffers(1, &_cubeVBO);
    glDeleteVertexArraysOES(1, &_screenVAO);
    glDeleteBuffers(1, &_screenVBO);
}

- (void)setupTexure {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];

    unsigned char *data;
    int size;
    int width;
    int height;

    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }

    // 创建纹理
    _texture = [self generateTexture:GL_RGB width:width height:height data:data];

    if (data) {
        free(data);
        data = NULL;
    }
}

- (void)generateCubeVAO {
    float cubeVertices[] = {
        // positions          // texture Coords
//        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
//        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//
//        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f

        1.0f,  1.0f, 0.0f, 1.0f, 1.0f,   // 右上
        1.0f, -1.0f, 0.0f, 1.0f, 0.0f,   // 右下
        -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,  // 左下
        -1.0f,  1.0f, 0.0f, 0.0f, 1.0f,   // 左上
        -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,  // 左下
        1.0f,  1.0f, 0.0f, 1.0f, 1.0f,   // 右上
    };
    
    glGenVertexArraysOES(1, &_cubeVAO);
    glBindVertexArrayOES(_cubeVAO);
    
    _cubeVBO = [self generateVBO:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW datSize:sizeof(cubeVertices) data:cubeVertices];

    int posLoc = glGetAttribLocation(_program1, "position");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 0);

    int texLoc = glGetAttribLocation(_program1, "texcoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
}

- (void)generateScreenVAO {
    float quadVertices[] = { // vertex attributes for a quad that fills the entire screen in Normalized Device Coordinates.
        // positions   // texCoords
//        -0.5f,  0.5f, 0.0f,  0.0f, 1.0f,
//        -0.5f, -0.5f, 0.0f,  0.0f, 0.0f,
//        0.5f, -0.5f, 0.0f,  1.0f, 0.0f,
//
//        -0.5f,  0.5f, 0.0f,  0.0f, 1.0f,
//        0.5f, -0.5f, 0.0f,  1.0f, 0.0f,
//        0.5f,  0.5f, 0.0f,  1.0f, 1.0f

        0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
        0.5f, -0.5f, 0.0f, 1.0f, 1.0f,   // 右下
        -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
        -0.5f,  0.5f, 0.0f, 0.0f, 0.0f,   // 左上
        -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
        0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
    };
    
    glGenVertexArraysOES(1, &_screenVAO);
    glBindVertexArrayOES(_screenVAO);
    
    _screenVBO = [self generateVBO:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW datSize:sizeof(quadVertices) data:quadVertices];

    int posLoc = glGetAttribLocation(_program, "position");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 0);

    int texLoc = glGetAttribLocation(_program, "texcoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
}

- (GLuint)generateVBO:(GLenum)target usage:(int)usage datSize:(int)datSize data:(void *)data {
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, datSize, data, usage);
    return vbo;
}

- (GLuint)generateTexture:(GLenum)format width:(int)width height:(int)height data:(void *)data {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
    
    {
        // 这个case中纹理的环绕方式和过滤方式必须按以下设置，否则有的图片渲染不出来，原因待查！！！！！！！！！
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    return texture;
}

@end
