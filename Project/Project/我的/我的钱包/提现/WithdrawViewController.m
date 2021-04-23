//
//  WithdrawViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "WithdrawViewController.h"
#import "EditCardViewController.h"

@interface WithdrawViewController ()

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UILabel *moneyLabel;

@end

@implementation WithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"提现";
    
    self.rightNavigationButton.hidden = YES;
    
    UIView *view = [UIView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, self.topBar.bottom + 180, zh_ScreenWidth - 15 * 2, 160)),
        zh_superView: self.view,
        zh_backgroundColor: kColor_FFFFFF,
    }];
    [view zh_addCornerRadius:6 withCorners:UIRectCornerAllCorners];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(20, 10, view.width - 40, 40)),
        zh_textColor: kColor_000000,
        zh_superView: view,
        zh_text: @"提现金额",
        zh_font: @14,
    }];
    
    self.textField = [UITextField viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(20, label.bottom + 10, label.width, 47)),
        zh_leftViewMode: @(UITextFieldViewModeAlways),
        zh_textColor: kColor_000000,
        zh_superView: view,
        zh_font: @31,
        
        zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入提现金额" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_C3C3C3]}],
        
        zh_leftView: [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 20, 47)),
            zh_textColor: kColor_000000,
            zh_text: @"¥  ",
            zh_font: @31
        }]
    }];
    
    [view zh_addLineWithFrame:CGRectMake(20, self.textField.bottom, label.width, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    
    self.moneyLabel = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(20, view.height - 52, label.width, 50)),
        zh_textColor: kColor_999999,
        zh_superView: view,
        zh_font: @14,
        zh_text: [NSString stringWithFormat:@"可提现金额%.2f元", [[AppDelegate appDelegate].userInfo[@"money"] doubleValue]],
    }];
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(label.right - 66, self.moneyLabel.top, 66, 50)),
        zh_contentHorizontalAlignment: @(UIControlContentHorizontalAlignmentRight),
        zh_normalTitleColor: kColor_Red,
        zh_normalTitle: @"全部提现",
        zh_superView: view,
        zh_titleFont: @14,
    }];
    [button addTarget:self action:@selector(tappedAllButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, view.bottom + 44, zh_ScreenWidth - 15 * 2, 50)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_normalTitle: @"确认提现",
        zh_superView: self.view,
        zh_titleFont: @16,
    }];
    [button zh_addCornerRadius:25 withCorners:UIRectCornerAllCorners];
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)fetchRequest {
    [Util POST:@"/api/User/user_bankcark" showHUD:YES showResultAlert:YES parameters:@{} result:^(NSArray *responseObject) {
        if (responseObject) {
            self.card = responseObject.count > 0 ? responseObject[0] : nil;
            
            if (!self.card) {
                [SVProgressHUD dismissWithDelay:0];
                
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统检测到您尚未添加银行卡，请添加银行卡" preferredStyle:UIAlertControllerStyleAlert];
                        
                [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    EditCardViewController *vc = [[EditCardViewController alloc] init];
                    
                    vc.operationSuccessBlock = ^{
                        [self fetchRequest];
                    };
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }]];
                
                [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self goBack];
                }]];
                
                [self presentViewController:alertVc animated:YES completion:nil];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"数据有误"];
            [self goBack];
        }
    }];
}

- (void)tappedAllButton:(UIButton *)button {
    self.textField.text = [NSString stringWithFormat:@"%.2f", [[AppDelegate appDelegate].userInfo[@"money"] doubleValue]];
}

- (void)tappedButton:(UIButton *)button {
    if ([self.textField.text doubleValue] <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入提现金额"];
        return;
    }
    
    [Util POST:@"/api/User/withdraw" showHUD:YES showResultAlert:YES parameters:@{
        @"bankcard_id": self.card[@"bankcard_id"],
        @"money": self.textField.text
    } result:^(id responseObject) {
        if (responseObject) {
            if (self.operationSuccessBlock) {
                self.operationSuccessBlock();
            }
            
            [self goBack];
        }
    }];
}

@end
