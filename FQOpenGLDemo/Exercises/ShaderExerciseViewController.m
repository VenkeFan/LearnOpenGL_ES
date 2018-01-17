//
//  ShaderExerciseViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/15.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ShaderExerciseViewController.h"
#import "MyEAGLView.h"

@interface ShaderExerciseViewController ()

@end

@implementation ShaderExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyEAGLView *view = [[MyEAGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
