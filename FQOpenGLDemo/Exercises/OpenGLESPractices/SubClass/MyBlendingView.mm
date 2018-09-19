//
//  MyBlendingView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/7.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyBlendingView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FQShaderHelper.h"
#import "FQTextureHelper.h"
#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"
#include "geometric.h"
#include <map>

@interface MyBlendingView () {
    GLuint _frameBuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;
    
    GLsizei _renderWidth;
    GLsizei _renderHeight;
    
    GLuint _floorVAO;
    GLuint _floorVBO;
    GLuint _cubeVAO;
    GLuint _cubeVBO;
    GLuint _grassVAO;
    GLuint _grassVBO;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyBlendingView

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
        [self initializeFrameAndRenderbuffer];
        [self initializeDepthbuffer];
        
        [self renderWithSort];
//        [self renderWithDiscard];
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

- (void)initializeFrameAndRenderbuffer {
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

- (void)initializeDepthbuffer {
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

#pragma mark - render

- (void)renderWithDiscard {
    GLuint floorTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"wood"
                                                                                              ofType:@"png"]];
    GLuint cubeTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"marble"
                                                                                             ofType:@"jpg"]];
    GLuint grassTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"grass"
                                                                                              ofType:@"png"]];
    
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:@"depthTest"
                                                       fragmentFileName:@"blending_discard"];
    if (shaderProgram == 0) {
        return;
    }
    glUseProgram(shaderProgram);
    
    // cube VBO
    [self generateCubeVAO:shaderProgram];
    
    // floor VBO
    [self generateFloorVAO:shaderProgram];
    
    // grass VBO
    [self generateGrassVAO:shaderProgram];
    
    // 全局配置
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 坐标转换
    glm::mat4 model;
    glm::mat4 view;
    glm::mat4 projection;
    view = glm::translate(view, glm::vec3(0.f, 0.f, -4.f));
    projection = glm::perspective(glm::radians(90.f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    // draw
    {
        glBindVertexArrayOES(_cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, cubeTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        model = glm::translate(model, glm::vec3(-1.0f, 0.0f, -1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        model = glm::mat4();
        model = glm::translate(model, glm::vec3(1.0f, 0.0f, 0.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArrayOES(0);
    }
    
    {
        glBindVertexArrayOES(_floorVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, floorTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(glm::mat4()));
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArrayOES(0);
    }
    
    {
        glm::vec3 vegetation[] = {
            glm::vec3(-1.5f, 0.0f, -0.48f),
            glm::vec3( 1.5f, 0.0f, 0.51f),
            glm::vec3( 0.0f, 0.0f, 0.7f),
            glm::vec3(-0.3f, 0.0f, -2.3f),
            glm::vec3 (0.5f, 0.0f, -0.6f)
        };
        
        glBindVertexArrayOES(_grassVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, grassTexture);
        // 因为使用了有alpha通道的图片，设置为GL_REPEAT会导致纹理周围有个半透明的有色边框
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        
        for (int i = 0; i < 5; i++) {
            model = glm::mat4();
            model = glm::translate(model, vegetation[i]);
            glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
        
        glBindVertexArrayOES(0);
    }
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    glDeleteVertexArraysOES(1, &_cubeVAO);
    glDeleteVertexArraysOES(1, &_floorVAO);
    glDeleteVertexArraysOES(1, &_grassVAO);
    glDeleteBuffers(1, &_cubeVBO);
    glDeleteBuffers(1, &_floorVBO);
    glDeleteBuffers(1, &_grassVBO);
}

- (void)renderWithSort {
    GLuint floorTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"wood"
                                                                                              ofType:@"png"]];
    GLuint cubeTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"marble"
                                                                                             ofType:@"jpg"]];
    GLuint winTexture = [FQTextureHelper genTextureWithPath:[[NSBundle mainBundle] pathForResource:@"window"
                                                                                            ofType:@"png"]];
    
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:@"depthTest"
                                                       fragmentFileName:@"blending_sort"];
    if (shaderProgram == 0) {
        return;
    }
    glUseProgram(shaderProgram);
    
    // cube VBO
    [self generateCubeVAO:shaderProgram];
    
    // floor VBO
    [self generateFloorVAO:shaderProgram];
    
    // grass VBO
    [self generateGrassVAO:shaderProgram];
    
    // 全局配置
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glEnable(GL_BLEND);
    /*
     GL_ZERO                        因子等于0
     GL_ONE                         因子等于1
     GL_SRC_COLOR                   因子等于源颜色向量C¯source
     GL_ONE_MINUS_SRC_COLOR         因子等于1−C¯source
     GL_DST_COLOR                   因子等于目标颜色向量C¯destination
     GL_ONE_MINUS_DST_COLOR         因子等于1−C¯destination
     GL_SRC_ALPHA                   因子等于C¯source的alpha分量
     GL_ONE_MINUS_SRC_ALPHA         因子等于1− C¯source的alpha分量
     GL_DST_ALPHA                   因子等于C¯destination的alpha分量
     GL_ONE_MINUS_DST_ALPHA         因子等于1− C¯destination的alpha分量
     GL_CONSTANT_COLOR              因子等于常数颜色向量C¯constant
     GL_ONE_MINUS_CONSTANT_COLOR    因子等于1−C¯constant
     GL_CONSTANT_ALPHA              因子等于C¯constant的alpha分量
     GL_ONE_MINUS_CONSTANT_ALPHA    因子等于1− C¯constant的alpha分量
     */
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    /*
     为RGB和alpha通道分别设置不同的选项，参数同上
     */
//    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
    
    /*
     GL_FUNC_ADD：               默认选项，将两个分量相加：C¯result=Src+Dst。
     GL_FUNC_SUBTRACT：          将两个分量相减： C¯result=Src−Dst。
     GL_FUNC_REVERSE_SUBTRACT：  将两个分量相减，但顺序相反：C¯result=Dst−Src。
     */
//    glBlendEquation(GL_FUNC_ADD);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 坐标转换
    glm::mat4 model;
    glm::mat4 view;
    glm::mat4 projection;
    view = glm::translate(view, glm::vec3(0.f, 0.f, -4.f));
    projection = glm::perspective(glm::radians(90.f), _renderWidth / (float)_renderHeight, 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
    
    // 1. 先绘制所有不透明的物体
    {
        glBindVertexArrayOES(_cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, cubeTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        model = glm::translate(model, glm::vec3(-1.0f, 0.0f, -1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        model = glm::mat4();
        model = glm::translate(model, glm::vec3(1.0f, 0.0f, 0.0f));
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArrayOES(0);
    }
    
    {
        glBindVertexArrayOES(_floorVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, floorTexture);
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(glm::mat4()));
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArrayOES(0);
    }
    
    {
        int count = 5;
        
        glm::vec3 vegetation[] = {
            glm::vec3(-1.5f, 0.0f, -0.48f),
            glm::vec3( 1.5f, 0.0f, 0.51f),
            glm::vec3( 0.0f, 0.0f, 0.7f),
            glm::vec3(-0.3f, 0.0f, -2.3f),
            glm::vec3(0.5f, 0.0f, -0.6f)
        };
        
        glBindVertexArrayOES(_grassVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, winTexture);
        // 因为使用了有alpha通道的图片，设置为GL_REPEAT会导致纹理周围有个半透明的有色边框
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glUniform1f(glGetUniformLocation(shaderProgram, "myTexture"), 0);
        
        // 2. 对所有透明的物体排序
        std::map<float, glm::vec3> sorted;
        for (unsigned int i = 0; i < count; i++)
        {
            float distance = glm::length(glm::vec3(0.0) - vegetation[i]);
            sorted[distance] = vegetation[i];
        }
        
        // 3. 按顺序绘制所有透明的物体
        for (std::map<float, glm::vec3>::reverse_iterator it = sorted.rbegin(); it != sorted.rend(); ++it) {
            model = glm::mat4();
            model = glm::translate(model, it->second);
            glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
        
        glBindVertexArrayOES(0);
    }
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    glDeleteVertexArraysOES(1, &_cubeVAO);
    glDeleteVertexArraysOES(1, &_floorVAO);
    glDeleteVertexArraysOES(1, &_grassVAO);
    glDeleteBuffers(1, &_cubeVBO);
    glDeleteBuffers(1, &_floorVBO);
    glDeleteBuffers(1, &_grassVBO);
}

- (void)generateFloorVAO:(GLuint)shaderProgram {
    float floorVertices[] = {
        // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
        5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f,  5.0f,  0.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
        
        5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
        5.0f, -0.5f, -5.0f,  2.0f, 2.0f
    };
    
    glGenVertexArraysOES(1, &_floorVAO);
    glBindVertexArrayOES(_floorVAO);
    
    glGenBuffers(1, &_floorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _floorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(floorVertices), floorVertices, GL_STATIC_DRAW);
    
    int posLoc = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
}

- (void)generateCubeVAO:(GLuint)shaderProgram {
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
    
    glGenVertexArraysOES(1, &_cubeVAO);
    glBindVertexArrayOES(_cubeVAO);
    
    glGenBuffers(1, &_cubeVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    
    int posLoc = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
}

- (void)generateGrassVAO:(GLuint)shaderProgram {
    float grassVertices[] = {
        // positions         // texture Coords (swapped y coordinates because texture is flipped upside down)
        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        0.0f, -0.5f,  0.0f,  0.0f,  1.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,
        
        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,
        1.0f,  0.5f,  0.0f,  1.0f,  0.0f
    };
    
    glGenVertexArraysOES(1, &_grassVAO);
    glBindVertexArrayOES(_grassVAO);
    
    glGenBuffers(1, &_grassVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _grassVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(grassVertices), grassVertices, GL_STATIC_DRAW);
    
    int posLoc = glGetAttribLocation(shaderProgram, "aPos");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL);
    
    int texLoc = glGetAttribLocation(shaderProgram, "aTexCoord");
    glEnableVertexAttribArray(texLoc);
    glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    glBindVertexArrayOES(0);
}

@end
