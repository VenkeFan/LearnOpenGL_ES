//
//  GLKTableViewController.m
//  FQOpenGLDemo
//
//  Created by fan qi on 2018/9/19.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "GLKTableViewController.h"
#import "GLKExerciseViewController.h"

static NSString * const ReuseID = @"TableViewCell";

@interface GLKTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation GLKTableViewController

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
        
    } else if ([class isSubclassOfClass:[UIViewController class]]) {
        UIViewController *ctr = [[class alloc] init];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Getter

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@{NSStringFromClass([GLKExerciseViewController class]): [GLKExerciseViewController class]}];
    }
    return _dataArray;
}

@end
