//
//  MyEAGLView.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/18.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "MyEAGLView.h"
#import <OpenGLES/ES2/gl.h>

@interface MyEAGLView ()

@property (nonatomic, assign) GLuint program;
@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;

@end

@implementation MyEAGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (CAEAGLLayer *)myEAGLLayer {
    return (CAEAGLLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
#pragma mark - 0. 配置渲染环境
    
    // 设置渲染上下文
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // 设置渲染窗口（图层）
    self.myEAGLLayer.opaque = YES;
    self.myEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(TRUE),
                                            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    // 设置帧缓存
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 设置渲染缓存
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    // 帧缓存装载渲染缓存的内容
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    // 渲染上下文绑定渲染窗口（图层）
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    
#pragma mark - 1. 复制顶点数组到缓冲中供OpenGL使用
    
    // 顶点数组
    float vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
        
        
        // 正方形
//        0.5, -0.5, 0.0f, //右下
//        0.5, 0.5, -0.0f, //右上
//        -0.5, 0.5, 0.0f, //左上
//
//        0.5, -0.5, 0.0f, //右下
//        -0.5, 0.5, 0.0f, //左上
//        -0.5, -0.5, 0.0f, //左下
    };
    
    // 顶点缓冲对象
    GLuint VBO; // 缓冲ID
    glGenBuffers(1, &VBO); // 生成VBO对象
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO); // 将缓冲对象绑定到 GL_ARRAY_BUFFER 目标上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); // 把顶点数据从 CPU 内存复制到 GPU 的缓冲内存中
    
#pragma mark - 2. 设置顶点属性指针
    
    /**
     
     第一个参数指定我们要配置的顶点属性。因为我们希望把数据传递到这一个顶点属性中，所以这里我们传入0。
     第二个参数指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
     第三个参数指定数据的类型，这里是GL_FLOAT(GLSL中vec*都是由浮点数值组成的)。
     第四个参数定义我们是否希望数据被标准化(Normalize)。如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。我们把它设置为GL_FALSE。
     第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔。由于下个组位置数据在3个float之后，我们把步长设置为3 * sizeof(float)。
     要注意的是由于我们知道这个数组是紧密排列的（在两个顶点属性之间没有空隙）我们也可以设置为0来让OpenGL决定具体步长是多少（只有当数值是紧密排列时才可用）。
     一旦我们有更多的顶点属性，我们就必须更小心地定义每个顶点属性之间的间隔（译注: 这个参数的意思简单说就是从这个属性第二次出现的地方到整个数组0位置之间有多少字节）。
     最后一个参数的类型是void*，所以需要我们进行这个奇怪的强制类型转换。它表示位置数据在缓冲中起始位置的偏移量(Offset)。由于位置数据在数组的开头，所以这里是0。
     
     */
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), (void*)0);
    glEnableVertexAttribArray(0); // 以顶点属性位置值作为参数，启用顶点属性
    
#pragma mark - 3. 自定义着色器程序
    
    // 着色器源码文件路径
    NSString* vertexFile = [[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"glsl"];
    NSString* fragmentFile = [[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"glsl"];
    
    // 着色器程序（项目对象）
    GLuint shaderProgram = [self linkShaderWithVertexFilePath:vertexFile fragmentFilePath:fragmentFile];
    if (shaderProgram == 0) {
        return;
    }
    
    // 设为实际的渲染目标
    glUseProgram(shaderProgram);
    
#pragma mark - 4. 绘制
    
    // 设置渲染窗口的位置和尺寸
    GLint renderWidth, renderHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderHeight);
    
    glViewport(0, 0, renderWidth, renderHeight);
    
    // 设置背景色
    glClearColor(1.0, 0.0, 0.0, 1.0);
    
    // 清空渲染缓存的旧内容
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3); // vertices里有几个顶点坐标，这里的参数就传几个
    
#pragma mark - 5. 渲染
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

#pragma mark - 着色器

/**
 着色器程序对象(Shader Program Object)是多个着色器合并之后并最终链接完成的版本。
 如果要使用编译的着色器就必须把它们链接为一个着色器程序对象，然后在渲染对象的时候激活这个着色器程序
 
 @param vertexFile 顶点着色器源码文件路径
 @param fragmentFile 片段着色器源码文件路径
 @return 着色器程序
 */
- (GLuint)linkShaderWithVertexFilePath:(NSString *)vertexFile fragmentFilePath:(NSString *)fragmentFile {
    GLuint program;
    program = glCreateProgram(); // 创建着色器程序
    
    GLuint vertexShader = [self loadShaderWithFilePath:vertexFile type:GL_VERTEX_SHADER]; // 顶点着色器
    GLuint fragmentShader = [self loadShaderWithFilePath:fragmentFile type:GL_FRAGMENT_SHADER]; // 片段着色器
    
    if (vertexShader == 0 || fragmentShader == 0) {
        glDeleteProgram(program);
        return 0;
    }
    
    // 把编译的着色器附加到程序对象上（一个程序对象必须且只能有一个顶点着色器和一个片段着色器）
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 链接它们
    glLinkProgram(program);
    
    // 释放不再需要的shader
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    // 判断链接是否成功
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        GLint infoLength = 0;
        // 获取错误信息长度
        glGetShaderiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetProgramInfoLog(program, infoLength, NULL, infoLog);
            NSLog(@"Error linking program: %s", infoLog);
            free(infoLog);
        }
        glDeleteProgram(program);
        return 0;
    }
    
    return program;
}

/**
 *  编译着色器
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *
 *  @param filePath 着色器源码文件路径
 *  @param type 着色器类型
 */
- (GLuint)loadShaderWithFilePath:(NSString *)filePath type:(GLenum)type {
    GLuint shader;
    shader = glCreateShader(type); // 创建着色器对象
    
    NSString *vertexString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *vertexShaderSource = (GLchar *)vertexString.UTF8String;
    glShaderSource(shader, 1, &vertexShaderSource, NULL); // 把着色器源码附加到着色器对象上
    glCompileShader(shader); // 编译
    
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success); // 判断编译是否成功
    if (success == GL_FALSE) {
        GLint infoLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength); // 获取错误信息长度
        if (infoLength > 1) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog); // 获取错误信息
            NSLog(@"Error compiling shader %d: %s", type, infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

@end
