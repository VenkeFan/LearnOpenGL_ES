//
//  ShaderExerciseViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/15.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ShaderExerciseViewController.h"
#import "MyTriangleView.h"
#import "MyTextureView.h"
#import "MyTransformationsView.h"
#import "MyCoordinateSystemsView.h"
#import "MyCameraView.h"
#import "MyColorView.h"

@interface ShaderExerciseViewController ()

@end

@implementation ShaderExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyColorView *view = [[MyColorView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
