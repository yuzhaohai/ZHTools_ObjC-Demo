//
//  ForgetPWDViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/25.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ForgetPWDViewController.h"

@interface ForgetPWDViewController ()

@property (copy, nonatomic) NSMutableArray *viewArray;

@end

@implementation ForgetPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"注册";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"请输入手机号", @"请输入验证码", @"请输入新密码", @"确认密码"];
    NSArray *imageArray = @[@"phone", @"yzm", @"password", @"password"];
    
    for (int i = 0; i < array.count; i++) {
        UITextField *tf = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 10 + 57 * i, zh_ScreenWidth, 56)),
            zh_leftViewMode: @(UITextFieldViewModeAlways),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_superView: self.view,
            zh_font: @15,
            zh_leftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 47, 56)],
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:array[i] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_999999]}],
        }];
        
        tf.secureTextEntry = i > 1;
        
        [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 47, 56)),
            zh_contentMode: @(UIViewContentModeCenter),
            zh_image: imageArray[i],
            zh_superView: tf
        }];
        
        [self.viewArray addObject:tf];
    }
    
    UIButton *codeButton = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 106, 0, 106, 56)),
        zh_normalTitleColor: kColor_999999,
        zh_superView: self.viewArray[1],
        zh_normalTitle: @"获取验证码",
        zh_titleFont: @15,
        zh_tag: @60
    }];
    [codeButton zh_addLineWithFrame:CGRectMake(0, 12, 1, 32) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    [codeButton addTarget:self action:@selector(tappedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    
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
        zh_normalTitle: @"提交",
        zh_titleFont: @15
    }];
    [button zh_addCornerRadius:22 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tappedCodeButton:(UIButton *)button {
    UITextField *textField = self.viewArray[0];
    
    if (textField.text.length < 11) {
        [SVProgressHUD showErrorWithStatus:textField.attributedPlaceholder.string];
        [textField becomeFirstResponder];
        return;
    }
    
    [Util POST:@"/api/Login/forget_yzm" showHUD:YES showResultAlert:YES parameters:@{@"phone": textField.text} result:^(id responseObject) {
        if (responseObject) {
            [self resetButton:button];
        }
    }];
}

- (void)resetButton:(UIButton *)button {
    NSInteger tag = button.tag;
    
    if (tag == 0) {
        
        [button setTitle:@"重新获取" forState:UIControlStateNormal];
        
        button.tag = 60;
        
        button.userInteractionEnabled = YES;
        
    } else {
        
        [button setTitle:[NSString stringWithFormat:@"%@s", @(tag)] forState:UIControlStateNormal];
        
        button.tag = --tag;
        
        button.userInteractionEnabled = NO;
        
        [self performSelector:@selector(resetButton:) withObject:button afterDelay:1];
        
    }
}

- (void)tappedButton:(UIButton *)button {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    UITextField *textField = self.viewArray[0];
    if (textField.text.length < 11) {
        [SVProgressHUD showErrorWithStatus:textField.attributedPlaceholder.string];
        [textField becomeFirstResponder];
        return;
    }
    parameters[@"phone"] = textField.text;
    
    textField = self.viewArray[1];
    if (textField.text.length < 4) {
        [SVProgressHUD showErrorWithStatus:textField.attributedPlaceholder.string];
        [textField becomeFirstResponder];
        return;
    }
    parameters[@"code"] = textField.text;
    
    textField = self.viewArray[2];
    if (![Util checkPassword:textField.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入6位及以上包含数字字母和特殊符号中至少两种组合的密码"];
        [textField becomeFirstResponder];
        return;
    }
    parameters[@"pwd"] = textField.text;
    
    if (![textField.text isEqualToString:((UITextField *)self.viewArray[3]).text]) {
        [SVProgressHUD showErrorWithStatus:@"两次输入的密码不一致"];
        [textField becomeFirstResponder];
        return;
    }
    parameters[@"pwd_cf"] = textField.text;
    
    [Util POST:@"/api/Login/forget" showHUD:YES showResultAlert:YES parameters:parameters result:^(id responseObject) {
        if (responseObject) {
            [self goBack];
        }
    }];
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

@end
