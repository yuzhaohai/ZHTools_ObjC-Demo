//
//  OrderTableFooterView.h
//  Project
//
//  Created by 于兆海 on 2021/1/28.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrderTableFooterView : UITableViewHeaderFooterView

@property (copy, nonatomic) NSDictionary *info;

@property (nonatomic, copy) void (^refreshDataBlock) (void);

@property (nonatomic, copy) void (^payOrder) (NSDictionary *order);

@end

NS_ASSUME_NONNULL_END
