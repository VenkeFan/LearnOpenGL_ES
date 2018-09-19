//
//  EffectsViewController.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/4.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "EffectsViewController.h"
#import "ShaderExerciseViewController.h"
#import "EffectGrayView.h"
#import "EffectReverseView.h"
#import "EffectEddyView.h"
#import "EffectMosaicView.h"
#import "EffectGaussianBlurView.h"
#import "EffectEmbossView.h"
#import "EffectMirrorView.h"
#import "EffectElectricShockView.h"
#import "EffectGhostView.h"
#import "EffectSudokuView.h"

static NSString * const ReuseID = @"TableViewCell";

@interface EffectsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation EffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

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
    
    ShaderExerciseViewController *ctr = [[ShaderExerciseViewController alloc] initWithChildViewClass:class];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.rowHeight = 50;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseID];
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@{NSStringFromClass([EffectGrayView class]): [EffectGrayView class]},
                       @{NSStringFromClass([EffectReverseView class]): [EffectReverseView class]},
                       @{NSStringFromClass([EffectEddyView class]): [EffectEddyView class]},
                       @{NSStringFromClass([EffectMosaicView class]): [EffectMosaicView class]},
                       @{NSStringFromClass([EffectGaussianBlurView class]): [EffectGaussianBlurView class]},
                       @{NSStringFromClass([EffectEmbossView class]): [EffectEmbossView class]},
                       @{NSStringFromClass([EffectMirrorView class]): [EffectMirrorView class]},
                       @{NSStringFromClass([EffectElectricShockView class]): [EffectElectricShockView class]},
                       @{NSStringFromClass([EffectGhostView class]): [EffectGhostView class]},
                       @{NSStringFromClass([EffectSudokuView class]): [EffectSudokuView class]}];
    }
    return _dataArray;
}

@end
