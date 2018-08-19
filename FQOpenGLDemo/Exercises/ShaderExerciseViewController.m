//
//  ShaderExerciseViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/15.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ShaderExerciseViewController.h"
#import "MyTriangleView.h"
#import "MyCircleView.h"
#import "MyTextureView.h"
#import "MyTransformationsView.h"
#import "MyCoordinateSystemsView.h"
#import "MyCameraView.h"
#import "MyColorView.h"
#import "MyBasicLightingView.h"
#import "MyEffectsView.h"
#import "MyInstancedRenderView.h"
#import "MyMaterialView.h"
#import "MyLightingMapsView.h"
#import "MyDepthTestView.h"
#import "MyStencilTestView.h"
#import "MyBlendingView.h"
#import "MyFaceCullingView.h"
#import "MyFrameBufferView.h"
#import "MyFrameBufferGLKView.h"
#import "MySkyboxView.h"

@interface ShaderExerciseViewController ()

@end

@implementation ShaderExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[MySkyboxView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
