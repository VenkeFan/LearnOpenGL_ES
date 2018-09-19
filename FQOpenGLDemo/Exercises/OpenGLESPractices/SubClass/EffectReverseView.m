//
//  EffectReverseView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/4.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "EffectReverseView.h"

@implementation EffectReverseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"effects" fragmentFileName:@"effects_reverse"];
    }
    return self;
}

@end
