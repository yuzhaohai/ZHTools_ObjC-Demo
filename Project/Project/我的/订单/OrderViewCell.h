//
//  OrderViewCell.h
//  Project
//
//  Created by 于兆海 on 2021/1/28.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderViewCell : BaseTableViewCell

- (void)setInfo:(NSDictionary *)info refoundType:(NSInteger)refoundType;

@property (nonatomic, copy) void (^amountDidChange) (NSDictionary *info, NSString *amount);
- (void)setExchangeOrderInfo:(NSDictionary *)info amount:(NSString *)amount;

@end

NS_ASSUME_NONNULL_END
