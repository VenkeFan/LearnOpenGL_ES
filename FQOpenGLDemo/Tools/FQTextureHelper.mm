//
//  FQTextureHelper.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/8/7.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQTextureHelper.h"
#import "JpegUtil.h"
#import "PngUtil.h"

@implementation FQTextureHelper

+ (GLuint)genTextureWithPath:(NSString *)path {
    BOOL isPng = [path.lastPathComponent.lowercaseString containsString:@"png"];
    BOOL hasAlpha = NO;
    
    unsigned char *data;
    int size, width, height;
    
    GLuint texture;
    glGenTextures(1, &texture);
    
    if (isPng) {
        pic_data picData;
        
        if (read_png_file(path.UTF8String, &picData) < 0) {
            return -1;
        }
        
        data = picData.rgba;
        width = picData.width;
        height = picData.height;
        hasAlpha = picData.flag > 0;
        
    } else {
        if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
            return -1;
        }
        
        hasAlpha = NO;
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    GLenum format = hasAlpha ? GL_RGBA : GL_RGB;
    glTexImage2D(GL_TEXTURE_2D, 0, format, (GLsizei)width, (GLsizei)height, 0, format, GL_UNSIGNED_BYTE, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}

@end
