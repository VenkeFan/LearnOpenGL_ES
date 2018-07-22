//
//  FQShaderHelper.h
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface FQShaderHelper : NSObject

+ (GLuint)linkShaderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName;
+ (GLuint)loadShaderWithFilePath:(NSString *)filePath type:(GLenum)type;

@end
