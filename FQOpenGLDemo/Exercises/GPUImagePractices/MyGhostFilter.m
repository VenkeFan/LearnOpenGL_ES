//
//  MyGhostFilter.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2021/2/5.
//  Copyright © 2021 fanqi. All rights reserved.
//

#import "MyGhostFilter.h"

NSString *const kMyGhostFragmentShaderString = SHADER_STRING
(
 precision highp float;

 uniform sampler2D inputImageTexture;
 varying vec2 textureCoordinate;

 uniform float Time;

 void main (void) {
     float duration = 0.7;
     float maxAlpha = 0.4;
     float maxScale = 1.8;
     
     float progress = mod(Time, duration) / duration; // 0~1
     float alpha = maxAlpha * (1.0 - progress);
     float scale = 1.0 + (maxScale - 1.0) * progress;
     
     float weakX = 0.5 + (textureCoordinate.x - 0.5) / scale;
     float weakY = 0.5 + (textureCoordinate.y - 0.5) / scale;
     vec2 weakTextureCoords = vec2(weakX, weakY);
     
     vec4 weakMask = texture2D(inputImageTexture, weakTextureCoords);
     
     vec4 mask = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;
//    gl_FragColor = mix(weakMask, mask, 0.2);
 }
);

@interface MyGhostFilter () {
    CADisplayLink *_displayLink;
    NSTimeInterval _startTimeInterval;
    
    GLint _uniformTime;
}

@end

@implementation MyGhostFilter

- (instancetype)init {
    if (self = [super initWithFragmentShaderFromString:kMyGhostFragmentShaderString]) {
        _uniformTime = [filterProgram uniformIndex:@"Time"];
        
        _startTimeInterval = 0;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)timeAction {
    if (_startTimeInterval == 0) {
        _startTimeInterval = _displayLink.timestamp;
    }
    
    CGFloat currentTime = _displayLink.timestamp - _startTimeInterval;
    [self setFloat:currentTime forUniform:_uniformTime program:filterProgram];
}

@end
