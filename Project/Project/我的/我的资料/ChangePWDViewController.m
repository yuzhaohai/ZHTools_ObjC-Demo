//
//  ChangePWDViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ChangePWDViewController.h"
#import "ForgetPWDViewController.h"

@interface ChangePWDViewController ()

@property (copy, nonatomic) NSMutableArray *viewArray;

@end

@implementation ChangePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"修改密码";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"请输入旧密码", @"请输入新密码", @"确认密码"];
    
    for (int i = 0; i < array.count; i++) {
        UITextField *tf = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 10 + 57 * i, zh_ScreenWidth, 56)),
            zh_leftViewMode: @(UITextFieldViewModeAlways),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_superView: self.view,
            zh_font: @15,
            zh_tag: @(i),
            zh_leftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 56)],
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:array[i] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_999999]}],
        }];
        tf.secureTextEntry = YES;
        
        [self.viewArray addObject:tf];
    }
        
    UIView *view = [self.viewArray lastObject];
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, view.bottom, zh_ScreenWidth, 32)),
        zh_text: @"请设置6位及以上包含数字字母和特殊符号中至少两种组合的密码",
        zh_textAlignment: @(NSTextAlignmentCenter),
        zh_textColor: kColor_B2B2B2,
        zh_superView: self.view,
        zh_font: @11
    }];
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth / 2.0 - 100, label.bottom + 100, 200, 44)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"确定",
        zh_titleFont: @15
    }];
    [button zh_addCornerRadius:22 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth / 2.0 - 100, button.bottom + 10, 200, 37)),
        zh_normalTitleColor: kColor_999999,
        zh_superView: self.view,
        zh_normalTitle: @"忘记密码",
        zh_titleFont: @12
    }];
    [button addTarget:self action:@selector(tappedForgetButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tappedButton:(UIButton *)button {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < self.viewArray.count; i++) {
        UITextField *tf = self.viewArray[i];
        
        if (i == 0) {
            if (tf.text.length < 1) {
                [SVProgressHUD showErrorWithStatus:tf.attributedPlaceholder.string];
                return;
            }
        } else {
            if (![Util checkPassword:tf.text]) {
                [SVProgressHUD showErrorWithStatus:@"请输入6位及以上包含数字字母和特殊符号中至少两种组合的密码"];
                return;
            }
        }
        
        parameters[@[@"pwd", @"npwd", @"z_npwd"][tf.tag]] = tf.text;
    }
    
    [Util POST:@"/api/User/edit_pwd" showHUD:YES showResultAlert:YES parameters:parameters result:^(id responseObject) {
        if (responseObject) {
            [AppDelegate appDelegate].userInfo = nil;
        }
    }];
}

- (void)tappedForgetButton:(UIButton *)button {
    [self.navigationController pushViewController:[ForgetPWDViewController new] animated:YES];
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

@end
