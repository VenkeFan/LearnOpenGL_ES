//
//  ShaderExerciseViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/15.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ShaderExerciseViewController.h"

@interface ShaderExerciseViewController () {
    Class _childClass;
}

@end

@implementation ShaderExerciseViewController

- (instancetype)initWithChildViewClass:(Class)childClass {
    if (self = [super init]) {
        _childClass = childClass;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_childClass isSubclassOfClass:[UIView class]]) {
        UIView *view = [[_childClass alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
