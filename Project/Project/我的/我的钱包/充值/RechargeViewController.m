//
//  RechargeViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "RechargeViewController.h"
#import <AlipaySDK/AlipaySDK.h>

#import <mob_sharesdk/WXApiObject.h>
#import <mob_sharesdk/WXApi.h>

@interface RechargeViewController ()

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) ZHButton *wechatButton;
@property (strong, nonatomic) ZHButton *aliButton;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"充值";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    self.textField = [UITextField viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 5, zh_ScreenWidth, 56)),
        zh_rightViewMode: @(UITextFieldViewModeAlways),
        zh_textAlignment: @(NSTextAlignmentRight),
        zh_backgroundColor: kColor_FFFFFF,
        zh_textColor: kColor_000000,
        zh_superView: self.view,
        zh_font: @15,
        
        zh_rightView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 56)],
        
        zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入充值金额" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_999999]}]
    }];
    
    [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 168, 56)),
        zh_superView: self.textField,
        zh_textColor: kColor_000000,
        zh_text: @"金额",
        zh_font: @15
    }];
    
    [self.view zh_addLineWithFrame:CGRectMake(0, self.textField.bottom + 5, zh_ScreenWidth, 56) color:[UIColor whiteColor]];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(15, self.textField.bottom + 5, zh_ScreenWidth - 15, 56)),
        zh_textColor: kColor_808080,
        zh_superView: self.view,
        zh_text: @"支付方式",
        zh_font: @15
    }];
        
    NSArray *array = @[@"微信支付", @"支付宝支付"];
    for (int i = 0; i < array.count; i++) {
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, label.bottom + 1, zh_ScreenWidth, 56)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_normalTitle: array[i],
            zh_selectedTitle: array[i],
            zh_normalImage: @"ico_chose",
            zh_selectedImage: @"ico_chosen",
            zh_superView: self.view,
            zh_titleFont: @14,
            zh_selected: @(i == 0),
            zh_normalTitleColor: kColor_333333,
        }];
        [button addTarget:self action:@selector(tappedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        button.titleRect = CGRectMake(56, 0, 168, 56);
        button.imageRect = CGRectMake(zh_ScreenWidth - 20 - 18, 19, 18, 18);
        
        [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(20, 15, 26, 26)),
            zh_contentMode: @(UIViewContentModeCenter),
            zh_superView: button,
            zh_image: array[i],
        }];
        
        if (i == 0) {
            
            self.wechatButton = button;
            
        } else {
            
            button.top = self.wechatButton.bottom + 1;
            self.aliButton = button;
            
        }
    }
    
    CGFloat height = SafeAreaHeight * .8 + 44;
    ZHButton *button = [ZHButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"确认充值",
        zh_titleFont: @16,
        zh_tag: @(-1)
    }];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleRect = CGRectMake(0, 0, zh_ScreenWidth, 44 + SafeAreaHeight * .3);
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAliPayCallBackNotification:) name:kAliPayCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXPayCallBackNotification:) name:kWXAuthorizationPay object:nil];
}

- (void)tappedTypeButton:(UIButton *)button {
    self.wechatButton.selected = button == self.wechatButton;
    self.aliButton.selected = button == self.aliButton;
}

- (void)tappedButton:(UIButton *)button {
    if ([self.textField.text doubleValue] <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入充值金额"];
        return;
    }
    
    __block NSInteger pay_type = self.wechatButton.selected ? 2 : 1;
    
    [Util POST:@"/api/Order/user_recharge" showHUD:YES showResultAlert:YES parameters:@{
        @"pay_type": @(pay_type),
        @"money": self.textField.text
    } result:^(id responseObject) {
        if (responseObject) {
            
            if (pay_type == 1) {
                
                [[AlipaySDK defaultService] payOrder:responseObject[@"pay_str"] fromScheme:kAliPay_Scheme callback:^(NSDictionary *resultDic) {
                    
                    NSLog(@"vc - %@", resultDic);
                    
                }];
                
            } else {
                
                NSDictionary *dict = responseObject;
                PayReq *req   = [[PayReq alloc] init];
                req.openID = dict[@"appid"];
                req.partnerId = dict[@"partnerid"];
                req.prepayId  = dict[@"prepayid"];
                req.package   = dict[@"package"];
                req.nonceStr  = dict[@"noncestr"];
                req.timeStamp = [dict[@"timestamp"] intValue];
                // 签名加密
                req.sign = dict[@"sign"];// [self md5:dict[@"sign"]];
                
                [WXApi sendReq:req completion:^(BOOL success) {
                    
                    if (success) {
                        
                        
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"支付失败"];
                    }
                    
                }];
            }
            
        }
    }];
}

-(void)onAliPayCallBackNotification:(NSNotification*)notify {
    NSString *string = notify.object[@"result"];
    
    NSDictionary *info = [NSDictionary zh_dictionaryFromJson:string];
    
    NSDictionary *alipay_trade_app_pay_response = info[@"alipay_trade_app_pay_response"];
    
    if ([alipay_trade_app_pay_response[@"code"] integerValue] == 10000) {
        [SVProgressHUD showSuccessWithStatus:@"充值成功"];
        
        if (self.operationSuccessBlock) {
            self.operationSuccessBlock();
        }
        
        [self goBack];
    }
}

- (void)onWXPayCallBackNotification:(NSNotification*)notify {
    NSInteger errCode = [notify.userInfo[@"code"] integerValue];
    
    if (errCode == 0) {
        [SVProgressHUD showSuccessWithStatus:@"充值成功"];
        
        if (self.operationSuccessBlock) {
            self.operationSuccessBlock();
        }
        
        [self goBack];
    }
}

@end
