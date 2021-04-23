//
//  MyCollectionViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "GoodsDetailViewController.h"

@interface MyCollectionViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的收藏";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
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
    }
}

#pragma mark -  网络请求
- (void)fetchRequestWithPage:(NSInteger)page {
    [Util POST:@"/api/User/goods_collect" showHUD:NO showResultAlert:YES parameters:@{
        @"limit": @(self.pageSize),
        @"page": @(page),
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.anImageView.frame = CGRectMake(10, 10, 60, 60);
        cell.anImageView.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
        [cell.anImageView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
                        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(80, 10, zh_ScreenWidth - 80 - 10, 40)),
            zh_textColor: kColor_000000,
            zh_numberOfLines: @2,
            zh_font: @13
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(80, 50, zh_ScreenWidth - 80 - 10, 20)),
            zh_textColor: kColor_Red,
            zh_font: @13
        }];
    }
    
    NSDictionary *info = self.array[indexPath.row];
    
    [cell.anImageView sd_setImageWithURL:[NSURL URLWithString:info[@"image_thumb"]]];
    
    cell.label.text = info[kName];
    
    cell.aLabel.text = [NSString stringWithFormat:@"¥%.2f", [info[@"price"] doubleValue]];
            
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
    NSDictionary *info = self.array[indexPath.row];
    
    GoodsDetailViewController *vc = [[GoodsDetailViewController alloc] initWithID:info[@"goods_id"]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_tableHeaderView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5)],
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight * .5)],
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

- (NSMutableArray *)tempArray {
    if (!_tempArray) {
        _tempArray = [NSMutableArray array];
    }
    return _tempArray;
}

- (NSInteger)pageSize {
    return 10;
}

@end
