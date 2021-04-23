//
//  XianShiGouViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "XianShiGouViewController.h"
#import "GoodsDetailViewController.h"

@interface XianShiGouViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UILabel *label;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@end

@implementation XianShiGouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.topBar.backgroundColor = [UIColor zh_colorWithHexString:kColor_Red];
    
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回-白"] forState:UIControlStateNormal];
    
    [self.navigationTitleLabel setPropertyWithDictionary:@{
        zh_textColor: kColor_FFFFFF,
        zh_text: @"限时购",
    }];
    
    UIView *view = [UIView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, 30)),
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
    }];
    
    UILabel *label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 5, 100, 21)),
        zh_textColor: kColor_FFFFFF,
        zh_text: @"距离结束  ",
        zh_superView: view,
        zh_font: @14
    }];
    [label sizeToFit];
    
    self.label = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 5, 100, 21)),
        zh_textAlignment: @(NSTextAlignmentCenter),
        zh_backgroundColor: kColor_FFFFFF,
        zh_textColor: kColor_Red,
        zh_text: @"03：22：34",
        zh_superView: view,
        zh_font: @14
    }];
    [self.label zh_addCornerRadius:4 withCorners:UIRectCornerAllCorners];
    
    label.frame = CGRectMake((zh_ScreenWidth - label.width - self.label.width) / 2.0, 5, label.width, 21);
    self.label.frame = CGRectMake(label.right, 5, 100, 21);
    
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
    
    [self resetTime:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark -  网络请求
- (void)fetchRequestWithPage:(NSInteger)page {
    [Util POST:@"/api/Index/miaosha_list" showHUD:NO showResultAlert:YES parameters:@{
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

- (void)resetTime:(XianShiGouViewController *)vc {
    int leftTime = [AppDelegate appDelegate].leftTime;
    int seconds = leftTime % 60;
    int minutes = (leftTime / 60) % 60;
    int hours = leftTime / 3600;
    self.label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        
    [self zh_performBlock:^{
        [self resetTime:self];
    } afterDelay:1];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        [cell.anImageView setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 12.5, 70, 70)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_F5F5F5,
        }];
        [cell.anImageView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(cell.anImageView.right + 10, 12.5, zh_ScreenWidth - cell.anImageView.right - 10, 38)),
            zh_textColor: kColor_000000,
            zh_numberOfLines: @2,
            zh_font: @14
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(cell.label.left, cell.label.bottom, cell.label.width, 32)),
            zh_numberOfLines: @2,
            zh_font: @13
        }];
        
        [cell.button setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 10 - 60, cell.anImageView.bottom  - 22, 60, 22)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_Red,
            zh_normalTitle: @"马上抢",
            zh_titleFont: @12,
            zh_userInteractionEnabled: @0
        }];
        [cell.button zh_addCornerRadius:11 withCorners:UIRectCornerAllCorners];
    }
    
    NSDictionary *info = self.array[indexPath.row];
    
    [cell.anImageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
    
    cell.label.frame = CGRectMake(cell.anImageView.right + 10, 12.5, zh_ScreenWidth - cell.anImageView.right - 10, 38);
    cell.label.text = info[kName];
    [cell.label sizeToFit];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@", info[@"price"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%@", info[@"del_price"]] attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    cell.aLabel.attributedText = aString;
    
    
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
    
    GoodsDetailViewController *vc = [[GoodsDetailViewController alloc] initWithID:info[@"id"]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 30, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 30)),
            zh_backgroundColor: kColor_F5F5F5,
            zh_separatorColor: kColor_EAEAEA,
            zh_tableFooterView: [UIView new],
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
            zh_tableHeaderView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5)],
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
