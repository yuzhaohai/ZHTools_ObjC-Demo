//
//  EditCardViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "EditCardViewController.h"

@interface EditCardViewController ()<UITextFieldDelegate>

@property (copy, nonatomic) NSDictionary *card;

@property (copy, nonatomic) NSArray *keyArray;

@property (copy, nonatomic) NSMutableArray *viewArray;

@end

@implementation EditCardViewController

- (instancetype)initWithCard:(NSDictionary *)card {
    self = [super init];
    if (self) {
        self.card = card;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.card ? @"编辑银行卡" : @"添加银行卡";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"填写持卡人姓名", @"选择银行", @"填写银行卡号"];
    NSArray *aArray = @[@"持卡人", @"银行", @"银行卡号"];
    
    for (int i = 0; i < array.count; i++) {
        UITextField *tf = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 10 + 57 * i, zh_ScreenWidth, 56)),
            zh_rightViewMode: @(UITextFieldViewModeAlways),
            zh_leftViewMode: @(UITextFieldViewModeAlways),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_superView: self.view,
            zh_font: @15,
            zh_tag: @(i),
            zh_text: (self.card ? self.card[self.keyArray[i]] : @""),
            zh_rightView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 56)],
            zh_leftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 56)],
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:array[i] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_999999]}],
        }];
        
        [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 88 - 15, 56)),
            zh_textColor: kColor_333333,
            zh_text: aArray[i],
            zh_superView: tf,
            zh_font: @15
        }];
        
        [self.viewArray addObject:tf];
    }
    
//    UITextField *textField = (UITextField *)self.viewArray[1];
//    textField.delegate = self;
//
//    [UIImageView viewWithDictionary:@{
//        zh_frame: NSStringFromCGRect(textField.rightView.bounds),
//        zh_contentMode: @(UIViewContentModeCenter),
//        zh_superView: textField.rightView,
//        zh_image: @"more",
//    }];
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth / 2.0 - 100, ((UIView *)[self.viewArray lastObject]).bottom + 100, 200, 44)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"确认",
        zh_titleFont: @15
    }];
    [button zh_addCornerRadius:22 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tappedButton:(UIButton *)button {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    for (UITextField *tf in self.viewArray) {
        if (tf.text.length < 1) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请%@", tf.attributedText.string]];
            return;
        } else {
            
            parameters[self.keyArray[tf.tag]] = tf.text;
            
        }
    }
    
    [Util POST:@"/api/User/user_bankcark_add" showHUD:YES showResultAlert:YES parameters:parameters  result:^(id responseObject) {
        if (responseObject) {
            if (self.operationSuccessBlock) {
                self.operationSuccessBlock();
            }
            
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

- (NSArray *)keyArray {
    if (!_keyArray) {
        _keyArray = @[@"name", @"bankname", @"bankcard_number"];
    }
    return _keyArray;
}

//#pragma mark -  UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    [self selectBank];
//
//    return NO;
//}
//
//- (void)selectBank {
//
//}

@end
