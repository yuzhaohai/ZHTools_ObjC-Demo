//
//  OrderViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderDetailViewController.h"
#import "OrderTableFooterView.h"
#import "OrderViewCell.h"
#import "BaseTableViewHeaderFooterView.h"

#import <AlipaySDK/AlipaySDK.h>

#import <mob_sharesdk/WXApiObject.h>
#import <mob_sharesdk/WXApi.h>

@interface OrderViewController ()

@property (assign, nonatomic) NSInteger index;



@property (strong, nonatomic) ZHButton *selectedButton;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (copy, nonatomic) NSURLSessionTask *networkTask;

@property (copy, nonatomic) NSDictionary *order_pay;

@end

@implementation OrderViewController

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"订单";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"待付款", @"已付款", @"已发货", @"已完成", @"已取消"];
    CGFloat width = ceil(zh_ScreenWidth / (1.0 * array.count));
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(idx * width, self.topBar.bottom + 1, width, 43)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_selectedImage: [UIImage zh_imageWithColor:[UIColor zh_colorWithHexString:kColor_Red] size:CGSizeMake(30, 20)],
            zh_normalImage: [UIImage zh_imageWithColor:[UIColor whiteColor] size:CGSizeMake(30, 20)],
            zh_normalTitleColor: kColor_000000,
            zh_selectedTitleColor: kColor_Red,
            zh_superView: self.view,
            zh_selectedTitle: obj,
            zh_normalTitle: obj,
            zh_titleFont: @13,
            zh_tag: @(idx)
        }];
        button.titleRect = CGRectMake(0, 0, width, 41);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.imageRect = CGRectMake(width / 2.0 - 15, 41, 30, 2);
        [button addTarget:self action:@selector(tappedTopButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [button zh_addLineWithFrame:CGRectMake(-1, 15, 1, 13) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        
        if (idx == self.index) {
            button.selected = YES;
            self.selectedButton = button;
        }
    }];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([self.tableView.mj_footer isRefreshing]) {
            return;
        }
        
        [self.tempArray removeAllObjects];
        
        [self fetchRequestWithPage:1];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([self.tableView.mj_header isRefreshing]) {
            return;
        }
        
        [self fetchRequestWithPage:(self.array.count / self.pageSize + 1)];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAliPayCallBackNotification:) name:kAliPayCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWXPayCallBackNotification:) name:kWXAuthorizationPay object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self.tableView.mj_header beginRefreshing];
        
        self.needRefresh = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAliPayCallBack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXAuthorizationPay object:nil];
}

- (void)tappedTopButton:(ZHButton *)button {
    if (!button.selected) {
        self.selectedButton.selected = NO;
        
        button.selected = YES;
        self.selectedButton = button;
    }
    
    [self.networkTask cancel];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark -  网络请求
- (void)fetchRequestWithPage:(NSInteger)page {
    self.networkTask = [Util POST:@"/api/Order/order_list" showHUD:NO showResultAlert:NO parameters:@{
        @"limit": @(self.pageSize),
        @"page": @(page),
        @"status": @(self.selectedButton.tag),
    } result:^(id responseObject) {
        
        [self endMJRefreshWithResult:[responseObject isKindOfClass:[NSArray class]] responseArray:responseObject];
        
    }];
}

#pragma mark -  self define
- (void)endMJRefreshWithResult:(BOOL)success responseArray:(NSArray *)responseArray {
    [self.tableView.mj_header endRefreshing];
    
    if (success && (responseArray.count < self.pageSize)) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (success) {
        
        [self.tempArray addObjectsFromArray:responseArray];
        
        self.array = [NSArray arrayWithArray:self.tempArray];
        
        [self.tableView reloadData];
        
    } else if (self.tempArray.count != self.array.count) {
        
        [self.tempArray removeAllObjects];
        [self.tempArray addObjectsFromArray:self.array];
        
    }
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *orderInfo = self.array[section];
    NSArray *goods_list = orderInfo[@"goods_list"];
    return goods_list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"OrderViewCell";
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[OrderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSDictionary *orderInfo = self.array[section];
    NSArray *goods_list = orderInfo[@"goods_list"];
    
    [cell setInfo:goods_list[row] refoundType:-1];
    
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
    OrderDetailViewController *vc = [[OrderDetailViewController alloc] initWithInfo:self.array[indexPath.section]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5 + 30;
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
            zh_tag: @(tag)
        }];
                
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 5, zh_ScreenWidth - 10 * 2, 30)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_backgroundColor: [UIColor clearColor],
            zh_textColor: kColor_Red,
            zh_font: @14,
            zh_superView: view,
            zh_tag: @(tag + 2),
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        [view zh_addLineWithFrame:CGRectMake(0, label.bottom - 1, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    }
    
    NSDictionary *orderInfo = self.array[section];
    
    ((UILabel *)[view viewWithTag:tag]).text = orderInfo[@"shop_name"];
    ((UILabel *)[view viewWithTag:(tag + 2)]).text = orderInfo[@"status_desc"];
        
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSDictionary *orderInfo = self.array[section];
    
    NSInteger status = [orderInfo[@"status"] integerValue];
    
    BOOL user_refund = ![orderInfo[@"user_refund"] boolValue];
    
    NSArray *array = @[@[@"立即付款", @"取消订单"], @[@"申请售后"], @[@"确认收货"], @[@"申请售后"], @[], @[], @[], @[], @[], @[]][status];
        
    if ([array containsObject:@"申请售后"] && (!user_refund)) {
        array = @[];
    }
    
    return 41 + (array.count > 0 ? 36 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString *Identifier = @"OrderTableFooterView";
    OrderTableFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    if (!view) {
        view = [[OrderTableFooterView alloc] initWithReuseIdentifier:Identifier];
        
        view.payOrder = ^(NSDictionary * _Nonnull order) {
            [self payOrder:order];
        };
        
        view.refreshDataBlock = ^{
            [self.tableView.mj_header beginRefreshing];
        };
    }
    
    view.info = self.array[section];
    
    return view;
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 45, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 45)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_dataSource: self,
            zh_delegate: self,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight)],
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableArray *)tempArray {
    if (!_tempArray) {
        _tempArray = [[NSMutableArray alloc] init];
    }
    return _tempArray;
}

- (NSInteger)pageSize {
    return 10;
}

#pragma mark -  <#mark#>
- (void)payOrder:(NSDictionary *)orderInfo {
    self.order_pay = orderInfo;
    
    __block NSInteger payType = [orderInfo[@"pay_type"] integerValue];
    
    [Util POST:@"/api/Order/order_pay" showHUD:YES showResultAlert:YES parameters:@{
        @"orderno": self.order_pay[@"orderno"],
        @"pay_type": @(payType),
    } result:^(id responseObject) {
        if (responseObject) {
            
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

-(void)onAliPayCallBackNotification:(NSNotification*)notify {
    NSString *string = notify.object[@"result"];
    
    NSDictionary *info = [NSDictionary zh_dictionaryFromJson:string];
    
    NSDictionary *alipay_trade_app_pay_response = info[@"alipay_trade_app_pay_response"];
    
    if ([alipay_trade_app_pay_response[@"code"] integerValue] == 10000) {
        [SVProgressHUD showSuccessWithStatus:@"支付成功"];
        
        [self paySuccess];
    }
}

- (void)onWXPayCallBackNotification:(NSNotification*)notify {
    NSInteger errCode = [notify.userInfo[@"code"] integerValue];
    
    if (errCode == 0) {
        [SVProgressHUD showSuccessWithStatus:@"支付成功"];
        [self paySuccess];
    }
}

- (void)paySuccess {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"支付成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"领取红包" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *union_orderno = self.order_pay[@"union_orderno"];
        NSArray *orderno = self.order_pay[@"orderno"];
        NSNumber *is_sum = self.order_pay[@"is_sum"];
        
        [Util POST:@"/api/Order/pay_ok_redmoney" showHUD:YES showResultAlert:YES parameters:@{
            @"is_sum": is_sum,
            @"union_orderno": union_orderno,
            @"orderno": [orderno zh_jsonStringValue],
        } result:^(id responseObject) {
            
            [SVProgressHUD dismissWithDelay:0];
                        
            if (responseObject) {
                [ZHAlertController alertTitle:@"恭喜" message:[NSString stringWithFormat:@"你获得%@元红包", responseObject[@"red_money"]] cancleButtonTitle:@"确定"];
            }
                        
        }];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
