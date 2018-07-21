//
//  MyTriangleView.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/18.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "MyTriangleView.h"
#import <OpenGLES/ES2/gl.h>
#import "FQShaderHelper.h"

@interface MyTriangleView ()
@end

@implementation MyTriangleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderWithVertexFileName:@"triangle" fragmentFileName:@"triangle"];
    }
    return self;
}

- (void)renderWithVertexFileName:(NSString *)vertexName fragmentFileName:(NSString *)fragmentName {
    
#pragma mark - 复制顶点数组到缓冲中供OpenGL使用
    
    // 顶点数组
    float vertices[] = {
        // 三角形
//        -0.5f, -0.5f, 0.0f,
//        0.5f, -0.5f, 0.0f,
//        0.0f,  0.5f, 0.0f
        
        
        // 正方形（顶点重复）
//        0.5, -0.5, 0.0f, //右下
//        0.5, 0.5, -0.0f, //右上
//        -0.5, 0.5, 0.0f, //左上
//
//        0.5, -0.5, 0.0f, //右下
//        -0.5, 0.5, 0.0f, //左上
//        -0.5, -0.5, 0.0f, //左下
        
        
        // 更多属性
        // 位置                  // 颜色
        0.5f, -0.5f, 0.0f,      1.0f, 0.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,     0.0f, 1.0f, 0.0f,   // 左下
        0.0f, 0.5f, 0.0f,       0.0f, 0.0f, 1.0f    // 顶部
    };
    
    
//    float vertices[] = {
//        // 正方形（顶点不重复）
//        0.5f, 0.5f, 0.0f,   // 右上角
//        0.5f, -0.5f, 0.0f,  // 右下角
//        -0.5f, -0.5f, 0.0f, // 左下角
//        -0.5f, 0.5f, 0.0f   // 左上角
//    };
//    unsigned int indices[] = { // 注意索引从0开始!
//        0, 1, 3, // 第一个三角形
//        1, 2, 3  // 第二个三角形
//    };
//
//    // 索引缓冲对象
//    GLuint EBO;
//    glGenBuffers(1, &EBO);
//
//    // 复制索引数组到一个索引缓冲中
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    // 顶点缓冲对象
    GLuint VBO; // 缓冲ID
    glGenBuffers(1, &VBO); // 生成VBO对象
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO); // 将缓冲对象绑定到 GL_ARRAY_BUFFER 目标上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); // 把顶点数据从 CPU 内存复制到 GPU 的缓冲内存中
    
#pragma mark - 自定义着色器程序
    
    // 着色器源码文件路径
    NSString* vertexFile = [[NSBundle mainBundle] pathForResource:vertexName ofType:@"vs"];
    NSString* fragmentFile = [[NSBundle mainBundle] pathForResource:fragmentName ofType:@"fs"];
    
    // 着色器程序（项目对象）
    GLuint shaderProgram = [FQShaderHelper linkShaderWithVertexFilePath:vertexFile fragmentFilePath:fragmentFile];
    if (shaderProgram == 0) {
        return;
    }
    
    // 设为实际的渲染目标
    glUseProgram(shaderProgram);
    
#pragma mark - 设置顶点属性指针
    
    // 获取shader中属性的位置
    GLuint positionLocation = glGetAttribLocation(shaderProgram, "v_Position");
    // 启用shader中的属性
    glEnableVertexAttribArray(positionLocation);
    
    /**
     
     第一个参数指定我们要配置的顶点属性。因为我们希望把数据传递到这一个顶点属性中，所以这里我们传入0。
     第二个参数指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
     第三个参数指定数据的类型，这里是GL_FLOAT(GLSL中vec*都是由浮点数值组成的)。
     第四个参数定义我们是否希望数据被标准化(Normalize)。如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。我们把它设置为GL_FALSE。
     第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔。由于下个组位置数据在3个float之后，我们把步长设置为3 * sizeof(float)。
     要注意的是由于我们知道这个数组是紧密排列的（在两个顶点属性之间没有空隙）我们也可以设置为0来让OpenGL决定具体步长是多少（只有当数值是紧密排列时才可用）。
     一旦我们有更多的顶点属性，我们就必须更小心地定义每个顶点属性之间的间隔（译注: 这个参数的意思简单说就是从这个属性第二次出现的地方到整个数组0位置之间有多少字节）。
     第六个参数的类型是void*，所以需要我们进行这个奇怪的强制类型转换。它表示位置数据在缓冲中起始位置的偏移量(Offset)。由于位置数据在数组的开头，所以这里是0。
     
     */
    
    // 为shader中的v_Position赋值
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (void*)0);
    
    
//    float timeValue = CACurrentMediaTime();
//    float greenValue = (sin(timeValue) / 2.0f) + 0.5f;
//    // 为片段着色器中的 ourColor 赋值
//    // 更新一个uniform之前必须先使用程序（调用glUseProgram)，因为它是在当前激活的着色器程序中设置uniform的
//    GLuint colorLocation = glGetUniformLocation(shaderProgram, "ourColor");
//    glUniform4f(colorLocation, 0.0, greenValue, 0.0, 1.0);
    
    
    GLuint vLocation = glGetAttribLocation(shaderProgram, "v_Color");
    glEnableVertexAttribArray(vLocation);
    glVertexAttribPointer(vLocation, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
#pragma mark - 绘制
    
    // 设置背景色
    glClearColor(0.3, 0.0, 0.0, 1.0);
    
    // 清空渲染缓存的旧内容
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 绘制（vertices里有几个顶点坐标，这里的参数就传几个）
    glDrawArrays(GL_TRIANGLES, 0, 3); // 使用当前激活的着色器，之前定义的顶点属性配置，和VBO的顶点数据（通过VAO间接绑定）来绘制图元
    
//    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0); // 从索引缓冲渲染
    
#pragma mark - 渲染
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
