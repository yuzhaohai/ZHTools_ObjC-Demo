//
//  BankCardViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BankCardViewController.h"
#import "EditCardViewController.h"


@interface BankCardViewController ()

@property (strong, nonatomic) UITextField *nameField;

@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) UILabel *bankLabel;
@property (strong, nonatomic) UILabel *accountLabel;

@end

@implementation BankCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"银行卡";
    
    [self.rightNavigationButton setPropertyWithDictionary:@{
        zh_normalTitleColor: kColor_000000,
        zh_normalTitle: @"添加",
        zh_titleFont: @14
    }];
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    self.nameField = [UITextField viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 5, zh_ScreenWidth, 44)),
        zh_leftViewMode: @(UITextFieldViewModeAlways),
        zh_backgroundColor: kColor_FFFFFF,
        zh_superView: self.view,
        zh_font: @15,
        zh_leftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 44)]
    }];
    
    self.cardView = [UIView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.nameField.bottom + 5, zh_ScreenWidth, 80)),
        zh_backgroundColor: kColor_FFFFFF,
        zh_superView: self.view,
    }];
    
    self.bankLabel = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, 0, zh_ScreenWidth - 15, 34)),
        zh_superView: self.cardView,
        zh_textColor: kColor_000000,
        zh_font: @14,
    }];
    
    self.accountLabel = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, 34, zh_ScreenWidth - 15, 80 - 34)),
        zh_superView: self.cardView,
        zh_textColor: kColor_333333,
    }];
    
    [self.cardView zh_addLineWithFrame:CGRectMake(15, self.bankLabel.bottom, zh_ScreenWidth - 15 * 2, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.card) {
        [self fetchRequest];
    }
}

- (void)rightNavigationButtonAction {
    EditCardViewController *vc = [[EditCardViewController alloc] initWithCard:self.card];
    
    vc.operationSuccessBlock = ^{
        [self fetchRequest];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fetchRequest {
    [Util POST:@"/api/User/user_bankcark" showHUD:YES showResultAlert:YES parameters:@{} result:^(NSArray *responseObject) {
        if (responseObject) {
            self.card = responseObject.count > 0 ? responseObject[0] : nil;
        }
    }];
}

- (void)setCard:(NSDictionary *)card {
    _card = [card copy];
    
    if (card) {
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"持卡人：" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:card[kName] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}]];
        self.nameField.attributedText = aString;
        
        self.bankLabel.text = card[@"bankname"];
        
        aString = [[NSMutableAttributedString alloc] initWithString:@"卡号：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:card[@"bankcard_number"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:21]}]];
        self.accountLabel.attributedText = aString;
        
    }
    
    self.nameField.hidden = self.cardView.hidden = !card;
    
    [self.rightNavigationButton setTitle:(card ? @"编辑" : @"添加") forState:UIControlStateNormal];
}

@end
