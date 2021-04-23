//
//  TypeinExpressViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/29.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "TypeinExpressViewController.h"

@interface TypeinExpressViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *companyField;
@property (strong, nonatomic) UITextField *numberFirld;

@end

@implementation TypeinExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"录入退件";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    for (int i = 0; i < 2; i++) {
        UITextField *textField = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 5 + 56 * i, zh_ScreenWidth, 55)),
            zh_rightViewMode: @(UITextFieldViewModeAlways),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_superView: self.view,
            zh_font: @14,
            zh_rightView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 55)],
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:(@[@"请输入快递公司", @"请输入快递单号"][i]) attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}],
        }];
        
        [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 168, 55)),
            zh_text: @[@"快递公司", @"快递单号"][i],
            zh_textColor: kColor_333333,
            zh_superView: textField,
            zh_font: @14
            
        }];
        
        if (i == 0) {
//            textField.delegate = self;
            self.companyField = textField;
        } else {
            self.numberFirld = textField;
        }
    }
    
//    [UIImageView viewWithDictionary:@{
//        zh_frame: NSStringFromCGRect(self.companyField.rightView.bounds),
//        zh_contentMode: @(UIViewContentModeCenter),
//        zh_superView: self.companyField.rightView,
//        zh_image: @"more",
//    }];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.numberFirld.bottom, zh_ScreenWidth, 36)),
        zh_text: @"请如实录入退件物流信息，否则可能会导致退款无法完成",
        zh_textAlignment: @(NSTextAlignmentCenter),
        zh_textColor: kColor_808080,
        zh_superView: self.view,
        zh_font: @12
    }];
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, label.bottom + 66, zh_ScreenWidth - 15 * 2, 44)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"确定",
        zh_titleFont: @16,
    }];
    [button zh_addCornerRadius:22 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tappedButton:(UIButton *)button {
    if (self.companyField.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:self.companyField.attributedPlaceholder.string];
        return;
    }
    
    if (self.numberFirld.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:self.numberFirld.attributedPlaceholder.string];
        return;
    }
    
    [Util POST:@"/api/refund/refund_send" showHUD:YES showResultAlert:YES parameters:@{
        @"refund_id": self.refoundID,
        @"expressno": self.numberFirld.text,
        @"express_company": self.companyField.text,
    } result:^(id responseObject) {
        if (responseObject) {
            if (self.operationSuccessBlock) {
                self.operationSuccessBlock();
            }
            
            [self goBack];
        }
    }];
}

//#pragma mark -  UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    
//    
//    return NO;
//}

@end
