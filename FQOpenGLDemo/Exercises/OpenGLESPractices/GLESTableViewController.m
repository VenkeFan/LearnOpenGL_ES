//
//  GLESTableViewController.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "GLESTableViewController.h"

#import "ShaderExerciseViewController.h"
#import "EffectsViewController.h"

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
#import "MyInstancingView.h"

static NSString * const ReuseID = @"TableViewCell";

@interface GLESTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation GLESTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseID];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseID];
    cell.textLabel.text = [self.dataArray[indexPath.row] allKeys].firstObject;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataArray[indexPath.row];
    Class class = [dic objectForKey:dic.allKeys.firstObject];
    
    if ([class isSubclassOfClass:[UIView class]]) {
        ShaderExerciseViewController *ctr = [[ShaderExerciseViewController alloc] initWithChildViewClass:class];
        [self.navigationController pushViewController:ctr animated:YES];
        
    } else if ([class isSubclassOfClass:[UIViewController class]]) {
        UIViewController *ctr = [[class alloc] init];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Getter

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@{NSStringFromClass([MyTriangleView class]): [MyTriangleView class]},
                       @{NSStringFromClass([MyCircleView class]): [MyCircleView class]},
                       @{NSStringFromClass([MyTextureView class]): [MyTextureView class]},
                       @{NSStringFromClass([MyTransformationsView class]): [MyTransformationsView class]},
                       @{NSStringFromClass([MyCoordinateSystemsView class]): [MyCoordinateSystemsView class]},
                       @{NSStringFromClass([MyCameraView class]): [MyCameraView class]},
                       @{NSStringFromClass([MyColorView class]): [MyColorView class]},
                       @{NSStringFromClass([MyBasicLightingView class]): [MyBasicLightingView class]},
                       @{NSStringFromClass([MyInstancedRenderView class]): [MyInstancedRenderView class]},
                       @{NSStringFromClass([MyMaterialView class]): [MyMaterialView class]},
                       @{NSStringFromClass([MyLightingMapsView class]): [MyLightingMapsView class]},
                       @{NSStringFromClass([MyDepthTestView class]): [MyDepthTestView class]},
                       @{NSStringFromClass([MyStencilTestView class]): [MyStencilTestView class]},
                       @{NSStringFromClass([MyBlendingView class]): [MyBlendingView class]},
                       @{NSStringFromClass([MyFaceCullingView class]): [MyFaceCullingView class]},
                       @{NSStringFromClass([MyFrameBufferView class]): [MyFrameBufferView class]},
                       @{NSStringFromClass([MyFrameBufferGLKView class]): [MyFrameBufferGLKView class]},
                       @{NSStringFromClass([MySkyboxView class]): [MySkyboxView class]},
                       @{NSStringFromClass([MyInstancingView class]): [MyInstancingView class]},
                       @{NSStringFromClass([EffectsViewController class]): [EffectsViewController class]}];
    }
    return _dataArray;
}

@end
