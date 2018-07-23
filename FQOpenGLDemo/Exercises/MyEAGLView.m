//
//  MyEAGLView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyEAGLView.h"

@interface MyEAGLView ()

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;

@end

@implementation MyEAGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeContext];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    
}

- (void)initializeContext {
    // 设置渲染上下文
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    // 设置渲染窗口（图层）
    self.myEAGLLayer.opaque = YES;
    self.myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(FALSE),
                                            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    // 设置帧缓存
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 设置颜色缓存
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    // 帧缓存装载渲染缓存的内容
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    // 渲染上下文绑定渲染窗口（图层）
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    // 渲染窗口
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
    
    glViewport(0, 0, _renderWidth, _renderHeight);
    
    // 设置深度缓冲区
    GLuint depthRenderbuffer;
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderWidth, _renderHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    glEnable(GL_DEPTH_TEST);
    
    // 设置颜色缓存为当前的渲染缓存
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
}

@end
