//
//  ConfirmOrderViewController.m
//  Project
//
//  Created by 于兆海 on 2021/3/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "BaseTableViewHeaderFooterView.h"
#import "PurchaseListViewCell.h"
#import "AddressViewController.h"
#import <AlipaySDK/AlipaySDK.h>

#import <mob_sharesdk/WXApiObject.h>
#import <mob_sharesdk/WXApi.h>

@interface ConfirmOrderViewController ()

@property (copy, nonatomic) NSArray *array;

@property (copy, nonatomic) NSDictionary *address;
@property (copy, nonatomic) NSArray *addressArray;
@property (strong, nonatomic) ZHButton *addressButton;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIView *footer;
@property (strong, nonatomic) ZHButton *redPacketButton;
@property (strong, nonatomic) ZHButton *selectedPayTypeButton;

@property (copy, nonatomic) NSMutableDictionary *shopCouponDictionary;

@property (copy, nonatomic) NSDictionary *orderInfo;

@property (copy, nonatomic) NSDictionary *userInfo;

@property (copy, nonatomic) NSNumber *payType;

@end

@implementation ConfirmOrderViewController

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        self.array = array;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"提交订单";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAliPayCallBackNotification:) name:kAliPayCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXPayCallBackNotification:) name:kWXAuthorizationPay object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.userInfo) {
        [self fetchUserInfo];
    }
}

- (void)fetchUserInfo {
    [Util POST:@"/api/User/index" showHUD:YES showResultAlert:NO parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            
            self.userInfo = responseObject;
            [AppDelegate appDelegate].userInfo = responseObject;
            
            [self.view addSubview:self.tableView];
            
            [self fetchRequest];
            
        } else {
            
            [SVProgressHUD showErrorWithStatus:@"数据有误"];
            
            [self goBack];
            
        }
    }];
}

- (void)fetchRequest {
    [Util POST:@"/api/User/address_list" showHUD:YES showResultAlert:YES parameters:@{} result:^(NSArray *responseObject) {
        if (responseObject) {
            self.addressArray = responseObject;
            
            for (NSDictionary *info in responseObject) {
                if ([info[@"is_default"] boolValue]) {
                    self.address = info;
                    break;
                }
            }
        }
    }];
}

- (void)calculatTotalMoney {
    double total = 0.0, kind = .0, amount = .0;
    for (NSDictionary *shop in self.array) {
        for (NSDictionary *goodsInfo in shop[@"goods"]) {
            for (NSDictionary *specsInfo in goodsInfo[@"goods_specs"]) {
                kind += 1;
                amount += [specsInfo[@"amount"] integerValue];
                total += ([specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue]);
            }
        }
    }
    
    for (NSDictionary *coupon in [self.shopCouponDictionary allValues]) {
        if ([coupon[@"type_two"] integerValue] == 0) {
            total -= [coupon[@"money"] doubleValue];
        }
    }
    
    if (self.redPacketButton.selected) {
        double money_red = [[AppDelegate appDelegate].userInfo[@"money_red"] doubleValue];
        
        total -= money_red;
        
        total = MAX(total, 0);
    }
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"合计：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f\n", total] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f种 %.0f件", kind, amount] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    self.label.attributedText = aString;
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *shop = self.array[section];
    NSArray *goods = shop[@"goods"];
    
    return goods.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSDictionary *shop = self.array[section];
    NSArray *goods = shop[@"goods"];
    
    NSDictionary *goodsInfo = goods[row];
    NSArray *specsArray = goodsInfo[@"goods_specs"];
    
    return 90 + 65 * specsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"PurchaseListViewCell";
    PurchaseListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell) {
        cell = [[PurchaseListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSDictionary *shop = self.array[section];
    NSArray *goods = shop[@"goods"];
    
    NSDictionary *goodsInfo = goods[row];
    [cell setGoodsInfo:goodsInfo];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *shop = self.array[section];
    
    NSArray *shop_coupon = shop[@"shop_coupon"];
    BOOL showCoupon = shop_coupon.count > 0;
    
    return showCoupon ? (5 + 30 + 33) : (5 + 30);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *Identifier = @"UITableViewHeaderView";
    BaseTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    NSInteger tag = 5201314;
    
    if (!view) {
        view = [[BaseTableViewHeaderFooterView alloc] initWithReuseIdentifier:Identifier];
        view.bgColor = [UIColor whiteColor];
        
        UILabel *label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 5, zh_ScreenWidth - 10 * 2, 30)),
            zh_textColor: kColor_333333,
            zh_font: @14,
            zh_superView: view,
            zh_text: @"商家：华硕科技",
            zh_tag: @(tag)
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, label.bottom - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, label.bottom, zh_ScreenWidth, 33)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: @"#FF7E30",
            zh_superView: view,
            zh_normalImage: @"more_white",
            zh_titleFont: @13,
            zh_tag: @(tag + 1)
        }];
        button.titleRect = CGRectMake(10, 0, zh_ScreenWidth - 10 - 7 - 10, 33);
        button.imageRect = CGRectMake(zh_ScreenWidth - 10 - 7, 13, 7, 7);
        
        [button zh_addTapGestureRecognizerWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            
            NSDictionary *shop = self.array[gestureRecoginzer.view.superview.tag];
            
            NSArray *shop_coupon = shop[@"shop_coupon"];
            
            NSMutableString *string = [NSMutableString string];
            
            for (NSDictionary *info in shop_coupon) {
                BOOL flag = [info[@"type_two"] integerValue] == 0;
                
                [string appendFormat:@"满%.0f%@%@\n", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
            }
            
            if (string.length > 0) {
                
                [ZHAlertController alertTitle:@"" message:string cancleButtonTitle:@"确定"];
                
            }
            
        }];
    }
    
    NSDictionary *shop = self.array[section];
    
    NSArray *shop_coupon = shop[@"shop_coupon"];
    BOOL showCoupon = shop_coupon.count > 0;
    
    view.tag = section;
    view.height = showCoupon ? (5 + 30 + 33) : (5 + 30);
    
    UILabel *label = [view viewWithTag:tag];
    label.text = [NSString stringWithFormat:@"商家：%@", shop[kName]];
    
    UIButton *button = [view viewWithTag:(tag + 1)];
    button.hidden = !showCoupon;
    
    if (showCoupon) {
        
        NSMutableString *string = [NSMutableString stringWithString:@"本店铺购"];
        
        for (NSDictionary *info in shop_coupon) {
            BOOL flag = [info[@"type_two"] integerValue] == 0;
            
            [string appendFormat:@"满%.0f%@%@  ", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
        }
        
        [button setTitle:string forState:UIControlStateNormal];
        
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    static NSString *Identifier = @"UITableViewFooterView";
    BaseTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    if (!view) {
        view = [[BaseTableViewHeaderFooterView alloc] initWithReuseIdentifier:Identifier];
        
        view.bgColor = [UIColor whiteColor];
        
        [view.button setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth - 168 - 10, 40)),
            zh_normalTitleColor: kColor_808080,
            zh_titleFont: @14,
        }];
        view.button.titleRect = CGRectMake(10, 0, view.button.width - 10, 40);
        [view.button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [view.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(view.button.right, 0, zh_ScreenWidth - view.button.right - 20, 40)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_font: @14,
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        [view zh_addLineWithFrame:CGRectMake(0, 40 - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    }
    
    NSDictionary *shop = self.array[section];
    NSString *shop_id = [shop[@"id"] stringValue];
    
    NSArray *goodsArray = shop[@"goods"];
    
    double money = 0.0, discount = 0.0;
    for (NSDictionary *goodsInfo in goodsArray) {
        
        NSArray *specsArray = goodsInfo[@"goods_specs"];
        
        for (NSDictionary *specsInfo in specsArray) {
            
            money += ([specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue]);
            
        }
        
    }
    
    NSDictionary *coupon = self.shopCouponDictionary[shop_id];
    if (money < [coupon[@"money_max"] doubleValue]) {
        [self.shopCouponDictionary removeObjectForKey:shop_id];
        coupon = nil;
    }
    
    NSString *couponInfo = @"未使用优惠";
    
    if (coupon) {
        BOOL flag = [coupon[@"type_two"] integerValue] == 0;
        
        if (flag) {
            
            couponInfo = [NSString stringWithFormat:@"减%@", coupon[@"money"]];
            discount = [coupon[@"money"] doubleValue];
            
        } else {
            
            couponInfo = [NSString stringWithFormat:@"赠%@", coupon[@"give_goods_name"]];
            
        }
    }
    
    [view.button setPropertyWithDictionary:@{
        zh_normalTitle: [NSString stringWithFormat:@"总额：¥%.2f  %@", 1.0 * money, couponInfo],
        zh_tag: @(section),
    }];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"小计：" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f", (money - discount)] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    view.label.attributedText = aString;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tappedFooterButton:(UIButton *)button {
    __block NSDictionary *shop = self.array[button.tag];
    
    NSArray *shop_coupon = shop[@"shop_coupon"];
    
    if (shop_coupon.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"无优惠活动"];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择优惠" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    if (shop_coupon.count == 1) {
        alertController = [UIAlertController alertControllerWithTitle:@"选择优惠" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    for (NSDictionary *info in shop_coupon) {
        BOOL flag = [info[@"type_two"] integerValue] == 0;
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"满%.0f%@%@\n", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *shop_id = [shop[@"id"] stringValue];
            
            NSArray *goodsArray = shop[@"goods"];
            
            double money = 0.0;
            for (NSDictionary *goodsInfo in goodsArray) {
                
                NSArray *specsArray = goodsInfo[@"goods_specs"];
                
                for (NSDictionary *specsInfo in specsArray) {
                    
                    money += ([specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue]);
                    
                }
                
            }
            
            if (money < [info[@"money_max"] doubleValue]) {
                [SVProgressHUD showErrorWithStatus:@"商品总金额不足，不可使用此优惠"];
            } else {
                self.shopCouponDictionary[shop_id] = info;
                
                [self.tableView reloadData];
                
                [self calculatTotalMoney];
            }
        
        }]];
        
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tappedAddressButton:(UIButton *)button {
    AddressViewController *vc = [[AddressViewController alloc] init];
    vc.didSelect = ^(NSDictionary * _Nonnull info) {
        self.address = info;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tappedRedPacketButton:(UIButton *)button {
    button.selected = !button.selected;
    [self calculatTotalMoney];
}

- (void)tappedPayTypeButton:(ZHButton *)button {
    self.selectedPayTypeButton.selected = NO;
    
    self.selectedPayTypeButton = button;
    button.selected = YES;
}

- (void)tappedJSButton:(UIButton *)button {
    if (!self.address) {
        [SVProgressHUD showErrorWithStatus:@"请选择收货地址"];
        return;
    }
    
    NSDictionary *user = [AppDelegate appDelegate].userInfo;
    
    double total = .0;
    
    NSMutableArray *mArray = [NSMutableArray array];
    for (NSDictionary *shop in self.array) {
        
        NSString *shop_id = [shop[@"id"] stringValue];
        NSDictionary *coupon = self.shopCouponDictionary[shop_id];
        
        NSMutableArray *goodsArray = [NSMutableArray array];
        
        double money = .0, discount = [coupon[@"money"] doubleValue];
        
        for (NSDictionary *goodsInfo in shop[@"goods"]) {
            
            for (NSDictionary *specsInfo in goodsInfo[@"goods_specs"]) {
                
                double aMoney = [specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue];
                
                money += aMoney;
                
                [goodsArray addObject:@{
                    @"shop_id": specsInfo[@"shop_id"],
                    @"goods_id": specsInfo[@"goods_id"],
                    kName: goodsInfo[kName],
                    @"specs_id": specsInfo[@"specs"],
                    @"specs": specsInfo[@"specs_name"],
                    @"image": (goodsInfo[@"image"] ? : @""),
                    @"total": @(aMoney),
                    @"pay_true": @(aMoney),
                    @"pay_price": specsInfo[@"price"],
                    @"amount": (specsInfo[@"amount"]),
                    @"image_thumb": (goodsInfo[@"image_thumb"] ? : @""),
                    @"cart_id": (specsInfo[@"id"] ? : @""),
                    @"type": (specsInfo[@"id"] ? @0 : @1)
                }];
                
            }
            
        }
        
        total += (money - discount);
        
        [mArray addObject:@{
            @"shop_id": shop_id,
            @"address_id": self.address[@"address_id"],
            @"person": self.address[@"person"],
            @"phone": self.address[@"phone"],
            @"province": self.address[@"province"],
            @"city": self.address[@"city"],
            @"district": self.address[@"district"],
            @"addr": self.address[@"addr"],
            @"coupon_id": (coupon ? coupon[@"id"] : @""),
            @"coupon": (coupon[@"money"] ? : @"0"),
            @"coupon_goods_id": (coupon ? coupon[@"give_goods_id"] : @""),
            @"total": @(money),
            @"pay_true": @(money - discount),
            @"order_goods": [goodsArray zh_jsonStringValue]
        }];
        
    }
    
    double money_red = [user[@"money_red"] doubleValue];
    if (self.redPacketButton.selected) {
        money_red = MIN(total, money_red);
        
        total -= money_red;
    }
    
    self.payType = (total == 0 ? @0 : (@[@2, @1, @0][self.selectedPayTypeButton.tag]));
    
    [Util POST:@"/api/Order/order_create" showHUD:YES showResultAlert:YES parameters:@{
        @"is_miaosha": @(self.isMiaoSha),
        @"red_money": (self.redPacketButton.selected ? @(money_red) : @0),
        @"is_sum": @(self.array.count == 1),
        @"union_pay_true": @(total),
        @"order": [mArray zh_jsonStringValue],
        @"pay_type": self.payType,
    } result:^(id responseObject) {
        if (responseObject) {
            
            if (self.operationSuccessBlock) {
                self.operationSuccessBlock();
            }
            
            [self payOrder:responseObject];
            
        }
    }];
}

- (void)payOrder:(NSDictionary *)order {
    self.orderInfo = order;
        
    [Util POST:@"/api/Order/order_pay_union" showHUD:YES showResultAlert:YES parameters:@{
        @"union_orderno": order[@"union_orderno"],
        @"pay_type": self.payType,
    } result:^(id responseObject) {
        if (responseObject) {
            
            NSInteger payType = [self.payType integerValue];
            
            if (payType == 2) {
                
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
            } else if (payType == 1) {
                
                [[AlipaySDK defaultService] payOrder:responseObject[@"pay_str"] fromScheme:kAliPay_Scheme callback:^(NSDictionary *resultDic) {
                    
                    NSLog(@"vc - %@", resultDic);
                    
                }];
                
            } else {
                
                [self paySuccess];
                
            }
            
        }
    }];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat height = SafeAreaHeight * .5 + 49;
        
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1 - height)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: self.footer,
            zh_tableHeaderView: self.addressButton,
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (ZHButton *)addressButton {
    if (!_addressButton) {
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 66 + 5)),
            zh_normalTitleColor: kColor_333333,
            zh_backgroundColor: kColor_FFFFFF,
            zh_titleFont: @14,
            zh_normalTitle: @"请选择收货地址",
            zh_normalImage: @"more"
        }];
        button.titleRect = CGRectMake(20, 0, zh_ScreenWidth - 20 * 2 - 7, 66);
        button.titleLabel.numberOfLines = 2;
        button.imageRect = CGRectMake(zh_ScreenWidth - 20 - 7, 29.5, 7, 7);
        [button addTarget:self action:@selector(tappedAddressButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [button zh_addLineWithFrame:CGRectMake(0, 66, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        
        _addressButton = button;
    }
    return _addressButton;
}

- (UIView *)footer {
    if (!_footer) {
        _footer = [UIView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, (SafeAreaHeight * .5 + 5 + 44 + 5 + 45 * 4 + 49)))
        }];
        
        NSDictionary *user = [AppDelegate appDelegate].userInfo;
        
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 5, zh_ScreenWidth, 44)),
            zh_normalTitleColor: kColor_333333,
            zh_backgroundColor: kColor_FFFFFF,
            zh_selectedImage: @"ico_chosen",
            zh_normalImage: @"ico_chose",
            zh_superView: _footer,
            zh_titleFont: @14,
            zh_normalTitle: [NSString stringWithFormat:@"可用红包：¥%.2f元", [user[@"money_red"] doubleValue]],
        }];
        button.titleRect = CGRectMake(15, 0, zh_ScreenWidth / 2.0, 44);
        button.imageRect = CGRectMake(zh_ScreenWidth - 15 - 18, 13, 18, 18);
        [button addTarget:self action:@selector(tappedRedPacketButton:) forControlEvents:UIControlEventTouchUpInside];
        self.redPacketButton = button;
        
        button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, button.bottom + 5, zh_ScreenWidth, 44)),
            zh_normalTitleColor: kColor_333333,
            zh_backgroundColor: kColor_FFFFFF,
            zh_titleFont: @14,
            zh_superView: _footer,
            zh_normalTitle: @"支付方式",
        }];
        button.titleRect = CGRectMake(15, 0, zh_ScreenWidth / 2.0, 44);
        
        NSArray *array = @[@"微信支付", @"支付宝支付", @"余额支付"];
        for (int i = 0; i < array.count; i++) {
            
            NSString *string = array[i];
            
            ZHButton *buttonX = [ZHButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, button.bottom + 1 + i * 45, zh_ScreenWidth, 44)),
                zh_normalTitleColor: kColor_333333,
                zh_backgroundColor: kColor_FFFFFF,
                zh_normalTitle: string,
                zh_normalImage: string,
                zh_superView: _footer,
                zh_titleFont: @13,
            }];
            buttonX.imageRect = CGRectMake(15, 9, 26, 26);
            buttonX.titleRect = CGRectMake(51, 0, 168, 44);
            
            ZHButton *buttonY = [ZHButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, buttonX.top, zh_ScreenWidth, 44)),
                zh_normalTitleColor: kColor_333333,
                zh_backgroundColor: [UIColor clearColor],
                zh_selectedImage: @"ico_chosen",
                zh_normalImage: @"ico_chose",
                zh_superView: _footer,
                zh_titleFont: @12,
                zh_selected: @(i == 0),
                zh_tag: @(i)
            }];
            buttonY.imageRect = CGRectMake(zh_ScreenWidth - 15 - 18, 13, 18, 18);
            [buttonY addTarget:self action:@selector(tappedPayTypeButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i == 2) {
                buttonY.titleLabel.textAlignment = NSTextAlignmentRight;
                buttonY.titleRect = CGRectMake(0, 0, zh_ScreenWidth - 15 - 18 - 10, 44);
                [buttonY setTitle:[NSString stringWithFormat:@"余额：%.2f", [user[@"money"] doubleValue]] forState:UIControlStateNormal];
            } else if (i == 0) {
                self.selectedPayTypeButton = buttonY;
            }
            
        }
    }
    return _footer;
}

- (UILabel *)label {
    if (!_label) {
        UIButton *jsButton = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 125, zh_ScreenHeight - SafeAreaHeight * .5 - 49, 125, 49)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_Red,
            zh_normalTitle: @"提交订单",
            zh_superView: self.view,
            zh_titleFont: @16
        }];
        [jsButton addTarget:self action:@selector(tappedJSButton:) forControlEvents:UIControlEventTouchUpInside];
        
        _label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, jsButton.top, jsButton.left - 10, 49)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.view,
            zh_numberOfLines: @0,
        }];
        
        [self.view zh_addLineWithFrame:CGRectMake(_label.right, _label.top, 10, _label.height) color:[UIColor whiteColor]];
    }
    return _label;
}

- (NSMutableDictionary *)shopCouponDictionary {
    if (!_shopCouponDictionary) {
        _shopCouponDictionary = [NSMutableDictionary dictionary];
    }
    return _shopCouponDictionary;
}

#pragma mark -  setter
- (void)setAddress:(NSDictionary *)address {
    _address = [address copy];
    
    [self.addressButton setTitle:[NSString stringWithFormat:@"%@ %@\n%@%@%@%@", address[@"person"], address[@"phone"], address[@"province"], address[@"city"], address[@"district"], address[@"addr"]] forState:UIControlStateNormal];
}

#pragma mark -  <#mark#>
-(void)onAliPayCallBackNotification:(NSNotification*)notify {
    NSString *string = notify.object[@"result"];
    
    NSDictionary *info = [NSDictionary zh_dictionaryFromJson:string];
    
    NSDictionary *alipay_trade_app_pay_response = info[@"alipay_trade_app_pay_response"];
    
    if ([alipay_trade_app_pay_response[@"code"] integerValue] == 10000) {
        [SVProgressHUD showSuccessWithStatus:@"充值成功"];
        
        [self paySuccess];
    } else {
        [self goBack];
    }
}

- (void)onWXPayCallBackNotification:(NSNotification*)notify {
    NSInteger errCode = [notify.userInfo[@"code"] integerValue];
    
    if (errCode == 0) {
        [SVProgressHUD showSuccessWithStatus:@"充值成功"];
        [self paySuccess];
    } else {
        [self goBack];
    }
}

- (void)paySuccess {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"支付成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"领取红包" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *union_orderno = self.orderInfo[@"union_orderno"];
        NSArray *orderno = self.orderInfo[@"orderno"];
        NSNumber *is_sum = self.orderInfo[@"is_sum"];
        
        [Util POST:@"/api/Order/pay_ok_redmoney" showHUD:YES showResultAlert:YES parameters:@{
            @"is_sum": is_sum,
            @"union_orderno": union_orderno,
            @"orderno": [orderno zh_jsonStringValue],
        } result:^(id responseObject) {
            
//            [SVProgressHUD dismissWithDelay:0];
            
            [self goBack];
            
            if (responseObject) {
                if (self.operationSuccessBlock) {
                    self.operationSuccessBlock();
                }
                
                [ZHAlertController alertTitle:@"恭喜" message:[NSString stringWithFormat:@"你获得%@元红包", responseObject[@"red_money"]] cancleButtonTitle:@"确定"];
            }
                        
        }];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
