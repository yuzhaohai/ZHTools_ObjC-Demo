//
//  SpecSelectView.m
//  Project
//
//  Created by 于兆海 on 2021/3/16.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "SpecSelectView.h"
#import "SpecSelectViewCell.h"
#import "EditAddressViewController.h"
#import "ConfirmOrderViewController.h"
#import "PurchaseListViewController.h"

@interface SpecSelectView ()

@property (copy, nonatomic) NSDictionary *goodsInfo;

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSMutableArray *specArray;

@property (copy, nonatomic) NSArray *addressArray;

@end

@implementation SpecSelectView

- (instancetype)initWithGoodsInfo:(NSDictionary *)info {
    self = [super initWithFrame:zh_ScreenBounds];
    if (self) {
        self.goodsInfo = info;
        
        self.backgroundColor = [UIColor zh_colorWithHexString:kColor_000000 alpha:.5];
        
        UIButton *button = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, ceil(zh_ScreenHeight / 3.0))),
            zh_backgroundColor: [UIColor clearColor],
            zh_superView: self
        }];
        [button addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.tableView];
        self.tableView.frame = CGRectMake(0, button.bottom, zh_ScreenWidth, zh_ScreenHeight - button.height);
        
        UIView *view = self.tableView.tableFooterView;
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, .5) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
        
        CGFloat width = ceil(zh_ScreenWidth / 2.0);
        for (int i = 0; i < 2; i++) {
            ZHButton *button = [ZHButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(i * width, self.height - view.height, width, view.height)),
                zh_normalTitle: (@[@"加入进货单", @"前往进货单"][i]),
                zh_backgroundColor: (@[@"#FF7E30", kColor_Red][i]),
                zh_normalTitleColor: kColor_FFFFFF,
                zh_titleFont: @16,
                zh_superView: self,
                zh_tag: @(i + 1)
            }];
            button.titleRect = CGRectMake(0, 0, button.width, 49);
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([info[@"ms_end_time"] integerValue] > 10000) {
                [button setPropertyWithDictionary:@{
                    zh_frame: NSStringFromCGRect(CGRectMake(0, self.height - view.height, zh_ScreenWidth, view.height)),
                    zh_normalTitle: @"立即购买",
                    zh_tag: @0,
                }];
                
                button.titleRect = CGRectMake(0, 0, zh_ScreenWidth, 49);
            }
        }
    }
    return self;
}

- (void)tappedButton:(UIButton *)button {
    //@"立即购买",@"加入进货单", @"前往进货单"
    if (button.tag == 0) {
        
        if (self.addressArray.count < 1) {
            
            [self fetchAddressArray];
            
        } else {
            
            [Util POST:@"/api/Order/now_pay" showHUD:YES showResultAlert:YES parameters:@{
                @"is_miaosha": @1,
                @"goods_id": self.goodsInfo[@"id"],
                @"shop_id": self.goodsInfo[@"shop_id"],
                @"specs_info": [self.specArray zh_jsonStringValue],
            } result:^(id responseObject) {
                if (responseObject) {
                    
                    double total = .0, amount = .0;
                    for (NSDictionary *info in self.specArray) {
                        
                        amount += [info[@"amount"] integerValue];
                        
                        total += ([info[@"amount"] integerValue] * [info[@"price"] doubleValue]);
                        
                    }
                    
                    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"合计：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
                    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f\n", total] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
                    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@种 %.0f件", @(self.specArray.count), amount] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                    paragraphStyle.alignment = NSTextAlignmentRight;
                    paragraphStyle.lineSpacing = 5;
                    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
                    
                    ConfirmOrderViewController *vc = [[ConfirmOrderViewController alloc] initWithArray:responseObject];
                    vc.isMiaoSha = YES;
                    vc.label.attributedText = aString;
                    vc.operationSuccessBlock = ^{
                        [self removeFromSuperview];
                    };
                    [[ZHTools getCurrentViewController].navigationController pushViewController:vc animated:YES];
                }
            }];
            
        }
        
    } else if (button.tag == 1) {
        
        if (self.specArray.count > 0) {
            
            [Util POST:@"/api/Cart/intocart" showHUD:YES showResultAlert:YES parameters:@{
                @"goods_id": self.goodsInfo[@"id"],
                @"shop_id": self.goodsInfo[@"shop_id"],
                @"specs_info": [self.specArray zh_jsonStringValue],
            } result:^(id responseObject) {
                if (responseObject) {
                    [self removeFromSuperview];
                }
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"请添加商品数量"];
        }
        
    } else {
        
        [[ZHTools getCurrentViewController].navigationController pushViewController:[[PurchaseListViewController alloc] initWithNoTabbar] animated:YES];
        
    }
}

- (void)fetchAddressArray {
    [Util POST:@"/api/User/address_list" showHUD:YES showResultAlert:YES parameters:@{} result:^(NSArray *responseObject) {
        if (responseObject) {
            if (responseObject.count == 0) {
                
                [SVProgressHUD showErrorWithStatus:@"请设置收货地址"];
                
                EditAddressViewController *vc = [[EditAddressViewController alloc] init];
                vc.operationSuccess = ^{
                    
                };
                [[ZHTools getCurrentViewController].navigationController pushViewController:vc animated:YES];
                
            } else {
                self.addressArray = responseObject;
                [self tappedButton:[UIButton buttonWithType:UIButtonTypeCustom]];
            }
        }
    }];
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_backgroundColor: kColor_FFFFFF,
            zh_separatorColor: kColor_EAEAEA,
            zh_tableFooterView: [UIView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight * .5 + 49))
            }],
            zh_dataSource: self,
            zh_delegate: self,
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.goodsInfo[@"specs"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"SpecSelectViewCell";
    SpecSelectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell) {
        cell = [[SpecSelectViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.amountChangeBlock = ^(NSString * _Nonnull amount, NSDictionary * _Nonnull info) {
            
            NSString *specs = info[@"id"];
            for (NSDictionary *dict in self.specArray) {
                if ([specs integerValue] == [dict[@"specs"] integerValue]) {
                    [self.specArray removeObject:dict];
                    break;
                }
            }
            
            if ([amount integerValue] > 0) {
                
                [self.specArray addObject:@{@"amount": amount, @"specs": specs, @"price": info[@"price"]}];
                
            }
        };
    }
    
    NSArray *array = self.goodsInfo[@"specs"];
    cell.info = array[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30 + 95;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 30 + 95)),
        zh_backgroundColor: kColor_FFFFFF,
    }];
    
    UIButton *button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 30, 5, 20, 20)),
        zh_borderColor: kColor_808080,
        zh_normalImage: @"关闭",
        zh_borderWidth: @1,
        zh_cornerRadius: @10,
        zh_superView: view,
        zh_masksToBounds: @1,
    }];
    [button addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [UIImageView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(10, 30 + 10, 70, 70)),
        zh_backgroundColor: kColor_F5F5F5,
        zh_cornerRadius: @5,
        zh_masksToBounds: @1,
        zh_superView: view,
    }];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.goodsInfo[@"image"]]];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(imageView.right + 10, imageView.top, zh_ScreenWidth - imageView.right - 10, 36)),
        zh_textColor: kColor_000000,
        zh_font: @13,
        zh_superView: view,
        zh_text: self.goodsInfo[kName],
        zh_numberOfLines: @2,
    }];
    
    label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(label.left, imageView.bottom - 15, label.width, 15)),
        zh_textColor: kColor_Red,
        zh_font: @13,
        zh_superView: view,
        zh_text: [NSString stringWithFormat:@"¥%@-¥%@", self.goodsInfo[@"min_price"], self.goodsInfo[@"max_price"]],
    }];
    
    label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(label.left, label.top - 19, label.width - 10, 19)),
        zh_textColor: kColor_000000,
        zh_font: @12,
        zh_superView: view,
        zh_textAlignment: @(NSTextAlignmentRight),
        zh_text: [NSString stringWithFormat:@"货号%@", self.goodsInfo[@"good_number"]],
    }];
    
    [view zh_addLineWithFrame:CGRectMake(0, view.height - .5, zh_ScreenWidth, .5) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    
    return view;
}

- (NSMutableArray *)specArray {
    if (!_specArray) {
        _specArray = [NSMutableArray array];
    }
    return _specArray;
}

@end
