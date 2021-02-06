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

//- (void)genTexture:(GLuint)shaderProgram {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
//    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//    
//    // 纹理单元1
//    GLuint texLocation = glGetUniformLocation(shaderProgram, "ourTexture");
//    glUniform1i(texLocation, 0); // 将0传递给uniform ourTexture,如果激活的是GL_TEXTURE1就传递1，以此类推
//    
//    // 纹理单元2
//    GLKTextureInfo *textureInfo2 = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"awesomeface" ofType:@"png"] options:options error:nil];
//    GLuint texLocation2 = glGetUniformLocation(shaderProgram, "anthorTexture");
//    glUniform1i(texLocation2, 1);
//    
//    // 激活并绑定
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
//    
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, textureInfo2.name);
//    
//    [self setupTexture];
//}
//
//- (void)genTexture2:(GLuint)shaderProgram {
//    UIImage *img = [UIImage imageNamed:@"1.jpg"];
//    // 将图片数据以RGBA的格式导出到textureData中
//    CGImageRef imageRef = [img CGImage];
//    size_t width = CGImageGetWidth(imageRef);
//    size_t height = CGImageGetHeight(imageRef);
//    
//    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    
//    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
//                                                 bitsPerComponent, bytesPerRow, colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//    
//    // 生成纹理
//    GLuint texture;
//    glGenTextures(1, &texture);
//    
//    // 在绑定纹理之前先激活纹理单元，OpenGL ES中最多可以激活8个通道。通道0是默认激活的，所以本例中这一句也可以不写
//    glActiveTexture(GL_TEXTURE0);
//    
//    glBindTexture(GL_TEXTURE_2D, texture);
//    
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
//    
//    glUniform1i(glGetUniformLocation(shaderProgram, "ourTexture"), 0);
//    
//    [self setupTexture];
//}

@end
