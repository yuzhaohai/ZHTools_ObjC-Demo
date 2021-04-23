//
//  BillViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BillViewController.h"

@interface BillViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"账单";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.tableView];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                                
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, zh_ScreenWidth - 15 * 30, 55)),
            zh_numberOfLines: @2
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(cell.label.frame),
            zh_font: @15
        }];
    }
    
    BOOL flag = indexPath.row % 2 == 0;
    
    cell.aLabel.frame = CGRectMake(0, 0, zh_ScreenWidth, 55);
    cell.aLabel.text = flag ? @"+5.20" : @"-5.20";
    [cell.aLabel setPropertyWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 55)),
        zh_textColor: (flag ? kColor_333333 : kColor_Red),
        zh_text: (flag ? @"+5.20" : @"-5.20"),
    }];
    [cell.aLabel sizeToFit];
    cell.aLabel.frame = CGRectMake(zh_ScreenWidth - 15 - cell.aLabel.width, 0, cell.aLabel.width, 55);
    
    cell.label.frame = CGRectMake(15, 0, cell.aLabel.left - 15, 55);
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"订单红包\n" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"2021-01-04 15:31:40" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}]];
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
    
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight * .5)],
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
            
            zh_tableHeaderView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 5)]
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
