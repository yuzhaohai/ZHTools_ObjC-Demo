//
//  BuyAgainViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/30.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BuyAgainViewController.h"
#import "BaseTableViewHeaderFooterView.h"
#import "OrderTableFooterView.h"
#import "OrderViewCell.h"
#import "PurchaseListViewCell.h"

@interface BuyAgainViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

@property (copy, nonatomic) NSMutableDictionary *specsAmountDictionary;

@property (copy, nonatomic) NSMutableDictionary *selectDictionary;
@property (copy, nonatomic) NSMutableArray *selectedGoodsArray;

@end

@implementation BuyAgainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"快速补货";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.tableView];
    
    [self.rightNavigationButton setPropertyWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 66, zh_StatusBar_HEIGHT, 66, zh_NavigationBar_HEIGHT)),
        zh_normalTitleColor: kColor_333333,
        zh_selectedTitle: @"取消全选",
        zh_normalTitle: @"全选",
        zh_titleFont: @12,
    }];
    
    CGFloat height = 49 + SafeAreaHeight;
    UIView *footer = [UIView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
        zh_backgroundColor: kColor_FFFFFF,
        zh_superView: self.view
    }];
        
    self.label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth - 125 - 20, 49)),
        zh_superView: footer,
        zh_numberOfLines: @2,
    }];
    
    self.button = [UIButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(self.label.right + 20, 0, 125, 49)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_999999,
        zh_normalTitle: @"加入进货单",
        zh_superView: footer,
        zh_titleFont: @16,
    }];
    [self.button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self fetchRequest];
    }
}

- (void)rightNavigationButtonAction {
    self.rightNavigationButton.selected = !self.rightNavigationButton.selected;
    
    [self.selectedGoodsArray removeAllObjects];
    [self.selectDictionary removeAllObjects];
        
    if (self.rightNavigationButton.selected) {
        
        for (NSInteger section = 0; section < self.array.count; section++) {
            
            NSDictionary *shop = self.array[section];
            NSArray *goods = shop[@"goods"];
                        
            for (NSInteger row = 0; row < goods.count; row++) {
                
                NSDictionary *goodInfo = goods[row];
                NSString *goodsID = goodInfo[@"id"];
                [self.selectedGoodsArray addObject:goodsID];
                
                NSMutableArray *aArray = [NSMutableArray array];
                self.selectDictionary[goodsID] = aArray;
                
                NSArray *specsArray = goodInfo[@"goods_specs"];
                
                for (NSDictionary *specsInfo in specsArray) {
                    [aArray addObject:specsInfo[@"goods_specs_id"]];
                }
                
            }
            
        }
        
    }
    
    [self.tableView reloadData];
    
    [self calculatTotalMoney];
}

- (void)tappedFooterButton:(UIButton *)button {
    NSMutableArray *pArray = [NSMutableArray array];
    
    for (NSInteger section = 0; section < self.array.count; section++) {
        
        NSDictionary *shop = self.array[section];
        NSArray *goods = shop[@"goods"];
                    
        for (NSInteger row = 0; row < goods.count; row++) {
            
            NSDictionary *goodInfo = goods[row];
            NSString *goodsID = goodInfo[@"id"];
            
            NSArray *specsArray = goodInfo[@"goods_specs"];
            NSMutableArray *aArray = self.selectDictionary[goodsID];
            
            for (NSDictionary *specsInfo in specsArray) {
                
                if ([aArray containsObject:specsInfo[@"goods_specs_id"]]) {
                    
                    [pArray addObject:@{
                        @"specs": specsInfo[@"specs"],
                        @"shop_id": specsInfo[@"shop_id"],
                        @"goods_id": specsInfo[@"goods_id"],
                        @"goods_specs_id": specsInfo[@"goods_specs_id"],
                        @"amount": self.specsAmountDictionary[specsInfo[@"goods_specs_id"]],
                    }];
                    
                }
            }
        }
    }
    
    [Util POST:@"/api/Cart/quick_intocart_add" showHUD:YES showResultAlert:YES parameters:@{
        @"cart_list": [pArray zh_jsonStringValue]
    } result:^(id responseObject) {
        if (responseObject) {
            [self goBack];
        }
    }];
}

- (void)fetchRequest {
    [Util POST:@"/api/Cart/quick_intocart" showHUD:YES showResultAlert:YES parameters:@{} result:^(NSArray *responseObject) {
        if (responseObject) {
            self.array = responseObject;
            
            [self.specsAmountDictionary removeAllObjects];
            
            for (NSDictionary *shop in responseObject) {
                
                NSArray *goodsArray = shop[@"goods"];
                
                for (NSDictionary *goodsInfo in goodsArray) {
                    
                    NSArray *specsArray = goodsInfo[@"goods_specs"];
                    
                    for (NSDictionary *specsInfo in specsArray) {
                        
                        self.specsAmountDictionary[specsInfo[@"goods_specs_id"]] = specsInfo[@"batch_min"];
                        
                    }
                    
                }
                
            }
            
            [self.tableView reloadData];
        }
    }];
}

- (void)calculatTotalMoney {
    double total = 0.0, kind = .0, amount = .0;
    
    for (NSInteger section = 0; section < self.array.count; section++) {
        
        NSDictionary *shop = self.array[section];
        NSArray *goods = shop[@"goods"];
                    
        for (NSInteger row = 0; row < goods.count; row++) {
            
            NSDictionary *goodInfo = goods[row];
            NSString *goodsID = goodInfo[@"id"];
            
            NSMutableArray *aArray = self.selectDictionary[goodsID];
            
            NSArray *specsArray = goodInfo[@"goods_specs"];
            
            for (NSDictionary *specsInfo in specsArray) {
                
                if ([aArray containsObject:specsInfo[@"goods_specs_id"]]) {
                    kind += 1;
                    amount += [self.specsAmountDictionary[specsInfo[@"goods_specs_id"]] integerValue];
                    total += ([self.specsAmountDictionary[specsInfo[@"goods_specs_id"]] integerValue] * [specsInfo[@"price"] doubleValue]);
                    
                }
                
            }
            
        }
        
    }
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"合计：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f\n", total] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f种 %.0f件", kind, amount] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    self.label.attributedText = kind == 0 ? nil : aString;
    
    self.button.backgroundColor = [UIColor zh_colorWithHexString:(kind > 0 ? kColor_Red : kColor_999999)];
    self.button.userInteractionEnabled = kind > 0;
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *shop = self.array[section];
    NSArray *array = shop[@"goods"];
    
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section, row = indexPath.row;
        
    NSDictionary *shop = self.array[section];
    NSArray *goods = shop[@"goods"];
    
    NSDictionary *goodInfo = goods[row];
    NSArray *specsArray = goodInfo[@"goods_specs"];
    
    return 90 + 65 * specsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"PurchaseListViewCell";
    PurchaseListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[PurchaseListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.amountDidChangeBlock = ^(NSDictionary * _Nonnull specsInfo, NSNumber * _Nonnull amount) {
            self.specsAmountDictionary[specsInfo[@"goods_specs_id"]] = amount;
            [self.tableView reloadData];
            
            [self calculatTotalMoney];
        };
        
        cell.didSelectBlock = ^(NSDictionary * _Nonnull goodsInfo, NSDictionary * _Nonnull specsInfo, BOOL isSpecs, BOOL selected) {
            
            NSMutableArray *array, *goods_specs = goodsInfo[@"goods_specs"];;
            NSString *goods_id = goodsInfo[@"id"], *theID;
            
            if (isSpecs) {
                
                theID = specsInfo[@"goods_specs_id"];
                                
                array = self.selectDictionary[goods_id];
                if (!array) {
                    array = [NSMutableArray array];
                    self.selectDictionary[goods_id] = array;
                }
                
                
                if (selected  && array.count == (goods_specs.count - 1)) {
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
                        if (![sArray containsObject:sInfo[@"goods_specs_id"]]) {
                            [sArray addObject:sInfo[@"goods_specs_id"]];
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
            for (NSInteger section = 0; section < self.array.count; section++) {
                
                NSDictionary *shop = self.array[section];
                NSArray *array = shop[@"goods"];
                
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
            self.rightNavigationButton.selected = selectAll;
            
            [self calculatTotalMoney];
                        
        };
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
        
    NSDictionary *shop = self.array[section];
    NSArray *goods = shop[@"goods"];
    
    NSDictionary *goodInfo = goods[row];
    
    [cell setInfo:goodInfo specsArray:goodInfo[@"goods_specs"] amountInfo:self.specsAmountDictionary selectionInfo:self.selectDictionary];
            
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
    return 35;
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
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_font: @14,
            zh_superView: view,
            zh_text: @"商家：华硕科技",
            zh_tag: @(tag)
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, label.bottom - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    }
    
    NSDictionary *shop = self.array[section];
    
    UILabel *label = [view viewWithTag:tag];
    label.text = [NSString stringWithFormat:@"商家：%@", shop[kName]];
    
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
                
        [view.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth - 10, 40)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_font: @14,
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        [view zh_addLineWithFrame:CGRectMake(0, 40 - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    }
    
    NSDictionary *shop = self.array[section];
    NSArray *goodsArray = shop[@"goods"];
        
    double money = 0.0;
    for (NSDictionary *goodsInfo in goodsArray) {
        
        NSArray *specsArray = goodsInfo[@"goods_specs"];
        
        for (NSDictionary *specsInfo in specsArray) {
            
            money += ([self.specsAmountDictionary[specsInfo[@"goods_specs_id"]] integerValue] * [specsInfo[@"price"] doubleValue]);
            
        }
        
    }
        
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"总额：" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f", money] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    view.label.attributedText = aString;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_dataSource: self,
            zh_delegate: self,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight + 49)],
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableDictionary *)specsAmountDictionary {
    if (!_specsAmountDictionary) {
        _specsAmountDictionary = [NSMutableDictionary dictionary];
    }
    return _specsAmountDictionary;
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
