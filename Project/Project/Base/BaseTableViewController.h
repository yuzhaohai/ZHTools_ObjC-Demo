//
//  BaseTableViewController.h
//  Project
//
//  Created by HC101 on 2020/11/25.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <ZHTools_ObjC/ZHViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewController : ZHViewController

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIView *lineView;

@property (assign, nonatomic) BOOL needRefresh;

- (void)fetchRequest ;




@end

NS_ASSUME_NONNULL_END
