//
//  MyFrameBufferView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/3.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyFrameBufferView.h"
#import <OpenGLES/ES2/gl.h>

@interface MyFrameBufferView () {
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _depthRenderbuffer;
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
        [self initializeContext];
        [self initializeLayer];
    }
    return self;
}

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
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
}

@end
