//
//  BaseViewController.m
//  MiHan
//
//  Created by YuZhaohai on 2020/6/9.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()


@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.needRefresh = YES;
        
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topBar.frame = CGRectMake(0, 0, zh_ScreenWidth, zh_StatusBar_HEIGHT + zh_NavigationBar_HEIGHT);
    self.topBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationTitleLabel.frame = CGRectMake(0, zh_StatusBar_HEIGHT, zh_ScreenWidth, zh_NavigationBar_HEIGHT);
    self.navigationTitleLabel.textColor = [UIColor zh_colorWithHexString:kColor_333333];
    self.navigationTitleLabel.font = [UIFont systemFontOfSize:18];
    
    self.leftNavigationButton.frame = CGRectMake(0, zh_StatusBar_HEIGHT, 44, 44);
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateHighlighted];
    
    self.rightNavigationButton.frame = CGRectMake(zh_ScreenWidth - 44, zh_StatusBar_HEIGHT, 44, zh_NavigationBar_HEIGHT);
}

- (void)fetchRequest {}

- (void)setNeedRefresh:(BOOL)needRefresh {
    _needRefresh = needRefresh;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
