//
//  MyEAGLView.h
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MyEAGLView : UIView

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign, readonly) int32_t renderWidth;
@property (nonatomic, assign, readonly) int32_t renderHeight;

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName;

@end
