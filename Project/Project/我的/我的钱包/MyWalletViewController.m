//
//  MyWalletViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "MyWalletViewController.h"
#import "BillViewController.h"
#import "WithdrawViewController.h"

@interface MyWalletViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;

@property (copy, nonatomic) NSDictionary *userInfo;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的钱包";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.userInfo) {
        [self fetchRequest];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/User/index" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            [AppDelegate appDelegate].userInfo = responseObject;
            self.userInfo = responseObject;
            
            [self.tableView reloadData];
        }
    }];
}

- (void)tappedButton:(UIButton *)button {
    [AppDelegate appDelegate].userInfo = nil;
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.array[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 168, cell.height)),
            zh_textColor: kColor_000000,
            zh_font: @15
        }];
        
        [cell.anImageView setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 15 - 7, (cell.height - 7) / 2.0, 7, 7)),
            zh_image: @"more",
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(cell.label.right, 0, cell.anImageView.right - cell.label.right, cell.height)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_font: @15,
        }];
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSArray *array = self.array[section];
    NSString *string = array[row];
    
    cell.label.text = string;
    
    cell.aLabel.hidden = section % 2 != 0;
    cell.anImageView.hidden = section % 2 == 0;
        
    if (section == 0) {
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.userInfo[@"money"] ? : @"0"] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"元" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}]];
        cell.aLabel.attributedText = aString;
        
    } else if (section == 2) {
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.userInfo[@"money_red"] ? : @"0"] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"元" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}]];
        cell.aLabel.attributedText = aString;
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSArray *array = @[@[@"余额"], @[@"RechargeViewController", @"WithdrawViewController"], @[@"红包余额"], @[@"HongBaoRecordViewController"]];
    NSArray *aArray = array[section];
    NSString *vcName = aArray[row];
    
    Class vcClass = NSClassFromString(vcName);
    
    if (vcClass) {
        BaseViewController *vc = [vcClass new];
        if (section == 1) {
            ((WithdrawViewController *)vc).operationSuccessBlock = ^{
                [self fetchRequest];
            };
        }
        
        [self.navigationController pushViewController:[vcClass new] animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5)];
}

- (void)uploadImage:(ZLPhotoAssets*)assets{
    
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [UIView new],
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

- (NSArray *)array {
    if (!_array) {
        _array = @[@[@"余额"], @[@"充值", @"提现"], @[@"红包余额"], @[@"红包记录"]];
    }
    return _array;
}

@end
