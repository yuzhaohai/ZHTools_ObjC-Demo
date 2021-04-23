//
//  ZHSelectViewController.m
//  Project
//
//  Created by 于兆海 on 2020/12/9.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "ZHSelectViewController.h"

@interface ZHSelectViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *_selectedObjects;
}

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ZHSelectViewController

- (instancetype)initWithSelectedObjects:(NSArray *)selectedObjects {
    self = [super init];
    if (self) {
        for (NSString *s in selectedObjects) {
            [self.selectedObjects addObject:s];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [UITableView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
        zh_backgroundColor: [UIColor whiteColor],
        zh_delegate: self,
        zh_dataSource: self,
        zh_superView: self.view,
        zh_tintColor: kColor_666666,
        zh_separatorColor: kColor_C3C3C3,
        zh_tableFooterView: [UIView new],
    }];
    
    [self.rightNavigationButton setPropertyWithDictionary:@{
        zh_normalTitle: @"  确定  ",
        zh_normalTitleColor: @"333333",
        zh_titleFont: @13
    }];
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor zh_colorWithHex:0x333333];
    }
    
    cell.textLabel.text = self.array[indexPath.row];
    
    cell.accessoryType = [self.selectedObjects containsObject:cell.textLabel.text] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *s = self.array[indexPath.row];
    if ([self.selectedObjects containsObject:s]) {
        [self.selectedObjects removeObject:s];
    } else {
        
        if (self.selectedObjects.count >= self.maxCount) {
            [SVProgressHUD showErrorWithStatus:@"已达到最大数量限制"];
            return;
        }
        
        [self.selectedObjects addObject:s];
    }
    
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSMutableArray *)selectedObjects {
    if (!_selectedObjects) {
        _selectedObjects = [NSMutableArray array];
    }
    return _selectedObjects;
}

@end
