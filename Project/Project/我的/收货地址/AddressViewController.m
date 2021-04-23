//
//  AddressViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "AddressViewController.h"
#import "EditAddressViewController.h"

@interface AddressViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;

@end

@implementation AddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的地址";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.tableView];
    
    CGFloat height = SafeAreaHeight * .8 + 44;
    ZHButton *button = [ZHButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_Red,
        zh_superView: self.view,
        zh_normalTitle: @"添加收货地址",
        zh_titleFont: @16,
        zh_tag: @(-1)
    }];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleRect = CGRectMake(0, 0, zh_ScreenWidth, 44 + SafeAreaHeight * .3);
    [button addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self fetchRequest];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/User/address_list" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            self.array = responseObject;
            
            [self.tableView reloadData];
        }
    }];
}

- (void)tappedEditButton:(UIButton *)button {
    EditAddressViewController *vc = [[EditAddressViewController alloc] initWithAddress:(button.tag == -1 ? nil : self.array[button.tag])];
    vc.operationSuccess = ^{
        [self fetchRequest];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tappedDeleteButton:(UIButton *)button {
    [Util POST:@"/api/User/address_del" showHUD:YES showResultAlert:YES parameters:@{
        @"address_id": self.array[button.tag][@"address_id"]
    } result:^(id responseObject) {
        if (responseObject) {
            [self fetchRequest];
        }
    }];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                                
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 0, zh_ScreenWidth - 10 - 100, 100)),
            zh_numberOfLines: @3,
        }];
        
        [cell.button setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 100, 0, 50, 100)),
            zh_normalTitleColor: kColor_999999,
            zh_normalTitle: @"编辑",
            zh_titleFont: @16
        }];
        [cell.button addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.aButton setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 50, 0, 50, 100)),
            zh_normalTitleColor: kColor_Red,
            zh_normalTitle: @"删除",
            zh_titleFont: @16
        }];
        [cell.aButton addTarget:self action:@selector(tappedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell zh_addLineWithFrame:CGRectMake(cell.aButton.left, 35, 1, 30) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    }
    
    NSInteger row = indexPath.row;
    NSDictionary *info = self.array[row];
        
    cell.aButton.tag = cell.button.tag = row;
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:info[@"person"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", info[@"phone"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    if ([info[@"is_default"] boolValue]) {
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"默认  " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    }
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@\n", info[@"province"], info[@"city"], info[@"district"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]}]];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:info[@"addr"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    
    cell.label.attributedText = aString;
                
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
    if (self.didSelect) {
        self.didSelect(self.array[indexPath.row]);
        
        [self goBack];
    }
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_tableHeaderView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5)],
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight * .8 + 44)],
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

@end
