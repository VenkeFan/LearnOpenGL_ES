//
//  MyTextureView.h
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyEAGLView.h"

@interface MyTextureView : MyEAGLView

- (void)genTexture:(GLuint)shaderProgram;

@end
