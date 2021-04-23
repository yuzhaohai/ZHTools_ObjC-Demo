//
//  LoginViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/22.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) UITextField *mobileField;
@property (strong, nonatomic) UITextField *pwdField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"登录";
    
    [self.topBar zh_addLineWithFrame:CGRectMake(0, self.topBar.bottom - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    
    UIImageView *imageView = [UIImageView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth / 2.0 - 26, self.topBar.bottom + 26, 52, 52)),
        zh_image: [UIImage zh_appIcon],
        zh_superView: self.view
    }];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(20, imageView.bottom, zh_ScreenWidth - 20 * 2, 128)),
        zh_text: @"你好",
        zh_textColor: kColor_333333,
        zh_superView: self.view,
        zh_numberOfLines: @2,
        zh_font: @23
    }];
    
    self.mobileField = [UITextField viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, label.bottom, zh_ScreenWidth - 15 * 2, 50)),
        zh_leftViewMode: @(UITextFieldViewModeAlways),
        zh_textColor: kColor_333333,
        zh_borderColor: kColor_Red,
        zh_superView: self.view,
        zh_cornerRadius: @25,
        zh_masksToBounds: @1,
        zh_borderWidth: @1,
        zh_font: @16,
        zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入账号" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_B2B2B2]}],
        zh_leftView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"手机号码"]]
    }];
    
    self.pwdField = [UITextField viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, self.mobileField.bottom + 15, zh_ScreenWidth - 15 * 2, 50)),
        zh_leftViewMode: @(UITextFieldViewModeAlways),
        zh_textColor: kColor_333333,
        zh_borderColor: kColor_Red,
        zh_superView: self.view,
        zh_cornerRadius: @25,
        zh_masksToBounds: @1,
        zh_borderWidth: @1,
        zh_font: @16,
        zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_B2B2B2]}],
        zh_leftView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"密码"]]
    }];
    self.pwdField.secureTextEntry = YES;
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, self.pwdField.bottom + 42, self.pwdField.width, 50)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"登 录",
        zh_titleFont: @16
    }];
    [button zh_addCornerRadius:25 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(26, button.bottom + 32 - 15, 66, 44)),
        zh_contentHorizontalAlignment: @(UIControlContentHorizontalAlignmentLeft),
        zh_normalTitleColor: kColor_333333,
        zh_superView: self.view,
        zh_normalTitle: @"注册账户",
        zh_titleFont: @14,
        zh_tag: @0
    }];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 26 - 66, button.top, 66, 44)),
        zh_contentHorizontalAlignment: @(UIControlContentHorizontalAlignmentRight),
        zh_normalTitleColor: kColor_333333,
        zh_superView: self.view,
        zh_normalTitle: @"忘记密码",
        zh_titleFont: @14,
        zh_tag: @1
    }];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - SafeAreaHeight * .5 - 32, zh_ScreenWidth, SafeAreaHeight * .5 + 32)),
        zh_textAlignment: @(NSTextAlignmentCenter),
        zh_text: @"山东省来客科技提供技术服务",
        zh_textColor: kColor_808080,
        zh_superView: self.view,
        zh_font: @12,
    }];
    
//    self.mobileField.text = @"15253913919";
//    self.pwdField.text = @"qqqqq1";
//
//    self.mobileField.text = @"18888888888";
//    self.pwdField.text = @"123456";
}

- (void)tappedSubmitButton:(UIButton *)button {
    if (self.mobileField.text.length < 6) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    if (self.pwdField.text.length < 6) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的密码"];
        return;
    }
    
    [Util POST:@"/api/Login/login" showHUD:YES showResultAlert:YES parameters:@{
        @"phone": self.mobileField.text,
        @"pwd": self.pwdField.text,
    } result:^(id responseObject) {
        if (responseObject) {
            [AppDelegate appDelegate].userInfo = responseObject;
            [self goBack];
        }
    }];
}

- (void)tappedButton:(UIButton *)button {
    NSArray *array = @[@"RegisterViewController", @"ForgetPWDViewController"];
    
    NSString *vcName = array[button.tag];
    Class vcClass = NSClassFromString(vcName);
    
    if (vcClass) {
        [self.navigationController pushViewController:[vcClass new] animated:YES];
    }
}

@end
