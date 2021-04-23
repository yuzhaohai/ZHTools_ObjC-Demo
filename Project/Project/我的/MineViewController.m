//
//  MineViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/22.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "MineViewController.h"
#import "OrderViewController.h"

@interface MineViewController ()

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSDictionary *user;

@property (copy, nonatomic) NSArray *array;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.needRefresh = YES;
    
    [self.view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, self.topBar.bottom + 87 + 19) color:[UIColor zh_colorWithHexString:kColor_Red]];
    
    self.avatarView = [UIImageView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(30, self.topBar.bottom, 88, 88)),
        zh_contentMode: @(UIViewContentModeScaleAspectFill),
        zh_backgroundColor: kColor_FFFFFF,
        zh_borderColor: kColor_FFFFFF,
        zh_superView: self.view,
        zh_cornerRadius: @44,
        zh_borderWidth: @1,
        zh_masksToBounds: @1,
        zh_image: [UIImage zh_appIcon]
    }];
    
    self.nameLabel = [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(self.avatarView.right + 19, self.avatarView.top, zh_ScreenWidth - self.avatarView.right - 19, self.avatarView.height)),
        zh_textColor: kColor_FFFFFF,
        zh_superView: self.view,
        zh_numberOfLines: @3,
        zh_font: @20,
    }];
    
    [self.view addSubview:self.tableView];
    
    NSArray *array = @[@"待付款", @"已付款", @"已发货", @"已完成", @"已取消"];
    CGFloat width = ceil(zh_ScreenWidth / array.count);
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(idx * width, 0, width, 80)),
            zh_superView: self.tableView.tableHeaderView,
            zh_normalTitleColor: kColor_666666,
            zh_backgroundColor: kColor_FFFFFF,
            zh_normalTitle: array[idx],
            zh_normalImage: array[idx],
            zh_titleFont: @13,
            zh_tag: @(idx)
        }];
        button.imageRect = CGRectMake(width / 2.0 - 15, 13.5, 30, 30);
        button.titleRect = CGRectMake(0, 53, width, 80 - 13.5 * 2 - 30 - 10);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self action:@selector(tappedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needRefresh) {
        [self fetchRequest];
        
        self.needRefresh = NO;
    }
    
    NSDictionary *responseObject = [AppDelegate appDelegate].userInfo;
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n\n%@", responseObject[kName], responseObject[@"phone"]];
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:responseObject[@"head"]]];
}

- (void)fetchRequest {
    [Util POST:@"/api/User/index" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            [AppDelegate appDelegate].userInfo = responseObject;
            
            self.nameLabel.text = [NSString stringWithFormat:@"%@\n\n%@", responseObject[kName], responseObject[@"phone"]];
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:responseObject[@"head"]]];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)tappedOrderButton:(UIButton *)button {
    [self.navigationController pushViewController:[[OrderViewController alloc] initWithIndex:button.tag] animated:YES];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.anImageView.frame = CGRectMake(12, 10, 24, 24);
                        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(46.5, 0, 168, 44)),
            zh_textColor: kColor_666666,
            zh_font: @14
        }];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more"]];
    }
    
    NSString *string = self.array[indexPath.row];
    
    cell.anImageView.image = [UIImage imageNamed:string];
    
    cell.label.text = string;
    
            
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
    NSArray *array = @[@"MyWalletViewController", @"AddressViewController", @"BuyAgainViewController", @"MyCollectionViewController", @"关于", @"MyInformationViewController", @"BankCardViewController", @"ExchangeOrderViewController"];
    
    NSString *vcName = array[indexPath.row];
    Class vcClass = NSClassFromString(vcName);
    
    if (vcClass) {
        
        [self.navigationController pushViewController:[vcClass new] animated:YES];
        
    } else if ([@"关于" isEqualToString:vcName]) {
        
        [Util POST:@"/api/Index/about" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
            if (responseObject) {
                LKWebViewController *vc = [[LKWebViewController alloc] init];
                vc.htmlString = responseObject[@"about_us"];
                vc.title = @"关于";
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        
    }
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.nameLabel.bottom + 19, zh_ScreenWidth, zh_ScreenHeight - self.nameLabel.bottom - 19 - zh_TabBar_HEIGHT)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [UIView new],
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
            
            zh_tableHeaderView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 85)]
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSArray *)array {
    if (!_array) {
        _array = @[@"我的钱包", @"收货地址", @"快速补货", @"商品收藏", @"关于", @"我的资料", @"银行卡", @"退货售后"];
    }
    return _array;
}

- (void)setNeedRefresh:(BOOL)needRefresh {
    [super setNeedRefresh:needRefresh];
}

@end
