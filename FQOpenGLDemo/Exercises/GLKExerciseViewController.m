//
//  GLKExerciseViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/15.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "GLKExerciseViewController.h"
#import <GLKit/GLKit.h>

@interface GLKExerciseViewController () <GLKViewDelegate>

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation GLKExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize {
    // 新建OpenGLES 上下文
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // GLKView 渲染窗口
    GLKView *glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:context];
    glkView.delegate = self;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [self.view addSubview:glkView];
    NSLog(@"GLKView layer: %@", glkView.layer);
    
    // 顶点数组对象(Vertex Array Object), 前三个是顶点坐标，后面两个是纹理坐标
    float vertices[] = {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        // 试试注释这3行看看效果
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    // 顶点缓冲对象 Vertex Buffer Object
    GLuint VBO; // 缓冲ID
    glGenBuffers(1, &VBO); // 生成标识符
    glBindBuffer(GL_ARRAY_BUFFER, VBO); // 将缓冲对象绑定到 GL_ARRAY_BUFFER 目标上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); // 把顶点数据从 CPU 内存复制到 GPU 的缓冲内存中
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //开启对应的顶点属性，顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0); // 设置合适的格式从buffer里面读取数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    
    // 纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(1)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // Apple 提供的默认的着色器
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = textureInfo.name;
    self.baseEffect = effect;
}

#pragma mark - GLKViewDelegate

/**
 渲染
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 启动着色器
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
