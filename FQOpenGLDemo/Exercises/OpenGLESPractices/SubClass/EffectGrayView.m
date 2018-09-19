//
//  EffectGrayView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/4.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "EffectGrayView.h"

@implementation EffectGrayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"effects" fragmentFileName:@"effects_gray"];
    }
    return self;
}

@end
