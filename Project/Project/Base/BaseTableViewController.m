//
//  BaseTableViewController.m
//  Project
//
//  Created by HC101 on 2020/11/25.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "BaseTableViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface BaseTableViewController ()<UITableViewDelegate, UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>


@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.needRefresh = YES;
        
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topBar.frame = CGRectMake(0, 0, zh_ScreenWidth, zh_StatusBar_HEIGHT + zh_NavigationBar_HEIGHT);
    self.topBar.backgroundColor = [UIColor whiteColor];
    self.navigationTitleLabel.frame = CGRectMake(0, zh_StatusBar_HEIGHT, zh_ScreenWidth, zh_NavigationBar_HEIGHT);
    self.navigationTitleLabel.textColor = [UIColor zh_colorWithHexString:kColor_333333];
    self.navigationTitleLabel.font = [UIFont systemFontOfSize:21];
    
    self.leftNavigationButton.frame = CGRectMake(0, zh_StatusBar_HEIGHT, 44, 44);
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateHighlighted];
    
    self.rightNavigationButton.frame = CGRectMake(zh_ScreenWidth - 44, zh_StatusBar_HEIGHT, 44, zh_NavigationBar_HEIGHT);
    [self.rightNavigationButton setTitleColor:[UIColor zh_colorWithHexString:kColor_333333] forState:UIControlStateNormal];
    [self.rightNavigationButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    
    self.lineView = [[UIView alloc] init];
    [self.topBar addSubview:self.lineView];
    self.lineView.backgroundColor = [UIColor zh_colorWithHexString:kColor_EAEAEA];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.topBar);
    }];
    
//    [self.topBar zh_addLineWithFrame:CGRectMake(0, self.topBar.height - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    
}

- (void)fetchRequest {}


#pragma mark - empty
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"空"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
//    NSString *text = @"很抱歉！没有找到相关内容";
//
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.f],
//                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
//
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return [[NSAttributedString alloc] initWithString:@""];
}
- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(0.f,0.f);
}
- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(0.f,0.f);
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -50.f/2.0f;
}
- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 10.0f;
}
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}


#pragma mark - setter / getter
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (zh_NavigationBar_HEIGHT+zh_StatusBar_HEIGHT), zh_ScreenWidth, zh_ScreenHeight-zh_NavigationBar_HEIGHT-zh_StatusBar_HEIGHT) style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //_tableView.tableHeaderView=self.headerView;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
//        _tableView.backgroundColor =  [UIColor zh_colorWithHexString:kColor_TableBGColor];
//        [_tableView registerClass:[CirclesCell class] forCellReuseIdentifier:CirclesCellID];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

@end
