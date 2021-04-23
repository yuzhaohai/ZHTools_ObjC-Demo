//
//  TabBarViewController.m
//  MiHan
//
//  Created by YuZhaohai on 2020/6/9.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()<UITabBarControllerDelegate, UITabBarDelegate>


@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addChildViewControlls];
    
    [self setTabcarTopLineColor:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    
    self.delegate = self;
    self.tabBarController.tabBar.delegate = self;
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [UITabBar appearance].translucent = NO;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor zh_colorWithHexString:kColor_999999],NSForegroundColorAttributeName,nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor zh_colorWithHexString:kColor_Red],NSForegroundColorAttributeName,nil]forState:UIControlStateSelected];

    if (@available(iOS 13.0, *)) {

        self.tabBar.tintColor = [UIColor zh_colorWithHexString:kColor_Red];
        self.tabBar.unselectedItemTintColor = [UIColor zh_colorWithHexString:kColor_999999];

    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (BaseViewController *vc in self.viewControllers) {
        vc.needRefresh = [AppDelegate appDelegate].needRefresh;
    }
    [AppDelegate appDelegate].needRefresh = NO;
}

- (void)addChildViewControlls {
    NSArray *vcArray = @[@"IndexViewController", @"CategoryViewController", @"BrandViewController", @"PurchaseListViewController", @"MineViewController"];
    NSArray *titleArray = @[@"首页", @"分类", @"品牌", @"进货单", @"我的"];
    
    for (int i = 0; i < vcArray.count; i++) {
        NSString *vcName = vcArray[i];
        Class vcClass = NSClassFromString(vcName);
        BaseViewController *vc = [vcClass new];
        
        NSString *title = titleArray[i];
        
        vc.tabBarItem.title = title;
        vc.leftNavigationButton.hidden = i != 0;
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:title] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.image = [[UIImage imageNamed:[title stringByAppendingString:@"_gray"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self addChildViewController:vc];
    }
    
}

- (void)setTabcarTopLineColor:(UIColor *)color {
    //改变tabbar 线条颜色
    CGRect rect = CGRectMake(0, 0, zh_ScreenWidth, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setShadowImage:img];
    [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark -  UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    
    if (index > 2 && (![AppDelegate appDelegate].userInfo)) {
        [[AppDelegate appDelegate] login];
        return NO;
    }
    
    return YES;
}

@end
