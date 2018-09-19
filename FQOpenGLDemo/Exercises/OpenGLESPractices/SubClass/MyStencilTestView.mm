//
//  MyStencilTestView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/7.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyStencilTestView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "JpegUtil.h"
#import "PngUtil.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

// https://learnopengl-cn.github.io/04%20Advanced%20OpenGL/02%20Stencil%20testing/

@interface MyStencilTestView () {
    GLuint _frameBuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthStencilRenderbuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyStencilTestView

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
        [self initializeDepthAndStencilBuffer];
        
        [self render];
    }
    return self;
}

- (void)dealloc {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderbuffer);
    _colorRenderbuffer = 0;
    glDeleteRenderbuffers(1, &_depthStencilRenderbuffer);
    _depthStencilRenderbuffer = 0;
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

- (void)initializeViewport {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    glViewport(0, 0, _renderWidth, _renderHeight);
}

- (void)initializeDepthAndStencilBuffer {
    glGenRenderbuffers(1, &_depthStencilRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthStencilRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthStencilRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthStencilRenderbuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
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
    
    GLuint borderProgram = [FQShaderHelper linkShaderWithVertexFileName:@"depthTest" fragmentFileName:@"stencil_border"];
    if (borderProgram == 0) {
        return;
    }
    
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
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glEnable(GL_STENCIL_TEST);
    /*
     func：设置模板测试函数(Stencil Test Function)。这个测试函数将会应用到已储存的模板值上和glStencilFunc函数的ref值上。可用的选项有：GL_NEVER、GL_LESS、GL_LEQUAL、GL_GREATER、GL_GEQUAL、GL_EQUAL、GL_NOTEQUAL和GL_ALWAYS。它们的语义和深度缓冲的函数类似。
     ref：设置了模板测试的参考值(Reference Value)。模板缓冲的内容将会与这个值进行比较。
     mask：设置一个掩码，它将会与参考值和储存的模板值在测试比较它们之前进行与(AND)运算。初始情况下所有位都为1。
     */
    glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
    /*
     sfail：模板测试失败时采取的行为。
     dpfail：模板测试通过，但深度测试失败时采取的行为。
     dppass：模板测试和深度测试都通过时采取的行为。
     
     GL_KEEP            保持当前储存的模板值
     GL_ZERO            将模板值设置为0
     GL_REPLACE         将模板值设置为glStencilFunc函数设置的ref值
     GL_INCR            如果模板值小于最大值则将模板值加1
     GL_INCR_WRAP       与GL_INCR一样，但如果模板值超过了最大值则归零
     GL_DECR            如果模板值大于最小值则将模板值减1
     GL_DECR_WRAP       与GL_DECR一样，但如果模板值小于0则将其设置为最大值
     GL_INVERT          按位翻转当前的模板缓冲值
     */
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    // 坐标转换
    glm::mat4 model;
    model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
    glm::mat4 view;
    view = glm::translate(view, glm::vec3(0.f, 0.f, -4.f));
    glm::mat4 projection;
    projection = glm::perspective(glm::radians(90.f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
    
    glUseProgram(borderProgram);
    glUniformMatrix4fv(glGetUniformLocation(borderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(borderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    glUseProgram(shaderProgram);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    {
        // draw floor as normal, but don't write the floor to the stencil buffer, we only care about the containers. We set its mask to 0x00 to not write to the stencil buffer.
        glStencilMask(0x00); // 禁用模板缓冲写入
        
        glBindVertexArrayOES(floorVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, floorTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(glm::mat4()));
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArrayOES(0);
    }
    
    {
        // 1. 在绘制（需要添加轮廓的）物体之前，将模板函数设置为GL_ALWAYS，每当物体的片段被渲染时，将模板缓冲更新为1
        glStencilFunc(GL_ALWAYS, 1, 0xFF); // 所有的片段都应该更新模板缓冲
        glStencilMask(0xFF); // 启用模板缓冲写入
        
        // 2. 渲染物体。
        glBindVertexArrayOES(cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, cubeTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        model = glm::translate(model, glm::vec3(-0.3f, 0.0f, -1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        model = glm::mat4();
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
        model = glm::translate(model, glm::vec3(0.1f, 0.0f, 1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArrayOES(0);
    }
    
    {
        // 3. 禁用模板写入以及深度测试。
        glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
        glStencilMask(0x00);
        glDisable(GL_DEPTH_TEST);
        
        // 4. 缩放
        float scale = 1.1;
        
        // 5. 使用一个不同的片段着色器，输出一个单独的（边框）颜色。
        glUseProgram(borderProgram);
        
        // 6. 再次绘制物体，但只在它们片段的模板值不等于1时才绘制。
        glBindVertexArrayOES(cubeVAO);
        glBindTexture(GL_TEXTURE_2D, cubeTexture);
        model = glm::mat4();
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
        model = glm::translate(model, glm::vec3(-0.3f, 0.0f, -1.0f));
        model = glm::scale(model, glm::vec3(scale, scale, scale));
        glUniformMatrix4fv(glGetUniformLocation(borderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        model = glm::mat4();
        model = glm::rotate(model, glm::radians(30.f), glm::vec3(0.f, 1.f, 0.f));
        model = glm::translate(model, glm::vec3(0.1f, 0.0f, 1.0f));
        model = glm::scale(model, glm::vec3(scale, scale, scale));
        glUniformMatrix4fv(glGetUniformLocation(borderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArrayOES(0);
        
        // 7. 再次启用模板写入和深度测试
        glStencilMask(0xFF);
        glEnable(GL_DEPTH_TEST);
    }
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    glDeleteVertexArraysOES(1, &cubeVAO);
    glDeleteVertexArraysOES(1, &floorVAO);
    glDeleteBuffers(1, &cubeVBO);
    glDeleteBuffers(1, &floorVBO);
}

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
