//
//  MyCircleView.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/7/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "MyCircleView.h"
#import "FQShaderHelper.h"

typedef struct {
    GLfloat x,y,z;
    GLfloat r,g,b;
} Vertex;

@implementation MyCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"circle" fragmentFileName:@"circle"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    GLfloat radiusX = 0.8;
    GLfloat radiusY = radiusX * self.renderWidth / self.renderHeight;
    int vertexCount = 100;
    float delta = (M_PI * 2) / vertexCount;
    Vertex *vertices = (Vertex *)malloc(sizeof(Vertex) * vertexCount);
    
    for (int i = 0; i < vertexCount; i++) {
        GLfloat x = radiusX * cos(delta * i);
        GLfloat y = radiusY * sin(delta * i);
        GLfloat z = 0.0;
        
        Vertex v = (Vertex){x, y, z, x, y, x + y};
        vertices[i] = v;
        
        printf("%f, %f\n", x, y);
    }
    
    GLuint VBO;
    glGenBuffers(1, &VBO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * vertexCount, vertices, GL_STATIC_DRAW);
    
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFileName:vertexName fragmentFileName:fragmentName];
    if (shaderProgram == 0) {
        return;
    }
    glUseProgram(shaderProgram);
    
    int posLoc = glGetAttribLocation(shaderProgram, "v_Position");
    glEnableVertexAttribArray(posLoc);
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLfloat *)NULL);
    
    int colorLoc = glGetAttribLocation(shaderProgram, "v_Color");
    glEnableVertexAttribArray(colorLoc);
    glVertexAttribPointer(colorLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLfloat *)NULL + sizeof(GLfloat) * 3);
    
    glClearColor(1.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLineWidth(2.0);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
