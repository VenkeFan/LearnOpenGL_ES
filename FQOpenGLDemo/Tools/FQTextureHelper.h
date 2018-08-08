//
//  FQTextureHelper.h
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/7.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface FQTextureHelper : NSObject

+ (GLuint)genTextureWithPath:(NSString *)path;

@end
