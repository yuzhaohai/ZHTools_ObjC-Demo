//
//  OrderTableFooterView.m
//  Project
//
//  Created by 于兆海 on 2021/1/28.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "OrderTableFooterView.h"
#import "TypeinExpressViewController.h"
#import "ApplyExchangeViewController.h"


@interface OrderTableFooterView ()

@property (assign, nonatomic) BOOL *isExchangeOrder;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *aLabel;

@property (copy, nonatomic) NSMutableArray *buttonArray;

@end

@implementation OrderTableFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage zh_imageWithColor:[UIColor whiteColor] size:CGSizeMake(zh_ScreenWidth, 77)]];
        
        [self zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        
        self.label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(90, 1, zh_ScreenWidth - 90 - 10, 40)),
            zh_superView: self.contentView,
            zh_textColor: kColor_000000,
            zh_font: @14,
        }];
        
        self.aLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(90, 1, zh_ScreenWidth - 90 - 10, 40)),
            zh_superView: self.contentView,
            zh_font: @14,
        }];
        
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {
    _info = [info copy];
    
    BOOL isRefound = [[info allKeys] containsObject:@"refund_id"];
        
    NSArray *array;
    
    NSInteger status = [info[@"status"] integerValue];
        
    if (isRefound) {
        
        self.aLabel.frame = CGRectMake(90, 1, zh_ScreenWidth - 90 - 10, 40);
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"退款金额：" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"：¥%.2f", [info[@"refund_money"] doubleValue]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
        self.aLabel.attributedText = aString;
        [self.aLabel sizeToFit];
        self.aLabel.frame = CGRectMake(self.label.right - self.aLabel.width, 1, self.aLabel.width, 40);
        
        self.label.text = @"";
        
        array = @[@[@"取消"], @[], @[], @[@"录入退件"], @[], @[], @[], @[], @[], @[]][status];
                
    } else {
        
        NSInteger amount = 0;
        NSArray *goods_list = info[@"goods_list"];
        for (NSDictionary *goodsInfo in goods_list) {
            amount += [goodsInfo[@"amount"] integerValue];
        }
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@种 %@件商品  合计：", @(goods_list.count), @(amount)] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@", info[@"pay_true"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]}]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
        self.aLabel.attributedText = aString;
        
        array = @[@[@"立即付款", @"取消订单"], @[@"取消订单"], @[@"确认收货"], @[@"申请售后"], @[], @[], @[], @[], @[], @[]][status];
        
        BOOL user_refund = ![info[@"user_refund"] boolValue];
        
        if ([array containsObject:@"申请售后"] && (!user_refund)) {
            array = @[];
        }
        
    }
    
    for (UIView *view in self.buttonArray) {
        view.hidden = YES;
    }
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *button;
        if (self.buttonArray.count > idx) {
            
            button = (UIButton *)(self.buttonArray[idx]);
            
        } else {
            
            button = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 90 * (idx + 1), 41, 80, 26)),
                zh_normalTitleColor: kColor_666666,
                zh_superView: self.contentView,
                zh_borderColor: kColor_EAEAEA,
                zh_normalTitle: obj,
                zh_titleFont: @13,
                zh_borderWidth: @1,
                zh_cornerRadius: @13,
                zh_masksToBounds: @1,
            }];
            [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.buttonArray addObject:button];
            
        }
        
        BOOL isRed = [@[@"确认收货", @"立即付款"] containsObject:obj];
        
        [button setPropertyWithDictionary:@{
            zh_hidden: @0,
            zh_normalTitle: obj,
            zh_borderColor: (isRed ? kColor_Red : kColor_EAEAEA),
            zh_normalTitleColor: (isRed ? kColor_Red : kColor_666666),
        }];
        
    }];
}

- (void)tappedButton:(UIButton *)button {
    NSArray *array = @[@"取消", @"录入退件", @"取消订单", @"立即付款", @"申请售后", @"确认收货"];
    NSInteger index = [array indexOfObject:button.titleLabel.text];
    
    switch (index) {
        case 0:{
            
            [Util POST:@"/api/refund/refund_cancel" showHUD:YES showResultAlert:YES parameters:@{
                @"refund_id": self.info[@"refund_id"]
            } result:^(id responseObject) {
                if (responseObject) {
                    if (self.refreshDataBlock) {
                        self.refreshDataBlock();
                    }
                }
            }];
            
            break;
        }
        case 1:{
            
            TypeinExpressViewController *vc = [TypeinExpressViewController new];
            vc.refoundID = self.info[@"refund_id"];
            vc.operationSuccessBlock = ^{
                if (self.refreshDataBlock) {
                    self.refreshDataBlock();
                }
            };
            [[self zh_viewController].navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case 2:{
            
            [Util POST:@"/api/Order/order_cancel" showHUD:YES showResultAlert:YES parameters:@{
                @"order_id": self.info[@"order_id"]
            } result:^(id responseObject) {
                if (responseObject) {
                    if (self.refreshDataBlock) {
                        self.refreshDataBlock();
                    }
                }
            }];
            
            break;
        }
        case 3:{
            
            if (self.payOrder) {
                self.payOrder(self.info);
            }
            
            break;
        }
        case 4:{
            
            ApplyExchangeViewController *vc = [[ApplyExchangeViewController alloc] initWithOrder:self.info[@"order_id"] step:1];
            [[self zh_viewController].navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case 5:{
            
            [Util POST:@"/api/Order/order_finish" showHUD:YES showResultAlert:YES parameters:@{
                @"order_id": self.info[@"order_id"]
            } result:^(id responseObject) {
                if (responseObject) {
                    if (self.refreshDataBlock) {
                        self.refreshDataBlock();
                    }
                }
            }];
            
            break;
        }
            
        default:
            break;
    }
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

@end
