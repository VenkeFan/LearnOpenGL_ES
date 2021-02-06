//
//  GPUImageTableViewController.m
//  FQOpenGLDemo
//
//  Created by fanqi on 2021/2/5.
//  Copyright © 2021 fanqi. All rights reserved.
//

#import "GPUImageTableViewController.h"
#import "GPUImageCameraViewController.h"

static NSString * const ReuseID = @"TableViewCell";

@interface GPUImageTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation GPUImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseID];
    [self.tableView reloadData];
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
    
    if ([class isSubclassOfClass:[UIViewController class]]) {
        UIViewController *ctr = [[class alloc] init];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Getter

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@{NSStringFromClass([GPUImageCameraViewController class]): [GPUImageCameraViewController class]},];
    }
    return _dataArray;
}

@end
