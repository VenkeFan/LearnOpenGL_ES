//
//  MyEffectsView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/30.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyEffectsView.h"
#import "FQShaderHelper.h"
#import "JpegUtil.h"
#import "PngUtil.h"

@implementation MyEffectsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /*
         effects_gray
         effects_reverse
         effects_eddy
         effects_mosaic
         effects_gaussianBlur
         effects_emboss
         */
        [self renderWithVertexFileName:@"effects" fragmentFileName:@"effects_emboss"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    float vertices[] = {
        // ---- 位置 ----     - 纹理坐标 -
        0.8f,  0.6f, 0.0f,   1.0f, 0.0f,   // 右上
        0.8f, -0.6f, 0.0f,   1.0f, 1.0f,   // 右下
        -0.8f, -0.6f, 0.0f,  0.0f, 1.0f,   // 左下
        -0.8f,  0.6f, 0.0f,  0.0f, 0.0f    // 左上
    };
    
    unsigned int indices[] = {
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint program = [FQShaderHelper linkShaderWithVertexFileName:vertexName fragmentFileName:fragmentName];
    if (program == 0) {
        return;
    }
    glUseProgram(program);
    
    int vPos = glGetAttribLocation(program, "vPos");
    glEnableVertexAttribArray(vPos);
    glVertexAttribPointer(vPos, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (void *)0);
    
    int texcoord = glGetAttribLocation(program, "texcoord");
    glEnableVertexAttribArray(texcoord);
    glVertexAttribPointer(texcoord, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
    
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
        
        unsigned char *data;
        int size;
        int width;
        int height;
        
        if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
            printf("%s\n", "decode texture fail");
        }
        
        GLuint texture;
        glGenTextures(1, &texture);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)width, (GLsizei)height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        glUniform1i(glGetUniformLocation(program, "image"), 0);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        if (data) {
            free(data);
            data = NULL;
        }
    }
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
