//
//  ViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2017/9/14.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ViewController.h"
#import "GLKTableViewController.h"
#import "GLESTableViewController.h"
#import "GPUImageTableViewController.h"

static NSString * const ReuseID = @"TableViewCell";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

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
    
    if ([class isSubclassOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:[class new] animated:YES];
    }
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
        _dataArray = @[@{NSStringFromClass([GLKTableViewController class]): [GLKTableViewController class]},
                       @{NSStringFromClass([GLESTableViewController class]): [GLESTableViewController class]},
                       @{NSStringFromClass([GPUImageTableViewController class]): [GPUImageTableViewController class]}];
    }
    return _dataArray;
}

@end
