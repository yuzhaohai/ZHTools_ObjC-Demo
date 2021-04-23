//
//  PurchaseListViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/22.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "PurchaseListViewController.h"
#import "ZZPopoverViewController.h"
#import "PurchaseListViewCell.h"
#import "BaseTableViewHeaderFooterView.h"
#import "ConfirmOrderViewController.h"

@interface PurchaseListViewController ()

@property (copy, nonatomic) NSMutableArray *onSaleShopArray;
@property (copy, nonatomic) NSMutableArray *offSaleShopArray;

@property (copy, nonatomic) NSMutableArray *orderedArray;

@property (copy, nonatomic) NSMutableDictionary *onSaleDictionary;
@property (copy, nonatomic) NSMutableDictionary *offSaleDictionary;

@property (copy, nonatomic) NSMutableDictionary *shopCouponDictionary;

@property (copy, nonatomic) NSMutableDictionary *selectDictionary;
@property (copy, nonatomic) NSMutableArray *selectedGoodsArray;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIView *footer;

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) ZHButton *selectAllButton;
@property (strong, nonatomic) UIButton *jsButton;

@property (assign, nonatomic) BOOL noTabbar;

@end

@implementation PurchaseListViewController

- (instancetype)initWithNoTabbar {
    self = [super init];
    if (self) {
        self.noTabbar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"进货单";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.rightNavigationButton setPropertyWithDictionary:@{
        zh_normalTitleColor: kColor_333333,
        zh_selectedTitle: @"完成",
        zh_normalTitle: @"编辑",
        zh_titleFont: @14
    }];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.footer];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if ([self.tableView.mj_footer isRefreshing]) {
                return;
            }
                        
            [self fetchRequest];
        }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fetchRequest];
}

- (void)rightNavigationButtonAction {
    self.rightNavigationButton.selected = !self.rightNavigationButton.selected;
    
    BOOL flag = self.selectDictionary.count > 0;
    [self.jsButton setPropertyWithDictionary:@{
        zh_userInteractionEnabled: @(flag),
        zh_backgroundColor: (flag ? kColor_Red : kColor_999999),
        zh_normalTitle: (self.rightNavigationButton.selected ? @"删除" : @"结算"),
    }];
}

- (void)tappedAllButton:(UIButton *)button {
    button.selected = !button.selected;
    
    [self.selectedGoodsArray removeAllObjects];
    [self.selectDictionary removeAllObjects];
        
    if (button.selected) {
        
        for (NSInteger section = 0; section < self.onSaleShopArray.count; section++) {
            
            NSDictionary *shop = self.onSaleShopArray[section];
            NSString *shop_id = [shop[@"shop_id"] stringValue];
            
            NSArray *goods = self.onSaleDictionary[shop_id];
                        
            for (NSInteger row = 0; row < goods.count; row++) {
                
                NSDictionary *goodInfo = goods[row];
                NSString *goodsID = [goodInfo[@"goods_id"] stringValue];
                
                [self.selectedGoodsArray addObject:goodsID];
                
                NSMutableArray *aArray = [NSMutableArray array];
                self.selectDictionary[goodsID] = aArray;
                
                NSArray *specsArray = self.onSaleDictionary[goodsID];
                
                for (NSDictionary *specsInfo in specsArray) {
                    [aArray addObject:specsInfo[@"id"]];
                }
                
            }
            
        }
        
    }
    
    [self.tableView reloadData];
    
    [self calculatTotalMoney];
}

- (void)tappedJSButton:(UIButton *)button {
    
    if (self.rightNavigationButton.selected) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        
        for (NSArray *array in [self.selectDictionary allValues]) {
            [mArray addObjectsFromArray:array];
        }
        
        [self removeGoods:mArray];
        
    } else {
        
        NSMutableArray *shopArray = [NSMutableArray array];
        NSMutableArray *goodsArray = [NSMutableArray array];
        NSMutableArray *cartArray = [NSMutableArray array];
        
        for (NSInteger section = 0; section < self.onSaleShopArray.count; section++) {
            
            NSDictionary *shop = self.onSaleShopArray[section];
            NSString *shop_id = [shop[@"shop_id"] stringValue];
            
            NSArray *goods = self.onSaleDictionary[shop_id];
                        
            for (NSInteger row = 0; row < goods.count; row++) {
                
                NSDictionary *goodInfo = goods[row];
                NSString *goodsID = [goodInfo[@"goods_id"] stringValue];
                
                [self.selectedGoodsArray addObject:goodsID];
                
                NSMutableArray *aArray = self.selectDictionary[goodsID];
                
                NSArray *specsArray = self.onSaleDictionary[goodsID];
                
                for (NSDictionary *specsInfo in specsArray) {
                    
                    if ([aArray containsObject:specsInfo[@"id"]]) {
                        
                        if (![shopArray containsObject:shop_id]) {
                            [shopArray addObject:shop_id];
                        }
                        
                        if (![goodsArray containsObject:goodsID]) {
                            [goodsArray addObject:goodsID];
                        }
                        
                        [cartArray addObject:specsInfo[@"id"]];
                        
                    }
                }
            }
        }
        
        if (cartArray.count < 1) {
            return;
        }
        
        [Util POST:@"/api/Cart/cart_settlement" showHUD:YES showResultAlert:YES parameters:@{
            @"shop_id": [shopArray componentsJoinedByString:@","],
            @"goods_id": [goodsArray componentsJoinedByString:@","],
            @"cart_id": [cartArray componentsJoinedByString:@","],
        } result:^(id responseObject) {
            if (responseObject) {
                
                ConfirmOrderViewController *vc = [[ConfirmOrderViewController alloc] initWithArray:responseObject];
                vc.isMiaoSha = NO;
                vc.label.attributedText = self.label.attributedText;
                vc.operationSuccessBlock = ^{
                    [self.selectedGoodsArray removeAllObjects];
                    [self.selectDictionary removeAllObjects];
                    self.selectAllButton.selected = NO;
                    
                    [self fetchRequest];
                };
                [self.navigationController pushViewController:vc animated:YES];
                
            }
        }];
        
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/Cart/cartlist" showHUD:(self.onSaleShopArray.count == 0) showResultAlert:NO parameters:@{} result:^(NSArray *responseObject) {
        [self.tableView.mj_header endRefreshing];
        
        if (responseObject) {
            [self handleResponseData:responseObject];
        }
    }];
}

- (void)handleResponseData:(NSArray *)responseObject {
    [self.onSaleShopArray removeAllObjects];
    [self.offSaleShopArray removeAllObjects];
    [self.onSaleDictionary removeAllObjects];
    [self.offSaleDictionary removeAllObjects];
                
    for (int x = 0; x < responseObject.count; x++) {
        
        NSDictionary *shopGoods = responseObject[x];
        
        NSArray *goodsArray = shopGoods[@"goods"];
        
        for (int y = 0; y < goodsArray.count; y++) {
            
            NSDictionary *goodsInfo = goodsArray[y];
            
            NSArray *specsArray = goodsInfo[@"specs"];
                                
            for (int z = 0; z < specsArray.count; z++) {
                NSDictionary *specsInfo = specsArray[z];
                
                BOOL on_sale = [specsInfo[@"on_sale"] boolValue];
                
                NSMutableArray *shopArray = on_sale ? self.onSaleShopArray : self.offSaleShopArray;
                NSMutableDictionary *dictionary = on_sale ? self.onSaleDictionary : self.offSaleDictionary;
                
                if (![shopArray containsObject:shopGoods]) {
                    [shopArray addObject:shopGoods];
                }
                
                NSString *shopIndex = [shopGoods[@"shop_id"] stringValue];
                NSMutableArray *goods_array = dictionary[shopIndex];
                if (!goods_array) {
                    goods_array = [NSMutableArray array];
                    dictionary[shopIndex] = goods_array;
                }
                if (![goods_array containsObject:goodsInfo]) {
                    [goods_array addObject:goodsInfo];
                }
                
                NSString *shopGoodsIndex = [goodsInfo[@"goods_id"] stringValue];
                NSMutableArray *specs_array = dictionary[shopGoodsIndex];
                if (!specs_array) {
                    specs_array = [NSMutableArray array];
                    dictionary[shopGoodsIndex] = specs_array;
                }
                if (![specs_array containsObject:specsInfo]) {
                    [specs_array addObject:specsInfo];
                }
            }
            
        }
        
    }
        
    [self.orderedArray removeAllObjects];
    [self.orderedArray addObjectsFromArray:self.onSaleShopArray];
    [self.orderedArray addObjectsFromArray:self.offSaleShopArray];
    
    [self.tableView reloadData];
    
    [self.tableView setNeedsLayout];
    [self calculatTotalMoney];
}

- (void)calculatTotalMoney {
    double total = 0.0, kind = .0, amount = .0;
    
    for (NSInteger section = 0; section < self.onSaleShopArray.count; section++) {
        
        NSDictionary *shop = self.onSaleShopArray[section];
        NSString *shop_id = [shop[@"shop_id"] stringValue];
        
        NSArray *goods = self.onSaleDictionary[shop_id];
                    
        for (NSInteger row = 0; row < goods.count; row++) {
            
            NSDictionary *goodInfo = goods[row];
            NSString *goodsID = [goodInfo[@"goods_id"] stringValue];
            
            [self.selectedGoodsArray addObject:goodsID];
            
            NSMutableArray *aArray = self.selectDictionary[goodsID];
            
            NSArray *specsArray = self.onSaleDictionary[goodsID];
            
            for (NSDictionary *specsInfo in specsArray) {
                
                if ([aArray containsObject:specsInfo[@"id"]]) {
                    kind += 1;
                    amount += [specsInfo[@"amount"] integerValue];
                    total += ([specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue]);
                }
                
            }
            
        }
        
    }
    
    BOOL isSelected = kind > 0;
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"合计：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f\n", total] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f种 %.0f件", kind, amount] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    self.label.attributedText = isSelected ? aString : nil;
    
    [self.jsButton setPropertyWithDictionary:@{
        zh_userInteractionEnabled: @(isSelected),
        zh_backgroundColor: (isSelected ? kColor_Red : kColor_999999),
        zh_normalTitle: (self.rightNavigationButton.selected ? @"删除" : @"结算"),
    }];
    
    if (!isSelected) {
        self.selectAllButton.selected = NO;
    }
}

- (void)removeGoods:(NSArray *)array {
    [Util POST:@"/api/Cart/cart_remove" showHUD:YES showResultAlert:YES parameters:@{
        @"cart_id": [array componentsJoinedByString:@","]
    } result:^(id responseObject) {
        if (responseObject) {
            [self.selectedGoodsArray removeAllObjects];
            [self.selectDictionary removeAllObjects];
            [self calculatTotalMoney];
            
            [self fetchRequest];
        }
    }];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orderedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL onSale = section < self.onSaleShopArray.count;
    
    NSDictionary *shop = self.orderedArray[section];
    NSString *shop_id = [shop[@"shop_id"] stringValue];
    
    NSDictionary *dict = onSale ? self.onSaleDictionary : self.offSaleDictionary;
    NSArray *array = dict[shop_id];
    
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section, row = indexPath.row;
    
    BOOL onSale = section < self.onSaleShopArray.count;
    
    NSDictionary *shop = self.orderedArray[section];
    NSString *shop_id = [shop[@"shop_id"] stringValue];
    
    NSDictionary *dict = onSale ? self.onSaleDictionary : self.offSaleDictionary;
    NSArray *goodsArray = dict[shop_id];
    
    NSDictionary *goodsInfo = goodsArray[row];
    NSString *goods_id = [goodsInfo[@"goods_id"] stringValue];
    
    NSArray *specsArray = dict[goods_id];
    
    return 90 + 65 * specsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"PurchaseListViewCell";
    PurchaseListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[PurchaseListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.amountDidChangeBlock = ^(NSDictionary * _Nonnull specsInfo, NSNumber * _Nonnull amount) {
            
            if ([amount integerValue] == 0) {
                NSString *goods_id = [specsInfo[@"goods_id"] stringValue];
                
                NSMutableArray *array = self.selectDictionary[goods_id];
                if ([array containsObject:specsInfo[@"id"]]) {
                    [array removeObject:specsInfo[@"id"]];
                }
            }
            
            [self fetchRequest];
        };
        
        cell.didSelectBlock = ^(NSDictionary * _Nonnull goodsInfo, NSDictionary * _Nonnull specsInfo, BOOL isSpecs, BOOL selected) {
            
            NSString *goods_id = [goodsInfo[@"goods_id"] stringValue], *theID;
            NSMutableArray *array, *goods_specs = self.onSaleDictionary[goods_id];
            
            if (isSpecs) {
                
                theID = specsInfo[@"id"];
                                
                array = self.selectDictionary[goods_id];
                if (!array) {
                    array = [NSMutableArray array];
                    self.selectDictionary[goods_id] = array;
                }
                
                
                if (selected  && array.count >= (goods_specs.count - 1)) {
                    [self.selectedGoodsArray addObject:goods_id];
                }
                                                
                
            } else {
                
                theID = goods_id;
                
                if (selected) {
                    
                    NSMutableArray *sArray = self.selectDictionary[goods_id];
                    if (!sArray) {
                        sArray = [NSMutableArray array];
                        self.selectDictionary[goods_id] = sArray;
                    }
                    
                    for (NSDictionary *sInfo in goods_specs) {
                        if (![sArray containsObject:sInfo[@"id"]]) {
                            [sArray addObject:sInfo[@"id"]];
                        }
                    }
                    
                } else {
                    
                    if ([[self.selectDictionary allKeys] containsObject:goods_id]) {
                        [self.selectDictionary removeObjectForKey:goods_id];
                    }
                    
                }
                
            }
            
            if (selected) {
                
                [array addObject:theID];
                
            } else {
                
                [array removeObject:theID];
                
            }
                        
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            
            BOOL selectAll = YES;
            for (NSInteger section = 0; section < self.onSaleShopArray.count; section++) {
                
                NSDictionary *shop = self.onSaleShopArray[section];
                NSString *shop_id = [shop[@"shop_id"] stringValue];
                
                NSArray *array = self.onSaleDictionary[shop_id];
                
                for (NSInteger row = 0; row < array.count; row++) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    
                    PurchaseListViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    
                    if (!cell.button.selected) {
                        selectAll = NO;
                        break;
                    }
                    
                }
                
                if (!selectAll) {
                    break;
                }
                
            }
            self.selectAllButton.selected = selectAll;
            
            [self calculatTotalMoney];
                        
        };
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    BOOL onSale = section < self.onSaleShopArray.count;
    
    NSDictionary *shop = self.orderedArray[section];
    NSString *shop_id = [shop[@"shop_id"] stringValue];
    
    NSDictionary *dict = onSale ? self.onSaleDictionary : self.offSaleDictionary;
    NSArray *goodsArray = dict[shop_id];
    
    NSDictionary *goodsInfo = goodsArray[row];
    NSString *goods_id = [goodsInfo[@"goods_id"] stringValue];

    NSArray *specsArray = dict[goods_id];
        
    [cell setInfo:goodsArray[row] specsArray:specsArray onSale:onSale];
    
    if (onSale) {
        [cell setSelectionInfo:self.selectDictionary];
    }
            
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
    BOOL onSale = section < self.onSaleShopArray.count;
    NSDictionary *shop = self.orderedArray[section];
        
    NSArray *shop_coupon = shop[@"shop_coupon"];
    BOOL showCoupon = shop_coupon.count > 0 && onSale;
    
    if (section > self.onSaleShopArray.count) {
        return 0;
    }
    
    return showCoupon ? (5 + 30 + 33) : (5 + 30);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *Identifier = @"UITableViewHeaderView";
    BaseTableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    NSInteger tag = 5201314;
    
    if (!view) {
        view = [[BaseTableViewHeaderFooterView alloc] initWithReuseIdentifier:Identifier];
        
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
            
            NSDictionary *shop = self.orderedArray[gestureRecoginzer.view.superview.tag];
            
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
        
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 5, zh_ScreenWidth - 10 * 2, 30)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_backgroundColor: [UIColor clearColor],
            zh_textColor: kColor_FFFFFF,
            zh_font: @14,
            zh_superView: view,
            zh_tag: @(tag + 2),
            zh_text: @"商品失效"
        }];
        
        [label zh_addTapGestureRecognizerWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            NSMutableArray *offSaleSpecIDs = [NSMutableArray array];
            
            for (int x = 0; x < self.offSaleShopArray.count; x++) {
                
                NSDictionary *shopGoods = self.offSaleShopArray[x];
                
                NSArray *goodsArray = shopGoods[@"goods"];
                
                for (int y = 0; y < goodsArray.count; y++) {
                    
                    NSDictionary *goodsInfo = goodsArray[y];
                    
                    NSArray *specsArray = goodsInfo[@"specs"];
                                        
                    for (int z = 0; z < specsArray.count; z++) {
                        NSDictionary *specsInfo = specsArray[z];
                        
                        BOOL on_sale = [specsInfo[@"on_sale"] boolValue];
                        
                        if (!on_sale) {
                            [offSaleSpecIDs addObject:specsInfo[@"id"]];
                        }
                    }
                    
                }
                
            }
            
            [self removeGoods:offSaleSpecIDs];
        }];
    }
    
    BOOL onSale = section < self.onSaleShopArray.count;
    NSDictionary *shop = self.orderedArray[section];
    
    NSArray *shop_coupon = shop[@"shop_coupon"];
    BOOL showCoupon = shop_coupon.count > 0 && onSale;
    
    view.tag = section;
    view.height = showCoupon ? (5 + 30 + 33) : (5 + 30);
    view.bgColor = [UIColor zh_colorWithHexString:(onSale ? kColor_FFFFFF : kColor_666666)];
    
    UILabel *label = [view viewWithTag:tag];
    label.text = [NSString stringWithFormat:@"商家：%@", shop[kName]];
    label.textColor = [UIColor zh_colorWithHexString:onSale ? kColor_333333 : kColor_FFFFFF];
    
    UIButton *button = [view viewWithTag:(tag + 1)];
    button.hidden = !showCoupon;
    
    UILabel *aLabel = [view viewWithTag:tag + 2];
    aLabel.hidden = onSale;
    
    if (showCoupon) {
                
        NSMutableString *string = [NSMutableString stringWithString:@"本店铺购"];
        
        for (NSDictionary *info in shop_coupon) {
            BOOL flag = [info[@"type_two"] integerValue] == 0;
            
            [string appendFormat:@"满%.0f%@%@  ", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
        }
        
        [button setTitle:string forState:UIControlStateNormal];
        
    }
        
    if (!onSale) {
        label.text = @"失效货品";
        aLabel.text = @"清空";
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    BOOL onSale = section < self.onSaleShopArray.count;
    return onSale ? 40 : 0;
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
            zh_frame: NSStringFromCGRect(CGRectMake(view.button.right, 0, zh_ScreenWidth - view.button.right - 10, 40)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_font: @14,
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        [view zh_addLineWithFrame:CGRectMake(0, 40 - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    }
        
    BOOL onSale = section < self.onSaleShopArray.count;
    
    NSDictionary *shop = self.orderedArray[section];
    NSString *shop_id = [shop[@"shop_id"] stringValue];
    
    NSDictionary *dict = onSale ? self.onSaleDictionary : self.offSaleDictionary;
    NSArray *goodsArray = dict[shop_id];
    
    double money = 0.0, discount = 0.0;
    for (NSDictionary *goodsInfo in goodsArray) {
        
        NSString *goods_id = [goodsInfo[@"goods_id"] stringValue];

        NSArray *specsArray = dict[goods_id];
        
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
        zh_normalTitle: [NSString stringWithFormat:@"总额：¥%.2f   %@", money, couponInfo],
        zh_tag: @(section),
        zh_hidden: @1,
    }];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"小计：" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f", (money - discount)] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    view.label.attributedText = aString;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tappedFooterButton:(UIButton *)button {
    __block NSDictionary *shop = self.orderedArray[button.tag];
    
    NSArray *shop_coupon = shop[@"shop_coupon"];
    
    if (shop_coupon.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"无优惠活动"];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择优惠" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSDictionary *info in shop_coupon) {
        BOOL flag = [info[@"type_two"] integerValue] == 0;
                
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"满%.0f%@%@\n", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *shop_id = [shop[@"shop_id"] stringValue];
            
            NSArray *goodsArray = self.onSaleDictionary[shop_id];
            
            double money = 0.0;
            for (NSDictionary *goodsInfo in goodsArray) {
                
                NSString *goods_id = [goodsInfo[@"goods_id"] stringValue];

                NSArray *specsArray = self.onSaleDictionary[goods_id];
                
                for (NSDictionary *specsInfo in specsArray) {
                    
                    money += ([specsInfo[@"amount"] integerValue] * [specsInfo[@"price"] doubleValue]);
                    
                }
                
            }
            
            if (money < [info[@"money_max"] doubleValue]) {
                [SVProgressHUD showErrorWithStatus:@"商品总金额不足，不可使用此优惠"];
            } else {
                self.shopCouponDictionary[shop_id] = info;
                
                [self.tableView reloadData];
            }
            
        }]];
        
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat height = self.noTabbar ? (SafeAreaHeight * .5 + 49) : 49;
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1 - height - (self.noTabbar ? 0 : zh_TabBar_HEIGHT))),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, height)],
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

- (UIView *)footer {
    if (!_footer) {
        CGFloat height = self.noTabbar ? (SafeAreaHeight * .5 + 49) : 49;
        _footer = [UIView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.tableView.bottom, zh_ScreenWidth, height)),
            zh_backgroundColor: kColor_FFFFFF
        }];
        
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 168, 49)),
            zh_normalTitleColor: kColor_333333,
            zh_selectedTitleColor: kColor_Red,
            zh_selectedImage: @"ico_chosen",
            zh_normalImage: @"ico_chose",
            zh_selectedTitle: @"取消全选",
            zh_normalTitle: @"全选",
            zh_superView: _footer,
            zh_titleFont: @16,
        }];
        button.titleRect = CGRectMake(50, 0, 100, 49);
        button.imageRect = CGRectMake(20, 15, 19, 19);
        [button addTarget:self action:@selector(tappedAllButton:) forControlEvents:UIControlEventTouchUpInside];
        self.selectAllButton = button;
        
        UIButton *jsButton = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 125, 0, 125, 49)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_999999,
            zh_normalTitle: @"结算",
            zh_superView: _footer,
            zh_titleFont: @16
        }];
        [jsButton addTarget:self action:@selector(tappedJSButton:) forControlEvents:UIControlEventTouchUpInside];
        self.jsButton = jsButton;
        
        self.label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(button.left, 0, jsButton.left - button.left - 10, 49)),
            zh_numberOfLines: @0,
            zh_superView: _footer,
        }];
    }
    return _footer;
}

- (NSMutableArray *)orderedArray {
    if (!_orderedArray) {
        _orderedArray = [NSMutableArray array];
    }
    return _orderedArray;
}

- (NSMutableArray *)onSaleShopArray {
    if (!_onSaleShopArray) {
        _onSaleShopArray = [NSMutableArray array];
    }
    return _onSaleShopArray;
}

- (NSMutableArray *)offSaleShopArray {
    if (!_offSaleShopArray) {
        _offSaleShopArray = [NSMutableArray array];
    }
    return _offSaleShopArray;
}

- (NSMutableDictionary *)onSaleDictionary {
    if (!_onSaleDictionary) {
        _onSaleDictionary = [NSMutableDictionary dictionary];
    }
    return _onSaleDictionary;
}

- (NSMutableDictionary *)offSaleDictionary {
    if (!_offSaleDictionary) {
        _offSaleDictionary = [NSMutableDictionary dictionary];
    }
    return _offSaleDictionary;
}

- (NSMutableDictionary *)shopCouponDictionary {
    if (!_shopCouponDictionary) {
        _shopCouponDictionary = [NSMutableDictionary dictionary];
    }
    return _shopCouponDictionary;
}

- (NSMutableDictionary *)selectDictionary {
    if (!_selectDictionary) {
        _selectDictionary = [NSMutableDictionary dictionary];
    }
    return _selectDictionary;
}

- (NSMutableArray *)selectedGoodsArray {
    if (!_selectedGoodsArray) {
        _selectedGoodsArray = [NSMutableArray array];
    }
    return _selectedGoodsArray;
}

@end
