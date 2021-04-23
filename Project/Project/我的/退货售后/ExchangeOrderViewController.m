//
//  ExchangeOrderViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/28.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ExchangeOrderViewController.h"
#import "ExchangeOrderDetailViewController.h"
#import "OrderTableFooterView.h"
#import "OrderViewCell.h"
#import "BaseTableViewHeaderFooterView.h"

@interface ExchangeOrderViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ZHButton *selectedButton;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (copy, nonatomic) NSURLSessionTask *networkTask;

@end

@implementation ExchangeOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"售后订单";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"待审核", @"已审核", @"已完成", @"已取消"];
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
        
        if (idx == 0) {
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self.tableView.mj_header beginRefreshing];
        
        self.needRefresh = NO;
    }
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
    self.networkTask = [Util POST:@"/api/refund/refund_list" showHUD:NO showResultAlert:NO parameters:@{
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
    
    [cell setInfo:goods_list[row] refoundType:[orderInfo[@"refund_type"] integerValue]];
    
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
//    ExchangeOrderDetailViewController *vc = [ExchangeOrderDetailViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
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
    NSDictionary *info = self.array[section];
    NSInteger status = [info[@"status"] integerValue];
    return (status == 0 || status == 3) ? 77 : 41;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString *Identifier = @"OrderTableFooterView";
    OrderTableFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    if (!view) {
        view = [[OrderTableFooterView alloc] initWithReuseIdentifier:Identifier];
        
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

@end
