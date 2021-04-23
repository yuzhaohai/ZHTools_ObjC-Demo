//
//  ZZPopoverViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/9.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ZZPopoverViewController.h"

@interface ZZPopoverViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ZZPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 改变弹出框圆角.
        self.view.superview.layer.cornerRadius = 6;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundColor = [UIColor blackColor];
        tableView.tableFooterView = [UIView new];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        tableView;
    });
        
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imageArray.count > 0 ? MIN(self.titleArray.count, self.imageArray.count) : self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.titleArray[indexPath.row]];
    
    if (self.imageArray.count > indexPath.row) {
        cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectBlock) {
        self.selectBlock(indexPath);
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//重写preferredContentSize，让popover返回你期望的大小
- (CGSize)preferredContentSize {
    if (self.presentingViewController && self.tableView != nil) {
        CGFloat height = 44 * [self tableView:self.tableView numberOfRowsInSection:0] + 20;
        self.tableView.frame = CGRectMake(0, 0, 150, MIN(height, zh_ScreenWidth));
        return self.tableView.frame.size;
    }else {
        return [super preferredContentSize];
    }
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize{
    super.preferredContentSize = preferredContentSize;
}

@end
